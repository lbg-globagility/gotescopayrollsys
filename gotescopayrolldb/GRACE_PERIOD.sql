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

-- Dumping structure for function gotescopayrolldb_server.GRACE_PERIOD
DROP FUNCTION IF EXISTS `GRACE_PERIOD`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `GRACE_PERIOD`(`Time_IN` TIME, `ShiftTimeFrom` TIME, `GracePeriodValue` DECIMAL(10,2)) RETURNS time
    DETERMINISTIC
BEGIN

DECLARE returnval TIME;

DECLARE mindec_11 DECIMAL(10,2) DEFAULT 0;

DECLARE mindec_12 DECIMAL(10,2) DEFAULT 0;

DECLARE grace_seconds INT(11);

DECLARE grace_minutes INT(11);

DECLARE seconds_in_a_minute INT(11) DEFAULT 60;

SELECT (GracePeriodValue MOD 1) INTO grace_seconds;

IF grace_seconds IS NULL THEN
	SET grace_seconds = 0;
END IF;

SET grace_minutes = (GracePeriodValue - grace_seconds);

SELECT (GracePeriodValue MOD 1) * 100 INTO grace_seconds;

#SET grace_seconds = (grace_seconds + (grace_minutes * seconds_in_a_minute));
SET grace_seconds = (GracePeriodValue * seconds_in_a_minute);

#IF Time_IN BETWEEN ADDDATE(ShiftTimeFrom, INTERVAL -6 HOUR) AND TIMESTAMPADD(SECOND, grace_seconds, ShiftTimeFrom) THEN
IF Time_IN BETWEEN ADDDATE(ShiftTimeFrom, INTERVAL -6 HOUR) AND ADDTIME(ShiftTimeFrom, TIME_FORMAT(SEC_TO_TIME( grace_seconds ), @@time_format)) THEN

	SET returnval = TIME_FORMAT(ShiftTimeFrom, @@time_format);

ELSE

	SET returnval = TIME_FORMAT(Time_IN, @@time_format);
	
END IF;

RETURN  returnval;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
