/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `restdaytimeentry`;
DROP TABLE IF EXISTS `restdaytimeentry`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `restdaytimeentry` AS /*SELECT et.*
	, '1st Query' `Group`
	FROM employeetimeentry et
	INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID
	INNER JOIN organization og ON og.RowID=et.OrganizationID AND og.NoPurpose=0
	WHERE et.EmployeeShiftID IS NULL
	
Regular Holiday
Special Non-Working Holiday
Regular Day

UNION*/
	SELECT et.*
	, 0 `RestDayAmount`
	, 0 `RestDayActualPay`
	, '1st Query' `Group`
	FROM employeetimeentry et
	INNER JOIN employeeshift esh ON esh.EmployeeID=et.EmployeeID AND esh.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo AND esh.RestDay = 1
	INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID AND e.CalcRestDay = 1 AND e.EmployeeType = 'Daily' AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
	INNER JOIN organization og ON og.RowID=et.OrganizationID AND og.NoPurpose=0
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Day'
	WHERE et.RegularHoursWorked > 0
	
UNION
	SELECT et.*
	, 0 `RestDayAmount`
	, 0 `RestDayActualPay`
	, '2nd Query' `Group`
	FROM employeetimeentry et
	INNER JOIN employeeshift esh ON esh.EmployeeID=et.EmployeeID AND esh.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo AND esh.RestDay = 1
	INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID AND e.CalcRestDay = 1 AND e.EmployeeType = 'Daily' AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
	INNER JOIN organization og ON og.RowID=et.OrganizationID AND og.NoPurpose=0
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Holiday'
	WHERE et.RegularHoursWorked > 0
	
UNION
	SELECT et.*
	, 0 `RestDayAmount`
	, 0 `RestDayActualPay`
	, '3rd Query' `Group`
	FROM employeetimeentry et
	INNER JOIN employeeshift esh ON esh.EmployeeID=et.EmployeeID AND esh.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo AND esh.RestDay = 1
	INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID AND e.CalcRestDay = 1 AND e.EmployeeType = 'Daily' AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
	INNER JOIN organization og ON og.RowID=et.OrganizationID AND og.NoPurpose=0
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Special Non-Working Holiday'
	WHERE et.RegularHoursWorked > 0 
	
	
	
############################################################################
	
	
	
UNION
	SELECT et.*
	, (et.RegularHoursAmount * (1 - (1 / pr.RestDayRate))) `RestDayAmount`
	, (et.RegularHoursAmount * (1 - (1 / pr.RestDayRate))) * esa.Percentage `RestDayActualPay`
	, '4th Query' `Group`
	FROM employeetimeentry et
	INNER JOIN employeeshift esh ON esh.EmployeeID=et.EmployeeID AND esh.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo AND esh.RestDay = 1
	INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID AND e.CalcRestDay = 1 AND e.EmployeeType IN ('Fixed', 'Monthly') AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
	INNER JOIN organization og ON og.RowID=et.OrganizationID AND og.NoPurpose=0
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Day'
	INNER JOIN employeesalary_withdailyrate esa ON esa.RowID = et.EmployeeSalaryID
	WHERE et.RegularHoursWorked > 0
	
UNION
	SELECT et.*
	, (et.RegularHoursAmount * (1 - (pr.`PayRate` / pr.RestDayRate))) `RestDayAmount`
	, (et.RegularHoursAmount * (1 - (1 / pr.RestDayRate))) * esa.Percentage `RestDayActualPay`
	, '5th Query' `Group`
	FROM employeetimeentry et
	INNER JOIN employeeshift esh ON esh.EmployeeID=et.EmployeeID AND esh.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo AND esh.RestDay = 1
	INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID AND e.CalcRestDay = 1 AND e.EmployeeType IN ('Fixed', 'Monthly') AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
	INNER JOIN organization og ON og.RowID=et.OrganizationID AND og.NoPurpose=0
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Holiday'
	INNER JOIN employeesalary_withdailyrate esa ON esa.RowID = et.EmployeeSalaryID
	WHERE et.RegularHoursWorked > 0
	
UNION
	SELECT et.*
	, (et.RegularHoursAmount * (1 - (pr.`PayRate` / pr.RestDayRate))) `RestDayAmount`
	, (et.RegularHoursAmount * (1 - (1 / pr.RestDayRate))) * esa.Percentage `RestDayActualPay`
	, '6th Query' `Group`
	FROM employeetimeentry et
	INNER JOIN employeeshift esh ON esh.EmployeeID=et.EmployeeID AND esh.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo AND esh.RestDay = 1
	INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID AND e.CalcRestDay = 1 AND e.EmployeeType IN ('Fixed', 'Monthly') AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
	INNER JOIN organization og ON og.RowID=et.OrganizationID AND og.NoPurpose=0
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Special Non-Working Holiday'
	INNER JOIN employeesalary_withdailyrate esa ON esa.RowID = et.EmployeeSalaryID
	WHERE et.RegularHoursWorked > 0 ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
