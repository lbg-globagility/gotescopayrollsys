/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `socialsecurityservice`;
DROP TABLE IF EXISTS `socialsecurityservice`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `socialsecurityservice` AS select `paysocialsecurity`.`RowID` AS `RowID`,`paysocialsecurity`.`Created` AS `Created`,`paysocialsecurity`.`CreatedBy` AS `CreatedBy`,`paysocialsecurity`.`LastUpd` AS `LastUpd`,`paysocialsecurity`.`LastUpdBy` AS `LastUpdBy`,`paysocialsecurity`.`RangeFromAmount` AS `RangeFromAmount`,`paysocialsecurity`.`RangeToAmount` AS `RangeToAmount`,`paysocialsecurity`.`MonthlySalaryCredit` AS `MonthlySalaryCredit`,`paysocialsecurity`.`EmployeeContributionAmount` AS `EmployeeContributionAmount`,`paysocialsecurity`.`EmployerContributionAmount` AS `EmployerContributionAmount`,`paysocialsecurity`.`EmployeeECAmount` AS `EmployeeECAmount`,`paysocialsecurity`.`HiddenData` AS `HiddenData`,`paysocialsecurity`.`EffectiveDateFrom` AS `EffectiveDateFrom`,`paysocialsecurity`.`EffectiveDateTo` AS `EffectiveDateTo` from `paysocialsecurity` ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
