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
			, e.EmployeeID `Code` 
			, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `Full Name` 
			
			
			, SUM(et.RegularHoursAmount) `Basic rate` 
			, SUM(et.OvertimeHoursAmount) `OT` 
			
			, ROUND(SUM(et.HolidayPayAmount), 2) `Holiday` 
			, SUM(et.NightDiffHoursAmount) `N.Diff` 
			
			, IFNULL(rd.`SumRestDay`, 0) `Restday` 
			, IFNULL(elv.`SumLeavePay`, 0) `Leave` 
			, SUM(et.HoursLateAmount) `Tardiness` 
			, SUM(et.UndertimeHoursAmount) `Undertime` 
			, ROUND(SUM(et.Absent), 2) `Absent` 
			, ps.TotalBonus `Bonus` 
			, ps.TotalAllowance `Allowance` 
			, ps.TotalGrossSalary `Gross` 
			, ps.TotalEmpSSS `SSS` 
			, ps.TotalEmpPhilhealth `Ph.Health` 
			, ps.TotalEmpHDMF `HDMF` 
			, ps.TotalTaxableSalary `Taxable` 
			, ps.TotalEmpWithholdingTax `W.Tax` 
			, ps.TotalLoans `Loan` 
			, ps.TotalAdjustments `Adj.`
			, ps.TotalNetSalary `Net` 
			
			
			, IF(dv.RowID IS NULL, '', dv.Name) `DivisionName`
			
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
			, e.EmployeeID `Code` 
			, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `Full Name` 
			, IFNULL(esa.BasicPay, 0) `Basic rate` 
			, SUM(et.OvertimeHoursAmount) `OT` 
			
			
			, ROUND(SUM(IF(IFNULL(ROUND(et.TotalDayPay,2), 0) = IFNULL(ROUND(et.HolidayPayAmount,2), 0)
			               , 0, et.HolidayPayAmount)
			            )
			        , 2) `Holiday` 
			        
			, SUM(et.NightDiffHoursAmount) `N.Diff` 
			
			, IFNULL(rd.`SumRestDay`, 0) `Restday` 
			, IFNULL(elv.`SumLeavePay`, 0) `Leave` 
			, SUM(et.HoursLateAmount) `Tardiness` 
			, SUM(et.UndertimeHoursAmount) `Undertime` 
			, ROUND(SUM(et.Absent), 2) `Absent` 
			, ps.TotalBonus `Bonus` 
			, ps.TotalAllowance `Allowance` 
			, ps.TotalGrossSalary `Gross` 
			, ps.TotalEmpSSS `SSS` 
			, ps.TotalEmpPhilhealth `Ph.Health` 
			, ps.TotalEmpHDMF `HDMF` 
			, ps.TotalTaxableSalary `Taxable` 
			, ps.TotalEmpWithholdingTax `W.Tax` 
			, ps.TotalLoans `Loan` 
			, ps.TotalAdjustments `Adj.`
			, ps.TotalNetSalary `Net` 
			
			
			, IF(dv.RowID IS NULL, '', dv.Name) `DivisionName` 
			
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
			, e.EmployeeID `Code` 
			, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `Full Name` 
			
			
			, SUM(et.RegularHoursAmount) `Basic rate` 
			, 0 `Regular`
			, SUM(et.OvertimeHoursAmount) `OT` 
			
			, ROUND(SUM(et.HolidayPayAmount), 2) `Holiday` 
			, SUM(et.NightDiffHoursAmount) `N.Diff` 
			
			, IFNULL(rd.`SumRestDay`, 0) `Restday` 
			, IFNULL(elv.`SumLeavePay`, 0) `Leave` 
			, SUM(et.HoursLateAmount) `Tardiness` 
			, SUM(et.UndertimeHoursAmount) `Undertime` 
			, ROUND(SUM(et.Absent), 2) `Absent` 
			, ps.TotalBonus `Bonus` 
			, ps.TotalAllowance `Allowance` 
			, ps.TotalGrossSalary `Gross` 
			, ps.TotalEmpSSS `SSS` 
			, ps.TotalEmpPhilhealth `Ph.Health` 
			, ps.TotalEmpHDMF `HDMF` 
			, ps.TotalTaxableSalary `Taxable` 
			, ps.TotalEmpWithholdingTax `W.Tax` 
			, ps.TotalLoans `Loan` 
			, ps.TotalAdjustments `Adj.`
			, ps.TotalNetSalary `Net` 
			
			
			, IF(dv.RowID IS NULL, '', dv.Name) `DivisionName` 
			
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
			, e.EmployeeID `Code` 
			, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `Full Name` 
			
			

			, ROUND((IF(isActual, esa.TrueSalary, esa.Salary) / 2), 2) `Basic rate` 
			, ROUND((IF(isActual, esa.TrueSalary, esa.Salary) / 2), 2) `Regular`
			, SUM(et.OvertimeHoursAmount) `OT` 
			
			
			, ROUND(SUM(IF(IFNULL(ROUND(et.TotalDayPay,2), 0) = IFNULL(ROUND(et.HolidayPayAmount,2), 0)
			               , 0, et.HolidayPayAmount)
			            )
			        , 2) `Holiday` 
			
			, SUM(et.NightDiffHoursAmount) `N.Diff` 
			
			, IFNULL(rd.`SumRestDay`, 0) `Restday` 
			, IFNULL(elv.`SumLeavePay`, 0) `Leave` 
			, SUM(et.HoursLateAmount) `Tardiness` 
			, SUM(et.UndertimeHoursAmount) `Undertime` 
			, ROUND(SUM(et.Absent), 2) `Absent` 
			, ps.TotalBonus `Bonus` 
			, ps.TotalAllowance `Allowance` 
			, ps.TotalGrossSalary `Gross` 
			, ps.TotalEmpSSS `SSS` 
			, ps.TotalEmpPhilhealth `Ph.Health` 
			, ps.TotalEmpHDMF `HDMF` 
			, ps.TotalTaxableSalary `Taxable` 
			, ps.TotalEmpWithholdingTax `W.Tax` 
			, ps.TotalLoans `Loan` 
			, ps.TotalAdjustments `Adj.`
			, ps.TotalNetSalary `Net` 
			, IF(dv.RowID IS NULL, '', dv.Name) `DivisionName` 
			
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
			, e.EmployeeID `Code` 
			, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `Full Name` 
			
			


			, ( @basicPay := ROUND((IF(isActual, esa.TrueSalary, esa.Salary) / 2), 2) ) `Basic rate`
			
			, ( ROUND((IF(isActual, esa.TrueSalary, esa.Salary) / 2), 2)
			    - (SUM(IFNULL(et.HoursLateAmount,0))
				    + SUM(IFNULL(et.UndertimeHoursAmount,0))
					 + SUM(IFNULL(et.Absent,0))
					 + ROUND(SUM(IF(IFNULL(ROUND(et.TotalDayPay,2), 0) = IFNULL(ROUND(et.HolidayPayAmount,2), 0)
			                      , 0, et.HolidayPayAmount)), 2)
					 + IFNULL(elv.`SumLeavePay`, 0)
				    )
			   ) `Regular`
			, SUM(et.OvertimeHoursAmount) `OT` 
			
			
			, ROUND(SUM(IF(IFNULL(ROUND(et.TotalDayPay,2), 0) = IFNULL(ROUND(et.HolidayPayAmount,2), 0)
			               , 0, et.HolidayPayAmount)
			            )
			        , 2) `Holiday` 

			, SUM(et.NightDiffHoursAmount) `N.Diff` 
			
			, IFNULL(rd.`SumRestDay`, 0) `Restday` 
			, IFNULL(elv.`SumLeavePay`, 0) `Leave` 
			, SUM(et.HoursLateAmount) `Tardiness` 
			, SUM(et.UndertimeHoursAmount) `Undertime` 
			, ROUND(SUM(et.Absent), 2) `Absent` 
			, ps.TotalBonus `Bonus` 
			, ps.TotalAllowance `Allowance` 
			, ps.TotalGrossSalary `Gross` 
			, ps.TotalEmpSSS `SSS` 
			, ps.TotalEmpPhilhealth `Ph.Health` 
			, ps.TotalEmpHDMF `HDMF` 
			, ps.TotalTaxableSalary `Taxable` 
			, ps.TotalEmpWithholdingTax `W.Tax` 
			, ps.TotalLoans `Loan` 
			, ps.TotalAdjustments `Adj.`
			, ps.TotalNetSalary `Net` 
			, IF(dv.RowID IS NULL, '', dv.Name) `DivisionName` 
			
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

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
