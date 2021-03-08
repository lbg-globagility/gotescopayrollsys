/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `PAYROLLSUMMARY3`;
DELIMITER //
CREATE PROCEDURE `PAYROLLSUMMARY3`(
	IN `og_rowid` INT,
	IN `pp_rowid` INT,
	IN `is_actual` CHAR(1),
	IN `strSalaryDistrib` VARCHAR(50)
)
    DETERMINISTIC
BEGIN

DECLARE paydate_from
        ,paydat_to DATE;
        
DECLARE monthCount INT DEFAULT 12;

SELECT
pp.PayFromDate
,pp.PayToDate
FROM payperiod pp
WHERE pp.RowID=pp_rowid
INTO paydate_from
     ,paydat_to;


CALL GetUnearnedAllowance(og_rowid, paydate_from, paydat_to);

CALL GetAttendancePeriod(og_rowid, paydate_from, paydat_to, is_actual);

DROP TEMPORARY TABLE IF EXISTS allowancepaystubitem;
DROP TABLE IF EXISTS allowancepaystubitem;
CREATE TEMPORARY TABLE allowancepaystubitem
SELECT
psi.*
FROM paystubitem psi
INNER JOIN product p ON p.RowID=psi.ProductID
INNER JOIN category c ON c.RowID=p.CategoryID AND c.CategoryName='Allowance Type'
INNER JOIN paystub ps ON ps.RowID=psi.PayStubID
INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID AND pp.RowID=pp_rowid
WHERE psi.OrganizationID=og_rowid
AND psi.Undeclared=is_actual
AND psi.PayAmount != 0
;

SELECT MAX(pp.PayToDate)
FROM payperiod pp
INNER JOIN payperiod ppd
        ON ppd.RowID=pp_rowid
		     AND ppd.OrganizationID=pp.OrganizationID
		     AND ppd.TotalGrossSalary=pp.TotalGrossSalary
		     AND ppd.`Year`=pp.`Year`
INTO @max_dateto;
        
SET @monthCount=12;
SET @defaultWorkHours=8;
SET @basic_payment = 0.00;

SELECT
ps.RowID
, ps.RowID `PaystubId`
, e.RowID `EmployeeRowID`
, e.EmployeeID `EmployeeNumber`
, e.LastName
, e.FirstName
, e.EmployeeType
, e.WorkDaysPerYear

, (@basic_payment := IFNULL(IF(ps.AsActual = 1, (esa.BasicPay * (esa.TrueSalary / esa.Salary)), esa.BasicPay), 0)) `TheBasicPay`

, esa.BasicPay `DeclaredSalary`
, esa.UndeclaredSalary
, (IF(is_actual, esa.TrueSalary, esa.Salary) * IF(e.EmployeeType = 'Daily', (e.WorkDaysPerYear / monthCount), 1)) `MonthlySalary`

, et.HoursLate `LateHours`
, IFNULL(et.HoursLateAmount, 0) `LateAmount`
, IFNULL(et.HoursLateAmount, 0) + IFNULL(ua.LateAllowance, 0) `LateAmountWithAllowance`

, et.UndertimeHours `UndertimeHours`
, IFNULL(et.UndertimeHoursAmount, 0) `UndertimeAmount`
, IFNULL(et.UndertimeHoursAmount, 0) + IFNULL(ua.UndertimeAllowance, 0) `UndertimeAmountWithAllowance`

, et.`AbsentHours` `AbsentHours`
, IFNULL(et.Absent, 0) `AbsentAmount`
, IFNULL(et.Absent, 0) + IFNULL(ua.AbsentAllowance, 0) `AbsentAmountWithAllowance`

, CONCAT_WS(' ', DATE_FORMAT(paydate_from, '%M'), DAY(paydate_from), '-', CONCAT(DAY(paydat_to), ','), YEAR(paydate_from) ) `PayperiodDescription`

, FORMAT(IFNULL(et.RegularHoursWorked,0), 2) `RegularHours`
,IF(e.EmployeeType = 'Daily' OR (LCASE(e.EmployeeType)='monthly' AND e.StartDate BETWEEN paydate_from AND paydat_to)
	 , FORMAT(IFNULL(et.RegularHoursAmount, 0), 2)
	 , FORMAT(@basic_payment - (IFNULL(et.HoursLateAmount, 0) + IFNULL(et.UndertimeHoursAmount, 0) + IFNULL(et.Absent, 0) + IF(LCASE(e.EmployeeType)='monthly', IFNULL(et.DefaultHolidayPay, 0), 0) + IFNULL(et.Leavepayment, 0)), 2)
 
 ) `RegularAmount`

, et.OvertimeHoursWorked `OvertimeHours`
, et.OvertimeHoursAmount `OvertimeAmount`
 
, et.NightDifferentialOTHours `NightDifferentialOTHours`
, et.NightDiffOTHoursAmount `NightDifferentialOTAmount`
 
, et.`RestDayHours` `RestDayHours`
, et.`RestDayAmount` `RestDayAmount`

, et.`AttendedHolidayHours` `HolidayHours`
, IFNULL(FORMAT( IF(e.EmployeeType='Daily', et.`HolidayPayAmount` + et.`AddedHolidayPayAmount`, et.`DefaultHolidayPay` + et.`AddedHolidayPayAmount`), 2), 0) `HolidayAmount`

, et.`LeaveHours` `LeaveHours`
, et.VacationLeaveHours * if(`e`.`EmployeeType` = 'Daily', (IF(ps.AsActual = 1, esa.TrueSalary, esa.Salary) / @defaultWorkHours), ((IF(ps.AsActual = 1, esa.TrueSalary, esa.Salary) / (`e`.`WorkDaysPerYear` / @monthCount)) / @defaultWorkHours)) `VacationLeaveAmount`
, et.SickLeaveHours * if(`e`.`EmployeeType` = 'Daily', (IF(ps.AsActual = 1, esa.TrueSalary, esa.Salary) / @defaultWorkHours), ((IF(ps.AsActual = 1, esa.TrueSalary, esa.Salary) / (`e`.`WorkDaysPerYear` / @monthCount)) / @defaultWorkHours)) `SickLeaveAmount`
, et.MaternityLeaveHours * if(`e`.`EmployeeType` = 'Daily', (IF(ps.AsActual = 1, esa.TrueSalary, esa.Salary) / @defaultWorkHours), ((IF(ps.AsActual = 1, esa.TrueSalary, esa.Salary) / (`e`.`WorkDaysPerYear` / @monthCount)) / @defaultWorkHours)) `MaternityLeaveAmount`
, et.OtherLeaveHours * if(`e`.`EmployeeType` = 'Daily', (IF(ps.AsActual = 1, esa.TrueSalary, esa.Salary) / @defaultWorkHours), ((IF(ps.AsActual = 1, esa.TrueSalary, esa.Salary) / (`e`.`WorkDaysPerYear` / @monthCount)) / @defaultWorkHours)) `OtherLeaveAmount`
, et.AdditionalVLHours * if(`e`.`EmployeeType` = 'Daily', (IF(ps.AsActual = 1, esa.TrueSalary, esa.Salary) / @defaultWorkHours), ((IF(ps.AsActual = 1, esa.TrueSalary, esa.Salary) / (`e`.`WorkDaysPerYear` / @monthCount)) / @defaultWorkHours)) `AdditionalVLAmount`
, et.`Leavepayment` `LeaveAmount`

, ps.TotalGrossSalary + IFNULL(adj_positive.`PayAmount`, 0) `TotalEarnings`
, ps.TotalEmpSSS `SSS` 
, ps.TotalEmpPhilhealth `PhilHealth` 
, ps.TotalEmpHDMF `HDMF` 
, ps.TotalEmpWithholdingTax `WithholdingTax` 
, ps.TotalNetSalary `Net`
, ps.TotalNetSalary - IFNULL(psi.`TotalAllowance`, 0) `CustomNet`

FROM proper_payroll ps


INNER JOIN employee_servedperiod e
        ON e.RowID=ps.EmployeeID
		     AND e.OrganizationID=ps.OrganizationID
           
           AND e.ServedPeriodId = ps.PayPeriodID
           
           AND IFNULL(TRIM(e.ATMNo), '') = IF(strSalaryDistrib = 'Cash', '', e.ATMNo)

INNER JOIN employeesalary esa
        ON esa.EmployeeID=ps.EmployeeID
		     AND esa.OrganizationID=ps.OrganizationID
		     AND (esa.EffectiveDateFrom >= ps.PayFromDate OR IFNULL(esa.EffectiveDateTo, @max_dateto) >= ps.PayFromDate)
		     AND (esa.EffectiveDateFrom <= ps.PayToDate OR IFNULL(esa.EffectiveDateTo, @max_dateto) <= ps.PayToDate)

LEFT JOIN (SELECT
			  et.RowID
			  ,et.OrganizationID
			  ,et.`Date`
			  ,et.EmployeeShiftID
			  ,et.EmployeeID
			  ,et.EmployeeSalaryID
			  ,SUM(et.RegularHoursWorked) `RegularHoursWorked`

			  ,SUM(IF(et.RegularHoursAmount > 0 AND et.DailyRate = et.HolidayPayAmount, 0, IF(e.EmployeeType='Daily' AND et.IsValidForHolidayPayment, (et.RegularHoursAmount - et.AddedHolidayPayAmount), et.RegularHoursAmount))) `RegularHoursAmount`

			  ,SUM(et.TotalHoursWorked) `TotalHoursWorked`
			  ,SUM(et.OvertimeHoursWorked) `OvertimeHoursWorked`
			  ,SUM(et.OvertimeHoursAmount) `OvertimeHoursAmount`
			  ,SUM(et.UndertimeHours) `UndertimeHours`
			  ,SUM(et.UndertimeHoursAmount) `UndertimeHoursAmount`
			  ,SUM(et.NightDifferentialHours) `NightDifferentialHours`
			  ,SUM(et.NightDiffHoursAmount) `NightDiffHoursAmount`
			  ,SUM(et.NightDifferentialOTHours) `NightDifferentialOTHours`
			  ,SUM(et.NightDiffOTHoursAmount) `NightDiffOTHoursAmount`
			  ,SUM(et.HoursLate) `HoursLate`
			  ,SUM(et.HoursLateAmount) `HoursLateAmount`
			  ,et.LateFlag
			  ,et.PayRateID
			  ,SUM(et.VacationLeaveHours) `VacationLeaveHours`
			  ,SUM(et.SickLeaveHours) `SickLeaveHours`
			  ,SUM(et.MaternityLeaveHours) `MaternityLeaveHours`
			  ,SUM(et.OtherLeaveHours) `OtherLeaveHours`
			  ,SUM(et.AdditionalVLHours) `AdditionalVLHours`
			  ,SUM(et.TotalDayPay) `TotalDayPay`
			  ,SUM(et.Absent) `Absent`
			  
			  ,SUM(et.TaxableDailyAllowance) `TaxableDailyAllowance`
			  ,SUM(et.HolidayPayAmount) `HolidayPayAmount`
			  ,SUM(et.TaxableDailyBonus) `TaxableDailyBonus`
			  ,SUM(et.NonTaxableDailyBonus) `NonTaxableDailyBonus`
			  ,SUM(et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) `LeaveHours`
			  ,SUM(et.Leavepayment) `Leavepayment`
			  , SUM(IFNULL(i.RegularHoursWorked, 0)) `RestDayHours`

			  , SUM(et.RestDayPay) `RestDayAmount`
			  , SUM(et.`AbsentHours`) `AbsentHours`
			  , SUM(IF(et.IsValidForHolidayPayment = 1
			           
			           , et.RegularHoursWorked
						  , 0)) `HolidayHours`
			  , SUM(IFNULL(et.AddedHolidayPayAmount, 0)) `AddedHolidayPayAmount`
			  , SUM(IF(et.IsValidForHolidayPayment, et.DailyRate, 0)) `DefaultHolidayPay`
			  , SUM(et.HolidayHours) `AttendedHolidayHours`
			  

			  FROM attendanceperiod et
			  
			  LEFT JOIN restdaytimeentry i ON i.RowID = et.RowID
			  
			  INNER JOIN (SELECT RowID, EmployeeType FROM employee WHERE OrganizationID=og_rowid) e ON e.RowID=et.EmployeeID
			  WHERE et.OrganizationID=og_rowid
			  AND et.AsActual=is_actual
			  AND et.`Date` BETWEEN paydate_from AND paydat_to
			  GROUP BY et.EmployeeID
           ) et
       ON et.EmployeeID=ps.EmployeeID

LEFT JOIN (SELECT d.PayStubID
           , d.AdjustmentName
           , d.AdjustmentAmount
           , d.PayAmount
			  FROM paystubadjustment_peritem d
			  WHERE d.OrganizationID=og_rowid
			  AND d.IsActual=is_actual
			UNION
           SELECT a.PayStubID
           , a.AdjustmentName
           , a.AdjustmentAmount
           , a.PayAmount
			  FROM paystubadjustmentactual_peritem a
			  WHERE a.OrganizationID=og_rowid
			  AND a.IsActual=is_actual) adj_positive ON adj_positive.PayStubID=ps.RowID

LEFT JOIN unearnedallowance ua
	ON ua.EmployeeID=ps.EmployeeID

LEFT JOIN (SELECT *,
				SUM(PayAmount) `TotalAllowance`
				FROM allowancepaystubitem
				GROUP BY PaystubID
				) psi ON psi.PaystubID = ps.RowID

WHERE ps.OrganizationID=og_rowid
AND ps.PayPeriodID=pp_rowid
AND ps.AsActual=is_actual
GROUP BY ps.RowID
ORDER BY CONCAT(e.LastName, e.FirstName)
;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
