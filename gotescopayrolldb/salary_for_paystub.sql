/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `salary_for_paystub`;
DROP TABLE IF EXISTS `salary_for_paystub`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `salary_for_paystub` AS SELECT esa.*
,pp.RowID `PayPeriodID`
# ,d.DateValue
,pp.PayFromDate
,pp.PayToDate
FROM employeesalary esa
INNER JOIN employee e
        ON e.RowID=esa.EmployeeID AND e.OrganizationID=esa.OrganizationID
INNER JOIN dates d
        ON d.DateValue BETWEEN esa.EffectiveDateFrom AND IFNULL(esa.EffectiveDateTo, d.DateValue)
INNER JOIN payperiod pp
        ON pp.OrganizationID=esa.OrganizationID
		     AND pp.TotalGrossSalary=e.PayFrequencyID
			  AND d.DateValue BETWEEN pp.PayFromDate AND pp.PayToDate ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
