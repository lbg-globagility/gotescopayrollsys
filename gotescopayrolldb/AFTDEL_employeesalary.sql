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

-- Dumping structure for trigger gotescopayrolldb_server.AFTDEL_employeesalary
DROP TRIGGER IF EXISTS `AFTDEL_employeesalary`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `AFTDEL_employeesalary` AFTER DELETE ON `employeesalary` FOR EACH ROW BEGIN

UPDATE employeetimeentry ete
INNER JOIN employeesalary es ON es.EmployeeID=ete.EmployeeID AND es.OrganizationID=ete.OrganizationID AND ete.`Date` BETWEEN es.EffectiveDateFrom AND IFNULL(es.EffectiveDateTo,ete.`Date`)
SET ete.EmployeeSalaryID=es.RowID
,ete.LastUpd=CURRENT_TIMESTAMP()
,ete.LastUpdBy=OLD.LastUpdBy
WHERE ete.EmployeeSalaryID IS NULL
AND ete.OrganizationID=OLD.OrganizationID AND ete.EmployeeID=OLD.EmployeeID
AND ete.`Date` BETWEEN OLD.EffectiveDateFrom AND OLD.EffectiveDateTo;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
