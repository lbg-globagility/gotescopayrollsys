/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP TRIGGER IF EXISTS `BEFINS_employeesalary`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `BEFINS_employeesalary` BEFORE INSERT ON `employeesalary` FOR EACH ROW BEGIN

DECLARE e_type VARCHAR(50);

DECLARE month_count INT(11) DEFAULT 12;

DECLARE e_workdays_peryear DECIMAL(15, 4);

SELECT e.EmployeeType
, e.WorkDaysPerYear
FROM employee e
WHERE e.RowID = NEW.RowID
INTO e_type
     ,e_workdays_peryear;

IF IFNULL(NEW.UndeclaredSalary,0) = 0 THEN
	SET NEW.UndeclaredSalary = IFNULL(NEW.TrueSalary - NEW.Salary,0);
END IF;

IF e_type = 'Daily' THEN
	IF NEW.OverrideDiscardPhilHealthContrib = FALSE THEN
		SET NEW.PhilHealthDeduction = GET_PhilHealthContribNewImplement(((NEW.Salary * e_workdays_peryear) / month_count), TRUE);
	ELSE
		SET NEW.PhilHealthDeduction = 0;
		SET NEW.PayPhilhealthID=NULL;
	END IF;
ELSE

	IF NEW.OverrideDiscardPhilHealthContrib = FALSE THEN
		SET NEW.PhilHealthDeduction = GET_PhilHealthContribNewImplement(NEW.Salary, TRUE);
	ELSE
		SET NEW.PhilHealthDeduction = 0;
		SET NEW.PayPhilhealthID=NULL;
	END IF;
END IF;

IF NEW.OverrideDiscardSSSContrib = TRUE THEN SET NEW.PaySocialSecurityID=NULL; END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
