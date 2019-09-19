/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP FUNCTION IF EXISTS `GENERATE_employeetimeentry`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `GENERATE_employeetimeentry`(
	`ete_EmpRowID` INT,
	`ete_OrganizID` INT,
	`ete_Date` DATE,
	`ete_UserRowID` INT


































) RETURNS int(11)
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


DECLARE hasLeave BOOL DEFAULT FALSE;
DECLARE leaveId INT(11);

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
DECLARE timeLogId INT(11);

UPDATE employeeovertime ot SET ot.LastUpd=IFNULL(ADDDATE(ot.LastUpd, INTERVAL 1 SECOND), CURRENT_TIMESTAMP()) WHERE ot.EmployeeID=ete_EmpRowID AND ot.OrganizationID=ete_OrganizID AND ete_Date BETWEEN ot.OTStartDate AND ot.OTEndDate AND ot.OTStatus='Approved';

DROP TEMPORARY TABLE IF EXISTS employeelogtime;
CREATE TEMPORARY TABLE IF NOT EXISTS employeelogtime
SELECT * FROM employeetimeentrydetails WHERE EmployeeID=ete_EmpRowID AND OrganizationID=ete_OrganizID AND `Date`=ete_Date AND TimeStampIn IS NOT NULL AND TimeStampOut IS NOT NULL ORDER BY IFNULL(LastUpd, Created) DESC LIMIT 1;

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
	,IF(e_CalcNightDiffOT = '1', (pr.NightDifferentialOTRate - pr.OvertimeRate), default_payrate)
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
/*UPDATE payrate SET NightDifferentialOTRate=1.375 WHERE PayType='Regular day';

ALTER TABLE `payrate`
	CHANGE COLUMN `PayRate` `PayRate` DECIMAL(10,4) NULL DEFAULT NULL COMMENT 'payout rate 1.10, 1.20,2.0 (10%, 20%, 100%, etc)' AFTER `Description`,
	CHANGE COLUMN `OvertimeRate` `OvertimeRate` DECIMAL(10,4) NULL DEFAULT NULL AFTER `PayRate`,
	CHANGE COLUMN `NightDifferentialRate` `NightDifferentialRate` DECIMAL(10,4) NULL DEFAULT NULL AFTER `OvertimeRate`,
	CHANGE COLUMN `NightDifferentialOTRate` `NightDifferentialOTRate` DECIMAL(10,4) NULL DEFAULT NULL AFTER `NightDifferentialRate`,
	CHANGE COLUMN `RestDayRate` `RestDayRate` DECIMAL(10,4) NULL DEFAULT NULL AFTER `NightDifferentialOTRate`,
	CHANGE COLUMN `RestDayOvertimeRate` `RestDayOvertimeRate` DECIMAL(10,4) NULL DEFAULT NULL AFTER `RestDayRate`;*/

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

SELECT i.RowID
FROM (SELECT RowID
		FROM employeelogtime
		WHERE EmployeeID=ete_EmpRowID
		AND `Date`=ete_Date
		AND OrganizationID=ete_OrganizID
		LIMIT 1) i
INTO timeLogId;

SET has_timelogs_onthisdate = timeLogId IS NOT NULL;

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


SET @breakFrom = NULL; SET @breakTo = NULL;


SELECT
sh.TimeFrom
,sh.TimeTo
,esh.RowID	
,sh.RowID, sh.BreakTimeFrom, sh.BreakTimeTo
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
	  ,sh_rowID, @breakFrom, @breakTo;
	  
IF OTCount = 1 THEN
	
	SELECT
	IF(eot.OTStartTime = shifttimeto, ADDTIME(shifttimeto,'00:00:01'), eot.OTStartTime)
	,IF(eot.OTEndTime > IF(empIn.TimeOut > empIn.TimeIn, empIn.TimeOut, ADDTIME(empIn.TimeOut, '24:00:00')), empIn.TimeOut, eot.OTEndTime)
	,eot.RowID
	FROM employeeovertime eot INNER JOIN (SELECT etd.TimeOut, etd.TimeIn FROM employeelogtime etd WHERE etd.EmployeeID=ete_EmpRowID AND etd.OrganizationID=ete_OrganizID AND etd.`Date`=ete_Date LIMIT 1) empIn ON empIn.TimeOut IS NULL OR empIn.TimeOut IS NOT NULL
	WHERE eot.EmployeeID=ete_EmpRowID
	AND eot.OrganizationID=ete_OrganizID
#	AND eot.OTStartTime >= shifttimeto
	AND eot.OTStatus='Approved'
	AND eot.OTStatus=eot.OTStatus2
	AND has_timelogs_onthisdate = TRUE
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

SELECT i.RowID
FROM (SELECT
		elv.RowID
		FROM employeeleave elv
		WHERE elv.EmployeeID=ete_EmpRowID AND elv.`Status`='Approved'
		AND elv.OrganizationID=ete_OrganizID
		AND ete_Date BETWEEN elv.LeaveStartDate AND elv.LeaveEndDate
		LIMIT 1) i
INTO leaveId;
SET hasLeave = leaveId IS NOT NULL;

SET @timeStampLogIn = NULL;
SET @timeStampLogOut = NULL;

IF isRestDay = '1' THEN 
	
	SET ndiffotrate = ndiffotrate * restday_rate;
	
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
	
	FROM employeelogtime etd
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
	
	# SELECT COMPUTE_TimeDifference(etd_TimeIn,etd_TimeOut)
	# INTO ete_RegHrsWorkd;
	
	SET ete_HrsLate = 0.0;
	
	SET ete_HrsUnder = 0.0;

	SET ete_NDiffHrs = 0.0;
	
	SET ete_NDiffOTHrs = 0.0;

	IF otstartingtime IS NOT NULL
		AND otendingtime IS NOT NULL THEN
		
		SELECT CalculateOvertimeHours(shifttimefrom, shifttimeto, ete_Date, ete_EmpRowID)
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
		INTO @ete_NDiffHrs; # 
		# og_ndtimefrom, og_ndtimeto
	ELSE
		
		SET ete_OvertimeHrs = 0.0;
		
	END IF;
	
ELSE 

	SET @breakStarts=NULL;
	SET @breakEnds=NULL;
	
	SELECT
	IF(etd.TimeStampIn BETWEEN CONCAT_DATETIME(ete_Date, MAKETIME(0,0,0)) AND ADDDATE(CONCAT_DATETIME(ete_Date, sh.TimeFrom), INTERVAL e.LateGracePeriod MINUTE), sh.TimeFrom, etd.TimeIn) `TimeIn`
#	etd.TimeIn
	,IF(e_UTOverride = 1, etd.TimeOut, IFNULL(sh.TimeTo,etd.TimeOut))
	,IF(etd.TimeStampIn BETWEEN CONCAT_DATETIME(ete_Date, MAKETIME(0,0,0)) AND ADDDATE(CONCAT_DATETIME(ete_Date, sh.TimeFrom), INTERVAL e.LateGracePeriod MINUTE), CONCAT_DATETIME(ete_Date, sh.TimeFrom), etd.TimeStampIn) `TimeStampIn`
#	, etd.TimeStampIn
	, IF(e_UTOverride = 1
			, LEAST(IFNULL(GetNextStartDateTime(CONCAT_DATETIME(ete_Date, sh.TimeFrom), sh.TimeTo), etd.TimeStampOut)
						, etd.TimeStampOut)
			, IFNULL(GetNextStartDateTime(CONCAT_DATETIME(ete_Date, sh.TimeFrom), sh.TimeTo), etd.TimeStampOut)
			) `TimeStampOut`
	, sh.BreakTimeFrom
	, sh.BreakTimeTo
	FROM employeelogtime etd
	INNER JOIN employee e ON e.RowID=etd.EmployeeID
	LEFT JOIN employeeshift esh ON esh.OrganizationID=etd.OrganizationID AND esh.EmployeeID=etd.EmployeeID AND etd.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo
	LEFT JOIN shift sh ON sh.RowID=esh.ShiftID
	WHERE etd.EmployeeID=ete_EmpRowID
	AND etd.OrganizationID=ete_OrganizID
	AND etd.`Date`=ete_Date
#	ORDER BY IFNULL(etd.LastUpd, etd.Created) DESC
	LIMIT 1
	INTO etd_TimeIn
	     ,etd_TimeOut
		  ,@timeStampLogIn
		  ,@timeStampLogOut
		  , @breakStarts
		  , @breakEnds;
	
	SELECT GRACE_PERIOD(etd_TimeIn, shifttimefrom, e_LateGracePeriod)
	INTO etd_TimeIn;

	IF otstartingtime IS NULL
		AND otstartingtime IS NULL THEN

		IF IF(HOUR(etd_TimeOut) = 00, ADDTIME(etd_TimeOut,'24:00'), etd_TimeOut) > shifttimeto THEN

			SET @dutyStart=CONCAT_DATETIME(ete_Date, shifttimefrom);
			SET @dutyGraceStart = ADDDATE(@dutyStart, INTERVAL e_LateGracePeriod MINUTE);
			
			IF @timeStampLogIn BETWEEN @dutyStart AND @dutyGraceStart THEN
				SET @timeStampLogIn = @dutyStart;
			END IF;
			
			SET @dutyEnd=GetNextStartDateTime(@dutyStart, shifttimeto);
			
			SET @breakStarts=GetNextStartDateTime(@dutyStart, @breakStarts);
			SET @breakEnds=GetNextStartDateTime(@breakStarts, @breakEnds);

			SELECT TIMESTAMPDIFF(SECOND
			                     , GREATEST(@dutyStart
										           #, @timeStampLogIn
													  , IF(@timeStampLogIn BETWEEN @breakStarts AND @breakEnds, @breakEnds, @timeStampLogIn)
													  )
										, LEAST(IF(@timeStampLogOut BETWEEN @breakStarts AND @breakEnds, @breakStarts, @timeStampLogOut)
										        #, @timeStampLogOut
										        , @dutyEnd)
												  ) / 3600
#			SELECT COMPUTE_TimeDifference(etd_TimeIn,shifttimeto)
			INTO ete_RegHrsWorkd;
			
			SET @lessBreak = 0.00;
			
			IF (@breakStarts BETWEEN @timeStampLogIn AND @timeStampLogOut)
			   AND (@breakEnds BETWEEN @timeStampLogIn AND @timeStampLogOut)
				AND (@timeStampLogIn NOT BETWEEN @breakStarts AND @breakEnds
				     AND @timeStampLogOut NOT BETWEEN @breakStarts AND @breakEnds) THEN
				SET @lessBreak = TIMESTAMPDIFF(SECOND, @breakStarts, @breakEnds) / 3600;
			/*ELSEIF @timeStampLogOut BETWEEN @timeStampLogIn AND @breakEnds THEN
				SET @lessBreak = TIMESTAMPDIFF(SECOND, @breakStarts, @timeStampLogOut) / 3600;
			ELSEIF @timeStampLogIn BETWEEN @breakStarts AND @timeStampLogOut THEN
				SET @lessBreak = TIMESTAMPDIFF(SECOND, @breakStarts, @timeStampLogIn) / 3600;*/
			END IF;
			
			SET ete_RegHrsWorkd = ete_RegHrsWorkd - IFNULL(@lessBreak, 0);
			
			SET etd_TimeOut = shifttimeto;

		ELSE

			SET @dutyStart=CONCAT_DATETIME(ete_Date, shifttimefrom);
			SET @dutyGraceStart = ADDDATE(@dutyStart, INTERVAL e_LateGracePeriod MINUTE);
			
			IF @timeStampLogIn BETWEEN @dutyStart AND @dutyGraceStart THEN
				SET @timeStampLogIn = @dutyStart;
			END IF;
			
			SET @dutyEnd=GetNextStartDateTime(@dutyStart, shifttimeto);
			
			SET @breakStarts=GetNextStartDateTime(@dutyStart, @breakStarts);
			SET @breakEnds=GetNextStartDateTime(@breakStarts, @breakEnds);

			SELECT TIMESTAMPDIFF(SECOND
			                     , GREATEST(@dutyStart
													  , IF(@timeStampLogIn BETWEEN @breakStarts AND @breakEnds, @breakEnds, @timeStampLogIn)
													  )
										, LEAST(IF(@timeStampLogOut BETWEEN @breakStarts AND @breakEnds, @breakStarts, @timeStampLogOut)
										        , @dutyEnd)
												  ) / 3600	
#			SELECT COMPUTE_TimeDifference(etd_TimeIn,etd_TimeOut)
			INTO ete_RegHrsWorkd;
			
			SET @lessBreak = 0.00;
			
			IF (@breakStarts BETWEEN @timeStampLogIn AND @timeStampLogOut)
			   AND (@breakEnds BETWEEN @timeStampLogIn AND @timeStampLogOut)
				AND (@timeStampLogIn NOT BETWEEN @breakStarts AND @breakEnds
				     AND @timeStampLogOut NOT BETWEEN @breakStarts AND @breakEnds) THEN
				SET @lessBreak = TIMESTAMPDIFF(SECOND, @breakStarts, @breakEnds) / 3600;
			/*ELSEIF @timeStampLogOut BETWEEN @timeStampLogIn AND @breakEnds THEN
				SET @lessBreak = TIMESTAMPDIFF(SECOND, @breakStarts, @timeStampLogOut) / 3600;
			ELSEIF @timeStampLogIn BETWEEN @breakStarts AND @timeStampLogOut THEN
				SET @lessBreak = TIMESTAMPDIFF(SECOND, @breakStarts, @timeStampLogIn) / 3600;*/
			END IF;
			
			SET ete_RegHrsWorkd = ete_RegHrsWorkd - IFNULL(@lessBreak, 0);
			
			IF @dutyEnd > @timeStampLogOut THEN
			
				SET ete_HrsUnder = TIMESTAMPDIFF(SECOND, @timeStampLogOut, @dutyEnd) / 3600;
			
			END IF;
			
		END IF;
		
		SET otstartingtime = '12:00:00'; 
		
		SET otendingtime = '12:00:00'; 

		SELECT CalculateOvertimeHours(shifttimefrom, shifttimeto, ete_Date, ete_EmpRowID)
		INTO ete_OvertimeHrs;
			
	ELSE

		SET @dutyStart=CONCAT_DATETIME(ete_Date, shifttimefrom);
		SET @dutyGraceStart = ADDDATE(@dutyStart, INTERVAL e_LateGracePeriod MINUTE);
		
		IF @timeStampLogIn BETWEEN @dutyStart AND @dutyGraceStart THEN
			SET @timeStampLogIn = @dutyStart;
		END IF;
		
		SET @dutyEnd=GetNextStartDateTime(@dutyStart, shifttimeto);
		
		SET @breakStarts=GetNextStartDateTime(@dutyStart, @breakStarts);
		SET @breakEnds=GetNextStartDateTime(@breakStarts, @breakEnds);

		SELECT TIMESTAMPDIFF(SECOND
		                     , GREATEST(@dutyStart
												  , IF(@timeStampLogIn BETWEEN @breakStarts AND @breakEnds, @breakEnds, @timeStampLogIn)
												  )
									, LEAST(IF(@timeStampLogOut BETWEEN @breakStarts AND @breakEnds, @breakStarts, @timeStampLogOut)
									        , @dutyEnd)
											  ) / 3600
		INTO ete_RegHrsWorkd;
		
		SET @lessBreak = 0.00;
		
		IF (@breakStarts BETWEEN @timeStampLogIn AND @timeStampLogOut)
		   AND (@breakEnds BETWEEN @timeStampLogIn AND @timeStampLogOut) THEN
			SET @lessBreak = TIMESTAMPDIFF(SECOND, @breakStarts, @breakEnds) / 3600;
		END IF;
		
		SET ete_RegHrsWorkd = ete_RegHrsWorkd - IFNULL(@lessBreak, 0);
		
		SELECT CalculateOvertimeHours(shifttimefrom, shifttimeto, ete_Date, ete_EmpRowID)
		INTO ete_OvertimeHrs;
		
	END IF;

	IF hasLeave THEN
	
		SET @leaveStartTime = NULL; SET @leaveEndTime = NULL;
		SET @shBreakStartDateTime = NULL;
		SET @hoursBreak = 0.0; SET @shiftHours = 0.0;
		SET @logStampIn = NULL; SET @logStampOut = NULL;
		SET @shStartDateTime = NULL;
		
		SELECT elv.LeaveStartTime, elv.LeaveEndTime
		, GetNextStartDateTime(CONCAT_DATETIME(ete_Date, sh.TimeFrom), sh.BreakTimeFrom)
		, (sh.ShiftHours - sh.WorkHours)
#		, etd.TimeStampIn, etd.TimeStampOut
		, IF(etd.TimeStampIn BETWEEN CONCAT_DATETIME(ete_Date, MAKETIME(0,0,0)) AND ADDDATE(CONCAT_DATETIME(ete_Date, sh.TimeFrom), INTERVAL e.LateGracePeriod MINUTE), CONCAT_DATETIME(ete_Date, sh.TimeFrom), etd.TimeStampIn) `TimeStampIn`
		, IF(e_UTOverride = 1, etd.TimeStampOut
			, LEAST(IFNULL(GetNextStartDateTime(CONCAT_DATETIME(ete_Date, sh.TimeFrom), sh.TimeTo), etd.TimeStampOut)
						, etd.TimeStampOut)
			) `TimeStampOut`
		, CONCAT_DATETIME(ete_Date, sh.TimeFrom)
		, sh.ShiftHours
		FROM employeeleave elv
		INNER JOIN employee e ON e.RowID=elv.EmployeeID
		INNER JOIN shift sh ON sh.RowID = sh_rowID
		LEFT JOIN employeelogtime etd ON etd.RowID = timeLogId
		WHERE elv.RowID = leaveId
		INTO @leaveStartTime
		     , @leaveEndTime
			  , @shBreakStartDateTime
			  , @hoursBreak
			  , @logStampIn, @logStampOut
			  , @shStartDateTime
			  , @shiftHours;

		SET @shBreakEndDateTime = ADDDATE(@shBreakStartDateTime, INTERVAL @hoursBreak HOUR);
		
		SET @leaveStartDateTime = CONCAT_DATETIME(ete_Date, @leaveStartTime);
		SET @leaveEndDateTime = GetNextStartDateTime(CONCAT_DATETIME(ete_Date, shifttimefrom), @leaveEndTime);
		
		SET @shEndDateTime = ADDDATE(@shStartDateTime, INTERVAL @shiftHours HOUR);
		
		SELECT TIMESTAMPDIFF(SECOND
									, @shStartDateTime
									, LEAST(IFNULL(@leaveStartDateTime, @logStampIn)
												, IFNULL(@logStampIn, @leaveStartDateTime))
									) / 3600
		INTO ete_HrsLate;
		IF ete_HrsLate < 0 THEN SET ete_HrsLate = 0; END IF;
		
		SELECT TIMESTAMPDIFF(SECOND
									, GREATEST(IFNULL(@leaveEndDateTime, @logStampOut)
													, IFNULL(@logStampOut, @leaveEndDateTime))
									, @shEndDateTime
									) / 3600
		INTO ete_HrsUnder;
		IF ete_HrsUnder < 0 THEN SET ete_HrsUnder = 0; END IF;

	ELSE
		IF etd_TimeIn > shifttimefrom THEN
		
			SELECT COMPUTE_TimeDifference(shifttimefrom, etd_TimeIn)
			INTO ete_HrsLate;

		ELSE
		
			SELECT COMPUTE_TimeDifference(etd_TimeIn, shifttimefrom)
			INTO ete_HrsLate;

		END IF;

		SET @lunchBreakStart = GetNextStartDateTime(CONCAT_DATETIME(ete_Date, shifttimefrom), @breakFrom);
		SET @lunchBreakEnd = GetNextStartDateTime(@lunchBreakStart, @breakTo);
		
		SET @dutyStart = CONCAT_DATETIME(ete_Date, shifttimefrom);
		SET @dutyEnd = GetNextStartDateTime(@dutyStart, shifttimeto);

		IF @timeStampLogOut BETWEEN @lunchBreakStart AND @lunchBreakEnd THEN

			SELECT TIMESTAMPDIFF(SECOND, @lunchBreakEnd, @dutyEnd) / 3600 `UndertimeHours`
#			SELECT COMPUTE_TimeDifference(TIME(@lunchBreakEnd), shifttimeto)
			INTO ete_HrsUnder;

		ELSEIF @timeStampLogOut BETWEEN @dutyStart AND @lunchBreakStart THEN
			
			SET @lunchBreakHourCount = TIMESTAMPDIFF(SECOND, @lunchBreakStart, @lunchBreakEnd) / 3600;
			
			SELECT TIMESTAMPDIFF(SECOND, @timeStampLogOut, @dutyEnd) / 3600 `UndertimeHours`
			INTO ete_HrsUnder;
			
			SET ete_HrsUnder = ete_HrsUnder - IFNULL(@lunchBreakHourCount, 0);

		ELSEIF @timeStampLogOut < @dutyEnd THEN
		
			SELECT TIMESTAMPDIFF(SECOND, @timeStampLogOut, @dutyEnd) / 3600
			INTO ete_HrsUnder;
			
		END IF;

		SET ete_HrsUnder = IFNULL(ete_HrsUnder, 0);
	END IF;
	
	SET ete_NDiffHrs = 0;
	
END IF;

	SET ete_NDiffOTHrs = IFNULL((SELECT SUM(ot.OfficialValidNightDiffHours) FROM employeeovertime ot WHERE ot.EmployeeID=ete_EmpRowID AND ot.OrganizationID=ete_OrganizID AND ete_Date BETWEEN ot.OTStartDate AND ot.OTEndDate AND ot.OTStatus='Approved'), 0);


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
SET rateperhour = IFNULL((SELECT DivisorToDailyRate FROM shift WHERE RowID=sh_rowID), default_work_hrs);
SET rateperhourforOT = rateperhour; SET rateperhour = dailypay / default_work_hrs;

SET rateperhourforOT =  dailypay / (SELECT DivisorToDailyRate FROM shift WHERE RowID=sh_rowID AND DivisorToDailyRate != rateperhourforOT);
IF IFNULL(rateperhourforOT,0) <= 0 THEN
	SET rateperhourforOT = rateperhour;
END IF;

SELECT
NULL
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

#IF isRestDay = '0' THEN
IF FALSE THEN

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


SET @minutePerHour = 60;
SET @secPerHour = @minutePerHour * 60;
SET @breakHours = ( TIME_TO_SEC(TIMEDIFF(@breakTo, @breakFrom)) / @secPerHour );
SET @breakHoursFloor = FLOOR(@breakHours);
SET @breakFractionMinutes = ( (@breakHours MOD 1) * @minutePerHour );

SET @breakFrom = CONCAT_DATETIME(ete_Date, @breakFrom);
SET @breakTo = ADDDATE(ADDDATE(@breakFrom, INTERVAL @breakHoursFloor HOUR), INTERVAL @breakFractionMinutes MINUTE);

IF @breakFrom <= @timeStampLogIn AND @breakTo <= @timeStampLogIn
	THEN
	SET ete_HrsLate = ete_HrsLate - @breakHours;
ELSEIF @timeStampLogIn BETWEEN @breakFrom AND @breakTo
	THEN
	SET @breakHours = ( TIME_TO_SEC(TIMEDIFF(DATE_FORMAT(@timeStampLogIn, @@time_format), DATE_FORMAT(@breakFrom, @@time_format))) / @secPerHour );
	SET ete_HrsLate = ete_HrsLate - @breakHours;
END IF;

IF ete_HrsLate < 0 THEN SET ete_HrsLate = 0; END IF;

/*IF ete_HrsUnder IS NULL THEN
	SET ete_HrsUnder = 0;
END IF;

IF ete_HrsUnder > 4 AND COMPUTE_TimeDifference(shifttimefrom, shifttimeto) = 9 THEN
	SET ete_HrsUnder = COMPUTE_TimeDifference(SUBTIME(shifttimeto,'04:00'), shifttimeto);

ELSEIF ete_HrsUnder > 5 AND COMPUTE_TimeDifference(shifttimefrom, shifttimeto) = 10 THEN
	SET ete_HrsUnder = COMPUTE_TimeDifference(SUBTIME(shifttimeto,'05:00'), shifttimeto);

END IF;*/

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
	FROM employeelogtime etd
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

/**/

	SET @leavePayment = 0; SET @lv_hrs = 0;

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
				, 0
		) INTO anyINT;
		

	ELSEIF yester_TotDayPay = 0 THEN

		SELECT elv.OfficialValidHours
		FROM employeeleave elv
		WHERE elv.RowID = leaveId
		INTO @lv_hrs;

		SET @leavePayment = (IFNULL(@lv_hrs, 0) * IFNULL(rateperhour, 0));

		IF isRestDay = '1' THEN

			SET ete_TotalDayPay = ((ete_RegHrsWorkd * rateperhour) * commonrate)
										 + ((ete_OvertimeHrs * rateperhourforOT) * otrate)
										 + @leavePayment;

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
					, @leavePayment
			) INTO anyINT;
			
			
		ELSEIF isRestDay = '0' THEN

			SET ete_TotalDayPay = ((ete_RegHrsWorkd * rateperhour) * commonrate)
			                    	 + ((ete_OvertimeHrs * rateperhourforOT) * otrate)
			                    	 + @leavePayment;

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
					, @leavePayment
			) INTO anyINT;
			
		END IF;
	
	ELSE

			



		IF hasLeave = FALSE THEN
	
			
			
			IF isRestDay = '1' THEN
			
				SET ete_TotalDayPay =	((ete_RegHrsWorkd * rateperhour) * restday_rate)
												+ (ete_OvertimeHrs * rateperhourforOT) * restdayot_rate
												+ (ete_NDiffHrs * rateperhour) * ndiffrate;
											 
				SET ete_HrsLate = 0.0;

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
						, 0
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
						, 0
				) INTO anyINT;
				
				
			END IF;
				
		ELSE

			SELECT elv.OfficialValidHours
			FROM employeeleave elv
			WHERE elv.RowID = leaveId
			INTO @lv_hrs;

			SET @leavePayment = IFNULL(@lv_hrs, 0) * rateperhour;

			SET hasLeave = TRUE;
	
			SET ete_TotalDayPay = ((ete_RegHrsWorkd * rateperhour) * commonrate)
										 + ((ete_OvertimeHrs * rateperhourforOT) * otrate)
										 + @leavePayment;

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
					, @leavePayment
			) INTO anyINT;
			
		END IF;

	END IF;

ELSE

	SET @specialNonWorkingHoliday = 'Special Non-Working Holiday';
	SET @legalHoliday = 'Regular Holiday';
	
	SELECT EXISTS(SELECT pr.RowID
						FROM payrate pr
						INNER JOIN employee e ON e.RowID = ete_EmpRowID AND e.CalcSpecialHoliday = TRUE AND e.EmployeeType IN ('Daily', 'Monthly')
						WHERE pr.RowID = payrateRowID
						AND pr.PayType = @specialNonWorkingHoliday
						AND IS_WORKINGDAY_PRESENT_DURINGHOLI(pr.OrganizationID, e.RowID, pr.`Date`, TRUE) = TRUE
						
					/*UNION
						SELECT pr.RowID
						FROM payrate pr
						INNER JOIN employee e ON e.RowID = ete_EmpRowID AND e.CalcSpecialHoliday = TRUE AND e.EmployeeType='Monthly'
						WHERE pr.RowID = payrateRowID
						AND pr.PayType = @specialNonWorkingHoliday*/
						
					UNION
						SELECT pr.RowID
						FROM payrate pr
						INNER JOIN employee e ON e.RowID = ete_EmpRowID AND e.CalcHoliday = TRUE
						WHERE pr.RowID = payrateRowID
						AND pr.PayType = @legalHoliday
						AND IS_WORKINGDAY_PRESENT_DURINGHOLI(pr.OrganizationID, e.RowID, pr.`Date`, TRUE) = TRUE
						)
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

		/*SELECT (DAYOFWEEK(SUBDATE(ete_Date, INTERVAL 1 DAY)) = e.DayOfRest)
		FROM employee e
		WHERE e.RowID=ete_EmpRowID
		INTO isRestDay;*/
		
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
					, (@availed_leave_hrs * rateperhour)
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
			IF hasLeave THEN SET ete_TotalDayPay = ete_TotalDayPay + (IFNULL((SELECT VacationLeaveHours + SickLeaveHours + MaternityLeaveHours + OtherLeaveHours FROM employeetimeentry WHERE EmployeeID=ete_EmpRowID AND OrganizationID=ete_OrganizID AND `Date`=ete_Date),0) * rateperhour); END IF;

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
					, (@availed_leave_hrs * rateperhour)
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
					, (@availed_leave_hrs * rateperhour)
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
				IF hasLeave THEN SET ete_TotalDayPay = ete_TotalDayPay + (IFNULL((SELECT VacationLeaveHours + SickLeaveHours + MaternityLeaveHours + OtherLeaveHours FROM employeetimeentry WHERE EmployeeID=ete_EmpRowID AND OrganizationID=ete_OrganizID AND `Date`=ete_Date),0) * rateperhour); END IF;
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
						, (@availed_leave_hrs * rateperhour)
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
