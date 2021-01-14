/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `dailyshiftschedule`;
DROP TABLE IF EXISTS `dailyshiftschedule`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `dailyshiftschedule` AS select `esh`.`RowID` AS `RowID`,`esh`.`OrganizationID` AS `OrganizationID`,`esh`.`EmployeeID` AS `EmployeeID`,`d`.`DateValue` AS `DateValue`,`esh`.`EffectiveFrom` AS `EffectiveFrom`,`esh`.`EffectiveTo` AS `EffectiveTo`,`esh`.`ShiftID` AS `ShiftID`,`sh`.`TimeFrom` AS `TimeFrom`,`sh`.`TimeTo` AS `TimeTo`,`sh`.`BreakTimeFrom` AS `BreakTimeFrom`,`sh`.`BreakTimeTo` AS `BreakTimeTo`,`sh`.`ShiftHours` AS `ShiftHours`,`sh`.`WorkHours` AS `WorkHours`,`esh`.`RestDay` AS `RestDay`,`esh`.`NightShift` AS `NightShift`,`pr`.`PayType` AS `HolidayType` from (((`employeeshift` `esh` join `dates` `d` on(`d`.`DateValue` between `esh`.`EffectiveFrom` and `esh`.`EffectiveTo`)) join `payrate` `pr` on(`pr`.`OrganizationID` = `esh`.`OrganizationID` and `pr`.`Date` = `d`.`DateValue`)) left join `shift` `sh` on(`sh`.`RowID` = `esh`.`ShiftID`)) ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
