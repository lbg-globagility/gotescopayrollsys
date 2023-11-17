/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `UpdateLeaveBalance`;
DELIMITER //
CREATE PROCEDURE `UpdateLeaveBalance`(
	IN `OrganizID` INT,
	IN `yearPeriod` INT




,
	IN `startDate` DATE




)
BEGIN

DECLARE eIndex INT(11) DEFAULT 0;

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

UPDATE employee e
SET e.LeaveBalance=e.LeaveAllowance
WHERE e.OrganizationID=OrganizID
AND e.LeaveAllowance=0
AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
;

UPDATE employee e
SET e.SickLeaveBalance=e.SickLeaveAllowance
WHERE e.OrganizationID=OrganizID
AND e.SickLeaveAllowance=0
AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
;

UPDATE employee e
SET e.MaternityLeaveBalance=e.MaternityLeaveAllowance
WHERE e.OrganizationID=OrganizID
AND e.MaternityLeaveAllowance=0
AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
;

UPDATE employee e
SET e.OtherLeaveBalance=e.OtherLeaveAllowance
WHERE e.OrganizationID=OrganizID
AND e.OtherLeaveAllowance=0
AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
;

UPDATE employee e
SET e.AdditionalVLBalance=e.AdditionalVLAllowance
WHERE e.OrganizationID=OrganizID
AND e.AdditionalVLAllowance=0
AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
;

CALL `LeavePrediction`(OrganizID, 'Additional VL', yearPeriod, startDate, endDate);
UPDATE employee e
INNER JOIN currentleavebalancepredict i ON i.EmployeeID=e.RowID
SET e.AdditionalVLBalance = i.CurrentLeaveBalance
;

SET @eIDCount = (SELECT COUNT(EmployeeID) FROM currentleavebalancepredict);
SET eIndex = 1;

WHILE eIndex < @eIDCount DO

	SET @eID = (SELECT EmployeeID FROM currentleavebalancepredict LIMIT eIndex, 1);
	SET @i = NULL;
	SET @psiRowID = NULL;
	
	DROP TEMPORARY TABLE IF EXISTS paystubitemleavebalance;
	CREATE TEMPORARY TABLE IF NOT EXISTS paystubitemleavebalance
	SELECT psi.RowID
	, @i := (SELECT MIN(ProperLeaveBalance) FROM leavebalancepredict ii WHERE ii.PayperiodID=ps.PayPeriodID AND ii.EmployeeID=ps.EmployeeID AND ii.LeaveType=p.PartNo) `ProperLeaveBalance`
	, IF(@i IS NOT NULL, @psiRowID := psi.RowID, (SELECT PayAmount FROM paystubitem WHERE RowID=@psiRowID)) `Result`
	, e.AdditionalVLAllowance
	FROM payperiod pp
	INNER JOIN paystub ps ON ps.PayPeriodID=pp.RowID AND ps.EmployeeID=@eID
	INNER JOIN employee e ON e.RowID=ps.EmployeeID
	INNER JOIN paystubitem psi ON psi.PayStubID=ps.RowID
	INNER JOIN product p ON p.RowID=psi.ProductID AND p.PartNo='Additional VL'
	INNER JOIN category c ON c.RowID=p.CategoryID AND c.CategoryName='Leave type'
	WHERE pp.`Year`=yearPeriod
	AND pp.OrganizationID=OrganizID
	ORDER BY pp.OrdinalValue
	;
	
	UPDATE paystubitem psi
	INNER JOIN paystubitemleavebalance i ON i.RowID=psi.RowID
	SET psi.PayAmount = IFNULL(IFNULL(i.`ProperLeaveBalance`, i.`Result`), i.AdditionalVLAllowance)
	;
	
	SET eIndex = eIndex + 1;
END WHILE;


CALL `LeavePrediction`(OrganizID, 'Maternity/paternity leave', yearPeriod, startDate, endDate);
UPDATE employee e
INNER JOIN currentleavebalancepredict i ON i.EmployeeID=e.RowID
SET e.MaternityLeaveBalance = i.CurrentLeaveBalance
;

SET @eIDCount = (SELECT COUNT(EmployeeID) FROM currentleavebalancepredict);
SET eIndex = 1;

WHILE eIndex < @eIDCount DO

	SET @eID = (SELECT EmployeeID FROM currentleavebalancepredict LIMIT eIndex, 1);
	SET @i = NULL;
	SET @psiRowID = NULL;
	
	DROP TEMPORARY TABLE IF EXISTS paystubitemleavebalance;
	CREATE TEMPORARY TABLE IF NOT EXISTS paystubitemleavebalance
	SELECT psi.RowID
	, @i := (SELECT MIN(ProperLeaveBalance) FROM leavebalancepredict ii WHERE ii.PayperiodID=ps.PayPeriodID AND ii.EmployeeID=ps.EmployeeID AND ii.LeaveType=p.PartNo) `ProperLeaveBalance`
	, IF(@i IS NOT NULL, @psiRowID := psi.RowID, (SELECT PayAmount FROM paystubitem WHERE RowID=@psiRowID)) `Result`
	, e.MaternityLeaveAllowance
	FROM payperiod pp
	INNER JOIN paystub ps ON ps.PayPeriodID=pp.RowID AND ps.EmployeeID=@eID
	INNER JOIN employee e ON e.RowID=ps.EmployeeID
	INNER JOIN paystubitem psi ON psi.PayStubID=ps.RowID
	INNER JOIN product p ON p.RowID=psi.ProductID AND p.PartNo='Maternity/paternity leave'
	INNER JOIN category c ON c.RowID=p.CategoryID AND c.CategoryName='Leave type'
	WHERE pp.`Year`=yearPeriod
	AND pp.OrganizationID=OrganizID
	ORDER BY pp.OrdinalValue
	;
	
	UPDATE paystubitem psi
	INNER JOIN paystubitemleavebalance i ON i.RowID=psi.RowID
	SET psi.PayAmount = IFNULL(IFNULL(i.`ProperLeaveBalance`, i.`Result`), i.MaternityLeaveAllowance)
	;
	
	SET eIndex = eIndex + 1;
END WHILE;


CALL `LeavePrediction`(OrganizID, 'Others', yearPeriod, startDate, endDate);
UPDATE employee e
INNER JOIN currentleavebalancepredict i ON i.EmployeeID=e.RowID
SET e.OtherLeaveBalance = i.CurrentLeaveBalance
;

SET @eIDCount = (SELECT COUNT(EmployeeID) FROM currentleavebalancepredict);
SET eIndex = 1;

WHILE eIndex < @eIDCount DO

	SET @eID = (SELECT EmployeeID FROM currentleavebalancepredict LIMIT eIndex, 1);
	SET @i = NULL;
	SET @psiRowID = NULL;
	
	DROP TEMPORARY TABLE IF EXISTS paystubitemleavebalance;
	CREATE TEMPORARY TABLE IF NOT EXISTS paystubitemleavebalance
	SELECT psi.RowID
	, @i := (SELECT MIN(ProperLeaveBalance) FROM leavebalancepredict ii WHERE ii.PayperiodID=ps.PayPeriodID AND ii.EmployeeID=ps.EmployeeID AND ii.LeaveType=p.PartNo) `ProperLeaveBalance`
	, IF(@i IS NOT NULL, @psiRowID := psi.RowID, (SELECT PayAmount FROM paystubitem WHERE RowID=@psiRowID)) `Result`
	, e.OtherLeaveAllowance
	FROM payperiod pp
	INNER JOIN paystub ps ON ps.PayPeriodID=pp.RowID AND ps.EmployeeID=@eID
	INNER JOIN employee e ON e.RowID=ps.EmployeeID
	INNER JOIN paystubitem psi ON psi.PayStubID=ps.RowID
	INNER JOIN product p ON p.RowID=psi.ProductID AND p.PartNo='Others'
	INNER JOIN category c ON c.RowID=p.CategoryID AND c.CategoryName='Leave type'
	WHERE pp.`Year`=yearPeriod
	AND pp.OrganizationID=OrganizID
	ORDER BY pp.OrdinalValue
	;
	
	UPDATE paystubitem psi
	INNER JOIN paystubitemleavebalance i ON i.RowID=psi.RowID
	SET psi.PayAmount = IFNULL(IFNULL(i.`ProperLeaveBalance`, i.`Result`), i.OtherLeaveAllowance)
	;
	
	SET eIndex = eIndex + 1;
END WHILE;


CALL `LeavePrediction`(OrganizID, 'Sick leave', yearPeriod, startDate, endDate);
UPDATE employee e
INNER JOIN currentleavebalancepredict i ON i.EmployeeID=e.RowID
SET e.SickLeaveBalance = i.CurrentLeaveBalance
;

SET @eIDCount = (SELECT COUNT(EmployeeID) FROM currentleavebalancepredict);
SET eIndex = 1;

WHILE eIndex < @eIDCount DO

	SET @eID = (SELECT EmployeeID FROM currentleavebalancepredict LIMIT eIndex, 1);
	SET @i = NULL;
	SET @psiRowID = NULL;
	
	DROP TEMPORARY TABLE IF EXISTS paystubitemleavebalance;
	CREATE TEMPORARY TABLE IF NOT EXISTS paystubitemleavebalance
	SELECT psi.RowID
	, @i := (SELECT MIN(ProperLeaveBalance) FROM leavebalancepredict ii WHERE ii.PayperiodID=ps.PayPeriodID AND ii.EmployeeID=ps.EmployeeID AND ii.LeaveType=p.PartNo) `ProperLeaveBalance`
	, IF(@i IS NOT NULL, @psiRowID := psi.RowID, (SELECT PayAmount FROM paystubitem WHERE RowID=@psiRowID)) `Result`
	, e.SickLeaveAllowance
	FROM payperiod pp
	INNER JOIN paystub ps ON ps.PayPeriodID=pp.RowID AND ps.EmployeeID=@eID
	INNER JOIN employee e ON e.RowID=ps.EmployeeID
	INNER JOIN paystubitem psi ON psi.PayStubID=ps.RowID
	INNER JOIN product p ON p.RowID=psi.ProductID AND p.PartNo='Sick leave'
	INNER JOIN category c ON c.RowID=p.CategoryID AND c.CategoryName='Leave type'
	WHERE pp.`Year`=yearPeriod
	AND pp.OrganizationID=OrganizID
	ORDER BY pp.OrdinalValue
	;
	
	UPDATE paystubitem psi
	INNER JOIN paystubitemleavebalance i ON i.RowID=psi.RowID
	SET psi.PayAmount = IFNULL(IFNULL(i.`ProperLeaveBalance`, i.`Result`), i.SickLeaveAllowance)
	;
	
	SET eIndex = eIndex + 1;
END WHILE;


CALL `LeavePrediction`(OrganizID, 'Vacation leave', yearPeriod, startDate, endDate);
UPDATE employee e
INNER JOIN currentleavebalancepredict i ON i.EmployeeID=e.RowID
SET e.LeaveBalance = i.CurrentLeaveBalance
;

SET @eIDCount = (SELECT COUNT(EmployeeID) FROM currentleavebalancepredict);
SET eIndex = 1;

WHILE eIndex < @eIDCount DO

	SET @eID = (SELECT EmployeeID FROM currentleavebalancepredict LIMIT eIndex, 1);
	SET @i = NULL;
	SET @psiRowID = NULL;
	
	DROP TEMPORARY TABLE IF EXISTS paystubitemleavebalance;
	CREATE TEMPORARY TABLE IF NOT EXISTS paystubitemleavebalance
	SELECT psi.RowID
	, @i := (SELECT MIN(ProperLeaveBalance) FROM leavebalancepredict ii WHERE ii.PayperiodID=ps.PayPeriodID AND ii.EmployeeID=ps.EmployeeID AND ii.LeaveType=p.PartNo) `ProperLeaveBalance`
	, IF(@i IS NOT NULL, @psiRowID := psi.RowID, (SELECT PayAmount FROM paystubitem WHERE RowID=@psiRowID)) `Result`
	, e.LeaveAllowance
	FROM payperiod pp
	INNER JOIN paystub ps ON ps.PayPeriodID=pp.RowID AND ps.EmployeeID=@eID
	INNER JOIN employee e ON e.RowID=ps.EmployeeID
	INNER JOIN paystubitem psi ON psi.PayStubID=ps.RowID
	INNER JOIN product p ON p.RowID=psi.ProductID AND p.PartNo='Vacation leave'
	INNER JOIN category c ON c.RowID=p.CategoryID AND c.CategoryName='Leave type'
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

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
