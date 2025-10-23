/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP PROCEDURE IF EXISTS `VIEW_employeeOT`;
DELIMITER //
CREATE PROCEDURE `VIEW_employeeOT`(
	IN `eot_EmployeeID` INT,
	IN `eot_OrganizationID` INT,
	IN `pagenumber` INT,
	IN `user_rowid` INT
)
    DETERMINISTIC
BEGIN

DECLARE is_deptmngr BOOL DEFAULT FALSE;

DECLARE dept_mngr_rowid INT(11);
DECLARE deptMngrJobName TEXT;

SET is_deptmngr = IS_USER_DEPTMNGR(eot_OrganizationID, user_rowid);

SELECT u.PositionID # u.DeptMngrID
, pos.PositionName
FROM `user` u
INNER JOIN `position` pos ON pos.RowID=u.PositionID
WHERE u.RowID=user_rowid
INTO dept_mngr_rowid
,deptMngrJobName;
	
IF is_deptmngr = TRUE THEN

	SELECT
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
	,COALESCE((SELECT FileName FROM employeeattachments WHERE EmployeeID=eot.EmployeeID AND `Type`=CONCAT('Employee Overtime@',eot.RowID) LIMIT 1),'') `FileName`
	,COALESCE((SELECT FileType FROM employeeattachments WHERE EmployeeID=eot.EmployeeID AND `Type`=CONCAT('Employee Overtime@',eot.RowID) LIMIT 1),'') `FileExtens`
	, DATE_FORMAT(eot.Created, '%c/%e/%Y %h:%i %p') `Created`
	FROM employeeovertime eot
	INNER JOIN employee e ON e.RowID=eot.EmployeeID AND e.OrganizationID=eot.OrganizationID #AND e.DeptManager=dept_mngr_rowid
	INNER JOIN `position` pos ON pos.RowID=e.DeptManager AND pos.PositionName=deptMngrJobName
#			INNER JOIN `position` deptmngr ON deptmngr.PositionName=pos.PositionName AND deptmngr.RowID=dept_mngr_rowid
	WHERE eot.OrganizationID=eot_OrganizationID
	AND eot.EmployeeID=eot_EmployeeID
	GROUP BY eot.RowID
	ORDER BY eot.OTStartDate DESC,eot.OTEndDate DESC
	;

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
			,COALESCE((SELECT FileName FROM employeeattachments WHERE EmployeeID=eot.EmployeeID AND `Type`=CONCAT('Employee Overtime@',eot.RowID) LIMIT 1),'') `FileName`
			,COALESCE((SELECT FileType FROM employeeattachments WHERE EmployeeID=eot.EmployeeID AND `Type`=CONCAT('Employee Overtime@',eot.RowID) LIMIT 1),'') `FileExtens`
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
			,COALESCE((SELECT FileName FROM employeeattachments WHERE EmployeeID=eot.EmployeeID AND `Type`=CONCAT('Employee Overtime@',eot.RowID) LIMIT 1),'') `FileName`
			,COALESCE((SELECT FileType FROM employeeattachments WHERE EmployeeID=eot.EmployeeID AND `Type`=CONCAT('Employee Overtime@',eot.RowID) LIMIT 1),'') `FileExtens`
			, DATE_FORMAT(eot.Created, '%c/%e/%Y %h:%i %p') `Created`
			FROM employeeovertime eot
			INNER JOIN employee e
			        ON e.RowID=eot.EmployeeID
					     AND e.OrganizationID=eot.OrganizationID
						  AND e.DeptManager IS NOT NULL
						  AND eot.OTStatus2 = 'Approved'
			WHERE eot.OrganizationID=eot_OrganizationID
			AND eot.EmployeeID=eot_EmployeeID
			) i	
	ORDER BY STR_TO_DATE(i.OTStartDate, '%m/%d/%Y') DESC, STR_TO_DATE(i.OTEndDate, '%m/%d/%Y') DESC
	;
	
END IF;
	
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
