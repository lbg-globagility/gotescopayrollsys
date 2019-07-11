/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `paystubadjustment_peritem`;
DROP TABLE IF EXISTS `paystubadjustment_peritem`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `paystubadjustment_peritem` AS select `adj`.`RowID` AS `RowID`,`adj`.`OrganizationID` AS `OrganizationID`,`adj`.`Created` AS `Created`,`adj`.`CreatedBy` AS `CreatedBy`,`adj`.`LastUpd` AS `LastUpd`,`adj`.`LastUpdBy` AS `LastUpdBy`,`adj`.`PayStubID` AS `PayStubID`,`adj`.`ProductID` AS `ProductID`,round(sum(`adj`.`PayAmount`),2) AS `PayAmount`,`adj`.`Comment` AS `Comment`,0 AS `IsActual`,group_concat(`p`.`PartNo` separator ',') AS `AdjustmentName`,group_concat(replace(format(`adj`.`PayAmount`,2),',','|') separator ',') AS `AdjustmentAmount` from (`paystubadjustment` `adj` join `product` `p` on(`p`.`RowID` = `adj`.`ProductID`)) where `adj`.`PayAmount` > 0 group by `adj`.`PayStubID` ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
