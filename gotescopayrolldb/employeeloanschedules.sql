/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `employeeloanschedules`;
CREATE TABLE `employeeloanschedules` (
	`RowID` INT(11) NOT NULL,
	`OrganizationID` INT(11) NOT NULL,
	`Created` TIMESTAMP NOT NULL,
	`CreatedBy` INT(11) NULL,
	`LastUpd` DATETIME NULL,
	`LastUpdBy` INT(11) NULL,
	`EmployeeID` INT(11) NULL,
	`LoanNumber` VARCHAR(50) NULL COLLATE 'latin1_swedish_ci',
	`DedEffectiveDateFrom` DATE NULL,
	`DedEffectiveDateTo` DATE NULL,
	`TotalLoanAmount` DECIMAL(10,2) NULL,
	`DeductionSchedule` VARCHAR(50) NULL COLLATE 'latin1_swedish_ci',
	`TotalBalanceLeft` DECIMAL(10,2) NULL,
	`DeductionAmount` DECIMAL(10,2) NULL,
	`Status` VARCHAR(50) NULL COLLATE 'latin1_swedish_ci',
	`LoanTypeID` INT(11) NULL,
	`DeductionPercentage` DECIMAL(10,2) NULL,
	`NoOfPayPeriod` DECIMAL(10,2) NULL,
	`LoanPayPeriodLeft` DECIMAL(10,2) NULL,
	`Comments` TEXT NULL COLLATE 'latin1_swedish_ci',
	`Nondeductible` CHAR(1) NULL COLLATE 'latin1_swedish_ci',
	`ReferenceLoanID` INT(11) NULL,
	`SubstituteEndDate` DATE NULL,
	`PayStubID` INT(11) NULL,
	`PayPeriodID` INT(11) NOT NULL,
	`Year` CHAR(4) NULL COLLATE 'latin1_swedish_ci',
	`Month` INT(11) NULL,
	`OrdinalValue` INT(11) NULL,
	`PayFromDate` DATE NULL,
	`PayToDate` DATE NULL
) ENGINE=MyISAM;

DROP VIEW IF EXISTS `employeeloanschedules`;
DROP TABLE IF EXISTS `employeeloanschedules`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `employeeloanschedules` AS SELECT els.*
	
	, pp.RowID `PayPeriodID`
	, pp.`Year`
	, pp.`Month`
	, pp.OrdinalValue
	, pp.PayFromDate
	, pp.PayToDate
	
	FROM employeeloanschedule els
	INNER JOIN employee e ON e.RowID=els.EmployeeID AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
	INNER JOIN dates d ON d.DateValue BETWEEN els.DedEffectiveDateFrom AND els.DedEffectiveDateTo
	INNER JOIN organization og ON og.RowID=els.OrganizationID AND og.NoPurpose=FALSE
	INNER JOIN payperiod pp ON pp.OrganizationID=e.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID AND d.DateValue BETWEEN pp.PayFromDate AND pp.PayToDate AND pp.Half=0
	WHERE els.DeductionSchedule = 'End of the month'

UNION
	SELECT els.*
	
	, pp.RowID `PayPeriodID`
	, pp.`Year`
	, pp.`Month`
	, pp.OrdinalValue
	, pp.PayFromDate
	, pp.PayToDate
	
	FROM employeeloanschedule els
	INNER JOIN employee e ON e.RowID=els.EmployeeID AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
	INNER JOIN dates d ON d.DateValue BETWEEN els.DedEffectiveDateFrom AND els.DedEffectiveDateTo
	INNER JOIN organization og ON og.RowID=els.OrganizationID AND og.NoPurpose=FALSE
	INNER JOIN payperiod pp ON pp.OrganizationID=e.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID AND d.DateValue BETWEEN pp.PayFromDate AND pp.PayToDate AND pp.Half=1
	WHERE els.DeductionSchedule = 'First half'
	
	/*
	TO DO:
	SET @_rowid = 0;
	SET @isnotequal = FALSE;
	SET @bal = 0.00;
	SET @decrem = 0;
	
	SELECT els.*
	
	, (@isnotequal := (@_rowid != els.RowID)) `IsNotEqual`
	
	, IF(@isnotequal
	     , (@_rowid := els.RowID)
		  , @_rowid) `CustomRowID`
	
	,IF(@isnotequal = TRUE
	    , (@bal := (els.TotalLoanAmount - els.DeductionAmount))
		 , ROUND((@bal := (@bal - els.DeductionAmount)), 6)
		 ) `RunningBalance`
	
	,IF(@isnotequal = TRUE
	    , (@decrem := els.NoOfPayPeriod - 1)
		 , (@decrem := @decrem - 1)
		 ) `DecrementNumOfPayperiod`
	
	, IF(@bal != 0 AND @decrem = 0
	     , ROUND((els.DeductionAmount + (@bal)), 6)
		  , els.DeductionAmount) `CorrectedDeductionAmount`
	
	FROM employeeloanschedules els
	WHERE els.OrganizationID = 1
	# AND els.PayStubID=892
	# AND els.RowID BETWEEN 300 AND 310
	ORDER BY els.RowID, els.EmployeeID, els.`Year`, els.`Month`#, els.OrdinalValue
	;
	*/
	
UNION
	SELECT els.*
	
	, pp.RowID `PayPeriodID`
	, pp.`Year`
	, pp.`Month`
	, pp.OrdinalValue
	, pp.PayFromDate
	, pp.PayToDate
	
	FROM employeeloanschedule els
	INNER JOIN employee e ON e.RowID=els.EmployeeID AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
	INNER JOIN dates d ON d.DateValue BETWEEN els.DedEffectiveDateFrom AND els.DedEffectiveDateTo
	INNER JOIN organization og ON og.RowID=els.OrganizationID AND og.NoPurpose=FALSE
	INNER JOIN payperiod pp ON pp.OrganizationID=e.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID AND d.DateValue BETWEEN pp.PayFromDate AND pp.PayToDate AND pp.Half IN (0, 1)
	WHERE els.DeductionSchedule = 'Per pay period' ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
