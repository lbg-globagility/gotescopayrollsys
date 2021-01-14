/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `timeentrylogspercutoff`;
DROP TABLE IF EXISTS `timeentrylogspercutoff`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `timeentrylogspercutoff` AS select `etd`.`RowID` AS `RowID`,`etd`.`OrganizationID` AS `OrganizationId`,`etd`.`Created` AS `Created`,`etd`.`CreatedBy` AS `CreatedBy`,`etd`.`LastUpd` AS `LastUpd`,`etd`.`LastUpdBy` AS `LastUpdBy`,`etd`.`EmployeeID` AS `EmployeeID`,`etd`.`TimeIn` AS `TimeIn`,`etd`.`TimeOut` AS `TimeOut`,`etd`.`Date` AS `Date`,`etd`.`TimeScheduleType` AS `TimeScheduleType`,`etd`.`TimeEntryStatus` AS `TimeEntryStatus`,`etd`.`TimeentrylogsImportID` AS `TimeentrylogsImportID`,`pp`.`RowID` AS `PayPeriodID`,`pp`.`PayFromDate` AS `PayFromDate`,`pp`.`PayToDate` AS `PayToDate`,`pp`.`Month` AS `Month`,`pp`.`Year` AS `Year`,`pp`.`OrdinalValue` AS `OrdinalValue`,`e`.`RowID` AS `EmployeePrimaKey`,`e`.`EmployeeID` AS `EmployeeUniqueKey`,`PROPERCASE`(concat_ws(', ',`e`.`LastName`,`e`.`FirstName`)) AS `FullName`,time_format(`etd`.`TimeIn`,'%l:%i %p') AS `TimeInText`,time_format(`etd`.`TimeOut`,'%l:%i %p') AS `TimeOutText` from (((`employeetimeentrydetails` `etd` join `organization` `og` on(`og`.`RowID` = `etd`.`OrganizationID` and `og`.`NoPurpose` = 0)) join `employee` `e` on(`e`.`RowID` = `etd`.`EmployeeID` and `e`.`OrganizationID` = `og`.`RowID` and find_in_set(`e`.`EmploymentStatus`,`UNEMPLOYEMENT_STATUSES`()) = 0)) join `payperiod` `pp` on(`pp`.`OrganizationID` = `e`.`OrganizationID` and `pp`.`TotalGrossSalary` = `e`.`PayFrequencyID` and `etd`.`Date` between `pp`.`PayFromDate` and `pp`.`PayToDate`)) where `etd`.`EmployeeID` is not null order by `pp`.`Year` desc,`pp`.`OrdinalValue` desc ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
