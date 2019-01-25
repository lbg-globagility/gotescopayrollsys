/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `properdisplayaudittrail`;
DROP TABLE IF EXISTS `properdisplayaudittrail`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `properdisplayaudittrail` AS select `au`.`Created` AS `Created`,`PROPERCASE`(concat_ws(', ',`u`.`LastName`,`u`.`FirstName`)) AS `Created By`,`v`.`ViewName` AS `Module`,`au`.`FieldChanged` AS `Field Changed`,`au`.`OldValue` AS `Previous Value`,if(`au`.`FieldChanged` = 'EmployeeID',(select `employee`.`EmployeeID` from `employee` where `employee`.`RowID` = ifnull(`au`.`NewValue`,0)),`au`.`NewValue`) AS `New Value`,`au`.`ActionPerformed` AS `ActionPerformed`,`au`.`ViewID` AS `ViewID`,`au`.`OrganizationID` AS `OrganizationID`,`au`.`RowID` AS `RowID` from ((`audittrail` `au` join `user` `u` on(`u`.`RowID` = `au`.`CreatedBy`)) join `view` `v` on(`v`.`RowID` = `au`.`ViewID`)) order by `au`.`Created` desc ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
