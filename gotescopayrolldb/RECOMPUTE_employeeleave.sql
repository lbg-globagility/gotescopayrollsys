/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `RECOMPUTE_employeeleave`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `RECOMPUTE_employeeleave`(
	IN `OrganizID` INT,
	IN `FromPayDate` DATE,
	IN `ToPayDate` DATE,
	IN `DivisionRowID` INT



)
    DETERMINISTIC
BEGIN

/*SET @rowIds = NULL;

SELECT GROUP_CONCAT(et.RowID)
FROM employeetimeentry et
INNER JOIN employee e ON e.OrganizationID=OrganizID AND et.EmployeeID=e.RowID AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
INNER JOIN `position` pos ON pos.RowID=e.PositionID
INNER JOIN division dv ON dv.RowID=pos.DivisionId AND dv.RowID=IFNULL(DivisionRowID, dv.RowID)
WHERE et.OrganizationID=OrganizID
AND et.EmployeeID=e.RowID
AND et.`Date` BETWEEN FromPayDate AND ToPayDate
INTO @rowIds
;

DELETE FROM employeetimeentry WHERE FIND_IN_SET(RowID, @rowIds) > 0; ALTER TABLE employeetimeentry AUTO_INCREMENT = 0;*/

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
