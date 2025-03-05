/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP PROCEDURE IF EXISTS `UpdateLeaveBalanceParental`;
DELIMITER //
CREATE PROCEDURE `UpdateLeaveBalanceParental`(
	IN `OrganizID` INT,
	IN `UserId` INT,
	IN `PeriodId` INT,
	IN `startDate` DATE
)
BEGIN

DECLARE eIndex,
	yearPeriod INT(11) DEFAULT 0;

DECLARE endDate DATE;

SELECT i.PayToDate
FROM (SELECT
		pp.`Year`, pp.OrdinalValue, pp.PayFromDate, pp.PayToDate
		FROM payperiod pp
		WHERE pp.OrganizationID=OrganizID
		AND pp.TotalGrossSalary=1
		AND pp.PayFromDate >= startDate
		ORDER BY pp.`Year`, pp.OrdinalValue
		LIMIT 24) i
ORDER BY i.PayFromDate DESC, i.PayToDate DESC
LIMIT 1
INTO endDate;

SELECT
pp.`Year`
FROM payperiod pp
WHERE pp.RowID=PeriodId
INTO yearPeriod;

/*UPDATE employee e
SET e.LeaveBalance=e.LeaveAllowance
WHERE e.OrganizationID=OrganizID
AND e.LeaveAllowance=0
AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
;*/

SET @leaveType='Maternity/paternity leave';

CALL `LeavePrediction`(OrganizID, @leaveType, yearPeriod, startDate, endDate);
UPDATE employee e
INNER JOIN currentleavebalancepredict i ON i.EmployeeID=e.RowID
SET e.MaternityLeaveBalance = i.CurrentLeaveBalance,
e.LastUpdBy = UserId
;

DROP TEMPORARY TABLE IF EXISTS paystubitemleavebalance;
CREATE TEMPORARY TABLE IF NOT EXISTS paystubitemleavebalance
SELECT
GROUP_CONCAT(DISTINCT psi.RowID) `RowIDs`,
MIN(i.ProperLeaveBalance) `ProperLeaveBalance`
FROM leavebalancepredict i
INNER JOIN paystub ps ON ps.EmployeeID=i.EmployeeID AND i.`Date` BETWEEN ps.PayFromDate AND ps.PayToDate
INNER JOIN paystubitem psi ON psi.PayStubID=ps.RowID
INNER JOIN product p ON p.RowID=psi.ProductID AND p.PartNo=i.LeaveType AND p.`Category`='Leave type'
GROUP BY i.EmployeeID, ps.PayPeriodID
;

UPDATE paystubitem psi
INNER JOIN paystubitemleavebalance i ON FIND_IN_SET(psi.RowID, i.`RowIDs`) > 0
SET psi.PayAmount = i.`ProperLeaveBalance`
WHERE IFNULL(psi.PayAmount, 0) != IFNULL(i.`ProperLeaveBalance`, 0)
;

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
