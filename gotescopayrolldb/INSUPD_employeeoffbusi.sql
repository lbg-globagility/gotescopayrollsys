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

-- Dumping structure for function gotescopayrolldb_server.INSUPD_employeeoffbusi
DROP FUNCTION IF EXISTS `INSUPD_employeeoffbusi`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `INSUPD_employeeoffbusi`(`obf_RowID` INT, `obf_OrganizationID` INT, `obf_CreatedBy` INT, `obf_LastUpdBy` INT, `obf_EmployeeID` INT, `obf_Type` VARCHAR(50), `obf_StartTime` TIME, `obf_EndTime` TIME, `obf_StartDate` DATE, `obf_EndDate` DATE, `obf_Reason` VARCHAR(500), `obf_Comments` VARCHAR(2000), `obf_Image` LONGBLOB, `obf_OffBusStatus` VARCHAR(500)) RETURNS int(11)
    DETERMINISTIC
BEGIN

DECLARE obf_ID INT(11);

DECLARE is_deptmngr BOOL DEFAULT FALSE;

SET is_deptmngr = IS_USER_DEPTMNGR(obf_OrganizationID, obf_CreatedBy);

IF is_deptmngr = TRUE THEN

	UPDATE employeeofficialbusiness ob
	SET
	ob.LastUpd=CURRENT_TIMESTAMP()
	,ob.LastUpdBy=obf_LastUpdBy
	,ob.OffBusStartTime=obf_StartTime
	,ob.OffBusType=obf_Type
	,ob.OffBusEndTime=obf_EndTime
	,ob.OffBusStartDate=obf_StartDate
	,ob.OffBusEndDate=obf_EndDate
	,ob.Reason=IFNULL(obf_Reason, '')
	,ob.Comments=IFNULL(obf_Comments, '')
	,ob.Image=obf_Image
	,ob.OffBusStatus2=obf_OffBusStatus
	WHERE ob.RowID=obf_RowID;

ELSE

	INSERT INTO employeeofficialbusiness
	(
		RowID
		,OrganizationID
		,Created
		,OffBusStartTime
		,OffBusType
		,CreatedBy
		,EmployeeID
		,OffBusEndTime
		,OffBusStartDate
		,OffBusEndDate
		,Reason
		,Comments
		,OffBusStatus
		,Image
		,OffBusStatus2
	) VALUES (
		obf_RowID
		,obf_OrganizationID
		,CURRENT_TIMESTAMP()
		,obf_StartTime
		,obf_Type
		,obf_CreatedBy
		,obf_EmployeeID
		,obf_EndTime
		,obf_StartDate
		,obf_EndDate
		,obf_Reason
		,obf_Comments
		,obf_OffBusStatus
		,obf_Image
		,obf_OffBusStatus
	) ON
	DUPLICATE
	KEY
	UPDATE 
		LastUpd=CURRENT_TIMESTAMP()
		,LastUpdBy=obf_LastUpdBy
		,OffBusStartTime=obf_StartTime
		,OffBusType=obf_Type
		,OffBusEndTime=obf_EndTime
		,OffBusStartDate=obf_StartDate
		,OffBusEndDate=obf_EndDate
		,Reason=IFNULL(obf_Reason, '')
		,Comments=IFNULL(obf_Comments, '')
		,OffBusStatus=obf_OffBusStatus
		,Image=obf_Image
		#,OffBusStatus2=obf_OffBusStatus
		;SELECT @@Identity AS id INTO obf_ID;

END IF;
	
RETURN obf_ID;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
