/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `paystubitem_sum_semimon_ecola_group_prodrowid`;
DROP TABLE IF EXISTS `paystubitem_sum_semimon_ecola_group_prodrowid`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `paystubitem_sum_semimon_ecola_group_prodrowid` AS select `i`.`RowID` AS `RowID`,`i`.`OrganizationID` AS `OrganizationID`,`i`.`Created` AS `Created`,`i`.`CreatedBy` AS `CreatedBy`,`i`.`LastUpd` AS `LastUpd`,`i`.`LastUpdBy` AS `LastUpdBy`,`i`.`EmployeeID` AS `EmployeeID`,`i`.`ProductID` AS `ProductID`,`i`.`EffectiveStartDate` AS `EffectiveStartDate`,`i`.`AllowanceFrequency` AS `AllowanceFrequency`,`i`.`EffectiveEndDate` AS `EffectiveEndDate`,`i`.`TaxableFlag` AS `TaxableFlag`,`i`.`AllowanceAmount` AS `AllowanceAmount`,`i`.`DailyAllowance` AS `DailyAllowance`,`i`.`IsFixed` AS `IsFixed`,`et`.`RowID` AS `etRowID`,`d`.`DateValue` AS `Date` from ((((((((`v_employeesemimonthlyallowance` `i` join `dates` `d` on(`d`.`DateValue` between `i`.`EffectiveStartDate` and `i`.`EffectiveEndDate`)) join `employee` `e` on(`e`.`RowID` = `i`.`EmployeeID` and `e`.`OrganizationID` = `i`.`OrganizationID` and `e`.`EmploymentStatus` = 'Regular')) join `payfrequency` `pf` on(`pf`.`RowID` = `e`.`PayFrequencyID`)) join `product` `p` on(`p`.`RowID` = `i`.`ProductID` and locate('ecola',lcase(`p`.`PartNo`)) > 0)) join `employeetimeentry` `et` on(`et`.`OrganizationID` = `i`.`OrganizationID` and `et`.`EmployeeID` = 28 and `et`.`Date` = `d`.`DateValue` and ifnull(`et`.`HoursLate`,0) + ifnull(`et`.`UndertimeHours`,0) > 0 or ifnull(`et`.`Absent`,0) > 0)) left join `employeeshift` `esh` on(`esh`.`RowID` = `et`.`EmployeeShiftID`)) left join `shift` `sh` on(`sh`.`RowID` = `esh`.`ShiftID`)) join `dates` `dd` on(`dd`.`DateValue` between `i`.`EffectiveStartDate` and `i`.`EffectiveEndDate`)) ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
