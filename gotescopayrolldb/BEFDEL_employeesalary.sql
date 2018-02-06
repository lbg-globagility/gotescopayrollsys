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

-- Dumping structure for trigger gotescopayrolldb_latest.BEFDEL_employeesalary
DROP TRIGGER IF EXISTS `BEFDEL_employeesalary`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `BEFDEL_employeesalary` BEFORE DELETE ON `employeesalary` FOR EACH ROW BEGIN

UPDATE employeetimeentry ete
SET ete.EmployeeSalaryID=NULL
,ete.LastUpd=TIMESTAMP('1900-01-01 00:00:00')#CURRENT_TIMESTAMP()
,ete.LastUpdBy=OLD.LastUpdBy
WHERE ete.EmployeeSalaryID=OLD.RowID
AND ete.OrganizationID=OLD.OrganizationID;

UPDATE employeepromotions ep
SET ep.EmployeeSalaryID=NULL
,ep.LastUpd=CURRENT_TIMESTAMP()
,ep.LastUpdBy=OLD.LastUpdBy
WHERE ep.EmployeeSalaryID=OLD.RowID
AND ep.OrganizationID=OLD.OrganizationID;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
