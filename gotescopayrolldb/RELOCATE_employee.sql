/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `RELOCATE_employee`;
DELIMITER //
CREATE PROCEDURE `RELOCATE_employee`()
    DETERMINISTIC
BEGIN

/*
DISABLE FIRST THIS TRIGGER : AFTUPD_employee_then_employeesalary
*/

SET @orgID = 1;

INSERT INTO employee (CreatedBy, Created, LastUpdBy, LastUpd, OrganizationID, Salutation, FirstName, MiddleName, LastName, Surname, EmployeeID, TINNo, SSSNo, HDMFNo, PhilHealthNo, EmploymentStatus, EmailAddress, WorkPhone, HomePhone, MobilePhone, HomeAddress, Nickname, JobTitle, Gender, EmployeeType, MaritalStatus, Birthdate, StartDate, TerminationDate, PositionID, PayFrequencyID, NoOfDependents, UndertimeOverride, OvertimeOverride, NewEmployeeFlag, LeaveBalance, SickLeaveBalance, MaternityLeaveBalance, OtherLeaveBalance, LeaveAllowance, SickLeaveAllowance, MaternityLeaveAllowance, OtherLeaveAllowance, Image, LeavePerPayPeriod, SickLeavePerPayPeriod, MaternityLeavePerPayPeriod, OtherLeavePerPayPeriod, AlphaListExempted, WorkDaysPerYear, DayOfRest, ATMNo, BankName, CalcHoliday, CalcSpecialHoliday, CalcNightDiff, CalcNightDiffOT, CalcRestDay, CalcRestDayOT, DateRegularized, DateEvaluated, RevealInPayroll, LateGracePeriod, AgencyID, OffsetBalance, DateR1A, AdditionalVLAllowance, AdditionalVLBalance, AdditionalVLPerPayPeriod, LeaveTenthYearService, LeaveFifteenthYearService, LeaveAboveFifteenthYearService, DeptManager)
SELECT
e.`CreatedBy`, CURRENT_TIMESTAMP() `Created`, e. `LastUpdBy`, CURRENT_TIMESTAMP() `LastUpd`, newog.RowID `OrganizationID`, e. `Salutation`, e. `FirstName`, e. `MiddleName`, e. `LastName`, e. `Surname`, e. `EmployeeID`, e. `TINNo`, e. `SSSNo`, e. `HDMFNo`, e. `PhilHealthNo`, e. `EmploymentStatus`, e. `EmailAddress`, e. `WorkPhone`, e. `HomePhone`, e. `MobilePhone`, e. `HomeAddress`, e. `Nickname`, e. `JobTitle`, e. `Gender`, e. `EmployeeType`, e. `MaritalStatus`, e. `Birthdate`, e. `StartDate`, e. `TerminationDate`, newpos.RowID `PositionID`, e. `PayFrequencyID`, e. `NoOfDependents`, e. `UndertimeOverride`, e. `OvertimeOverride`, e. `NewEmployeeFlag`, e. `LeaveBalance`, e. `SickLeaveBalance`, e. `MaternityLeaveBalance`, e. `OtherLeaveBalance`, e. `LeaveAllowance`, e. `SickLeaveAllowance`, e. `MaternityLeaveAllowance`, e. `OtherLeaveAllowance`, e. `Image`, e. `LeavePerPayPeriod`, e. `SickLeavePerPayPeriod`, e. `MaternityLeavePerPayPeriod`, e. `OtherLeavePerPayPeriod`, e. `AlphaListExempted`, e. `WorkDaysPerYear`, e. `DayOfRest`, e. `ATMNo`, e. `BankName`, e. `CalcHoliday`, e. `CalcSpecialHoliday`, e. `CalcNightDiff`, e. `CalcNightDiffOT`, e. `CalcRestDay`, e. `CalcRestDayOT`, e. `DateRegularized`, e. `DateEvaluated`, e. `RevealInPayroll`, e. `LateGracePeriod`, e. `AgencyID`, e. `OffsetBalance`, e. `DateR1A`, e. `AdditionalVLAllowance`, e. `AdditionalVLBalance`, e. `AdditionalVLPerPayPeriod`, e. `LeaveTenthYearService`, e. `LeaveFifteenthYearService`, e. `LeaveAboveFifteenthYearService`, newdptmgr.RowID `DeptManager`

FROM employee e
INNER JOIN separategmi i ON i.EmployeeID=e.EmployeeID AND i.OrganizationName NOT IN ('gt', 'gmi')
INNER JOIN `position` epos ON epos.RowID=e.PositionID
LEFT JOIN `position` dptmgr ON dptmgr.RowID=e.DeptManager

INNER JOIN organization newog ON newog.`Name` = i.CompanyName

INNER JOIN `position` newpos ON newpos.PositionName=epos.PositionName AND newpos.OrganizationID=newog.RowID
LEFT JOIN `position` newdptmgr ON newdptmgr.PositionName=dptmgr.PositionName AND newdptmgr.OrganizationID=newog.RowID

WHERE e.OrganizationID = @orgID
ON DUPLICATE KEY UPDATE LastUpd=CURRENT_TIMESTAMP()#, LastUpdBy=IF(e.LastUpdBy, e.CreatedBy)
;










SET @eIDs = NULL;

SELECT GROUP_CONCAT(ee.RowID)
FROM separategmi i
INNER JOIN organization og ON og.`Name`=i.CompanyName
INNER JOIN employee ee ON ee.EmployeeID=i.EmployeeID AND ee.OrganizationID=og.RowID
INTO @eIDs
;


SET @eNos = NULL;

SELECT GROUP_CONCAT(i.EmployeeID)
FROM separategmi i
INNER JOIN organization og ON og.`Name`=i.CompanyName
INNER JOIN employee ee ON ee.EmployeeID=i.EmployeeID AND ee.OrganizationID=og.RowID
INTO @eNos
;




IF EXISTS(SELECT RowID FROM employeesalary WHERE FIND_IN_SET(EmployeeID, @eIDs) > 0)
	THEN

	DELETE FROM employeesalary WHERE FIND_IN_SET(EmployeeID, @eIDs) > 0; ALTER TABLE employeesalary AUTO_INCREMENT = 0;

END IF;

INSERT INTO `employeesalary` (`EmployeeID`, `Created`, `CreatedBy`, `LastUpd`, `LastUpdBy`, `OrganizationID`, `FilingStatusID`, `PaySocialSecurityID`, `PayPhilhealthID`, `PhilHealthDeduction`, `HDMFAmount`, `TrueSalary`, `BasicPay`, `Salary`, `UndeclaredSalary`, `BasicDailyPay`, `BasicHourlyPay`, `NoofDependents`, `MaritalStatus`, `PositionID`, `EffectiveDateFrom`, `EffectiveDateTo`, `ContributeToGovt`, `OverrideDiscardSSSContrib`, `OverrideDiscardPhilHealthContrib`)
SELECT
ee.RowID `EmployeeID`, CURRENT_TIMESTAMP() Created, es. CreatedBy, CURRENT_TIMESTAMP() LastUpd, es. LastUpdBy, og.RowID `OrganizationID`, es. FilingStatusID, es. PaySocialSecurityID, es. PayPhilhealthID, es. PhilHealthDeduction, es. HDMFAmount, es. TrueSalary, es. BasicPay, es. Salary, es. UndeclaredSalary, es. BasicDailyPay, es. BasicHourlyPay, es. NoofDependents, es. MaritalStatus, ee.PositionID `PositionID`, es. EffectiveDateFrom, es. EffectiveDateTo, es. ContributeToGovt, es. OverrideDiscardSSSContrib, es. OverrideDiscardPhilHealthContrib

FROM employeesalary es
INNER JOIN employee e ON e.RowID=es.EmployeeID AND FIND_IN_SET(e.EmployeeID, @eNos) > 0
INNER JOIN separategmi i ON i.EmployeeID=e.EmployeeID
INNER JOIN organization og ON og.`Name`=i.CompanyName
INNER JOIN employee ee ON ee.OrganizationID=og.RowID AND ee.EmployeeID=i.EmployeeID
WHERE es.OrganizationID = @orgID
ON DUPLICATE KEY UPDATE LastUpd=CURRENT_TIMESTAMP()
;


















DELETE FROM employeeallowance WHERE FIND_IN_SET(EmployeeID, @eIDs) > 0; ALTER TABLE employeeallowance AUTO_INCREMENT = 0;

INSERT INTO `employeeallowance` (`OrganizationID`, `Created`, `CreatedBy`, `LastUpd`, `LastUpdBy`, `EmployeeID`, `ProductID`, `EffectiveStartDate`, `AllowanceFrequency`, `EffectiveEndDate`, `TaxableFlag`, `AllowanceAmount`)
SELECT
og.RowID `OrganizationID`, CURRENT_TIMESTAMP() `Created`, ea. CreatedBy, CURRENT_TIMESTAMP() `LastUpd`, ea. LastUpdBy, ee.RowID `EmployeeID`, p.RowID `ProductID`, ea. EffectiveStartDate, ea. AllowanceFrequency, ea. EffectiveEndDate, ea. TaxableFlag, ea. AllowanceAmount
FROM employeeallowance ea
INNER JOIN employee e ON e.RowID=ea.EmployeeID

INNER JOIN separategmi i ON i.EmployeeID=e.EmployeeID
INNER JOIN organization og ON og.`Name`=i.CompanyName
INNER JOIN employee ee ON ee.OrganizationID=og.RowID AND ee.EmployeeID=i.EmployeeID

INNER JOIN product item ON item.RowID=ea.ProductID
INNER JOIN product p ON p.PartNo=item.PartNo AND p.OrganizationID=og.RowID

WHERE ea.OrganizationID = @orgID
ON DUPLICATE KEY UPDATE LastUpd=CURRENT_TIMESTAMP()
;
















DELETE FROM employeeloanschedule WHERE FIND_IN_SET(EmployeeID, @eIDs) > 0; ALTER TABLE employeeloanschedule AUTO_INCREMENT = 0;

INSERT INTO `employeeloanschedule` (`OrganizationID`, `Created`, `CreatedBy`, `LastUpd`, `LastUpdBy`, `EmployeeID`, `LoanNumber`, `DedEffectiveDateFrom`, `DedEffectiveDateTo`, `TotalLoanAmount`, `DeductionSchedule`, `TotalBalanceLeft`, `DeductionAmount`, `Status`, `LoanTypeID`, `DeductionPercentage`, `NoOfPayPeriod`, `LoanPayPeriodLeft`, `Comments`, `Nondeductible`, `SubstituteEndDate`)
SELECT
og.RowID `OrganizationID`, CURRENT_TIMESTAMP() `Created`, els. CreatedBy, CURRENT_TIMESTAMP() `LastUpd`, els. LastUpdBy, ee.RowID `EmployeeID`, els. LoanNumber, els. DedEffectiveDateFrom, els. DedEffectiveDateTo, els. TotalLoanAmount, els. DeductionSchedule, els. TotalBalanceLeft, els. DeductionAmount, els. `Status`, els. LoanTypeID, els. DeductionPercentage, els. NoOfPayPeriod, els. LoanPayPeriodLeft, els. Comments, els. Nondeductible, els. SubstituteEndDate
FROM employeeloanschedule els
INNER JOIN employee e ON e.RowID=els.EmployeeID

INNER JOIN separategmi i ON i.EmployeeID=e.EmployeeID
INNER JOIN organization og ON og.`Name`=i.CompanyName
INNER JOIN employee ee ON ee.OrganizationID=og.RowID AND ee.EmployeeID=i.EmployeeID

INNER JOIN product item ON item.RowID=els.LoanTypeID
INNER JOIN product p ON p.PartNo=item.PartNo AND p.OrganizationID=og.RowID

WHERE els.OrganizationID = @orgID
ON DUPLICATE KEY UPDATE LastUpd=CURRENT_TIMESTAMP()
;








INSERT INTO `shift` (`OrganizationID`, `Created`, `CreatedBy`, `LastUpd`, `LastUpdBy`, `TimeFrom`, `TimeTo`, `BreakTimeFrom`, `BreakTimeTo`, `DivisorToDailyRate`)
SELECT og.RowID, CURRENT_TIMESTAMP(), og.CreatedBy, CURRENT_TIMESTAMP(), og.LastUpdBy, i.TimeFrom, i.TimeTo, i.BreakTimeFrom, i.BreakTimeTo, i.DivisorToDailyRate
FROM organization og
INNER JOIN (SELECT sh.*
				FROM shift sh
				GROUP BY sh.TimeFrom, sh.TimeTo) i ON i.RowID IS NOT NULL
WHERE og.RowID IN (13,14,15,16,18)
AND og.NoPurpose=FALSE
ON DUPLICATE KEY UPDATE LastUpd=CURRENT_TIMESTAMP()
;

INSERT INTO `employeeshift` (`OrganizationID`, `Created`, `CreatedBy`, `LastUpd`, `LastUpdBy`, `EmployeeID`, `ShiftID`, `EffectiveFrom`, `EffectiveTo`, `NightShift`, `RestDay`, `IsEncodedByDay`)
SELECT og.RowID, CURRENT_TIMESTAMP(), esh.CreatedBy, CURRENT_TIMESTAMP(), esh.LastUpdBy, ee.RowID, s.RowID, esh.EffectiveFrom, esh.EffectiveTo, esh.NightShift, esh.RestDay, esh.IsEncodedByDay
FROM employeeshift esh
INNER JOIN employee e ON e.RowID=esh.EmployeeID

INNER JOIN separategmi i ON i.EmployeeID=e.EmployeeID
INNER JOIN organization og ON og.`Name`=i.CompanyName
INNER JOIN employee ee ON ee.OrganizationID=og.RowID AND ee.EmployeeID=i.EmployeeID

LEFT JOIN shift sh ON sh.RowID=esh.ShiftID

LEFT JOIN shift s ON s.OrganizationID=og.RowID AND s.TimeFrom=sh.TimeFrom AND s.TimeTo=sh.TimeTo

WHERE esh.OrganizationID = @orgID
ON DUPLICATE KEY UPDATE LastUpd=CURRENT_TIMESTAMP()
;


DELETE FROM employeetimeentrydetails WHERE FIND_IN_SET(EmployeeID, @eIDs) > 0; ALTER TABLE employeetimeentrydetails AUTO_INCREMENT = 0;

INSERT INTO `employeetimeentrydetails` (`OrganizationID`, `Created`, `CreatedBy`, `LastUpd`, `LastUpdBy`, `EmployeeID`, `TimeIn`, `TimeOut`, `Date`, `TimeScheduleType`, `TimeEntryStatus`, `TimeStampIn`, `TimeStampOut`, `TimeentrylogsImportID`)
SELECT og.RowID, CURRENT_TIMESTAMP(), etd.CreatedBy, CURRENT_TIMESTAMP(), etd.LastUpdBy, ee.RowID, etd.TimeIn, etd.TimeOut, etd.`Date`, etd.TimeScheduleType, etd.TimeEntryStatus, etd.TimeStampIn, etd.TimeStampOut, etd.TimeentrylogsImportID
FROM employeetimeentrydetails etd
INNER JOIN employee e ON e.RowID=etd.EmployeeID

INNER JOIN separategmi i ON i.EmployeeID=e.EmployeeID
INNER JOIN organization og ON og.`Name`=i.CompanyName
INNER JOIN employee ee ON ee.OrganizationID=og.RowID AND ee.EmployeeID=i.EmployeeID
;



















DELETE FROM employeeofficialbusiness WHERE FIND_IN_SET(EmployeeID, @eIDs) > 0; ALTER TABLE employeeofficialbusiness AUTO_INCREMENT = 0;

INSERT INTO `employeeofficialbusiness` (`OrganizationID`, `Created`, `OffBusStartTime`, `OffBusType`, `OffBusStatus`, `OffBusStatus2`, `CreatedBy`, `LastUpd`, `LastUpdBy`, `EmployeeID`, `OffBusEndTime`, `OffBusStartDate`, `OffBusEndDate`, `Reason`, `Comments`, `Image`)
SELECT og.RowID `OrganizationID`
,CURRENT_TIMESTAMP()
,ob.OffBusStartTime
,ob.OffBusType
,ob.OffBusStatus
,ob.OffBusStatus2
,ob.CreatedBy
,CURRENT_TIMESTAMP()
,ob.LastUpdBy
,ee.RowID `EmployeeID`
,ob.OffBusEndTime
,ob.OffBusStartDate
,ob.OffBusEndDate
,ob.Reason
,ob.Comments
,ob.Image
FROM employeeofficialbusiness ob
INNER JOIN employee e ON e.RowID=ob.EmployeeID

INNER JOIN separategmi i ON i.EmployeeID=e.EmployeeID
INNER JOIN organization og ON og.`Name`=i.CompanyName
INNER JOIN employee ee ON ee.OrganizationID=og.RowID AND ee.EmployeeID=i.EmployeeID
ON DUPLICATE KEY UPDATE LastUpd=CURRENT_TIMESTAMP()
;























DELETE FROM employeeovertime WHERE FIND_IN_SET(EmployeeID, @eIDs) > 0; ALTER TABLE employeeovertime AUTO_INCREMENT = 0;

INSERT INTO `employeeovertime` (`OrganizationID`, `Created`, `OTStartTime`, `OTType`, `OTStatus`, `OTStatus2`, `CreatedBy`, `LastUpd`, `LastUpdBy`, `EmployeeID`, `OTEndTime`, `OfficialValidHours`, `OfficialValidNightDiffHours`, `OTStartDate`, `OTEndDate`, `Reason`, `Comments`, `Image`)
SELECT og.RowID, CURRENT_TIMESTAMP(), ot.OTStartTime, ot.OTType, ot.OTStatus, ot.OTStatus2, ot.CreatedBy, CURRENT_TIMESTAMP(), ot.LastUpdBy, ee.RowID, ot.OTEndTime, ot.OfficialValidHours, ot.OfficialValidNightDiffHours, ot.OTStartDate, ot.OTEndDate, ot.Reason, ot.Comments, ot.Image
FROM employeeovertime ot
INNER JOIN employee e ON e.RowID=ot.EmployeeID

INNER JOIN separategmi i ON i.EmployeeID=e.EmployeeID
INNER JOIN organization og ON og.`Name`=i.CompanyName
INNER JOIN employee ee ON ee.OrganizationID=og.RowID AND ee.EmployeeID=i.EmployeeID
ON DUPLICATE KEY UPDATE LastUpd=CURRENT_TIMESTAMP()
;
















DELETE FROM employeeleave WHERE FIND_IN_SET(EmployeeID, @eIDs) > 0; ALTER TABLE employeeleave AUTO_INCREMENT = 0;

INSERT INTO `employeeleave` (`OrganizationID`, `Created`, `LeaveStartTime`, `LeaveType`, `CreatedBy`, `LastUpd`, `LastUpdBy`, `EmployeeID`, `LeaveEndTime`, `LeaveStartDate`, `LeaveEndDate`, `Reason`, `Comments`, `Image`, `Status`, `Status2`, `LeaveTypeID`, `AdditionalOverrideLeaveBalance`, `OfficialValidHours`, `OfficialValidDays`)
SELECT og.RowID, CURRENT_TIMESTAMP(), elv.LeaveStartTime, elv.LeaveType, elv.CreatedBy, CURRENT_TIMESTAMP(), elv.LastUpdBy, ee.RowID, elv.LeaveEndTime, elv.LeaveStartDate, elv.LeaveEndDate, elv.Reason, elv.Comments, elv.Image, elv.`Status`, elv.Status2, p.RowID, elv.AdditionalOverrideLeaveBalance, elv.OfficialValidHours, elv.OfficialValidDays
FROM employeeleave elv
INNER JOIN employee e ON e.RowID=elv.EmployeeID

INNER JOIN separategmi i ON i.EmployeeID=e.EmployeeID
INNER JOIN organization og ON og.`Name`=i.CompanyName
INNER JOIN employee ee ON ee.OrganizationID=og.RowID AND ee.EmployeeID=i.EmployeeID

INNER JOIN product item ON item.RowID=elv.LeaveTypeID
INNER JOIN product p ON p.PartNo=item.PartNo AND p.OrganizationID=og.RowID

ON DUPLICATE KEY UPDATE LastUpd=CURRENT_TIMESTAMP()
;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
