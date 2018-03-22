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

-- Dumping structure for procedure gotescopayrolldb_server.PAYROLL_GENERATE_employeesalary
DROP PROCEDURE IF EXISTS `PAYROLL_GENERATE_employeesalary`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `PAYROLL_GENERATE_employeesalary`(IN `OrganizID` INT, IN `PayFreqRowID` INT, IN `FromDateValue` DATE, IN `ToDateValue` DATE)
    DETERMINISTIC
BEGIN

DECLARE date_start DATE;

DECLARE date_end DATE;


DECLARE date1_start DATE;

DECLARE date1_end DATE;


DECLARE date2_start DATE;

DECLARE date2_end DATE;


DECLARE date3_start DATE;

DECLARE date3_end DATE;


DECLARE payperd_month INT(10);

DECLARE payperd_year INT(10);


DECLARE phh_sched CHAR(1);

DECLARE sss_sched CHAR(1);

DECLARE hdmf_sched CHAR(1);

DECLARE wtax_sched CHAR(1);



SELECT pp.`Month`
,pp.`Year`
,IF(og.PhilhealthDeductionSchedule = 'First half', '1'
	,IF(og.PhilhealthDeductionSchedule = 'Per pay period', '2'
		,IF(og.PhilhealthDeductionSchedule = 'End of the month', '0', '3'))) AS PhilhealthDeductionSchedule
,IF(og.SSSDeductionSchedule = 'First half', '1'
	,IF(og.SSSDeductionSchedule = 'Per pay period', '2'
		,IF(og.SSSDeductionSchedule = 'End of the month', '0', '3'))) AS SSSDeductionSchedule
,IF(og.PagIbigDeductionSchedule = 'First half', '1'
	,IF(og.PagIbigDeductionSchedule = 'Per pay period', '2'
		,IF(og.PagIbigDeductionSchedule = 'End of the month', '0', '3'))) AS PagIbigDeductionSchedule
,IF(og.WithholdingDeductionSchedule = 'First half', '1'
	,IF(og.WithholdingDeductionSchedule = 'Per pay period', '2'
		,IF(og.WithholdingDeductionSchedule = 'End of the month', '0', '3'))) AS WithholdingDeductionSchedule
FROM payperiod pp
INNER JOIN organization og ON og.RowID=pp.OrganizationID
WHERE pp.OrganizationID=OrganizID
AND pp.TotalGrossSalary=PayFreqRowID
AND pp.PayFromDate=FromDateValue
AND pp.PayToDate=ToDateValue
INTO payperd_month
		,payperd_year
		,phh_sched
		,sss_sched
		,hdmf_sched
		,wtax_sched;

SELECT IF(phh_sched = '3', SUBDATE(pp.PayFromDate, INTERVAL 1 MONTH)
			,IF(phh_sched = '0', pp.PayFromDate, FromDateValue))
,IF(phh_sched = '3', SUBDATE(pp.PayToDate, INTERVAL 1 MONTH)
	,IF(phh_sched = '0', pyp.PayToDate, ToDateValue))
	
,IF(sss_sched = '3', SUBDATE(pp.PayFromDate, INTERVAL 1 MONTH)
	,IF(sss_sched = '0', pp.PayFromDate, FromDateValue))
,IF(sss_sched = '3', SUBDATE(pp.PayToDate, INTERVAL 1 MONTH)
	,IF(sss_sched = '0', pyp.PayToDate, ToDateValue))
	
,IF(hdmf_sched = '3', SUBDATE(pp.PayFromDate, INTERVAL 1 MONTH)
	,IF(hdmf_sched = '0', pp.PayFromDate, FromDateValue))
,IF(hdmf_sched = '3', SUBDATE(pp.PayToDate, INTERVAL 1 MONTH)
	,IF(hdmf_sched = '0', pyp.PayToDate, ToDateValue))
	
,IF(wtax_sched = '3', SUBDATE(pp.PayFromDate, INTERVAL 1 MONTH)
	,IF(wtax_sched = '0', pp.PayFromDate, FromDateValue))
,IF(wtax_sched = '3', SUBDATE(pp.PayToDate, INTERVAL 1 MONTH)
	,IF(wtax_sched = '0', pyp.PayToDate, ToDateValue))
	
FROM payperiod pp
INNER JOIN (SELECT pp.*
				FROM payperiod pp
				WHERE pp.OrganizationiD=OrganizID
				AND pp.TotalGrossSalary=PayFreqRowID
				AND pp.`Month`=payperd_month
				AND pp.`Year`=payperd_year
				ORDER BY pp.PayFromDate DESC,pp.PayToDate DESC
				LIMIT 1) pyp ON pyp.RowID > 0
WHERE pp.OrganizationiD=OrganizID
AND pp.TotalGrossSalary=PayFreqRowID
AND pp.`Month`=payperd_month
AND pp.`Year`=payperd_year
ORDER BY pp.PayFromDate,pp.PayToDate
LIMIT 1
INTO date_start
		,date_end
		,date1_start
		,date1_end
		,date2_start
		,date2_end
		,date3_start
		,date3_end;

SELECT employeesalary.*
	,IFNULL(phh.EmployeeShare,0) AS EmployeeShare
	,IFNULL(phh.EmployerShare,0) AS EmployerShare
	,IFNULL(pss.EmployeeContributionAmount,0) AS EmployeeContributionAmount
	,IFNULL(pss.EmployerContributionAmount,0) AS EmployerContributionAmount
	
FROM employeesalary

INNER JOIN (SELECT *
				FROM employee
				WHERE OrganizationID=OrganizID
				AND EmployeeType='Daily') e ON e.RowID=employeesalary.EmployeeID
				
LEFT JOIN (SELECT RowID AS eteRowID
				,EmployeeID
				,SUM(RegularHoursWorked) AS RegularHoursWorked
				,SUM(RegularHoursAmount) AS RegularHoursAmount
				,SUM(TotalHoursWorked) AS TotalHoursWorked
				,SUM(OvertimeHoursWorked) AS OvertimeHoursWorked
				,SUM(OvertimeHoursAmount) AS OvertimeHoursAmount
				,SUM(UndertimeHours) AS UndertimeHours
				,SUM(UndertimeHoursAmount) AS UndertimeHoursAmount
				,SUM(NightDifferentialHours) AS NightDifferentialHours
				,SUM(NightDiffHoursAmount) AS NightDiffHoursAmount
				,SUM(NightDifferentialOTHours) AS NightDifferentialOTHours
				,SUM(NightDiffOTHoursAmount) AS NightDiffOTHoursAmount
				,SUM(HoursLate) AS HoursLate
				,SUM(HoursLateAmount) AS HoursLateAmount
				,SUM(VacationLeaveHours) AS VacationLeaveHours
				,SUM(SickLeaveHours) AS SickLeaveHours
				,SUM(MaternityLeaveHours) AS MaternityLeaveHours
				,SUM(OtherLeaveHours) AS OtherLeaveHours
				,SUM(TotalDayPay) AS TotalDayPay
				,SUM(Absent) AS Absent
				 FROM employeetimeentry
				 WHERE OrganizationID=OrganizID
				 AND `Date` BETWEEN date_start AND date_end
				 GROUP BY EmployeeID) et ON et.EmployeeID = employeesalary.EmployeeID
				 
LEFT JOIN (SELECT RowID AS eteRowID
				,EmployeeID
				,SUM(RegularHoursWorked) AS RegularHoursWorked
				,SUM(RegularHoursAmount) AS RegularHoursAmount
				,SUM(TotalHoursWorked) AS TotalHoursWorked
				,SUM(OvertimeHoursWorked) AS OvertimeHoursWorked
				,SUM(OvertimeHoursAmount) AS OvertimeHoursAmount
				,SUM(UndertimeHours) AS UndertimeHours
				,SUM(UndertimeHoursAmount) AS UndertimeHoursAmount
				,SUM(NightDifferentialHours) AS NightDifferentialHours
				,SUM(NightDiffHoursAmount) AS NightDiffHoursAmount
				,SUM(NightDifferentialOTHours) AS NightDifferentialOTHours
				,SUM(NightDiffOTHoursAmount) AS NightDiffOTHoursAmount
				,SUM(HoursLate) AS HoursLate
				,SUM(HoursLateAmount) AS HoursLateAmount
				,SUM(VacationLeaveHours) AS VacationLeaveHours
				,SUM(SickLeaveHours) AS SickLeaveHours
				,SUM(MaternityLeaveHours) AS MaternityLeaveHours
				,SUM(OtherLeaveHours) AS OtherLeaveHours
				,SUM(TotalDayPay) AS TotalDayPay
				,SUM(Absent) AS Absent
				 FROM employeetimeentry
				 WHERE OrganizationID=OrganizID
				 AND `Date` BETWEEN date_start AND date_end
				 GROUP BY EmployeeID) ete ON ete.EmployeeID = employeesalary.EmployeeID
				 
LEFT JOIN (SELECT RowID AS eteRowID
				,EmployeeID
				,SUM(RegularHoursWorked) AS RegularHoursWorked
				,SUM(RegularHoursAmount) AS RegularHoursAmount
				,SUM(TotalHoursWorked) AS TotalHoursWorked
				,SUM(OvertimeHoursWorked) AS OvertimeHoursWorked
				,SUM(OvertimeHoursAmount) AS OvertimeHoursAmount
				,SUM(UndertimeHours) AS UndertimeHours
				,SUM(UndertimeHoursAmount) AS UndertimeHoursAmount
				,SUM(NightDifferentialHours) AS NightDifferentialHours
				,SUM(NightDiffHoursAmount) AS NightDiffHoursAmount
				,SUM(NightDifferentialOTHours) AS NightDifferentialOTHours
				,SUM(NightDiffOTHoursAmount) AS NightDiffOTHoursAmount
				,SUM(HoursLate) AS HoursLate
				,SUM(HoursLateAmount) AS HoursLateAmount
				,SUM(VacationLeaveHours) AS VacationLeaveHours
				,SUM(SickLeaveHours) AS SickLeaveHours
				,SUM(MaternityLeaveHours) AS MaternityLeaveHours
				,SUM(OtherLeaveHours) AS OtherLeaveHours
				,SUM(TotalDayPay) AS TotalDayPay
				,SUM(Absent) AS Absent
				 FROM employeetimeentry
				 WHERE OrganizationID=OrganizID
				 AND `Date` BETWEEN date_start AND date_end
				 GROUP BY EmployeeID) ett ON ett.EmployeeID = employeesalary.EmployeeID

LEFT JOIN payphilhealth phh ON et.TotalDayPay BETWEEN phh.SalaryRangeFrom AND phh.SalaryRangeTo

LEFT JOIN paysocialsecurity pss ON ete.TotalDayPay BETWEEN pss.RangeFromAmount AND pss.RangeToAmount

WHERE employeesalary.OrganizationID=OrganizID
AND (employeesalary.EffectiveDateFrom >= FromDateValue OR IFNULL(employeesalary.EffectiveDateTo,CURDATE()) >= FromDateValue)
AND (employeesalary.EffectiveDateFrom <= ToDateValue OR IFNULL(employeesalary.EffectiveDateTo,CURDATE()) <= ToDateValue)
GROUP BY employeesalary.EmployeeID;


END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
