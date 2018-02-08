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

-- Dumping structure for procedure gotescopayrolldb_latest.VIEW_paystubitem_declared
DROP PROCEDURE IF EXISTS `VIEW_paystubitem_declared`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `VIEW_paystubitem_declared`(IN `OrganizID` INT, IN `EmpRowID` INT, IN `pay_date_from` DATE, IN `pay_date_to` DATE)
    DETERMINISTIC
BEGIN

DECLARE themonth INT(11);

DECLARE theyear INT(11);

DECLARE startdate_ofpreviousmonth DATE;

DECLARE enddate_ofpreviousmonth DATE;

SELECT pp.`Month`,pp.`Year`
FROM payperiod pp
INNER JOIN employee e ON e.RowID=EmpRowID AND e.OrganizationID=OrganizID
WHERE pp.OrganizationID=OrganizID
AND pp.TotalGrossSalary=e.PayFrequencyID
AND pp.PayFromDate=pay_date_from
AND pp.PayToDate=pay_date_to
INTO themonth
		,theyear;

SELECT pp.PayFromDate
,pp.PayToDate
FROM payperiod pp
INNER JOIN employee e ON e.RowID=EmpRowID AND e.OrganizationID=OrganizID
WHERE pp.OrganizationID=OrganizID
AND pp.TotalGrossSalary=e.PayFrequencyID
AND pp.`Month`=MONTH(SUBDATE(DATE(CONCAT(theyear,'-',themonth,'-01')), INTERVAL 1 DAY))
AND pp.`Year`=theyear
ORDER BY pp.PayFromDate DESC,pp.PayToDate DESC
LIMIT 1
INTO startdate_ofpreviousmonth
		,enddate_ofpreviousmonth;

SELECT psa.RowID
,psa.OrganizationID
,psa.Created
,psa.CreatedBy
,psa.LastUpd
,psa.LastUpdBy
,psa.PayPeriodID
,psa.EmployeeID
,psa.TimeEntryID
,psa.PayFromDate
,psa.PayToDate
,psa.TotalGrossSalary
,psa.TotalNetSalary

,psa.TotalEmpSSS
# ,IF(og.WithholdingDeductionSchedule = 'First half of next month', IFNULL(ps2.TotalEmpWithholdingTax,0), psa.TotalEmpWithholdingTax) AS TotalEmpWithholdingTax
,psa.TotalEmpWithholdingTax
,psa.TotalCompSSS
,psa.TotalEmpPhilhealth
,psa.TotalCompPhilhealth
,psa.TotalEmpHDMF
,psa.TotalCompHDMF
,psa.TotalVacationDaysLeft
,psa.TotalUndeclaredSalary
,(psa.TotalLoans + psa.NondeductibleTotalLoans) AS TotalLoans
,psa.TotalBonus
,psa.TotalAllowance
,psa.TotalAdjustments
,psa.ThirteenthMonthInclusion
,es.BasicPay,es.RowID
,es.Salary AS TrueSalary
, IF(e.EmployeeType='Daily',PAYFREQUENCY_DIVISOR(e.EmployeeType),PAYFREQUENCY_DIVISOR(pf.PayFrequencyType)) AS PAYFREQUENCYDIVISOR
,ete.*
,e.EmployeeType
,(e.StartDate BETWEEN pay_date_from AND pay_date_to) AS FirstTimeSalary
,IFNULL(paidleave.PaidLeaveAmount,0) AS PaidLeaveAmount
,IFNULL(paidleave.PaidLeaveHours,0) AS PaidLeaveHours

,(@is_mwe := ROUND(IF(e.EmployeeType = 'Daily', es.BasicPay, (es.Salary / (e.WorkDaysPerYear / 12))), 2)
             <= IFNULL(pp.MinimumWageValue, GET_MinimumWageRate())
  ) `IsMWE`

# ,IF(GET_emprateperday_with_taxableallowance(EmpRowID, OrganizID, pay_date_from) <= pp.MinimumWageValue, 0, psa.TotalTaxableSalary) `TotalTaxableSalary`

# ,IF(@is_mwe = TRUE, 0, psa.TotalTaxableSalary) `TotalTaxableSalary`
,psa.TotalTaxableSalary

,IFNULL(psi_rest.PayAmount, 0) `RestDayPayment`

FROM paystub psa
# LEFT JOIN paystub ps2 ON ps2.EmployeeID=EmpRowID AND ps2.OrganizationID=OrganizID AND ps2.PayFromDate=startdate_ofpreviousmonth AND ps2.PayToDate=enddate_ofpreviousmonth
INNER JOIN employee e ON e.RowID=psa.EmployeeID AND e.OrganizationID=psa.OrganizationID
LEFT JOIN `position` p ON p.RowID=e.PositionID
LEFT JOIN division d ON d.RowID=p.DivisionId
INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID

INNER JOIN employeesalary es ON es.EmployeeID=psa.EmployeeID AND es.OrganizationID=psa.OrganizationID
AND (es.EffectiveDateFrom >= psa.PayFromDate OR IFNULL(es.EffectiveDateTo, ADDDATE(es.EffectiveDateFrom, INTERVAL 99 YEAR)) >= psa.PayFromDate)
AND (es.EffectiveDateFrom <= psa.PayToDate OR IFNULL(es.EffectiveDateTo, ADDDATE(es.EffectiveDateFrom, INTERVAL 99 YEAR)) <= psa.PayToDate)



INNER JOIN payperiod pp ON pp.RowID=psa.PayPeriodID

INNER JOIN (SELECT etea.RowID AS eteRowID
				, SUM(etea.RegularHoursWorked) AS RegularHoursWorked
				
				, SUM(etea.RegularHoursAmount - IF(etea.RegularHoursAmount = 0 AND etea.TotalDayPay > 0, 0, etea.HolidayPayAmount)) AS RegularHoursAmount
				, SUM(etea.TotalHoursWorked) AS TotalHoursWorked
				, SUM(etea.OvertimeHoursWorked) AS OvertimeHoursWorked
				, SUM(etea.OvertimeHoursAmount) AS OvertimeHoursAmount
				, SUM(etea.UndertimeHours) AS UndertimeHours
				, SUM(etea.UndertimeHoursAmount) AS UndertimeHoursAmount
				, SUM(etea.NightDifferentialHours) AS NightDifferentialHours
				, SUM(etea.NightDiffHoursAmount) AS NightDiffHoursAmount
				, SUM(etea.NightDifferentialOTHours) AS NightDifferentialOTHours
				, SUM(etea.NightDiffOTHoursAmount) AS NightDiffOTHoursAmount
				, SUM(etea.HoursLate) AS HoursLate
				, SUM(etea.HoursLateAmount) AS HoursLateAmount
				, SUM(etea.VacationLeaveHours) AS VacationLeaveHours
				, SUM(etea.SickLeaveHours) AS SickLeaveHours
				, SUM(etea.MaternityLeaveHours) AS MaternityLeaveHours
				, SUM(etea.OtherLeaveHours) AS OtherLeaveHours
				, SUM(etea.AdditionalVLHours) AS AdditionalVLHours
				, SUM(etea.TotalDayPay) AS TotalDayPay
				, SUM(etea.Absent) AS Absent, SUM(etea.HolidayPayAmount) AS HolidayPayAmount
				FROM employeetimeentry etea
				INNER JOIN payrate pr ON pr.RowID=etea.PayRateID
				WHERE etea.EmployeeID=EmpRowID
				AND etea.OrganizationID=OrganizID
				AND etea.`Date` BETWEEN pay_date_from AND pay_date_to) ete ON ete.eteRowID > 0
				
INNER JOIN organization og ON og.RowID=psa.OrganizationID

LEFT JOIN (SELECT RowID,SUM(TotalDayPay - (RegularHoursAmount + OvertimeHoursAmount + HolidayPayAmount)) AS PaidLeaveAmount,SUM((VacationLeaveHours + SickLeaveHours + MaternityLeaveHours + OtherLeaveHours + AdditionalVLHours)) AS PaidLeaveHours FROM employeetimeentry WHERE (VacationLeaveHours + SickLeaveHours + MaternityLeaveHours + OtherLeaveHours + AdditionalVLHours) > 0 AND EmployeeID=EmpRowID AND OrganizationID=OrganizID AND `Date` BETWEEN pay_date_from AND pay_date_to) paidleave ON paidleave.RowID IS NOT NULL

INNER JOIN product p_rest ON p_rest.OrganizationID=psa.OrganizationID AND p_rest.PartNo='Restday pay'
LEFT JOIN paystubitem psi_rest ON psi_rest.ProductID=p_rest.RowID AND psi_rest.PayStubID=psa.RowID AND psi_rest.Undeclared=FALSE

WHERE psa.EmployeeID=EmpRowID
AND psa.OrganizationID=OrganizID
AND psa.PayFromDate=pay_date_from AND psa.PayToDate=pay_date_to
ORDER BY es.EffectiveDateFrom DESC
LIMIT 1;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
