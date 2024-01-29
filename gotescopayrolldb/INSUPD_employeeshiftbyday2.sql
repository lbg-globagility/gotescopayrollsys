/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP PROCEDURE IF EXISTS `INSUPD_employeeshiftbyday2`;
DELIMITER //
CREATE PROCEDURE `INSUPD_employeeshiftbyday2`(
	IN `param1` VARCHAR(2048),
	IN `orgId` INT,
	IN `userId` INT,
	IN `employeeId` INT
)
BEGIN

DROP TEMPORARY TABLE IF EXISTS `shiftbyday`;

PREPARE prepared_stmt FROM param1;

EXECUTE prepared_stmt;

SET @shiftId=0;
SET @isOtherShiftId=FALSE;
SET @_count=0;

DROP TEMPORARY TABLE IF EXISTS `shiftbydaydef`;
CREATE TEMPORARY TABLE IF NOT EXISTS `shiftbydaydef`
SELECT
i.*
, @isOtherShiftId := (@shiftId != i.ShiftId) `isOtherShiftId`
, IF(@isOtherShiftId, @shiftId:=i.ShiftId, @shiftId) `ThisShiftId`
, IF(@isOtherShiftId, @_count:=@_count+1, @_count) `CounterId`

FROM shiftbyday i
;

/*SELECT
i.*
FROM shiftbydaydef i
;*/

SET @datefrom=CURDATE();
SET @datefrom=IFNULL((SELECT esh.EffectiveTo FROM employeeshift esh WHERE esh.EmployeeID=employeeId AND esh.OrganizationID=orgId order BY esh.EffectiveTo LIMIT 1), SUBDATE(MAKEDATE(YEAR(CURDATE()), 1), INTERVAL 0 DAY));

SELECT @datefrom, LAST_DAY(CONCAT(YEAR(CURDATE()), '-12-01')), SUBDATE(MAKEDATE(YEAR(CURDATE()), 1), INTERVAL 0 DAY);

INSERT INTO `employeeshift` (`OrganizationID`, `CreatedBy`, `EmployeeID`, `ShiftID`, `EffectiveFrom`, `EffectiveTo`, `NightShift`, `RestDay`)
SELECT
orgId,
userId,
employeeId,
NULLIF(ii.ShiftId, 0),
d.DateValue,
ADDDATE(d.DateValue,INTERVAL ii.`DayDiff` DAY) `EndDate`,
FALSE,
NULLIF(ii.ShiftId, 0) IS NULL
FROM dates d
INNER JOIN (SELECT
				i.*
				, MIN(i.Index) `Min`, MAX(i.Index) `Max`, (MAX(i.Index) - MIN(i.Index)) `DayDiff`
				FROM shiftbydaydef i
				GROUP BY i.CounterId
#				GROUP BY i.ShiftId
				) ii ON ii.Index = DAYOFWEEK(d.DateValue)
WHERE d.DateValue BETWEEN @datefrom AND LAST_DAY(CONCAT(YEAR(CURDATE()), '-12-01'))
order BY d.DateValue
ON DUPLICATE KEY UPDATE LastUpd=CURRENT_TIMESTAMP(), LastUpdBy=userId
;

DEALLOCATE PREPARE prepared_stmt;

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
