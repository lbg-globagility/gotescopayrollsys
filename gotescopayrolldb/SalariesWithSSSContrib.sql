/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `SalariesWithSSSContrib`;
DELIMITER //
CREATE PROCEDURE `SalariesWithSSSContrib`(
	IN `organizationPrimaID` INT
)
BEGIN

SET @orgID = organizationPrimaID;

DROP TEMPORARY TABLE IF EXISTS salarieswithsssamount;
CREATE TEMPORARY TABLE salarieswithsssamount
SELECT es.*
, pp.RowID `PayPeriodID`
, pp.PayFromDate, pp.PayToDate
, GetSSSContribution(e.EmployeeType, e.WorkDaysPerYear, es.Salary, pp.PayFromDate, pp.PayToDate) `Result`
, sss.EmployeeContributionAmount
FROM employeesalary es
INNER JOIN employee e ON e.RowID=es.EmployeeID

INNER JOIN payperiod pp ON pp.OrganizationID=e.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID AND pp.PayFromDate >= es.EffectiveDateFrom AND pp.PayToDate <= es.EffectiveDateTo

LEFT JOIN paysocialsecurity sss ON sss.RowID=es.PaySocialSecurityID
WHERE es.OrganizationID=@orgID
#AND es.EmployeeID=324
ORDER BY e.RowID, pp.`Year`, pp.OrdinalValue
;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
