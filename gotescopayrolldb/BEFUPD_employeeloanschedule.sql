-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.5.5-10.0.12-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             8.3.0.4694
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for trigger gotescopayrolldb_server.BEFUPD_employeeloanschedule
DROP TRIGGER IF EXISTS `BEFUPD_employeeloanschedule`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `BEFUPD_employeeloanschedule` BEFORE UPDATE ON `employeeloanschedule` FOR EACH ROW BEGIN

DECLARE loan_amount_update DECIMAL(11,6);

DECLARE myText TEXT DEFAULT 'Loan number already exists, please input another loan number.';

DECLARE specialty CONDITION FOR SQLSTATE '45000';

DECLARE loannumexist CHAR(1);

DECLARE cancelled_status VARCHAR(50) DEFAULT '';

DECLARE catchrowid INT(11);

SELECT TRIM(SUBSTRING_INDEX(ii.COLUMN_COMMENT,',',-1)) FROM information_schema.`COLUMNS` ii WHERE ii.TABLE_SCHEMA='gotescopayrolldatabaseoct3' AND ii.COLUMN_NAME='Status' AND ii.TABLE_NAME='employeeloanschedule' INTO cancelled_status;

SELECT EXISTS(SELECT RowID FROM employeeloanschedule WHERE LoanNumber=NEW.LoanNumber AND OrganizationID=NEW.OrganizationID AND EmployeeID=NEW.EmployeeID AND RowID IS NULL LIMIT 1) INTO loannumexist;

SET NEW.DedEffectiveDateTo = PAYTODATE_OF_NoOfPayPeriod(NEW.DedEffectiveDateFrom, NEW.NoOfPayPeriod, NEW.EmployeeID, NEW.DeductionSchedule);

IF loannumexist = '1' THEN

	SIGNAL specialty SET MESSAGE_TEXT = myText;

ELSE

	# IF NEW.LoanPayPeriodLeft = 1 AND IFNULL(OLD.LoanPayPeriodLeft,0) > 1 THEN
	IF NEW.LoanPayPeriodLeft = 0 AND IFNULL(OLD.LoanPayPeriodLeft,0) > 0 THEN
	
		SET loan_amount_update = NEW.TotalLoanAmount - (NEW.DeductionAmount * (NEW.NoOfPayPeriod - 1));
		
		SET @kulangsobra = (NEW.TotalLoanAmount - (NEW.DeductionAmount * NEW.NoOfPayPeriod));
		
		# SET NEW.DeductionAmount = loan_amount_update;
		SET NEW.DeductionAmount = (NEW.DeductionAmount + (@kulangsobra));
	
		# SET NEW.TotalBalanceLeft = loan_amount_update;
		# SET NEW.TotalBalanceLeft = NEW.DeductionAmount; # (NEW.TotalBalanceLeft + (@kulangsobra));
		SET NEW.TotalBalanceLeft = 0;
	
	ELSEIF OLD.LoanPayPeriodLeft <= 0 AND NEW.LoanPayPeriodLeft = 1 THEN
	
		SET loan_amount_update = NEW.TotalLoanAmount - (NEW.DeductionAmount * (NEW.NoOfPayPeriod - 1));
	
		SET NEW.DeductionAmount = loan_amount_update;
		
	ELSEIF OLD.LoanPayPeriodLeft = 1 AND NEW.LoanPayPeriodLeft > 1 THEN
	
		SET loan_amount_update = NEW.TotalLoanAmount / NEW.NoOfPayPeriod;
	
		SET NEW.DeductionAmount = loan_amount_update;
		
	END IF;
	
	IF NEW.LoanPayPeriodLeft <= 0 THEN
		
		SET NEW.LoanPayPeriodLeft = 0;
		SET NEW.`Status` = 'Complete';
		
	END IF;
	
	IF NEW.LoanPayPeriodLeft > NEW.NoOfPayPeriod THEN
	
		SET NEW.LoanPayPeriodLeft = NEW.NoOfPayPeriod;
		
	END IF;
	
	IF NEW.TotalBalanceLeft > NEW.TotalLoanAmount THEN
		SET NEW.TotalBalanceLeft = OLD.TotalLoanAmount;
		
	END IF;

END IF;

IF NEW.`Status` = cancelled_status THEN

	SET NEW.SubstituteEndDate = PAYTODATE_OF_NoOfPayPeriod(NEW.DedEffectiveDateFrom
	,IF((NEW.Noofpayperiod - NEW.LoanPayPeriodLeft) = 0, NEW.Noofpayperiod, (NEW.Noofpayperiod - NEW.LoanPayPeriodLeft))
	,NEW.EmployeeID
	,NEW.DeductionSchedule);
	
END IF;

IF NEW.PayStubID IS NOT NULL THEN

# OrganizID,UserRowID,EmpRowID,PaystubRowID,LoanSchedRowID,LoanBalance,LoanPayPeriodLeft,AmountPerDeduct,Estatus
	SELECT INSUP_employeeloanschedulebacktrack(
		NEW.OrganizationID
		,NEW.LastUpdBy
		,NEW.EmployeeID
		,NEW.PayStubID
		,NEW.RowID
		,NEW.TotalBalanceLeft
		,NEW.LoanPayPeriodLeft
		,NEW.DeductionAmount
		,NEW.`Status`
	) INTO catchrowid;

END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
