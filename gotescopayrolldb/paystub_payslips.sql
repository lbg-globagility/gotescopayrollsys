/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `paystub_payslips`;
DELIMITER //
CREATE PROCEDURE `paystub_payslips`(
	IN `og_rowid` INT,
	IN `pp_rowid` INT,
	IN `is_actual` CHAR(1)








































)
    DETERMINISTIC
BEGIN

DECLARE paydate_from
        ,paydat_to DATE;

DECLARE logo MEDIUMBLOB DEFAULT NULL;

SET @totalDeductions = 0.0;

CALL `LoanPrediction`(og_rowid)
;

/*SELECT ImageBlob
FROM images
WHERE (RowID=1
       OR UniqueKey='Transprint Logo')
LIMIT 1
INTO logo;*/

SELECT
pp.PayFromDate
,pp.PayToDate
FROM payperiod pp
WHERE pp.RowID=pp_rowid
INTO paydate_from
     ,paydat_to;


CALL GetUnearnedAllowance(og_rowid, paydate_from, paydat_to);

CALL GetUnearnedDailyAllowance(og_rowid, paydate_from, paydat_to);

CALL GetAttendancePeriod(og_rowid, paydate_from, paydat_to, is_actual);

SELECT MAX(pp.PayToDate)
FROM payperiod pp
INNER JOIN payperiod ppd
        ON ppd.RowID=pp_rowid
		     AND ppd.OrganizationID=pp.OrganizationID
		     AND ppd.TotalGrossSalary=pp.TotalGrossSalary
		     AND ppd.`Year`=pp.`Year`
INTO @max_dateto;

SET @basic_payment = 0.00;

SET @_ordinal = 0;

SET @deduct_amt = 0;

SET @middle_name = 0;

SELECT
ps.RowID
,e.EmployeeID `Column2`
, (@middle_name := IF(LENGTH(TRIM(IFNULL(e.MiddleName, ''))) = 0, NULL, TRIM(e.MiddleName))) `CustomMiddleName`
,UCASE( CONCAT(REPLACE(CONCAT_WS(', ', e.LastName, e.FirstName, @middle_name), ',,', ','), ' ( ', e.EmployeeType, ' )') ) `Column3`
, PROPERCASE(CONCAT_WS(', ', REPLACE(e.LastName,',',''), e.FirstName)) `Column63`

,(@basic_payment := IFNULL(IF(ps.AsActual = 1, (esa.BasicPay * (esa.TrueSalary / esa.Salary)), esa.BasicPay), 0)) `TheBasicPay`
,IFNULL(IF(is_actual = '1'
           , TrueSalary
			  , esa.Salary)
        , 0) `Column11`
# ,FORMAT(@basic_payment, 2) `Column11`

,FORMAT(ps.TotalGrossSalary, 2) `Column4`
,FORMAT(ps.TotalNetSalary, 2) `Column5`
,FORMAT(ps.TotalAllowance, 2) `Column8`
,FORMAT(ps.TotalBonus, 2) `Column10`
,FORMAT(ps.TotalEmpSSS, 2) `Column12`
,FORMAT(ps.TotalEmpPhilhealth, 2) `Column13`
,FORMAT(ps.TotalEmpHDMF, 2) `Column14`
,FORMAT(ps.TotalLoans, 2) `Column9`
,FORMAT(ps.TotalTaxableSalary, 2) `Column6`
,FORMAT(ps.TotalEmpWithholdingTax, 2) `Column7`
,FORMAT(ps.TotalAdjustments, 2) `Column32`

, NEWLINECHARTRIMMER(REPLACE(REPLACE(psiallw.`Column34`, ',', '\r\n'), '|', ',')) `Column34`
, NEWLINECHARTRIMMER(REPLACE(REPLACE(psiallw.`Column37`, ',', '\r\n'), '|', ',')) `Column37`

, RidCharacater(REPLACE(REPLACE(psibon.`Column36`, ',', '\r\n'), '|', ','), '\r\n') `Column36`
, RidCharacater(REPLACE(REPLACE(psibon.`Column39`, ',', '\r\n'), '|', ','), '\r\n') `Column39`

/**/ , REPLACE(NEWLINECHARTRIMMER(REPLACE(psiloan.`Column35`, ',', '\n'))
          , '|', ',')  `Column35`
, REPLACE(NEWLINECHARTRIMMER(REPLACE(psiloan.`Column38`, ',', '\n'))
          , '|', ',') `Column38`
, REPLACE(NEWLINECHARTRIMMER(REPLACE(psiloan.`Column33`, ',', '\n'))
          , '|', ',') `Column33`
/* , CONCAT_WS('\r\n', 'TESTLOAN#1', 'TESTLOAN#2', 'TESTLOAN#3', 'TESTLOAN#4', 'TESTLOAN#5')  `Column35`
, CONCAT_WS('\r\n', '50,000.00', '50,000.00', '50,000.00', '50,000.00', '50,000.00') `Column38`
, CONCAT_WS('\r\n', '50,000.00', '50,000.00', '50,000.00', '50,000.00', '50,000.00') `Column33`*/

, IFNULL((LENGTH(psiloan.`Column33`) - LENGTH(REPLACE(psiloan.`Column33`, ',', ''))) + 1, 0) `Column10`

, FORMAT(IFNULL(et.RegularHoursWorked,0), 2) `Column17`

,IF(e.EmployeeType = 'Daily' OR (LCASE(e.EmployeeType)='monthly' AND e.StartDate BETWEEN paydate_from AND paydat_to)
    , FORMAT(IFNULL(et.RegularHoursAmount, 0), 2)
    , FORMAT(@basic_payment - (IFNULL(et.HoursLateAmount, 0) + IFNULL(et.UndertimeHoursAmount, 0) + IFNULL(et.Absent, 0) + IF(LCASE(e.EmployeeType)='monthly', IFNULL(et.DefaultHolidayPay, 0), 0) + IFNULL(et.Leavepayment, 0)), 2)
    /*, IF(e.EmployeeType = 'Monthly'
         , FORMAT(@basic_payment - IFNULL((et.UndertimeHoursAmount + et.HoursLateAmount + et.Absent + et.Leavepayment + et.HolidayPayAmount), 0), 2)
			, @basic_payment
			)*/
    ) `Column18`

,IFNULL(FORMAT(et.OvertimeHoursWorked, 2), 0) `Column19`
,IFNULL(FORMAT(et.OvertimeHoursAmount, 2), 0) `Column20`

,IFNULL(FORMAT(et.NightDifferentialHours,2), 0) `Column21`
,IFNULL(FORMAT(et.NightDiffHoursAmount,2), 0) `Column22`

,IFNULL(FORMAT(et.NightDifferentialOTHours,2), 0) `Column23`
,IFNULL(FORMAT(et.NightDiffOTHoursAmount, 2), 0) `Column24`

,FORMAT(IFNULL(et.`AbsentHours`, 0),2) `Column41`
,FORMAT(IFNULL(et.Absent, 0) + IFNULL(ua.AbsentAllowance, 0) + IFNULL(uda.AbsentAllowance, 0), 2) `Column26`

,FORMAT(IFNULL(et.HoursLate,0), 2) `Column42`
,FORMAT(IFNULL(et.HoursLateAmount, 0) + IFNULL(ua.LateAllowance, 0) + IFNULL(uda.LateAllowance, 0), 2) `Column27`

,FORMAT(IFNULL(et.UndertimeHours,0), 2) `Column43`
,FORMAT(IFNULL(et.UndertimeHoursAmount, 0) + IFNULL(ua.UndertimeAllowance, 0) + IFNULL(uda.UndertimeAllowance, 0), 2) `Column28`

,logo `Column40`

,NEWLINECHARTRIMMER(REPLACE(psilv.`Column30`, ',', '\n')) `Column30`
,NEWLINECHARTRIMMER(REPLACE(psilv.`Column31`, ',', '\n')) `Column31`

, ROUND(IFNULL(et.`RestDayHours`, 0), 2) `Column25`
, IFNULL(ROUND(et.`RestDayAmount`, 2), 0) `Column16`

, FORMAT(IFNULL(et.`AttendedHolidayHours`, 0), 2) `Column44`
#, IFNULL(FORMAT( IF(e.EmployeeType='Daily', et.`DefaultHolidayPay`, et.HolidayPayAmount), 2), 0) `Column1`
#, IFNULL(FORMAT( et.`TotalDefaultHolidayPay` + et.`AddedHolidayPayAmount`, 2), 0) `Column1`
, IF(e.EmployeeType='Daily', IF(et.`AddedHolidayPayAmount`=0, et.`TotalDefaultHolidayPay`, et.`AddedHolidayPayAmount`), IFNULL(FORMAT( et.`TotalDefaultHolidayPay` + et.`AddedHolidayPayAmount`, 2), 0)) `Column1`

, FORMAT(IFNULL(et.`LeaveHours`, 0), 2) `Column45`
, IFNULL(ROUND(et.`Leavepayment`, 2), 0) `Column15`

,NEWLINECHARTRIMMER(REPLACE(adj.`AdjustmentName`, ',', '\n')) `Column46`
,NEWLINECHARTRIMMER(REPLACE(adj.`AdjustmentAmount`, ',', '\n')) `Column47`

,NEWLINECHARTRIMMER(REPLACE(adj_positive.`AdjustmentName`, ',', '\n')) `Column50`
,NEWLINECHARTRIMMER(REPLACE(REPLACE(adj_positive.`AdjustmentAmount`, ',', '\n'), '|', ',')) `Column51`

,NEWLINECHARTRIMMER(REPLACE(adj_negative.`AdjustmentName`, ',', '\n')) `Column52`
,NEWLINECHARTRIMMER(REPLACE(REPLACE(adj_negative.`AdjustmentAmount`, ',', '\n'), '|', ',')) `Column53`

,NEWLINECHARTRIMMER(REPLACE(eapp.`AllowanceName`, ',', '\n')) `Column48`
,REPLACE(NEWLINECHARTRIMMER(REPLACE(eapp.`AmountPresentation`, ',', '\n')), '|', ',') `Column49`

/**/ , ( ps.TotalGrossSalary + IFNULL(adj_positive.`PayAmount`, 0) ) `Column60`

, @totalDeductions := 
  ( ps.TotalLoans
    + (ps.TotalEmpSSS + ps.TotalEmpPhilhealth + ps.TotalEmpHDMF)
	 + ps.TotalEmpWithholdingTax
	 + ROUND(IFNULL(et.Absent, 0) + IFNULL(et.HoursLateAmount, 0) + IFNULL(et.UndertimeHoursAmount, 0), 2)
	 + (IFNULL(ua.LateAllowance, 0) + IFNULL(uda.LateAllowance, 0))
	 + (IFNULL(ua.UndertimeAllowance, 0) + IFNULL(uda.UndertimeAllowance, 0))
	 + (IFNULL(ua.AbsentAllowance, 0) + IFNULL(uda.AbsentAllowance, 0))
	 ) `Column62`

, ROUND(( @totalDeductions
			+ IFNULL(adj_negative.`PayAmount` * -1, 0) 
			), 2) `Column61`

, IF(ps.TotalAllowance > 0
     , CONCAT_WS(' '
                 , CONCAT_WS(' &', IF(et.HolidayPayAmount>0, 'holiday', NULL)
					              , IF(et.`Leavepayment`>0, ' leave', NULL)
					              )
                 , 'included in'
                 , REPLACE(RidCharacater(psiallw.`Column34`, ','), ',', '')
	              )
	  , '') `Column64`

FROM proper_payroll ps

# INNER JOIN employee e
INNER JOIN employee_servedperiod e
        ON e.RowID=ps.EmployeeID
		     AND e.OrganizationID=ps.OrganizationID
           # AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
           AND e.ServedPeriodId = ps.PayPeriodID

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
#			  ,SUM(et.RegularHoursAmount - IF(et.RegularHoursAmount = 0 AND et.TotalDayPay > 0, 0, et.HolidayPayAmount)) `RegularHoursAmount`
#			  ,SUM(IF(et.RegularHoursAmount > 0 AND et.DailyRate = et.HolidayPayAmount, 0, IF(e.EmployeeType='Daily' AND et.IsValidForHolidayPayment, (et.RegularHoursAmount - et.AddedHolidayPayAmount), et.RegularHoursAmount))) `RegularHoursAmount`
			  , SUM(IF(et.IsValidForHolidayPayment AND et.IsDaily, IF(et.IsLegalHoliday, et.AddedHolidayPayAmount, et.RegularHoursAmount), et.RegularHoursAmount)) `RegularHoursAmount`
#			  ,SUM(et.RegularHoursAmount) `RegularHoursAmount`
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
			  ,SUM(et.TotalDayPay) `TotalDayPay`
			  ,SUM(et.Absent) `Absent`
			  # ,et.ChargeToDivisionID
			  ,SUM(et.TaxableDailyAllowance) `TaxableDailyAllowance`
			  ,SUM(et.HolidayPayAmount) `HolidayPayAmount`
			  ,SUM(et.TaxableDailyBonus) `TaxableDailyBonus`
			  ,SUM(et.NonTaxableDailyBonus) `NonTaxableDailyBonus`
			  ,SUM(et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) `LeaveHours`
			  ,SUM(et.Leavepayment) `Leavepayment`
			  , SUM(IFNULL(i.RegularHoursWorked, 0)) `RestDayHours`
/*			  , IF(is_actual = 1
			       , SUM(i.RestDayActualPay)
					 , SUM(i.RestDayAmount)) `RestDayAmount`*/
			  , SUM(et.RestDayPay) `RestDayAmount`
			  , SUM(et.`AbsentHours`) `AbsentHours`
			  , SUM(IF(et.IsValidForHolidayPayment = 1
			           # , GREATEST(et.RegularHoursWorked, et.WorkHours)
			           , et.RegularHoursWorked
						  , 0)) `HolidayHours`
			  , SUM(IFNULL(et.AddedHolidayPayAmount, 0)) `AddedHolidayPayAmount`
			  , SUM(IF(et.IsValidForHolidayPayment, IF(et.IsLegalHoliday OR (et.IsSpecialHoliday AND et.IsMonthly AND et.RegularHoursWorked = 0), et.DailyRate, 0), 0)) `DefaultHolidayPay`
			  , SUM(IF(et.IsValidForHolidayPayment,
			  				IF(et.IsLegalHoliday OR (et.IsSpecialHoliday AND et.IsMonthly AND et.RegularHoursWorked = 0),
								IF(et.IsFixed AND et.RegularHoursWorked = 0, 0, et.DailyRate),
								0),
							0)) `TotalDefaultHolidayPay`
			  , SUM(et.HolidayHours) `AttendedHolidayHours`
			  
#			  FROM proper_time_entry et
			  FROM attendanceperiod et
			  
			  LEFT JOIN restdaytimeentry i ON i.RowID = et.RowID
#			  LEFT JOIN employeesalary_withdailyrate es ON es.RowID=et.EmployeeSalaryID
			  INNER JOIN (SELECT RowID, EmployeeType FROM employee WHERE OrganizationID=og_rowid) e ON e.RowID=et.EmployeeID
			  WHERE et.OrganizationID=og_rowid
			  AND et.AsActual=is_actual
			  AND et.`Date` BETWEEN paydate_from AND paydat_to
			  GROUP BY et.EmployeeID
           ) et
       ON et.EmployeeID=ps.EmployeeID

LEFT JOIN (SELECT
           PayStubID
           ,GROUP_CONCAT(IF(psi.PayAmount = 0, '', p.PartNo)) `Column34`
           ,GROUP_CONCAT(IF(psi.PayAmount = 0, '', REPLACE(FORMAT(psi.PayAmount, 2), ',', '|'))) `Column37`
           FROM paystubitem psi
			  INNER JOIN product p ON p.RowID=psi.ProductID AND p.`Category`='Allowance Type' AND p.ActiveData=1
			  WHERE psi.OrganizationID = og_rowid
			  # AND psi.PayAmount != 0
			  GROUP BY psi.PayStubID
			  ORDER BY psi.RowID
           ) psiallw
       ON psiallw.PayStubID = ps.RowID
       
LEFT JOIN (SELECT
           PayStubID
           ,GROUP_CONCAT(IF(psi.PayAmount = 0, '', p.PartNo)) `Column36`
           ,GROUP_CONCAT(IF(psi.PayAmount = 0, '', REPLACE(FORMAT(psi.PayAmount, 2), ',', '|'))) `Column39`
           FROM paystubitem psi
			  INNER JOIN product p ON p.RowID=psi.ProductID AND p.`Category`='Bonus' AND p.ActiveData=1
			  WHERE psi.OrganizationID = og_rowid
			  # AND psi.PayAmount != 0
#			  AND psi.PayAmount > 0
			  GROUP BY psi.PayStubID
			  ORDER BY psi.RowID
           ) psibon
       ON psibon.PayStubID = ps.RowID

# #######################

 LEFT JOIN (SELECT ii.*
            ,GROUP_CONCAT(ii.LoanName order BY FIELD(ii.LoanName, 'PartNo','ABSENT','Advance Salary prev','advances','ANTIGEN TEST','ATD','ATD-SSS LOAN','Authority To Deduct','AUTHORIZATION TO DEDUCT','BIR Penalty','Calamity','Calamity Loan','car loam','Car Loan','Cash Advance','CASH ADVANCE NONDEDUCTIBLE','Cash Advance-CV 46936','cv refund boracay sept 2019','CV-46936','cv000817 4000-2500','double payment june 30','EXCESS BDO CREDIT','FOR MEDICAL','lates not yet deducted','Negative Salary-prev','NHIP ADDTL AUG & SEPT 2020','NIAGARA INV#84936','NIAGARA INV#84939','Overpaid Salary prev','Overpayment Allow','overpayment aug 7 not yet employed','Overpayment OT','OVERPAYMENT SALARY SSS PREVIOUS','OVERPAYMENT SALARY UT PREVIOUS','overpayment salary wtax previous','OVERPAYMENT WFH 20%','Overpayment-Salary','Overpayment-SIL','pag ibig cont aug 2023','pag ibig contribution july 2023','PAG-IBIG (ADDITIONAL CONTRI)','PAG-IBIG (ADDITONAL CONTRIBUTION)','PAG-IBIG CONTRI - MARCH 30, 2019','Pag-Ibig Loan','Pag-Ibig Loan - March','Pag-ibig MP2','Pag-Ibig Premium (Addl)','PAGIBIG','PF#00624','PhilHealth','PHILHEALTH PREVIOUS','Prepaid Card','Provident Fund','Provident Loan','safety jogger shoes','Salary Deduction','SHORTAGE IN LIQUIDATION','SMART BILLING EXCESS
','SSS','SSS ADDITIONAL','SSS ADDTL OCT 2020','SSS Cont Previous','SSS FEB 2023 PREM ADDTL','SSS Loan','SSS Loan - March','SSS LOAN ADDITIONAL','SSS LOAN SHORT PAYMENT','SSS LOAN UNPAID JUNE 30','SSS LOAN UNPAID MAY 31','sss prem july addtl','SSS Restructured Loan','SWAB TEST','UNDERTIME','voucher change','VOUCHER14777','W/TAX Prev','wtax feb 2023','wtax june 2022','wtax september 2020')) `Column35`
            /*,GROUP_CONCAT(ROUND(ii.DeductionAmount, 2)) `Column38`
            ,GROUP_CONCAT(ROUND(ii.BalanceOfLoan, 2)) `Column33`*/
            
            ,GROUP_CONCAT(REPLACE(FORMAT(ROUND(ii.DeductedAmount, 2), 2)
				                      , ',', '|') order BY FIELD(ii.LoanName, 'PartNo','ABSENT','Advance Salary prev','advances','ANTIGEN TEST','ATD','ATD-SSS LOAN','Authority To Deduct','AUTHORIZATION TO DEDUCT','BIR Penalty','Calamity','Calamity Loan','car loam','Car Loan','Cash Advance','CASH ADVANCE NONDEDUCTIBLE','Cash Advance-CV 46936','cv refund boracay sept 2019','CV-46936','cv000817 4000-2500','double payment june 30','EXCESS BDO CREDIT','FOR MEDICAL','lates not yet deducted','Negative Salary-prev','NHIP ADDTL AUG & SEPT 2020','NIAGARA INV#84936','NIAGARA INV#84939','Overpaid Salary prev','Overpayment Allow','overpayment aug 7 not yet employed','Overpayment OT','OVERPAYMENT SALARY SSS PREVIOUS','OVERPAYMENT SALARY UT PREVIOUS','overpayment salary wtax previous','OVERPAYMENT WFH 20%','Overpayment-Salary','Overpayment-SIL','pag ibig cont aug 2023','pag ibig contribution july 2023','PAG-IBIG (ADDITIONAL CONTRI)','PAG-IBIG (ADDITONAL CONTRIBUTION)','PAG-IBIG CONTRI - MARCH 30, 2019','Pag-Ibig Loan','Pag-Ibig Loan - March','Pag-ibig MP2','Pag-Ibig Premium (Addl)','PAGIBIG','PF#00624','PhilHealth','PHILHEALTH PREVIOUS','Prepaid Card','Provident Fund','Provident Loan','safety jogger shoes','Salary Deduction','SHORTAGE IN LIQUIDATION','SMART BILLING EXCESS
','SSS','SSS ADDITIONAL','SSS ADDTL OCT 2020','SSS Cont Previous','SSS FEB 2023 PREM ADDTL','SSS Loan','SSS Loan - March','SSS LOAN ADDITIONAL','SSS LOAN SHORT PAYMENT','SSS LOAN UNPAID JUNE 30','SSS LOAN UNPAID MAY 31','sss prem july addtl','SSS Restructured Loan','SWAB TEST','UNDERTIME','voucher change','VOUCHER14777','W/TAX Prev','wtax feb 2023','wtax june 2022','wtax september 2020')
				              ) `Column38`
            ,GROUP_CONCAT(REPLACE(FORMAT(ROUND(ii.Balance, 2), 2)
				                      , ',', '|') order BY FIELD(ii.LoanName, 'PartNo','ABSENT','Advance Salary prev','advances','ANTIGEN TEST','ATD','ATD-SSS LOAN','Authority To Deduct','AUTHORIZATION TO DEDUCT','BIR Penalty','Calamity','Calamity Loan','car loam','Car Loan','Cash Advance','CASH ADVANCE NONDEDUCTIBLE','Cash Advance-CV 46936','cv refund boracay sept 2019','CV-46936','cv000817 4000-2500','double payment june 30','EXCESS BDO CREDIT','FOR MEDICAL','lates not yet deducted','Negative Salary-prev','NHIP ADDTL AUG & SEPT 2020','NIAGARA INV#84936','NIAGARA INV#84939','Overpaid Salary prev','Overpayment Allow','overpayment aug 7 not yet employed','Overpayment OT','OVERPAYMENT SALARY SSS PREVIOUS','OVERPAYMENT SALARY UT PREVIOUS','overpayment salary wtax previous','OVERPAYMENT WFH 20%','Overpayment-Salary','Overpayment-SIL','pag ibig cont aug 2023','pag ibig contribution july 2023','PAG-IBIG (ADDITIONAL CONTRI)','PAG-IBIG (ADDITONAL CONTRIBUTION)','PAG-IBIG CONTRI - MARCH 30, 2019','Pag-Ibig Loan','Pag-Ibig Loan - March','Pag-ibig MP2','Pag-Ibig Premium (Addl)','PAGIBIG','PF#00624','PhilHealth','PHILHEALTH PREVIOUS','Prepaid Card','Provident Fund','Provident Loan','safety jogger shoes','Salary Deduction','SHORTAGE IN LIQUIDATION','SMART BILLING EXCESS
','SSS','SSS ADDITIONAL','SSS ADDTL OCT 2020','SSS Cont Previous','SSS FEB 2023 PREM ADDTL','SSS Loan','SSS Loan - March','SSS LOAN ADDITIONAL','SSS LOAN SHORT PAYMENT','SSS LOAN UNPAID JUNE 30','SSS LOAN UNPAID MAY 31','sss prem july addtl','SSS Restructured Loan','SWAB TEST','UNDERTIME','voucher change','VOUCHER14777','W/TAX Prev','wtax feb 2023','wtax june 2022','wtax september 2020')
				              ) `Column33`
 				FROM (SELECT
						i.OrganizationID
						, i.Created
						, i.CreatedBy
						, i.LastUpd
						, i.LastUpdBy
						, i.EmployeeID
						, i.PayStubID
						, i.RowID `LoanschedID`
						, i.LoanBalance `Balance`
						
						, FLOOR(((i.NoOfPayPeriod-i.OrdinalIndex)/i.NoOfPayPeriod)*i.NoOfPayPeriod) `CountPayPeriodLeft`
						
						, i.ProperDeductAmount `DeductedAmount`
						, i.`Status`
						, p.PartNo `LoanName`
						, i.PayPeriodID
						FROM (SELECT lp.*
								FROM loanpredict lp
								WHERE lp.PayperiodID=pp_rowid
								AND LCASE(lp.`Status`) IN ('in progress', 'complete')
								AND lp.DiscontinuedDate IS NULL
							UNION
								SELECT lp.*
								FROM loanpredict lp
								WHERE lp.PayperiodID=pp_rowid
								AND LCASE(lp.`Status`) = 'cancelled'
								AND lp.DiscontinuedDate IS NOT NULL
								) i
						INNER JOIN product p ON p.RowID=i.LoanTypeID
						WHERE i.PayperiodID=pp_rowid
						order BY FIELD(p.PartNo, 'PartNo','ABSENT','Advance Salary prev','advances','ANTIGEN TEST','ATD','ATD-SSS LOAN','Authority To Deduct','AUTHORIZATION TO DEDUCT','BIR Penalty','Calamity','Calamity Loan','car loam','Car Loan','Cash Advance','CASH ADVANCE NONDEDUCTIBLE','Cash Advance-CV 46936','cv refund boracay sept 2019','CV-46936','cv000817 4000-2500','double payment june 30','EXCESS BDO CREDIT','FOR MEDICAL','lates not yet deducted','Negative Salary-prev','NHIP ADDTL AUG & SEPT 2020','NIAGARA INV#84936','NIAGARA INV#84939','Overpaid Salary prev','Overpayment Allow','overpayment aug 7 not yet employed','Overpayment OT','OVERPAYMENT SALARY SSS PREVIOUS','OVERPAYMENT SALARY UT PREVIOUS','overpayment salary wtax previous','OVERPAYMENT WFH 20%','Overpayment-Salary','Overpayment-SIL','pag ibig cont aug 2023','pag ibig contribution july 2023','PAG-IBIG (ADDITIONAL CONTRI)','PAG-IBIG (ADDITONAL CONTRIBUTION)','PAG-IBIG CONTRI - MARCH 30, 2019','Pag-Ibig Loan','Pag-Ibig Loan - March','Pag-ibig MP2','Pag-Ibig Premium (Addl)','PAGIBIG','PF#00624','PhilHealth','PHILHEALTH PREVIOUS','Prepaid Card','Provident Fund','Provident Loan','safety jogger shoes','Salary Deduction','SHORTAGE IN LIQUIDATION','SMART BILLING EXCESS
','SSS','SSS ADDITIONAL','SSS ADDTL OCT 2020','SSS Cont Previous','SSS FEB 2023 PREM ADDTL','SSS Loan','SSS Loan - March','SSS LOAN ADDITIONAL','SSS LOAN SHORT PAYMENT','SSS LOAN UNPAID JUNE 30','SSS LOAN UNPAID MAY 31','sss prem july addtl','SSS Restructured Loan','SWAB TEST','UNDERTIME','voucher change','VOUCHER14777','W/TAX Prev','wtax feb 2023','wtax june 2022','wtax september 2020')
						) ii
 				GROUP BY ii.EmployeeID
				) psiloan ON psiloan.EmployeeID = ps.EmployeeID

# #######################

/*LEFT JOIN (SELECT
           p.RowID
           ,ls.PaystubRowID
           ,GROUP_CONCAT(IF(ls.LoanTypeID = 0, '', p.PartNo)) `Column35`
           ,GROUP_CONCAT(IF(ls.LoanTypeID = 0, '', ls.DeductionAmount)) `Column38`
           ,(@sum_deduct_amt := SUM(lsc.DeductionAmount)) `Result`
           ,GROUP_CONCAT(IF(ls.LoanTypeID = 0, '', (ls.TotalLoanAmount - @sum_deduct_amt))) `Column33`
			  FROM product p
			  LEFT JOIN (SELECT ls.RowID
			             ,ls.PaystubRowID
			             ,ls.LoanRowID
			             ,ls.PayPeriodID
			             ,ls.DeductionAmount
			             ,ls.OrdinalValue
			             ,els.LoanTypeID
			             ,els.TotalLoanAmount
							 FROM employeeloanschedpercutoff ls
							 INNER JOIN employeeloanschedule els
							         ON els.RowID=ls.LoanRowID
							 WHERE ls.PayPeriodID=pp_rowid
							 AND ls.OrganizationID=og_rowid
		                ) ls
						ON ls.PayPeriodID = pp_rowid
			  LEFT JOIN employeeloanschedpercutoff lsc
			         ON lsc.LoanRowID=ls.LoanRowID
						   AND lsc.LoanRowID=ls.LoanRowID
							AND lsc.PaystubRowID IS NOT NULL
							AND lsc.OrdinalValue <= ls.OrdinalValue
			  WHERE p.RowID=ls.LoanTypeID
			  AND p.`Category`='Loan Type'
			  AND p.OrganizationID=og_rowid
			  AND p.ActiveData=1
			  # GROUP BY p.RowID
			  ORDER BY p.PartNo
			  ) psiloan
		  ON psiloan.PaystubRowID = ps.RowID*/

/*LEFT JOIN (SELECT i.PaystubRowID
           ,GROUP_CONCAT(i.PartNo) `Column35`
			  ,GROUP_CONCAT(i.DeductionAmount) `Column38`
			  # ,(@sum_deduct_amt := SUM(lsc.DeductionAmount)) `Result`
			  ,GROUP_CONCAT(i.`Result`) `Column33`
           FROM (SELECT
			        ls.RowID
					  ,ls.PaystubRowID
					  ,p.PartNo
					  ,ROUND(ls.DeductionAmount, 2) `DeductionAmount`
		           ,ROUND((els.TotalLoanAmount - SUM(lsc.DeductionAmount)), 2) `Result`
					  FROM employeeloanschedpercutoff ls
					  INNER JOIN employeeloanschedule els
			                ON els.RowID=ls.LoanRowID
					  INNER JOIN product p
				             ON p.RowID=els.LoanTypeID AND p.`Category`='Loan Type' AND p.OrganizationID=ls.OrganizationID AND p.ActiveData=1
					  INNER JOIN employeeloanschedpercutoff lsc
				             ON lsc.LoanRowID=ls.LoanRowID AND lsc.PaystubRowID IS NOT NULL AND lsc.OrdinalValue <= ls.OrdinalValue
					  WHERE ls.OrganizationID=og_rowid
					        AND ls.PayPeriodID=pp_rowid
					  GROUP BY lsc.LoanRowID
                 ) i
           GROUP BY i.PaystubRowID
           ) psiloan
       ON psiloan.PaystubRowID = ps.RowID*/

/*
SELECT p.PartNo `Allowance name`
	,FORMAT(psi.PayAmount ,2) `Amount`
	FROM paystubitem psi
	INNER JOIN product p ON p.RowID=psi.ProductID AND p.`Category`='Allowance Type'
	WHERE psi.OrganizationID = og_rowid
	AND psi.PayStubID = ps_rowid
	AND psi.PayAmount != 0;
	
	SELECT p.PartNo `Bonus name`
	,FORMAT(psi.PayAmount, 2) `Amount`
	FROM paystubitem psi
	INNER JOIN product p ON p.RowID=psi.ProductID AND p.`Category`='Bonus'
	WHERE psi.OrganizationID = og_rowid
	AND psi.PayStubID = ps_rowid
	AND psi.PayAmount != 0;
	
	SELECT
		p.PartNo `Loan type`
		,FORMAT(ls.DeductionAmount, 2) `Amount deducted`
		,FORMAT((els.TotalLoanAmount - SUM(lsc.DeductionAmount)), 2) `Balance as of`
		,FORMAT(els.TotalLoanAmount, 2) `Total loan amount`
	FROM employeeloanschedpercutoff ls
	INNER JOIN employeeloanschedule els
	        ON els.RowID=ls.LoanRowID
	INNER JOIN product p
	        ON p.RowID=els.LoanTypeID AND p.`Category`='Loan Type' AND p.OrganizationID=ls.OrganizationID
	INNER JOIN employeeloanschedpercutoff lsc
	        ON lsc.LoanRowID=ls.LoanRowID AND lsc.PaystubRowID IS NOT NULL AND lsc.OrdinalValue <= ls.OrdinalValue
	WHERE ls.PaystubRowID=ps_rowid
	AND ls.OrganizationID=og_rowid
	GROUP BY ls.RowID;
*/

 LEFT JOIN product p
        ON p.OrganizationID=ps.OrganizationID AND p.PartNo='Regular amount worked' AND p.ActiveData=1
 LEFT JOIN paystubitem psi
        ON psi.PayStubID=ps.RowID AND psi.ProductID=p.RowID AND psi.Undeclared=ps.AsActual
       
# INNER JOIN (SELECT
LEFT JOIN (SELECT
           PayStubID
           ,GROUP_CONCAT(IF(psi.PayAmount = 0, '', UCASE(p.PartNo)) order BY p.PartNo) `Column30`
           ,GROUP_CONCAT(IF(psi.PayAmount = 0, '', ROUND(psi.PayAmount, 2)) order BY p.PartNo) `Column31`
           FROM paystubitem psi
			  INNER JOIN product p ON p.RowID=psi.ProductID
			  INNER JOIN category c ON c.RowID=p.CategoryID AND c.CategoryName='Leave Type'
			  WHERE psi.OrganizationID = og_rowid
			  AND psi.Undeclared = FALSE
			  AND psi.PayAmount != 0
			  GROUP BY psi.PayStubID
			  ORDER BY psi.RowID
           ) psilv
       ON psilv.PayStubID = ps.RowID

/*LEFT JOIN (SELECT
           i.EmployeeID
			  , IF(is_actual = 1
			       , SUM(i.RestDayActualPay)
					 , SUM(i.RestDayAmount)) `RestDayAmount`
			  FROM restdaytimeentry i
			  WHERE i.OrganizationID = og_rowid
			  AND i.`Date` BETWEEN paydate_from AND paydat_to
			  GROUP BY i.EmployeeID
           ) rd ON rd.EmployeeID = ps.EmployeeID*/

LEFT JOIN (SELECT d.*
			  FROM paystubadjustment_itemized d
			  WHERE d.OrganizationID=og_rowid
			  AND d.IsActual=is_actual
			UNION
           SELECT a.*
			  FROM paystubadjustmentactual_itemized a
			  WHERE a.OrganizationID=og_rowid
			  AND a.IsActual=is_actual) adj ON adj.PayStubID=ps.RowID

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

LEFT JOIN (SELECT d.PayStubID
           , d.AdjustmentName
           , d.AdjustmentAmount
           , d.PayAmount
			  FROM paystubadjustment_peritemnega d
			  WHERE d.OrganizationID=og_rowid
			  AND d.IsActual=is_actual
			UNION
           SELECT a.PayStubID
           , a.AdjustmentName
           , a.AdjustmentAmount
           , a.PayAmount
			  FROM paystubadjustmentactual_peritemnega a
			  WHERE a.OrganizationID=og_rowid
			  AND a.IsActual=is_actual) adj_negative ON adj_negative.PayStubID=ps.RowID

LEFT JOIN (SELECT GROUP_CONCAT(eapp.AllowanceAmount) `AllowanceAmount`
           , GROUP_CONCAT(eapp.AllowanceName) `AllowanceName`
           , GROUP_CONCAT(REPLACE(FORMAT(eapp.AmountPresentation, 2), ',', '|')) `AmountPresentation`
			  , eapp.EmployeeID
			  FROM employeeallowance_perperiod eapp
			  WHERE eapp.OrganizationID=og_rowid
			  AND eapp.PayPeriodId=pp_rowid
			  GROUP BY eapp.EmployeeID) eapp ON eapp.EmployeeID=ps.EmployeeID

LEFT JOIN unearnedallowance ua ON ua.EmployeeID=ps.EmployeeID

LEFT JOIN unearneddailyallowance uda ON uda.EmployeeID=ps.EmployeeID

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
