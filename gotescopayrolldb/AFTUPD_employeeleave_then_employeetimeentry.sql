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

-- Dumping structure for trigger gotescopayrolldb_server.AFTUPD_employeeleave_then_employeetimeentry
DROP TRIGGER IF EXISTS `AFTUPD_employeeleave_then_employeetimeentry`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `AFTUPD_employeeleave_then_employeetimeentry` AFTER UPDATE ON `employeeleave` FOR EACH ROW BEGIN

DECLARE leav_type VARCHAR(50);

DECLARE any_int
        ,default_min_hrswork INT(11);

DECLARE month_count INT(11) DEFAULT 12;

SET default_min_hrswork = 8;

SET leav_type = LCASE(NEW.LeaveType);

	UPDATE employeetimeentry et
	INNER JOIN (SELECT *
	            FROM dates d
					WHERE d.DateValue BETWEEN NEW.LeaveStartDate AND NEW.LeaveEndDate
					ORDER BY d.DateValue) d ON d.DateValue = et.`Date`
	SET et.LastUpd = CURRENT_TIMESTAMP()
	,et.LastUpdBy = NEW.LastUpdBy
	,et.RegularHoursWorked=0
	,et.RegularHoursAmount=0
	,et.TotalHoursWorked=0
	,et.OvertimeHoursWorked=0
	,et.OvertimeHoursAmount=0
	,et.UndertimeHours=0
	,et.UndertimeHoursAmount=0
	,et.NightDifferentialHours=0
	,et.NightDiffHoursAmount=0
	,et.NightDifferentialOTHours=0
	,et.NightDiffOTHoursAmount=0
	,et.HoursLate=0
	,et.HoursLateAmount=0
	,et.VacationLeaveHours=0
	,et.SickLeaveHours=0
	,et.MaternityLeaveHours=0
	,et.OtherLeaveHours=0
	,et.AdditionalVLHours=0
	,et.TotalDayPay=0
	,et.Absent=0
	,et.TaxableDailyAllowance=0
	,et.HolidayPayAmount=0
	,et.TaxableDailyBonus=0
	,et.NonTaxableDailyBonus=0
	WHERE et.EmployeeID=NEW.EmployeeID
	AND et.OrganizationID=NEW.OrganizationID;

IF LOCATE('aternity', leav_type) > 0 THEN
	
	UPDATE employeetimeentry et
	INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID
	INNER JOIN (SELECT *
	            FROM dates d
					WHERE d.DateValue BETWEEN NEW.LeaveStartDate AND NEW.LeaveEndDate
					ORDER BY d.DateValue) d ON d.DateValue = et.`Date`
	LEFT JOIN employeesalary esa ON esa.RowID=et.EmployeeSalaryID
	SET et.LastUpd = CURRENT_TIMESTAMP()
	,et.LastUpdBy = NEW.LastUpdBy
	,et.MaternityLeaveHours = 0
	,et.TotalDayPay = 0
	WHERE et.EmployeeID=NEW.EmployeeID
	AND et.OrganizationID=NEW.OrganizationID;

ELSEIF LOCATE('vacation', leav_type) > 0 THEN

	UPDATE employeetimeentry et
	INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID
	INNER JOIN (SELECT *
	            FROM dates d
					WHERE d.DateValue BETWEEN NEW.LeaveStartDate AND NEW.LeaveEndDate
					ORDER BY d.DateValue) d ON d.DateValue = et.`Date`
	LEFT JOIN employeesalary esa ON esa.RowID=et.EmployeeSalaryID
	SET et.LastUpd = CURRENT_TIMESTAMP()
	,et.LastUpdBy = NEW.LastUpdBy
	,et.VacationLeaveHours = IF(NEW.`Status` = 'Approved'
	                            , IF(et.EmployeeShiftID IS NULL, default_min_hrswork, NEW.OfficialValidHours)
										 , 0)
	,et.TotalDayPay = IF(e.EmployeeType = 'Daily'
	                     , esa.BasicPay
								, esa.Salary / (e.WorkDaysPerYear / month_count))
                     * IF(et.EmployeeShiftID IS NULL, 1
							     , IF((NEW.OfficialValidHours / default_min_hrswork) > 1, 1
								       , (NEW.OfficialValidHours / default_min_hrswork)))
	WHERE et.EmployeeID=NEW.EmployeeID
	AND et.OrganizationID=NEW.OrganizationID;

ELSEIF LOCATE('sick', leav_type) > 0 THEN

	UPDATE employeetimeentry et
	INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID
	INNER JOIN (SELECT *
	            FROM dates d
					WHERE d.DateValue BETWEEN NEW.LeaveStartDate AND NEW.LeaveEndDate
					ORDER BY d.DateValue) d ON d.DateValue = et.`Date`
	LEFT JOIN employeesalary esa ON esa.RowID=et.EmployeeSalaryID
	SET et.LastUpd = CURRENT_TIMESTAMP()
	,et.LastUpdBy = NEW.LastUpdBy
	,et.SickLeaveHours = IF(NEW.`Status` = 'Approved'
	                        , IF(et.EmployeeShiftID IS NULL, default_min_hrswork, NEW.OfficialValidHours)
									, 0)
	,et.TotalDayPay = IF(e.EmployeeType = 'Daily'
	                     , esa.BasicPay
								, esa.Salary / (e.WorkDaysPerYear / month_count))
                     * IF(et.EmployeeShiftID IS NULL, 1
							     , IF((NEW.OfficialValidHours / default_min_hrswork) > 1, 1
								       , (NEW.OfficialValidHours / default_min_hrswork)))
	WHERE et.EmployeeID=NEW.EmployeeID
	AND et.OrganizationID=NEW.OrganizationID;

ELSEIF LOCATE('others', leav_type) > 0 THEN

	UPDATE employeetimeentry et
	INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID
	INNER JOIN (SELECT *
	            FROM dates d
					WHERE d.DateValue BETWEEN NEW.LeaveStartDate AND NEW.LeaveEndDate
					ORDER BY d.DateValue) d ON d.DateValue = et.`Date`
	LEFT JOIN employeesalary esa ON esa.RowID=et.EmployeeSalaryID
	SET et.LastUpd = CURRENT_TIMESTAMP()
	,et.LastUpdBy = NEW.LastUpdBy
	,et.OtherLeaveHours = IF(NEW.`Status` = 'Approved'
	                         , IF(et.EmployeeShiftID IS NULL, default_min_hrswork, NEW.OfficialValidHours)
									 , 0)
	,et.TotalDayPay = IF(e.EmployeeType = 'Daily'
	                     , esa.BasicPay
								, esa.Salary / (e.WorkDaysPerYear / month_count))
                     * IF(et.EmployeeShiftID IS NULL, 1
							     , IF((NEW.OfficialValidHours / default_min_hrswork) > 1, 1
								       , (NEW.OfficialValidHours / default_min_hrswork)))
	WHERE et.EmployeeID=NEW.EmployeeID
	AND et.OrganizationID=NEW.OrganizationID;

ELSEIF LOCATE('additional', leav_type) > 0 THEN

	UPDATE employeetimeentry et
	INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID
	INNER JOIN (SELECT *
	            FROM dates d
					WHERE d.DateValue BETWEEN NEW.LeaveStartDate AND NEW.LeaveEndDate
					ORDER BY d.DateValue) d ON d.DateValue = et.`Date`
	LEFT JOIN employeesalary esa ON esa.RowID=et.EmployeeSalaryID
	SET et.LastUpd = CURRENT_TIMESTAMP()
	,et.LastUpdBy = NEW.LastUpdBy
	,et.AdditionalVLHours = IF(NEW.`Status` = 'Approved'
	                           , IF(et.EmployeeShiftID IS NULL, default_min_hrswork, NEW.OfficialValidHours)
										, 0)
	,et.TotalDayPay = IF(e.EmployeeType = 'Daily'
	                     , esa.BasicPay
								, esa.Salary / (e.WorkDaysPerYear / month_count))
                     * IF(et.EmployeeShiftID IS NULL, 1
							     , IF((NEW.OfficialValidHours / default_min_hrswork) > 1, 1
								       , (NEW.OfficialValidHours / default_min_hrswork)))
	WHERE et.EmployeeID=NEW.EmployeeID
	AND et.OrganizationID=NEW.OrganizationID;

END IF;

	SELECT
	EXISTS(SELECT GENERATE_employeetimeentry(NEW.EmployeeID, NEW.OrganizationID, d.DateValue, NEW.LastUpdBy)
	       FROM dates d
			 WHERE d.DateValue BETWEEN NEW.LeaveStartDate AND NEW.LeaveEndDate
			 ORDER BY d.DateValue)
	INTO any_int;
	
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
