-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.5.5-10.0.12-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             8.3.0.4694
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for view gotescopayrolldb_server.paystubitem_sum_semimon_allowance_group_prodid
DROP VIEW IF EXISTS `paystubitem_sum_semimon_allowance_group_prodid`;
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `paystubitem_sum_semimon_allowance_group_prodid`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `paystubitem_sum_semimon_allowance_group_prodid` AS SELECT
	et.RowID
	,ea.ProductID
	,ea.EmployeeID
	,ea.OrganizationID
	,d.DateValue `Date`
	,0 `Column1`
	,0 `Column2`
	,ea.AllowanceAmount `TotalAllowanceAmt`
	,ea.TaxableFlag
	,IF(IFNULL(et.Absent, 0) > 0, IFNULL(sh.DivisorToDailyRate, 8), 0) `HoursToLess`
	,ea.AllowanceAmount
	,e.WorkDaysPerYear
	,p.`Fixed`
	,PAYFREQUENCY_DIVISOR(pf.PayFrequencyType) `PAYFREQDIV`
	,IFNULL(sh.DivisorToDailyRate, 8) `DivisorToDailyRate`
	,1 `Result`
	FROM employeeallowance ea
	INNER JOIN employee e ON e.OrganizationID=ea.OrganizationID AND e.RowID=ea.EmployeeID AND e.EmploymentStatus='Regular'
	INNER JOIN product p ON p.RowID=ea.ProductID AND LOCATE('ecola', LCASE(p.PartNo)) > 0
	INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
	INNER JOIN dates d ON d.DateValue BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
	LEFT JOIN employeetimeentry et ON et.`Date`=d.DateValue AND et.EmployeeID=e.RowID AND et.OrganizationID=e.OrganizationID
	LEFT JOIN employeesalary esa ON esa.RowID=et.EmployeeSalaryID
	LEFT JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
	LEFT JOIN shift sh ON sh.RowID=es.ShiftID
	INNER JOIN payrate pr ON pr.`Date`=d.DateValue AND pr.OrganizationID=ea.OrganizationID
	WHERE ea.AllowanceFrequency='Semi-monthly'# AND d.DateValue BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate

UNION
	SELECT
	et.RowID
	,ea.ProductID
	,ea.EmployeeID
	,ea.OrganizationID
	,d.DateValue `Date`
	,0 `Column1`
	,0 `Column2`
	,ea.AllowanceAmount `TotalAllowanceAmt`
	,ea.TaxableFlag
	,IF(pr.PayType != 'Regular Day' OR IFNULL(et.Absent, 0) > 0
	    , IFNULL(sh.DivisorToDailyRate, 8)
		 , 0) `HoursToLess`
	,ea.AllowanceAmount
	,e.WorkDaysPerYear
	,p.`Fixed`
	,PAYFREQUENCY_DIVISOR(pf.PayFrequencyType) `PAYFREQDIV`
	,IFNULL(sh.DivisorToDailyRate, 8) `DivisorToDailyRate`
	,2 `Result`
	FROM employeeallowance ea
	INNER JOIN employee e ON e.OrganizationID=ea.OrganizationID AND e.RowID=ea.EmployeeID AND e.EmploymentStatus='Contractual'
	INNER JOIN product p ON p.RowID=ea.ProductID AND LOCATE('ecola', LCASE(p.PartNo)) > 0
	INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
	INNER JOIN dates d ON d.DateValue BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
	LEFT JOIN employeetimeentry et ON et.`Date`=d.DateValue AND et.EmployeeID=e.RowID AND et.OrganizationID=e.OrganizationID
	LEFT JOIN employeesalary esa ON esa.RowID=et.EmployeeSalaryID
	LEFT JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
	LEFT JOIN shift sh ON sh.RowID=es.ShiftID
	INNER JOIN payrate pr ON pr.`Date`=d.DateValue AND pr.OrganizationID=ea.OrganizationID #AND pr.PayType != 'Regular Day'
	WHERE ea.AllowanceFrequency='Semi-monthly'# AND d.DateValue BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
	
UNION
	SELECT
	et.RowID
	,(ea.ProductID) AS ProductID
	,et.EmployeeID,et.OrganizationID,et.`Date`
	,0 AS Column1
	,IF(e.EmployeeType = 'Daily', esa.BasicPay, ( esa.Salary / (e.WorkDaysPerYear / 12) )) AS Column2
	,((IF(pr.PayType='Regular Day'
			, IF(et.TotalDayPay > et.RegularHoursAmount AND (et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours) > 0, IF(et.RegularHoursAmount = 0, et.TotalDayPay, et.RegularHoursAmount), IF(et.RegularHoursAmount > IF(e.EmployeeType = 'Daily', esa.BasicPay, ( esa.Salary / (e.WorkDaysPerYear / 12) )), IF(e.EmployeeType = 'Daily', esa.BasicPay, ( esa.Salary / (e.WorkDaysPerYear / 12) )), et.RegularHoursAmount))
			, IF(pr.PayType='Special Non-Working Holiday' AND e.CalcSpecialHoliday = '1'
				, IF(e.EmployeeType = 'Daily', (et.RegularHoursAmount / pr.`PayRate`), et.HolidayPayAmount)
				, IF(pr.PayType='Special Non-Working Holiday' AND e.CalcSpecialHoliday = '0'
					, IF(e.EmployeeType = 'Daily', et.RegularHoursAmount, et.HolidayPayAmount)
					, IF(pr.PayType='Regular Holiday' AND e.CalcHoliday = '1'
						, et.HolidayPayAmount + ((et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours) * (IF(e.EmployeeType = 'Daily', esa.BasicPay, ( esa.Salary / (e.WorkDaysPerYear / 12) ))
						/ IFNULL(COMPUTE_TimeDifference(sh.TimeFrom, sh.TimeTo) - COMPUTE_TimeDifference(sh.BreakTimeFrom, sh.BreakTimeTo),0)))
						#/ IFNULL(sh.DivisorToDailyRate,0)))
						, 0)))) / IF(e.EmployeeType = 'Daily', esa.BasicPay, ( esa.Salary / (e.WorkDaysPerYear / 12) ))) * (ea.AllowanceAmount / (e.WorkDaysPerYear / (PAYFREQUENCY_DIVISOR(pf.PayFrequencyType) * 12))) ) AS TotalAllowanceAmt
	,ea.TaxableFlag
	,(et.HoursLate + et.UndertimeHours) AS HoursToLess
	,ea.AllowanceAmount
	,e.WorkDaysPerYear
	,p.`Fixed`
	,PAYFREQUENCY_DIVISOR(pf.PayFrequencyType) AS PAYFREQDIV
	,IFNULL(sh.DivisorToDailyRate, 8) `DivisorToDailyRate`
	,3 `Result`
	FROM employeetimeentry et
	INNER JOIN employee e ON e.OrganizationID=et.OrganizationID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') #AND e.EmployeeType!='Fixed'
	INNER JOIN employeesalary esa ON esa.RowID=et.EmployeeSalaryID
	INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
	LEFT JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
	LEFT JOIN shift sh ON sh.RowID=es.ShiftID
	INNER JOIN employeeallowance ea ON ea.AllowanceFrequency='Semi-monthly' AND ea.EmployeeID=e.RowID AND ea.OrganizationID=e.OrganizationID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
	INNER JOIN product p ON p.RowID=ea.ProductID AND LOCATE('ecola', LCASE(p.PartNo)) = 0
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
