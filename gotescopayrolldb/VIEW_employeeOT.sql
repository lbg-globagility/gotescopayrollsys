/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `VIEW_employeeOT`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `VIEW_employeeOT`(IN `eot_EmployeeID` INT, IN `eot_OrganizationID` INT, IN `pagenumber` INT, IN `user_rowid` INT)
    DETERMINISTIC
BEGIN

DECLARE is_deptmngr BOOL DEFAULT FALSE;

DECLARE dept_mngr_rowid INT(11);

SET is_deptmngr = IS_USER_DEPTMNGR(eot_OrganizationID, user_rowid);

SELECT u.PositionID # u.DeptMngrID
FROM `user` u
WHERE u.RowID=user_rowid
INTO dept_mngr_rowid;
	
IF is_deptmngr = TRUE THEN

	SELECT i.*
	FROM (SELECT
			eot.RowID
			,COALESCE(eot.OTType,'') `LeaveType`
			,IF(eot.OTStartTime IS NULL,'',CONCAT(SUBSTRING_INDEX(TIME_FORMAT(eot.OTStartTime,'%h:%i:%s'),':',2),RIGHT(TIME_FORMAT(eot.OTStartTime,'%r'),3))) `OTStartTime`
			,IF(eot.OTEndTime IS NULL,'',CONCAT(SUBSTRING_INDEX(TIME_FORMAT(eot.OTEndTime,'%h:%i:%s'),':',2),RIGHT(TIME_FORMAT(eot.OTEndTime,'%r'),3))) `OTEndTime`
			,COALESCE(DATE_FORMAT(eot.OTStartDate,'%m/%d/%Y'),'') `OTStartDate`
			,COALESCE(DATE_FORMAT(eot.OTEndDate,'%m/%d/%Y'),'') `OTEndDate`
			,COALESCE(eot.OTStatus2,'') `Status`
			,COALESCE(eot.Reason,'') `Reason`
			,COALESCE(eot.Comments,'') `Comments`
			,COALESCE(eot.Image,'') `Image`
			,'view this'
			,COALESCE((SELECT FileName FROM employeeattachments WHERE EmployeeID=eot.EmployeeID AND `Type`=CONCAT('Employee Overtime@',eot.RowID)),'') `FileName`
			,COALESCE((SELECT FileType FROM employeeattachments WHERE EmployeeID=eot.EmployeeID AND `Type`=CONCAT('Employee Overtime@',eot.RowID)),'') `FileExtens`
			, DATE_FORMAT(eot.Created, '%c/%e/%Y %h:%i %p') `Created`
			FROM employeeovertime eot
			INNER JOIN employee e ON e.RowID=eot.EmployeeID AND e.OrganizationID=eot.OrganizationID #AND e.DeptManager=dept_mngr_rowid
			INNER JOIN `position` pos ON pos.RowID=e.DeptManager
			INNER JOIN `position` deptmngr ON deptmngr.PositionName=pos.PositionName
			WHERE eot.OrganizationID=eot_OrganizationID
			AND eot.EmployeeID=eot_EmployeeID
			GROUP BY eot.RowID
			ORDER BY eot.OTStartDate DESC,eot.OTEndDate DESC
			) i
	LIMIT pagenumber, 10;

ELSE

	SELECT i.*
	FROM (SELECT
			eot.RowID
			,COALESCE(eot.OTType,'') `LeaveType`
			,IF(eot.OTStartTime IS NULL,'',CONCAT(SUBSTRING_INDEX(TIME_FORMAT(eot.OTStartTime,'%h:%i:%s'),':',2),RIGHT(TIME_FORMAT(eot.OTStartTime,'%r'),3))) `OTStartTime`
			,IF(eot.OTEndTime IS NULL,'',CONCAT(SUBSTRING_INDEX(TIME_FORMAT(eot.OTEndTime,'%h:%i:%s'),':',2),RIGHT(TIME_FORMAT(eot.OTEndTime,'%r'),3))) `OTEndTime`
			,COALESCE(DATE_FORMAT(eot.OTStartDate,'%m/%d/%Y'),'') `OTStartDate`
			,COALESCE(DATE_FORMAT(eot.OTEndDate,'%m/%d/%Y'),'') `OTEndDate`
			,COALESCE(eot.OTStatus,'') `Status`
			,COALESCE(eot.Reason,'') `Reason`
			,COALESCE(eot.Comments,'') `Comments`
			,COALESCE(eot.Image,'') `Image`
			,'view this'
			,COALESCE((SELECT FileName FROM employeeattachments WHERE EmployeeID=eot.EmployeeID AND `Type`=CONCAT('Employee Overtime@',eot.RowID)),'') `FileName`
			,COALESCE((SELECT FileType FROM employeeattachments WHERE EmployeeID=eot.EmployeeID AND `Type`=CONCAT('Employee Overtime@',eot.RowID)),'') `FileExtens`
			, DATE_FORMAT(eot.Created, '%c/%e/%Y %h:%i %p') `Created`
			FROM employeeovertime eot
			INNER JOIN employee e ON e.RowID=eot.EmployeeID AND e.OrganizationID=eot.OrganizationID AND e.DeptManager IS NULL
			WHERE eot.OrganizationID=eot_OrganizationID
			AND eot.EmployeeID=eot_EmployeeID
			
		UNION
			SELECT
			eot.RowID
			,COALESCE(eot.OTType,'') `LeaveType`
			,IF(eot.OTStartTime IS NULL,'',CONCAT(SUBSTRING_INDEX(TIME_FORMAT(eot.OTStartTime,'%h:%i:%s'),':',2),RIGHT(TIME_FORMAT(eot.OTStartTime,'%r'),3))) `OTStartTime`
			,IF(eot.OTEndTime IS NULL,'',CONCAT(SUBSTRING_INDEX(TIME_FORMAT(eot.OTEndTime,'%h:%i:%s'),':',2),RIGHT(TIME_FORMAT(eot.OTEndTime,'%r'),3))) `OTEndTime`
			,COALESCE(DATE_FORMAT(eot.OTStartDate,'%m/%d/%Y'),'') `OTStartDate`
			,COALESCE(DATE_FORMAT(eot.OTEndDate,'%m/%d/%Y'),'') `OTEndDate`
			,COALESCE(eot.OTStatus,'') `Status`
			,COALESCE(eot.Reason,'') `Reason`
			,COALESCE(eot.Comments,'') `Comments`
			,COALESCE(eot.Image,'') `Image`
			,'view this'
			,COALESCE((SELECT FileName FROM employeeattachments WHERE EmployeeID=eot.EmployeeID AND `Type`=CONCAT('Employee Overtime@',eot.RowID)),'') `FileName`
			,COALESCE((SELECT FileType FROM employeeattachments WHERE EmployeeID=eot.EmployeeID AND `Type`=CONCAT('Employee Overtime@',eot.RowID)),'') `FileExtens`
			, DATE_FORMAT(eot.Created, '%c/%e/%Y %h:%i %p') `Created`
			FROM employeeovertime eot
			INNER JOIN employee e
			        ON e.RowID=eot.EmployeeID
					     AND e.OrganizationID=eot.OrganizationID
						  AND e.DeptManager IS NOT NULL
						  AND eot.OTStatus2 = 'Approved'
			WHERE eot.OrganizationID=eot_OrganizationID
			AND eot.EmployeeID=eot_EmployeeID) i
	
	ORDER BY i.OTStartDate DESC, i.OTEndDate DESC
	LIMIT pagenumber, 10;
	
END IF;
	
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
