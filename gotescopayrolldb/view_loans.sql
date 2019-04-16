/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `view_loans`;
DROP TABLE IF EXISTS `view_loans`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_loans` AS select `els`.`RowID` AS `RowID`,`els`.`OrganizationID` AS `OrganizationID`,`els`.`Created` AS `Created`,`els`.`CreatedBy` AS `CreatedBy`,`els`.`LastUpd` AS `LastUpd`,`els`.`LastUpdBy` AS `LastUpdBy`,`els`.`EmployeeID` AS `EmployeeID`,`els`.`LoanNumber` AS `LoanNumber`,`els`.`DedEffectiveDateFrom` AS `DedEffectiveDateFrom`,`els`.`DedEffectiveDateTo` AS `DedEffectiveDateTo`,`els`.`TotalLoanAmount` AS `TotalLoanAmount`,`els`.`DeductionSchedule` AS `DeductionSchedule`,`els`.`TotalBalanceLeft` AS `TotalBalanceLeft`,`els`.`DeductionAmount` AS `DeductionAmount`,`els`.`Status` AS `Status`,`els`.`LoanTypeID` AS `LoanTypeID`,`els`.`DeductionPercentage` AS `DeductionPercentage`,`els`.`NoOfPayPeriod` AS `NoOfPayPeriod`,`els`.`LoanPayPeriodLeft` AS `LoanPayPeriodLeft`,`els`.`Comments` AS `Comments`,`els`.`Nondeductible` AS `Nondeductible`,`els`.`ReferenceLoanID` AS `ReferenceLoanID`,`els`.`SubstituteEndDate` AS `SubstituteEndDate`,`els`.`PayStubID` AS `PayStubID` from `employeeloanschedule` `els` ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
