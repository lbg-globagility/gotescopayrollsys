/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP FUNCTION IF EXISTS `INSUPD_employeetimeentrydetails`;
DELIMITER //
CREATE FUNCTION `INSUPD_employeetimeentrydetails`(`etentd_RowID` INT, `etentd_OrganizationID` INT, `etentd_CreatedBy` INT, `etentd_Created` DATETIME, `etentd_LastUpdBy` INT, `etentd_EmployeeID` VARCHAR(50), `etentd_TimeIn` TIME, `etentd_TimeOut` TIME, `etentd_Date` DATE, `etentd_TimeScheduleType` VARCHAR(50), `etentd_TimeEntryStatus` VARCHAR(50), `EditAsUnique` CHAR(1)) RETURNS int(11)
    DETERMINISTIC
BEGIN

DECLARE etentdID INT(11) DEFAULT -1;

DECLARE branch_rowid INT(11);

SET EditAsUnique = 0;

IF etentd_RowID IS NULL AND EditAsUnique = 1 THEN

	SELECT etd.RowID
	FROM employeetimeentrydetails etd
	INNER JOIN employee e ON e.RowID=etd.EmployeeID AND e.OrganizationID=etd.OrganizationID AND e.EmployeeID=etentd_EmployeeID 
	WHERE etd.OrganizationID=etentd_OrganizationID
	AND etd.Created			=etentd_Created
	AND etd.`Date`				=etentd_Date
	LIMIT 1
	INTO etentd_RowID;
	
END IF;

IF EditAsUnique = '1'
	AND EXISTS(SELECT RowID FROM employee WHERE OrganizationID=etentd_OrganizationID AND EmployeeID=etentd_EmployeeID LIMIT 1) = '1' THEN
	INSERT INTO employeetimeentrydetails
	(
		RowID
		,OrganizationID
		,Created
		,CreatedBy
		,EmployeeID
		,TimeIn
		,TimeOut
		,`Date`
		,TimeScheduleType
		,TimeEntryStatus
	) VALUES (
		etentd_RowID
		,etentd_OrganizationID
		,etentd_Created
		,etentd_CreatedBy
		,(SELECT RowID FROM employee WHERE OrganizationID=etentd_OrganizationID AND EmployeeID=etentd_EmployeeID LIMIT 1)
		,etentd_TimeIn
		,etentd_TimeOut
		,etentd_Date
		,etentd_TimeScheduleType
		,IFNULL(etentd_TimeEntryStatus,IF(IFNULL(etentd_TimeIn,'') = '', 'missing clock in', IF(IFNULL(etentd_TimeOut,'') = '', 'missing clock out', '')))
	) ON 
	DUPLICATE 
	KEY 
	UPDATE
		LastUpd=CURRENT_TIMESTAMP()
		,LastUpdBy=etentd_LastUpdBy
		,TimeScheduleType=etentd_TimeScheduleType;SELECT @@Identity AS id INTO etentdID;

ELSE
	IF EXISTS(SELECT RowID FROM employee WHERE OrganizationID=etentd_OrganizationID AND EmployeeID=etentd_EmployeeID LIMIT 1) = '1' THEN
	INSERT INTO employeetimeentrydetails
	(
		RowID,
		OrganizationID
		,Created
		,CreatedBy
		,EmployeeID
		,TimeIn
		,TimeOut
		,`Date`
		,TimeScheduleType
		,TimeEntryStatus
	) #VALUES (
		SELECT etentd_RowID,
		etentd_OrganizationID
		,etentd_Created
		,etentd_CreatedBy
		,(SELECT RowID FROM employee WHERE OrganizationID=etentd_OrganizationID AND EmployeeID=etentd_EmployeeID LIMIT 1)
		,etentd_TimeIn
		,etentd_TimeOut
		,etentd_Date
		,etentd_TimeScheduleType
		,IFNULL(etentd_TimeEntryStatus,IF(IFNULL(etentd_TimeIn,'') = '', 'missing clock in', IF(IFNULL(etentd_TimeOut,'') = '', 'missing clock out', '')))
	UNION
		SELECT
		etd.RowID
		,etd.OrganizationID
		,etd.Created
		,etentd_CreatedBy
		,etd.EmployeeID
		,etentd_TimeIn
		,etentd_TimeOut
		,etd.`Date`
		,etentd_TimeScheduleType
		,IFNULL(etentd_TimeEntryStatus,IF(IFNULL(etentd_TimeIn,'') = '', 'missing clock in', IF(IFNULL(etentd_TimeOut,'') = '', 'missing clock out', '')))
		FROM employeetimeentrydetails etd
		WHERE etd.RowID			!=IFNULL(etentd_RowID,0)
		AND etd.OrganizationID	=etentd_OrganizationID
		AND etd.EmployeeID		=etentd_EmployeeID
		AND etd.`Date`				=etentd_Date
	ON 
	DUPLICATE 
	KEY 
	UPDATE
		LastUpd=CURRENT_TIMESTAMP()
		,LastUpdBy=etentd_LastUpdBy
		,TimeIn = etentd_TimeIn
		,TimeOut = etentd_TimeOut
		,`Date` = etentd_Date
		,TimeScheduleType=etentd_TimeScheduleType;SELECT @@Identity AS id INTO etentdID;
	END IF;
END IF;

RETURN etentdID;

/*DECLARE etentdID INT(11) DEFAULT -1;

IF etentd_RowID IS NULL THEN

	SELECT RowID FROM employeetimeentrydetails WHERE OrganizationID=etentd_OrganizationID AND EmployeeID=etentd_EmployeeID AND `Date`=etentd_Date INTO etentd_RowID;
	
END IF;

IF EditAsUnique = '1' THEN

	INSERT INTO employeetimeentrydetails
	(
		RowID
		,OrganizationID
		,Created
		,CreatedBy
		,EmployeeID
		,TimeIn
		,TimeOut
		,`Date`
		,TimeScheduleType
		,TimeEntryStatus)
	
		SELECT etentd_RowID
		,etentd_OrganizationID
		,etentd_Created
		,etentd_CreatedBy
		,e.RowID
		,etentd_TimeIn
		,etentd_TimeOut
		,etentd_Date
		,etentd_TimeScheduleType
		,COALESCE(etentd_TimeEntryStatus,IF(COALESCE(etentd_TimeIn,'') = '', 'missing clock in', IF(COALESCE(etentd_TimeOut,'') = '', 'missing clock out', ''))) FROM employee e WHERE e.OrganizationID=etentd_OrganizationID AND e.EmployeeID=etentd_EmployeeID LIMIT 1
	
	ON DUPLICATE 
	KEY 
	UPDATE
		LastUpd=CURRENT_TIMESTAMP()
		,LastUpdBy=etentd_LastUpdBy;SELECT @@Identity AS id INTO etentdID;

ELSE
	
	INSERT INTO employeetimeentrydetails
	(
		RowID
		,OrganizationID
		,Created
		,CreatedBy
		,EmployeeID
		,TimeIn
		,TimeOut
		,`Date`
		,TimeScheduleType
		,TimeEntryStatus)
	
		SELECT etentd_RowID
		,etentd_OrganizationID
		,etentd_Created
		,etentd_CreatedBy
		,e.RowID
		,etentd_TimeIn
		,etentd_TimeOut
		,etentd_Date
		,etentd_TimeScheduleType
		,COALESCE(etentd_TimeEntryStatus,IF(COALESCE(etentd_TimeIn,'') = '', 'missing clock in', IF(COALESCE(etentd_TimeOut,'') = '', 'missing clock out', ''))) FROM employee e WHERE e.OrganizationID=etentd_OrganizationID AND e.EmployeeID=etentd_EmployeeID LIMIT 1
	
	ON DUPLICATE 
	KEY 
	UPDATE
		LastUpd=CURRENT_TIMESTAMP()
		,LastUpdBy=etentd_LastUpdBy
		,TimeIn = etentd_TimeIn
		,TimeOut = etentd_TimeOut
		,`Date` = etentd_Date;SELECT @@Identity AS id INTO etentdID;

END IF;

RETURN etentdID;*/

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
