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

-- Dumping structure for procedure gotescopayrolldb_server.DEL_employeesalary
DROP PROCEDURE IF EXISTS `DEL_employeesalary`;
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `DEL_employeesalary`(IN `es_rowid` INT)
    DETERMINISTIC
BEGIN
# SET foreign_key_checks = OFF;

DECLARE emp_rowid INT(11);

DECLARE og_rowid INT(11);

SELECT es.EmployeeID,es.OrganizationID FROM employeesalary es WHERE es.RowID=es_rowid INTO emp_rowid,og_rowid;

UPDATE employeesalary es SET es.OrganizationID=NULL WHERE es.RowID=es_rowid;

UPDATE employeetimeentry ete
SET ete.EmployeeSalaryID=NULL
,ete.LastUpd=CURRENT_TIMESTAMP()
,ete.LastUpdBy=IFNULL(ete.LastUpdBy,ete.CreatedBy)
WHERE ete.EmployeeSalaryID=es_rowid;

# UPDATE employeesalary es INNER JOIN (SELECT * FROM employeesalary WHERE EmployeeID='73' AND OrganizationID=1 ORDER BY EffectiveDateFrom DESC LIMIT 1,1) esa ON esa.RowID > 0 SET es.EffectiveDateTo=NULL,es.LastUpd=CURRENT_TIMESTAMP(),es.LastUpdBy='1' WHERE es.RowID=esa.RowID AND es.OrganizationID='1';

# UPDATE employeesalary SET LastUpdBy='1' WHERE RowID=es_rowid;

DELETE FROM employeesalary WHERE RowID = es_rowid;
ALTER TABLE employeesalary AUTO_INCREMENT = 0;

# SET foreign_key_checks = ON;

SET @esal_count = (SELECT COUNT(RowID) FROM employeesalary WHERE EmployeeID=emp_rowid AND OrganizationID=og_rowid);

IF @esal_count = 0 THEN
	UPDATE employee e SET e.LastUpd=CURRENT_TIMESTAMP(),e.LastUpdBy=IFNULL(e.LastUpdBy,e.CreatedBy) WHERE e.RowID=emp_rowid AND e.OrganizationID=og_rowid;
END IF;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
