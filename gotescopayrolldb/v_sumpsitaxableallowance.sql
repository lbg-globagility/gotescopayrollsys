/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `v_sumpsitaxableallowance`;
DROP TABLE IF EXISTS `v_sumpsitaxableallowance`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_sumpsitaxableallowance` AS select `psi`.`RowID` AS `psiRowID`,`psi`.`PayAmount` AS `PayAmount`,`psi`.`OrganizationID` AS `OrganizationID`,`psi`.`PayStubID` AS `PayStubID`,`psi`.`ProductID` AS `ProductID`,`psi`.`Undeclared` AS `Undeclared`,`p`.`CategoryID` AS `CategoryID`,`p`.`Status` AS `Taxable`,`p`.`PartNo` AS `PartNo` from (`paystubitem` `psi` join `product` `p` on(`p`.`RowID` = `psi`.`ProductID`)) order by `psi`.`PayStubID` ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
