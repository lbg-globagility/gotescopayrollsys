/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP PROCEDURE IF EXISTS `UpdateLeaveBalanceOthers`;
DELIMITER //
CREATE PROCEDURE `UpdateLeaveBalanceOthers`(
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

SET @leaveType='Others';

CALL `LeavePrediction`(OrganizID, @leaveType, yearPeriod, startDate, endDate);
UPDATE employee e
INNER JOIN currentleavebalancepredict i ON i.EmployeeID=e.RowID
SET e.OtherLeaveBalance = i.CurrentLeaveBalance,
e.LastUpdBy = UserId
;

/**/SET @eIDCount = (SELECT COUNT(EmployeeID) FROM currentleavebalancepredict);
SET eIndex = 1;

WHILE eIndex < @eIDCount DO

	SET @eID = (SELECT EmployeeID FROM currentleavebalancepredict LIMIT eIndex, 1);
	SET @i = NULL;
	SET @psiRowID = NULL;
	
	DROP TEMPORARY TABLE IF EXISTS paystubitemleavebalance;
	CREATE TEMPORARY TABLE IF NOT EXISTS paystubitemleavebalance
	SELECT psi.RowID
#	, @i := (SELECT MIN(ProperLeaveBalance) FROM leavebalancepredict ii WHERE ii.PayperiodID=ps.PayPeriodID AND ii.EmployeeID=ps.EmployeeID AND ii.LeaveType=p.PartNo) `ProperLeaveBalance`
	, @i := ii.ProperLeaveBalance `ProperLeaveBalance`
	, IF(@i IS NOT NULL, @psiRowID := psi.RowID, (SELECT PayAmount FROM paystubitem WHERE RowID=@psiRowID)) `Result`
	, e.LeaveAllowance
	FROM payperiod pp
	INNER JOIN paystub ps ON ps.PayPeriodID=pp.RowID AND ps.EmployeeID=@eID
	INNER JOIN employee e ON e.RowID=ps.EmployeeID
	INNER JOIN paystubitem psi ON psi.PayStubID=ps.RowID
	INNER JOIN product p ON p.RowID=psi.ProductID AND p.PartNo=@leaveType # Others
	INNER JOIN category c ON c.RowID=p.CategoryID AND c.CategoryName='Leave type'
	INNER JOIN (SELECT
					#ii.PayperiodID,
					EmployeeID,
#					MIN(ProperLeaveBalance) `ProperLeaveBalance`
					ProperLeaveBalance,
					PayPeriodID
					FROM leavebalancepredict
					WHERE LeaveType=@leaveType
					AND EmployeeID=@eID
#					GROUP BY ii.EmployeeID
					) ii ON ii.EmployeeID=ps.EmployeeID AND ii.PayPeriodID=ps.PayPeriodID
	WHERE pp.`Year`=yearPeriod
	AND pp.OrganizationID=OrganizID
	ORDER BY pp.OrdinalValue
	;

	UPDATE paystubitem psi
	INNER JOIN paystubitemleavebalance i ON i.RowID=psi.RowID
	SET psi.PayAmount = IFNULL(IFNULL(i.`ProperLeaveBalance`, i.`Result`), i.LeaveAllowance)
	;
	
	SET eIndex = eIndex + 1;
END WHILE;

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
