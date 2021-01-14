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

DECLARE strloantype TEXT;

DECLARE pp_rowid INT(11);

SELECT pp.RowID FROM payperiod pp WHERE pp.OrganizationID=OrganizID AND pp.PayFromDate=PayDateFrom AND pp.PayToDate=PayDateTo AND pp.TotalGrossSalary=1 LIMIT 1 INTO pp_rowid;

SELECT PartNo FROM product WHERE RowID=LoanTypeID INTO strloantype;

# SELECT

/*elh.Comments
,ee.EmployeeID
,CONCAT(ee.LastName,',',ee.FirstName, IF(ee.MiddleName='','',','),INITIALS(ee.MiddleName,'. ','1')) 'Fullname'
,FORMAT(SUM(IFNULL(elh.DeductionAmount,0)),2) 'DeductionAmount'
,els.TotalLoanAmount
,els.TotalBalanceLeft*/

# elh.*,

/*ee.EmployeeID `DatCol1`
,CONCAT_WS('', ee.LastName, ee.FirstName, LEFT(ee.MiddleName, 1)) `DatCol2`
,elh.Comments `DatCol3`
,FORMAT(SUM(IFNULL(elh.DeductionAmount,0)),2) `DatCol4`
FROM employeeloanhistory elh
INNER JOIN paystub ps ON ps.RowID=elh.PayStubID AND ps.OrganizationID=elh.OrganizationID
INNER JOIN employee ee ON ee.RowID=ps.EmployeeID AND ee.OrganizationID=elh.OrganizationID
INNER JOIN employeeloanschedule els ON els.LoanTypeID=IFNULL(LoanTypeID, els.LoanTypeID) AND els.OrganizationID=OrganizID AND (els.DedEffectiveDateFrom>=PayDateFrom OR els.DedEffectiveDateTo>=PayDateFrom) AND (els.DedEffectiveDateFrom<=PayDateTo OR els.DedEffectiveDateTo<=PayDateTo)
WHERE elh.DeductionAmount!=0
AND elh.OrganizationID=OrganizID
AND elh.DeductionDate BETWEEN PayDateFrom AND PayDateTo
# AND elh.Comments=strloantype
GROUP BY elh.EmployeeID, elh.Comments, els.RowID
# GROUP BY elh.EmployeeID, els.LoanTypeID
ORDER BY elh.Comments,ee.LastName;*/

# ###############################

SELECT psiloan.*
FROM (SELECT # ii.*
      /*,GROUP_CONCAT(ii.LoanName) `Column35`
      ,GROUP_CONCAT(ROUND(ii.DeductionAmount, 2)) `Column38`
      ,GROUP_CONCAT(ROUND(ii.BalanceOfLoan, 2)) `Column33`*/
      
      ii.EmployeeUniqueId `DatCol1`
		,ii.FullName `DatCol2`
		,ii.LoanName `DatCol3`
		,FORMAT(ii.DeductionAmount, 2) `DatCol4`

      FROM (SELECT i.RowID
				,i.EmployeeID
				,i.TotalLoanAmount
				,i.ppRowID
				,i.psRowID
				,(i.TotalLoanAmount - SUM(i.Deduction)) `BalanceOfLoan`
				,i.LoanName
				,MAX(i.DeductionAmount) `DeductionAmount`
				,i.EmployeeUniqueId
				,i.FullName
				FROM (SELECT
						els.RowID
						,els.OrganizationID
						,els.EmployeeID
						,els.TotalLoanAmount
						,pp.RowID `ppRowID`
						,pp.PayFromDate
						,pp.PayToDate
						,pp.OrdinalValue
						,
						(@_ordinal := (@_ordinal + 1)) `AscOrder`
						
						,(@_deduction :=
						 IF(@_ordinal = els.NoOfPayPeriod
						    , ( els.DeductionAmount + (els.TotalLoanAmount - (els.DeductionAmount * els.NoOfPayPeriod)) )
							 , els.DeductionAmount)) `Deduction`
						
						,IF(pp.RowID = pp_rowid, @_deduction, 0) `DeductionAmount`
						
						,ps.RowID `psRowID`
						,e.EmployeeID `EmployeeUniqueId`
						,p.PartNo `LoanName`
						,CONCAT_WS(', ', e.LastName, e.FirstName, LEFT(e.MiddleName, 1)) `FullName`
						FROM employeeloanschedule els
						INNER JOIN employee e ON e.RowID=els.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated') AND e.OrganizationID=els.OrganizationID
						INNER JOIN payperiod pp ON pp.OrganizationID=els.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID
						AND (els.DedEffectiveDateFrom >= pp.PayFromDate OR els.DedEffectiveDateTo >= pp.PayFromDate)
						AND (els.DedEffectiveDateFrom <= pp.PayToDate OR els.DedEffectiveDateTo <= pp.PayToDate)
						
						LEFT JOIN paystub ps ON ps.OrganizationID=els.OrganizationID AND ps.EmployeeID=els.EmployeeID AND ps.PayPeriodID=pp.RowID
						
						INNER JOIN product p ON p.RowID=els.LoanTypeID
						
						WHERE els.RowID > 0
						AND els.OrganizationID=OrganizID
						# paydate_from paydat_to
						AND (els.DedEffectiveDateFrom >= PayDateFrom OR els.DedEffectiveDateTo >= PayDateFrom)
						AND (els.DedEffectiveDateFrom <= PayDateTo OR els.DedEffectiveDateTo <= PayDateTo)
						ORDER BY pp.OrdinalValue
				      ) i
				WHERE i.psRowID IS NOT NULL
				GROUP BY i.RowID
		      ) ii
	  GROUP BY ii.EmployeeID
     ) psiloan
# WHERE psiloan.EmployeeID = 55
;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
