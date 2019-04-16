/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `v_sumthirteenthmonthpay`;
DROP TABLE IF EXISTS `v_sumthirteenthmonthpay`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_sumthirteenthmonthpay` AS select `tmp`.`RowID` AS `RowID`,`tmp`.`OrganizationID` AS `OrganizationID`,`tmp`.`PaystubID` AS `PaystubID`,`tmp`.`Amount` AS `Amount`,`ps`.`PayFromDate` AS `PayFromDate`,`ps`.`PayToDate` AS `PayToDate`,`ps`.`EmployeeID` AS `EmployeeID`,`pp`.`Half` AS `Half`,`pp`.`Month` AS `Month`,`pp`.`Year` AS `Year` from ((`thirteenthmonthpay` `tmp` join `paystub` `ps` on(`ps`.`RowID` = `tmp`.`PaystubID` and `ps`.`OrganizationID` = `tmp`.`OrganizationID`)) join `payperiod` `pp` on(`pp`.`RowID` = `ps`.`PayPeriodID` and `pp`.`OrganizationID` = `tmp`.`OrganizationID`)) ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
