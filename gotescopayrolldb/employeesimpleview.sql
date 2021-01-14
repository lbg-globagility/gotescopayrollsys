/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `employeesimpleview`;
DROP TABLE IF EXISTS `employeesimpleview`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `employeesimpleview` AS select `e`.`RowID` AS `RowID`,`e`.`EmployeeID` AS `EmployeeID`,`e`.`LastName` AS `LastName`,`e`.`FirstName` AS `FirstName`,`e`.`MiddleName` AS `MiddleName`,`e`.`OrganizationID` AS `OrganizationID`,`PROPERCASE`(concat_ws(', ',`e`.`LastName`,`e`.`FirstName`)) AS `FullName` from (`employee` `e` join `organization` `og` on(`og`.`RowID` = `e`.`OrganizationID` and `og`.`NoPurpose` = 0)) where find_in_set(`e`.`EmploymentStatus`,`UNEMPLOYEMENT_STATUSES`()) = 0 ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
