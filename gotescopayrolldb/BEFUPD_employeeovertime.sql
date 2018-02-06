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

-- Dumping structure for trigger gotescopayrolldb_latest.BEFUPD_employeeovertime
DROP TRIGGER IF EXISTS `BEFUPD_employeeovertime`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `BEFUPD_employeeovertime` BEFORE UPDATE ON `employeeovertime` FOR EACH ROW BEGIN

DECLARE ot_aftr_shifttime TIME DEFAULT NULL;

DECLARE ot_befr_shifttime TIME DEFAULT NULL;

SELECT
sh.TimeFrom
,sh.TimeTo
FROM employeeshift esh
INNER JOIN shift sh ON sh.RowID=esh.ShiftID
WHERE esh.EmployeeID=NEW.EmployeeID
AND esh.OrganizationID=NEW.OrganizationID
AND (esh.EffectiveFrom >= NEW.OTStartDate OR esh.EffectiveTo >= NEW.OTStartDate)
AND (esh.EffectiveFrom <= NEW.OTEndDate OR esh.EffectiveTo <= NEW.OTEndDate)
LIMIT 1
INTO ot_befr_shifttime
		,ot_aftr_shifttime;

IF ot_befr_shifttime IS NOT NULL
	AND ot_aftr_shifttime IS NOT NULL THEN

	IF HOUR(NEW.OTStartTime) = HOUR(ot_aftr_shifttime) THEN
	
		SET NEW.OTStartTime = TIME(TIME_FORMAT(NEW.OTStartTime,@@time_format));

	END IF;
	
END IF;

IF NEW.LastUpdBy IS NULL THEN
	SET NEW.LastUpdBy = 1;
END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
