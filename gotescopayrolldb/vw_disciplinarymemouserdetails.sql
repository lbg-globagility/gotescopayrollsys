/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `vw_disciplinarymemouserdetails`;
DROP TABLE IF EXISTS `vw_disciplinarymemouserdetails`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_disciplinarymemouserdetails` AS select `u`.`RowID` AS `UserID`,`u`.`FirstName` AS `FirstName`,`u`.`MiddleName` AS `MiddleName`,`u`.`LastName` AS `LastName`,trim(`o`.`Name`) AS `CompanyName`,`o`.`Image` AS `Image`,`p`.`PositionName` AS `PositionName`,concat(if(`u`.`FirstName` is null or trim(`u`.`FirstName`) = '','',concat(ucase(substr(trim(`u`.`FirstName`),1,1)),lcase(substr(trim(`u`.`FirstName`),2)),' ')),if(`u`.`MiddleName` is null or trim(`u`.`MiddleName`) = '','',concat(ucase(substr(trim(`u`.`MiddleName`),1,1)),'. ')),if(`u`.`LastName` is null or trim(`u`.`LastName`) = '','',concat(ucase(substr(trim(`u`.`LastName`),1,1)),lcase(substr(trim(`u`.`LastName`),2)),' '))) AS `FullName` from ((`user` `u` left join `organization` `o` on(`u`.`OrganizationID` = `o`.`RowID`)) left join `position` `p` on(`u`.`PositionID` = `p`.`RowID`)) limit 1 ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
