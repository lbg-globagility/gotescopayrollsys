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

-- Dumping structure for procedure gotescopayrolldb_server.paystub_singlepayslip
DROP PROCEDURE IF EXISTS `paystub_singlepayslip`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `paystub_singlepayslip`(IN `OrganizID` INT, IN `PayPeriodRowID` INT, IN `IsActualFlag` CHAR(1), IN `e_rowid` INT)
    DETERMINISTIC
BEGIN
DECLARE loan_typ_count INT(11) DEFAULT 0;

DECLARE default_min_wage DECIMAL(11,2) DEFAULT 481.0;

DECLARE month_count_peryear INT(11) DEFAULT 12;

DECLARE default_min_workhours INT(11) DEFAULT 8;

DECLARE loan_typelist TEXT;

DECLARE filler_loan_onamount TEXT;

DECLARE max_itemlist_count INT(11) DEFAULT 6;

DECLARE filler_blank_loanitems TEXT DEFAULT '-\n-\n-\n-\n-\n';

SET @from_date = CURDATE();
SET @to_date = CURDATE();

SELECT COUNT(p_loan.RowID) FROM product p_loan WHERE p_loan.OrganizationID=OrganizID AND p_loan.`Category`='Loan Type' INTO loan_typ_count;

SELECT REPLACE(GROUP_CONCAT(p_loan.PartNo), ',','\n'), REPLACE(GROUP_CONCAT(IFNULL(p_loan.Image,0)), ',','\n') FROM product p_loan WHERE p_loan.OrganizationID=OrganizID AND p_loan.`Category`='Loan Type' ORDER BY p_loan.PartNo INTO loan_typelist, filler_loan_onamount;

SELECT pp.PayFromDate,pp.PayToDate FROM payperiod pp WHERE pp.RowID=PayPeriodRowID INTO @from_date,@to_date;

SET @virtual_erowid = 0;

SELECT ps.RowID , ps.AsActual, es.RowID, es.EffectiveDateFrom, es.EffectiveDateTo
,e.EmployeeID `Column2`
,CONCAT_WS(', ',e.LastName,e.FirstName) `Column3`
,es.BasicPay `Column11`, es.`SalaryGroup`

,IFNULL(ete.RegularHoursWorked,0) `Column17`,	ete.RegularHoursAmount `Column18`
,IFNULL(ete.OvertimeHoursWorked,0) `Column19`,	ete.OvertimeHoursAmount `Column20`
	
,ete.NightDifferentialHours `Column21`,			ete.NightDiffHoursAmount `Column22`
,ete.NightDifferentialOTHours `Column23`,			ete.NightDiffOTHoursAmount `Column24`

,IF(e.EmployeeType = 'Daily'
	,IFNULL(ete.TotalDayPay,0)
	,IF(e.EmployeeType = 'Fixed'
		,es.BasicPay
		,((es.BasicPay
			- (ete.HoursLateAmount + ete.UndertimeHoursAmount
				+ ete.Absent))))# + IFNULL(psi_holi.PayAmount,0) + IFNULL(addtlholipay.`SumAmount`,0)
	) `Column15`

,IFNULL(ete.Absent,0) `Column26`
						
,ete.HoursLateAmount `Column27`
,ete.UndertimeHoursAmount `Column28`

,ps.TotalEmpSSS `Column12`
,ps.TotalEmpPhilhealth `Column13`
,ps.TotalEmpHDMF `Column14`

,ps.TotalAllowance `Column8`
,ps.TotalBonus `Column10`

,ps.TotalLoans `Column9`

,IF(IFNULL(pp.MinimumWageValue,default_min_wage)
	>= IF(e.EmployeeType = 'Daily', es.BasicPay, (es.Salary / (e.WorkDaysPerYear / month_count_peryear)))
	, 0
	, ps.TotalTaxableSalary) `Column6`

,ps.TotalEmpWithholdingTax `Column7`

,ps.TotalGrossSalary `Column4`

,ps.TotalNetSalary `Column5`

,IFNULL((SELECT REPLACE(GROUP_CONCAT(ROUND(psi_loan.PayAmount, 2)), ',', '\n') `Result`
			FROM paystubitem psi_loan
			INNER JOIN product p_loan ON p_loan.OrganizationID=OrganizID AND p_loan.`Category`='Loan Type'
			WHERE psi_loan.PayStubID=ps.RowID AND psi_loan.ProductID=p_loan.RowID AND psi_loan.Undeclared=0
			AND psi_loan.PayAmount > 0
			ORDER BY p_loan.PartNo
			), filler_blank_loanitems) `Column38`
	
,(@virtual_erowid := ps.EmployeeID) `employeerowid`

,IFNULL((SELECT
			REPLACE(GROUP_CONCAT(p.PartNo), ',', '\n') `Result`
			FROM product p
			INNER JOIN payperiod pp ON pp.RowID=PayPeriodRowID
			INNER JOIN employeeloanschedule els
					ON els.OrganizationID=p.OrganizationID AND els.LoanTypeID=p.RowID #AND PAYMENT_SCHED_TO_CHAR(els.DeductionSchedule) = pp.Half
					AND els.EmployeeID=@virtual_erowid
					AND (els.DedEffectiveDateFrom >= pp.PayFromDate OR els.DedEffectiveDateTo >= pp.PayFromDate)
					AND (els.DedEffectiveDateFrom <= pp.PayToDate OR els.DedEffectiveDateTo <= pp.PayToDate)
					
			WHERE p.OrganizationID=OrganizID
			AND p.`Category`='Loan Type'
			ORDER BY p.PartNo
			LIMIT max_itemlist_count
			), filler_blank_loanitems) `Column35`

,IFNULL((SELECT
			REPLACE(GROUP_CONCAT(IFNULL(ROUND(lbt.DeductedAmount,2), IFNULL(els.TotalBalanceLeft,'-'))), ',', '\n') `Result`
			FROM product p
			INNER JOIN payperiod pp ON pp.RowID=PayPeriodRowID
			INNER JOIN employeeloanschedule els
					ON els.OrganizationID=p.OrganizationID AND els.LoanTypeID=p.RowID #AND PAYMENT_SCHED_TO_CHAR(els.DeductionSchedule) = pp.Half
					AND els.EmployeeID=@virtual_erowid
					AND (els.DedEffectiveDateFrom >= pp.PayFromDate OR els.DedEffectiveDateTo >= pp.PayFromDate)
					AND (els.DedEffectiveDateFrom <= pp.PayToDate OR els.DedEffectiveDateTo <= pp.PayToDate)
					
			LEFT JOIN employeeloanschedulebacktrack lbt ON lbt.RowID=els.RowID
			
			WHERE p.OrganizationID=OrganizID
			AND p.`Category`='Loan Type'
			ORDER BY p.PartNo
			LIMIT max_itemlist_count
			), filler_blank_loanitems) `Column33` # filler_loan_onamount

,IFNULL(psi_holi.PayAmount,0) `Column1`

,es.`SalaryGroup`

,IFNULL(REPLACE(psiallw.`Column34`, ',', '\n'), '') `Column34`
,IFNULL(REPLACE(psiallw.`Column37`, ',', '\n'), '') `Column37`

,IFNULL(REPLACE(psibon.`Column36`, ',', '\n'), '') `Column36`
,IFNULL(REPLACE(psibon.`Column39`, ',', '\n'), '') `Column39`

FROM v_uni_paystub ps
		
INNER JOIN payperiod pp ON pp.RowID = ps.PayPeriodID AND pp.RowID = PayPeriodRowID

INNER JOIN employee e
		ON e.OrganizationID=ps.OrganizationID
		AND e.RowID=e_rowid
		AND e.RowID = ps.EmployeeID
		AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')

LEFT JOIN `position` pos ON pos.RowID=e.PositionID

# INNER JOIN division dv ON dv.RowID=pos.DivisionId

# LEFT JOIN divisionminimumwage dmin ON dmin.DivisionID=dv.RowID AND @from_date BETWEEN dmin.EffectiveDateFrom AND dmin.EffectiveDateTo

INNER JOIN (SELECT es.*,0 `SalaryGroup`
				FROM employeesalary es
				WHERE es.OrganizationID=OrganizID
				AND (@from_date BETWEEN es.EffectiveDateFrom AND IFNULL(es.EffectiveDateTo,@to_date))
				AND (@to_date BETWEEN es.EffectiveDateFrom AND IFNULL(es.EffectiveDateTo,@to_date))
			UNION
				SELECT es.*,1 `SalaryGroup`
				FROM employeesalary es
				WHERE es.OrganizationID=OrganizID
				/*AND es.EffectiveDateFrom >= @from_date
				AND IFNULL(es.EffectiveDateTo, IF(@to_date < es.EffectiveDateFrom, NULL, @to_date)) <= @to_date
				
				AND (es.EffectiveDateFrom >= @from_date OR IFNULL(es.EffectiveDateTo,@to_date) >= @from_date)
				AND (es.EffectiveDateFrom <= @to_date OR IFNULL(es.EffectiveDateTo
																				, IF(@to_date < es.EffectiveDateFrom
																					, NULL, @to_date)) <= @to_date)*/
				AND (@from_date >= es.EffectiveDateFrom OR @to_date >= es.EffectiveDateFrom)
				AND (@from_date <= IFNULL(es.EffectiveDateTo,@to_date) OR @to_date <= IFNULL(es.EffectiveDateTo,@to_date))
				) es ON es.EmployeeID = ps.EmployeeID

LEFT JOIN (SELECT etea.RowID `eteRowID`,etea.EmployeeID
				, SUM(etea.RegularHoursWorked) `RegularHoursWorked`
				, SUM(IF(etea.RegularHoursAmount > IF(e.EmployeeType = 'Daily', es.BasicPay, (es.BasicPay / (e.WorkDaysPerYear / 24)))
						,(etea.RegularHoursAmount / IF(e.CalcHoliday = 1 OR e.CalcSpecialHoliday = 1, pr.`PayRate`, 1))
						,etea.RegularHoursAmount)) `RegularHoursAmount`
				, SUM(etea.TotalHoursWorked) `TotalHoursWorked`
				, SUM(etea.OvertimeHoursWorked) `OvertimeHoursWorked`
				, SUM(etea.OvertimeHoursAmount) `OvertimeHoursAmount`
				, SUM(etea.UndertimeHours) `UndertimeHours`
				, SUM(etea.UndertimeHoursAmount) `UndertimeHoursAmount`
				, SUM(etea.NightDifferentialHours) `NightDifferentialHours`
				, SUM(etea.NightDiffHoursAmount) `NightDiffHoursAmount`
				, SUM(etea.NightDifferentialOTHours) `NightDifferentialOTHours`
				, SUM(etea.NightDiffOTHoursAmount) `NightDiffOTHoursAmount`
				, SUM(etea.HoursLate) `HoursLate`
				, SUM(etea.HoursLateAmount) `HoursLateAmount`
				, SUM(etea.VacationLeaveHours) `VacationLeaveHours`
				, SUM(etea.SickLeaveHours) `SickLeaveHours`
				, SUM(etea.MaternityLeaveHours) `MaternityLeaveHours`
				, SUM(etea.OtherLeaveHours) `OtherLeaveHours`
				, SUM(etea.TotalDayPay) `TotalDayPay`
				, SUM(etea.Absent) `Absent`
				
				FROM v_uni_employeetimeentry etea
				INNER JOIN employee e ON e.RowID=etea.EmployeeID
				INNER JOIN employeesalary es ON es.RowID=etea.EmployeeSalaryID
				INNER JOIN payrate pr ON pr.RowID=etea.PayRateID
				WHERE etea.OrganizationID=OrganizID AND etea.AsActual = IsActualFlag
				AND etea.`Date` BETWEEN @from_date AND @to_date
				GROUP BY etea.EmployeeID) ete ON ete.EmployeeID=ps.EmployeeID

#INNER JOIN product p_loan ON p_loan.OrganizationID=ps.OrganizationID AND p_loan.`Category`='Loan Type'
#LEFT JOIN paystubitem psi_loan ON psi_loan.PayStubID=ps.RowID AND psi_loan.ProductID=p_loan.RowID AND psi_loan.Undeclared=0 #AND psi_loan.PayAmount IS NOT NULL

INNER JOIN product p_holi ON p_holi.OrganizationID=ps.OrganizationID AND p_holi.PartNo='Holiday pay' AND p_holi.`Category`='Miscellaneous'
LEFT JOIN paystubitem psi_holi ON psi_holi.OrganizationID=ps.OrganizationID AND psi_holi.PayStubID=ps.RowID AND psi_holi.Undeclared=ps.AsActual AND psi_holi.ProductID=p_holi.RowID

LEFT JOIN (SELECT ete.RowID,ete.EmployeeID
				,SUM((ete.RegularHoursAmount - (ete.RegularHoursAmount / pr.`PayRate`))) `SumAmount`,'PaidWitAttendance' `ResultType`
				FROM employeetimeentry ete
				INNER JOIN employee e ON e.RowID=ete.EmployeeID AND e.OrganizationID=ete.OrganizationID AND e.CalcSpecialHoliday='1' AND e.EmployeeType = 'Monthly'
				INNER JOIN employeesalary es
						ON es.RowID=ete.EmployeeSalaryID
						AND (IF(e.EmployeeType='Daily',es.BasicPay,(es.Salary / (e.WorkDaysPerYear / month_count_peryear))) / default_min_workhours) < (ete.RegularHoursAmount / ete.RegularHoursWorked)
				INNER JOIN payrate pr ON pr.RowID=ete.PayRateID AND pr.PayType IN ('Special Non-Working Holiday','Regular Holiday')
				WHERE ete.OrganizationID=OrganizID
				AND ete.`Date` BETWEEN @from_date AND @to_date
				AND ete.IsValidForHolidayPayment=1
				GROUP BY ete.EmployeeID
				HAVING SUM((ete.RegularHoursAmount - (ete.RegularHoursAmount / pr.`PayRate`))) IS NOT NULL) addtlholipay ON addtlholipay.EmployeeID=ps.EmployeeID

LEFT JOIN (SELECT
           PayStubID
           ,GROUP_CONCAT(IF(psi.PayAmount = 0, '', p.PartNo)) `Column34`
           ,GROUP_CONCAT(IF(psi.PayAmount = 0, '', ROUND(psi.PayAmount, 2))) `Column37`
           FROM paystubitem psi
			  INNER JOIN product p ON p.RowID=psi.ProductID AND p.`Category`='Allowance Type' AND p.ActiveData=1
			  WHERE psi.OrganizationID = OrganizID
			  AND psi.PayAmount != 0
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
			  WHERE psi.OrganizationID = OrganizID
			  AND psi.PayAmount != 0
			  GROUP BY psi.PayStubID
			  ORDER BY psi.RowID
           ) psibon
       ON psibon.PayStubID = ps.RowID

WHERE ps.OrganizationID = OrganizID AND ps.AsActual = IsActualFlag

GROUP BY ps.RowID

ORDER BY CONCAT(e.LastName,e.FirstName);

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
