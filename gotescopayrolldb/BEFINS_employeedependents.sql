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

-- Dumping structure for trigger gotescopayrolldb_server.BEFINS_employeedependents
DROP TRIGGER IF EXISTS `BEFINS_employeedependents`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `BEFINS_employeedependents` BEFORE INSERT ON `employeedependents` FOR EACH ROW BEGIN

SET NEW.Gender = UPPER(LEFT(NEW.Gender,1));


IF LOCATE('Daugther',NEW.RelationToEmployee) > 0 THEN
	SET NEW.RelationToEmployee = 'Daughter';
END IF;

SET NEW.RelationToEmployee = PROPERCASE(NEW.RelationToEmployee);

SET NEW.Salutation=IFNULL(NEW.Salutation,'');
SET NEW.FirstName=IFNULL(NEW.FirstName,'');
SET NEW.MiddleName=IFNULL(NEW.MiddleName,'');
SET NEW.LastName=IFNULL(NEW.LastName,'');
SET NEW.Surname=IFNULL(NEW.Surname,'');
SET NEW.TINNo=IFNULL(NEW.TINNo,'');
SET NEW.SSSNo=IFNULL(NEW.SSSNo,'');
SET NEW.HDMFNo=IFNULL(NEW.HDMFNo,'');
SET NEW.PhilHealthNo=IFNULL(NEW.PhilHealthNo,'');
SET NEW.EmailAddress=IFNULL(NEW.EmailAddress,'');
SET NEW.WorkPhone=IFNULL(NEW.WorkPhone,'');
SET NEW.HomePhone=IFNULL(NEW.HomePhone,'');
SET NEW.MobilePhone=IFNULL(NEW.MobilePhone,'');
SET NEW.HomeAddress=IFNULL(NEW.HomeAddress,'');
SET NEW.Nickname=IFNULL(NEW.Nickname,'');
SET NEW.JobTitle=IFNULL(NEW.JobTitle,'');

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
