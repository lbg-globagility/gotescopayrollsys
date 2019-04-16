/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `salary_for_paystub`;
DROP TABLE IF EXISTS `salary_for_paystub`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `salary_for_paystub` AS select `esa`.`RowID` AS `RowID`,`esa`.`EmployeeID` AS `EmployeeID`,`esa`.`Created` AS `Created`,`esa`.`CreatedBy` AS `CreatedBy`,`esa`.`LastUpd` AS `LastUpd`,`esa`.`LastUpdBy` AS `LastUpdBy`,`esa`.`OrganizationID` AS `OrganizationID`,`esa`.`FilingStatusID` AS `FilingStatusID`,`esa`.`PaySocialSecurityID` AS `PaySocialSecurityID`,`esa`.`PayPhilhealthID` AS `PayPhilhealthID`,`esa`.`PhilHealthDeduction` AS `PhilHealthDeduction`,`esa`.`HDMFAmount` AS `HDMFAmount`,`esa`.`TrueSalary` AS `TrueSalary`,`esa`.`BasicPay` AS `BasicPay`,`esa`.`Salary` AS `Salary`,`esa`.`UndeclaredSalary` AS `UndeclaredSalary`,`esa`.`BasicDailyPay` AS `BasicDailyPay`,`esa`.`BasicHourlyPay` AS `BasicHourlyPay`,`esa`.`NoofDependents` AS `NoofDependents`,`esa`.`MaritalStatus` AS `MaritalStatus`,`esa`.`PositionID` AS `PositionID`,`esa`.`EffectiveDateFrom` AS `EffectiveDateFrom`,`esa`.`EffectiveDateTo` AS `EffectiveDateTo`,`esa`.`ContributeToGovt` AS `ContributeToGovt`,`esa`.`OverrideDiscardSSSContrib` AS `OverrideDiscardSSSContrib`,`esa`.`OverrideDiscardPhilHealthContrib` AS `OverrideDiscardPhilHealthContrib`,`pp`.`RowID` AS `PayPeriodID`,`pp`.`PayFromDate` AS `PayFromDate`,`pp`.`PayToDate` AS `PayToDate` from (((`employeesalary` `esa` join `employee` `e` on(`e`.`RowID` = `esa`.`EmployeeID` and `e`.`OrganizationID` = `esa`.`OrganizationID`)) join `dates` `d` on(`d`.`DateValue` between `esa`.`EffectiveDateFrom` and ifnull(`esa`.`EffectiveDateTo`,`d`.`DateValue`))) join `payperiod` `pp` on(`pp`.`OrganizationID` = `esa`.`OrganizationID` and `pp`.`TotalGrossSalary` = `e`.`PayFrequencyID` and `d`.`DateValue` between `pp`.`PayFromDate` and `pp`.`PayToDate`)) ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
