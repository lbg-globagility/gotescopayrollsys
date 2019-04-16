/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `employee_quitperiod`;
DROP TABLE IF EXISTS `employee_quitperiod`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `employee_quitperiod` AS select `e`.`RowID` AS `EmployeeId`,`e`.`OrganizationID` AS `OrganizationID`,`e`.`PayFrequencyID` AS `PayFrequencyID`,`pp`.`RowID` AS `PayPeriodId`,`pp`.`Year` AS `Year`,`pp`.`OrdinalValue` AS `OrdinalValue`,`pp`.`PayFromDate` AS `PayFromDate`,`pp`.`PayToDate` AS `PayToDate` from (`employee` `e` join `payperiod` `pp` on(`pp`.`OrganizationID` = `e`.`OrganizationID` and `pp`.`TotalGrossSalary` = `e`.`PayFrequencyID` and `e`.`TerminationDate` between `pp`.`PayFromDate` and `pp`.`PayToDate`)) where find_in_set(`e`.`EmploymentStatus`,`UNEMPLOYEMENT_STATUSES`()) > 0 and `e`.`TerminationDate` is not null ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
