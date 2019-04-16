/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `payperiod_totalperiods`;
DROP TABLE IF EXISTS `payperiod_totalperiods`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `payperiod_totalperiods` AS select `pp`.`RowID` AS `RowID`,`pp`.`OrganizationID` AS `OrganizationID`,`pp`.`Created` AS `Created`,`pp`.`CreatedBy` AS `CreatedBy`,`pp`.`LastUpd` AS `LastUpd`,`pp`.`LastUpdBy` AS `LastUpdBy`,`pp`.`PayFromDate` AS `PayFromDate`,`pp`.`PayToDate` AS `PayToDate`,`pp`.`TotalGrossSalary` AS `TotalGrossSalary`,`pp`.`TotalNetSalary` AS `TotalNetSalary`,`pp`.`TotalEmpSSS` AS `TotalEmpSSS`,`pp`.`TotalEmpWithholdingTax` AS `TotalEmpWithholdingTax`,`pp`.`TotalCompSSS` AS `TotalCompSSS`,`pp`.`TotalEmpPhilhealth` AS `TotalEmpPhilhealth`,`pp`.`TotalCompPhilhealth` AS `TotalCompPhilhealth`,`pp`.`TotalEmpHDMF` AS `TotalEmpHDMF`,`pp`.`TotalCompHDMF` AS `TotalCompHDMF`,`pp`.`Month` AS `Month`,`pp`.`Year` AS `Year`,`pp`.`Half` AS `Half`,`pp`.`SSSContribSched` AS `SSSContribSched`,`pp`.`PhHContribSched` AS `PhHContribSched`,`pp`.`HDMFContribSched` AS `HDMFContribSched`,`pp`.`OrdinalValue` AS `OrdinalValue`,`pp`.`MinimumWageValue` AS `MinimumWageValue`,count(`pp`.`RowID`) AS `ppcount` from `payperiod` `pp` group by `pp`.`OrganizationID`,`pp`.`TotalGrossSalary`,`pp`.`Year` ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
