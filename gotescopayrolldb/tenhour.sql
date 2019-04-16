/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `tenhour`;
DROP TABLE IF EXISTS `tenhour`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tenhour` AS select 30 AS `MinuteInterval` union select 60 AS `60` union select 90 AS `90` union select 120 AS `120` union select 150 AS `150` union select 180 AS `180` union select 210 AS `210` union select 240 AS `240` union select 270 AS `270` union select 300 AS `300` union select 330 AS `330` union select 360 AS `360` union select 390 AS `390` union select 420 AS `420` union select 450 AS `450` union select 480 AS `480` union select 510 AS `510` union select 540 AS `540` union select 570 AS `570` union select 600 AS `600` ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
