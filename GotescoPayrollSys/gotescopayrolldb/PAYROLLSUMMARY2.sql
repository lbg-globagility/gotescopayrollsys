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

-- Dumping structure for procedure gotescopayrolldb_oct19.PAYROLLSUMMARY2
DROP PROCEDURE IF EXISTS `PAYROLLSUMMARY2`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `PAYROLLSUMMARY2`(IN `ps_OrganizationID` INT, IN `ps_PayPeriodID1` INT, IN `ps_PayPeriodID2` INT, IN `psi_undeclared` CHAR(1), IN `strSalaryDistrib` VARCHAR(50)

)
    DETERMINISTIC
BEGIN

DECLARE paypdatefrom DATE;

DECLARE paypdateto DATE;

DECLARE payfreq_rowid INT(11);


SELECT PayFromDate, TotalGrossSalary FROM payperiod WHERE RowID=ps_PayPeriodID1 INTO paypdatefrom, payfreq_rowid;

SELECT PayToDate FROM payperiod WHERE RowID=IFNULL(ps_PayPeriodID2,ps_PayPeriodID1) INTO paypdateto;



SELECT
# (SELECT SUM((IFNULL(TotalDayPay,0)) - (IFNULL(OvertimeHoursAmount,0) + IFNULL(NightDiffHoursAmount,0) + IFNULL(NightDiffOTHoursAmount,0))) FROM employeetimeentry WHERE OrganizationID=ps_OrganizationID AND EmployeeID=ps.EmployeeID AND `Date` BETWEEN paypdatefrom AND paypdateto) * IF(psi_undeclared = '0', 1, (GET_employeeundeclaredsalarypercent(ps.EmployeeID,ps_OrganizationID,ps.PayFromDate,ps.PayToDate) + 1)) 'BasicPay'
IF(e.EmployeeType = 'Daily', IFNULL(ett.RegularHoursAmount,0), ( es.BasicPay - SUM(IFNULL(pst3.PayAmount,0)) )) `BasicPay`
,SUM(IFNULL(pst6.PayAmount,0)) 'TotalGrossSalary'
,SUM(IFNULL(pst7.PayAmount,0)) 'TotalNetSalary'
#,IF((GET_employeerateperday(ps.EmployeeID,ps_OrganizationID,PayFromDate) <= d.MinimumWageAmount)
,IF(IF(e.EmployeeType = 'Daily', es.BasicPay, ROUND( ( es.BasicPay / (e.WorkDaysPerYear / 24) ) , 2) ) <= d.MinimumWageAmount
	,0
	,SUM(ps.TotalTaxableSalary)) 'TotalTaxableSalary'
,ps.TotalEmpSSS
,SUM(IFNULL(pst9.PayAmount,0)) 'TotalEmpWithholdingTax'
,ps.TotalEmpPhilhealth
,ps.TotalEmpHDMF
,ps.TotalLoans
,ps.TotalBonus
,ps.TotalAllowance
,e.EmployeeID
,UCASE(e.FirstName) 'FirstName'
,INITIALS(e.MiddleName,'. ','1') 'MiddleName'
,UCASE(e.LastName) 'LastName'
,UCASE(e.Surname) 'Surname'
,UCASE(p.PositionName) 'PositionName'
,UCASE(d.Name) 'DivisionName'
,e.RowID 'EmployeeRowID'
,SUM(IFNULL(pst.PayAmount,0)) AS Tardiness
,SUM(IFNULL(pst1.PayAmount,0)) AS Undertime
,SUM(IFNULL(pst2.PayAmount,0)) AS NightDifftl
,SUM(IFNULL(pst3.PayAmount,0)) AS HolidayPay
,SUM(IFNULL(pst4.PayAmount,0)) AS OverTime
,SUM(IFNULL(pst5.PayAmount,0)) AS NightDifftlOT
,IFNULL(pst10.PayAmount,0) AS DatCol32
,(IF(e.EmployeeType = 'Daily', es.BasicPay, ROUND( ( es.BasicPay / (e.WorkDaysPerYear / 24) ) , 2) ) <= d.MinimumWageAmount) `IsMinimum`
,IFNULL(0,0) AS DatCol39
FROM paystub ps
INNER JOIN employee e ON e.RowID=ps.EmployeeID
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

INNER JOIN product pd10 ON pd10.OrganizationID=ps_OrganizationID AND pd10.PartNo='Absent'
LEFT JOIN paystubitem pst10 ON pst10.PayStubID=ps.RowID AND pst10.ProductID=pd10.RowID AND pst10.`Undeclared`=psi_undeclared

LEFT JOIN (SELECT et.RowID,et.EmployeeID
				,et.RegularHoursAmount `RegularHoursAmount0`
				,SUM(et.RegularHoursAmount / IF(e.CalcHoliday = 1 OR e.CalcSpecialHoliday = 1, pr.`PayRate`, 1)) `RegularHoursAmount`
				,pr.PayType,e.EmployeeType,e.EmployeeID `EmpNumber`
				FROM v_uni_employeetimeentry et
				INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.EmployeeType='Daily'
				INNER JOIN payrate pr ON pr.RowID=et.PayRateID
				WHERE et.AsActual = psi_undeclared AND et.RegularHoursAmount > 0 AND et.OrganizationID=ps_OrganizationID AND et.`Date` BETWEEN paypdatefrom AND paypdateto GROUP BY et.EmployeeID) ett ON ett.EmployeeID=ps.EmployeeID

INNER JOIN employeesalary es ON es.EmployeeID=ps.EmployeeID AND es.OrganizationID=ps.OrganizationID AND (es.EffectiveDateFrom >= paypdatefrom OR IFNULL(es.EffectiveDateTo,paypdateto) >= paypdatefrom) AND (es.EffectiveDateFrom <= paypdateto OR IFNULL(es.EffectiveDateTo,paypdateto) <= paypdateto)

WHERE ps.OrganizationID=ps_OrganizationID
# AND ps.TotalNetSalary > -1
AND (ps.PayFromDate >= paypdatefrom OR ps.PayToDate >= paypdatefrom)
AND (ps.PayFromDate <= paypdateto OR ps.PayToDate <= paypdateto)
AND LENGTH(IFNULL(e.ATMNo,''))=IF(strSalaryDistrib = 'Cash', 0, LENGTH(IFNULL(e.ATMNo,'')))
GROUP BY ps.EmployeeID
ORDER BY d.Name,e.LastName,e.FirstName;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
