/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `GetUnearnedAllowance`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUnearnedAllowance`(
	IN `organizatID` INT,
	IN `periodDateFrom` DATE,
	IN `periodDateTo` DATE





)
BEGIN

SET @dateFrom = periodDateFrom;
SET @dateTo = periodDateTo;

SET @orgID = organizatID;
SET @dailyAllowance=0.00;
SET @hourlyAllowance=0.00;

SET @monthCount=12;
SET @twiceAMonth=2;

DROP TEMPORARY TABLE IF EXISTS unearnedallowance; DROP TABLE IF EXISTS unearnedallowance; CREATE TEMPORARY TABLE unearnedallowance
SELECT
i.EmployeeID
/* , (SUM(i.LateHours) * TRIM(i.TotalAllowanceAmt / 8)+0) `LateAllowance`
, (SUM(i.UndertimeHours) * TRIM(i.TotalAllowanceAmt / 8)+0) `UndertimeAllowance`
, (SUM(i.AbsentHours) * TRIM(i.TotalAllowanceAmt / 8)+0) `AbsentAllowance`
*/
, @dailyAllowance := (i.AllowanceAmount / ((e.WorkDaysPerYear / @monthCount) / @twiceAMonth)) `DailyAllowance`
, @hourlyAllowance := @dailyAllowance / 8 `HourlyAllowance`
, TRIM(SUM(i.LateHours * @hourlyAllowance))+0 `LateAllowance`
, TRIM(SUM(i.UndertimeHours * @hourlyAllowance))+0 `UndertimeAllowance`
, TRIM(SUM(i.AbsentHours * @hourlyAllowance))+0 `AbsentAllowance`

FROM paystubitem_sum_semimon_allowance_group_prodid i
INNER JOIN employee e ON e.RowID=i.EmployeeID
WHERE i.OrganizationID=@orgID
AND i.`Date` BETWEEN @dateFrom AND @dateTo
GROUP BY i.EmployeeID
#HAVING SUM(i.LateHours + i.UndertimeHours + i.AbsentHours) > 0
HAVING SUM(i.HoursToLess) > 0
;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
