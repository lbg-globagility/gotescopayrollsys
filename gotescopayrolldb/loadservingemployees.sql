/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `loadservingemployees`;
DELIMITER //
CREATE PROCEDURE `loadservingemployees`(
	IN `_orgRowId` INT,
	IN `_payPeriodId` INT,
	IN `_payFrequencyType` VARCHAR(50),
	IN `_pageNumber` INT,
	IN `_searchText` VARCHAR(50)

)
BEGIN

DECLARE _customDateFormat VARCHAR(24) DEFAULT '%m-%d-%Y';

DECLARE _limit10 INT(11) DEFAULT 10;

IF LENGTH(TRIM(_searchText)) = 0 THEN

	SELECT e.RowID,
	e.EmployeeID 'Employee ID',
	e.FirstName 'First Name',
	e.MiddleName 'Middle Name',
	e.LastName 'Last Name',
	e.Surname,
	e.Nickname,
	e.MaritalStatus 'Marital Status'
	, IFNULL(e.NoOfDependents,0) 'No. Of Dependents',
	e.Birthdate,
	e.Startdate,
	e.JobTitle 'Job Title'
	, IFNULL(pos.PositionName,'') `Position`,
	e.Salutation,
	e.TINNo `TIN`,
	e.SSSNo 'SSS No.',
	e.HDMFNo 'PAGIBIG No.',
	e.PhilHealthNo 'PhilHealth No.',
	e.WorkPhone 'Work Phone No.',
	e.HomePhone 'Home Phone No.',
	e.MobilePhone 'Mobile Phone No.',
	e.HomeAddress 'Home address',
	e.EmailAddress 'Email address', IF(e.Gender='M','Male','Female') 'Gender',
	e.EmploymentStatus 'Employment Status'
	, IFNULL(pf.PayFrequencyType,'') 'Pay Frequency',
	e.UndertimeOverride,
	e.OvertimeOverride
	, IFNULL(pos.RowID,'pos.RowID') `PositionID`
	, IFNULL(e.PayFrequencyID,'') `PayFrequencyID`,
	e.EmployeeType,
	e.LeaveBalance,
	e.SickLeaveBalance,
	e.MaternityLeaveBalance,
	e.LeaveAllowance,
	e.SickLeaveAllowance,
	e.MaternityLeaveAllowance,
	e.LeavePerPayPeriod,
	e.SickLeavePerPayPeriod,
	e.MaternityLeavePerPayPeriod
	
	, IFNULL(fstat.RowID,3) `fstatRowID`
	, NULL `Image`
	
	, DATE_FORMAT(e.Created,_customDateFormat) 'Creation Date'
	
	, CONCAT_WS(', ', u.LastName, u.FirstName) 'Created by'
	
	, IFNULL(DATE_FORMAT(e.LastUpd,_customDateFormat),'') 'Last Update'
	
	, CONCAT_WS(', ', upd.LastName, upd.FirstName) 'LastUpdate by'
	
	FROM employee_servedperiod e
	
	LEFT JOIN `user` u
	       ON e.CreatedBy=u.RowID
	LEFT JOIN `user` upd
	       ON e.LastUpdBy=upd.RowID
	
	LEFT JOIN `position` pos
	       ON e.PositionID=pos.RowID
	LEFT JOIN payfrequency pf
	       ON e.PayFrequencyID=pf.RowID
	LEFT JOIN filingstatus fstat
	       ON fstat.MaritalStatus=e.MaritalStatus
			    AND fstat.Dependent=e.NoOfDependents
	
	WHERE e.OrganizationID=_orgRowId
	AND pf.PayFrequencyType=_payFrequencyType
	AND e.ServedPeriodId=_payPeriodId
	
	ORDER BY CONCAT(e.LastName, e.FirstName)
	         , FIELD(e.EmploymentStatus,'Retired','Resigned','Terminated')
				, FIELD(e.RevealInPayroll,'1','0')
	LIMIT _pageNumber, _limit10;

ELSE

	SET _searchText = CONCAT('%', _searchText, '%');
	
	SELECT e.RowID,
	e.EmployeeID 'Employee ID',
	e.FirstName 'First Name',
	e.MiddleName 'Middle Name',
	e.LastName 'Last Name',
	e.Surname,
	e.Nickname,
	e.MaritalStatus 'Marital Status'
	, IFNULL(e.NoOfDependents,0) 'No. Of Dependents',
	e.Birthdate,
	e.Startdate,
	e.JobTitle 'Job Title'
	, IFNULL(pos.PositionName,'') `Position`,
	e.Salutation,
	e.TINNo `TIN`,
	e.SSSNo 'SSS No.',
	e.HDMFNo 'PAGIBIG No.',
	e.PhilHealthNo 'PhilHealth No.',
	e.WorkPhone 'Work Phone No.',
	e.HomePhone 'Home Phone No.',
	e.MobilePhone 'Mobile Phone No.',
	e.HomeAddress 'Home address',
	e.EmailAddress 'Email address', IF(e.Gender='M','Male','Female') 'Gender',
	e.EmploymentStatus 'Employment Status'
	, IFNULL(pf.PayFrequencyType,'') 'Pay Frequency',
	e.UndertimeOverride,
	e.OvertimeOverride
	, IFNULL(pos.RowID,'pos.RowID') `PositionID`
	, IFNULL(e.PayFrequencyID,'') `PayFrequencyID`,
	e.EmployeeType,
	e.LeaveBalance,
	e.SickLeaveBalance,
	e.MaternityLeaveBalance,
	e.LeaveAllowance,
	e.SickLeaveAllowance,
	e.MaternityLeaveAllowance,
	e.LeavePerPayPeriod,
	e.SickLeavePerPayPeriod,
	e.MaternityLeavePerPayPeriod
	
	, IFNULL(fstat.RowID,3) `fstatRowID`
	, NULL `Image`
	
	, DATE_FORMAT(e.Created,_customDateFormat) 'Creation Date'
	
	, CONCAT_WS(', ', u.LastName, u.FirstName) 'Created by'
	
	, IFNULL(DATE_FORMAT(e.LastUpd,_customDateFormat),'') 'Last Update'
	
	, CONCAT_WS(', ', upd.LastName, upd.FirstName) 'LastUpdate by'
	
	FROM employee_servedperiod e
	
	LEFT JOIN `user` u
	       ON e.CreatedBy=u.RowID
	LEFT JOIN `user` upd
	       ON e.LastUpdBy=upd.RowID
	
	LEFT JOIN `position` pos
	       ON e.PositionID=pos.RowID
	LEFT JOIN payfrequency pf
	       ON e.PayFrequencyID=pf.RowID
	LEFT JOIN filingstatus fstat
	       ON fstat.MaritalStatus=e.MaritalStatus
			    AND fstat.Dependent=e.NoOfDependents
	
	WHERE e.OrganizationID=_orgRowId
	AND pf.PayFrequencyType=_payFrequencyType
	AND e.ServedPeriodId=_payPeriodId
	AND (e.LastName LIKE _searchText
	     OR e.FirstName LIKE _searchText
		  OR e.EmployeeID LIKE _searchText)
	
	ORDER BY CONCAT(e.LastName, e.FirstName)
	         , FIELD(e.EmploymentStatus,'Retired','Resigned','Terminated')
				, FIELD(e.RevealInPayroll,'1','0')
	LIMIT _pageNumber, _limit10;

END IF;
	
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
