/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `RPT_loans`;
DELIMITER //
CREATE PROCEDURE `RPT_loans`(IN `OrganizID` INT, IN `PayDateFrom` DATE, IN `PayDateTo` DATE, IN `LoanTypeID` INT)
    DETERMINISTIC
BEGIN

SET @orgId=OrganizID;
SET @datefrom=PayDateFrom;
SET @dateto=PayDateTo;

CALL `LoanPrediction`(@orgId);

SELECT
ii.*
FROM (SELECT
		e.EmployeeID `DatCol`,
		CONCAT_WS(', ', e.LastName, e.FirstName) `DatCol2`,
		p.PartNo `DatCol3`,
		i.DeductionAmount `DatCol4`,
		pp.`Year`,
		pp.OrdinalValue
		FROM loanpredict i
		INNER JOIN payperiod pp ON pp.RowID=i.PayPeriodId
		INNER JOIN employee e ON e.RowID=i.EmployeeID
		INNER JOIN product p ON p.RowID=i.LoanTypeId
		WHERE ((@datefrom <= i.PayFromDate AND @dateto <= i.PayToDate)
		AND (i.PayFromDate <= @dateto AND i.PayToDate <= @dateto))
		
		AND IF(pp.Half=0, i.DeductionSchedule IN ('End of the month', 'Per pay period'), i.DeductionSchedule IN ('First half', 'Per pay period'))
		
		AND i.LoanTypeId=IFNULL(LoanTypeID, i.LoanTypeId)
		AND LCASE(i.`Status`) IN ('in progress', 'complete')
UNION
		SELECT
		e.EmployeeID `DatCol`,
		CONCAT_WS(', ', e.LastName, e.FirstName) `DatCol2`,
		p.PartNo `DatCol3`,
		i.DeductionAmount `DatCol4`,
		pp.`Year`,
		pp.OrdinalValue
		FROM loanpredict i
		INNER JOIN payperiod pp ON pp.RowID=i.PayPeriodId
		INNER JOIN employee e ON e.RowID=i.EmployeeID
		INNER JOIN product p ON p.RowID=i.LoanTypeId
		WHERE ((@datefrom BETWEEN i.DedEffectiveDateFrom AND i.SubstituteEndDate) OR
				(@dateto BETWEEN i.DedEffectiveDateFrom AND i.SubstituteEndDate))
		
		AND IF(pp.Half=0, i.DeductionSchedule IN ('End of the month', 'Per pay period'), i.DeductionSchedule IN ('First half', 'Per pay period'))
		
		AND i.LoanTypeId=IFNULL(LoanTypeID, i.LoanTypeId)
		AND LCASE(i.`Status`) = 'cancelled'
		) ii

ORDER BY ii.`DatCol2`, ii.`DatCol3`, ii.`Year`, ii.OrdinalValue
;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
