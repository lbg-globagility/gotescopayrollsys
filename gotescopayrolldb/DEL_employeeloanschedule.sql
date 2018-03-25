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

-- Dumping structure for procedure gotescopayrolldb_server.DEL_employeeloanschedule
DROP PROCEDURE IF EXISTS `DEL_employeeloanschedule`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `DEL_employeeloanschedule`(IN `els_rowid` INT)
    DETERMINISTIC
BEGIN

DECLARE isRollback BOOL DEFAULT 0;

DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET isRollback = 1;

START TRANSACTION;

DELETE FROM employeeloanschedule WHERE RowID=els_rowid; ALTER TABLE employeeloanschedule AUTO_INCREMENT = 0;

IF isRollback = 1 THEN
	ROLLBACK;
	
ELSE
	COMMIT;
	
END IF;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
