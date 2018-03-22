-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.5.5-10.0.12-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win32
-- HeidiSQL Version:             8.3.0.4694
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for view gotescopayrolldb_server.proper_time_entry
DROP VIEW IF EXISTS `proper_time_entry`;
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `proper_time_entry`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `proper_time_entry` AS SELECT
	et.RowID
	,et.OrganizationID
	,et.`Date`
	,et.EmployeeShiftID
	,et.EmployeeID
	,et.EmployeeSalaryID
	,et.EmployeeFixedSalaryFlag
	,et.RegularHoursWorked
	,et.RegularHoursAmount
	,et.TotalHoursWorked
	,et.OvertimeHoursWorked
	,et.OvertimeHoursAmount
	,et.UndertimeHours
	,et.UndertimeHoursAmount
	,et.NightDifferentialHours
	,et.NightDiffHoursAmount
	,et.NightDifferentialOTHours
	,et.NightDiffOTHoursAmount
	,et.HoursLate
	,et.HoursLateAmount
	,et.LateFlag
	,et.PayRateID
	,et.VacationLeaveHours
	,et.SickLeaveHours
	,et.MaternityLeaveHours
	,et.OtherLeaveHours
	,et.AdditionalVLHours
	,et.TotalDayPay
	,et.Absent
	,et.TaxableDailyAllowance
	,et.HolidayPayAmount
	,et.TaxableDailyBonus
	,et.NonTaxableDailyBonus
	,et.IsValidForHolidayPayment
	,((et.VacationLeaveHours + et.SickLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours)
	  * IF(e.EmployeeType = 'Daily'
	       , (esa.BasicPay / IFNULL(sh.DivisorToDailyRate, 8))
		    , ((esa.Salary / (e.WorkDaysPerYear / 12)) / IFNULL(sh.DivisorToDailyRate, 8)))
	  ) `Leavepayment`
	,0 `AsActual`
	FROM employeetimeentry et
	INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID
	INNER JOIN employeesalary esa ON esa.RowID=et.EmployeeSalaryID
	LEFT JOIN employeeshift esh ON esh.RowID=et.EmployeeShiftID
	LEFT JOIN shift sh ON sh.RowID=esh.ShiftID AND sh.OrganizationID=et.OrganizationID

UNION
	SELECT
	et.RowID
	,et.OrganizationID
	,et.`Date`
	,et.EmployeeShiftID
	,et.EmployeeID
	,et.EmployeeSalaryID
	,et.EmployeeFixedSalaryFlag
	,et.RegularHoursWorked
	,et.RegularHoursAmount
	,et.TotalHoursWorked
	,et.OvertimeHoursWorked
	,et.OvertimeHoursAmount
	,et.UndertimeHours
	,et.UndertimeHoursAmount
	,et.NightDifferentialHours
	,et.NightDiffHoursAmount
	,et.NightDifferentialOTHours
	,et.NightDiffOTHoursAmount
	,et.HoursLate
	,et.HoursLateAmount
	,et.LateFlag
	,et.PayRateID
	,et.VacationLeaveHours
	,et.SickLeaveHours
	,et.MaternityLeaveHours
	,et.OtherLeaveHours
	,et.AdditionalVLHours
	,et.TotalDayPay
	,et.Absent
	,et.TaxableDailyAllowance
	,et.HolidayPayAmount
	,et.TaxableDailyBonus
	,et.NonTaxableDailyBonus
	,ete.IsValidForHolidayPayment
	,((et.VacationLeaveHours + et.SickLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours)
	  * IF(e.EmployeeType = 'Daily'
	       , (esa.BasicPay / IFNULL(sh.DivisorToDailyRate, 8))
		    , ((esa.Salary / (e.WorkDaysPerYear / 12)) / IFNULL(sh.DivisorToDailyRate, 8)))
	  ) `Leavepayment`
	,1 `AsActual`
	FROM employeetimeentryactual et
	INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID
	INNER JOIN employeetimeentry ete ON ete.RowID=et.RowID
	INNER JOIN employeesalary esa ON esa.RowID=et.EmployeeSalaryID
	LEFT JOIN employeeshift esh ON esh.RowID=et.EmployeeShiftID
	LEFT JOIN shift sh ON sh.RowID=esh.ShiftID AND sh.OrganizationID=et.OrganizationID ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
