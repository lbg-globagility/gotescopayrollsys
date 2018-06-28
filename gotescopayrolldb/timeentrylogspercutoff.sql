/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `timeentrylogspercutoff`;
DROP TABLE IF EXISTS `timeentrylogspercutoff`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `timeentrylogspercutoff` AS SELECT etd.RowID
, etd.OrganizationId
, etd.Created
, etd.CreatedBy
, etd.LastUpd
, etd.LastUpdBy
, etd.EmployeeID
, etd.TimeIn
, etd.TimeOut
, etd.`Date`
, etd.TimeScheduleType
, etd.TimeEntryStatus
, etd.TimeentrylogsImportID

, pp.RowID `PayPeriodID`
, pp.PayFromDate
, pp.PayToDate
, pp.`Month`
, pp.`Year`
, pp.OrdinalValue

, e.RowID `EmployeePrimaKey`
, e.EmployeeID `EmployeeUniqueKey`
, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `FullName`

, TIME_FORMAT(etd.TimeIn, '%l:%i %p') `TimeInText`
, TIME_FORMAT(etd.TimeOut, '%l:%i %p') `TimeOutText`

FROM employeetimeentrydetails etd
INNER JOIN organization og ON og.RowID = etd.OrganizationID AND og.NoPurpose = 0
INNER JOIN employee e ON e.RowID = etd.EmployeeID AND e.OrganizationID = og.RowID AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
INNER JOIN payperiod pp ON pp.OrganizationID = e.OrganizationID AND pp.TotalGrossSalary = e.PayFrequencyID AND etd.`Date` BETWEEN pp.PayFromDate AND pp.PayToDate
WHERE etd.EmployeeID IS NOT NULL
ORDER BY pp.`Year` DESC, pp.OrdinalValue DESC ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
