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

-- Dumping structure for trigger gotescopayrolldb_server.BEFINS_employeetimeentrydetails
DROP TRIGGER IF EXISTS `BEFINS_employeetimeentrydetails`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `BEFINS_employeetimeentrydetails` BEFORE INSERT ON `employeetimeentrydetails` FOR EACH ROW BEGIN

DECLARE shift_id INT(11);
DECLARE timestamp_created DATETIME;
IF NEW.TimeIn IS NOT NULL AND NEW.TimeOut IS NOT NULL THEN
	
	IF NEW.TimeIn = NEW.TimeOut THEN
		SET NEW.TimeOut = NULL;
	END IF;

END IF;



# SET timestamp_created = (SELECT etd.Created FROM employeetimeentrydetails etd INNER JOIN (SELECT pp.RowID,pp.PayFromDate, pp.PayToDate FROM employee e INNER JOIN payperiod pp ON pp.TotalGrossSalary=e.PayFrequencyID AND pp.OrganizationID=e.OrganizationID AND NEW.`Date` BETWEEN pp.PayFromDate AND pp.PayToDate WHERE e.RowID=NEW.EmployeeID AND e.OrganizationID=NEW.OrganizationID LIMIT 1) i ON i.RowID IS NOT NULL OR i.RowID IS NULL WHERE etd.EmployeeID=NEW.EmployeeID AND etd.OrganizationID=NEW.OrganizationID AND etd.`Date` BETWEEN i.PayFromDate AND i.PayToDate LIMIT 1);





END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
