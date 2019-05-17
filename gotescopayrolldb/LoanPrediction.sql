/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `LoanPrediction`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LoanPrediction`(
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

SET @loanBalans = 0.00;

DROP TEMPORARY TABLE IF EXISTS loanpredict;
DROP TABLE IF EXISTS loanpredict;
CREATE TEMPORARY TABLE loanpredict
SELECT i.*
, (@isAnotherID := @elsID != i.RowID) `IsAnother`
, IF(@isAnotherID, (@elsID := i.RowID), @elsID) `AssignAnotherID`

, @loanBalans :=
 TRIM(
   IF(@isAnotherID
		, (@totalLoan := i.TotalLoanAmount - i.DeductionAmount)
		, (@totalLoan := @totalLoan - i.DeductionAmount))
		)+0 `LoanBalance`

, IF(@isAnotherID
		, @ordinalIndex := 1
		, @ordinalIndex := @ordinalIndex + 1) `OrdinalIndex`
, (@totalLoan <= 0 AND @ordinalIndex = i.NoOfPayPeriod) `IsLast`

, @progAmt := @ordinalIndex / i.NoOfPayPeriod `Progress`

, TRIM(
  IF(@isAnotherID
     , @progInterval := @progAmt
	  , @progInterval := @progAmt - ((@ordinalIndex - 1) / i.NoOfPayPeriod)
	  ))+0 `ProgressInterval`

, TRIM(
  IF(@loanBalans < 0
     , ROUND((@progInterval * i.TotalLoanAmount) + @loanBalans, 2)
     , ROUND(@progInterval * i.TotalLoanAmount, 2)
	  ))+0 `ProperDeductAmount`

FROM (SELECT els.*
		, pp.RowID `PayperiodID`, pp.PayFromDate, pp.PayToDate
		, e.EmployeeID `EmployeeUniqueID`
		, CONCAT_WS(', ', e.LastName, e.FirstName) `FullName`
		FROM employeeloanschedule els
		INNER JOIN employee e ON e.RowID=els.EmployeeID
		INNER JOIN payperiod pp ON pp.OrganizationID=els.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID
		AND (pp.PayFromDate >= els.DedEffectiveDateFrom AND pp.PayToDate <= IFNULL(els.DiscontinuedDate, els.DedEffectiveDateTo))
		WHERE els.OrganizationID = organizID
		ORDER BY els.RowID, pp.`Year`, pp.OrdinalValue
		) i
;
/*
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

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
