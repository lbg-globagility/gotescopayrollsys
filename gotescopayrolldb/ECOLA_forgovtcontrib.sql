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

-- Dumping structure for procedure gotescopayrolldb_server.ECOLA_forgovtcontrib
DROP PROCEDURE IF EXISTS `ECOLA_forgovtcontrib`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `ECOLA_forgovtcontrib`(IN `og_rowid` INT, IN `date_from` DATE, IN `date_to` DATE)
    DETERMINISTIC
BEGIN

DECLARE ecola_rowid INT(11);

DECLARE month_count_peryear INT(11) DEFAULT 12;

DECLARE divided_into_half INT(11) DEFAULT 2;

DECLARE is_end_ofthe_month BOOL DEFAULT FALSE;

DECLARE ecola_name
        ,sss_deduct_sched
		  ,end_ofthe_month_deductsched VARCHAR(50);

SET end_ofthe_month_deductsched = 'End of the month';

SELECT og.SSSDeductionSchedule
FROM organization og
WHERE og.RowID=og_rowid
INTO sss_deduct_sched;

IF sss_deduct_sched = end_ofthe_month_deductsched THEN
	
	SELECT MIN(pp.PayFromDate)
	,MAX(pp.PayToDate)
	FROM payperiod pp
	INNER JOIN payperiod pyp ON pyp.OrganizationID=pp.OrganizationID AND pyp.PayFromDate=date_from AND pyp.PayToDate=date_to
	WHERE pp.OrganizationID=og_rowid
	AND pp.`Year`=pyp.`Year`
	AND pp.`Month`=pyp.`Month`
	AND pp.TotalGrossSalary=pyp.TotalGrossSalary
	INTO date_from
	     ,date_to;
	
	SET is_end_ofthe_month = TRUE;
	
END IF;

SELECT p.RowID
,p.PartNo
FROM product p
WHERE p.OrganizationID=og_rowid
AND p.PartNo='Ecola'
AND p.`Category`='Allowance Type'
LIMIT 1
INTO ecola_rowid
     ,ecola_name;

	SET @day_pay = 0.0;SET @day_pay1 = 0.0;SET @day_pay2 = 0.0;

	SELECT i.*
	FROM (SELECT et.RowID
			,et.EmployeeID
			,et.`Date`
			,(SELECT @timediffcount := sh.DivisorToDailyRate # COMPUTE_TimeDifference(sh.TimeFrom,sh.TimeTo)
			  ) `Equatn`
			,(SELECT @timediffcount := sh.DivisorToDailyRate # IF(@timediffcount < 6,@timediffcount,(@timediffcount - 1.0))
			  ) `timediffcount`
			
			,(et.RegularHoursWorked * (ea.AllowanceAmount / sh.DivisorToDailyRate)) `TotalAllowanceAmount`
			,es.ShiftID
			,ecola_name `PartNo`
			,'1st statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr
		           ON pr.RowID=et.PayRateID AND pr.PayType='Regular Day'
			INNER JOIN employee e
		           ON e.OrganizationID=og_rowid AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') AND e.EmployeeType='Daily'
			INNER JOIN employeeshift es
		           ON es.RowID=et.EmployeeShiftID
			INNER JOIN shift sh
		           ON sh.RowID=es.ShiftID
			INNER JOIN employeeallowance ea
		           ON ea.AllowanceFrequency='Daily' AND ea.EmployeeID=e.RowID AND ea.OrganizationID=og_rowid AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate AND ea.ProductID=ecola_rowid
		           
			WHERE et.OrganizationID=og_rowid AND et.`Date` BETWEEN date_from AND date_to
			
		UNION
			SELECT et.RowID
			,et.EmployeeID
			,et.`Date`
			,(@day_pay1 := esa.BasicPay) `Equatn`
			,0 `timediffcount`
			,ea.AllowanceAmount * ((et.HolidayPayAmount + ((et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) * (@day_pay1 / sh.DivisorToDailyRate))) / @day_pay1) `TotalAllowanceAmount`
			,es.ShiftID
			,ecola_name `PartNo`
			,'2nd statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr
		           ON pr.RowID=et.PayRateID AND pr.PayType='Regular Holiday'
			INNER JOIN employee e
		           ON e.OrganizationID=og_rowid AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') AND e.CalcHoliday='1' AND e.EmployeeType='Daily'
			INNER JOIN employeeshift es
		           ON es.RowID=et.EmployeeShiftID
			INNER JOIN shift sh
		           ON sh.RowID=es.ShiftID
			INNER JOIN employeeallowance ea
		           ON ea.AllowanceFrequency='Daily' AND ea.EmployeeID=e.RowID AND ea.OrganizationID=og_rowid AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate AND ea.ProductID=ecola_rowid
		           
			INNER JOIN employeesalary esa
		           ON esa.RowID=et.EmployeeSalaryID
			WHERE et.OrganizationID=og_rowid AND et.`Date` BETWEEN date_from AND date_to
			
		UNION
			SELECT et.RowID
			,et.EmployeeID
			,et.`Date`
			,(@day_pay1 := esa.BasicPay) `Equatn`
			,0 `timediffcount`
			,ea.AllowanceAmount * ((et.HolidayPayAmount + ((et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) * (@day_pay1 / sh.DivisorToDailyRate))) / @day_pay1) `TotalAllowanceAmount`
			,es.ShiftID
			,ecola_name `PartNo`
			,'3rd statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr
		           ON pr.RowID=et.PayRateID AND pr.PayType='Special Non-Working Holiday'
			INNER JOIN employee e
		           ON e.OrganizationID=og_rowid AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') AND e.CalcSpecialHoliday=1 AND e.EmployeeType='Daily'
			INNER JOIN employeeshift es
		           ON es.RowID=et.EmployeeShiftID
			INNER JOIN shift sh
		           ON sh.RowID=es.ShiftID
			INNER JOIN employeeallowance ea
		           ON ea.AllowanceFrequency='Daily' AND ea.EmployeeID=e.RowID AND ea.OrganizationID=og_rowid AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate AND ea.ProductID=ecola_rowid
		           
			INNER JOIN employeesalary esa
		           ON esa.RowID=et.EmployeeSalaryID
			WHERE et.OrganizationID=og_rowid AND et.RegularHoursAmount=0 AND et.TotalDayPay > 0 AND et.`Date` BETWEEN date_from AND date_to
			
		UNION
			SELECT et.RowID
			,et.EmployeeID
			,et.`Date`
			,(@timediffcount := sh.DivisorToDailyRate # COMPUTE_TimeDifference(sh.TimeFrom,sh.TimeTo)
			  ) `Equatn`
			,(@timediffcount := sh.DivisorToDailyRate # IF(@timediffcount < 6,@timediffcount,(@timediffcount - 1.0))
			  ) `timediffcount`
			
			,ea.AllowanceAmount `TotalAllowanceAmount`
			,es.ShiftID
			,ecola_name `PartNo`
			,'4th statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr
		           ON pr.RowID=et.PayRateID AND pr.PayType='Regular Day'
			INNER JOIN employee e
		           ON e.OrganizationID=og_rowid AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') AND e.EmployeeType='Daily'
			INNER JOIN employeeshift es
		           ON es.RowID=et.EmployeeShiftID
			INNER JOIN shift sh
		           ON sh.RowID=es.ShiftID
			INNER JOIN employeeallowance ea
		           ON ea.AllowanceFrequency='Daily' AND ea.EmployeeID=e.RowID AND ea.OrganizationID=og_rowid AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate AND ea.ProductID=ecola_rowid
		           
			WHERE et.OrganizationID=og_rowid AND et.`Date` BETWEEN date_from AND date_to
			AND et.RegularHoursWorked > 0
			
		UNION
			SELECT et.RowID
			,et.EmployeeID
			,et.`Date`
			,0 `Equatn`
			,0 `timediffcount`
			,ea.AllowanceAmount `TotalAllowanceAmount`
			,es.ShiftID
			,ecola_name `PartNo`
			,'5th statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr
		           ON pr.RowID=et.PayRateID AND pr.PayType='Regular Holiday'
			INNER JOIN employee e
		           ON e.OrganizationID=og_rowid AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') AND e.CalcHoliday='1' AND e.EmployeeType='Daily'
			LEFT JOIN employeeshift es
		          ON es.RowID=et.EmployeeShiftID
			                          AND (et.EmployeeShiftID IS NULL OR es.RestDay=1 OR e.DayOfRest=DAYOFWEEK(et.`Date`))
			INNER JOIN employeeallowance ea
		           ON ea.AllowanceFrequency='Daily' AND ea.EmployeeID=e.RowID AND ea.OrganizationID=og_rowid AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate AND ea.ProductID=ecola_rowid
		           
			WHERE et.OrganizationID=og_rowid AND et.`Date` BETWEEN date_from AND date_to
			
			# pay Ecola on leave
		UNION
			SELECT et.RowID
			,et.EmployeeID
			,et.`Date`
			,0 `Equatn`
			,0 `timediffcount`
			,IF((et.TotalDayPay / esa.BasicPay) >= 1
			    , ea.AllowanceAmount
				 , (ea.AllowanceAmount * (et.TotalDayPay / esa.BasicPay))) `TotalAllowanceAmount`
			
			,es.ShiftID
			,ecola_name `PartNo`
			,'6th statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr
		           ON pr.RowID=et.PayRateID AND pr.PayType='Regular day'
			INNER JOIN employee e
		           ON e.OrganizationID=og_rowid AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') AND e.EmployeeType='Daily'
			INNER JOIN employeeshift es
		           ON es.RowID=et.EmployeeShiftID
			INNER JOIN shift sh
		           ON sh.RowID=es.ShiftID
			INNER JOIN employeeallowance ea
		           ON ea.AllowanceFrequency='Daily' AND ea.EmployeeID=e.RowID AND ea.OrganizationID=og_rowid AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate AND ea.ProductID=ecola_rowid
		           
			INNER JOIN employeesalary esa
		           ON esa.RowID=et.EmployeeSalaryID
			WHERE et.OrganizationID=og_rowid AND et.`Date` BETWEEN date_from AND date_to
			AND (et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) > 0 AND et.TotalDayPay > 0
			
			) i
	GROUP BY i.RowID
	ORDER BY i.EmployeeID, i.`Date`
	;

# ###############################################################

	SET @allowance_amount = 0.00;
	
	SELECT
	ea.RowID
	, ea.ProductID
   , ea.EmployeeID
   , e.EmployeeID `EmpUniqueKey`
   , og_rowid `OrganizationID`
   , IFNULL(xy.`Date`, '1900-01-01') `Date`
   , ea.TaxableFlag
   , (@allowance_amount := IF(is_end_ofthe_month = TRUE, (ea.AllowanceAmount * 2), ea.AllowanceAmount)) `AllowanceAmount`
   # , (@allowance_amount := ea.AllowanceAmount) `AllowanceAmount`
	, e.WorkDaysPerYear
	, ROUND((@allowance_amount
	         - IFNULL((ea.AllowanceAmount / (e.WorkDaysPerYear / (month_count_peryear * divided_into_half)))
		                * IFNULL(xy.`AbsentCount`,0), 0)
		      ), 2) `TotalAllowanceAmount`
	, ea.EffectiveStartDate
	, ea.EffectiveEndDate
	
	FROM employeeallowance ea
	INNER JOIN employee e ON ea.EmployeeID=e.RowID AND e.EmployeeType != 'Daily'
	LEFT JOIN (SELECT COUNT(et.RowID) `AbsentCount`
		        ,et.`Date`
	           ,et.EmployeeID
				  FROM employeetimeentry et
				  INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.EmployeeType != 'Daily'
				  WHERE et.OrganizationID=og_rowid
				  AND et.Absent > 0
				  AND et.`Date` BETWEEN date_from AND date_to
				  GROUP BY et.EmployeeID
				  HAVING COUNT(et.RowID) IS NOT NULL
	           ) xy
			  ON xy.EmployeeID = e.RowID
	WHERE ea.OrganizationID=og_rowid
	AND ea.ProductID=ecola_rowid
	AND ea.AllowanceFrequency='Semi-monthly'
	AND (ea.EffectiveStartDate >= date_from OR ea.EffectiveEndDate >= date_from)
	AND (ea.EffectiveStartDate <= date_to OR ea.EffectiveEndDate <= date_to)
	GROUP BY e.RowID, ea.ProductID;
	
END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
