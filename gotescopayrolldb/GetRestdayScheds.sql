/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP PROCEDURE IF EXISTS `GetRestdayScheds`;
DELIMITER //
CREATE PROCEDURE `GetRestdayScheds`(
	IN `orgId` INT,
	IN `dateFrom` DATE,
	IN `dateTo` DATE
)
BEGIN

SET @_datefrom=SUBDATE(dateFrom, INTERVAL 1 WEEK);
SET @_dateto=dateTo;

DROP TEMPORARY TABLE IF EXISTS `restdaysched`;
CREATE TEMPORARY TABLE IF NOT EXISTS `restdaysched`
SELECT
d.*,
esh.*,
esh.RestDay = '1' `IsRestDay`,
esh.RestDay = '0' `IsNotRestDay`,

pr.PayType = 'Regular Holiday' `IsRegularHoliday`,
pr.PayType = 'Special Non-Working Holiday' `IsSpecialNonWorkingHoliday`,
pr.PayType = 'Regular Day' `IsRegularDay`,
pr.PayType IN ('Regular Holiday', 'Special Non-Working Holiday') `IsHoliday`

FROM dates d
INNER JOIN payrate pr ON pr.OrganizationID=orgId AND pr.`Date`=d.DateValue
LEFT JOIN employeeshift esh ON esh.OrganizationID=pr.OrganizationID AND d.DateValue BETWEEN esh.EffectiveFrom AND esh.EffectiveTo
WHERE d.DateValue BETWEEN @_datefrom AND @_dateto
order BY esh.EmployeeID, d.DateValue
;

SET @_count=0;
SET @_curdate='1775-01-01';
SET @_isNewDay=FALSE;
SET @_eId=0;
SET @_isNewEmployee=FALSE;

DROP TEMPORARY TABLE IF EXISTS `restdayscheds`;
CREATE TEMPORARY TABLE IF NOT EXISTS `restdayscheds`
SELECT
i.*,
IF(i.SetNewDay=1,
	(SELECT x.`DateValue` FROM `restdaysched` x WHERE i.`SetCurDate` > x.`DateValue` AND x.`IsNotRestDay` order BY x.`DateValue` DESC LIMIT 1),
	IF(i.SetNewDay=2,
		(SELECT x.`DateValue` FROM `restdaysched` x WHERE SUBDATE(i.`SetCurDate`, INTERVAL 1 DAY) = x.`DateValue` AND x.`IsRestDay` order BY x.`DateValue` DESC LIMIT 1),
		NULL)) `PriorDateToValidate`
FROM (SELECT
		i.*,
		@_isNewEmployee:=i.EmployeeID != @_eId `IsNewEmployee`,
		IF(@_isNewEmployee, @_eId:=i.EmployeeID, @_eId) `SetEmployeeId`,
		IF(@_isNewEmployee, @_count:=0, @_count) `ResetCounter`,
		@_isNewDay:=i.DateValue != IFNULL(@_curdate, '1775-01-01') `IsNewDay`,
		@_curdate:=IF(@_isNewDay AND i.RestDay=TRUE, i.DateValue, NULL) `SetCurDate`,
		
		@_count:=IF(@_curdate IS NOT NULL AND @_isNewDay AND i.RestDay=TRUE, @_count+1, 0) `SetNewDay`
		
		FROM `restdaysched` i) i
WHERE i.`SetCurDate` IS NOT NULL
# AND i.`IsRegularDay`
;

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
