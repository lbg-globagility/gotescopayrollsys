/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `employeeallowance_withdailyrate`;
DROP TABLE IF EXISTS `employeeallowance_withdailyrate`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `employeeallowance_withdailyrate` AS select `ea`.`RowID` AS `RowID`,`ea`.`OrganizationID` AS `OrganizationID`,`ea`.`Created` AS `Created`,`ea`.`CreatedBy` AS `CreatedBy`,`ea`.`LastUpd` AS `LastUpd`,`ea`.`LastUpdBy` AS `LastUpdBy`,`ea`.`EmployeeID` AS `EmployeeID`,`ea`.`ProductID` AS `ProductID`,`ea`.`EffectiveStartDate` AS `EffectiveStartDate`,`ea`.`AllowanceFrequency` AS `AllowanceFrequency`,`ea`.`EffectiveEndDate` AS `EffectiveEndDate`,`ea`.`TaxableFlag` AS `TaxableFlag`,`ea`.`AllowanceAmount` AS `AllowanceAmount`,if(`ea`.`AllowanceFrequency` <> 'Semi-monthly',`ea`.`AllowanceAmount`,`ea`.`AllowanceAmount` / (`e`.`WorkDaysPerYear` / 12 / 2)) AS `DailyAllowance` from (`employeeallowance` `ea` join `employee` `e` on(`e`.`RowID` = `ea`.`EmployeeID` and find_in_set(`e`.`EmploymentStatus`,`UNEMPLOYEMENT_STATUSES`()) = 0)) where `ea`.`AllowanceAmount` <> 0 and octet_length(trim(`ea`.`AllowanceFrequency`)) > 0 ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
