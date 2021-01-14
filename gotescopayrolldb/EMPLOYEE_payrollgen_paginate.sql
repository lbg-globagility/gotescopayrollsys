/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `EMPLOYEE_payrollgen_paginate`;
DELIMITER //
CREATE PROCEDURE `EMPLOYEE_payrollgen_paginate`(IN `OrganizID` INT, IN `Pay_Date_From` DATE, IN `Pay_Date_To` DATE, IN `max_rec_perpage` INT




)
    DETERMINISTIC
BEGIN

DECLARE i INT(11) DEFAULT 0;

DECLARE max_limit INT(11);# DEFAULT 50;

DECLARE page_num INT(11) DEFAULT 50;

DECLARE max_val INT(11) DEFAULT 0;

SET max_limit = max_rec_perpage;

SELECT (COUNT(e.RowID) / max_limit) + 1 FROM employee e WHERE e.OrganizationID=OrganizID INTO max_val;

SET @counter = -1;

WHILE i < max_val DO # max_val
	
	SET page_num = i * max_limit;
	
	# SELECT e.RowID FROM employee e WHERE e.OrganizationID=3 LIMIT page_num, max_limit;
	
	/*e.*,
og.PhilhealthDeductionSchedule AS PhHealthDeductSched,
og.PagIbigDeductionSchedule AS HDMFDeductSched,
og.SSSDeductionSchedule AS SSSDeductSched,
og.WithholdingDeductionSchedule AS WTaxDeductSched,
PAYFREQUENCY_DIVISOR(pf.PayFrequencyType) AS PAYFREQUENCY_DIVISOR,
GET_employeerateperday(e.RowID, e.OrganizationID, '2017-01-12') AS EmpRatePerDay,
 IFNULL(CAST(lv.DisplayValue AS DECIMAL(11,2)),0) AS MinimumWageAmount,
 IF(e.DateR1A <= e.StartDate, '0', (e.StartDate BETWEEN '2016-12-28' AND '2017-01-12')) AS IsFirstTimeSalary
 
 FROM employee e
INNER JOIN employeesalary esal ON e.RowID=esal.EmployeeID
INNER JOIN organization og ON og.RowID=e.OrganizationID
LEFT JOIN listofval lv ON lv.`Type`='Minimum Wage Rate'
INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
WHERE e.OrganizationID=1 AND '2017-01-12' BETWEEN esal.EffectiveDateFrom AND COALESCE(esal.EffectiveDateTo,
'2017-01-12')
GROUP BY e.RowID
ORDER BY e.RowID DESC;*/
	
	SELECT
	e.RowID
	,e.EmployeeID,e.MaritalStatus
	,e.NoOfDependents
	,e.PayFrequencyID
	,e.EmployeeType
	,e.EmploymentStatus
	,e.WorkDaysPerYear
	,e.PositionID
	,IF(e.AgencyID IS NOT NULL, IFNULL(d.PhHealthDeductSchedAgency,d.PhHealthDeductSched), d.PhHealthDeductSched) `PhHealthDeductSched`
	,IF(e.AgencyID IS NOT NULL, IFNULL(d.HDMFDeductSchedAgency,d.HDMFDeductSched), d.HDMFDeductSched) `HDMFDeductSched`
	,IF(e.AgencyID IS NOT NULL, IFNULL(d.SSSDeductSchedAgency,d.SSSDeductSched), d.SSSDeductSched) `SSSDeductSched`
	,IF(e.AgencyID IS NOT NULL, IFNULL(d.WTaxDeductSchedAgency,d.WTaxDeductSched), d.WTaxDeductSched) `WTaxDeductSched`
	,PAYFREQUENCY_DIVISOR(pf.PayFrequencyType) `PAYFREQUENCY_DIVISOR`
 	,IFNULL(CAST(lv.DisplayValue AS DECIMAL(11,2)),0) `MinimumWageAmount`
	,(e.StartDate BETWEEN Pay_Date_From AND Pay_Date_To) `IsFirstTimeSalary`
	,IF(e.EmployeeType='Daily', esal.BasicPay, esal.Salary / (e.WorkDaysPerYear / 12)) `EmpRatePerDay`
	,IFNULL(et.`etcount`,0) `StartingAttendanceCount`
	/*
	,GET_employeeStartingAttendanceCount(e.RowID,Pay_Date_From,Pay_Date_To) AS StartingAttendanceCount
	,GET_employeerateperday(e.RowID, OrganizID, Pay_Date_To) `EmpRatePerDay`
	*/
	#,(@counter := @counter + 1) `counter`
	FROM employee e
	LEFT JOIN employeesalary esal ON e.RowID=esal.EmployeeID AND esal.OrganizationID=e.OrganizationID
	LEFT JOIN `position` p ON p.RowID=e.PositionID AND p.OrganizationID=e.OrganizationID
	LEFT JOIN `division` d ON d.RowID=p.DivisionId AND d.OrganizationID=e.OrganizationID
	LEFT JOIN agency ag ON ag.RowID=e.AgencyID AND ag.OrganizationID=e.OrganizationID
	LEFT JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
	
	LEFT JOIN (SELECT COUNT(RowID) `etcount`,EmployeeID
					FROM employeetimeentry
					WHERE TotalDayPay!=0
					AND OrganizationID=OrganizID
					AND `Date` BETWEEN Pay_Date_From AND Pay_Date_To
					GROUP BY EmployeeID) et ON et.EmployeeID=e.RowID
		
	LEFT JOIN listofval lv ON lv.`Type`='Minimum Wage Rate'

	WHERE e.OrganizationID=OrganizID
	# AND Pay_Date_To BETWEEN esal.EffectiveDateFrom AND IFNULL(esal.EffectiveDateTo, Pay_Date_To)
	AND (esal.EffectiveDateFrom >= Pay_Date_From OR IFNULL(esal.EffectiveDateTo, Pay_Date_To) >= Pay_Date_From)
	AND (esal.EffectiveDateFrom <= Pay_Date_To OR IFNULL(esal.EffectiveDateTo, Pay_Date_To) <= Pay_Date_To)
	
	GROUP BY e.RowID
	ORDER BY e.LastName#@counter, e.RowID DESC
	LIMIT page_num, max_limit;
	
	SET i = i + 1;

END WHILE;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
