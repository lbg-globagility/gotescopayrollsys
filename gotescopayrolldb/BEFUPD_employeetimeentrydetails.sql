/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP TRIGGER IF EXISTS `BEFUPD_employeetimeentrydetails`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `BEFUPD_employeetimeentrydetails` BEFORE UPDATE ON `employeetimeentrydetails` FOR EACH ROW BEGIN

DECLARE anyint INT(11);

DECLARE old_timein_sec INT(11);

DECLARE old_timeout_sec INT(11);

/*
ALTER TABLE `employeetimeentrydetails`
	ADD COLUMN `TimeStampIn` DATETIME NULL DEFAULT NULL AFTER `TimeEntryStatus`,
	ADD COLUMN `TimeStampOut` DATETIME NULL DEFAULT NULL AFTER `TimeStampIn`;
*/

SET old_timein_sec = IFNULL(SECOND(OLD.TimeIn),0);
SET old_timeout_sec = IFNULL(SECOND(OLD.TimeOut),0);

SET @time_in_format = CONCAT('%H:%i:', LPAD(old_timein_sec, 2, 0));
SET @time_out_format = CONCAT('%H:%i:', LPAD(old_timeout_sec, 2, 0));

SET @is_start_time_reachedtomorrow = (SUBDATE(TIMESTAMP(TIME(0)), INTERVAL 1 SECOND)
                                      = SUBDATE(TIMESTAMP(MAKETIME(HOUR(NEW.TimeIn),0,0)), INTERVAL 1 SECOND));

SET @is_start_time_reachedtomorrow = IFNULL(@is_start_time_reachedtomorrow, FALSE);

#SET NEW.TimeStampIn = CONCAT_DATETIME(ADDDATE(NEW.`Date`, INTERVAL @is_start_time_reachedtomorrow DAY), TIME_FORMAT(NEW.TimeIn, @time_in_format));
SET NEW.TimeStampIn = CONCAT_DATETIME(NEW.`Date`, TIME_FORMAT(NEW.TimeIn, @time_in_format));
SET NEW.TimeStampOut = CONCAT_DATETIME(ADDDATE(NEW.`Date`, INTERVAL IS_TIMERANGE_REACHTOMORROW(NEW.TimeIn, NEW.TimeOut) DAY), TIME_FORMAT(NEW.TimeOut, @time_out_format));

# IF NEW.TimeStampIn IS NOT NULL THEN SELECT INSUPD_timeentrylog(NEW.OrganizationID,EmployeeID,NEW.TimeStampIn,1) FROM employee WHERE RowID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID INTO anyint; END IF;

# IF NEW.TimeStampOut IS NOT NULL THEN SELECT INSUPD_timeentrylog(NEW.OrganizationID,EmployeeID,NEW.TimeStampOut,1) FROM employee WHERE RowID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID INTO anyint; END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
