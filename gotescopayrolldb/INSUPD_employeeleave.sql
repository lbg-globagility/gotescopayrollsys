/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP FUNCTION IF EXISTS `INSUPD_employeeleave`;
DELIMITER //
CREATE FUNCTION `INSUPD_employeeleave`(`elv_RowID` INT, `elv_OrganizationID` INT, `elv_LeaveStartTime` TIME, `elv_LeaveType` VARCHAR(50), `elv_CreatedBy` INT, `elv_LastUpdBy` INT, `elv_EmployeeID` INT, `elv_LeaveEndTime` TIME, `elv_LeaveStartDate` DATE, `elv_LeaveEndDate` DATE, `elv_Reason` VARCHAR(500), `elv_Comments` VARCHAR(2000), `elv_Image` LONGBLOB, `elv_Status` VARCHAR(50), `elv_OverrideLeaveBal` DECIMAL(11,2)) RETURNS int(11)
    DETERMINISTIC
BEGIN

DECLARE empleaveID INT(11);

DECLARE specialty CONDITION FOR SQLSTATE '45000';
 
DECLARE emp_employment_stat TEXT;

DECLARE elv_LeaveTypeID INT(11) DEFAULT NULL;

DECLARE is_deptmngr BOOL DEFAULT FALSE;

SET is_deptmngr = IS_USER_DEPTMNGR(elv_OrganizationID, elv_CreatedBy);

SELECT EmploymentStatus FROM employee WHERE RowID=elv_EmployeeID INTO emp_employment_stat;

SELECT p.RowID FROM product p WHERE p.PartNo=elv_LeaveType AND p.OrganizationID=elv_OrganizationID AND p.`Category`='Leave Type' LIMIT 1 INTO elv_LeaveTypeID;
SET emp_employment_stat = 'Regular';
IF emp_employment_stat = 'Regular' THEN

	IF is_deptmngr = TRUE THEN
	
		UPDATE employeeleave elv
		SET
		elv.LeaveStartTime=elv_LeaveStartTime
		,elv.LeaveType=elv_LeaveType
		,elv.LastUpd=CURRENT_TIMESTAMP()
		,elv.LastUpdBy=elv_LastUpdBy
		,elv.LeaveEndTime=elv_LeaveEndTime
		,elv.LeaveStartDate=elv_LeaveStartDate
		,elv.LeaveEndDate=elv_LeaveEndDate
		,elv.Reason=elv_Reason
		,elv.Comments=elv_Comments
		,elv.Image=elv_Image
		,elv.Status2=IF(elv_Status = '', 'Pending', elv_Status)
		,elv.LeaveTypeID=elv_LeaveTypeID
		,elv.AdditionalOverrideLeaveBalance=elv_OverrideLeaveBal
		WHERE RowID=elv_RowID;
		
	ELSE
	
		INSERT INTO employeeleave
		(
			RowID
			,OrganizationID
			,Created
			,LeaveStartTime
			,LeaveType
			,CreatedBy
			,LastUpdBy
			,EmployeeID
			,LeaveEndTime
			,LeaveStartDate
			,LeaveEndDate
			,Reason
			,Comments
			,Image
			,`Status`
			,LeaveTypeID
			,AdditionalOverrideLeaveBalance
			,Status2
		) VALUES (
			elv_RowID
			,elv_OrganizationID
			,CURRENT_TIMESTAMP()
			,elv_LeaveStartTime
			,elv_LeaveType
			,elv_CreatedBy
			,elv_LastUpdBy
			,elv_EmployeeID
			,elv_LeaveEndTime
			,elv_LeaveStartDate
			,elv_LeaveEndDate
			,elv_Reason
			,elv_Comments
			,elv_Image
			,IF(elv_Status = '', 'Pending', elv_Status)
			,elv_LeaveTypeID
			,elv_OverrideLeaveBal
			,IF(elv_Status = '', 'Pending', elv_Status)
		) ON 
		DUPLICATE 
		KEY 
		UPDATE 
			LeaveStartTime=elv_LeaveStartTime
			,LeaveType=elv_LeaveType
			,LastUpd=CURRENT_TIMESTAMP()
			,LastUpdBy=elv_LastUpdBy
			,LeaveEndTime=elv_LeaveEndTime
			,LeaveStartDate=elv_LeaveStartDate
			,LeaveEndDate=elv_LeaveEndDate
			,Reason=elv_Reason
			,Comments=elv_Comments
			,Image=elv_Image
			,`Status`=IF(elv_Status = '', 'Pending', elv_Status)
			,LeaveTypeID=elv_LeaveTypeID
			,AdditionalOverrideLeaveBalance=elv_OverrideLeaveBal
			# ,Status2=IF(elv_Status = '', 'Pending', elv_Status)
			;SELECT @@Identity AS id INTO empleaveID;

	END IF;
	
ELSE

	SIGNAL specialty
	SET MESSAGE_TEXT = 'LEAVE FILING APPLIES ONLY TO REGULAR EMPLOYEES';
	
	SET empleaveID = 0;
	
END IF;



RETURN empleaveID;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
