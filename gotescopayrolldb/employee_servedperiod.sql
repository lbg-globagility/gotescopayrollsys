/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `employee_servedperiod`;
DROP TABLE IF EXISTS `employee_servedperiod`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `employee_servedperiod` AS SELECT

e.*
, ee.PayPeriodId `ServedPeriod`
, quit.PayPeriodId `QuitPeriod`

, ee.Description

FROM employee_activeperiod ee
INNER JOIN employee e ON e.RowID=ee.RowID
LEFT JOIN employee_quitperiod quit ON quit.EmployeeId=e.RowID
INNER JOIN payperiod pp ON pp.RowID=ee.PayPeriodId
# WHERE ee.RowID=114
ORDER BY pp.`Year`, pp.OrdinalValue ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
