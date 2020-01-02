/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `GetAttendancePeriod`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAttendancePeriod`(
	IN `orgId` INT,
	IN `dateFrom` DATE,
	IN `dateTo` DATE
,
	IN `isActual` TINYINT

















)
LANGUAGE SQL
DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN

SET @legalHoliday='Regular Holiday';
SET @specialHoliday='Special Non-Working Holiday';

SET @monthlyType='monthly';

SET @monthCount=12;
SET @defaultWorkHours=8;
SET @isRestDay=FALSE;
SET @isHoliday=FALSE;

DROP TEMPORARY TABLE IF EXISTS attendanceperiod;
DROP TABLE IF EXISTS attendanceperiod;

IF NOT isActual THEN

	CREATE TEMPORARY TABLE attendanceperiod
	SELECT
	et.`RowID`
	, et.`OrganizationID`
	, et.`Date`
	, @hourlyRate := TRIM(es.DailyRate / @defaultWorkHours)+0 `HourlyRate`
	, esh.RowID `EmployeeShiftID`
	, et.`EmployeeID`
	, et.`EmployeeSalaryID`
	, et.`EmployeeFixedSalaryFlag`
	
	, (@isRestDay := IFNULL(esh.RestDay, FALSE)) `IsRestDay`
	, IF(@isRestDay, et.RegularHoursWorked, 0) `RestDayHours`
	, IF(@isRestDay
			, IF(LCASE(e.EmployeeType)=@monthlyType AND e.CalcRestDay=TRUE, ROUND(et.RegularHoursAmount * ((pr.RestDayRate-pr.`PayRate`) / pr.RestDayRate), 2), et.RegularHoursAmount)
			, 0) `RestDayPay`
	
	, IF(@isRestDay, 0, et.`RegularHoursWorked`) `RegularHoursWorked`
	, IF(@isRestDay, 0, et.`RegularHoursAmount`) `RegularHoursAmount`
	
	, (@isHoliday := IFNULL(pr.PayType IN (@legalHoliday, @specialHoliday), FALSE)) `IsHoliday`
	
	, IF(@isHoliday AND et.IsValidForHolidayPayment, et.`RegularHoursWorked`, 0) `HolidayHours`
	, IF(@isHoliday=TRUE AND et.`RegularHoursWorked` > 0, et.HolidayPayAmount, 0) `HolidayPay`
	
	, et.`TotalHoursWorked`
	, et.`OvertimeHoursWorked`
	, et.`OvertimeHoursAmount`
	, et.HoursUndertime `UndertimeHours`
	, TRIM(et.HoursUndertime * @hourlyRate)+0 `UndertimeHoursAmount`
	, et.`NightDifferentialHours`
	, et.`NightDiffHoursAmount`
	, et.`NightDifferentialOTHours`
	, et.`NightDiffOTHoursAmount`
	, et.HoursTardy `HoursLate`
	, TRIM(et.HoursTardy * @hourlyRate)+0 `HoursLateAmount`
	, et.`LateFlag`
	, et.`PayRateID`
	, et.`VacationLeaveHours`
	, et.`SickLeaveHours`
	, et.`MaternityLeaveHours`
	, et.`OtherLeaveHours`
	, et.`AdditionalVLHours`
	, et.`TotalDayPay`
	, et.`Absent`
	, IF(et.Absent > 0, sh.WorkHours, 0) `AbsentHours`
	, et.`TaxableDailyAllowance`
	, et.`HolidayPayAmount`
	, et.`TaxableDailyBonus`
	, et.`NonTaxableDailyBonus`
	, et.`IsValidForHolidayPayment`

	, ROUND(( (`et`.`VacationLeaveHours` + `et`.`SickLeaveHours` + `et`.`OtherLeaveHours` + `et`.`AdditionalVLHours`) * if(`e`.`EmployeeType` = 'Daily', (`es`.`Salary` / @defaultWorkHours), ((`es`.`Salary` / (`e`.`WorkDaysPerYear` / @monthCount)) / @defaultWorkHours)) ), 2) `Leavepayment`
	, isActual `AsActual`
	, IFNULL(sh.WorkHours, 0) `WorkHours`
	, et.`AddedHolidayPayAmount`
	, es.Percentage `ActualSalaryRate`
	, es.DailyRate
	
	FROM employeetimeentry et
	INNER JOIN employee e ON e.RowID=et.EmployeeID
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID
	LEFT JOIN employeesalary_withdailyrate es ON es.RowID=et.EmployeeSalaryID

	LEFT JOIN employeeshift esh ON esh.EmployeeID=e.RowID AND esh.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo
	LEFT JOIN shift sh ON sh.RowID=esh.ShiftID
	WHERE et.OrganizationID=orgId
	AND et.`Date` BETWEEN dateFrom AND dateTo
	;

ELSE

	CREATE TEMPORARY TABLE attendanceperiod
	SELECT
	et.`RowID`
	, et.`OrganizationID`
	, et.`Date`
	, @dailyRate := TRIM(es.DailyRate * es.Percentage)+0 `DailyRate`
	, @hourlyRate := TRIM(@dailyRate / @defaultWorkHours)+0 `HourlyRate`
	, esh.RowID `EmployeeShiftID`
	, et.`EmployeeID`
	, et.`EmployeeSalaryID`
	, et.`EmployeeFixedSalaryFlag`
	
	, (@isRestDay := IFNULL(esh.RestDay, FALSE)) `IsRestDay`
	, IF(@isRestDay, et.RegularHoursWorked, 0) `RestDayHours`
	, IF(@isRestDay
			, IF(LCASE(e.EmployeeType)=@monthlyType AND e.CalcRestDay=TRUE, ROUND(et.RegularHoursAmount * ((pr.RestDayRate-pr.`PayRate`) / pr.RestDayRate), 2), et.RegularHoursAmount)
			, 0) `RestDayPay`
	
	, IF(@isRestDay, 0, et.`RegularHoursWorked`) `RegularHoursWorked`
	, IF(@isRestDay, 0, et.`RegularHoursAmount`) `RegularHoursAmount`
	
	, (@isHoliday := IFNULL(pr.PayType IN (@legalHoliday, @specialHoliday), FALSE)) `IsHoliday`
	
	, IF(@isHoliday AND ett.IsValidForHolidayPayment, et.`RegularHoursWorked`, 0) `HolidayHours`
	, IF(@isHoliday=TRUE AND et.`RegularHoursWorked` > 0, et.HolidayPayAmount, 0) `HolidayPay`
	
	, et.`TotalHoursWorked`
	, et.`OvertimeHoursWorked`
	, et.`OvertimeHoursAmount`
	, ett.HoursUndertime `UndertimeHours`

	, et.UndertimeHoursAmount
	, et.`NightDifferentialHours`
	, et.`NightDiffHoursAmount`
	, et.`NightDifferentialOTHours`
	, et.`NightDiffOTHoursAmount`
	, ett.HoursTardy `HoursLate`

	, et.HoursLateAmount
	, et.`LateFlag`
	, et.`PayRateID`
	, et.`VacationLeaveHours`
	, et.`SickLeaveHours`
	, et.`MaternityLeaveHours`
	, et.`OtherLeaveHours`
	, et.`AdditionalVLHours`
	, et.`TotalDayPay`
	, et.`Absent`
	, IF(et.Absent > 0, sh.WorkHours, 0) `AbsentHours`
	, et.`TaxableDailyAllowance`
	, et.`HolidayPayAmount`
	, et.`TaxableDailyBonus`
	, et.`NonTaxableDailyBonus`
	, ett.`IsValidForHolidayPayment`

	, ROUND(( (`et`.`VacationLeaveHours` + `et`.`SickLeaveHours` + `et`.`OtherLeaveHours` + `et`.`AdditionalVLHours`) * if(`e`.`EmployeeType` = 'Daily', (`es`.`TrueSalary` / @defaultWorkHours), ((`es`.`TrueSalary` / (`e`.`WorkDaysPerYear` / @monthCount)) / @defaultWorkHours)) ), 2) `Leavepayment`
	, isActual `AsActual`
	, IFNULL(sh.WorkHours, 0) `WorkHours`
	, et.`AddedHolidayPayAmount`
	, es.Percentage `ActualSalaryRate`
	
	FROM employeetimeentryactual et
	INNER JOIN employee e ON e.RowID=et.EmployeeID
	INNER JOIN employeetimeentry ett ON ett.EmployeeID=e.RowID AND ett.`Date`=et.`Date` AND ett.OrganizationID=et.OrganizationID
	INNER JOIN payrate pr ON pr.RowID=ett.PayRateID
	LEFT JOIN employeesalary_withdailyrate es ON es.RowID=et.EmployeeSalaryID
	LEFT JOIN employeeshift esh ON esh.EmployeeID=e.RowID AND esh.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo
	LEFT JOIN shift sh ON sh.RowID=esh.ShiftID
	WHERE et.OrganizationID=orgId
	AND et.`Date` BETWEEN dateFrom AND dateTo
	;

END IF;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
