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

-- Dumping structure for function gotescopayrolldb_latest.GENERATE_employeetimeentry
DROP FUNCTION IF EXISTS `GENERATE_employeetimeentry`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `GENERATE_employeetimeentry`(`ete_EmpRowID` INT, `ete_OrganizID` INT, `ete_Date` DATE, `ete_UserRowID` INT) RETURNS int(11)
    DETERMINISTIC
BEGIN

DECLARE returnvalue INT(11);

DECLARE default_work_hrs INT(11) DEFAULT 8;

DECLARE pr_DayBefore DATE;

DECLARE pr_PayType TEXT;

DECLARE isRestDay TEXT;

DECLARE hasTimeLogs TEXT;


DECLARE yester_TotDayPay DECIMAL(11,2);

DECLARE yester_TotHrsWorkd DECIMAL(11,2);


DECLARE ete_RegHrsWorkd DECIMAL(11,6);

DECLARE ete_HrsLate DECIMAL(11,6);

DECLARE ete_HrsUnder DECIMAL(11,6);

DECLARE ete_OvertimeHrs DECIMAL(11,6);

DECLARE ete_NDiffHrs DECIMAL(11,6);

DECLARE ete_NDiffOTHrs DECIMAL(11,6);


DECLARE etd_TimeIn TIME;

DECLARE etd_TimeOut TIME;


DECLARE shifttimefrom TIME;

DECLARE shifttimeto TIME;


DECLARE otstartingtime TIME DEFAULT NULL;

DECLARE otendingtime TIME DEFAULT NULL;

DECLARE og_ndtimefrom TIME DEFAULT NULL;

DECLARE og_ndtimeto TIME DEFAULT NULL;


DECLARE e_EmpStatus TEXT;

DECLARE e_EmpType TEXT;

DECLARE e_MaritStatus TEXT;

DECLARE e_StartDate DATE;

DECLARE e_PayFreqID INT(11);

DECLARE e_NumDependent INT(11);

DECLARE e_UTOverride CHAR(1);

DECLARE e_OTOverride CHAR(1);

DECLARE e_DaysPerYear INT(11);

DECLARE calc_Holiday CHAR(1);

DECLARE e_CalcSpecialHoliday CHAR(1);

DECLARE e_CalcNightDiff CHAR(1);

DECLARE e_CalcNightDiffOT CHAR(1);

DECLARE e_CalcRestDay CHAR(1);

DECLARE e_CalcRestDayOT CHAR(1);


DECLARE yes_true CHAR(8) DEFAULT '0';

DECLARE anytime TIME;

DECLARE anyINT INT(11);


DECLARE rateperhour DECIMAL(11,6);
DECLARE rateperhourforOT DECIMAL(11,6);
DECLARE dailypay DECIMAL(11,6);



DECLARE commonrate DECIMAL(11,6);

DECLARE otrate DECIMAL(11,6);

DECLARE ndiffrate DECIMAL(11,6);

DECLARE ndiffotrate DECIMAL(11,6);

DECLARE restday_rate DECIMAL(11,6);

DECLARE restdayot_rate DECIMAL(11,6);


DECLARE eshRowID INT(11);

DECLARE esalRowID INT(11);

DECLARE payrateRowID INT(11);

DECLARE ete_TotalDayPay DECIMAL(11,6);


DECLARE hasLeave CHAR(1) DEFAULT '0';

DECLARE OTCount INT(11) DEFAULT 0;

DECLARE aftershiftOTRowID INT(11) DEFAULT 0;

DECLARE anotherOTHours DECIMAL(11,6);

DECLARE e_LateGracePeriod DECIMAL(11,2);

DECLARE e_PositionID INT(11);
DECLARE sh_rowID INT(11);

DECLARE default_payrate DECIMAL(11,2) DEFAULT 1.0;

DECLARE default_specholi_payrate DECIMAL(11,2) DEFAULT 1.3;

DECLARE default_regholi_payrate DECIMAL(11,2) DEFAULT 2.0;

DECLARE has_timelogs_onthisdate
        ,is_valid_for_holipayment BOOL DEFAULT FALSE;

SELECT
e.EmploymentStatus
,e.EmployeeType
,e.MaritalStatus
,e.StartDate
,e.PayFrequencyID
,e.NoOfDependents
,e.UndertimeOverride
,e.OvertimeOverride
,e.WorkDaysPerYear
,e.CalcHoliday
,e.CalcSpecialHoliday
,e.CalcNightDiff
,e.CalcNightDiffOT
,e.CalcRestDay
,e.CalcRestDayOT
,e.LateGracePeriod
,e.PositionID,og.NightDifferentialTimeFrom,og.NightDifferentialTimeTo
FROM employee e
INNER JOIN organization og ON og.RowID=e.OrganizationID
WHERE e.RowID=ete_EmpRowID
INTO e_EmpStatus
		,e_EmpType
		,e_MaritStatus
		,e_StartDate
		,e_PayFreqID
		,e_NumDependent
		,e_UTOverride
		,e_OTOverride
		,e_DaysPerYear
		,calc_Holiday
		,e_CalcSpecialHoliday
		,e_CalcNightDiff
		,e_CalcNightDiffOT
		,e_CalcRestDay
		,e_CalcRestDayOT
		,e_LateGracePeriod
		,e_PositionID,og_ndtimefrom,og_ndtimeto;



SELECT
	RowID
	#,IF(PayType = 'Special Non-Working Holiday', IF(e_CalcSpecialHoliday = '1', PayRate, 1), IF(PayType = 'Regular Holiday', IF(calc_Holiday = '1', PayRate, 1), PayRate))
	,IF((pr.PayType = 'Regular Holiday' OR pr.`PayRate` = default_regholi_payrate) AND calc_Holiday = 1
		, IF(IS_WORKINGDAY_PRESENT_DURINGHOLI(ete_OrganizID, ete_EmpRowID, ete_Date, TRUE) = 1
				# AND IS_WORKINGDAY_PRESENT_DURINGHOLI(ete_OrganizID, ete_EmpRowID, ete_Date, FALSE) = 1
				, pr.`PayRate`
				, default_payrate)
		, IF((pr.PayType = 'Special Non-Working Holiday' OR pr.`PayRate` = default_specholi_payrate) AND e_CalcSpecialHoliday = 1
				, pr.`PayRate`
				, default_payrate))
	,IF(e_OTOverride = '1', pr.OvertimeRate, default_payrate)
	,IF(e_CalcNightDiff = '1', pr.NightDifferentialRate, default_payrate)
	,IF(e_CalcNightDiffOT = '1', pr.NightDifferentialOTRate, default_payrate)
	,IF(e_CalcRestDay = '1', pr.RestDayRate, default_payrate)
	,IF(e_CalcRestDayOT = '1', pr.RestDayOvertimeRate, default_payrate)
	,pr.DayBefore
	,pr.PayType
FROM payrate pr
WHERE pr.`Date`=ete_Date
AND pr.OrganizationID=ete_OrganizID
INTO  payrateRowID
		,commonrate
		,otrate
		,ndiffrate
		,ndiffotrate
		,restday_rate
		,restdayot_rate
		,pr_DayBefore
		,pr_PayType;


SELECT IFNULL((RestDay = 1), FALSE)
FROM employeeshift
WHERE EmployeeID=ete_EmpRowID
AND OrganizationID=ete_OrganizID
AND ete_Date BETWEEN EffectiveFrom AND EffectiveTo
AND DATEDIFF(ete_Date,EffectiveFrom) >= 0 AND IFNULL(RestDay,0)=1
ORDER BY DATEDIFF(ete_Date,EffectiveFrom)
LIMIT 1 INTO isRestDay;


SET ete_HrsLate = 0.0;

SET ete_HrsUnder = 0.0;

SET ete_OvertimeHrs = 0.0;

SET ete_NDiffHrs = 0.0;

SET ete_NDiffOTHrs = 0.0;


IF isRestDay IS NULL THEN
	
	SELECT (DAYOFWEEK(ete_Date) = e.DayOfRest)
	FROM employee e
	WHERE e.RowID=ete_EmpRowID
	INTO isRestDay;

END IF;

SELECT EXISTS(SELECT RowID
					FROM employeetimeentrydetails
					WHERE EmployeeID=ete_EmpRowID
					AND `Date`=ete_Date
					AND OrganizationID=ete_OrganizID
					LIMIT 1) `Result`
INTO has_timelogs_onthisdate;

SELECT
COUNT(RowID)
FROM employeeovertime
WHERE EmployeeID=ete_EmpRowID
AND OrganizationID=ete_OrganizID
AND ete_Date
BETWEEN OTStartDate
AND OTEndDate
AND OTStatus='Approved' AND has_timelogs_onthisdate = TRUE
INTO OTCount;





SELECT
sh.TimeFrom
,sh.TimeTo
,esh.RowID	
,sh.RowID
FROM employeeshift esh
INNER JOIN shift sh ON sh.RowID=esh.ShiftID
WHERE esh.EmployeeID=ete_EmpRowID
AND esh.OrganizationID=ete_OrganizID
AND ete_Date BETWEEN esh.EffectiveFrom AND esh.EffectiveTo
ORDER BY DATEDIFF(ete_Date, esh.EffectiveFrom) DESC
LIMIT 1
INTO shifttimefrom
	  ,shifttimeto
	  ,eshRowID
	  ,sh_rowID;
	  
IF OTCount = 1 THEN
	
	SELECT
	IF(eot.OTStartTime = shifttimeto, ADDTIME(shifttimeto,'00:00:01'), eot.OTStartTime)
	,IF(eot.OTEndTime > IF(empIn.TimeOut > empIn.TimeIn, empIn.TimeOut, ADDTIME(empIn.TimeOut, '24:00:00')), empIn.TimeOut, eot.OTEndTime)
	,eot.RowID
	FROM employeeovertime eot INNER JOIN (SELECT etd.TimeOut, etd.TimeIn FROM employeetimeentrydetails etd WHERE etd.EmployeeID=ete_EmpRowID AND etd.OrganizationID=ete_OrganizID AND etd.`Date`=ete_Date LIMIT 1) empIn ON empIn.TimeOut IS NULL OR empIn.TimeOut IS NOT NULL
	WHERE eot.EmployeeID=ete_EmpRowID
	AND eot.OrganizationID=ete_OrganizID
	AND eot.OTStartTime >= shifttimeto
	AND eot.OTStatus='Approved' AND has_timelogs_onthisdate = TRUE
	AND (ete_Date BETWEEN eot.OTStartDate AND eot.OTEndDate)
	ORDER BY eot.OTStartTime DESC
	LIMIT 1
	INTO otstartingtime
		  ,otendingtime
		  ,aftershiftOTRowID;

ELSE
	
	SELECT
	IF(OTStartTime = shifttimeto, ADDTIME(shifttimeto,'00:00:01'), OTStartTime)
	,OTEndTime
	,RowID
	FROM employeeovertime
	WHERE EmployeeID=ete_EmpRowID
	AND OrganizationID=ete_OrganizID
	AND ete_Date
	BETWEEN OTStartDate
	AND COALESCE(OTEndDate,OTStartDate)
	AND OTStatus='Approved' AND has_timelogs_onthisdate = TRUE
	ORDER BY OTStartTime DESC
	LIMIT 1
	INTO otstartingtime
		  ,otendingtime
		  ,aftershiftOTRowID;


END IF;



IF isRestDay = '1' THEN 
	
	SET @var_is_timelogs_betweenbreaktime = FALSE;
	
	SET @is_timelogs_betweenbreaktime = FALSE;
	
	SET @break_hours = 0.00;
	
	SELECT
	etd.TimeIn
	,etd.TimeOut
	,(@var_is_timelogs_betweenbreaktime := ( (CONCAT_DATETIME(etd.`Date`, etd.TimeIn)
												BETWEEN CONCAT_DATETIME(etd.`Date`, sh.BreakTimeFrom) AND CONCAT_DATETIME(etd.`Date`, sh.BreakTimeTo))
											OR (CONCAT_DATETIME(etd.`Date`, etd.TimeOut)
												BETWEEN CONCAT_DATETIME(etd.`Date`, sh.BreakTimeFrom) AND CONCAT_DATETIME(etd.`Date`, sh.BreakTimeTo)) ))
	,IF(sh.RowID IS NULL
		, COMPUTE_TimeDifference(etd.TimeIn, etd.TimeOut)
		, COMPUTE_TimeDifference(IF(CONCAT_DATETIME(etd.`Date`, etd.TimeIn)
											BETWEEN CONCAT_DATETIME(etd.`Date`, sh.BreakTimeFrom) AND CONCAT_DATETIME(etd.`Date`, sh.BreakTimeTo)
											,	sh.BreakTimeTo
											,	IF(CONCAT_DATETIME(etd.`Date`, etd.TimeIn) < CONCAT_DATETIME(etd.`Date`, sh.TimeFrom)
													,	sh.TimeFrom
													,	etd.TimeIn)
											)
		
										,IF(CONCAT_DATETIME(etd.`Date`, etd.TimeOut)
											BETWEEN
											CONCAT_DATETIME(etd.`Date`, sh.BreakTimeFrom) AND CONCAT_DATETIME(etd.`Date`, sh.BreakTimeTo)
											,	sh.BreakTimeFrom
											,	IF(CONCAT_DATETIME(etd.`Date`, etd.TimeOut) > CONCAT_DATETIME(etd.`Date`, sh.TimeTo)
													,	sh.TimeTo
													,	etd.TimeOut)
											)
										)
									- IF(@var_is_timelogs_betweenbreaktime = TRUE, 0, COMPUTE_TimeDifference(sh.BreakTimeFrom, sh.BreakTimeTo))
		) `Result`
	
	, IFNULL(TIMEDIFF(GREATEST(sh.TimeFrom, sh.TimeTo), LEAST(sh.TimeFrom, sh.TimeTo)), 0) `BreakHours`
	
	FROM employeetimeentrydetails etd
	LEFT JOIN employeeshift esh ON esh.EmployeeID=etd.EmployeeID AND esh.OrganizationID=etd.OrganizationID AND etd.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo
	LEFT JOIN shift sh ON sh.RowID=esh.ShiftID
	INNER JOIN organization og ON og.RowID=etd.OrganizationID
	WHERE etd.EmployeeID=ete_EmpRowID
	AND etd.OrganizationID=ete_OrganizID
	AND etd.`Date`=ete_Date
	ORDER BY etd.LastUpd DESC
	LIMIT 1
	INTO etd_TimeIn
	     ,etd_TimeOut
		  ,@is_timelogs_betweenbreaktime
		  ,ete_RegHrsWorkd
		  ,@break_hours;
	
	IF default_work_hrs < ete_RegHrsWorkd THEN SET ete_RegHrsWorkd = default_work_hrs; END IF;
	
	# SELECT ete_RegHrsWorkd, @break_hours INTO OUTFILE 'D:/New Downloads/result.txt';
	
	# SELECT COMPUTE_TimeDifference(etd_TimeIn,etd_TimeOut)
	# INTO ete_RegHrsWorkd;
	
	SET ete_HrsLate = 0.0;
	
	SET ete_HrsUnder = 0.0;

	SET ete_NDiffHrs = 0.0;
	
	SET ete_NDiffOTHrs = 0.0;
	
	IF otstartingtime IS NOT NULL
		AND otendingtime IS NOT NULL THEN
		
		SELECT COMPUTE_TimeDifference(otstartingtime, otendingtime)
		INTO ete_OvertimeHrs;
		
		SET @is_otEndTimeReachedTomorrow = IF(otstartingtime BETWEEN TIME('12:00') AND TIME('23:59:59')
															AND
															otendingtime BETWEEN TIME('00:00') AND TIME('11:59:59')
															,	TRUE
															,	FALSE);
		SET @mins_perhour = 60;
		SET @secs_perminute = 60;
		/*SELECT COMPUTE_TimeDifference(IF(CONCAT_DATETIME(ete_Date, og_ndtimefrom)
													BETWEEN CONCAT_DATETIME(ete_Date, otstartingtime) AND CONCAT_DATETIME(IF(@is_otEndTimeReachedTomorrow = 0, ete_Date, ADDDATE(ete_Date, INTERVAL 1 DAY)), otendingtime)
													,	og_ndtimefrom
													,	NULL
													)
												
												,	otendingtime) `Result`*/
		SET @ot_endtime = IF(@is_otEndTimeReachedTomorrow = TRUE
									, CONCAT_DATETIME(ADDDATE(ete_Date, INTERVAL 1 DAY), otendingtime)
									, CONCAT_DATETIME(ete_Date, otendingtime));
		
		SELECT
		IF(CONCAT_DATETIME(ete_Date, otstartingtime) <= CONCAT_DATETIME(ete_Date, og_ndtimefrom)
			AND @ot_endtime
					BETWEEN	CONCAT_DATETIME(ete_Date, og_ndtimefrom)
					AND 		CONCAT_DATETIME(ADDDATE(ete_Date, INTERVAL 1 DAY), og_ndtimeto)
			, (TIMESTAMPDIFF(SECOND, CONCAT_DATETIME(ete_Date, og_ndtimefrom), @ot_endtime) / (@mins_perhour * @secs_perminute))
			
			,IF(@ot_endtime >= CONCAT_DATETIME(ADDDATE(ete_Date, INTERVAL 1 DAY), og_ndtimeto)
				 AND CONCAT_DATETIME(ete_Date, otstartingtime)
				 		BETWEEN	CONCAT_DATETIME(ete_Date, og_ndtimefrom)
						AND 		CONCAT_DATETIME(ADDDATE(ete_Date, INTERVAL 1 DAY), og_ndtimeto)
				, (TIMESTAMPDIFF(SECOND, CONCAT_DATETIME(ete_Date, otstartingtime), CONCAT_DATETIME(ADDDATE(ete_Date, INTERVAL 1 DAY), og_ndtimeto)) / (@mins_perhour * @secs_perminute))
				
				, (TIMESTAMPDIFF(SECOND, CONCAT_DATETIME(ete_Date, otstartingtime), @ot_endtime) / (@mins_perhour * @secs_perminute)))
			) `Result`
		INTO ete_NDiffHrs;
		# og_ndtimefrom, og_ndtimeto
	ELSE
		
		SET ete_OvertimeHrs = 0.0;
		
	END IF;
	
ELSE 

	SELECT
	etd.TimeIn
	,IF(e_UTOverride = 1, etd.TimeOut, IFNULL(sh.TimeTo,etd.TimeOut))
	FROM employeetimeentrydetails etd
	LEFT JOIN employeeshift esh ON esh.OrganizationID=etd.OrganizationID AND esh.EmployeeID=etd.EmployeeID AND etd.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo
	LEFT JOIN shift sh ON sh.RowID=esh.ShiftID
	WHERE etd.EmployeeID=ete_EmpRowID
	AND etd.OrganizationID=ete_OrganizID
	AND etd.`Date`=ete_Date
	LIMIT 1
	INTO etd_TimeIn
	     ,etd_TimeOut;
	
	SELECT GRACE_PERIOD(etd_TimeIn, shifttimefrom, e_LateGracePeriod)
	INTO etd_TimeIn;
	
	IF otstartingtime IS NULL
		AND otstartingtime IS NULL THEN
		
		IF IF(HOUR(etd_TimeOut) = 00, ADDTIME(etd_TimeOut,'24:00'), etd_TimeOut) > shifttimeto THEN
	
			SELECT COMPUTE_TimeDifference(etd_TimeIn,shifttimeto)
			INTO ete_RegHrsWorkd;
			
			SET etd_TimeOut = shifttimeto;
			
		ELSE
		
			SELECT COMPUTE_TimeDifference(etd_TimeIn,etd_TimeOut)
			INTO ete_RegHrsWorkd;
			
			IF shifttimeto > etd_TimeOut THEN
			
				SET ete_HrsUnder = COMPUTE_TimeDifference(etd_TimeOut,shifttimeto);
			
			END IF;
			
		END IF;
		
		SET otstartingtime = '12:00:00'; 
		
		SET otendingtime = '12:00:00'; 

		SELECT COMPUTE_TimeDifference(otstartingtime, otendingtime)
		INTO ete_OvertimeHrs;
			
	ELSE 
		 
		SELECT COMPUTE_TimeDifference(otstartingtime, etd_TimeOut)
		INTO ete_OvertimeHrs;
	
		IF TIME_FORMAT(otstartingtime,'%p') = 'PM'
			AND TIME_FORMAT(otendingtime,'%p') = 'AM'
			AND TIME_FORMAT(etd_TimeOut,'%p') = 'AM' THEN 
	
			SELECT COMPUTE_TimeDifference(etd_TimeIn,shifttimeto)
			INTO ete_RegHrsWorkd;
		
			IF ADDTIME(etd_TimeOut,'24:00') BETWEEN otstartingtime AND ADDTIME(otendingtime,'24:00') THEN
			
				SELECT COMPUTE_TimeDifference(otstartingtime, etd_TimeOut)
				INTO ete_OvertimeHrs;
				
				SET etd_TimeOut = SUBTIME(otstartingtime, '00:00:01');
				
			ELSEIF etd_TimeOut > otendingtime THEN
			
				SELECT COMPUTE_TimeDifference(otstartingtime, otendingtime)
				INTO ete_OvertimeHrs;
		
				SET etd_TimeOut = SUBTIME(otstartingtime,'00:00:01');
				
			ELSE
			
				SELECT COMPUTE_TimeDifference(otstartingtime, etd_TimeOut)
				INTO ete_OvertimeHrs;
		
				SET ete_OvertimeHrs = ete_OvertimeHrs - COMPUTE_TimeDifference(otendingtime,etd_TimeOut);
				
				SET etd_TimeOut = SUBTIME(otstartingtime,'00:00:01');
				
			END IF;
		
		ELSEIF TIME_FORMAT(otstartingtime,'%p') = 'PM'
				 AND TIME_FORMAT(otendingtime,'%p') = 'AM'
				 AND TIME_FORMAT(etd_TimeOut,'%p') = 'PM' THEN

			SELECT COMPUTE_TimeDifference(etd_TimeIn,shifttimeto)
			INTO ete_RegHrsWorkd;
			
			/*SELECT COMPUTE_TimeDifference(otstartingtime, otendingtime)
			INTO ete_OvertimeHrs;
		
			IF etd_TimeOut BETWEEN otstartingtime AND ADDTIME(otendingtime,'24:00') THEN
			
				SELECT COMPUTE_TimeDifference(etd_TimeIn,SUBTIME(otstartingtime,'00:00:01'))
				INTO ete_RegHrsWorkd;
				
			ELSEIF etd_TimeOut < shifttimeto THEN
			
				SELECT COMPUTE_TimeDifference(etd_TimeIn,etd_TimeOut)
				INTO ete_RegHrsWorkd;
				
				SELECT COMPUTE_TimeDifference(otstartingtime, otendingtime)
				INTO ete_OvertimeHrs;
		
			
			
				
				
				
			END IF;*/
			
			SET @sec_per_hour = 3600;
			
			SET @proper_ot_endtime_stamp = IF(CONCAT_DATETIME(ADDDATE(ete_Date, INTERVAL IS_TIMERANGE_REACHTOMORROW(otstartingtime, otendingtime) DAY), otendingtime) > CONCAT_DATETIME(ADDDATE(ete_Date, INTERVAL IS_TIMERANGE_REACHTOMORROW(etd_TimeIn, etd_TimeOut) DAY), etd_TimeOut)
			                                  , CONCAT_DATETIME(ADDDATE(ete_Date, INTERVAL IS_TIMERANGE_REACHTOMORROW(etd_TimeIn, etd_TimeOut) DAY), etd_TimeOut)
			                                  , CONCAT_DATETIME(ADDDATE(ete_Date, INTERVAL IS_TIMERANGE_REACHTOMORROW(otstartingtime, otendingtime) DAY), otendingtime));
			
			SET ete_OvertimeHrs = (TIMESTAMPDIFF(SECOND
			                                     ,CONCAT_DATETIME(ete_Date, otstartingtime)
			                                     ,@proper_ot_endtime_stamp) / @sec_per_hour);
			
			IF ete_OvertimeHrs IS NULL OR ete_OvertimeHrs < 0 THEN SET ete_OvertimeHrs = 0; END IF;
			
		ELSEIF TIME_FORMAT(otstartingtime,'%p') = 'AM'
				 AND TIME_FORMAT(otendingtime,'%p') = 'PM'
				 AND TIME_FORMAT(etd_TimeOut,'%p') = 'PM' THEN
		
			SELECT COMPUTE_TimeDifference(etd_TimeIn, IF(etd_TimeOut > shifttimeto, shifttimeto, etd_TimeOut))
			INTO ete_RegHrsWorkd; 
			
			SELECT COMPUTE_TimeDifference(otstartingtime, otendingtime)
			INTO ete_OvertimeHrs;
	
		ELSEIF TIME_FORMAT(otstartingtime,'%p') = 'AM'
				 AND TIME_FORMAT(otendingtime,'%p') = 'PM'
				 AND TIME_FORMAT(etd_TimeOut,'%p') = 'AM' THEN

			SELECT COMPUTE_TimeDifference(etd_TimeIn, IF(etd_TimeOut > shifttimeto, shifttimeto, etd_TimeOut))
			INTO ete_RegHrsWorkd;
			
			IF (etd_TimeIn < otstartingtime AND etd_TimeIn < otendingtime) THEN
			
				SET ete_OvertimeHrs = 0;
		
			ELSEIF etd_TimeOut BETWEEN shifttimeto AND otendingtime THEN
			
				SELECT COMPUTE_TimeDifference(otstartingtime, etd_TimeOut)
				INTO ete_OvertimeHrs;
		
			ELSEIF etd_TimeOut > otendingtime THEN
		
				SELECT COMPUTE_TimeDifference(otstartingtime, otendingtime)
				INTO ete_OvertimeHrs;
		
			END IF;
				
		ELSEIF TIME_FORMAT(otstartingtime,'%p') = 'PM'
				 AND TIME_FORMAT(otendingtime,'%p') = 'PM'
				 AND TIME_FORMAT(etd_TimeOut,'%p') = 'AM' THEN

			SELECT COMPUTE_TimeDifference(etd_TimeIn, IF(etd_TimeOut > shifttimeto, shifttimeto, etd_TimeOut))
			INTO ete_RegHrsWorkd;
			
			IF DATE_FORMAT(etd_TimeOut, '%H') = '00' THEN
			
				IF (DATE_FORMAT(etd_TimeOut, '24:%i:%s') > otstartingtime AND DATE_FORMAT(etd_TimeOut, '24:%i:%s') > otendingtime) THEN 
				
					SELECT COMPUTE_TimeDifference(otstartingtime, otendingtime)
					INTO ete_OvertimeHrs;
			
					SET etd_TimeOut = SUBTIME(otstartingtime,'00:00:01');
							
					SELECT COMPUTE_TimeDifference(etd_TimeIn, etd_TimeOut)
					INTO ete_RegHrsWorkd;
					
				ELSE
					SET ete_OvertimeHrs = 0.0;
					
				END IF;
			
			ELSE
		
				IF (etd_TimeOut > otstartingtime AND etd_TimeOut > otendingtime) THEN 
				
					SELECT COMPUTE_TimeDifference(otstartingtime, otendingtime)
					INTO ete_OvertimeHrs;
			
					SET etd_TimeOut = SUBTIME(otstartingtime,'00:00:01');
							
					SELECT COMPUTE_TimeDifference(etd_TimeIn, etd_TimeOut)
					INTO ete_RegHrsWorkd;
					
				ELSE
					SET ete_OvertimeHrs = 0.0;
					
					SELECT COMPUTE_TimeDifference(otstartingtime, otendingtime)
					INTO ete_OvertimeHrs;
			
				END IF;
			
			END IF;
										
		ELSE
		
			IF TIME_FORMAT(otstartingtime,'%p') = 'PM'
					 AND TIME_FORMAT(otendingtime,'%p') = 'AM' THEN
				
				IF etd_TimeOut BETWEEN otstartingtime AND ADDTIME(otendingtime,'24:00') THEN
				
					SELECT COMPUTE_TimeDifference(etd_TimeIn,SUBTIME(otstartingtime,'00:00:01'))
					INTO ete_RegHrsWorkd;
			
					IF COMPUTE_TimeDifference(otendingtime, etd_TimeOut) > 0 THEN
					
						SELECT COMPUTE_TimeDifference(otstartingtime, etd_TimeOut)
						INTO ete_OvertimeHrs;
						
					ELSE
						
						SELECT COMPUTE_TimeDifference(otstartingtime, otendingtime)
						INTO ete_OvertimeHrs;
						
					END IF;
			
				ELSE
					
					IF etd_TimeOut > shifttimeto THEN
						
						SELECT COMPUTE_TimeDifference(etd_TimeIn,shifttimeto)
						INTO ete_RegHrsWorkd;
						
					ELSE
					
						SELECT COMPUTE_TimeDifference(etd_TimeIn,etd_TimeOut)
						INTO ete_RegHrsWorkd;
						
					END IF;
					
				END IF;
				
			ELSE
			
				IF etd_TimeOut BETWEEN otstartingtime AND otendingtime THEN
				
					
					SELECT COMPUTE_TimeDifference(etd_TimeIn,shifttimeto)
					INTO ete_RegHrsWorkd;
				
					SELECT COMPUTE_TimeDifference(otstartingtime, etd_TimeOut)
					INTO ete_OvertimeHrs;
				
					SET etd_TimeOut = shifttimeto;
				
				ELSE
				
					IF shifttimefrom > otendingtime THEN
						
						SELECT COMPUTE_TimeDifference(etd_TimeIn,etd_TimeOut)
						INTO ete_RegHrsWorkd; 
						
						SET ete_RegHrsWorkd = ete_RegHrsWorkd - COMPUTE_TimeDifference(shifttimeto,etd_TimeOut);
						
						SELECT COMPUTE_TimeDifference(otstartingtime, otendingtime)
						INTO ete_OvertimeHrs;
					
					ELSEIF etd_TimeOut < otstartingtime AND etd_TimeOut < otendingtime THEN
					
						SELECT COMPUTE_TimeDifference(etd_TimeIn,shifttimeto)
						INTO ete_RegHrsWorkd;
						
						SET ete_OvertimeHrs = 0;
						
					ELSEIF etd_TimeOut < otstartingtime THEN
					
						SELECT COMPUTE_TimeDifference(etd_TimeIn,etd_TimeOut)
						INTO ete_RegHrsWorkd;
						
						SET ete_OvertimeHrs = 0;
						
					ELSE
				
						SELECT COMPUTE_TimeDifference(etd_TimeIn,shifttimeto)
						INTO ete_RegHrsWorkd;
						
						
						SELECT COMPUTE_TimeDifference(otstartingtime, otendingtime)
						INTO ete_OvertimeHrs;
						
						SET etd_TimeOut = SUBTIME(otstartingtime, '00:00:01');
					
					END IF;
					
				END IF;
				
			END IF;
			
		END IF;
			
	END IF;

	IF etd_TimeIn > shifttimefrom THEN
	
		SELECT COMPUTE_TimeDifference(shifttimefrom, etd_TimeIn)
		INTO ete_HrsLate;

	ELSE
	
		SELECT COMPUTE_TimeDifference(etd_TimeIn, shifttimefrom)
		INTO ete_HrsLate;

	END IF;
		
	IF etd_TimeOut < shifttimeto THEN
	
		SELECT COMPUTE_TimeDifference(etd_TimeOut, shifttimeto)
		INTO ete_HrsUnder;
		
	END IF;
		
	SET ete_NDiffHrs = 0.0;
	
	SET ete_NDiffOTHrs = 0.0;
	
END IF;


SELECT GET_employeerateperday(ete_EmpRowID, ete_OrganizID, ete_Date)
INTO dailypay;

SET rateperhour = COMPUTE_TimeDifference(shifttimefrom, shifttimeto);

IF rateperhour IS NULL THEN
	SET rateperhour = 9;
	
END IF;

IF rateperhour > 4 THEN
	SET rateperhour = rateperhour - 1;

ELSEIF IFNULL(rateperhour,0) = 0 THEN 
	SET rateperhour = 8;
	
END IF;
SET rateperhour = IFNULL((SELECT DivisorToDailyRate FROM shift WHERE RowID=sh_rowID),8);
SET rateperhourforOT = rateperhour;SET rateperhour = dailypay / rateperhour;

SET rateperhourforOT =  dailypay / (SELECT DivisorToDailyRate FROM shift WHERE RowID=sh_rowID AND DivisorToDailyRate != rateperhourforOT);
IF IFNULL(rateperhourforOT,0) <= 0 THEN
	SET rateperhourforOT = rateperhour;
END IF;

SELECT
RowID
FROM employeetimeentry
WHERE EmployeeID=ete_EmpRowID
AND OrganizationID=ete_OrganizID
AND `Date`=ete_Date
LIMIT 1
INTO anyINT;


SELECT
RowID
FROM employeesalary
WHERE EmployeeID=ete_EmpRowID
AND OrganizationID=ete_OrganizID
AND ete_Date BETWEEN DATE(COALESCE(EffectiveDateFrom, DATE_FORMAT(CURRENT_TIMESTAMP(),'%Y-%m-%d'))) AND DATE(COALESCE(EffectiveDateTo,ete_Date))
AND DATEDIFF(ete_Date,EffectiveDateFrom) >= 0
ORDER BY DATEDIFF(DATE_FORMAT(ete_Date,'%Y-%m-%d'),EffectiveDateFrom)
LIMIT 1
INTO esalRowID;



IF ete_RegHrsWorkd IS NULL THEN
	SET ete_RegHrsWorkd = 0;
END IF;

IF isRestDay = '0' THEN

	IF (ete_RegHrsWorkd > 4 AND ete_RegHrsWorkd < 5) AND COMPUTE_TimeDifference(shifttimefrom, shifttimeto) = 9 THEN
		SET ete_RegHrsWorkd = 4;
		
	ELSEIF (ete_RegHrsWorkd > 5 AND ete_RegHrsWorkd < 6) AND COMPUTE_TimeDifference(shifttimefrom, shifttimeto) = 10 THEN
		SET ete_RegHrsWorkd = 5;
		
	ELSEIF ete_RegHrsWorkd > 4 AND COMPUTE_TimeDifference(shifttimefrom, shifttimeto) = 9 THEN
		SET ete_RegHrsWorkd = ete_RegHrsWorkd - 1;
		
	ELSEIF ete_RegHrsWorkd > 5 AND COMPUTE_TimeDifference(shifttimefrom, shifttimeto) = 10 THEN
		SET ete_RegHrsWorkd = ete_RegHrsWorkd - 1;
		
	END IF;

END IF;
	

IF ete_HrsLate IS NULL THEN
	SET ete_HrsLate = 0;
END IF;


IF ete_HrsLate > 4 AND COMPUTE_TimeDifference(shifttimefrom, shifttimeto) = 9 THEN
	SET ete_HrsLate = COMPUTE_TimeDifference(SUBTIME(shifttimeto,'04:00'), shifttimeto);

ELSEIF ete_HrsLate > 5 AND COMPUTE_TimeDifference(shifttimefrom, shifttimeto) = 10 THEN
	SET ete_HrsLate = COMPUTE_TimeDifference(SUBTIME(shifttimeto,'05:00'), shifttimeto);

END IF;


IF ete_HrsUnder IS NULL THEN
	SET ete_HrsUnder = 0;
END IF;

IF ete_HrsUnder > 4 AND COMPUTE_TimeDifference(shifttimefrom, shifttimeto) = 9 THEN
	SET ete_HrsUnder = COMPUTE_TimeDifference(SUBTIME(shifttimeto,'04:00'), shifttimeto);

ELSEIF ete_HrsUnder > 5 AND COMPUTE_TimeDifference(shifttimefrom, shifttimeto) = 10 THEN
	SET ete_HrsUnder = COMPUTE_TimeDifference(SUBTIME(shifttimeto,'05:00'), shifttimeto);

END IF;

IF ete_OvertimeHrs IS NULL THEN
	SET ete_OvertimeHrs = 0;
END IF;

IF ete_NDiffHrs IS NULL THEN
	SET ete_NDiffHrs = 0;
END IF;

IF ete_NDiffOTHrs IS NULL THEN
	SET ete_NDiffOTHrs = 0;
END IF;



	SET @etd_in = NULL; SET @etd_out = NULL;

	SELECT
	etd.TimeIn
	,IF(e_UTOverride = 1, etd.TimeOut, IFNULL(sh.TimeTo,etd.TimeOut))
	FROM employeetimeentrydetails etd
	LEFT JOIN employeeshift esh ON esh.OrganizationID=etd.OrganizationID AND esh.EmployeeID=etd.EmployeeID AND etd.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo
	LEFT JOIN shift sh ON sh.RowID=esh.ShiftID
	WHERE etd.EmployeeID=ete_EmpRowID
	AND etd.OrganizationID=ete_OrganizID
	AND etd.`Date`=ete_Date
	ORDER BY IFNULL(etd.LastUpd, etd.Created) DESC
	LIMIT 1
	INTO @etd_in
	     ,@etd_out;
	
	SET @proper_date_in = ete_Date; SET @proper_date_out = ete_Date;
	
	IF IS_TIMERANGE_REACHTOMORROW(@etd_in, @etd_out) = TRUE THEN
		SET @proper_date_out = ADDDATE(ete_Date, INTERVAL 1 DAY);
		
	END IF;
	
	SET @etd_login = CONCAT_DATETIME(@proper_date_in, @etd_in);
	SET @etd_logout = CONCAT_DATETIME(@proper_date_out, @etd_out);
		
	SET @secs_per_hour = (60 * 60); # sixty seconds times sixty minutes

IF IFNULL(OTCount,0) > 1 THEN
	
	SELECT
   (TIMESTAMPDIFF(SECOND
	               , IF(@etd_login > CONCAT_DATETIME(ete_Date, eot.OTStartTime)
					        , @etd_login
						 	 , CONCAT_DATETIME(ete_Date, eot.OTStartTime))
					   , CONCAT_DATETIME(ADDDATE(ete_Date, INTERVAL IS_TIMERANGE_REACHTOMORROW(eot.OTStartTime, eot.OTEndTime) DAY), eot.OTEndTime)) / @secs_per_hour) `Resultt`
	FROM employeeovertime eot
	WHERE eot.EmployeeID=ete_EmpRowID
	AND eot.OrganizationID=ete_OrganizID
	AND ete_Date
	BETWEEN eot.OTStartDate
	AND COALESCE(eot.OTEndDate,eot.OTStartDate)
	AND eot.OTStatus='Approved' AND has_timelogs_onthisdate = TRUE
	AND eot.RowID!=aftershiftOTRowID
	LIMIT 1
	INTO anotherOTHours;
	
	IF anotherOTHours IS NULL
	   OR anotherOTHours < 0 THEN
		
		SET anotherOTHours = 0.0;
	END IF;
	
	SET ete_OvertimeHrs = ete_OvertimeHrs + anotherOTHours;
	
ELSEIF IFNULL(OTCount,0) = 1 && ete_OvertimeHrs = 0 THEN
	
	SET @valid_ndiffhrs = 0.00;
	
	SET @eot_rowid = NULL;
	
	SELECT
   (TIMESTAMPDIFF(SECOND
	               , IF(@etd_login > CONCAT_DATETIME(ete_Date, eot.OTStartTime)
					        , @etd_login
						 	 , CONCAT_DATETIME(ete_Date, eot.OTStartTime))
					   , CONCAT_DATETIME(ADDDATE(ete_Date, INTERVAL IS_TIMERANGE_REACHTOMORROW(eot.OTStartTime, eot.OTEndTime) DAY), eot.OTEndTime)) / @secs_per_hour) `Resultt`
	/*,COMPUTE_TimeDifference(OTStartTime
							, IF((OTEndTime <= og.NightDifferentialTimeTo OR OTEndTime <= shifttimefrom), OTEndTime, IF(shifttimefrom > og.NightDifferentialTimeTo, shifttimefrom, og.NightDifferentialTimeTo)))*/
	,IF(ADDTIME(TIMESTAMP(eot.OTStartDate), og.NightDifferentialTimeTo)
		BETWEEN
		ADDTIME(TIMESTAMP(eot.OTStartDate), eot.OTStartTime)
		AND ADDTIME(TIMESTAMP(eot.OTStartDate)
						, IF(TIME_FORMAT(eot.OTEndTime, '%H:%i') = TIME_FORMAT(shifttimefrom, '%H:%i'), TIME(SUBTIME(shifttimefrom, '00:00:01')), OTEndTime))
		
		, COMPUTE_TimeDifference(eot.OTStartTime, og.NightDifferentialTimeTo)
		, COMPUTE_TimeDifference(eot.OTStartTime
										, IF((eot.OTEndTime <= og.NightDifferentialTimeTo OR eot.OTEndTime <= shifttimefrom)
												, eot.OTEndTime
												, IF(shifttimefrom > og.NightDifferentialTimeTo, shifttimefrom, og.NightDifferentialTimeTo)))) `Result`
	FROM employeeovertime eot
	INNER JOIN organization og ON og.RowID=eot.OrganizationID
	WHERE eot.EmployeeID=ete_EmpRowID
	AND eot.OrganizationID=ete_OrganizID
	AND eot.OTStatus='Approved' AND has_timelogs_onthisdate = TRUE
	AND ete_Date BETWEEN eot.OTStartDate AND eot.OTStartDate
	AND eot.RowID!=aftershiftOTRowID
	LIMIT 1
	INTO anotherOTHours,@valid_ndiffhrs;
	
	IF anotherOTHours IS NULL
	   OR anotherOTHours < 0 THEN
		
		SET anotherOTHours = 0.0;
	END IF;
	
	SET ete_OvertimeHrs = ete_OvertimeHrs + anotherOTHours;
	
END IF;


IF pr_DayBefore IS NULL THEN

	

	SELECT
	IFNULL(TotalDayPay,0)
	,IFNULL(TotalHoursWorked,0)
	FROM employeetimeentry
	WHERE EmployeeID=ete_EmpRowID
	AND OrganizationID=ete_OrganizID
	AND `Date`=ete_Date
	INTO yester_TotDayPay
		  ,yester_TotHrsWorkd; 

	IF yester_TotDayPay IS NULL THEN
		SET yester_TotDayPay = 0;
		
	END IF;
		
	IF ete_Date < e_StartDate THEN 
		

				
		SET ete_TotalDayPay = 0.0;
									 
		SELECT INSUPD_employeetimeentries(
				anyINT
				, ete_OrganizID
				, ete_UserRowID
				, ete_UserRowID
				, ete_Date
				, eshRowID
				, ete_EmpRowID
				, esalRowID
				, '0'
				, ete_RegHrsWorkd
				, ete_OvertimeHrs
				, ete_HrsUnder
				, ete_NDiffHrs
				, ete_NDiffOTHrs
				, ete_HrsLate
				, payrateRowID
				, ete_TotalDayPay
				, 0
				, 0
				, 0
				, 0
				, 0
				, 0
				, 0
		) INTO anyINT;
		

	ELSEIF yester_TotDayPay = 0 THEN


		
		IF isRestDay = '1' THEN
		
			SET ete_TotalDayPay = ((ete_RegHrsWorkd * rateperhour) * commonrate)
										 + ((ete_OvertimeHrs * rateperhourforOT) * otrate);
										 
			SELECT INSUPD_employeetimeentries(
					anyINT
					, ete_OrganizID
					, ete_UserRowID
					, ete_UserRowID
					, ete_Date
					, eshRowID
					, ete_EmpRowID
					, esalRowID
					, '0'
					, ete_RegHrsWorkd
					, ete_OvertimeHrs
					, ete_HrsUnder
					, ete_NDiffHrs
					, ete_NDiffOTHrs
					, ete_HrsLate
					, payrateRowID
					, ete_TotalDayPay
					, ete_RegHrsWorkd + ete_OvertimeHrs
					, ((ete_RegHrsWorkd - ete_NDiffHrs) * rateperhour) * ((commonrate + restday_rate) - 1)
					, (ete_OvertimeHrs * rateperhourforOT) * ((commonrate + restdayot_rate) - 1)
					, (ete_HrsUnder * rateperhour)
					, (ete_NDiffHrs * rateperhour) * ndiffrate
					, (ete_NDiffOTHrs * rateperhour) * ndiffotrate
					, (ete_HrsLate * rateperhour)
			) INTO anyINT;
			
			
		ELSEIF isRestDay = '0' THEN
		
			IF ete_RegHrsWorkd = 0 THEN
			
				SET ete_TotalDayPay = 0;
				
			ELSE
				
				
					
				SET ete_TotalDayPay = ((ete_RegHrsWorkd * rateperhour) * commonrate)
				                    	 + ((ete_OvertimeHrs * rateperhourforOT) * otrate);
					
			END IF;
									 
			SELECT INSUPD_employeetimeentries(
					anyINT
					, ete_OrganizID
					, ete_UserRowID
					, ete_UserRowID
					, ete_Date
					, eshRowID
					, ete_EmpRowID
					, esalRowID
					, '0'
					, ete_RegHrsWorkd
					, ete_OvertimeHrs
					, ete_HrsUnder
					, ete_NDiffHrs
					, ete_NDiffOTHrs
					, ete_HrsLate
					, payrateRowID
					, ete_TotalDayPay
					, ete_RegHrsWorkd + ete_OvertimeHrs
					, ((ete_RegHrsWorkd - ete_NDiffHrs) * rateperhour) * commonrate
					, (ete_OvertimeHrs * rateperhourforOT) * otrate
					, (ete_HrsUnder * rateperhour)
					, (ete_NDiffHrs * rateperhour) * ndiffrate
					, (ete_NDiffOTHrs * rateperhour) * ndiffotrate
					, (ete_HrsLate * rateperhour)
			) INTO anyINT;
			

		END IF;
	
	ELSE

			
		
		SELECT CAST(EXISTS(
		SELECT
		elv.RowID
		FROM employeeleave elv
		WHERE elv.EmployeeID=ete_EmpRowID AND elv.`Status`='Approved'
		AND elv.OrganizationID=ete_OrganizID
		AND ete_Date BETWEEN elv.LeaveStartDate AND elv.LeaveEndDate
		LIMIT 1) AS CHAR) 'CharResult'
		INTO hasLeave;

		
		IF hasLeave = '0' THEN
	
			
			
			IF isRestDay = '1' THEN

				IF ete_RegHrsWorkd = 140 THEN # IF ete_RegHrsWorkd > 8 THEN
					SET ete_RegHrsWorkd = 8;
				
				END IF;

				/*SET ete_TotalDayPay = ((ete_RegHrsWorkd * rateperhour) * ((commonrate + restday_rate) - 1))
											 + ((ete_OvertimeHrs * rateperhourforOT) * restdayot_rate);*/#(otrate * restdayot_rate)#((otrate + restdayot_rate) - 1))
				
				SET ete_TotalDayPay =	((ete_RegHrsWorkd * rateperhour) * restday_rate)
												+ (ete_OvertimeHrs * rateperhourforOT) * restdayot_rate
												+ (ete_NDiffHrs * rateperhour) * ndiffrate;
											 
				SET ete_HrsLate = 0.0;

SET yes_true = 1;

				SELECT INSUPD_employeetimeentries(
						anyINT
						, ete_OrganizID
						, ete_UserRowID
						, ete_UserRowID
						, ete_Date
						, eshRowID
						, ete_EmpRowID
						, esalRowID
						, '0'
						, ete_RegHrsWorkd
						, ete_OvertimeHrs
						, ete_HrsUnder
						, ete_NDiffHrs
						, ete_NDiffOTHrs
						, ete_HrsLate
						, payrateRowID
						, ete_TotalDayPay
						, ete_RegHrsWorkd + ete_OvertimeHrs
						, (ete_RegHrsWorkd * rateperhour) * restday_rate#((commonrate + restday_rate) - 1)
						, (ete_OvertimeHrs * rateperhourforOT) * restdayot_rate# (otrate * restdayot_rate)# ((otrate + restdayot_rate) - 1)
						, (ete_HrsUnder * rateperhour)
						, (ete_NDiffHrs * rateperhour) * ndiffrate
						, (ete_NDiffOTHrs * rateperhour) * ndiffotrate
						, (ete_HrsLate * rateperhour)
				) INTO anyINT;
				
			ELSE
			
				SET ete_TotalDayPay = ((ete_RegHrsWorkd * rateperhour) * commonrate)
											 + ((ete_OvertimeHrs * rateperhourforOT) * otrate);
											 
											 
				SELECT INSUPD_employeetimeentries(
						anyINT
						, ete_OrganizID
						, ete_UserRowID
						, ete_UserRowID
						, ete_Date
						, eshRowID
						, ete_EmpRowID
						, esalRowID
						, '0'
						, ete_RegHrsWorkd
						, ete_OvertimeHrs
						, ete_HrsUnder
						, ete_NDiffHrs
						, ete_NDiffOTHrs
						, ete_HrsLate
						, payrateRowID
						, ete_TotalDayPay
						, ete_RegHrsWorkd + ete_OvertimeHrs
						, ((ete_RegHrsWorkd - ete_NDiffHrs) * rateperhour) * commonrate
						, (ete_OvertimeHrs * rateperhourforOT) * otrate
						, (ete_HrsUnder * rateperhour)
						, (ete_NDiffHrs * rateperhour) * ndiffrate
						, (ete_NDiffOTHrs * rateperhour) * ndiffotrate
						, (ete_HrsLate * rateperhour)
				) INTO anyINT;
				
				
			END IF;
				
		ELSE
		
			SET @lv_hrs = IFNULL((SELECT (et.VacationLeaveHours + et.SickLeaveHours + et.OtherLeaveHours + et.MaternityLeaveHours) `Result` FROM employeetimeentry et WHERE et.EmployeeID=ete_EmpRowID AND et.OrganizationID=ete_OrganizID AND et.`Date`=ete_Date), 0);
		
			SET hasLeave = '1';
	
			SET ete_TotalDayPay = ((ete_RegHrsWorkd * rateperhour) * commonrate)
										 + ((ete_OvertimeHrs * rateperhourforOT) * otrate)
										 + (@lv_hrs * rateperhour);
			
			SELECT INSUPD_employeetimeentries(
					anyINT
					, ete_OrganizID
					, ete_UserRowID
					, ete_UserRowID
					, ete_Date
					, eshRowID
					, ete_EmpRowID
					, esalRowID
					, '0'
					, ete_RegHrsWorkd
					, ete_OvertimeHrs
					, ete_HrsUnder
					, ete_NDiffHrs
					, ete_NDiffOTHrs
					, ete_HrsLate
					, payrateRowID
					, ete_TotalDayPay
					, ete_RegHrsWorkd + ete_OvertimeHrs
					, ((ete_RegHrsWorkd - ete_NDiffHrs) * rateperhour) * commonrate
					, (ete_OvertimeHrs * rateperhourforOT) * otrate
					, (ete_HrsUnder * rateperhour)
					, (ete_NDiffHrs * rateperhour) * ndiffrate
					, (ete_NDiffOTHrs * rateperhour) * ndiffotrate
					, (ete_HrsLate * rateperhour)
			) INTO anyINT;
			
		END IF;

	END IF;

ELSE
	
	SELECT
	(IS_WORKINGDAY_PRESENT_DURINGHOLI(ete_OrganizID, ete_EmpRowID, ete_Date, TRUE) # checks the attendance prior to holiday
	 # AND IS_WORKINGDAY_PRESENT_DURINGHOLI(ete_OrganizID, ete_EmpRowID, ete_Date, FALSE) # checks the attendance after the holiday
	 ) `Result`
	FROM payrate pr
	WHERE pr.RowID=payrateRowID AND pr.`PayRate` > 1
	INTO is_valid_for_holipayment;
	
	SET is_valid_for_holipayment = IFNULL(is_valid_for_holipayment, FALSE);
	
	IF is_valid_for_holipayment = TRUE THEN
		SET @zero = 0;

	   # if this date is holiday, it's a rule that there's no late or undertime
		SET ete_HrsUnder = @zero;
		SET ete_HrsLate = @zero;
		
	END IF;
	
	SET @availed_leave_hrs = 0.0;
	
	SELECT (et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours) `Result`
	FROM employeetimeentry et
	WHERE et.EmployeeID=ete_EmpRowID
	AND et.OrganizationID=ete_OrganizID
	AND et.`Date`=ete_Date
	AND (et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours) > 0
	LIMIT 1
	INTO @availed_leave_hrs;
	
	SET @availed_leave_hrs = IFNULL(@availed_leave_hrs, 0);
	
	SELECT
	IFNULL(et.TotalDayPay,0)
	,IFNULL(et.TotalHoursWorked,0)
	FROM employeetimeentry et
	INNER JOIN employee e ON e.RowID=et.EmployeeID
	WHERE et.EmployeeID=ete_EmpRowID
	AND et.OrganizationID=ete_OrganizID
	AND et.`Date`=IF(CHAR_TO_DAYOFWEEK(e.DayOfRest) = DAYNAME(pr_DayBefore), SUBDATE(pr_DayBefore, INTERVAL 1 DAY), pr_DayBefore)
	INTO yester_TotDayPay
		  ,yester_TotHrsWorkd;
	SELECT EXISTS(SELECT elv.RowID FROM employeeleave elv WHERE elv.EmployeeID=ete_EmpRowID AND elv.`Status`='Approved' AND elv.OrganizationID=ete_OrganizID AND ete_Date BETWEEN elv.LeaveStartDate AND elv.LeaveEndDate LIMIT 1) INTO hasLeave;
	IF yester_TotDayPay IS NULL THEN
		SET yester_TotDayPay = 0;
		
	END IF;
		
	IF pr_DayBefore <= SUBDATE(e_StartDate, INTERVAL 1 DAY) THEN
		
		
		SET isRestDay = '0';
		
		SET yester_TotDayPay = 0;
		
	END IF;
		
	IF yester_TotDayPay != 0 THEN # employee was present yester date

		SELECT (DAYOFWEEK(SUBDATE(ete_Date, INTERVAL 1 DAY)) = e.DayOfRest)
		FROM employee e
		WHERE e.RowID=ete_EmpRowID
		INTO isRestDay;

		IF isRestDay = '1' THEN # it's his/her rest day yester date
			
			SET ete_TotalDayPay = ((ete_RegHrsWorkd * rateperhour) * ((commonrate + restday_rate) - 1))
										 + ((ete_OvertimeHrs * rateperhourforOT) * ((commonrate + restdayot_rate) - 1))
										 + (@availed_leave_hrs * rateperhour);
			
			SELECT INSUPD_employeetimeentries(
					anyINT
					, ete_OrganizID
					, ete_UserRowID
					, ete_UserRowID
					, ete_Date
					, eshRowID
					, ete_EmpRowID
					, esalRowID
					, '0'
					, ete_RegHrsWorkd
					, ete_OvertimeHrs
					, ete_HrsUnder
					, ete_NDiffHrs
					, ete_NDiffOTHrs
					, ete_HrsLate
					, payrateRowID
					, ete_TotalDayPay
					, ete_RegHrsWorkd + ete_OvertimeHrs
					, ((ete_RegHrsWorkd - ete_NDiffHrs) * rateperhour) * ((commonrate + restday_rate) - 1)
					, (ete_OvertimeHrs * rateperhourforOT) * ((commonrate + restdayot_rate) - 1)
					, (ete_HrsUnder * rateperhour)
					, (ete_NDiffHrs * rateperhour) * ndiffrate
					, (ete_NDiffOTHrs * rateperhour) * ndiffotrate
					, (ete_HrsLate * rateperhour)
			) INTO anyINT;
			
		ELSE

			SET ete_TotalDayPay = ((ete_RegHrsWorkd * rateperhour) * commonrate)
										 + ((ete_OvertimeHrs * rateperhourforOT) * otrate)
										 + (@availed_leave_hrs * rateperhour);
					
			IF (ete_TotalDayPay IS NULL 
				OR ete_TotalDayPay = 0)
				AND pr_PayType = 'Regular Holiday' THEN
				
		
		
				SET ete_TotalDayPay = dailypay;
				
			END IF;
			IF hasLeave = '1' THEN SET ete_TotalDayPay = ete_TotalDayPay + (IFNULL((SELECT VacationLeaveHours + SickLeaveHours + MaternityLeaveHours + OtherLeaveHours FROM employeetimeentry WHERE EmployeeID=ete_EmpRowID AND OrganizationID=ete_OrganizID AND `Date`=ete_Date),0) * rateperhour); END IF;
			SELECT INSUPD_employeetimeentries(
					anyINT
					, ete_OrganizID
					, ete_UserRowID
					, ete_UserRowID
					, ete_Date
					, eshRowID
					, ete_EmpRowID
					, esalRowID
					, '0'
					, ete_RegHrsWorkd
					, ete_OvertimeHrs
					, ete_HrsUnder
					, ete_NDiffHrs
					, ete_NDiffOTHrs
					, ete_HrsLate
					, payrateRowID
					, ete_TotalDayPay
					, ete_RegHrsWorkd + ete_OvertimeHrs
					, ((ete_RegHrsWorkd - ete_NDiffHrs) * rateperhour) * commonrate
					, (ete_OvertimeHrs * rateperhourforOT) * otrate
					, (ete_HrsUnder * rateperhour)
					, (ete_NDiffHrs * rateperhour) * ndiffrate
					, (ete_NDiffOTHrs * rateperhour) * ndiffotrate
					, (ete_HrsLate * rateperhour)
			) INTO anyINT;
			
		END IF;
			
	ELSE
	
		IF isRestDay = '1' THEN
		
				
			SET ete_TotalDayPay = ((ete_RegHrsWorkd * rateperhour) * commonrate)
										 + ((ete_OvertimeHrs * rateperhourforOT) * otrate)
										 + (@availed_leave_hrs * rateperhour);
										 
			SELECT INSUPD_employeetimeentries(
					anyINT
					, ete_OrganizID
					, ete_UserRowID
					, ete_UserRowID
					, ete_Date
					, eshRowID
					, ete_EmpRowID
					, esalRowID
					, '0'
					, ete_RegHrsWorkd
					, ete_OvertimeHrs
					, ete_HrsUnder
					, ete_NDiffHrs
					, ete_NDiffOTHrs
					, ete_HrsLate
					, payrateRowID
					, ete_TotalDayPay
					, ete_RegHrsWorkd + ete_OvertimeHrs
					, ((ete_RegHrsWorkd - ete_NDiffHrs) * rateperhour) * ((commonrate + restday_rate) - 1)
					, (ete_OvertimeHrs * rateperhourforOT) * ((commonrate + restdayot_rate) - 1)
					, (ete_HrsUnder * rateperhour)
					, (ete_NDiffHrs * rateperhour) * ndiffrate
					, (ete_NDiffOTHrs * rateperhour) * ndiffotrate
					, (ete_HrsLate * rateperhour)
			) INTO anyINT;
				
			


		ELSEIF isRestDay = '0' THEN
		
			SELECT (IF(CHAR_TO_DAYOFWEEK(e.DayOfRest) = DAYNAME(pr_DayBefore), DAYOFWEEK(SUBDATE(pr_DayBefore, INTERVAL 1 DAY)), DAYOFWEEK(pr_DayBefore)) = e.DayOfRest)
			FROM employee e
			WHERE e.RowID=ete_EmpRowID
			INTO isRestDay;

			SET @satisf_conditn = TRUE;
			# IF isRestDay = '1' THEN
			IF @satisf_conditn THEN
			
				SET ete_TotalDayPay = ((ete_RegHrsWorkd * rateperhour) * commonrate)
											 + ((ete_OvertimeHrs * rateperhourforOT) * otrate)
											 + (@availed_leave_hrs * rateperhour);
				IF hasLeave = '1' THEN SET ete_TotalDayPay = ete_TotalDayPay + (IFNULL((SELECT VacationLeaveHours + SickLeaveHours + MaternityLeaveHours + OtherLeaveHours FROM employeetimeentry WHERE EmployeeID=ete_EmpRowID AND OrganizationID=ete_OrganizID AND `Date`=ete_Date),0) * rateperhour); END IF;				 
				SELECT INSUPD_employeetimeentries(
						anyINT
						, ete_OrganizID
						, ete_UserRowID
						, ete_UserRowID
						, ete_Date
						, eshRowID
						, ete_EmpRowID
						, esalRowID
						, '0'
						, ete_RegHrsWorkd
						, ete_OvertimeHrs
						, ete_HrsUnder
						, ete_NDiffHrs
						, ete_NDiffOTHrs
						, ete_HrsLate
						, payrateRowID
						, ete_TotalDayPay
						, ete_RegHrsWorkd + ete_OvertimeHrs
						, ((ete_RegHrsWorkd - ete_NDiffHrs) * rateperhour) * commonrate
						, (ete_OvertimeHrs * rateperhourforOT) * otrate
						, (ete_HrsUnder * rateperhour)
						, (ete_NDiffHrs * rateperhour) * ndiffrate
						, (ete_NDiffOTHrs * rateperhour) * ndiffotrate
						, (ete_HrsLate * rateperhour)
				) INTO anyINT;
				
			ELSE
	
				SET ete_TotalDayPay = 0.0;
											 
				SELECT INSUPD_employeetimeentries(
						anyINT
						, ete_OrganizID
						, ete_UserRowID
						, ete_UserRowID
						, ete_Date
						, eshRowID
						, ete_EmpRowID
						, esalRowID
						, '0'
						, ete_RegHrsWorkd
						, ete_OvertimeHrs
						, ete_HrsUnder
						, ete_NDiffHrs
						, ete_NDiffOTHrs
						, ete_HrsLate
						, payrateRowID
						, ete_TotalDayPay
						, 0
						, 0
						, 0
						, 0
						, 0
						, 0
						, 0
				) INTO anyINT;
				
			END IF;


		END IF;
		
	END IF;
	
END IF;

	
	
	











SET returnvalue = anyint;

RETURN yes_true;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
