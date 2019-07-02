/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP FUNCTION IF EXISTS `CalculateOvertimeHours`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `CalculateOvertimeHours`(
	`shiftTimeFrom` TIME,
	`shiftTimeTo` TIME,
	`etDate` DATE,
	`employeeRowID` INT




) RETURNS decimal(11,4)
BEGIN

DECLARE approvedStatus VARCHAR(8) DEFAULT 'Approved';
DECLARE otHours, preOtHours, postOtHours DECIMAL(11,4);
DECLARE secondsPerHour INT(11) DEFAULT 3600;

SET @shFrom = CONCAT_DATETIME(etDate, shiftTimeFrom);
SET @shTo = GetNextStartDateTime(@shFrom, shiftTimeTo);

SELECT
 TIMESTAMPDIFF(SECOND
                , GREATEST(etd.TimeStampIn
					            , CONCAT_DATETIME(etDate, preOt.OTStartTime))
                , LEAST(GetNextStartDateTime(CONCAT_DATETIME(etDate, preOt.OTStartTime), preOt.OTEndTime)
					         , @shFrom)
                ) / secondsPerHour `PreOvertime`

, TIMESTAMPDIFF(SECOND
                , GREATEST(CONCAT_DATETIME(etDate, postOt.OTStartTime)
					            , @shTo)
                , LEAST(etd.TimeStampOut
					         , GetNextStartDateTime(CONCAT_DATETIME(etDate, postOt.OTStartTime), postOt.OTEndTime))
                ) / secondsPerHour `PostOvertime`

FROM employeeshift esh
INNER JOIN shift sh ON sh.RowID=esh.ShiftID

LEFT JOIN (SELECT *
           FROM employeeovertime preOt
			  WHERE preOt.EmployeeID = employeeRowID AND etDate BETWEEN preOt.OTStartDate AND preOt.OTEndDate AND preOt.OTStatus = approvedStatus AND GetNextStartDateTime(CONCAT_DATETIME(etDate, preOt.OTStartTime), preOt.OTEndTime) <= @shFrom
			  LIMIT 1) preOt ON preOt.RowID IS NOT NULL

LEFT JOIN (SELECT *
           FROM employeeovertime postOt
			  WHERE postOt.EmployeeID = employeeRowID AND etDate BETWEEN postOt.OTStartDate AND postOt.OTEndDate AND postOt.OTStatus = approvedStatus AND CONCAT_DATETIME(etDate, postOt.OTStartTime) >= @shTo
			  LIMIT 1) postOt ON postOt.RowID IS NOT NULL

LEFT JOIN (SELECT *
           FROM employeetimeentrydetails etd
			  WHERE etd.EmployeeID = employeeRowID AND etd.`Date` = etDate
			  ORDER BY IFNULL(etd.LastUpd, etd.Created)
			  LIMIT 1) etd ON etd.RowID IS NOT NULL

WHERE esh.EmployeeID = employeeRowID
AND etDate BETWEEN esh.EffectiveFrom AND esh.EffectiveTo
ORDER BY IFNULL(esh.LastUpd, esh.Created) DESC
LIMIT 1
INTO preOtHours
     , postOtHours
;

SET otHours = IFNULL(preOtHours, 0)
              + IFNULL(postOtHours, 0);

RETURN otHours;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
