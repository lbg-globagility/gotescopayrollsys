/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `RecomputeHighPrecisionLateUndertime`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `RecomputeHighPrecisionLateUndertime`(
	IN `organizationID` INT,
	IN `payDateFrom` DATE,
	IN `payDateTo` DATE

)
    DETERMINISTIC
BEGIN

SET @orgID=organizationID;
SET @dateFrom=payDateFrom;
SET @dateTo=payDateTo;

SET @startTime=TIMESTAMP(CURDATE());
SET @breakStartTimeStamp=TIMESTAMP(CURDATE());
SET @breakEndTimeStamp=TIMESTAMP(CURDATE());

DROP TEMPORARY TABLE IF EXISTS shiftschedwithtimestamp;
DROP TABLE IF EXISTS shiftschedwithtimestamp;
CREATE TEMPORARY TABLE shiftschedwithtimestamp
SELECT esh.RowID
, d.DateValue `Date`
, esh.ShiftID
, TIMESTAMP(@startTime := CONCAT_DATETIME(d.DateValue, sh.TimeFrom)) `StartTimeStamp`

, TIMESTAMP(@breakStartTimeStamp := GetNextStartDateTime(@startTime, sh.BreakTimeFrom)) `BreakStartTimeStamp`
, TIMESTAMP(@breakEndTimeStamp := GetNextStartDateTime(@breakStartTimeStamp, sh.BreakTimeTo)) `BreakEndTimeStamp`

, GetNextStartDateTime(@breakEndTimeStamp, sh.TimeTo)`EndTimeStamp`
FROM employeeshift esh
INNER JOIN dates d ON (d.DateValue BETWEEN esh.EffectiveFrom AND esh.EffectiveTo) AND d.DateValue BETWEEN @dateFrom AND @dateTo
INNER JOIN shift sh ON sh.RowID=esh.ShiftID
WHERE esh.OrganizationID=@orgID
;

DROP TEMPORARY TABLE IF EXISTS obtimelog;
DROP TABLE IF EXISTS obtimelog;
CREATE TEMPORARY TABLE obtimelog
SELECT et.RowID, et.OrganizationID, et.EmployeeID, et.EmployeeShiftID, et.`Date`
, TIMESTAMP(@obStartTimeStamp := CONCAT_DATETIME(et.`Date`, ob.OffBusStartTime)) `ObStartTimeStamp`
, GetNextStartDateTime(@obStartTimeStamp, ob.OffBusEndTime) `ObEndTimeStamp`
FROM employeetimeentry et
INNER JOIN employeeofficialbusiness ob ON ob.EmployeeID=et.EmployeeID AND et.`Date` BETWEEN ob.OffBusStartDate AND ob.OffBusEndDate AND ob.OffBusStatus='Approved' AND ob.OffBusStatus=ob.OffBusStatus2 AND ob.OffBusStartTime IS NOT NULL AND ob.OffBusEndTime IS NOT NULL
WHERE et.`Date` BETWEEN @dateFrom AND @dateTo
AND et.HoursLate > 0
AND et.OrganizationID=@orgID
;

DROP TEMPORARY TABLE IF EXISTS leavetimelog;
DROP TABLE IF EXISTS leavetimelog;
CREATE TEMPORARY TABLE leavetimelog
SELECT et.RowID, et.OrganizationID, et.EmployeeID, et.EmployeeShiftID, et.`Date`
, TIMESTAMP(@leaveStartTimeStamp := CONCAT_DATETIME(et.`Date`, elv.LeaveStartTime)) `LeaveStartTimeStamp`
, GetNextStartDateTime(@leaveStartTimeStamp, elv.LeaveEndTime) `leaveEndTimeStamp`
FROM employeetimeentry et
INNER JOIN employeeleave elv ON elv.EmployeeID=et.EmployeeID AND et.`Date` BETWEEN elv.LeaveStartDate AND elv.LeaveEndDate AND elv.`Status`='Approved' AND elv.`Status`=elv.`Status2`
WHERE et.`Date` BETWEEN @dateFrom AND @dateTo
AND et.HoursLate > 0
AND et.OrganizationID=@orgID
;










SET @breakHours1=0.00;
SET @logInIsEarlyThanBreak=FALSE;
SET @logInIsBetweenBreak=FALSE;
SET @officialLogIn=TIMESTAMP(CURDATE());

SET @secondsPerMinute=60*60;

DROP TEMPORARY TABLE IF EXISTS tardiness;
DROP TABLE IF EXISTS tardiness;
CREATE TEMPORARY TABLE tardiness
SELECT et.RowID, et.`Date`, et.EmployeeID
, et.HoursLate

, shst.StartTimeStamp, shst.BreakStartTimeStamp, shst.BreakEndTimeStamp, shst.EndTimeStamp

, @breakHours1 := TRIM(TIMESTAMPDIFF(SECOND, shst.BreakStartTimeStamp, shst.BreakEndTimeStamp) / @secondsPerMinute)+0 `BreakHours`
, TIMESTAMP(@officialLogIn := LateTimeLog(etd.TimeStampIn, obtl.`ObStartTimeStamp`, ltl.`LeaveStartTimeStamp`)) `OfficialLogIn`
, @logInIsEarlyThanBreak := (@officialLogIn < shst.BreakStartTimeStamp) `LogInIsEarlyThanBreak`
, @logInIsBetweenBreak := (@officialLogIn BETWEEN shst.BreakStartTimeStamp AND shst.BreakEndTimeStamp) `LogInIsBetweenBreak`
, TRIM(FORMAT(TIMESTAMPDIFF(SECOND, shst.StartTimeStamp
									 , IF(@logInIsBetweenBreak
									 		, shst.BreakStartTimeStamp
											, IF(@logInIsEarlyThanBreak
													, @officialLogIn
													, SUBDATE(@officialLogIn, INTERVAL TIMESTAMPDIFF(SECOND, shst.BreakStartTimeStamp, shst.BreakEndTimeStamp) SECOND)
													)
											)
) / @secondsPerMinute, 6))+0 `LateHighPrecision`
, et.HoursTardy
FROM employeetimeentry et
INNER JOIN shiftschedwithtimestamp shst ON shst.RowID=et.EmployeeShiftID AND et.`Date`=shst.`Date`

LEFT JOIN employeetimeentrydetails etd ON etd.EmployeeID=et.EmployeeID AND etd.`Date`=et.`Date`

LEFT JOIN obtimelog obtl ON obtl.RowID=et.RowID

LEFT JOIN leavetimelog ltl ON ltl.RowID=et.RowID

WHERE et.OrganizationID=@orgID
AND et.`Date` BETWEEN @dateFrom AND @dateTo
AND et.HoursLate > 0
;

SET @breakHours2=0.00;
SET @logOutIsLaterThanBreak=FALSE;
SET @logOutIsBetweenBreak=FALSE;
SET @officialLogOut=TIMESTAMP(CURDATE());

DROP TEMPORARY TABLE IF EXISTS earlyout;
DROP TABLE IF EXISTS earlyout;
CREATE TEMPORARY TABLE earlyout
SELECT et.RowID, et.`Date`, et.EmployeeID
, et.UndertimeHours
, @breakHours2 := TRIM(TIMESTAMPDIFF(SECOND, shst.BreakStartTimeStamp, shst.BreakEndTimeStamp) / @secondsPerMinute)+0 `BreakHours`
, TIMESTAMP(@officialLogOut := UndertimeLog(etd.TimeStampOut, obtl.`ObEndTimeStamp`, ltl.`LeaveEndTimeStamp`)) `OfficialLogOut`
, @logOutIsLaterThanBreak := (@officialLogOut >= shst.BreakEndTimeStamp) `LogOutIsLaterThanBreak`
, @logOutIsBetweenBreak := (@officialLogOut BETWEEN shst.BreakStartTimeStamp AND shst.BreakEndTimeStamp) `LogOutIsBetweenBreak`
, TRIM(FORMAT(TIMESTAMPDIFF(SECOND
                            , IF(@logOutIsBetweenBreak
									 		, shst.BreakEndTimeStamp
											 , IF(@logOutIsLaterThanBreak
											 		, @officialLogOut
													 , ADDDATE(@officialLogOut, INTERVAL TIMESTAMPDIFF(SECOND, shst.BreakStartTimeStamp, shst.BreakEndTimeStamp) SECOND)
													 )
											)
									 , shst.`EndTimeStamp`
									 ) / @secondsPerMinute
				  , 6)
		 )+0 `TardyHighPrecision`
, et.HoursUndertime
FROM employeetimeentry et
INNER JOIN shiftschedwithtimestamp shst ON shst.RowID=et.EmployeeShiftID AND et.`Date`=shst.`Date`

LEFT JOIN employeetimeentrydetails etd ON etd.EmployeeID=et.EmployeeID AND etd.`Date`=et.`Date`

LEFT JOIN obtimelog obtl ON obtl.RowID=et.RowID

LEFT JOIN leavetimelog ltl ON ltl.RowID=et.RowID

WHERE et.OrganizationID=@orgID
AND et.`Date` BETWEEN @dateFrom AND @dateTo
AND et.UndertimeHours > 0
;

SET @databaseName='gotescopayrolldb';
SET @tableName='employeetimeentry';

SET @columnName='HoursTardy';
SET @existsHoursTardy=EXISTS(SELECT i.ORDINAL_POSITION
										FROM information_schema.`COLUMNS` i
										WHERE i.TABLE_SCHEMA=@databaseName
										AND i.`TABLE_NAME`=@tableName
										AND i.`COLUMN_NAME`=@columnName);

SET @columnName='HoursUndertime';
SET @existsHoursUnderColumn=EXISTS(SELECT i.ORDINAL_POSITION
												FROM information_schema.`COLUMNS` i
												WHERE i.TABLE_SCHEMA=@databaseName
												AND i.`TABLE_NAME`=@tableName
												AND i.`COLUMN_NAME`=@columnName);

#IF @existsHoursTardy THEN  END IF;
/*UPDATE employeetimeentry et INNER JOIN tardiness t ON t.RowID=et.RowID SET et.HoursTardy=t.`LateHighPrecision`
;*/

#IF @existsHoursUnderColumn THEN  END IF;
/*UPDATE employeetimeentry et INNER JOIN earlyout eo ON eo.RowID=et.RowID SET et.HoursUndertime=eo.`TardyHighPrecision`
;*/

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
