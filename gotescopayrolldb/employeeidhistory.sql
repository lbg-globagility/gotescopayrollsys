/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `employeeidhistory`;
DROP TABLE IF EXISTS `employeeidhistory`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `employeeidhistory` AS select `aut`.`RowID` AS `RowID`,`e`.`RowID` AS `EmployeeRowID`,`v`.`OrganizationID` AS `OrganizationID`,`e`.`EmployeeID` AS `EmployeeID`,`e`.`LastName` AS `LastName`,`e`.`FirstName` AS `FirstName`,`e`.`MiddleName` AS `MiddleName`,`pos`.`PositionName` AS `PositionName`,`aut`.`OldValue` AS `OldValue`,`aut`.`NewValue` AS `NewValue`,`aut`.`ActionPerformed` AS `ActionPerformed`,`aut`.`Created` AS `Created` from (((`audittrail` `aut` join `view` `v` on(`v`.`ViewName` = 'Employee Personal Profile' and `aut`.`ViewID` = `v`.`RowID`)) join `employee` `e` on(`e`.`RowID` = `aut`.`ChangedRowID` and `e`.`OrganizationID` = `v`.`OrganizationID` and `e`.`EmploymentStatus` not in ('Resigned','Terminated'))) join `position` `pos` on(`pos`.`RowID` = `e`.`PositionID`)) where `aut`.`FieldChanged` = 'EmployeeID' and `aut`.`ActionPerformed` in ('Insert','Update') ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
