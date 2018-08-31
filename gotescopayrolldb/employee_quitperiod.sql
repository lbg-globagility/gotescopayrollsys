/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `employee_quitperiod`;
DROP TABLE IF EXISTS `employee_quitperiod`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `employee_quitperiod` AS SELECT
# pp.*,

e.RowID `EmployeeId`
, e.OrganizationID
, e.PayFrequencyID

, pp.RowID `PayPeriodId`
, pp.`Year`
, pp.OrdinalValue
, pp.PayFromDate
, pp.PayToDate

FROM employee e
INNER JOIN payperiod pp ON pp.OrganizationID=e.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID AND e.TerminationDate BETWEEN pp.PayFromDate AND pp.PayToDate
WHERE FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) > 0
AND e.TerminationDate IS NOT NULL ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
