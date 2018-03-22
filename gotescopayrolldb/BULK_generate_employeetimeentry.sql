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

-- Dumping structure for procedure gotescopayrolldb_server.BULK_generate_employeetimeentry
DROP PROCEDURE IF EXISTS `BULK_generate_employeetimeentry`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `BULK_generate_employeetimeentry`(IN `OrganizID` INT, IN `Pay_FrequencyType` TEXT, IN `UserRowID` INT, IN `periodDateFrom` DATE, IN `periodDateTo` DATE)
    DETERMINISTIC
BEGIN

UPDATE employee SET DayOfRest='1' WHERE OrganizationID=OrganizID AND DayOfRest IN ('','0');

SELECT GENERATE_employeetimeentry(e.RowID,OrganizID,d.DateValue,UserRowID)
FROM dates d
INNER JOIN employee e ON e.OrganizationID=OrganizID
INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID AND pf.PayFrequencyType=Pay_FrequencyType
WHERE d.DateValue BETWEEN periodDateFrom AND periodDateTo;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
