/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `socialsecurityservice`;
CREATE TABLE `socialsecurityservice` (
	`RowID` INT(11) NOT NULL,
	`Created` TIMESTAMP NULL,
	`CreatedBy` INT(10) NOT NULL,
	`LastUpd` DATETIME NULL,
	`LastUpdBy` INT(10) NULL,
	`RangeFromAmount` DECIMAL(10,2) NOT NULL,
	`RangeToAmount` DECIMAL(10,2) NOT NULL,
	`MonthlySalaryCredit` DECIMAL(10,2) NOT NULL,
	`EmployeeContributionAmount` DECIMAL(10,2) NOT NULL,
	`EmployerContributionAmount` DECIMAL(10,2) NOT NULL,
	`EmployeeECAmount` DECIMAL(10,2) NOT NULL,
	`HiddenData` CHAR(1) NOT NULL COLLATE 'latin1_swedish_ci',
	`EffectiveDateFrom` DATE NOT NULL,
	`EffectiveDateTo` DATE NOT NULL
) ENGINE=MyISAM;

DROP VIEW IF EXISTS `socialsecurityservice`;
DROP TABLE IF EXISTS `socialsecurityservice`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `socialsecurityservice` AS select * from paysocialsecurity ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
