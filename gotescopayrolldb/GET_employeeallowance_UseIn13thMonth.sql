/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DELIMITER //
DROP PROCEDURE IF EXISTS `GET_employeeallowance_UseIn13thMonth`;
CREATE PROCEDURE `GET_employeeallowance_UseIn13thMonth`(
	IN `orgId` INT,
	IN `periodId` INT
)
BEGIN

SET @ecoalId=0;

SELECT p.RowID
FROM product p
INNER JOIN category c ON c.RowID = p.CategoryID AND c.CategoryName = 'Allowance Type'
WHERE p.OrganizationID = orgId
AND p.PartNo = 'Ecola'
LIMIT 1
INTO @ecoalId;

SET @dailyFrequency='Daily';
SET @semiMonthlyFrequency='Semi-monthly';
SET @monthlyFrequency='Monthly';
SET @onceFrequency='Once';

SET @datefrom=CURDATE(); SET @dateto=CURDATE();
SET @orgId=orgId;
SET @useIn13thMonth=TRUE;
SET @thismonth=0;
SET @thisyear=0;
SET @isPeriodEndOfMonth=FALSE;
SET @isPeriodFirstHalf=FALSE;
SET @periodHalf=0;

SELECT
pp.PayFromDate, pp.PayToDate, pp.`Month`, pp.`Year`, pp.Half, (pp.Half=0) `IsEndOfMonth`, (pp.Half=1) `IsFirstHalf`
FROM payperiod pp
WHERE pp.RowID=periodId
INTO @datefrom, @dateto, @thismonth, @thisyear, @periodHalf, @isPeriodEndOfMonth, @isPeriodFirstHalf;

SET @preceedingMonth=IF(@thismonth=1 AND @periodHalf=1, 24, @thismonth-1);

/*custom employee*/
SET @sssDeductSched='';

DROP TEMPORARY TABLE IF EXISTS `customemployee1`;
CREATE TEMPORARY TABLE IF NOT EXISTS `customemployee1`
SELECT
e.RowID,e.OrganizationID,e.Salutation,e.FirstName,e.MiddleName,e.LastName,e.Surname,e.TINNo,e.SSSNo,e.HDMFNo,e.PhilHealthNo,e.EmploymentStatus,e.EmailAddress,e.WorkPhone,e.HomePhone,e.MobilePhone,e.HomeAddress,e.Nickname,e.JobTitle,e.Gender,e.EmployeeType,e.MaritalStatus,e.Birthdate,e.StartDate,e.TerminationDate,e.PositionID,e.PayFrequencyID,e.NoOfDependents,e.UndertimeOverride,e.OvertimeOverride,e.NewEmployeeFlag,e.LeaveBalance,e.SickLeaveBalance,e.MaternityLeaveBalance,e.OtherLeaveBalance,e.LeaveAllowance,e.SickLeaveAllowance,e.MaternityLeaveAllowance,e.OtherLeaveAllowance,e.Image,e.LeavePerPayPeriod,e.SickLeavePerPayPeriod,e.MaternityLeavePerPayPeriod,e.OtherLeavePerPayPeriod,e.AlphaListExempted,e.WorkDaysPerYear,e.DayOfRest,e.ATMNo,e.BankName,e.CalcHoliday,e.CalcSpecialHoliday,e.CalcNightDiff,e.CalcNightDiffOT,e.CalcRestDay,e.CalcRestDayOT,e.DateRegularized,e.DateEvaluated,e.RevealInPayroll,e.LateGracePeriod,e.AgencyID,e.OffsetBalance,e.DateR1A,e.AdditionalVLAllowance,e.AdditionalVLBalance,e.AdditionalVLPerPayPeriod,e.LeaveTenthYearService,e.LeaveFifteenthYearService,e.LeaveAboveFifteenthYearService,e.DeptManager,
@sssDeductSched:=IF(e.AgencyID IS NOT NULL, IFNULL(d.SSSDeductSchedAgency,d.SSSDeductSched), d.SSSDeductSched) `SSSDeductSched`,
@sssDeductSched='End of the month' `IsEndOfMonth`,
@sssDeductSched='First half' `IsFirstHalf`,
@sssDeductSched='Per pay period' `IsPerPayPeriod`,

(CASE @sssDeductSched
WHEN 'End of the month' THEN (SELECT pp.PayFromDate FROM payperiod pp WHERE pp.OrganizationID=e.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID AND pp.`Month`=@thismonth AND pp.`Year`=@thisyear AND pp.Half=1 LIMIT 1)
WHEN 'First half' THEN (SELECT pp.PayFromDate FROM payperiod pp WHERE pp.OrganizationID=e.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID AND pp.`Month`=@preceedingMonth AND pp.`Year`=@thisyear AND pp.Half=0 LIMIT 1)
WHEN 'Per pay period' THEN (SELECT @datefrom)
END) `DateFrom`,

(CASE @sssDeductSched
WHEN 'End of the month' THEN (SELECT pp.PayToDate FROM payperiod pp WHERE pp.OrganizationID=e.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID AND pp.`Month`=@thismonth AND pp.`Year`=@thisyear AND pp.Half=0 LIMIT 1)
WHEN 'First half' THEN (SELECT pp.PayToDate FROM payperiod pp WHERE pp.OrganizationID=e.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID AND pp.`Month`=@thismonth AND pp.`Year`=@thisyear AND pp.Half=1 LIMIT 1)
WHEN 'Per pay period' THEN (SELECT @dateto)
END) `DateTo`

FROM employee e
INNER JOIN `position` pos ON pos.RowID=e.PositionID
INNER JOIN division d ON d.RowID=pos.DivisionId
WHERE e.OrganizationID=orgId
;






















/*DAILY*/
DROP TEMPORARY TABLE IF EXISTS `allowancedaily1`;
CREATE TEMPORARY TABLE IF NOT EXISTS `allowancedaily1`
SELECT
i.EmployeeID
,i.`Date`
,0 `Equatn`
,0 `timediffcount`
,pr.PayType
,0 `AllowanceAmount`
,i.TotalAllowanceAmt `TotalAllowanceAmount`
FROM paystubitem_sum_daily_allowance_group_prodid i

INNER JOIN `customemployee1` e ON e.RowID=i.EmployeeID AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
AND IF(e.`IsPerPayPeriod`, TRUE, IF(e.`IsEndOfMonth`=@isPeriodEndOfMonth, TRUE, IF(e.`IsFirstHalf`=@isPeriodFirstHalf, TRUE, FALSE)))

INNER JOIN product p ON p.RowID=i.ProductID AND p.UseIn13thMonth=@useIn13thMonth AND p.RowID NOT IN (@ecoalId)
INNER JOIN employeetimeentry et ON et.EmployeeID=e.RowID AND et.`Date`=i.`Date` AND et.OrganizationID=i.OrganizationID
INNER JOIN payrate pr ON pr.RowID=et.PayRateID
#WHERE i.`Date` BETWEEN @datefrom AND @dateto
WHERE i.`Date` BETWEEN e.`DateFrom` AND e.`DateTo`
AND i.TotalAllowanceAmt > 0
AND i.OrganizationID=@orgId
;

/*SEMI-MONTHLY*/
DROP TEMPORARY TABLE IF EXISTS `allowancesemimonthly1`;
CREATE TEMPORARY TABLE IF NOT EXISTS `allowancesemimonthly1`
SELECT
i.*,
i.AllowanceAmount - TRIM(SUM(i.HoursToLess * (i.DailyAllowance / 8)))+0 `TotalAllowanceAmount`,
#0 `TotalAllowanceAmount`,
pp.RowID `PeriodId`
FROM (SELECT
		x.*,
		e.PayFrequencyID, e.`DateFrom`, e.`DateTo`
		FROM paystubitem_sum_semimon_allowance_group_prodid x
		INNER JOIN product p ON p.RowID=x.ProductID AND p.UseIn13thMonth=@useIn13thMonth AND p.RowID NOT IN (@ecoalId)

		INNER JOIN `customemployee1` e ON e.RowID=x.EmployeeID AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
		AND IF(e.`IsPerPayPeriod`, TRUE, IF(e.`IsEndOfMonth`=@isPeriodEndOfMonth, TRUE, IF(e.`IsFirstHalf`=@isPeriodFirstHalf, TRUE, FALSE)))
		
		WHERE x.OrganizationID = @orgId
		) i

		INNER JOIN payperiod pp ON pp.OrganizationID=i.OrganizationID AND pp.TotalGrossSalary=i.PayFrequencyID AND i.`Date` BETWEEN pp.PayFromDate AND pp.PayToDate
		
#WHERE i.`Date` BETWEEN @datefrom AND @dateto
WHERE i.`Date` BETWEEN i.`DateFrom` AND i.`DateTo`
#GROUP BY i.`PeriodId`, i.EmployeeID, i.ProductID
GROUP BY pp.RowID, i.EmployeeID, i.AllowanceId
;

/*MONTHLY*/
SET @dailyallowanceamount=0.00;
SET @timediffcount=0.00;
SET @monthCount=12;

SELECT
PayFromDate
FROM payperiod
WHERE OrganizationID=@orgId
AND `Month`=@thismonth
AND `Year`=@thisyear
ORDER BY PayFromDate, PayToDate
LIMIT 1
INTO @firstdate;

DROP TEMPORARY TABLE IF EXISTS `allowancemonthly1`;
CREATE TEMPORARY TABLE IF NOT EXISTS `allowancemonthly1`
SELECT
@dailyallowanceamount:=ROUND((ea.AllowanceAmount / (e.WorkDaysPerYear / @monthCount)),2) `DailyAllowance`
,@timediffcount:=COMPUTE_TimeDifference(sh.TimeFrom,sh.TimeTo) `TimeDifference1`
,@timediffcount:=IF(@timediffcount IN (4,5),@timediffcount,(@timediffcount - 1.0)) `TimeDifference2`
,ROUND((@dailyallowanceamount - ( ( (et.HoursLate + et.UndertimeHours) / @timediffcount ) * @dailyallowanceamount )),2) `TotalAllowanceAmount`
,et.EmployeeID
,ea.ProductID
FROM employeetimeentry et

INNER JOIN `customemployee1` e ON e.RowID=et.EmployeeID AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
AND IF(e.`IsPerPayPeriod`, TRUE, IF(e.`IsEndOfMonth`=@isPeriodEndOfMonth, TRUE, IF(e.`IsFirstHalf`=@isPeriodFirstHalf, TRUE, FALSE)))
AND et.`Date` BETWEEN e.`DateFrom` AND e.`DateTo`

INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
INNER JOIN shift sh ON sh.RowID=es.ShiftID
INNER JOIN employeeallowance ea ON ea.AllowanceFrequency=@monthlyFrequency AND ea.EmployeeID=e.RowID AND ea.OrganizationID=@orgId AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
INNER JOIN product p ON p.RowID=ea.ProductID AND p.UseIn13thMonth=@useIn13thMonth AND p.RowID NOT IN (@ecoalId)
#WHERE et.OrganizationID=@orgId AND et.`Date` BETWEEN @firstdate AND @dateto
;

/*ONCE*/
DROP TEMPORARY TABLE IF EXISTS `allowanceonce1`;
CREATE TEMPORARY TABLE IF NOT EXISTS `allowanceonce1`
SELECT SUM(IFNULL(ea.AllowanceAmount,0)) `TotalAllowanceAmount`
,ea.EmployeeID
FROM employeeallowance ea

INNER JOIN `customemployee1` e ON e.RowID=ea.EmployeeID AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
AND IF(e.`IsPerPayPeriod`, TRUE, IF(e.`IsEndOfMonth`=@isPeriodEndOfMonth, TRUE, IF(e.`IsFirstHalf`=@isPeriodFirstHalf, TRUE, FALSE)))
AND ea.EffectiveStartDate BETWEEN e.`DateFrom` AND e.`DateTo`

INNER JOIN product p ON p.RowID=ea.ProductID AND p.UseIn13thMonth=@useIn13thMonth AND p.RowID NOT IN (@ecoalId)
WHERE ea.OrganizationID=@orgId
AND ea.AllowanceFrequency=@onceFrequency
#AND ea.EffectiveStartDate BETWEEN @datefrom AND @dateto
GROUP BY ea.EmployeeID
ORDER BY DATEDIFF(CURDATE(), ea.EffectiveStartDate);

/*TOTAL ALLOWANCE USE IN SSS*/
DROP TEMPORARY TABLE IF EXISTS `totalallowanceusein13thmonth`;
CREATE TEMPORARY TABLE IF NOT EXISTS `totalallowanceusein13thmonth`
SELECT
i.EmployeeID,
SUM(i.TotalAllowanceAmount) `TotalAllowanceAmount`
FROM (SELECT @dailyFrequency `Frequency`, EmployeeID, TotalAllowanceAmount FROM `allowancedaily1`
		UNION
		SELECT @semiMonthlyFrequency `Frequency`, EmployeeID, TotalAllowanceAmount FROM `allowancesemimonthly1`
		UNION
		SELECT @monthlyFrequency `Frequency`, EmployeeID, TotalAllowanceAmount FROM `allowancemonthly1`
		UNION
		SELECT @onceFrequency `Frequency`, EmployeeID, TotalAllowanceAmount FROM `allowanceonce1`
		) i
GROUP BY i.EmployeeID
;

SELECT * FROM `totalallowanceusein13thmonth`;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
