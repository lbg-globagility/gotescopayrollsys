/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `monthlyemployee_restday_payment`;
DROP TABLE IF EXISTS `monthlyemployee_restday_payment`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `monthlyemployee_restday_payment` AS SELECT et.*
	, DAYNAME(et.`Date`) `DayName`
	, (esa.Salary / (e.WorkDaysPerYear / 12)) `DailyRate`
	, (et.RegularHoursAmount * (1 - (1 / pr.RestDayRate))) `AddtlRestDayPayment`
	, (esa.TrueSalary / esa.Salary) `ActualPercentage`
	FROM employeetimeentry et
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType = 'Regular Day'
	INNER JOIN employee e
	        ON e.RowID=et.EmployeeID
			     AND e.OrganizationID=et.OrganizationID
				  AND e.EmploymentStatus = 'Regular'
				  AND e.EmployeeType = 'Monthly'
				  AND e.CalcRestDay = TRUE
	INNER JOIN employeesalary esa
	        ON esa.RowID=et.EmployeeSalaryID
	INNER JOIN employeeshift esh
	        ON esh.RowID=et.EmployeeShiftID AND esh.RestDay = TRUE
	WHERE et.RegularHoursWorked > 0
	AND et.TotalDayPay > 0

UNION
	SELECT et.*
	, DAYNAME(et.`Date`) `DayName`
	, (esa.Salary / (e.WorkDaysPerYear / 12)) `DailyRate`
	, (et.RegularHoursAmount * (1 - (1 / pr.RestDayRate))) `AddtlRestDayPayment`
	, (esa.TrueSalary / esa.Salary) `ActualPercentage`
	FROM employeetimeentry et
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType = 'Regular Day'
	INNER JOIN employee e
	        ON e.RowID=et.EmployeeID
			     AND e.OrganizationID=et.OrganizationID
				  AND e.EmploymentStatus = 'Regular'
				  AND e.EmployeeType = 'Monthly'
				  AND e.CalcRestDay = TRUE
	INNER JOIN employeesalary esa
	        ON esa.RowID=et.EmployeeSalaryID
	WHERE et.RegularHoursWorked > 0
	AND et.TotalDayPay > 0
	AND et.EmployeeShiftID IS NULL

# #############################################

UNION
	SELECT et.*
	, DAYNAME(et.`Date`) `DayName`
	, (esa.Salary / (e.WorkDaysPerYear / 12)) `DailyRate`
	, (et.RegularHoursAmount * (1 - (1 / pr.RestDayRate))) `AddtlRestDayPayment`
	, (esa.TrueSalary / esa.Salary) `ActualPercentage`
	FROM employeetimeentry et
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType = 'Regular Day'
	INNER JOIN employee e
	        ON e.RowID=et.EmployeeID
			     AND e.OrganizationID=et.OrganizationID
				  AND e.EmploymentStatus = 'Contractual'
				  AND e.EmployeeType = 'Monthly'
				  AND e.CalcRestDay = TRUE
	INNER JOIN employeesalary esa
	        ON esa.RowID=et.EmployeeSalaryID
	INNER JOIN employeeshift esh
	        ON esh.RowID=et.EmployeeShiftID AND esh.RestDay = TRUE
	WHERE et.RegularHoursWorked > 0
	AND et.TotalDayPay > 0

UNION
	SELECT et.*
	, DAYNAME(et.`Date`) `DayName`
	, (esa.Salary / (e.WorkDaysPerYear / 12)) `DailyRate`
	, (et.RegularHoursAmount * (1 - (1 / pr.RestDayRate))) `AddtlRestDayPayment`
	, (esa.TrueSalary / esa.Salary) `ActualPercentage`
	FROM employeetimeentry et
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType = 'Regular Day'
	INNER JOIN employee e
	        ON e.RowID=et.EmployeeID
			     AND e.OrganizationID=et.OrganizationID
				  AND e.EmploymentStatus = 'Contractual'
				  AND e.EmployeeType = 'Monthly'
				  AND e.CalcRestDay = TRUE
	INNER JOIN employeesalary esa
	        ON esa.RowID=et.EmployeeSalaryID
	WHERE et.RegularHoursWorked > 0
	AND et.TotalDayPay > 0
	AND et.EmployeeShiftID IS NULL ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
