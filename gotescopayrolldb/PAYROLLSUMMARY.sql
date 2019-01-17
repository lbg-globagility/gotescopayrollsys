/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

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
/*


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

# ,SUM(IFNULL(pst6.PayAmount,0)) 'TotalGrossSalary'
# ,SUM(IFNULL(pst7.PayAmount,0)) 'TotalNetSalary'
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
ORDER BY d.Name,e.LastName;*/








IF psi_undeclared = 0 THEN
	
SELECT ii.* FROM (
	
	SELECT i.*
	FROM (
			SELECT
			# BasicPay	TotalGrossSalary	TotalNetSalary	TotalTaxableSalary	TotalEmpSSS	TotalEmpWithholdingTax	TotalEmpPhilhealth	TotalEmpHDMF	TotalLoans	TotalBonus	TotalAllowance	EmployeeID	FirstName	MiddleName	LastName	Surname	PositionName	DivisionName	EmployeeRowID	Tardiness	Undertime	NightDifftl	HolidayPay	OverTime	NightDifftlOT
			ps.RowID
			, e.EmployeeID `Code` # `DatCol2`
			, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `Full Name` # `DatCol3`
			# , IFNULL(esa.BasicPay, 0) `DatCol21` # `BasicPay`
			# , SUM(etp.BasicDayPay) `BasicPay`
			, SUM(et.RegularHoursAmount) `Basic rate` # `DatCol21` # `BasicPay`
			, SUM(et.OvertimeHoursAmount) `OT` # `DatCol37` # `OverTime`
			# , IFNULL(pst3.PayAmount, 0) `DatCol36` # `HolidayPay`
			, ROUND(SUM(et.HolidayPayAmount), 2) `Holiday` # `DatCol36` # `HolidayPay`
			, SUM(et.NightDiffHoursAmount) `N.Diff` # `DatCol35` # `NightDifftl`
			# , IFNULL(psrd.PayAmount, 0) `DatCol39` # Restday pay
			, IFNULL(rd.`SumRestDay`, 0) `Restday` # `DatCol39` # Restday pay
			, IFNULL(elv.`SumLeavePay`, 0) `Leave` # `LeavePayment`
			, SUM(et.HoursLateAmount) `Tardiness` # `DatCol33` # `Tardiness`
			, SUM(et.UndertimeHoursAmount) `Undertime` # `DatCol34` # `Undertime`
			, ROUND(SUM(et.Absent), 2) `Absent` # `DatCol32` # Absent
			, ps.TotalBonus `Bonus` # `DatCol30`
			, ps.TotalAllowance `Allowance` # `DatCol31`
			, ps.TotalGrossSalary `Gross` # `DatCol22`
			, ps.TotalEmpSSS `SSS` # `DatCol25`
			, ps.TotalEmpPhilhealth `Ph.Health` # `DatCol27`
			, ps.TotalEmpHDMF `HDMF` # `DatCol28`
			, ps.TotalTaxableSalary `Taxable` # `DatCol24`
			, ps.TotalEmpWithholdingTax `W.Tax` # `DatCol26`
			, ps.TotalLoans `Loan` # `DatCol29`
			, ps.TotalAdjustments `Adj.`
			, ps.TotalNetSalary `Net` # `DatCol23`
			
			# , IF(pos.RowID IS NULL, '', pos.PositionName) `PositionName` # `DatCol4`
			, IF(dv.RowID IS NULL, '', dv.Name) `DivisionName` # `DatCol1` # `DivisionName`
			# , CONCAT_WS(' to ', DATE_FORMAT(ps.PayFromDate, '%c/%e/%Y'), DATE_FORMAT(ps.PayToDate, '%c/%e/%Y')) `Cutoff` # `DatCol20`
			
			/*, e.EmployeeID
			, e.FirstName
			, e.MiddleName
			, e.LastName
			, e.Surname
			, e.RowID `EmployeeRowID`
			, SUM(et.NightDiffHoursAmount) `DatCol35` # `NightDifftl`
			, SUM(et.NightDiffOTHoursAmount) `DatCol38` # `NightDifftlOT`*/
			
			FROM paystub ps
			
			LEFT JOIN product pd3 ON pd3.OrganizationID=ps.OrganizationID AND pd3.PartNo='Holiday pay'
			LEFT JOIN paystubitem pst3 ON pst3.PayStubID=ps.RowID AND pst3.ProductID=pd3.RowID AND pst3.OrganizationID=ps.OrganizationID AND pst3.`Undeclared`=psi_undeclared
			
			LEFT JOIN product prd ON prd.OrganizationID=ps.OrganizationID AND prd.PartNo='Restday pay'
			LEFT JOIN paystubitem psrd ON psrd.PayStubID=ps.RowID AND psrd.ProductID=pd3.RowID AND psrd.OrganizationID=ps.OrganizationID AND psrd.`Undeclared`=psi_undeclared
			
			INNER JOIN employee e
			        ON e.RowID=ps.EmployeeID
					     AND e.EmployeeType = 'Daily'
						  AND IFNULL(TRIM(e.ATMNo), '') = IF(strSalaryDistrib = 'Cash', '', e.ATMNo)
			INNER JOIN employeetimeentry et ON et.EmployeeID = e.RowID AND et.OrganizationID = ps.OrganizationID AND et.`Date` BETWEEN ps.PayFromDate AND ps.PayToDate
			
			LEFT JOIN (SELECT rd.*
			           , SUM(RestDayAmount) `SumRestDay`
			           FROM restdaytimeentry rd
						  WHERE rd.OrganizationID=ps_OrganizationID
						  AND rd.`Date` BETWEEN paypdatefrom AND paypdateto
						  GROUP BY rd.EmployeeID
			           ) rd
			       ON rd.EmployeeID = e.RowID
			
			LEFT JOIN (SELECT l.*
			           , SUM(l.LeavePayment) `SumLeavePay`
			           FROM leavetimeentry l
						  WHERE l.OrganizationID=ps_OrganizationID
						  AND l.`Date` BETWEEN paypdatefrom AND paypdateto
						  GROUP BY l.EmployeeID
			           ) elv
			       ON elv.EmployeeID = e.RowID
			
			# INNER JOIN employeetimeentryproper etp ON et.EmployeeID = e.RowID AND etp.OrganizationID = ps.OrganizationID AND etp.`Date` BETWEEN ps.PayFromDate AND ps.PayToDate
			
			LEFT JOIN employeesalary esa ON esa.RowID=et.EmployeeSalaryID
			LEFT JOIN `position` pos ON pos.RowID=e.PositionID
			LEFT JOIN division dv ON dv.RowID=pos.DivisionId
			WHERE ps.PayPeriodID = ps_PayPeriodID1
			AND ps.OrganizationID = ps_OrganizationID
			GROUP BY ps.EmployeeID
			ORDER BY CONCAT(e.LastName, e.FirstName)
	) i
	
UNION
	SELECT i.*
	FROM (
			SELECT
			ps.RowID
			, e.EmployeeID `Code` # `DatCol2`
			, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `Full Name` # `DatCol3`
			, IFNULL(esa.BasicPay, 0) `Basic rate` # `DatCol21` # `BasicPay`
			, SUM(et.OvertimeHoursAmount) `OT` # `DatCol37` # `OverTime`
			# , IFNULL(pst3.PayAmount, 0) `DatCol36` # `HolidayPay`
			# , ROUND(SUM(et.HolidayPayAmount), 2) `Holiday` # `DatCol36` # `HolidayPay`
			, ROUND(SUM(IF(IFNULL(ROUND(et.TotalDayPay,2), 0) = IFNULL(ROUND(et.HolidayPayAmount,2), 0)
			               , 0, et.HolidayPayAmount)
			            )
			        , 2) `Holiday` # `DatCol36` # `HolidayPay`
			        
			, SUM(et.NightDiffHoursAmount) `N.Diff` # `DatCol35` # `NightDifftl`
			# , IFNULL(psrd.PayAmount, 0) `DatCol39` # Restday pay
			, IFNULL(rd.`SumRestDay`, 0) `Restday` # `DatCol39` # Restday pay
			, IFNULL(elv.`SumLeavePay`, 0) `Leave` # `LeavePayment`
			, SUM(et.HoursLateAmount) `Tardiness` # `DatCol33` # `Tardiness`
			, SUM(et.UndertimeHoursAmount) `Undertime` # `DatCol34` # `Undertime`
			, ROUND(SUM(et.Absent), 2) `Absent` # `DatCol32` # Absent
			, ps.TotalBonus `Bonus` # `DatCol30`
			, ps.TotalAllowance `Allowance` # `DatCol31`
			, ps.TotalGrossSalary `Gross` # `DatCol22`
			, ps.TotalEmpSSS `SSS` # `DatCol25`
			, ps.TotalEmpPhilhealth `Ph.Health` # `DatCol27`
			, ps.TotalEmpHDMF `HDMF` # `DatCol28`
			, ps.TotalTaxableSalary `Taxable` # `DatCol24`
			, ps.TotalEmpWithholdingTax `W.Tax` # `DatCol26`
			, ps.TotalLoans `Loan` # `DatCol29`
			, ps.TotalAdjustments `Adj.`
			, ps.TotalNetSalary `Net` # `DatCol23`
			
			# , IF(pos.RowID IS NULL, '', pos.PositionName) `PositionName` # `DatCol4`
			, IF(dv.RowID IS NULL, '', dv.Name) `DivisionName` # `DatCol1` # `DivisionName`
			# , CONCAT_WS(' to ', DATE_FORMAT(ps.PayFromDate, '%c/%e/%Y'), DATE_FORMAT(ps.PayToDate, '%c/%e/%Y')) `Cutoff` # `DatCol20`
			
			/*, e.EmployeeID
			, e.FirstName
			, e.MiddleName
			, e.LastName
			, e.Surname
			, e.RowID `EmployeeRowID`
			, SUM(et.NightDiffHoursAmount) `DatCol35` # `NightDifftl`
			, SUM(et.NightDiffOTHoursAmount) `DatCol38` # `NightDifftlOT`*/
			
			FROM paystub ps
			
			LEFT JOIN product pd3 ON pd3.OrganizationID=ps.OrganizationID AND pd3.PartNo='Holiday pay'
			LEFT JOIN paystubitem pst3 ON pst3.PayStubID=ps.RowID AND pst3.ProductID=pd3.RowID AND pst3.OrganizationID=ps.OrganizationID AND pst3.`Undeclared`=psi_undeclared
			
			LEFT JOIN product prd ON prd.OrganizationID=ps.OrganizationID AND prd.PartNo='Restday pay'
			LEFT JOIN paystubitem psrd ON psrd.PayStubID=ps.RowID AND psrd.ProductID=pd3.RowID AND psrd.OrganizationID=ps.OrganizationID AND psrd.`Undeclared`=psi_undeclared
			
			INNER JOIN employee e ON e.RowID=ps.EmployeeID AND e.EmployeeType IN ('Fixed', 'Monthly')
						  AND IFNULL(TRIM(e.ATMNo), '') = IF(strSalaryDistrib = 'Cash', '', e.ATMNo)
			INNER JOIN employeetimeentry et ON et.EmployeeID = e.RowID AND et.OrganizationID = ps.OrganizationID AND et.`Date` BETWEEN ps.PayFromDate AND ps.PayToDate
			
			LEFT JOIN (SELECT rd.*
			           , SUM(RestDayAmount) `SumRestDay`
			           FROM restdaytimeentry rd
						  WHERE rd.OrganizationID=ps_OrganizationID
						  AND rd.`Date` BETWEEN paypdatefrom AND paypdateto
						  GROUP BY rd.EmployeeID
			           ) rd
			       ON rd.EmployeeID = e.RowID
			
			LEFT JOIN (SELECT l.*
			           , SUM(ROUND(l.LeavePayment, 2)) `SumLeavePay`
			           FROM leavetimeentry l
						  WHERE l.OrganizationID=ps_OrganizationID
						  AND l.`Date` BETWEEN paypdatefrom AND paypdateto
						  GROUP BY l.EmployeeID
			           ) elv
			       ON elv.EmployeeID = e.RowID
			
			LEFT JOIN employeesalary esa ON esa.RowID=et.EmployeeSalaryID
			LEFT JOIN `position` pos ON pos.RowID=e.PositionID
			LEFT JOIN division dv ON dv.RowID=pos.DivisionId
			WHERE ps.PayPeriodID = ps_PayPeriodID1
			AND ps.OrganizationID = ps_OrganizationID
			GROUP BY ps.EmployeeID
			ORDER BY CONCAT(e.LastName, e.FirstName)
	) i
) ii
ORDER BY ii.`Full Name`
	;
	
ELSE
	
SELECT ii.* FROM (	
	
	SELECT i.*
	FROM (
			SELECT
			ps.RowID
			, e.EmployeeID `Code` # `DatCol2`
			, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `Full Name` # `DatCol3`
			# , IFNULL(esa.BasicPay, 0) `DatCol21` # `BasicPay`
			# , SUM(etp.BasicDayPay) `BasicPay`
			, SUM(et.RegularHoursAmount) `Basic rate` # `DatCol21` # `BasicPay`
			, SUM(et.OvertimeHoursAmount) `OT` # `DatCol37` # `OverTime`
			# , IFNULL(pst3.PayAmount, 0) `DatCol36` # `HolidayPay`
			, ROUND(SUM(et.HolidayPayAmount), 2) `Holiday` # `DatCol36` # `HolidayPay`
			, SUM(et.NightDiffHoursAmount) `N.Diff` # `DatCol35` # `NightDifftl`
			# , IFNULL(psrd.PayAmount, 0) `DatCol39` # Restday pay
			, IFNULL(rd.`SumRestDay`, 0) `Restday` # `DatCol39` # Restday pay
			, IFNULL(elv.`SumLeavePay`, 0) `Leave` # `LeavePayment`
			, SUM(et.HoursLateAmount) `Tardiness` # `DatCol33` # `Tardiness`
			, SUM(et.UndertimeHoursAmount) `Undertime` # `DatCol34` # `Undertime`
			, ROUND(SUM(et.Absent), 2) `Absent` # `DatCol32` # Absent
			, ps.TotalBonus `Bonus` # `DatCol30`
			, ps.TotalAllowance `Allowance` # `DatCol31`
			, ps.TotalGrossSalary `Gross` # `DatCol22`
			, ps.TotalEmpSSS `SSS` # `DatCol25`
			, ps.TotalEmpPhilhealth `Ph.Health` # `DatCol27`
			, ps.TotalEmpHDMF `HDMF` # `DatCol28`
			, ps.TotalTaxableSalary `Taxable` # `DatCol24`
			, ps.TotalEmpWithholdingTax `W.Tax` # `DatCol26`
			, ps.TotalLoans `Loan` # `DatCol29`
			, ps.TotalAdjustments `Adj.`
			, ps.TotalNetSalary `Net` # `DatCol23`
			
			# , IF(pos.RowID IS NULL, '', pos.PositionName) `PositionName` # `DatCol4`
			, IF(dv.RowID IS NULL, '', dv.Name) `DivisionName` # `DatCol1` # `DivisionName`
			# , CONCAT_WS(' to ', DATE_FORMAT(ps.PayFromDate, '%c/%e/%Y'), DATE_FORMAT(ps.PayToDate, '%c/%e/%Y')) `Cutoff` # `DatCol20`
			
			/*, e.EmployeeID
			, e.FirstName
			, e.MiddleName
			, e.LastName
			, e.Surname
			, e.RowID `EmployeeRowID`
			, SUM(et.NightDiffHoursAmount) `DatCol35` # `NightDifftl`
			, SUM(et.NightDiffOTHoursAmount) `DatCol38` # `NightDifftlOT`*/
			
			FROM paystubactual ps
			
			LEFT JOIN product pd3 ON pd3.OrganizationID=ps.OrganizationID AND pd3.PartNo='Holiday pay'
			LEFT JOIN paystubitem pst3 ON pst3.PayStubID=ps.RowID AND pst3.ProductID=pd3.RowID AND pst3.OrganizationID=ps.OrganizationID AND pst3.`Undeclared`=psi_undeclared
			
			LEFT JOIN product prd ON prd.OrganizationID=ps.OrganizationID AND prd.PartNo='Restday pay'
			LEFT JOIN paystubitem psrd ON psrd.PayStubID=ps.RowID AND psrd.ProductID=pd3.RowID AND psrd.OrganizationID=ps.OrganizationID AND psrd.`Undeclared`=psi_undeclared
			
			INNER JOIN employee e ON e.RowID=ps.EmployeeID AND e.EmployeeType = 'Daily'
						  AND IFNULL(TRIM(e.ATMNo), '') = IF(strSalaryDistrib = 'Cash', '', e.ATMNo)
			INNER JOIN employeetimeentryactual et ON et.EmployeeID = e.RowID AND et.OrganizationID = ps.OrganizationID AND et.`Date` BETWEEN ps.PayFromDate AND ps.PayToDate
			
			LEFT JOIN (SELECT rd.*
			           , SUM(RestDayAmount) `SumRestDay`
			           FROM restdaytimeentry rd
						  WHERE rd.OrganizationID=ps_OrganizationID
						  AND rd.`Date` BETWEEN paypdatefrom AND paypdateto
						  GROUP BY rd.EmployeeID
			           ) rd
			       ON rd.EmployeeID = e.RowID
			
			LEFT JOIN (SELECT l.*
			           , SUM(l.LeavePayment) `SumLeavePay`
			           FROM leavetimeentry l
						  WHERE l.OrganizationID=ps_OrganizationID
						  AND l.`Date` BETWEEN paypdatefrom AND paypdateto
						  GROUP BY l.EmployeeID
			           ) elv
			       ON elv.EmployeeID = e.RowID
			
			# INNER JOIN employeetimeentryactualproper etp ON et.EmployeeID = e.RowID AND etp.OrganizationID = ps.OrganizationID AND etp.`Date` BETWEEN ps.PayFromDate AND ps.PayToDate
			
			LEFT JOIN employeesalary esa ON esa.RowID=et.EmployeeSalaryID
			LEFT JOIN `position` pos ON pos.RowID=e.PositionID
			LEFT JOIN division dv ON dv.RowID=pos.DivisionId
			WHERE ps.PayPeriodID = ps_PayPeriodID1
			AND ps.OrganizationID = ps_OrganizationID
			GROUP BY ps.EmployeeID
			ORDER BY CONCAT(e.LastName, e.FirstName)
	) i
	
UNION
	SELECT i.*
	FROM (
			SELECT
			ps.RowID
			, e.EmployeeID `Code` # `DatCol2`
			, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `Full Name` # `DatCol3`
			# , IFNULL(esa.BasicPay, 0) `DatCol21` # `BasicPay`
			# , SUM(etp.BasicDayPay) `BasicPay`
			, ROUND(IFNULL(esa.BasicPay * IFNULL(esad.Percentage, 1), 0), 2) `Basic rate` # `DatCol21` # `BasicPay`
			, SUM(et.OvertimeHoursAmount) `OT` # `DatCol37` # `OverTime`
			# , IFNULL(pst3.PayAmount, 0) `DatCol36` # `HolidayPay`
			# , ROUND(SUM(et.HolidayPayAmount), 2) `Holiday` # `DatCol36` # `HolidayPay`
			, ROUND(SUM(IF(IFNULL(ROUND(et.TotalDayPay,2), 0) = IFNULL(ROUND(et.HolidayPayAmount,2), 0)
			               , 0, et.HolidayPayAmount)
			            )
			        , 2) `Holiday` # `DatCol36` # `HolidayPay`
			
			, SUM(et.NightDiffHoursAmount) `N.Diff` # `DatCol35` # `NightDifftl`
			# , IFNULL(psrd.PayAmount, 0) `DatCol39` # Restday pay
			, IFNULL(rd.`SumRestDay`, 0) `Restday` # `DatCol39` # Restday pay
			, IFNULL(elv.`SumLeavePay`, 0) `Leave` # `LeavePayment`
			, SUM(et.HoursLateAmount) `Tardiness` # `DatCol33` # `Tardiness`
			, SUM(et.UndertimeHoursAmount) `Undertime` # `DatCol34` # `Undertime`
			, ROUND(SUM(et.Absent), 2) `Absent` # `DatCol32` # Absent
			, ps.TotalBonus `Bonus` # `DatCol30`
			, ps.TotalAllowance `Allowance` # `DatCol31`
			, ps.TotalGrossSalary `Gross` # `DatCol22`
			, ps.TotalEmpSSS `SSS` # `DatCol25`
			, ps.TotalEmpPhilhealth `Ph.Health` # `DatCol27`
			, ps.TotalEmpHDMF `HDMF` # `DatCol28`
			, ps.TotalTaxableSalary `Taxable` # `DatCol24`
			, ps.TotalEmpWithholdingTax `W.Tax` # `DatCol26`
			, ps.TotalLoans `Loan` # `DatCol29`
			, ps.TotalAdjustments `Adj.`
			, ps.TotalNetSalary `Net` # `DatCol23`
			
			# , IF(pos.RowID IS NULL, '', pos.PositionName) `PositionName` # `DatCol4`
			, IF(dv.RowID IS NULL, '', dv.Name) `DivisionName` # `DatCol1` # `DivisionName`
			# , CONCAT_WS(' to ', DATE_FORMAT(ps.PayFromDate, '%c/%e/%Y'), DATE_FORMAT(ps.PayToDate, '%c/%e/%Y')) `Cutoff` # `DatCol20`
			
			/*, e.EmployeeID
			, e.FirstName
			, e.MiddleName
			, e.LastName
			, e.Surname
			, e.RowID `EmployeeRowID`
			, SUM(et.NightDiffHoursAmount) `DatCol35` # `NightDifftl`
			, SUM(et.NightDiffOTHoursAmount) `DatCol38` # `NightDifftlOT`*/
			
			FROM paystubactual ps
			
			LEFT JOIN product pd3 ON pd3.OrganizationID=ps.OrganizationID AND pd3.PartNo='Holiday pay'
			LEFT JOIN paystubitem pst3 ON pst3.PayStubID=ps.RowID AND pst3.ProductID=pd3.RowID AND pst3.OrganizationID=ps.OrganizationID AND pst3.`Undeclared`=psi_undeclared
			
			LEFT JOIN product prd ON prd.OrganizationID=ps.OrganizationID AND prd.PartNo='Restday pay'
			LEFT JOIN paystubitem psrd ON psrd.PayStubID=ps.RowID AND psrd.ProductID=pd3.RowID AND psrd.OrganizationID=ps.OrganizationID AND psrd.`Undeclared`=psi_undeclared
			
			INNER JOIN employee e ON e.RowID=ps.EmployeeID AND e.EmployeeType IN ('Fixed', 'Monthly')
						  AND IFNULL(TRIM(e.ATMNo), '') = IF(strSalaryDistrib = 'Cash', '', e.ATMNo)
			INNER JOIN employeetimeentryactual et ON et.EmployeeID = e.RowID AND et.OrganizationID = ps.OrganizationID AND et.`Date` BETWEEN ps.PayFromDate AND ps.PayToDate
			
			LEFT JOIN (SELECT rd.*
			           , SUM(RestDayAmount) `SumRestDay`
			           FROM restdaytimeentry rd
						  WHERE rd.OrganizationID=ps_OrganizationID
						  AND rd.`Date` BETWEEN paypdatefrom AND paypdateto
						  GROUP BY rd.EmployeeID
			           ) rd
			       ON rd.EmployeeID = e.RowID
			
			LEFT JOIN (SELECT l.*
			           , SUM(ROUND(l.LeavePayment, 2)) `SumLeavePay`
			           FROM leavetimeentry l
						  WHERE l.OrganizationID=ps_OrganizationID
						  AND l.`Date` BETWEEN paypdatefrom AND paypdateto
						  GROUP BY l.EmployeeID
			           ) elv
			       ON elv.EmployeeID = e.RowID
			
			LEFT JOIN employeesalary esa ON esa.RowID=et.EmployeeSalaryID
			LEFT JOIN employeesalary_withdailyrate esad ON esad.RowID=esa.RowID
			LEFT JOIN `position` pos ON pos.RowID=e.PositionID
			LEFT JOIN division dv ON dv.RowID=pos.DivisionId
			WHERE ps.PayPeriodID = ps_PayPeriodID1
			AND ps.OrganizationID = ps_OrganizationID
			GROUP BY ps.EmployeeID
			ORDER BY CONCAT(e.LastName, e.FirstName)
	) i
) ii
ORDER BY ii.`Full Name`
	;
	
END IF;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
