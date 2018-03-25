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

-- Dumping structure for function gotescopayrolldb_server.VIEW_privilege
DROP FUNCTION IF EXISTS `VIEW_privilege`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `VIEW_privilege`(`vw_ViewName` VARCHAR(150), `vw_OrganizationID` INT) RETURNS int(11)
    DETERMINISTIC
BEGIN

DECLARE viewIsExists INT(1);

DECLARE view_RowID INT(11);



	SELECT RowID FROM `view` WHERE ViewName=vw_ViewName AND OrganizationID=vw_OrganizationID INTO view_RowID;

RETURN view_RowID;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
