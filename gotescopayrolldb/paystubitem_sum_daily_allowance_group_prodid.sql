/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `paystubitem_sum_daily_allowance_group_prodid`;
DROP TABLE IF EXISTS `paystubitem_sum_daily_allowance_group_prodid`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `paystubitem_sum_daily_allowance_group_prodid` AS SELECT
p.RowID AS ProductID
,et.EmployeeID,et.OrganizationID,et.`Date`
,0 AS Column1

# ,GET_employeerateperday(et.EmployeeID,et.OrganizationID,et.`Date`) AS Column2
# , (esa.DailyRate / IFNULL(sh.DivisorToDailyRate, 8) * GREATEST(et.VacationLeaveHours,et.SickLeaveHours,et.MaternityLeaveHours,et.OtherLeaveHours)) `LeavePay`

, esa.DailyRate `Column2`
,   ((IF(pr.PayType='Regular Day'
		, ROUND((
		         IF(p.PartNo='Ecola' AND et.TotalDayPay > 0
					   , esa.DailyRate
					   , ( (et.RegularHoursAmount * IF((es.RestDay = '1' OR es.RestDay IS NULL) AND e.CalcRestDay = '1', (pr.`PayRate` / pr.RestDayRate), 1)) + (esa.DailyRate / IFNULL(sh.DivisorToDailyRate, 8) * GREATEST(et.VacationLeaveHours,et.SickLeaveHours,et.MaternityLeaveHours,et.OtherLeaveHours)) )
					   )
					)
		        , 2)
		, IF(pr.PayType='Special Non-Working Holiday' AND e.CalcSpecialHoliday = '1'
			, IF(e.EmployeeType = 'Daily', (et.RegularHoursAmount / pr.`PayRate`), et.HolidayPayAmount)
			, IF(pr.PayType='Special Non-Working Holiday' AND e.CalcSpecialHoliday = '0'
				, IF(e.EmployeeType = 'Daily', et.RegularHoursAmount, et.HolidayPayAmount)
				, IF(pr.PayType='Regular Holiday' AND e.CalcHoliday = '1'
					, et.HolidayPayAmount + ((et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours) * (esa.DailyRate / IFNULL(sh.DivisorToDailyRate,0)))
					, 0)))) / esa.DailyRate) * ea.AllowanceAmount
    ) AS TotalAllowanceAmt

FROM employeetimeentry et
INNER JOIN employee e ON e.OrganizationID=et.OrganizationID AND e.RowID=et.EmployeeID AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
LEFT JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
LEFT JOIN shift sh ON sh.RowID=es.ShiftID
INNER JOIN employeeallowance ea ON ea.AllowanceFrequency='Daily' AND ea.EmployeeID=e.RowID AND ea.OrganizationID=e.OrganizationID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
INNER JOIN product p ON p.RowID=ea.ProductID
INNER JOIN payrate pr ON pr.RowID=et.PayRateID
INNER JOIN employeesalary_withdailyrate esa ON esa.RowID=et.EmployeeSalaryID ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
