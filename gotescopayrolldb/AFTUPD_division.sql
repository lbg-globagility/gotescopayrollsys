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

-- Dumping structure for trigger gotescopayrolldb_server.AFTUPD_division
DROP TRIGGER IF EXISTS `AFTUPD_division`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `AFTUPD_division` AFTER UPDATE ON `division` FOR EACH ROW BEGIN



IF OLD.AutomaticOvertimeFiling = '0' AND NEW.AutomaticOvertimeFiling = '1' THEN
	
	UPDATE employeetimeentrydetails etd INNER JOIN position pos ON pos.OrganizationID=NEW.OrganizationID AND pos.DivisionId=NEW.RowID INNER JOIN employee e ON e.OrganizationID=pos.OrganizationID AND e.PositionID=pos.RowID AND e.RowID=etd.EmployeeID SET etd.LastUpd=TIMESTAMPADD(SECOND,1,etd.LastUpd) WHERE etd.EmployeeID=e.RowID AND etd.OrganizationID=NEW.OrganizationID;
	
END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
