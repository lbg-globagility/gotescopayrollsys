/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `MASS_generate_employeetimeentry`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `MASS_generate_employeetimeentry`(IN `OrganizID` INT, IN `Pay_FrequencyType` TEXT, IN `UserRowID` INT, IN `periodDateFrom` DATE, IN `periodDateTo` DATE, IN `DivisionRowID` INT)
    NO SQL
    DETERMINISTIC
BEGIN

UPDATE employee SET DayOfRest='1' WHERE OrganizationID=OrganizID AND DayOfRest IN ('','0');

SET @rec_count = 0;

SELECT GENERATE_employeetimeentry(e.RowID,OrganizID,d.DateValue,UserRowID)
FROM dates d
INNER JOIN employee e ON e.OrganizationID=OrganizID AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
INNER JOIN `position` pos ON pos.RowID=e.PositionID
INNER JOIN division dv ON dv.RowID=pos.DivisionId AND dv.RowID=IFNULL(DivisionRowID, dv.RowID)
INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID AND pf.PayFrequencyType=Pay_FrequencyType
WHERE d.DateValue BETWEEN periodDateFrom AND periodDateTo
ORDER BY e.RowID,d.DateValue;
# INTO @rec_count;

/*SET @i = 0;

WHILE (@i < @rec_count) DO
	
	
	FROM dates d
	INNER JOIN employee e ON e.OrganizationID=OrganizID
	INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID AND pf.PayFrequencyType=Pay_FrequencyType
	WHERE d.DateValue BETWEEN periodDateFrom AND periodDateTo;
	
	SELECT GENERATE_employeetimeentry(e.RowID,OrganizID,d.DateValue,UserRowID);
	
	SET @i = @i + 1;

END WHILE;*/

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
