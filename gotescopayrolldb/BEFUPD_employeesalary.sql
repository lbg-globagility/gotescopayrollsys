-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.5.5-10.0.12-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win32
-- HeidiSQL Version:             8.3.0.4694
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for trigger gotescopayrolldb_server.BEFUPD_employeesalary
DROP TRIGGER IF EXISTS `BEFUPD_employeesalary`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `BEFUPD_employeesalary` BEFORE UPDATE ON `employeesalary` FOR EACH ROW BEGIN

DECLARE e_status VARCHAR(50);

DECLARE e_type VARCHAR(50);

DECLARE e_payfreqID INT(11);

DECLARE e_workdayyear INT(11);

DECLARE hasadditionalamount CHAR(1);

DECLARE month_count_per_year INT(11) DEFAULT 12;



SET NEW.FilingStatusID = IFNULL(NEW.FilingStatusID,1);











SELECT e.EmploymentStatus,e.EmployeeType,e.PayFrequencyID,e.WorkDaysPerYear FROM employee e WHERE e.RowID=NEW.EmployeeID INTO e_status
,e_type
,e_payfreqID
,e_workdayyear;

SELECT EXISTS(SELECT RowID
					FROM employeeallowance
					WHERE (DATE_FORMAT(Created,'%Y-%m-%d')=CURDATE() OR DATE_FORMAT(LastUpd,'%Y-%m-%d')=CURDATE())
					AND EmployeeID=NEW.EmployeeID
					AND OrganizationID=NEW.OrganizationID
					AND (EffectiveStartDate >= NEW.EffectiveDateFrom OR EffectiveEndDate >= NEW.EffectiveDateFrom)
					AND (EffectiveStartDate <= IFNULL(NEW.EffectiveDateTo,CURDATE()) OR EffectiveEndDate <= IFNULL(NEW.EffectiveDateTo,CURDATE()))
				UNION ALL
					SELECT RowID
					FROM employeeallowance
					WHERE (DATE_FORMAT(Created,'%Y-%m-%d')=CURDATE() OR DATE_FORMAT(LastUpd,'%Y-%m-%d')=CURDATE())
					AND EmployeeID=NEW.EmployeeID
					AND OrganizationID=NEW.OrganizationID
					AND (EffectiveStartDate <= NEW.EffectiveDateFrom OR EffectiveEndDate <= NEW.EffectiveDateFrom)
					AND (EffectiveStartDate >= IFNULL(NEW.EffectiveDateTo,CURDATE()) OR EffectiveEndDate >= IFNULL(NEW.EffectiveDateTo,CURDATE()))) INTO hasadditionalamount;

IF NEW.ContributeToGovt = '0' THEN
	IF NEW.EffectiveDateTo IS NULL THEN
		SET NEW.EffectiveDateTo = OLD.EffectiveDateTo;
	END IF;

	SET NEW.HDMFAmount = 0;

ELSE

	IF e_type = 'Daily' AND hasadditionalamount = '9' THEN

		SET NEW.PaySocialSecurityID = (SELECT RowID FROM paysocialsecurity WHERE HiddenData='0' AND ((e_workdayyear / 12.00) * NEW.Salary) BETWEEN RangeFromAmount AND RangeToAmount LIMIT 1);

	END IF;
	
END IF;

# SET NEW.PaySocialSecurityID = (SELECT RowID FROM paysocialsecurity WHERE ((NEW.BasicPay * e_workdayyear) / month_count_per_year) BETWEEN RangeFromAmount AND RangeToAmount AND NEW.OverrideDiscardSSSContrib = 0 LIMIT 1);

# SET NEW.PayPhilhealthID = (SELECT RowID FROM payphilhealth WHERE ((NEW.BasicPay * e_workdayyear) / month_count_per_year) BETWEEN SalaryRangeFrom AND SalaryRangeTo AND NEW.OverrideDiscardPhilHealthContrib = 0 LIMIT 1);

/*IF IFNULL(NEW.UndeclaredSalary,0) = 0 THEN
	SET NEW.UndeclaredSalary = IFNULL(NEW.TrueSalary - NEW.Salary,0);
END IF;

IF NEW.EffectiveDateTo IS NULL AND OLD.EffectiveDateTo IS NOT NULL THEN
	SET NEW.EffectiveDateTo = OLD.EffectiveDateTo;
END IF;*/

SET NEW.PhilHealthDeduction = GET_PhilHealthContribNewImplement(
											IFNULL((SELECT s.MonthlySalary
											        FROM employeesalary_withdailyrate s
													  WHERE s.RowID = NEW.RowID
													  LIMIT 1), 0), TRUE);

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
