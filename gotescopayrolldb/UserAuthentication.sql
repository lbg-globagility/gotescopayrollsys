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

-- Dumping structure for function gotescopayrolldb_server.UserAuthentication
DROP FUNCTION IF EXISTS `UserAuthentication`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `UserAuthentication`(`user_name` VARCHAR(90), `pass_word` VARCHAR(90)) RETURNS int(11)
    DETERMINISTIC
BEGIN

DECLARE returnvaue INT(11) DEFAULT 0;

SELECT RowID FROM `user` WHERE InSession='0' AND UserID=user_name AND `Password`=pass_word AND RowID > 0 LIMIT 1 INTO returnvaue;

IF returnvaue IS NULL THEN
	SET returnvaue = 0;
END IF;

IF returnvaue > 0 THEN
	UPDATE `user` SET
	#InSession='1',
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=returnvaue
	WHERE RowID=returnvaue;
END IF;

RETURN returnvaue;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
