/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `paystub_payslips`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `paystub_payslips`(
	IN `og_rowid` INT,
	IN `pp_rowid` INT,
	IN `is_actual` CHAR(1)















)
    DETERMINISTIC
BEGIN

DECLARE paydate_from
        ,paydat_to DATE;

DECLARE logo MEDIUMBLOB DEFAULT NULL;

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

, NEWLINECHARTRIMMER(REPLACE(psiallw.`Column34`, ',', '\r\n')) `Column34`
, NEWLINECHARTRIMMER(REPLACE(psiallw.`Column37`, ',', '\r\n')) `Column37`

, NEWLINECHARTRIMMER(REPLACE(psibon.`Column36`, ',', '\n')) `Column36`
, NEWLINECHARTRIMMER(REPLACE(psibon.`Column39`, ',', '\n')) `Column39`

/**/, REPLACE(NEWLINECHARTRIMMER(REPLACE(psiloan.`Column35`, ',', '\n'))
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
    
,IF(e.EmployeeType = 'Daily'
    , FORMAT(IFNULL(et.RegularHoursAmount, 0), 2)
    , FORMAT(@basic_payment - (IFNULL(et.UndertimeHoursAmount, 0) + IFNULL(et.HoursLateAmount, 0) + IFNULL(et.Absent, 0) + IFNULL(et.Leavepayment, 0) + IFNULL(et.HolidayPayAmount, 0)), 2)
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
,FORMAT(IFNULL(et.Absent, 0),2) `Column26`

,FORMAT(IFNULL(et.HoursLate,0), 2) `Column42`
,FORMAT(IFNULL(et.HoursLateAmount, 0), 2) `Column27`

,FORMAT(IFNULL(et.UndertimeHours,0), 2) `Column43`
,FORMAT(IFNULL(et.UndertimeHoursAmount, 0), 2) `Column28`

,logo `Column40`

,NEWLINECHARTRIMMER(REPLACE(psilv.`Column30`, ',', '\n')) `Column30`
,NEWLINECHARTRIMMER(REPLACE(psilv.`Column31`, ',', '\n')) `Column31`

# , IFNULL(rd.`RestDayAmount`, 0) `Column16`
, IFNULL(ROUND(et.`RestDayAmount`, 2), 0) `Column16`

, FORMAT(IFNULL(et.`HolidayHours`, 0), 2) `Column44`
, IFNULL(FORMAT(et.HolidayPayAmount, 2), 0) `Column1`

, FORMAT(IFNULL(et.`LeaveHours`, 0), 2) `Column45`
, IFNULL(ROUND(et.`Leavepayment`, 2), 0) `Column15`

,NEWLINECHARTRIMMER(REPLACE(adj.`AdjustmentName`, ',', '\n')) `Column46`
,NEWLINECHARTRIMMER(REPLACE(adj.`AdjustmentAmount`, ',', '\n')) `Column47`

,NEWLINECHARTRIMMER(REPLACE(adj_positive.`AdjustmentName`, ',', '\n')) `Column50`
,NEWLINECHARTRIMMER(REPLACE(adj_positive.`AdjustmentAmount`, ',', '\n')) `Column51`

,NEWLINECHARTRIMMER(REPLACE(adj_negative.`AdjustmentName`, ',', '\n')) `Column52`
,NEWLINECHARTRIMMER(REPLACE(adj_negative.`AdjustmentAmount`, ',', '\n')) `Column53`

,NEWLINECHARTRIMMER(REPLACE(eapp.`AllowanceName`, ',', '\n')) `Column48`
,NEWLINECHARTRIMMER(REPLACE(eapp.`AllowanceAmount`, ',', '\n')) `Column49`

/**/, ( ps.TotalGrossSalary + IFNULL(adj_positive.`PayAmount`, 0) ) `Column60`
, ( ps.TotalLoans
    + (ps.TotalEmpSSS + ps.TotalEmpPhilhealth + ps.TotalEmpHDMF)
	 # + (IFNULL(et.Absent, 0) + IFNULL(et.HoursLateAmount, 0) + IFNULL(et.UndertimeHoursAmount, 0))
	 + IFNULL(adj_negative.`PayAmount` * -1, 0) ) `Column61`
	 
, ( ps.TotalLoans
    + (ps.TotalEmpSSS + ps.TotalEmpPhilhealth + ps.TotalEmpHDMF)
	 # + (IFNULL(et.Absent, 0) + IFNULL(et.HoursLateAmount, 0) + IFNULL(et.UndertimeHoursAmount, 0))
	 ) `Column62`
# , '50,000.00' `Column60`, '50,000.00' `Column61`, '50,000.00' `Column62`

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
			  ,SUM(et.RegularHoursAmount) `RegularHoursAmount`
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
			  ,SUM(et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours) `LeaveHours`
			  ,SUM(et.Leavepayment) `Leavepayment`
			  , IF(is_actual = 1
			       , SUM(i.RestDayActualPay)
					 , SUM(i.RestDayAmount)) `RestDayAmount`
			  , SUM(et.`AbsentHours`) `AbsentHours`
			  , SUM(IF(et.IsValidForHolidayPayment = 1
			           # , GREATEST(et.RegularHoursWorked, et.WorkHours)
			           , et.RegularHoursWorked
						  , 0)) `HolidayHours`
			  FROM proper_time_entry et
			  
			  LEFT JOIN restdaytimeentry i ON i.RowID = et.RowID
			  
			  WHERE et.OrganizationID=og_rowid
			  AND et.AsActual=is_actual
			  AND et.`Date` BETWEEN paydate_from AND paydat_to
			  GROUP BY et.EmployeeID
           ) et
       ON et.EmployeeID=ps.EmployeeID

LEFT JOIN (SELECT
           PayStubID
           ,GROUP_CONCAT(IF(psi.PayAmount = 0, '', p.PartNo)) `Column34`
           ,GROUP_CONCAT(IF(psi.PayAmount = 0, '', ROUND(psi.PayAmount, 2))) `Column37`
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
           ,GROUP_CONCAT(IF(psi.PayAmount = 0, '', ROUND(psi.PayAmount, 2))) `Column39`
           FROM paystubitem psi
			  INNER JOIN product p ON p.RowID=psi.ProductID AND p.`Category`='Bonus' AND p.ActiveData=1
			  WHERE psi.OrganizationID = og_rowid
			  # AND psi.PayAmount != 0
			  GROUP BY psi.PayStubID
			  ORDER BY psi.RowID
           ) psibon
       ON psibon.PayStubID = ps.RowID

# #######################

 LEFT JOIN (SELECT ii.*
            ,GROUP_CONCAT(UCASE(ii.LoanName)) `Column35`
            /*,GROUP_CONCAT(ROUND(ii.DeductionAmount, 2)) `Column38`
            ,GROUP_CONCAT(ROUND(ii.BalanceOfLoan, 2)) `Column33`*/
            
            ,GROUP_CONCAT(REPLACE(FORMAT(ROUND(ii.DeductedAmount, 2), 2)
				                      , ',', '|')
				              ) `Column38`
            ,GROUP_CONCAT(REPLACE(FORMAT(ROUND(ii.Balance, 2), 2)
				                      , ',', '|')
				              ) `Column33`
            FROM (/*SELECT i.RowID
						,i.EmployeeID
						,i.TotalLoanAmount
						,i.ppRowID
						,i.psRowID
						,(i.TotalLoanAmount - SUM(i.Deduction)) `BalanceOfLoan`
						,i.LoanName
						,MAX(i.DeductionAmount) `DeductionAmount`
						FROM (SELECT
								els.RowID
								,els.OrganizationID
								,els.EmployeeID
								,els.TotalLoanAmount
								,pp.RowID `ppRowID`
								,pp.PayFromDate
								,pp.PayToDate
								,pp.OrdinalValue
								, (@_ordinal := (@_ordinal + 1)) `AscOrder`
								, (@deduct_amt := ROUND((els.TotalLoanAmount / els.NoOfPayPeriod), 2)) `DeductAmt`
								
								,(@_deduction :=
								 IF(@_ordinal = els.NoOfPayPeriod
								    , ( @deduct_amt + (els.TotalLoanAmount - (@deduct_amt * els.NoOfPayPeriod)) )
									 , els.DeductionAmount)) `Deduction`
								
								,IF(pp.RowID = pp_rowid, @_deduction, 0) `DeductionAmount`
								
								,ps.RowID `psRowID`
								,e.EmployeeID `EmployeeUniqueId`
								,p.PartNo `LoanName`
								FROM employeeloanschedule els
								INNER JOIN employee e ON e.RowID=els.EmployeeID
								INNER JOIN payperiod pp ON pp.OrganizationID=els.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID
								AND (els.DedEffectiveDateFrom >= pp.PayFromDate OR els.DedEffectiveDateTo >= pp.PayFromDate)
								AND (els.DedEffectiveDateFrom <= pp.PayToDate OR els.DedEffectiveDateTo <= pp.PayToDate)
								
								LEFT JOIN paystub ps ON ps.OrganizationID=els.OrganizationID AND ps.EmployeeID=els.EmployeeID AND ps.PayPeriodID=pp.RowID
								
								INNER JOIN product p ON p.RowID=els.LoanTypeID
								
								WHERE els.RowID > 0
								AND els.OrganizationID=og_rowid
								# paydate_from paydat_to
								AND (els.DedEffectiveDateFrom >= paydate_from OR els.DedEffectiveDateTo >= paydate_from)
								AND (els.DedEffectiveDateFrom <= paydat_to OR els.DedEffectiveDateTo <= paydat_to)
								ORDER BY pp.OrdinalValue
						) i
						WHERE i.psRowID IS NOT NULL
						GROUP BY i.RowID*/
						SELECT plb.*
						FROM paysliploanbalances plb
						WHERE plb.OrganizationID = og_rowid
						AND plb.PayPeriodID = pp_rowid
				      ) ii
			  GROUP BY ii.EmployeeID
           ) psiloan
       ON psiloan.EmployeeID = ps.EmployeeID

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
           ,GROUP_CONCAT(IF(psi.PayAmount = 0, '', UCASE(p.PartNo))) `Column30`
           ,GROUP_CONCAT(IF(psi.PayAmount = 0, '', ROUND(psi.PayAmount, 2))) `Column31`
           FROM paystubitem psi
			  INNER JOIN product p ON p.RowID=psi.ProductID AND p.OrganizationID=psi.OrganizationID AND p.`Category`='Leave Type' AND p.ActiveData=1
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
			  , eapp.EmployeeID
			  FROM employeeallowance_perperiod eapp
			  WHERE eapp.OrganizationID=og_rowid
			  AND eapp.PayPeriodId=pp_rowid
			  GROUP BY eapp.EmployeeID) eapp ON eapp.EmployeeID=ps.EmployeeID
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
