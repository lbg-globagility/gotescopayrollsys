/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `paystubitem_sum_semimon_allowance_group_prodid`;
DROP TABLE IF EXISTS `paystubitem_sum_semimon_allowance_group_prodid`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `paystubitem_sum_semimon_allowance_group_prodid` AS select `et`.`RowID` AS `RowID`,`p`.`RowID` AS `ProductID`,`ea`.`EmployeeID` AS `EmployeeID`,`ea`.`OrganizationID` AS `OrganizationID`,`d`.`DateValue` AS `Date`,0 AS `Column1`,if(lcase(`e`.`EmployeeType`) = '',`es`.`BasicPay`,`es`.`Salary` / (`e`.`WorkDaysPerYear` / 12)) AS `Column2`,0 AS `TotalAllowanceAmt`,`ea`.`TaxableFlag` AS `TaxableFlag`,ifnull(`et`.`HoursTardy`,0) + ifnull(`et`.`HoursUndertime`,0) + if(ifnull(`et`.`Absent`,0) > 0,ifnull(`sh`.`WorkHours`,8),0) AS `HoursToLess`,ifnull(`et`.`HoursTardy`,0) AS `LateHours`,ifnull(`et`.`HoursUndertime`,0) AS `UndertimeHours`,if(ifnull(`et`.`Absent`,0) > 0,ifnull(`sh`.`WorkHours`,8),0) AS `AbsentHours`,`ea`.`AllowanceAmount` AS `AllowanceAmount`,`e`.`WorkDaysPerYear` AS `WorkDaysPerYear`,`p`.`Fixed` AS `Fixed`,2 AS `PAYFREQDIV`,8 AS `DivisorToDailyRate`,`ea`.`AllowanceAmount` / (`e`.`WorkDaysPerYear` / (12 * 2)) AS `DailyAllowance`,0 AS `Result` from ((((((((`employeeallowance` `ea` join `employee` `e` on(`e`.`RowID` = `ea`.`EmployeeID`)) join `product` `p` on(`p`.`RowID` = `ea`.`ProductID`)) join `category` `c` on(`c`.`RowID` = `p`.`CategoryID` and `c`.`CategoryName` = 'Allowance type')) join `dates` `d` on(`d`.`DateValue` between `ea`.`EffectiveStartDate` and `ea`.`EffectiveEndDate`)) left join `employeetimeentry` `et` on(`et`.`EmployeeID` = `e`.`RowID` and `et`.`Date` = `d`.`DateValue` and `et`.`OrganizationID` = `ea`.`OrganizationID`)) left join `employeesalary` `es` on(`es`.`RowID` = `et`.`EmployeeSalaryID`)) left join `employeeshift` `esh` on(`esh`.`RowID` = `et`.`EmployeeShiftID`)) left join `shift` `sh` on(`sh`.`RowID` = `esh`.`ShiftID`)) where `ea`.`AllowanceFrequency` = 'Semi-monthly' order by `ea`.`EmployeeID`,`d`.`DateValue` ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
