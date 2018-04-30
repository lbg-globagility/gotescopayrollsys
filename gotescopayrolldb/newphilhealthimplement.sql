/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `newphilhealthimplement`;
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
            ) `MaximumContribution`
            
, (SELECT lv.DisplayValue
            FROM listofval lv
            WHERE lv.`Type`='PhilHealth'
				AND lv.LIC = 'YearOfEffect'
            ) `YearOfEffect` ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
