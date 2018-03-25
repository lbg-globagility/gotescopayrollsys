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

-- Dumping structure for procedure gotescopayrolldb_server.GET_employee_allowanceofthisperiod
DROP PROCEDURE IF EXISTS `GET_employee_allowanceofthisperiod`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `GET_employee_allowanceofthisperiod`(IN `OrganizID` INT, IN `AllowanceFrequenzy` VARCHAR(50), IN `IsTaxable` CHAR(1), IN `DatePayFrom` DATE, IN `DatePayTo` DATE)
    DETERMINISTIC
BEGIN



DECLARE isEndOfMonth CHAR(1);

DECLARE MonthCount DECIMAL(11,2) DEFAULT 12.0;

DECLARE firstdate DATE;

DECLARE thismonth VARCHAR(2);

DECLARE thisyear INT(11);

DECLARE ecola_rowid INT(11);

DECLARE default_min_hrswork INT(11) DEFAULT 8;

SET @timediffcount = 0.00;

SELECT RowID FROM product WHERE OrganizationID=OrganizID AND LCASE(PartNo)='ecola' AND `Category`='Allowance type' INTO ecola_rowid;

IF AllowanceFrequenzy = 'Semi-monthly version 1' THEN
	
	SET @dailyallowanceamount = 0.000000;
	
	
	SELECT
	(SELECT @dailyallowanceamount := ROUND((ea.AllowanceAmount / (e.WorkDaysPerYear / (PAYFREQUENCY_DIVISOR(pf.PayFrequencyType) * MonthCount))),2))
	,(SELECT @timediffcount := COMPUTE_TimeDifference(sh.TimeFrom,sh.TimeTo))
	,(SELECT @timediffcount := IF(@timediffcount < 6,@timediffcount,(@timediffcount - 1.0)))
	,((et.RegularHoursWorked / @timediffcount) * @dailyallowanceamount) AS TotalAllowanceAmount
	,et.EmployeeID
	,ea.ProductID
	FROM employeetimeentry et
	INNER JOIN employee e ON e.OrganizationID=OrganizID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
	INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
	INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
	INNER JOIN shift sh ON sh.RowID=es.ShiftID
	INNER JOIN employeeallowance ea ON ea.AllowanceFrequency=AllowanceFrequenzy AND ea.TaxableFlag=IsTaxable AND ea.EmployeeID=e.RowID AND ea.OrganizationID=OrganizID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
	INNER JOIN product p ON p.RowID=ea.ProductID
	WHERE et.OrganizationID=OrganizID AND et.`Date` BETWEEN DatePayFrom AND DatePayTo;
	
ELSEIF AllowanceFrequenzy = 'Monthly' THEN

	SELECT (`Half` = 0),`Month`,`Year` FROM payperiod WHERE OrganizationID=OrganizID AND PayFromDate=DatePayFrom AND PayToDate=DatePayTo LIMIT 1 INTO isEndOfMonth,thismonth,thisyear;
	
	
	
	IF isEndOfMonth = '1' THEN
	
		SELECT PayFromDate FROM payperiod WHERE OrganizationID=OrganizID AND `Month`=thismonth AND `Year`=thisyear ORDER BY PayFromDate,PayToDate LIMIT 1 INTO firstdate;
		
		SELECT
		(SELECT @dailyallowanceamount := ROUND((ea.AllowanceAmount / (e.WorkDaysPerYear / MonthCount)),2))
		,(SELECT @timediffcount := COMPUTE_TimeDifference(sh.TimeFrom,sh.TimeTo))
		,(SELECT @timediffcount := IF(@timediffcount IN (4,5),@timediffcount,(@timediffcount - 1.0)))
		,ROUND((@dailyallowanceamount - ( ( (et.HoursLate + et.UndertimeHours) / @timediffcount ) * @dailyallowanceamount )),2) AS TotalAllowanceAmount
		,et.EmployeeID
		,ea.ProductID
		FROM employeetimeentry et
		INNER JOIN employee e ON e.OrganizationID=OrganizID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
		INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
		INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
		INNER JOIN shift sh ON sh.RowID=es.ShiftID
		INNER JOIN employeeallowance ea ON ea.AllowanceFrequency=AllowanceFrequenzy AND ea.TaxableFlag=IsTaxable AND ea.EmployeeID=e.RowID AND ea.OrganizationID=OrganizID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
		INNER JOIN product p ON p.RowID=ea.ProductID
		WHERE et.OrganizationID=OrganizID AND et.`Date` BETWEEN firstdate AND DatePayTo;
		
	ELSE
		SELECT 0 AS TotalAllowanceAmount, '' AS EmployeeID, 0 AS ProductID;
		
	END IF;

ELSEIF AllowanceFrequenzy = 'Semi-monthly' THEN
	
# ProductID, EmployeeD, OrganizationID, `Date`, Column1, Column2, TotalAllowanceAmt, TaxableFlag, HoursToLess, AllowanceAmount, WorkDaysPerYear, PAYFREQDIV

	/*SELECT i.*,ii.AllowanceAmount - (SUM(i.HoursToLess) * ((i.AllowanceAmount / (i.WorkDaysPerYear / (i.PAYFREQDIV * 12))) / 8)) AS TotalAllowanceAmount
	FROM paystubitem_sum_semimon_allowance_group_prodid i
	INNER JOIN (SELECT ea.*,MIN(d.DateValue) AS DateRange1,MAX(d.DateValue) AS DateRange2 FROM dates d INNER JOIN employeeallowance ea ON ea.ProductID != ecola_rowid AND ea.AllowanceFrequency='Semi-monthly' AND TaxableFlag=IsTaxable AND ea.OrganizationID=OrganizID AND d.DateValue BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate WHERE d.DateValue BETWEEN DatePayFrom AND DatePayTo GROUP BY ea.RowID ORDER BY d.DateValue) ii ON i.ProductID != ecola_rowid AND i.EmployeeID=ii.EmployeeID AND i.OrganizationID=ii.OrganizationID AND i.`Date` BETWEEN ii.DateRange1 AND ii.DateRange2
	
	GROUP BY i.EmployeeID,ii.RowID;*/
	
	/*SELECT i.ProductID, i.EmployeeD, i.OrganizationID, i.`Date`, i.Column1, i.Column2, i.TotalAllowanceAmt, i.TaxableFlag, i.HoursToLess, i.AllowanceAmount, i.WorkDaysPerYear, i.PAYFREQDIV, i.TotalAllowanceAmount
	FROM () i
UNION
	SELECT ea.ProductID, ea.EmployeeD, OrganizID `OrganizationID`, ea.EffectiveEndDate `Date`, 0 `Column1`, 0 `Column2`, 0 `TotalAllowanceAmt`, ea.TaxableFlag, 0 `HoursToLess`, ea.AllowanceAmount, e.WorkDaysPerYear, 0 `PAYFREQDIV`, ea.AllowanceAmount `TotalAllowanceAmount`
	FROM employeeallowance ea
	INNER JOIN employee e ON ea.EmployeeID=e.RowID
	WHERE ea.OrganizationID=OrganizID
	AND ea.ProductID=ecola_rowid
	AND ea.AllowanceFrequency=AllowanceFrequenzy;*/
	
	/*SELECT i.ProductID, i.EmployeeID, i.OrganizationID, i.`Date`, i.Column1, i.Column2, i.TotalAllowanceAmt, i.TaxableFlag, i.HoursToLess, i.AllowanceAmount, i.WorkDaysPerYear, i.PAYFREQDIV, i.TotalAllowanceAmount
	FROM (SELECT i.*,ii.AllowanceAmount - (SUM(i.HoursToLess) * ((i.AllowanceAmount / (i.WorkDaysPerYear / (i.PAYFREQDIV * 12))) / 8)) AS TotalAllowanceAmount
	FROM paystubitem_sum_semimon_allowance_group_prodid i
	INNER JOIN (SELECT ea.*,MIN(d.DateValue) AS DateRange1,MAX(d.DateValue) AS DateRange2 FROM dates d INNER JOIN employeeallowance ea ON ea.ProductID != ecola_rowid AND ea.AllowanceFrequency='Semi-monthly' AND TaxableFlag=IsTaxable AND ea.OrganizationID=OrganizID AND d.DateValue BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate WHERE d.DateValue BETWEEN DatePayFrom AND DatePayTo GROUP BY ea.RowID ORDER BY d.DateValue) ii ON i.ProductID != ecola_rowid AND i.EmployeeID=ii.EmployeeID AND i.OrganizationID=ii.OrganizationID AND i.`Date` BETWEEN ii.DateRange1 AND ii.DateRange2
	
	GROUP BY i.EmployeeID,ii.RowID) i*/
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	/*SELECT i.ProductID, i.EmployeeID, i.OrganizationID, i.`Date`, i.Column1, i.Column2, i.TotalAllowanceAmt, i.TaxableFlag, i.HoursToLess, i.AllowanceAmount, i.WorkDaysPerYear, i.PAYFREQDIV, i.TotalAllowanceAmount
	FROM (SELECT i.ProductID, i.EmployeeID, i.OrganizationID, i.`Date`, i.Column1, i.Column2, i.TotalAllowanceAmt, i.TaxableFlag, i.HoursToLess, i.AllowanceAmount, i.WorkDaysPerYear, i.PAYFREQDIV, SUM(i.TotalAllowanceAmt) `TotalAllowanceAmount` FROM paystubitem_sum_semimon_allowance_group_prodid i WHERE i.ProductID != ecola_rowid AND i.TaxableFlag = IsTaxable AND i.OrganizationID=OrganizID AND i.`Date` BETWEEN DatePayFrom AND DatePayTo GROUP BY i.ProductID, i.EmployeeID) i
UNION
	SELECT ea.ProductID, ea.EmployeeID, OrganizID `OrganizationID`, '1900-01-01' `Date`, 0 `Column1`, 0 `Column2`, 0 `TotalAllowanceAmt`, ea.TaxableFlag, 0 `HoursToLess`, ea.AllowanceAmount, e.WorkDaysPerYear, 0 `PAYFREQDIV`
	, ea.AllowanceAmount - IFNULL(ROUND((ea.AllowanceAmount / (e.WorkDaysPerYear / 24)), 2) * IFNULL(xy.`AbsentCount`,0), 0) `TotalAllowanceAmount`
	FROM employeeallowance ea
	INNER JOIN employee e ON ea.EmployeeID=e.RowID
	LEFT JOIN (SELECT COUNT(et.RowID) `AbsentCount`,et.EmployeeID FROM employeetimeentry et WHERE et.OrganizationID=OrganizID AND et.Absent > 0 AND et.`Date` BETWEEN DatePayFrom AND DatePayTo GROUP BY et.EmployeeID) xy ON xy.EmployeeID = e.RowID
	WHERE ea.OrganizationID=OrganizID AND ea.TaxableFlag = IsTaxable
	AND ea.ProductID=ecola_rowid
	AND ea.AllowanceFrequency=AllowanceFrequenzy;*/
	
	
	
	
	
	
	
	
	SELECT i.*
	
	# ,ii.AllowanceAmount - (SUM(i.HoursToLess) * ((i.AllowanceAmount / (i.WorkDaysPerYear / (i.PAYFREQDIV * MonthCount))) / default_min_hrswork)) AS TotalAllowanceAmount
	
	,ii.AllowanceAmount - (SUM(i.HoursToLess) * ((ii.AllowanceAmount / (i.WorkDaysPerYear / (i.PAYFREQDIV * MonthCount))) / default_min_hrswork)) AS TotalAllowanceAmount
	
	# ,i.AllowanceAmount - (SUM(i.HoursToLess) * ((i.AllowanceAmount / (i.WorkDaysPerYear / (i.PAYFREQDIV * MonthCount))) / default_min_hrswork)) AS TotalAllowanceAmount
	
	,SUM(i.HoursToLess)
	FROM paystubitem_sum_semimon_allowance_group_prodid i
	INNER JOIN (SELECT ea.*,MIN(d.DateValue) AS DateRange1,MAX(d.DateValue) AS DateRange2 FROM dates d INNER JOIN employeeallowance ea ON ea.AllowanceFrequency='Semi-monthly' AND TaxableFlag=IsTaxable AND ea.OrganizationID=OrganizID AND d.DateValue BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate WHERE d.DateValue BETWEEN DatePayFrom AND DatePayTo GROUP BY ea.RowID ORDER BY d.DateValue) ii ON i.EmployeeID=ii.EmployeeID AND i.OrganizationID=ii.OrganizationID AND i.`Date` BETWEEN ii.DateRange1 AND ii.DateRange2 AND i.`Fixed`=0 AND ii.TaxableFlag = i.TaxableFlag
	WHERE i.TaxableFlag = IsTaxable
	GROUP BY i.EmployeeID,ii.RowID,ii.ProductID;
	
	
	
	
	
	
	
	
	
ELSEIF AllowanceFrequenzy = 'Semi-monthly version 2' THEN
	SET @day_pay = 0.0;SET @day_pay1 = 0.0;SET @day_pay2 = 0.0;
	SELECT
	et.EmployeeID
	,et.`Date`
	,(SELECT @timediffcount := COMPUTE_TimeDifference(sh.TimeFrom,sh.TimeTo)) AS Equatn
	,(SELECT @timediffcount := IF(@timediffcount < 6,@timediffcount,(@timediffcount - 1.0))) AS timediffcount
	,pr.PayType,ea.AllowanceAmount
	,(et.RegularHoursWorked * (ROUND((ea.AllowanceAmount / (e.WorkDaysPerYear / (PAYFREQUENCY_DIVISOR(pf.PayFrequencyType) * MonthCount))),2) / sh.DivisorToDailyRate)) AS TotalAllowanceAmount
	,es.ShiftID
	FROM employeetimeentry et
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Day'
	INNER JOIN employee e ON e.OrganizationID=OrganizID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
	INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
	INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
	INNER JOIN shift sh ON sh.RowID=es.ShiftID
	INNER JOIN employeeallowance ea ON ea.AllowanceFrequency=AllowanceFrequenzy AND ea.TaxableFlag=IsTaxable AND ea.EmployeeID=e.RowID AND ea.OrganizationID=OrganizID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
	INNER JOIN product p ON p.RowID=ea.ProductID
	WHERE et.OrganizationID=OrganizID AND et.`Date` BETWEEN DatePayFrom AND DatePayTo
UNION ALL
	SELECT
	et.EmployeeID
	,et.`Date`
	,(@day_pay1 := GET_employeerateperday(et.EmployeeID,et.OrganizationID,et.`Date`)) AS Equatn
	,0 AS timediffcount,pr.PayType,ea.AllowanceAmount
	,ROUND((ea.AllowanceAmount / (e.WorkDaysPerYear / (PAYFREQUENCY_DIVISOR(pf.PayFrequencyType) * MonthCount))),2) * ((et.HolidayPayAmount + ((et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) * (@day_pay1 / sh.DivisorToDailyRate))) / @day_pay1) AS TotalAllowanceAmount
	,es.ShiftID
	FROM employeetimeentry et
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Holiday'
	INNER JOIN employee e ON e.OrganizationID=OrganizID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') AND e.CalcHoliday='1'
	INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
	INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
	INNER JOIN shift sh ON sh.RowID=es.ShiftID
	INNER JOIN employeeallowance ea ON ea.AllowanceFrequency=AllowanceFrequenzy AND ea.TaxableFlag=IsTaxable AND ea.EmployeeID=e.RowID AND ea.OrganizationID=OrganizID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
	INNER JOIN product p ON p.RowID=ea.ProductID
	WHERE et.OrganizationID=OrganizID AND et.`Date` BETWEEN DatePayFrom AND DatePayTo
UNION ALL
	SELECT
	et.EmployeeID
	,et.`Date`
	,(@day_pay1 := GET_employeerateperday(et.EmployeeID,et.OrganizationID,et.`Date`)) AS Equatn
	,0 AS timediffcount,pr.PayType,ea.AllowanceAmount
	,ROUND((ea.AllowanceAmount / (e.WorkDaysPerYear / (PAYFREQUENCY_DIVISOR(pf.PayFrequencyType) * MonthCount))),2) * ((et.HolidayPayAmount + ((et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) * (@day_pay1 / sh.DivisorToDailyRate))) / @day_pay1) AS TotalAllowanceAmount
	,es.ShiftID
	FROM employeetimeentry et
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Special Non-Working Holiday'
	INNER JOIN employee e ON e.OrganizationID=OrganizID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') AND e.EmployeeType!='Daily'
	INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
	INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
	INNER JOIN shift sh ON sh.RowID=es.ShiftID
	INNER JOIN employeeallowance ea ON ea.AllowanceFrequency=AllowanceFrequenzy AND ea.TaxableFlag=IsTaxable AND ea.EmployeeID=e.RowID AND ea.OrganizationID=OrganizID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
	INNER JOIN product p ON p.RowID=ea.ProductID
	WHERE et.OrganizationID=OrganizID AND et.RegularHoursAmount=0 AND et.TotalDayPay > 0 AND et.`Date` BETWEEN DatePayFrom AND DatePayTo;
	
ELSE

	SET @day_pay = 0.0;SET @day_pay1 = 0.0;SET @day_pay2 = 0.0;

	SELECT i.*
	FROM 
	(
	SELECT et.RowID
	,et.EmployeeID
	,et.`Date`
	,(SELECT @timediffcount := sh.DivisorToDailyRate # COMPUTE_TimeDifference(sh.TimeFrom,sh.TimeTo)
	  ) AS Equatn
	,(SELECT @timediffcount := sh.DivisorToDailyRate # IF(@timediffcount < 6,@timediffcount,(@timediffcount - 1.0))
	  ) AS timediffcount
	
	,(et.RegularHoursWorked * (ea.AllowanceAmount / sh.DivisorToDailyRate)) AS TotalAllowanceAmount
	,es.ShiftID
	,p.PartNo
	,'1st statement' `Result`
	FROM employeetimeentry et
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Day'
	INNER JOIN employee e ON e.OrganizationID=OrganizID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
	INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
	INNER JOIN shift sh ON sh.RowID=es.ShiftID
	INNER JOIN employeeallowance ea ON ea.AllowanceFrequency=AllowanceFrequenzy AND ea.TaxableFlag=IsTaxable AND ea.EmployeeID=e.RowID AND ea.OrganizationID=OrganizID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
	INNER JOIN product p ON p.RowID=ea.ProductID
									AND p.RowID != ecola_rowid
	WHERE et.OrganizationID=OrganizID AND et.`Date` BETWEEN DatePayFrom AND DatePayTo
UNION
	SELECT et.RowID
	,et.EmployeeID
	,et.`Date`
	,(@day_pay1 := GET_employeerateperday(et.EmployeeID,et.OrganizationID,et.`Date`)) AS Equatn
	,0 AS timediffcount
	,ea.AllowanceAmount * ((et.HolidayPayAmount + ((et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) * (@day_pay1 / sh.DivisorToDailyRate))) / @day_pay1) AS TotalAllowanceAmount
	,es.ShiftID
	,p.PartNo
	,'2nd statement' `Result`
	FROM employeetimeentry et
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Holiday'
	INNER JOIN employee e ON e.OrganizationID=OrganizID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') AND e.CalcHoliday='1'
	INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
	INNER JOIN shift sh ON sh.RowID=es.ShiftID
	INNER JOIN employeeallowance ea ON ea.AllowanceFrequency=AllowanceFrequenzy AND ea.TaxableFlag=IsTaxable AND ea.EmployeeID=e.RowID AND ea.OrganizationID=OrganizID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
	INNER JOIN product p ON p.RowID=ea.ProductID
									#AND p.RowID != ecola_rowid
									AND LOCATE('cola', p.PartNo) > 0
	WHERE et.OrganizationID=OrganizID AND et.`Date` BETWEEN DatePayFrom AND DatePayTo
UNION
	SELECT et.RowID
	,et.EmployeeID
	,et.`Date`
	,(@day_pay1 := GET_employeerateperday(et.EmployeeID,et.OrganizationID,et.`Date`)) AS Equatn
	,0 AS timediffcount
	,ea.AllowanceAmount * ((et.HolidayPayAmount + ((et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) * (@day_pay1 / sh.DivisorToDailyRate))) / @day_pay1) AS TotalAllowanceAmount
	,es.ShiftID
	,p.PartNo
	,'3rd statement' `Result`
	FROM employeetimeentry et
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Special Non-Working Holiday'
	INNER JOIN employee e ON e.OrganizationID=OrganizID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') AND e.CalcSpecialHoliday=1 # e.EmployeeType!='Daily'
	INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
	INNER JOIN shift sh ON sh.RowID=es.ShiftID
	INNER JOIN employeeallowance ea ON ea.AllowanceFrequency=AllowanceFrequenzy AND IF(IsTaxable='1', (ea.TaxableFlag=IsTaxable), FALSE) AND ea.EmployeeID=e.RowID AND ea.OrganizationID=OrganizID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
	INNER JOIN product p ON p.RowID=ea.ProductID
	                        #AND p.RowID != ecola_rowid
									AND LOCATE('cola', p.PartNo) > 0
	WHERE et.OrganizationID=OrganizID AND et.RegularHoursAmount=0 AND et.TotalDayPay > 0 AND et.`Date` BETWEEN DatePayFrom AND DatePayTo
	
UNION
	SELECT et.RowID
	,et.EmployeeID
	,et.`Date`
	,(@timediffcount := sh.DivisorToDailyRate # COMPUTE_TimeDifference(sh.TimeFrom,sh.TimeTo)
	  ) AS Equatn
	,(@timediffcount := sh.DivisorToDailyRate # IF(@timediffcount < 6,@timediffcount,(@timediffcount - 1.0))
	  ) AS timediffcount
	
	,ea.AllowanceAmount `TotalAllowanceAmount`
	,es.ShiftID
	,p.PartNo
	,'4th statement' `Result`
	FROM employeetimeentry et
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Day'
	INNER JOIN employee e ON e.OrganizationID=OrganizID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
	INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
	INNER JOIN shift sh ON sh.RowID=es.ShiftID
	INNER JOIN employeeallowance ea ON ea.AllowanceFrequency=AllowanceFrequenzy AND ea.TaxableFlag=IsTaxable AND ea.EmployeeID=e.RowID AND ea.OrganizationID=OrganizID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
	INNER JOIN product p ON p.RowID=ea.ProductID
									AND p.RowID = ecola_rowid
	WHERE et.OrganizationID=OrganizID AND et.`Date` BETWEEN DatePayFrom AND DatePayTo
	AND et.RegularHoursWorked > 0
	
UNION
	SELECT et.RowID
	,et.EmployeeID
	,et.`Date`
	,0 `Equatn`
	,0 `timediffcount`
	,ea.AllowanceAmount `TotalAllowanceAmount`
	,es.ShiftID
	,p.PartNo
	,'5th statement' `Result`
	FROM employeetimeentry et
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Holiday'
	INNER JOIN employee e ON e.OrganizationID=OrganizID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') AND e.CalcHoliday='1'
	LEFT JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
	                          AND (et.EmployeeShiftID IS NULL OR es.RestDay=1 OR e.DayOfRest=DAYOFWEEK(et.`Date`))
	INNER JOIN employeeallowance ea ON ea.AllowanceFrequency=AllowanceFrequenzy AND ea.TaxableFlag=IsTaxable AND ea.EmployeeID=e.RowID AND ea.OrganizationID=OrganizID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
	INNER JOIN product p ON p.RowID=ea.ProductID
									#AND p.RowID != ecola_rowid
									AND LOCATE('cola', LCASE(p.PartNo)) > 0
	WHERE et.OrganizationID=OrganizID AND et.`Date` BETWEEN DatePayFrom AND DatePayTo
	
	# pay Ecola on leave
UNION
	SELECT et.RowID
	,et.EmployeeID
	,et.`Date`
	,0 `Equatn`
	,0 `timediffcount`
	,IF((et.TotalDayPay / IF(e.EmployeeType='Daily', esa.BasicPay, ((esa.Salary * e.WorkDaysPerYear) / MonthCount))) >= 1
	    , ea.AllowanceAmount
		 , (ea.AllowanceAmount * (et.TotalDayPay / IF(e.EmployeeType='Daily', esa.BasicPay, ((esa.Salary * e.WorkDaysPerYear) / MonthCount))))) `TotalAllowanceAmount`
	
	,es.ShiftID
	,p.PartNo
	,'6th statement' `Result`
	FROM employeetimeentry et
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular day'
	INNER JOIN employee e ON e.OrganizationID=OrganizID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
	INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
	INNER JOIN shift sh ON sh.RowID=es.ShiftID
	INNER JOIN employeeallowance ea ON ea.AllowanceFrequency=AllowanceFrequenzy AND ea.TaxableFlag=IsTaxable AND ea.EmployeeID=e.RowID AND ea.OrganizationID=OrganizID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
	INNER JOIN product p ON p.RowID=ea.ProductID
									AND LOCATE('cola', LCASE(p.PartNo)) > 0
	INNER JOIN employeesalary esa ON esa.RowID=et.EmployeeSalaryID
	WHERE et.OrganizationID=OrganizID AND et.`Date` BETWEEN DatePayFrom AND DatePayTo
	AND (et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) > 0 AND et.TotalDayPay > 0
	
	) i
	GROUP BY i.RowID
	ORDER BY i.EmployeeID, i.`Date`;
	
END IF;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
