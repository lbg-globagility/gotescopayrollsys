BEGIN

DECLARE paypdatefrom DATE;

DECLARE paypdateto DATE;

DECLARE payfreq_rowid INT(11);

DECLARE month_count_peryear INT(11) DEFAULT 12;

DECLARE isActual BOOL DEFAULT FALSE;

SET isActual = (psi_undeclared = '1');

SELECT PayFromDate, TotalGrossSalary FROM payperiod WHERE RowID=ps_PayPeriodID1 INTO paypdatefrom, payfreq_rowid;

SELECT PayToDate FROM payperiod WHERE RowID=IFNULL(ps_PayPeriodID2,ps_PayPeriodID1) INTO paypdateto;




SET @basicPay = NULL;




IF psi_undeclared = 0 THEN
	
SELECT ii.* FROM (
	
	SELECT i.*
	FROM (
			SELECT
			
			ps.RowID
			, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `Full Name` 
			, e.LastName
			, e.FirstName
			, SUM(et.HoursLate + et.UndertimeHours) `LateHours`
			, SUM(et.HoursLateAmount + et.UndertimeHoursAmount) `LateAmount`
			, ROUND(SUM(et.Absent) / GET_employeerateperday(e.RowID, e.OrganizationID, paypdatefrom)) * 8 `AbsentHours`
			, SUM(et.Absent) `AbsentAmount`
			, SUM(et.VacationLeaveHours + et.SickLeaveHours) `LeaveHours`
			, IFNULL(elv.`SumLeavePay`, 0) `LeaveAmount`
			, SUM(et.OvertimeHoursWorked) `OvertimeHours`
			, SUM(et.OvertimeHoursAmount) `OvertimeAmount`
			, ps.TotalGrossSalary - ps.TotalAllowance `GrossWithoutAllowance`
			, ps.TotalEmpSSS `SSS` 
			, ps.TotalEmpPhilhealth `PhilHealth` 
			, ps.TotalEmpHDMF `HDMF` 
			, ps.TotalEmpWithholdingTax `WithholdingTax` 
			, ps.TotalNetSalary `Net` 
			,e.RowID 'EmployeeRowID'
			,ps.RowID AS 'PaystubId'
			
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
			, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `Full Name` 
			, e.LastName
			, e.FirstName
			, SUM(et.HoursLate + et.UndertimeHours) `LateHours`
			, SUM(et.HoursLateAmount + et.UndertimeHoursAmount) `LateAmount` 
			, ROUND(SUM(et.Absent) / GET_employeerateperday(e.RowID, e.OrganizationID, paypdatefrom)) * 8 `AbsentHours`
			, SUM(et.Absent) `AbsentAmount`
			, SUM(et.VacationLeaveHours + et.SickLeaveHours) `LeaveHours`
			, IFNULL(elv.`SumLeavePay`, 0) `LeaveAmount`
			, SUM(et.OvertimeHoursWorked) `OvertimeHours`
			, SUM(et.OvertimeHoursAmount) `OvertimeAmount`
			, ps.TotalGrossSalary - ps.TotalAllowance `GrossWithoutAllowance`
			, ps.TotalEmpSSS `SSS` 
			, ps.TotalEmpPhilhealth `PhilHealth` 
			, ps.TotalEmpHDMF `HDMF` 
			, ps.TotalEmpWithholdingTax `WithholdingTax` 
			, ps.TotalNetSalary `Net` 
			,e.RowID 'EmployeeRowID'
			,ps.RowID AS 'PaystubId'
			
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
			, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `Full Name` 
			, e.LastName
			, e.FirstName
			, SUM(et.HoursLate + et.UndertimeHours) `LateHours`
			, SUM(et.HoursLateAmount + et.UndertimeHoursAmount) `LateAmount` 
			, ROUND(SUM(et.Absent) / GET_employeerateperday(e.RowID, e.OrganizationID, paypdatefrom)) * 8 `AbsentHours`
			, SUM(et.Absent) `AbsentAmount`
			, SUM(et.VacationLeaveHours + et.SickLeaveHours) `LeaveHours`
			, IFNULL(elv.`SumLeavePay`, 0) `LeaveAmount`
			, SUM(et.OvertimeHoursWorked) `OvertimeHours`
			, SUM(et.OvertimeHoursAmount) `OvertimeAmount`
			, ps.TotalGrossSalary - ps.TotalAllowance `GrossWithoutAllowance`
			, ps.TotalEmpSSS `SSS` 
			, ps.TotalEmpPhilhealth `PhilHealth` 
			, ps.TotalEmpHDMF `HDMF` 
			, ps.TotalEmpWithholdingTax `WithholdingTax` 
			, ps.TotalNetSalary `Net` 
			,e.RowID 'EmployeeRowID'
			,ps.RowID AS 'PaystubId'
			
			
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
			, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `Full Name` 
			, e.LastName
			, e.FirstName
			, SUM(et.HoursLate + et.UndertimeHours) `LateHours`
			, SUM(et.HoursLateAmount + et.UndertimeHoursAmount) `LateAmount`
			, ROUND(SUM(et.Absent) / GET_employeerateperday(e.RowID, e.OrganizationID, paypdatefrom)) * 8 `AbsentHours` 
			, SUM(et.Absent) `AbsentAmount`
			, SUM(et.VacationLeaveHours + et.SickLeaveHours) `LeaveHours`
			, IFNULL(elv.`SumLeavePay`, 0) `LeaveAmount`
			, SUM(et.OvertimeHoursWorked) `OvertimeHours`
			, SUM(et.OvertimeHoursAmount) `OvertimeAmount`
			, ps.TotalGrossSalary - ps.TotalAllowance `GrossWithoutAllowance`
			, ps.TotalEmpSSS `SSS` 
			, ps.TotalEmpPhilhealth `PhilHealth` 
			, ps.TotalEmpHDMF `HDMF` 
			, ps.TotalEmpWithholdingTax `WithholdingTax` 
			, ps.TotalNetSalary `Net` 
			,e.RowID 'EmployeeRowID'
			,ps.RowID AS 'PaystubId'
			
			FROM paystubactual ps
			
			LEFT JOIN product pd3 ON pd3.OrganizationID=ps.OrganizationID AND pd3.PartNo='Holiday pay'
			LEFT JOIN paystubitem pst3 ON pst3.PayStubID=ps.RowID AND pst3.ProductID=pd3.RowID AND pst3.OrganizationID=ps.OrganizationID AND pst3.`Undeclared`=psi_undeclared
			
			LEFT JOIN product prd ON prd.OrganizationID=ps.OrganizationID AND prd.PartNo='Restday pay'
			LEFT JOIN paystubitem psrd ON psrd.PayStubID=ps.RowID AND psrd.ProductID=pd3.RowID AND psrd.OrganizationID=ps.OrganizationID AND psrd.`Undeclared`=psi_undeclared
			
			INNER JOIN employee e ON e.RowID=ps.EmployeeID AND e.EmployeeType = 'Fixed'
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
	
UNION
	SELECT i.*
	FROM (
			SELECT
			ps.RowID
			, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `Full Name` 
			, e.LastName
			, e.FirstName
			, SUM(et.HoursLate + et.UndertimeHours) `LateHours`
			, SUM(et.HoursLateAmount + et.UndertimeHoursAmount) `LateAmount`
			, ROUND(SUM(et.Absent) / GET_employeerateperday(e.RowID, e.OrganizationID, paypdatefrom)) * 8 `AbsentHours`
			, SUM(et.Absent) `AbsentAmount`
			, SUM(et.VacationLeaveHours + et.SickLeaveHours) `LeaveHours`
			, IFNULL(elv.`SumLeavePay`, 0) `LeaveAmount`
			, SUM(et.OvertimeHoursWorked) `OvertimeHours`
			, SUM(et.OvertimeHoursAmount) `OvertimeAmount`
			, ps.TotalGrossSalary - ps.TotalAllowance `GrossWithoutAllowance`
			, ps.TotalEmpSSS `SSS` 
			, ps.TotalEmpPhilhealth `PhilHealth` 
			, ps.TotalEmpHDMF `HDMF` 
			, ps.TotalEmpWithholdingTax `WithholdingTax` 
			, ps.TotalNetSalary `Net` 
			,e.RowID 'EmployeeRowID'
			,ps.RowID AS 'PaystubId'
			
			FROM paystubactual ps
			
			LEFT JOIN product pd3 ON pd3.OrganizationID=ps.OrganizationID AND pd3.PartNo='Holiday pay'
			LEFT JOIN paystubitem pst3 ON pst3.PayStubID=ps.RowID AND pst3.ProductID=pd3.RowID AND pst3.OrganizationID=ps.OrganizationID AND pst3.`Undeclared`=psi_undeclared
			
			LEFT JOIN product prd ON prd.OrganizationID=ps.OrganizationID AND prd.PartNo='Restday pay'
			LEFT JOIN paystubitem psrd ON psrd.PayStubID=ps.RowID AND psrd.ProductID=pd3.RowID AND psrd.OrganizationID=ps.OrganizationID AND psrd.`Undeclared`=psi_undeclared
			
			INNER JOIN employee e ON e.RowID=ps.EmployeeID AND e.EmployeeType = 'Monthly'
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

END