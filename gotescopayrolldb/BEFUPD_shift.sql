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

-- Dumping structure for trigger gotescopayrolldb_server.BEFUPD_shift
DROP TRIGGER IF EXISTS `BEFUPD_shift`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `BEFUPD_shift` BEFORE UPDATE ON `shift` FOR EACH ROW BEGIN

DECLARE time_diff DECIMAL(11,2);

DECLARE sec_per_hour DECIMAL(10, 2) DEFAULT 3600;

DECLARE sh_hrs, work_hrs, br_hrs DECIMAL(10, 2) DEFAULT 0;

DECLARE is_reach_tomorrow BOOL DEFAULT FALSE;

IF IFNULL(NEW.DivisorToDailyRate,0) = 0 THEN

	SET time_diff = COMPUTE_TimeDifference(NEW.TimeFrom,NEW.TimeTo);
	
	IF time_diff > 6 THEN
		SET time_diff = time_diff - 1;
	END IF;
	
	SET NEW.DivisorToDailyRate = time_diff;
	
END IF;

/*
 * execute the ff. query to make BEFUPD_shift works :
 * UPDATE shift sh SET sh.LastUpd=CURRENT_TIMESTAMP();
 */
 
SET is_reach_tomorrow = IS_TIMERANGE_REACHTOMORROW(NEW.TimeFrom, NEW.TimeTo);

SET sh_hrs = TIMESTAMPDIFF(SECOND
                           , CONCAT_DATETIME(CURDATE(), NEW.TimeFrom)
                           , ADDDATE(CONCAT_DATETIME(CURDATE(), NEW.TimeTo), INTERVAL is_reach_tomorrow DAY)) / sec_per_hour;

SET NEW.ShiftHours = IFNULL(sh_hrs, 0);


SET is_reach_tomorrow = IS_TIMERANGE_REACHTOMORROW(NEW.BreakTimeFrom, NEW.BreakTimeTo);

SET br_hrs = TIMESTAMPDIFF(SECOND
                           , CONCAT_DATETIME(CURDATE(), NEW.BreakTimeFrom)
                           , ADDDATE(CONCAT_DATETIME(CURDATE(), NEW.BreakTimeTo), INTERVAL is_reach_tomorrow DAY)) / sec_per_hour;

SET NEW.WorkHours = NEW.ShiftHours - IFNULL(br_hrs, 0);

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
