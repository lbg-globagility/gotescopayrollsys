/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP PROCEDURE IF EXISTS `LoanPrediction`;
DELIMITER //
CREATE PROCEDURE `LoanPrediction`(
	IN `organizID` INT
)
BEGIN

/*
UPDATE employeeloanschedule els
SET els.DedEffectiveDateTo = `PAYTODATE_OF_NoOfPayPeriod`(els.DedEffectiveDateFrom, els.NoOfPayPeriod, els.EmployeeID, els.DeductionSchedule)
, els.LastUpd = IFNULL(ADDDATE(els.LastUpd, INTERVAL 1 SECOND), CURRENT_TIMESTAMP());
*/

SET @elsID = 0;
SET @isAnotherID = FALSE;
SET @totalLoan = 0.00;
SET @ordinalIndex = 0;
SET @propDeductAmt = 0.00;
SET @progInterval = 0;
SET @progAmt = 0.00;
SET @isLast = FALSE;

SET @loanBalans = 0.00;

DROP TEMPORARY TABLE IF EXISTS loanpredict;
DROP TABLE IF EXISTS loanpredict;
CREATE TEMPORARY TABLE loanpredict
SELECT i.*
, (@isAnotherID := @elsID != i.RowID) `IsAnother`
, IF(@isAnotherID, (@elsID := i.RowID), @elsID) `AssignAnotherID`

, IF(@isAnotherID
		, @ordinalIndex := 1
		, @ordinalIndex := @ordinalIndex + 1) `OrdinalIndex`
#, @isLast := (@totalLoan <= 0 AND @ordinalIndex = i.NoOfPayPeriod) `IsLast`
, @isLast := FLOOR(@ordinalIndex / i.NoOfPayPeriod) `IsLast`

, @progAmt := @ordinalIndex / i.NoOfPayPeriod `Progress`

, TRIM(
		IF(@isAnotherID
	      , @progInterval := @progAmt
		   , @progInterval := @progAmt - ((@ordinalIndex - 1) / i.NoOfPayPeriod)
		   ))+0 `ProgressInterval`

, @properDeduction:=IF(@isLast=FALSE
		, i.DeductionAmount
		, IF((i.TotalLoanAmount / i.DeductionAmount) < i.NoOfPayPeriod,
			(i.DeductionAmount * ((i.TotalLoanAmount / i.DeductionAmount) MOD 1)),
			IF((i.TotalLoanAmount / i.DeductionAmount) > i.NoOfPayPeriod,
				(i.DeductionAmount * ((i.TotalLoanAmount / i.DeductionAmount) - (i.NoOfPayPeriod-1))),
				i.DeductionAmount))) `ProperDeductAmount`

, @loanBalans :=
 TRIM(
   IF(@isAnotherID
		, (@totalLoan := IF(i.TotalLoanAmount - i.DeductionAmount < 0, 0, i.TotalLoanAmount - i.DeductionAmount))
		, (@totalLoan := IF(@totalLoan - @properDeduction < 0, 0, ROUND(@totalLoan - @properDeduction, 2))))
		)+0 `LoanBalance`

FROM (SELECT els.`RowID`, els.`OrganizationID`, els.`Created`, els.`CreatedBy`, els.`LastUpd`, els.`LastUpdBy`, els.`EmployeeID`, els.`LoanNumber`, els.`DedEffectiveDateFrom`, els.`DedEffectiveDateTo`, els.`TotalLoanAmount`, els.`DeductionSchedule`, els.`TotalBalanceLeft`, IFNULL(els.OriginDeductionAmount, els.`DeductionAmount`) `DeductionAmount`, els.`Status`, els.`LoanTypeID`, els.`DeductionPercentage`, els.`NoOfPayPeriod`, els.`LoanPayPeriodLeft`, els.`Comments`, els.`Nondeductible`, els.`ReferenceLoanID`, els.`SubstituteEndDate`, els.`PayStubID`, els.`DiscontinuedDate`
		, pp.RowID `PayperiodID`, pp.PayFromDate, pp.PayToDate
		, e.EmployeeID `EmployeeUniqueID`
		, CONCAT_WS(', ', e.LastName, e.FirstName) `FullName`
		FROM employeeloanschedule els
		INNER JOIN employee e ON e.RowID=els.EmployeeID
		INNER JOIN payperiod pp ON pp.OrganizationID=els.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID
#		AND (pp.PayFromDate >= els.DedEffectiveDateFrom AND pp.PayToDate <= IFNULL(els.DiscontinuedDate, els.DedEffectiveDateTo))
		AND (((pp.PayFromDate >= els.DedEffectiveDateFrom AND pp.PayToDate <= IFNULL(els.DiscontinuedDate, els.DedEffectiveDateTo)) AND 
		((pp.Half = 0 AND els.DeductionSchedule = 'End of the month')
		OR (pp.Half = 1 AND els.DeductionSchedule = 'First half')
		OR (pp.Half IN (0, 1) AND els.DeductionSchedule = 'Per pay period')))
			OR (els.NoOfPayPeriod = 1 AND IFNULL(els.DiscontinuedDate, els.DedEffectiveDateTo) BETWEEN pp.PayFromDate AND pp.PayToDate))
		/*AND IF(els.NoOfPayPeriod = 1 AND els.DeductionSchedule = 'Per pay period'
				, (els.DedEffectiveDateFrom BETWEEN pp.PayFromDate AND pp.PayToDate)
				, (pp.PayFromDate >= els.DedEffectiveDateFrom AND pp.PayToDate <= IFNULL(els.DiscontinuedDate, els.DedEffectiveDateTo))
				)*/

		WHERE els.OrganizationID = organizID
		AND els.`Status` NOT IN ('Cancelled')
		AND els.NoOfPayPeriod > 0
		ORDER BY els.RowID, pp.`Year`, pp.OrdinalValue
		) i
;
/*
Per pay period
End of the month
First half

UPDATE loanpredict i
INNER JOIN employeeloanschedulebacktrack ii ON ii.EmployeeID=i.EmployeeID AND ii.OrganizationID=i.OrganizationID AND ii.LoanschedID=i.RowID
INNER JOIN paystub ps ON ps.RowID=ii.PayStubID
INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID AND pp.RowID=i.PayperiodID
SET ii.Balance = i.LoanBalance
, ii.CountPayPeriodLeft = ROUND((i.LoanBalance / i.TotalLoanAmount) * i.NoOfPayPeriod, 2)
, ii.DeductedAmount = IF(i.IsLast, (ii.DeductedAmount + i.LoanBalance), ii.DeductedAmount)
#WHERE i.FullName LIKE '%Bernal%'
;
*/

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
