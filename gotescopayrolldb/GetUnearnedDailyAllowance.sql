/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `GetUnearnedDailyAllowance`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUnearnedDailyAllowance`(
	IN `orgid` INT,
	IN `payDateFrom` DATE,
	IN `payDateTo` DATE





)
BEGIN

DECLARE eightHours INT DEFAULT 8;

DECLARE productid INT;

SET productid=(SELECT p.RowID FROM product p INNER JOIN category c ON c.RowID=p.CategoryID AND c.CategoryName='Allowance Type' WHERE p.PartNo='Company Allowance' AND p.OrganizationID=orgid);

SET @hourlyAllowance=0.00;

DROP TEMPORARY TABLE IF EXISTS unearneddailyallowance0; CREATE TEMPORARY TABLE unearneddailyallowance0
SELECT
ea.EmployeeID
, (@hourlyAllowance := ea.AllowanceAmount / @eightHours) `HourlyAllowance`

, (@hourlyAllowance * et.HoursTardy) `LateAllowanceAmount`
, (@hourlyAllowance * et.HoursUndertime) `UndertimeAllowanceAmount`
, IF(et.Absent > 0, ea.AllowanceAmount, 0) `AbsentAllowanceAmount`
FROM employeeallowance ea
INNER JOIN dates d ON d.DateValue BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate

INNER JOIN employeetimeentry et ON et.EmployeeID=ea.EmployeeID AND et.`Date`=d.DateValue AND et.OrganizationID=ea.OrganizationID AND (et.HoursLate + et.HoursUndertime + et.Absent) > 0
WHERE ea.OrganizationID=orgid
AND ea.AllowanceFrequency='Daily'
AND d.DateValue BETWEEN payDateFrom AND payDateTo
AND ea.ProductID=productid
AND ea.AllowanceAmount != 0
#GROUP BY ea.EmployeeID
;

DROP TEMPORARY TABLE IF EXISTS unearneddailyallowance; CREATE TEMPORARY TABLE unearneddailyallowance
SELECT EmployeeID
, SUM(`LateAllowanceAmount`) `LateAllowance`
, SUM(`UndertimeAllowanceAmount`) `UndertimeAllowance`
, SUM(`AbsentAllowanceAmount`) `AbsentAllowance`
FROM unearneddailyallowance0
GROUP BY EmployeeID
;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
