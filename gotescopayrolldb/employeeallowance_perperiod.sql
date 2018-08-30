/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `employeeallowance_perperiod`;
DROP TABLE IF EXISTS `employeeallowance_perperiod`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `employeeallowance_perperiod` AS SELECT ea.*
, pp.RowID `PayPeriodId`
, p.PartNo `AllowanceName`
FROM payperiod pp
INNER JOIN employeeallowance ea
        ON ea.OrganizationID=pp.OrganizationID
		     AND ea.AllowanceAmount != 0
		     AND (ea.EffectiveStartDate <= pp.PayFromDate OR ea.EffectiveStartDate <= pp.PayToDate)
		     AND (ea.EffectiveEndDate >= pp.PayFromDate OR ea.EffectiveEndDate >= pp.PayToDate)
INNER JOIN product p ON p.RowID=ea.ProductID
INNER JOIN employee e ON e.RowID=ea.EmployeeID AND e.OrganizationID=ea.OrganizationID AND e.PayFrequencyID=pp.TotalGrossSalary ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
