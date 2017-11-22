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

-- Dumping structure for procedure gotescopayrolldb_oct19.GET_parameter_collection
DROP PROCEDURE IF EXISTS `GET_parameter_collection`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `GET_parameter_collection`(IN `data_base_name` VARCHAR(50), IN `sql_object_name` VARCHAR(50))
    DETERMINISTIC
BEGIN

/**/

# SELECT GROUP_CONCAT(ii.PARAMETER_NAME) `Result`
SELECT ii.PARAMETER_NAME `Result`
FROM datadictionary ii
WHERE ii.SPECIFIC_NAME	=sql_object_name
# AND ii.`SPECIFIC_SCHEMA`=data_base_name
AND ii.PARAMETER_NAME IS NOT NULL
ORDER BY ii.ORDINAL_POSITION;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
