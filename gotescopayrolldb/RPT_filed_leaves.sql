/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `RPT_filed_leaves`;
DELIMITER //
CREATE PROCEDURE `RPT_filed_leaves`(
	IN `org_rowid` INT,
	IN `emp_rowid` INT,
	IN `date_from` DATE,
	IN `date_to` DATE








)
BEGIN

DECLARE leave_prodids TEXT;

DECLARE yeartofollow INT(11);

DECLARE remarks TEXT;

DECLARE custom_dateformat TEXT DEFAULT '%c/%e/%Y';

SELECT GROUP_CONCAT(p.RowID)
FROM product p
WHERE p.`Category`='Leave type'
AND p.OrganizationID=org_rowid
AND p.PartNo IN ('Vacation leave', 'Sick leave', 'Others', 'Additional VL')
INTO leave_prodids;

SELECT MAX(pp.`Year`)
FROM payperiod pp
INNER JOIN dates d ON d.DateValue BETWEEN date_from AND date_to
WHERE pp.OrganizationID = org_rowid
AND d.DateValue BETWEEN pp.PayFromDate AND pp.PayToDate
AND pp.TotalGrossSalary = 1
INTO yeartofollow;

SELECT CONCAT('BALANCE AS OF ', DATE_FORMAT(MAX(pp.PayToDate), custom_dateformat)) `Remarks`
FROM payperiod pp
WHERE pp.OrganizationID = org_rowid
AND pp.TotalGrossSalary = 1
AND date_to BETWEEN pp.PayFromDate AND pp.PayToDate
INTO remarks;

SET @eIds='';
SELECT
GROUP_CONCAT(i.EmployeeID) `Result`
FROM (SELECT
		et.EmployeeID
		FROM employee e
		LEFT JOIN employeetimeentry et
			ON et.EmployeeID = e.RowID
			AND et.OrganizationID = e.OrganizationID
			AND et.`Date` BETWEEN date_from AND date_to
		WHERE et.OrganizationID = org_rowid
		AND IFNULL(emp_rowid, e.RowID) = e.RowID
		AND IFNULL(e.TerminationDate, date_to) BETWEEN date_from AND date_to
		AND (e.LeaveAllowance + e.SickLeaveAllowance + e.OtherLeaveAllowance + e.AdditionalVLAllowance) > 0
		GROUP BY et.EmployeeID
		HAVING SUM(IFNULL((et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours), 0)) = 0) i
INTO @eIds;

	SELECT
	x.*
	FROM (SELECT
			et.RowID
			, DATE_FORMAT(et.`Date`, custom_dateformat) `Date`
			,et.`Date` `DateValue`
			,et.EmployeeShiftID
			,e.EmployeeID
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
			
			, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `FullName`
			, e.LeaveAllowance
			, e.SickLeaveAllowance
			, e.OtherLeaveAllowance
			, e.AdditionalVLAllowance
			
			, (e.LeaveAllowance
			   + e.SickLeaveAllowance
			   + e.OtherLeaveAllowance
			   + e.AdditionalVLAllowance) `TotalLeave`
			
			, remarks `Remarks`
			
			,TRUE `HasLeave`
			FROM employeetimeentry et
			
			INNER JOIN employee e
				ON e.RowID=et.EmployeeID
				AND e.RowID = IFNULL(emp_rowid, e.RowID)
				AND e.OrganizationID = et.OrganizationID
				AND IFNULL(e.TerminationDate, date_to) BETWEEN date_from AND date_to
					     
			WHERE et.OrganizationID = org_rowid
			AND et.`Date` BETWEEN date_from AND date_to
			AND (et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) > 0
		
		UNION
			SELECT
			NULL `RowID`
			,NULL `Date`
			,NULL `DateValue`
			,NULL `EmployeeShiftID`
			,e.EmployeeID
			,NULL `EmployeeSalaryID`
			,NULL `EmployeeFixedSalaryFlag`
			,NULL `RegularHoursWorked`
			,NULL `RegularHoursAmount`
			,NULL `TotalHoursWorked`
			,NULL `OvertimeHoursWorked`
			,NULL `OvertimeHoursAmount`
			,NULL `UndertimeHours`
			,NULL `UndertimeHoursAmount`
			,NULL `NightDifferentialHours`
			,NULL `NightDiffHoursAmount`
			,NULL `NightDifferentialOTHours`
			,NULL `NightDiffOTHoursAmount`
			,NULL `HoursLate`
			,NULL `HoursLateAmount`
			,NULL `LateFlag`
			,NULL `PayRateID`
			,NULL `VacationLeaveHours`
			,NULL `SickLeaveHours`
			,NULL `MaternityLeaveHours`
			,NULL `OtherLeaveHours`
			,NULL `AdditionalVLHours`
			,NULL `TotalDayPay`
			,NULL `Absent`
			,NULL `TaxableDailyAllowance`
			,NULL `HolidayPayAmount`
			,NULL `TaxableDailyBonus`
			,NULL `NonTaxableDailyBonus`
			,NULL `IsValidForHolidayPayment`
			
			, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `FullName`
			, e.LeaveAllowance
			, e.SickLeaveAllowance
			, e.OtherLeaveAllowance
			, e.AdditionalVLAllowance
			
			, (e.LeaveAllowance
			   + e.SickLeaveAllowance
			   + e.OtherLeaveAllowance
			   + e.AdditionalVLAllowance) `TotalLeave`
			
			, remarks `Remarks`
			
			,FALSE `HasLeave`
			FROM employee e
			WHERE LOCATE(e.RowID, @eIds) > 0
			AND IFNULL(e.TerminationDate, date_to) BETWEEN date_from AND date_to
			) x
	
#	ORDER BY CONCAT(e.LastName, e.FirstName), et.`DateValue`
	ORDER BY x.`FullName`, x.`DateValue`
	;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
