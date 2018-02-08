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

-- Dumping structure for view gotescopayrolldb_latest.newphilhealthimplement
DROP VIEW IF EXISTS `newphilhealthimplement`;
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `newphilhealthimplement`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `newphilhealthimplement` AS SELECT
1 `RowID`

, (SELECT lv.DisplayValue
				FROM listofval lv
            WHERE lv.`Type`='PhilHealth'
				AND lv.LIC = 'DeductionType'
            ) `DeductionType`

, (SELECT lv.DisplayValue
				FROM listofval lv
            WHERE lv.`Type`='PhilHealth'
				AND lv.LIC = 'Rate'
            ) `Rate`

, (SELECT lv.DisplayValue
				FROM listofval lv
            WHERE lv.`Type`='PhilHealth'
				AND lv.LIC = 'MinimumContribution'
            ) `MinimumContribution`
            
, (SELECT lv.DisplayValue
            FROM listofval lv
            WHERE lv.`Type`='PhilHealth'
				AND lv.LIC = 'MaximumContribution'
            ) `MaximumContribution` ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
