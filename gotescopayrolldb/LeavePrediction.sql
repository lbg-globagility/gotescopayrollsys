/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `LeavePrediction`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LeavePrediction`(
	IN `organizationID` INT

,
	IN `typeOfLeave` TEXT
,
	IN `whatYear` INT


)
BEGIN

SET @orgID = organizationID;
SET @thisYear = whatYear;

SET @eID = 0;
SET @isAnotherID = FALSE;
SET @leaveBal = 0.0;
SET @ordinalIndex = 0;

DROP TEMPORARY TABLE IF EXISTS leavepredict;
DROP TABLE IF EXISTS leavepredict;
CREATE TEMPORARY TABLE leavepredict
SELECT elv.OrganizationID, elv.Created, elv.LeaveStartTime, elv.LeaveType, elv.CreatedBy, elv.LastUpd, elv.LastUpdBy, elv.EmployeeID, elv.LeaveEndTime, elv.LeaveStartDate, elv.LeaveEndDate, elv.Reason, elv.Comments, elv.Image, elv.`Status`, elv.Status2, elv.LeaveTypeID, elv.AdditionalOverrideLeaveBalance, elv.OfficialValidHours, elv.OfficialValidDays
, e.EmployeeID `EmployeUniqID`
, CONCAT_WS(', ', e.LastName, e.FirstName) `FullName`
, CONCAT(e.LastName, e.FirstName, e.MiddleName) `WholeName`
, e.LeaveAllowance, e.LeaveBalance
, e.SickLeaveAllowance, e.SickLeaveBalance
, e.OtherLeaveAllowance, e.OtherLeaveBalance
, e.AdditionalVLAllowance, e.AdditionalVLBalance
, pp.RowID `PayperiodID`
, et.VacationLeaveHours
, et.SickLeaveHours
, et.OtherLeaveHours
, et.AdditionalVLHours
, et.MaternityLeaveHours
, et.`Date`

FROM employeeleave elv
INNER JOIN employee e ON e.RowID=elv.EmployeeID
INNER JOIN employeetimeentry et ON et.EmployeeID=e.RowID AND et.`Date` BETWEEN elv.LeaveStartDate AND elv.LeaveEndDate
INNER JOIN payperiod pp ON pp.OrganizationID=e.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID AND et.`Date` BETWEEN pp.PayFromDate AND pp.PayToDate AND pp.`Year`=@thisYear
WHERE elv.OrganizationID=@orgID
AND elv.`Status` = 'Approved'
AND elv.LeaveType = typeOfLeave
#		AND elv.EmployeeID=149
ORDER BY CONCAT(e.LastName, e.FirstName, e.MiddleName), et.`Date`
;























SET @isAnotherID = FALSE;
SET @eID = 0;
SET @leaveBal = NULL;
SET @indx = 1;

IF typeOfLeave = 'Vacation leave' THEN

	DROP TEMPORARY TABLE IF EXISTS leavebalancepredict;
	DROP TABLE IF EXISTS leavebalancepredict;
	CREATE TEMPORARY TABLE leavebalancepredict
	SELECT i.*
	, (@isAnotherID := @eID != i.EmployeeID) `IsAnother`
	, IF(@isAnotherID, (@eID := i.EmployeeID), @eID) `AssignAnotherID`
	, IF(@isAnotherID
			, (@leaveBal := i.LeaveAllowance - i.VacationLeaveHours)
			, (@leaveBal := @leaveBal - i.VacationLeaveHours)) `ProperLeaveBalance`
	, IF(@isAnotherID
	     , @indx := 1
		  , (@indx := @indx + 1)) `OrdinalIndex`
	
	FROM leavepredict i
	;

ELSEIF typeOfLeave = 'Sick leave' THEN

	DROP TEMPORARY TABLE IF EXISTS leavebalancepredict;
	DROP TABLE IF EXISTS leavebalancepredict;
	CREATE TEMPORARY TABLE leavebalancepredict
	SELECT i.*
	, (@isAnotherID := @eID != i.EmployeeID) `IsAnother`
	, IF(@isAnotherID, (@eID := i.EmployeeID), @eID) `AssignAnotherID`
	, IF(@isAnotherID
			, (@leaveBal := i.LeaveAllowance - i.SickLeaveHours)
			, (@leaveBal := @leaveBal - i.SickLeaveHours)) `ProperLeaveBalance`
	, IF(@isAnotherID
	     , @indx := 1
		  , (@indx := @indx + 1)) `OrdinalIndex`
	
	FROM leavepredict i
	;

ELSEIF typeOfLeave = 'Additional VL' THEN

	DROP TEMPORARY TABLE IF EXISTS leavebalancepredict;
	DROP TABLE IF EXISTS leavebalancepredict;
	CREATE TEMPORARY TABLE leavebalancepredict
	SELECT i.*
	, (@isAnotherID := @eID != i.EmployeeID) `IsAnother`
	, IF(@isAnotherID, (@eID := i.EmployeeID), @eID) `AssignAnotherID`
	, IF(@isAnotherID
			, (@leaveBal := i.LeaveAllowance - i.AdditionalVLHours)
			, (@leaveBal := @leaveBal - i.AdditionalVLHours)) `ProperLeaveBalance`
	, IF(@isAnotherID
	     , @indx := 1
		  , (@indx := @indx + 1)) `OrdinalIndex`
	
	FROM leavepredict i
	;

ELSEIF typeOfLeave = 'Others' THEN

	DROP TEMPORARY TABLE IF EXISTS leavebalancepredict;
	DROP TABLE IF EXISTS leavebalancepredict;
	CREATE TEMPORARY TABLE leavebalancepredict
	SELECT i.*
	, (@isAnotherID := @eID != i.EmployeeID) `IsAnother`
	, IF(@isAnotherID, (@eID := i.EmployeeID), @eID) `AssignAnotherID`
	, IF(@isAnotherID
			, (@leaveBal := i.LeaveAllowance - i.OtherLeaveHours)
			, (@leaveBal := @leaveBal - i.OtherLeaveHours)) `ProperLeaveBalance`
	, IF(@isAnotherID
	     , @indx := 1
		  , (@indx := @indx + 1)) `OrdinalIndex`
	
	FROM leavepredict i
	;

ELSEIF typeOfLeave = 'Maternity/paternity leave' THEN

	DROP TEMPORARY TABLE IF EXISTS leavebalancepredict;
	DROP TABLE IF EXISTS leavebalancepredict;
	CREATE TEMPORARY TABLE leavebalancepredict
	SELECT i.*
	, (@isAnotherID := @eID != i.EmployeeID) `IsAnother`
	, IF(@isAnotherID, (@eID := i.EmployeeID), @eID) `AssignAnotherID`
	, IF(@isAnotherID
			, (@leaveBal := i.LeaveAllowance - i.MaternityLeaveHours)
			, (@leaveBal := @leaveBal - i.MaternityLeaveHours)) `ProperLeaveBalance`
	, IF(@isAnotherID
	     , @indx := 1
		  , (@indx := @indx + 1)) `OrdinalIndex`
	
	FROM leavepredict i
	;

END IF;


DROP TEMPORARY TABLE IF EXISTS currentleavebalancepredict;
DROP TABLE IF EXISTS currentleavebalancepredict;
CREATE TEMPORARY TABLE currentleavebalancepredict
SELECT i.*
, MIN(i.ProperLeaveBalance) `CurrentLeaveBalance`
, MAX(i.OrdinalIndex) `MaxOrdinalIndex`
FROM leavebalancepredict i
GROUP BY i.WholeName
;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
