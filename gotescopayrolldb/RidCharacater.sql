/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP FUNCTION IF EXISTS `RidCharacater`;
DELIMITER //
CREATE FUNCTION `RidCharacater`(`textValue` TEXT,
	`customCharacter` TEXT
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN

DECLARE repeatCount INT(11) DEFAULT 5;

DECLARE i INT(11) DEFAULT 0;

DECLARE returnValue TEXT DEFAULT '';
DECLARE annoyingText TEXT DEFAULT '';

SET returnValue = textValue;
WHILE i < repeatCount DO
	SET annoyingText = REPEAT(customCharacter, repeatCount);
	
	SET returnValue = TRIM(LEADING annoyingText FROM returnValue);
	SET returnValue = TRIM(TRAILING annoyingText FROM returnValue);
	
	SET returnValue = REPLACE(returnValue, annoyingText, customCharacter);
	
	SET repeatCount = repeatCount - 1;
END WHILE;

RETURN returnValue;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
