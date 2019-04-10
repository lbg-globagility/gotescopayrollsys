/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `UpdateLeaveBalance`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateLeaveBalance`(
	IN `OrganizID` INT,
	IN `yearPeriod` INT
)
BEGIN

CALL `LeavePrediction`(OrganizID, 'Additional VL', yearPeriod);
UPDATE employee e
INNER JOIN currentleavebalancepredict i ON i.EmployeeID=e.RowID
SET e.AdditionalVLBalance = i.CurrentLeaveBalance
;

CALL `LeavePrediction`(OrganizID, 'Maternity/paternity leave', yearPeriod);
UPDATE employee e
INNER JOIN currentleavebalancepredict i ON i.EmployeeID=e.RowID
SET e.MaternityLeaveBalance = i.CurrentLeaveBalance
;

CALL `LeavePrediction`(OrganizID, 'Others', yearPeriod);
UPDATE employee e
INNER JOIN currentleavebalancepredict i ON i.EmployeeID=e.RowID
SET e.OtherLeaveBalance = i.CurrentLeaveBalance
;

CALL `LeavePrediction`(OrganizID, 'Sick leave', yearPeriod);
UPDATE employee e
INNER JOIN currentleavebalancepredict i ON i.EmployeeID=e.RowID
SET e.SickLeaveBalance = i.CurrentLeaveBalance
;

CALL `LeavePrediction`(OrganizID, 'Vacation leave', yearPeriod);
UPDATE employee e
INNER JOIN currentleavebalancepredict i ON i.EmployeeID=e.RowID
SET e.LeaveBalance = i.CurrentLeaveBalance
;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
