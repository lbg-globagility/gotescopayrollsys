-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.5.5-10.0.12-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             8.3.0.4694
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for procedure gotescopayrolldb_server.RESET_employeeleave_duplicate
DROP PROCEDURE IF EXISTS `RESET_employeeleave_duplicate`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `RESET_employeeleave_duplicate`(IN `OrganizID` INT, IN `FromPayDate` DATE, IN `ToPayDate` DATE, IN `Pay_FrequencyType` VARCHAR(50), IN `DivisionRowID` INT)
    DETERMINISTIC
BEGIN

DECLARE atleast_one CHAR(1);

SELECT EXISTS(SELECT lv.RowID FROM employeeleave lv INNER JOIN employee e ON e.RowID=lv.EmployeeID AND e.OrganizationID=lv.OrganizationID AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated') INNER JOIN `position` pos ON pos.RowID=e.PositionID INNER JOIN division dv ON dv.RowID=pos.DivisionId AND dv.RowID=IFNULL(DivisionRowID, dv.RowID) WHERE lv.OrganizationID=OrganizID AND (lv.LeaveStartDate >= FromPayDate OR lv.LeaveEndDate >= FromPayDate) AND (lv.LeaveStartDate <= ToPayDate OR lv.LeaveEndDate <= ToPayDate) LIMIT 1) INTO atleast_one;

IF atleast_one = '1' THEN

	UPDATE employeetimeentry et
	
	
	
	INNER JOIN employee e ON e.OrganizationID=OrganizID AND et.EmployeeID=e.RowID AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
	INNER JOIN `position` pos ON pos.RowID=e.PositionID
	INNER JOIN division dv ON dv.RowID=pos.DivisionId AND dv.RowID=IFNULL(DivisionRowID, dv.RowID)
	SET
		et.RegularHoursWorked=0
		,et.RegularHoursAmount=0
		,et.TotalHoursWorked=0
		,et.OvertimeHoursWorked=0
		,et.OvertimeHoursAmount=0
		,et.UndertimeHours=0
		,et.UndertimeHoursAmount=0
		,et.NightDifferentialHours=0
		,et.NightDiffHoursAmount=0
		,et.NightDifferentialOTHours=0
		,et.NightDiffOTHoursAmount=0
		,et.HoursLate=0
		,et.HoursLateAmount=0
		,et.VacationLeaveHours=0
		,et.SickLeaveHours=0
		,et.MaternityLeaveHours=0
		,et.OtherLeaveHours=0
		,et.TotalDayPay=0
		,et.Absent=0
	WHERE et.OrganizationID=OrganizID
	AND et.EmployeeID=e.RowID
	AND et.`Date` BETWEEN FromPayDate AND ToPayDate;
	
	DELETE FROM employeeleave_duplicate WHERE OrganizationID=OrganizID AND (LeaveStartDate >= FromPayDate OR LeaveEndDate >= FromPayDate) AND (LeaveStartDate <= ToPayDate OR LeaveEndDate <= ToPayDate);
	
	INSERT INTO employeeleave_duplicate
	(
		RowID
		,OrganizationID
		,Created
		,LeaveStartTime
		,LeaveType
		,CreatedBy
		,LastUpd
		,LastUpdBy
		,EmployeeID
		,LeaveEndTime
		,LeaveStartDate
		,LeaveEndDate
		,Reason
		,Comments
		,Image
		,`Status`
		,AdditionalOverrideLeaveBalance
	) SELECT elv.RowID
		,elv.OrganizationID
		,elv.Created
		,elv.LeaveStartTime
		,elv.LeaveType
		,elv.CreatedBy
		,elv.LastUpd
		,elv.LastUpdBy
		,elv.EmployeeID
		,elv.LeaveEndTime
		,elv.LeaveStartDate
		,elv.LeaveEndDate
		,elv.Reason
		,elv.Comments
		,elv.Image
		,elv.`Status`
		,elv.AdditionalOverrideLeaveBalance
	FROM employeeleave elv
	INNER JOIN employee e ON e.RowID=elv.EmployeeID AND e.OrganizationID=elv.OrganizationID AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
	INNER JOIN `position` pos ON pos.RowID=e.PositionID
	INNER JOIN division dv ON dv.RowID=pos.DivisionId AND dv.RowID=IFNULL(DivisionRowID, dv.RowID)
	WHERE elv.OrganizationID=OrganizID
	AND (elv.LeaveStartDate >= FromPayDate OR elv.LeaveEndDate >= FromPayDate)
	AND (elv.LeaveStartDate <= ToPayDate OR elv.LeaveEndDate <= ToPayDate);

END IF;
	
END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
