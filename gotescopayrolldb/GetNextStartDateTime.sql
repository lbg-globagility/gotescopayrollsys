/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP FUNCTION IF EXISTS `GetNextStartDateTime`;
DELIMITER //
CREATE FUNCTION `GetNextStartDateTime`(`shiftStartDateTime` DATETIME,
	`breakStartTime` TIME




) RETURNS datetime
    DETERMINISTIC
BEGIN

DECLARE breakStartDateTime DATETIME DEFAULT NULL;
DECLARE oneMinute INT(11) DEFAULT 1;
DECLARE isNotEqual BOOL DEFAULT TRUE;
DECLARE runThroughHere BOOL DEFAULT FALSE;

SET @startingDateTime = shiftStartDateTime;

/**/ WHILE TIME(@startingDateTime) < breakStartTime DO
	SET @startingDateTime = ADDDATE(shiftStartDateTime, INTERVAL oneMinute MINUTE);
	SET oneMinute = oneMinute + 1;
	SET runThroughHere = TRUE;
END WHILE;

IF NOT runThroughHere THEN
	SET @startingDateTime = TIMESTAMP(DATE(ADDDATE(shiftStartDateTime, INTERVAL 1 DAY)));
	SET shiftStartDateTime = @startingDateTime;

	WHILE TIME(@startingDateTime) < breakStartTime DO
		SET @startingDateTime = ADDDATE(shiftStartDateTime, INTERVAL oneMinute MINUTE);
		SET oneMinute = oneMinute + 1;
	END WHILE;
END IF;

SET breakStartDateTime = @startingDateTime;

RETURN breakStartDateTime;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
