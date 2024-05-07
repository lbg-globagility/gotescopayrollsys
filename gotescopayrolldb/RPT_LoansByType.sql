/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP PROCEDURE IF EXISTS `RPT_LoansByType`;
DELIMITER //
CREATE PROCEDURE `RPT_LoansByType`(
	IN `og_rowid` INT,
	IN `pay_datefrom` DATE,
	IN `pay_dateto` DATE,
	IN `loan_typeid` INT,
	IN `loan_typeids` TEXT
)
BEGIN

SET @orgId=og_rowid;
SET @datefrom=pay_datefrom;
SET @dateto=pay_dateto;

CALL `LoanPrediction`(@orgId);

SELECT
/*ls.RowID			i.RowID
,ls.`Column1`			,p.PartNo `Column1`
,ls.`Column2`			,e.EmployeeID `Column2`
,ls.`Column3`			,PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName, IF(LENGTH(@_midinit) = 0, NULL, @_midinit))) `Column3`
,ls.`Column4`			,i.TotalLoanAmount `Column4`

,ls.`PayFromDate`		, pp.PayFromDate
				, pp.PayToDate
,SUM(ls.`Column5`) `Column5`	,ROUND(i.DeductionAmount, decimal_size) `Column5`
,SUM(ls.`Column6`) `Column6`	,ROUND(IFNULL(lb.Balance, 0), decimal_size) `Column6`

,DATE_FORMAT(ls.`PayToDate`, '%c/%e/%Y') `Column5`
*/
ii.RowID,
ii.PartNo `Column1`,
ii.EmployeeID `Column2`,
ii.`FullName` `Column3`,
ii.TotalLoanAmount `Column4`,
ii.DeductionAmount `Column5`,
#i.LoanBalance `Column6`,
ii.TotalBalanceLeft `Column6`,
ii.PayFromDate
FROM (SELECT
		i.RowID,
		e.EmployeeID,
		CONCAT_WS(', ', e.LastName, e.FirstName) `FullName`,
		p.PartNo,
		pp.`Year`,
		pp.OrdinalValue,
		i.TotalLoanAmount,
		i.DeductionAmount,
		i.TotalBalanceLeft,
		i.PayFromDate,
		i.PayToDate
		FROM loanpredict i
		INNER JOIN payperiod pp ON pp.RowID=i.PayPeriodId
		INNER JOIN employee e ON e.RowID=i.EmployeeID
		INNER JOIN product p ON p.RowID=i.LoanTypeId
		WHERE ((@datefrom <= i.PayFromDate AND @dateto <= i.PayToDate)
		AND (i.PayFromDate <= @dateto AND i.PayToDate <= @dateto))
		
		AND IF(pp.Half=0, i.DeductionSchedule IN ('End of the month', 'Per pay period'), i.DeductionSchedule IN ('First half', 'Per pay period'))
		
#		AND i.LoanTypeId=IFNULL(loan_typeid, i.LoanTypeId)
		AND FIND_IN_SET(i.LoanTypeId, loan_typeids) > 0
		AND LCASE(i.`Status`) IN ('in progress', 'complete')
UNION
		SELECT
		i.RowID,
		e.EmployeeID,
		CONCAT_WS(', ', e.LastName, e.FirstName) `FullName`,
		p.PartNo,
		pp.`Year`,
		pp.OrdinalValue,
		i.TotalLoanAmount,
		i.DeductionAmount,
		i.TotalBalanceLeft,
		i.PayFromDate,
		i.PayToDate
		FROM loanpredict i
		INNER JOIN payperiod pp ON pp.RowID=i.PayPeriodId
		INNER JOIN employee e ON e.RowID=i.EmployeeID
		INNER JOIN product p ON p.RowID=i.LoanTypeId
		WHERE ((@datefrom BETWEEN i.DedEffectiveDateFrom AND i.SubstituteEndDate) OR
				(@dateto BETWEEN i.DedEffectiveDateFrom AND i.SubstituteEndDate))
		
		AND IF(pp.Half=0, i.DeductionSchedule IN ('End of the month', 'Per pay period'), i.DeductionSchedule IN ('First half', 'Per pay period'))
		
#		AND i.LoanTypeId=IFNULL(loan_typeid, i.LoanTypeId)
		AND FIND_IN_SET(i.LoanTypeId, loan_typeids) > 0
		AND LCASE(i.`Status`) = 'cancelled'
		) ii

ORDER BY ii.`FullName`, ii.`PartNo`, ii.`Year`, ii.OrdinalValue
;

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
