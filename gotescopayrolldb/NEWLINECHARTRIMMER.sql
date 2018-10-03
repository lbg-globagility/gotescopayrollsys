/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP FUNCTION IF EXISTS `NEWLINECHARTRIMMER`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `NEWLINECHARTRIMMER`(
	`stringParam` VARCHAR(200)


) RETURNS varchar(200) CHARSET latin1
    DETERMINISTIC
BEGIN

DECLARE returnval VARCHAR(255) DEFAULT '';

DECLARE nextLine VARCHAR(50) DEFAULT '\n';
DECLARE newLine VARCHAR(50) DEFAULT '\r\n';
DECLARE leading4NewLine
			,leading3NewLine
			,leading2NewLine
			,leading1NewLine VARCHAR(50);

SET leading4NewLine = CONCAT(newLine, newLine, newLine, newLine);
SET leading3NewLine = CONCAT(newLine, newLine, newLine);
SET leading2NewLine = CONCAT(newLine, newLine);
SET leading1NewLine = newLine;

SET returnval =
 IFNULL(REPLACE(REPLACE(REPLACE(stringParam
                                , leading4NewLine, leading3NewLine)
                        , leading3NewLine, leading2NewLine)
					 , leading2NewLine, leading1NewLine)
        , '');

SET returnval = TRIM(LEADING newLine FROM returnval);
SET returnval = TRIM(TRAILING newLine FROM returnval);

SET returnval = TRIM(LEADING nextLine FROM returnval);
SET returnval = TRIM(TRAILING nextLine FROM returnval);

RETURN returnval;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
