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

-- Dumping structure for procedure gotescopayrolldb_latest.INSUPD_paystubitemallowances
DROP PROCEDURE IF EXISTS `INSUPD_paystubitemallowances`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSUPD_paystubitemallowances`(IN `og_rowid` INT, IN `e_rowid` INT, IN `pp_rowid` INT, IN `user_rowid` INT)
    DETERMINISTIC
BEGIN

DECLARE ps_rowid
        ,MonthCount INT(11);

DECLARE date_from
        , date_to DATE;

SET MonthCount = 12;

SELECT ps.RowID
,ps.PayFromDate
,ps.PayToDate
FROM paystub ps
WHERE ps.OrganizationID = og_rowid
AND ps.EmployeeID = e_rowid
AND ps.PayPeriodID = pp_rowid
INTO ps_rowid
     ,date_from
     ,date_to;

SET @timediffcount = 0.00;
SET @ecola_rowid = 0.00;
SET @day_pay1 = 0.00;

SELECT p.RowID
FROM product p
WHERE p.OrganizationID = og_rowid
AND p.PartNo = 'Ecola'
LIMIT 1
INTO @ecola_rowid;

SET SESSION low_priority_updates = ON;# LOW_PRIORITY 

INSERT LOW_PRIORITY INTO paystubitem(`ProductID`,`OrganizationID`,`Created`,`CreatedBy`,`PayStubID`,`PayAmount`,`Undeclared`)
	SELECT
	ii.ProductID
	,og_rowid
	,CURRENT_TIMESTAMP()
	,user_rowid
	,ps_rowid
	,ROUND(ii.`TotalAllowanceAmount`, 2)
	,'0'
	FROM
	(
		# SELECT i.*,SUM(i.TotalAllowanceAmt) AS TotalAllowanceAmount FROM paystubitem_sum_daily_allowance_group_prodid i WHERE i.EmployeeID=e_rowid AND i.ProductID != ecola_rowid AND i.OrganizationID=og_rowid AND i.`Date` BETWEEN date_from AND date_to GROUP BY i.ProductID
			
		SELECT i.ProductID, SUM(TotalAllowanceAmount) `TotalAllowanceAmount`
		FROM 
			(
			SELECT et.RowID,
			et.EmployeeID
			,et.`Date`
			,(SELECT @timediffcount := sh.DivisorToDailyRate # COMPUTE_TimeDifference(sh.TimeFrom,sh.TimeTo)
			  ) AS Equatn
			,(SELECT @timediffcount := sh.DivisorToDailyRate # IF(@timediffcount < 6,@timediffcount,(@timediffcount - 1.0))
			  ) AS timediffcount
			
			,(et.RegularHoursWorked * (ea.AllowanceAmount / sh.DivisorToDailyRate)) AS TotalAllowanceAmount
			,ea.ProductID
			,'1st statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Day'
			INNER JOIN employee e ON e.RowID=e_rowid AND e.OrganizationID=et.OrganizationID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
			INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
			INNER JOIN shift sh ON sh.RowID=es.ShiftID
			INNER JOIN employeeallowance ea ON ea.EmployeeID=e.RowID AND ea.AllowanceFrequency='Daily' AND ea.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
			INNER JOIN product p ON p.RowID=ea.ProductID
											AND p.RowID != @ecola_rowid
			WHERE et.OrganizationID=og_rowid AND et.`Date` BETWEEN date_from AND date_to
		UNION
			SELECT et.RowID,
			et.EmployeeID
			,et.`Date`
			,(@day_pay1 := GET_employeerateperday(et.EmployeeID,et.OrganizationID,et.`Date`)) AS Equatn
			,0 AS timediffcount
			,ea.AllowanceAmount * ((et.HolidayPayAmount + ((et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) * (@day_pay1 / sh.DivisorToDailyRate))) / @day_pay1) AS TotalAllowanceAmount
			,ea.ProductID
			,'2nd statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Holiday'
			INNER JOIN employee e ON e.RowID=e_rowid AND e.OrganizationID=et.OrganizationID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') AND e.CalcHoliday='1'
			INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
			INNER JOIN shift sh ON sh.RowID=es.ShiftID
			INNER JOIN employeeallowance ea ON ea.EmployeeID=e.RowID AND ea.AllowanceFrequency='Daily' AND ea.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
			INNER JOIN product p ON p.RowID=ea.ProductID
											#AND p.RowID != @ecola_rowid
											AND LOCATE('cola', p.PartNo) > 0
			WHERE et.OrganizationID=og_rowid AND et.`Date` BETWEEN date_from AND date_to
		UNION
			SELECT et.RowID,
			et.EmployeeID
			,et.`Date`
			,(@day_pay1 := GET_employeerateperday(et.EmployeeID,et.OrganizationID,et.`Date`)) AS Equatn
			,0 AS timediffcount
			,ea.AllowanceAmount * ((et.HolidayPayAmount + ((et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) * (@day_pay1 / sh.DivisorToDailyRate))) / @day_pay1) AS TotalAllowanceAmount
			,ea.ProductID
			,'3rd statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Special Non-Working Holiday'
			INNER JOIN employee e ON e.RowID=e_rowid AND e.OrganizationID=et.OrganizationID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') AND e.EmployeeType!='Daily'
			INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
			INNER JOIN shift sh ON sh.RowID=es.ShiftID
			INNER JOIN employeeallowance ea ON ea.EmployeeID=e.RowID AND ea.AllowanceFrequency='Daily' AND ea.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
			INNER JOIN product p ON p.RowID=ea.ProductID
			                        #AND p.RowID != @ecola_rowid
											AND LOCATE('cola', p.PartNo) > 0
			WHERE et.OrganizationID=og_rowid AND et.RegularHoursAmount=0 AND et.TotalDayPay > 0 AND et.`Date` BETWEEN date_from AND date_to
			
		UNION
			SELECT et.RowID,
			et.EmployeeID
			,et.`Date`
			,(@timediffcount := sh.DivisorToDailyRate # COMPUTE_TimeDifference(sh.TimeFrom,sh.TimeTo)
			  ) AS Equatn
			,(@timediffcount := sh.DivisorToDailyRate # IF(@timediffcount < 6,@timediffcount,(@timediffcount - 1.0))
			  ) AS timediffcount
			
			,ea.AllowanceAmount `TotalAllowanceAmount`
			,ea.ProductID
			,'4th statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Day'
			INNER JOIN employee e ON e.RowID=e_rowid AND e.OrganizationID=et.OrganizationID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
			INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
			INNER JOIN shift sh ON sh.RowID=es.ShiftID
			INNER JOIN employeeallowance ea ON ea.EmployeeID=e.RowID AND ea.AllowanceFrequency='Daily' AND ea.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
			INNER JOIN product p ON p.RowID=ea.ProductID
											AND p.RowID = @ecola_rowid
			WHERE et.OrganizationID=og_rowid AND et.`Date` BETWEEN date_from AND date_to
			AND et.RegularHoursWorked > 0
					
		UNION
			SELECT et.RowID
			,et.EmployeeID
			,et.`Date`
			,0 `Equatn`
			,0 `timediffcount`
			,ea.AllowanceAmount `TotalAllowanceAmount`
			,ea.ProductID
			,'5th statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr
			        ON pr.RowID=et.PayRateID AND pr.PayType='Regular Holiday'
			INNER JOIN employee e
			        ON e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') AND e.CalcHoliday='1'
			LEFT JOIN employeeshift es
			       ON es.RowID=et.EmployeeShiftID
			INNER JOIN employeeallowance ea
			        ON ea.EmployeeID=e.RowID AND ea.AllowanceFrequency='Daily' AND ea.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
			INNER JOIN product p
			        ON p.RowID=ea.ProductID
			        AND p.RowID=@ecola_rowid
			WHERE et.EmployeeID=e_rowid AND et.OrganizationID=og_rowid AND et.`Date` BETWEEN date_from AND date_to
			AND (et.EmployeeShiftID IS NULL OR es.RestDay=1 OR e.DayOfRest=DAYOFWEEK(et.`Date`))
			
		UNION
			SELECT et.RowID
			,et.EmployeeID
			,et.`Date`
			,0 `Equatn`
			,0 `timediffcount`
			,IF((et.TotalDayPay / IF(e.EmployeeType='Daily', esa.BasicPay, ((esa.Salary * e.WorkDaysPerYear) / MonthCount))) >= 1
	    , ea.AllowanceAmount
		 , (ea.AllowanceAmount * (et.TotalDayPay / IF(e.EmployeeType='Daily', esa.BasicPay, ((esa.Salary * e.WorkDaysPerYear) / MonthCount))))) `TotalAllowanceAmount`
			,ea.ProductID
			,'6th statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular day'
			INNER JOIN employee e ON e.OrganizationID=et.OrganizationID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
			INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
			INNER JOIN shift sh ON sh.RowID=es.ShiftID
			INNER JOIN employeeallowance ea ON ea.EmployeeID=e.RowID AND ea.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
			INNER JOIN product p
			        ON p.RowID=ea.ProductID
			        AND p.RowID=@ecola_rowid
			INNER JOIN employeesalary esa ON esa.RowID=et.EmployeeSalaryID
			WHERE et.EmployeeID=e_rowid AND et.OrganizationID=og_rowid AND et.`Date` BETWEEN date_from AND date_to
			AND (et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) > 0 AND et.TotalDayPay > 0) i
			GROUP BY i.ProductID

	) ii
	WHERE ii.ProductID IS NOT NULL
ON
DUPLICATE
KEY
UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=user_rowid
	,PayAmount=ROUND(ii.`TotalAllowanceAmount`, 2);

#######################################################################

SET @timediffcount = 0.00;

SET @day_pay = 0.00;

# ***************************************************** # ***************************************************** #

INSERT LOW_PRIORITY INTO paystubitem(`ProductID`,`OrganizationID`,`Created`,`CreatedBy`,`PayStubID`,`PayAmount`,`Undeclared`)
	SELECT i.ProductID
	,og_rowid
	,CURRENT_TIMESTAMP()
	,user_rowid
	,ps_rowid
	,ROUND(i.`AllowanceAmount`, 2)
	,0
	FROM (SELECT i.ProductID
	      ,i.EmployeeID
	      ,( i.AllowanceAmount - (SUM(i.HoursToLess) * ((i.AllowanceAmount / (i.WorkDaysPerYear / (i.PAYFREQDIV * 12))) / 8)) ) `AllowanceAmount`
	      FROM paystubitem_sum_semimon_allowance_group_prodid i
			WHERE i.OrganizationID=og_rowid
			AND i.EmployeeID=e_rowid
			# AND i.TaxableFlag = FALSE
			AND i.`Date` BETWEEN date_from AND date_to
			# GROUP BY i.EmployeeID,ii.RowID,ii.ProductID
			GROUP BY i.ProductID, i.TaxableFlag) i
ON
DUPLICATE
KEY
UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=user_rowid
	,PayAmount=ROUND(i.`AllowanceAmount`, 2);

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
