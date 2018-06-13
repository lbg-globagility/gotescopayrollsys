/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `RPT_loansummary`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `RPT_loansummary`(IN `og_rowid` INT, IN `pay_datefrom` DATE, IN `pay_dateto` DATE, IN `loan_typeid` INT)
BEGIN

SET @_rowid = NULL;

SET @_index = 0;

/*
ii.EmployeeUniqueId `DatCol1`
,ii.FullName `DatCol2`
,ii.LoanName `DatCol3`
,FORMAT(ii.DeductionAmount, 2) `DatCol4`
*/

/*SELECT ls.RowID
,ls.`DatCol1`
,ls.`DatCol2`
,ls.`DatCol3`
,ls.`DatCol4`

,ls.`PayFromDate`
,ls.`PayToDate`
FROM (SELECT i.*
		, pp.PayFromDate
		, pp.PayToDate
		,(@enddate := PAYTODATE_OF_NoOfPayPeriod(i.DedEffectiveDateFrom, i.NoOfPayPeriod, e.RowID, i.DeductionSchedule)) `LoanEffectiveEndDate`
		,e.EmployeeID `DatCol1`
		,(@_midinit := LEFT(e.MiddleName, 1))
		,CONCAT_WS(', ', e.LastName, e.FirstName, IF(LENGTH(@_midinit) = 0, NULL, @_midinit)) `DatCol2`
		,p.PartNo `DatCol3`
      ,FORMAT(i.DeductionAmount, 2) `DatCol4`
		FROM view_loans i
		INNER JOIN employee e ON e.RowID=i.EmployeeID AND e.OrganizationID=i.OrganizationID
		
		INNER JOIN payperiod pp
		        ON pp.OrganizationID=i.OrganizationID
		           AND pp.TotalGrossSalary=e.PayFrequencyID
					  AND (i.DedEffectiveDateFrom >= pay_datefrom OR PAYTODATE_OF_NoOfPayPeriod(i.DedEffectiveDateFrom, i.NoOfPayPeriod, e.RowID, i.DeductionSchedule) >= pay_datefrom)
					  AND (i.DedEffectiveDateFrom <= pay_dateto OR PAYTODATE_OF_NoOfPayPeriod(i.DedEffectiveDateFrom, i.NoOfPayPeriod, e.RowID, i.DeductionSchedule) <= pay_dateto)
					  AND (pp.PayFromDate >= pay_datefrom OR pp.PayToDate >=pay_datefrom)
					  AND (pp.PayFromDate <= pay_dateto OR pp.PayToDate <=pay_dateto)
					
		INNER JOIN product p ON p.RowID=i.LoanTypeID
		
		INNER JOIN paystub ps
		        ON ps.OrganizationID=e.OrganizationID
		           AND ps.EmployeeID=e.RowID
		           AND ps.PayPeriodID=pp.RowID
		
		WHERE i.OrganizationID = og_rowid
		AND i.LoanTypeID = IFNULL(loan_typeid, i.LoanTypeID)
		
		ORDER BY i.RowID, i.ReferenceLoanID, pp.OrdinalValue, p.PartNo
		) ls
ORDER BY ls.`DatCol2`
;*/

# #######################################

SET @enddate = NULL;

SELECT ls.RowID
,ls.`DatCol1`
,ls.`DatCol2`
,ls.`DatCol3`
,ls.`DatCol4`

,ls.`PayFromDate`
,DATE_FORMAT(ls.`PayToDate`, '%c/%e/%Y') `DatCol5`
FROM (SELECT i.*
		, pp.PayFromDate
		, pp.PayToDate
		# , (@_index := IF(@_index < i.NoOfPayPeriod, (@_index + 1), 0)) `Index`
		,(@enddate := PAYTODATE_OF_NoOfPayPeriod(i.DedEffectiveDateFrom, i.NoOfPayPeriod, e.RowID, i.DeductionSchedule)) `LoanEffectiveEndDate`
		# ,@enddate `LoanEffectiveEndDate`
		,e.EmployeeID `DatCol1`
		,(@_midinit := LEFT(e.MiddleName, 1))
		,CONCAT_WS(', ', e.LastName, e.FirstName, IF(LENGTH(@_midinit) = 0, NULL, @_midinit)) `DatCol2`
		,p.PartNo `DatCol3`
      ,FORMAT(i.DeductionAmount, 2) `DatCol4`
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
ORDER BY ls.`DatCol2`
;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
