/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `RPT_LoansByType`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `RPT_LoansByType`(IN `og_rowid` INT, IN `pay_datefrom` DATE, IN `pay_dateto` DATE, IN `loan_typeid` INT)
BEGIN

DECLARE decimal_size INT(11) DEFAULT 2;

SET @_rowid = NULL;

SET @_index = 0;

SET @enddate = NULL;

SELECT ls.RowID
,ls.`Column1`
,ls.`Column2`
,ls.`Column3`
,ls.`Column4`

,ls.`PayFromDate`

,SUM(ls.`Column5`) `Column5`
,SUM(ls.`Column6`) `Column6`

,DATE_FORMAT(ls.`PayToDate`, '%c/%e/%Y') `Column5`
FROM (SELECT i.*
		, pp.PayFromDate
		, pp.PayToDate
		
		,(@enddate := PAYTODATE_OF_NoOfPayPeriod(i.DedEffectiveDateFrom, i.NoOfPayPeriod, e.RowID, i.DeductionSchedule)) `LoanEffectiveEndDate`
		
		,e.EmployeeID `Column2`
		,(@_midinit := LEFT(e.MiddleName, 1))
		
		,PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName, IF(LENGTH(@_midinit) = 0, NULL, @_midinit))) `Column3`
		
		,p.PartNo `Column1`
		
		,i.TotalLoanAmount `Column4`
		
      ,ROUND(i.DeductionAmount, decimal_size) `Column5`
      
      ,ROUND(IFNULL(lb.Balance, 0), decimal_size) `Column6`
      
		FROM employeeloanschedule i
		INNER JOIN employee e ON e.RowID=i.EmployeeID AND e.OrganizationID=i.OrganizationID AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
		
		INNER JOIN payperiod pp
		        ON pp.OrganizationID=i.OrganizationID
		           AND pp.TotalGrossSalary=e.PayFrequencyID
				     /*AND (i.DedEffectiveDateFrom >= pp.PayFromDate OR @enddate >= pp.PayFromDate)
				     AND (i.DedEffectiveDateFrom <= pp.PayToDate OR @enddate <= pp.PayToDate)*/
					  AND (i.DedEffectiveDateFrom >= pay_datefrom OR PAYTODATE_OF_NoOfPayPeriod(i.DedEffectiveDateFrom, i.NoOfPayPeriod, e.RowID, i.DeductionSchedule) >= pay_datefrom)
					  AND (i.DedEffectiveDateFrom <= pay_dateto OR PAYTODATE_OF_NoOfPayPeriod(i.DedEffectiveDateFrom, i.NoOfPayPeriod, e.RowID, i.DeductionSchedule) <= pay_dateto)
					  AND (pp.PayFromDate >= pay_datefrom OR pp.PayToDate >=pay_datefrom)
					  AND (pp.PayFromDate <= pay_dateto OR pp.PayToDate <=pay_dateto)
					
		INNER JOIN product p ON p.RowID=i.LoanTypeID
		
		INNER JOIN paystub ps
		        ON ps.OrganizationID=e.OrganizationID
		           AND ps.EmployeeID=e.RowID
		           AND ps.PayPeriodID=pp.RowID
		
		INNER JOIN employeeloanschedulebacktrack lb ON lb.LoanschedID=i.RowID AND lb.PayStubID=ps.RowID
		
		WHERE i.OrganizationID = og_rowid
		AND i.LoanTypeID = IFNULL(loan_typeid, i.LoanTypeID)
		
		AND i.RowID NOT IN (SELECT ReferenceLoanID
		                    FROM employeeloanschedule
		                    WHERE OrganizationID=og_rowid
		                    AND ReferenceLoanID IS NOT NULL
							     AND (DedEffectiveDateFrom >= pay_datefrom OR DedEffectiveDateTo >= pay_datefrom)
							     AND (DedEffectiveDateFrom <= pay_dateto OR DedEffectiveDateTo <= pay_dateto)
		                    )
		ORDER BY i.RowID, pp.OrdinalValue, p.PartNo
		) ls
GROUP BY ls.RowID
ORDER BY ls.`Column1`, ls.`Column3`
;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
