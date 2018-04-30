/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `leavetimeentry`;
DROP TABLE IF EXISTS `leavetimeentry`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `leavetimeentry` AS SELECT et.*
, (et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) `LeaveHours`
, ((esa.DailyRate / sh.DivisorToDailyRate) * (et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours)) `LeavePayment`
FROM employeetimeentry et
INNER JOIN employeeshift esh
        ON esh.EmployeeID=et.EmployeeID
		     AND esh.OrganizationID=et.OrganizationID
			  AND et.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo
INNER JOIN shift sh
        ON sh.RowID=esh.ShiftID

INNER JOIN employee e
        ON e.RowID=et.EmployeeID
		     AND e.OrganizationID=et.OrganizationID
			  AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
INNER JOIN organization og
        ON og.RowID=et.OrganizationID
		     AND og.NoPurpose=0

INNER JOIN employeesalary_withdailyrate esa
        ON esa.RowID = et.EmployeeSalaryID

WHERE (et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) > 0
GROUP BY et.RowID ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
