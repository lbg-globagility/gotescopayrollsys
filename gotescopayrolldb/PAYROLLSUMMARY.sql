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

-- Dumping structure for procedure gotescopayrolldb_server.PAYROLLSUMMARY
DROP PROCEDURE IF EXISTS `PAYROLLSUMMARY`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `PAYROLLSUMMARY`(IN `ps_OrganizationID` INT, IN `ps_PayPeriodID1` INT, IN `ps_PayPeriodID2` INT, IN `psi_undeclared` CHAR(1), IN `strSalaryDistrib` VARCHAR(50)

)
    DETERMINISTIC
BEGIN

DECLARE paypdatefrom DATE;

DECLARE paypdateto DATE;

DECLARE payfreq_rowid INT(11);

DECLARE month_count_peryear INT(11) DEFAULT 12;

SELECT PayFromDate, TotalGrossSalary FROM payperiod WHERE RowID=ps_PayPeriodID1 INTO paypdatefrom, payfreq_rowid;

SELECT PayToDate FROM payperiod WHERE RowID=IFNULL(ps_PayPeriodID2,ps_PayPeriodID1) INTO paypdateto;



SELECT

IFNULL(
(SELECT IF(e.EmployeeType='Fixed', IFNULL(es.BasicPay,0), IF(e.EmployeeType='Daily', SUM(IFNULL(i.RegularHoursAmount,0)), (IFNULL(es.BasicPay,0) - (SUM(IFNULL(i.HoursLateAmount,0)) + SUM(IFNULL(i.UndertimeHoursAmount,0)) + SUM(IFNULL(i.Absent,0)) + SUM(IFNULL(HolidayPayAmount,0)))))) FROM (SELECT RowID,OrganizationID,`Date`,EmployeeShiftID,EmployeeID,EmployeeSalaryID,EmployeeFixedSalaryFlag,RegularHoursWorked,RegularHoursAmount,TotalHoursWorked,OvertimeHoursWorked,OvertimeHoursAmount,UndertimeHours,UndertimeHoursAmount,NightDifferentialHours,NightDiffHoursAmount,NightDifferentialOTHours,NightDiffOTHoursAmount,HoursLate,HoursLateAmount,LateFlag,PayRateID,VacationLeaveHours,SickLeaveHours,MaternityLeaveHours,OtherLeaveHours,AdditionalVLHours,TotalDayPay,Absent,TaxableDailyAllowance,HolidayPayAmount,TaxableDailyBonus,NonTaxableDailyBonus
												FROM employeetimeentry
												WHERE psi_undeclared='0' AND OrganizationID=ps_OrganizationID
											UNION
												SELECT RowID,OrganizationID,`Date`,EmployeeShiftID,EmployeeID,EmployeeSalaryID,EmployeeFixedSalaryFlag,RegularHoursWorked,RegularHoursAmount,TotalHoursWorked,OvertimeHoursWorked,OvertimeHoursAmount,UndertimeHours,UndertimeHoursAmount,NightDifferentialHours,NightDiffHoursAmount,NightDifferentialOTHours,NightDiffOTHoursAmount,HoursLate,HoursLateAmount,LateFlag,PayRateID,VacationLeaveHours,SickLeaveHours,MaternityLeaveHours,OtherLeaveHours,AdditionalVLHours,TotalDayPay,Absent,TaxableDailyAllowance,HolidayPayAmount,TaxableDailyBonus,NonTaxableDailyBonus
												FROM employeetimeentryactual
												WHERE psi_undeclared='1'
												AND OrganizationID=ps_OrganizationID) i LEFT JOIN employeesalary es ON es.RowID=i.EmployeeSalaryID WHERE i.EmployeeID=ps.EmployeeID AND i.`Date` BETWEEN paypdatefrom AND paypdateto
												AND e.EmployeeType = 'Daily')
, emsal.BasicPay)
												AS BasicPay

/*,SUM(IFNULL(pst6.PayAmount,0)) 'TotalGrossSalary'
,SUM(IFNULL(pst7.PayAmount,0)) 'TotalNetSalary'*/
,ps.TotalGrossSalary
,ps.TotalNetSalary

,IF(pp.MinimumWageValue >= (SELECT IF(e.EmployeeType = 'Daily', esa.BasicPay, (esa.Salary / (e.WorkDaysPerYear / month_count_peryear)))
                            FROM employeesalary esa
									 WHERE esa.OrganizationID=ps_OrganizationID
									 AND esa.EmployeeID=ps.EmployeeID
									 AND (esa.EffectiveDateFrom >= pp.PayFromDate OR IFNULL(esa.EffectiveDateTo, pp.PayToDate) >= pp.PayFromDate)
									 AND (esa.EffectiveDateFrom <= pp.PayToDate OR IFNULL(esa.EffectiveDateTo, pp.PayToDate) <= pp.PayToDate)
									 ORDER BY esa.EffectiveDateFrom DESC LIMIT 1)
    , 0
	 , SUM(ps.TotalTaxableSalary)) `TotalTaxableSalary`

,SUM(ps.TotalEmpSSS) 'TotalEmpSSS'
,SUM(IFNULL(pst9.PayAmount,0)) 'TotalEmpWithholdingTax'
,SUM(ps.TotalEmpPhilhealth) 'TotalEmpPhilhealth'
,SUM(ps.TotalEmpHDMF) 'TotalEmpHDMF'
,SUM(ps.TotalLoans) 'TotalLoans'
,SUM(ps.TotalBonus) 'TotalBonus'
,SUM(ps.TotalAllowance) 'TotalAllowance'
,e.EmployeeID
,UCASE(e.FirstName) 'FirstName'
,INITIALS(e.MiddleName,'. ','1') 'MiddleName'
,UCASE(e.LastName) 'LastName'
,UCASE(e.Surname) 'Surname'
,UCASE(p.PositionName) 'PositionName'
,UCASE(d.Name) 'DivisionName'
,e.RowID 'EmployeeRowID'
# ,SUM(IFNULL(pst.PayAmount,0)) AS Tardiness
, SUM(IFNULL(pst.PayAmount,0)) AS Tardiness
, SUM(IFNULL(pst1.PayAmount,0)) AS Undertime
, SUM(IFNULL(pst2.PayAmount,0)) AS NightDifftl
, SUM(IFNULL(pst3.PayAmount,0)) AS HolidayPay
, SUM(IFNULL(pst4.PayAmount,0)) AS OverTime
, SUM(IFNULL(pst5.PayAmount,0)) AS NightDifftlOT
FROM (SELECT RowID,OrganizationID,PayPeriodID,EmployeeID,TimeEntryID,PayFromDate,PayToDate,TotalGrossSalary,TotalNetSalary,TotalTaxableSalary,TotalEmpSSS,TotalEmpWithholdingTax,TotalCompSSS,TotalEmpPhilhealth,TotalCompPhilhealth,TotalEmpHDMF,TotalCompHDMF,TotalVacationDaysLeft,TotalLoans,TotalBonus,TotalAllowance,TotalAdjustments,ThirteenthMonthInclusion,NondeductibleTotalLoans,'Declared' AS Result FROM paystub WHERE psi_undeclared='0' AND OrganizationID=ps_OrganizationID
UNION
SELECT RowID,OrganizationID,PayPeriodID,EmployeeID,TimeEntryID,PayFromDate,PayToDate,TotalGrossSalary,TotalNetSalary,TotalTaxableSalary,TotalEmpSSS,TotalEmpWithholdingTax,TotalCompSSS,TotalEmpPhilhealth,TotalCompPhilhealth,TotalEmpHDMF,TotalCompHDMF,TotalVacationDaysLeft,TotalLoans,TotalBonus,TotalAllowance,TotalAdjustments,ThirteenthMonthInclusion,NondeductibleTotalLoans,'Actual' AS Result FROM paystubactual WHERE psi_undeclared='1' AND OrganizationID=ps_OrganizationID) ps
LEFT JOIN employee e ON e.RowID=ps.EmployeeID
LEFT JOIN `position` p ON p.RowID=e.PositionID
LEFT JOIN division d ON d.RowID=p.DivisionId
INNER JOIN product pd ON pd.OrganizationID=ps_OrganizationID AND pd.PartNo='Tardiness'
LEFT JOIN paystubitem pst ON pst.PayStubID=ps.RowID AND pst.ProductID=pd.RowID AND pst.`Undeclared`=psi_undeclared

INNER JOIN product pd1 ON pd1.OrganizationID=ps_OrganizationID AND pd1.PartNo='Undertime'
LEFT JOIN paystubitem pst1 ON pst1.PayStubID=ps.RowID AND pst1.ProductID=pd1.RowID AND pst1.`Undeclared`=psi_undeclared

INNER JOIN product pd2 ON pd2.OrganizationID=ps_OrganizationID AND pd2.PartNo='Night differential'
LEFT JOIN paystubitem pst2 ON pst2.PayStubID=ps.RowID AND pst2.ProductID=pd2.RowID AND pst2.`Undeclared`=psi_undeclared

INNER JOIN product pd3 ON pd3.OrganizationID=ps_OrganizationID AND pd3.PartNo='Holiday pay'
LEFT JOIN paystubitem pst3 ON pst3.PayStubID=ps.RowID AND pst3.ProductID=pd3.RowID AND pst3.`Undeclared`=psi_undeclared

INNER JOIN product pd4 ON pd4.OrganizationID=ps_OrganizationID AND pd4.PartNo='Overtime'
LEFT JOIN paystubitem pst4 ON pst4.PayStubID=ps.RowID AND pst4.ProductID=pd4.RowID AND pst4.`Undeclared`=psi_undeclared

INNER JOIN product pd5 ON pd5.OrganizationID=ps_OrganizationID AND pd5.PartNo='Night differential OT'
LEFT JOIN paystubitem pst5 ON pst5.PayStubID=ps.RowID AND pst5.ProductID=pd5.RowID AND pst5.`Undeclared`=psi_undeclared

INNER JOIN product pd6 ON pd6.OrganizationID=ps_OrganizationID AND pd6.PartNo='Gross Income'
LEFT JOIN paystubitem pst6 ON pst6.PayStubID=ps.RowID AND pst6.ProductID=pd6.RowID AND pst6.`Undeclared`=psi_undeclared

INNER JOIN product pd7 ON pd7.OrganizationID=ps_OrganizationID AND pd7.PartNo='Net Income'
LEFT JOIN paystubitem pst7 ON pst7.PayStubID=ps.RowID AND pst7.ProductID=pd7.RowID AND pst7.`Undeclared`=psi_undeclared

INNER JOIN product pd8 ON pd8.OrganizationID=ps_OrganizationID AND pd8.PartNo='Taxable Income'
LEFT JOIN paystubitem pst8 ON pst8.PayStubID=ps.RowID AND pst8.ProductID=pd8.RowID AND pst8.`Undeclared`=psi_undeclared

INNER JOIN product pd9 ON pd9.OrganizationID=ps_OrganizationID AND pd9.PartNo='Withholding Tax'
LEFT JOIN paystubitem pst9 ON pst9.PayStubID=ps.RowID AND pst9.ProductID=pd9.RowID AND pst9.`Undeclared`=psi_undeclared

INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID

INNER JOIN (SELECT i.*
				FROM salary_for_paystub i
				WHERE i.OrganizationID=ps_OrganizationID
				AND i.PayPeriodID=ps_PayPeriodID1
				GROUP BY i.RowID) emsal
        ON emsal.EmployeeID=ps.EmployeeID

WHERE ps.OrganizationID=ps_OrganizationID
#AND ps.TotalNetSalary > 0
AND (ps.PayFromDate >= paypdatefrom OR ps.PayToDate >= paypdatefrom)
AND (ps.PayFromDate <= paypdateto OR ps.PayToDate <= paypdateto)
#AND LENGTH(IFNULL(e.ATMNo,''))=IF(strSalaryDistrib = 'Cash', 0, NOT 0)
GROUP BY ps.RowID # EmployeeID
ORDER BY d.Name,e.LastName;












END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
