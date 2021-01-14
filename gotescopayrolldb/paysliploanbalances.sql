/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `paysliploanbalances`;
DROP TABLE IF EXISTS `paysliploanbalances`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `paysliploanbalances` AS select `eb`.`RowID` AS `RowID`,`eb`.`OrganizationID` AS `OrganizationID`,`eb`.`Created` AS `Created`,`eb`.`CreatedBy` AS `CreatedBy`,`eb`.`LastUpd` AS `LastUpd`,`eb`.`LastUpdBy` AS `LastUpdBy`,`eb`.`EmployeeID` AS `EmployeeID`,`eb`.`PayStubID` AS `PayStubID`,`eb`.`LoanschedID` AS `LoanschedID`,`eb`.`Balance` AS `Balance`,`eb`.`CountPayPeriodLeft` AS `CountPayPeriodLeft`,`eb`.`DeductedAmount` AS `DeductedAmount`,`eb`.`Status` AS `Status`,`p`.`PartNo` AS `LoanName`,`ps`.`PayPeriodID` AS `PayPeriodID` from (((`employeeloanschedulebacktrack` `eb` join `employeeloanschedule` `els` on(`els`.`RowID` = `eb`.`LoanschedID`)) join `product` `p` on(`p`.`RowID` = `els`.`LoanTypeID`)) join `paystub` `ps` on(`ps`.`RowID` = `eb`.`PayStubID`)) ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
