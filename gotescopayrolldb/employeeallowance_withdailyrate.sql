/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `employeeallowance_withdailyrate`;
DROP TABLE IF EXISTS `employeeallowance_withdailyrate`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `employeeallowance_withdailyrate` AS SELECT ea.*
, IF(ea.AllowanceFrequency != 'Semi-monthly'
     , ea.AllowanceAmount
	  , ( ea.AllowanceAmount / ((e.WorkDaysPerYear / 12) / 2) )
	  ) `DailyAllowance`
FROM employeeallowance ea
INNER JOIN employee e ON e.RowID=ea.EmployeeID AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
WHERE ea.AllowanceAmount != 0
AND LENGTH(TRIM(ea.AllowanceFrequency)) > 0 ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
