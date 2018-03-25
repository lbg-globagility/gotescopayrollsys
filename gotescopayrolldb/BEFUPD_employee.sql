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

-- Dumping structure for trigger gotescopayrolldb_server.BEFUPD_employee
DROP TRIGGER IF EXISTS `BEFUPD_employee`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `BEFUPD_employee` BEFORE UPDATE ON `employee` FOR EACH ROW BEGIN

DECLARE anyvchar VARCHAR(150);

DECLARE terminate_date DATE;

DECLARE first_date DATE;

DECLARE eom_payp CHAR(1);

DECLARE loan_num INT(11);

DECLARE loan_typeID INT(11);

DECLARE ps_RowID INT(11);

DECLARE payp_ID INT(11);
DECLARE hasPrivilege CHAR(1);
SELECT EXISTS(SELECT pv.RowID FROM position_view pv INNER JOIN user u ON u.RowID=NEW.LastUpdBy INNER JOIN position p ON p.RowID=u.PositionID WHERE pv.PositionID=p.RowID AND pv.OrganizationID=NEW.OrganizationID AND pv.Updates='Y') INTO hasPrivilege;
IF hasPrivilege='1' AND OLD.EmploymentStatus NOT IN ('Resigned','Terminated') AND NEW.EmploymentStatus IN ('Resigned','Terminated') THEN
	SET anyvchar = '';

	SELECT RowID,PayFromDate,PayToDate,`Half` FROM payperiod WHERE OrganizationID=NEW.OrganizationID AND TotalGrossSalary=NEW.PayFrequencyID AND NEW.TerminationDate BETWEEN PayFromDate AND PayToDate INTO payp_ID,first_date,terminate_date,eom_payp;

	SET NEW.TerminationDate = terminate_date;

	
	
	SELECT COUNT(RowID) FROM employeeloanschedule WHERE OrganizationID=NEW.OrganizationID AND EmployeeID=NEW.RowID INTO loan_num;
	
	SELECT RowID FROM product WHERE OrganizationID=NEW.OrganizationID AND `Category`='Loan Type' AND PartNo='CASH ADVANCE' INTO loan_typeID;
	
	INSERT INTO employeeloanschedule(OrganizationID,Created,CreatedBy,EmployeeID,LoanNumber,DedEffectiveDateFrom,DedEffectiveDateTo,TotalLoanAmount,DeductionSchedule,TotalBalanceLeft,DeductionAmount,`Status`,LoanTypeID,DeductionPercentage,NoOfPayPeriod,LoanPayPeriodLeft,Comments) VALUES (NEW.OrganizationID,CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.RowID,(loan_num + 1),first_date,terminate_date,1500.0,IF(eom_payp='0', 'End of the month', 'First half'),1500.0,1500.0,'In progress',loan_typeID,0.0,1,1,'deposit for transpo allowance') ON DUPLICATE KEY UPDATE LastUpd=CURRENT_TIMESTAMP(),LastUpdBy=NEW.LastUpdBy;

	SELECT RowID FROM paystub WHERE EmployeeID=NEW.RowID AND OrganizationID=NEW.OrganizationID AND PayPeriodID=payp_ID INTO ps_RowID;

	IF ps_RowID > 0 THEN
		
		UPDATE paystubitem psi
		SET psi.PayAmount=psi.PayAmount + 1500.0
		,psi.LastUpd=CURRENT_TIMESTAMP()
		,psi.LastUpdBy=NEW.LastUpdBy
		WHERE psi.ProductID=loan_typeID
		AND psi.OrganizationID=NEW.OrganizationID
		AND psi.PayStubID=ps_RowID;
		
	END IF;

END IF;

IF NEW.LeaveBalance < 0 THEN
	SET NEW.LeaveBalance = 0;
END IF;

IF NEW.SickLeaveBalance < 0 THEN
	SET NEW.SickLeaveBalance = 0;
END IF;

IF NEW.MaternityLeaveBalance < 0 THEN
	SET NEW.MaternityLeaveBalance = 0;
END IF;

IF NEW.OtherLeaveBalance < 0 THEN
	SET NEW.OtherLeaveBalance = 0;
END IF;

IF NEW.AdditionalVLBalance < 0 THEN
	SET NEW.AdditionalVLBalance = 0;
END IF;

IF IFNULL(LENGTH(NEW.Image),0) = 0 THEN
	SET NEW.Image = NULL;
END IF;

IF NEW.DateR1A IS NOT NULL AND OLD.DateRegularized IS NULL
	AND EXISTS(SELECT RowID FROM listofval WHERE `Type`='Years to serve' AND LIC='Regularization' LIMIT 1) = '1' THEN
	SET anyvchar = 'R3gvlar!z@t!0n';
	SET NEW.DateRegularized = (SELECT ADDDATE(NEW.DateR1A, INTERVAL (DisplayValue * 1) YEAR) FROM listofval WHERE `Type`='Years to serve' AND LIC='Regularization' LIMIT 1);
	SET anyvchar = '';
	
	
END IF;

IF (IFNULL(NEW.DayOfRest,0) * 1) < 1 THEN
	SET NEW.DayOfRest = '1';
END IF;

IF NEW.PositionID IS NOT NULL THEN
	
	IF OLD.PositionID != NEW.PositionID THEN
	
		SET anyvchar = '';
		
		
	
	END IF;
	
END IF;

IF NEW.WorkDaysPerYear = 0 THEN
	SET NEW.WorkDaysPerYear = 313;
END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
