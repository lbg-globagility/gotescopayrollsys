/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `RECOMPUTE_thirteenthmonthpay`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `RECOMPUTE_thirteenthmonthpay`(IN `OrganizID` INT, IN `PayPRowID` INT, IN `UserRowID` INT)
    DETERMINISTIC
BEGIN

DECLARE dateFrom, dateTo DATE;
DECLARE monthNumber, yearNumber, periodID INT;
DECLARE thirteenthMonthDivisor INT DEFAULT 12;

SELECT pp.`Month`, pp.`Year`
FROM payperiod pp
WHERE pp.RowID=PayPRowID
INTO monthNumber, yearNumber;

/**********First Half**********/
SELECT pp.PayFromDate, pp.PayToDate, pp.RowID
FROM payperiod pp
WHERE pp.OrganizationID=OrganizID
AND pp.`Month`=monthNumber
AND pp.`Year`=yearNumber
AND pp.Half=1
AND pp.TotalGrossSalary=1
INTO dateFrom, dateTo, periodID;

CALL GetAttendancePeriod(OrganizID, dateFrom, dateTo, FALSE);

DROP TEMPORARY TABLE IF EXISTS firsthalf;
CREATE TEMPORARY TABLE firsthalf
SELECT i.EmployeeID
, SUM(i.RegularHoursAmount - i.HolidayPayAmount) `BasicAmount`
, periodID `PayPeriodID`
FROM attendanceperiod i
INNER JOIN employee e ON e.RowID=i.EmployeeID AND e.EmployeeType='Daily'
GROUP BY i.EmployeeID
;

/**********Second Half**********/
SELECT pp.PayFromDate, pp.PayToDate, pp.RowID
FROM payperiod pp
WHERE pp.OrganizationID=OrganizID
AND pp.`Month`=monthNumber
AND pp.`Year`=yearNumber
AND pp.Half=0
AND pp.TotalGrossSalary=1
INTO dateFrom, dateTo, periodID;

CALL GetAttendancePeriod(OrganizID, dateFrom, dateTo, TRUE);

DROP TEMPORARY TABLE IF EXISTS secondhalf;
CREATE TEMPORARY TABLE secondhalf
SELECT i.EmployeeID
, SUM(i.RegularHoursAmount - i.HolidayPayAmount) `BasicAmount`
, periodID `PayPeriodID`
FROM attendanceperiod i
INNER JOIN employee e ON e.RowID=i.EmployeeID AND e.EmployeeType='Daily'
GROUP BY i.EmployeeID
;












IF EXISTS(SELECT * FROM firsthalf LIMIT 1)
	AND EXISTS(SELECT * FROM secondhalf LIMIT 1) THEN

	INSERT INTO thirteenthmonthpay
	(
		OrganizationID
		,Created
		,CreatedBy
		,PaystubID
		,Amount
		,Amount14
		,Amount15
		,Amount16
	) SELECT ps.OrganizationID
	, CURRENT_TIMESTAMP()
	, UserRowID
	, ps.RowID
	, (i.BasicAmount / thirteenthMonthDivisor)
	, 0
	, 0
	, 0
	FROM firsthalf i
	INNER JOIN paystub ps ON ps.OrganizationID=OrganizID AND ps.PayPeriodID=i.PayPeriodID AND ps.EmployeeID=i.EmployeeID
	ON DUPLICATE KEY UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	, LastUpdBy=UserRowID
	, Amount=(i.BasicAmount / thirteenthMonthDivisor)
	, Amount14=0
	, Amount15=0
	, Amount16=0
	;

	INSERT INTO thirteenthmonthpay
	(
		OrganizationID
		,Created
		,CreatedBy
		,PaystubID
		,Amount
		,Amount14
		,Amount15
		,Amount16
	) SELECT ps.OrganizationID
	, CURRENT_TIMESTAMP()
	, UserRowID
	, ps.RowID
	, (i.BasicAmount / thirteenthMonthDivisor)
	, 0
	, 0
	, 0
	FROM secondhalf i
	INNER JOIN paystub ps ON ps.OrganizationID=OrganizID AND ps.PayPeriodID=i.PayPeriodID AND ps.EmployeeID=i.EmployeeID
	ON DUPLICATE KEY UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	, LastUpdBy=UserRowID
	, Amount=(i.BasicAmount / thirteenthMonthDivisor)
	, Amount14=0
	, Amount15=0
	, Amount16=0
	;

ELSEIF NOT EXISTS(SELECT * FROM secondhalf LIMIT 1)
	AND EXISTS(SELECT * FROM firsthalf LIMIT 1) THEN

	INSERT INTO thirteenthmonthpay
	(
		OrganizationID
		,Created
		,CreatedBy
		,PaystubID
		,Amount
		,Amount14
		,Amount15
		,Amount16
	) SELECT ps.OrganizationID
	, CURRENT_TIMESTAMP()
	, UserRowID
	, ps.RowID
	, (i.BasicAmount / thirteenthMonthDivisor)
	, 0
	, 0
	, 0
	FROM firsthalf i
	INNER JOIN paystub ps ON ps.OrganizationID=OrganizID AND ps.PayPeriodID=i.PayPeriodID AND ps.EmployeeID=i.EmployeeID
	ON DUPLICATE KEY UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	, LastUpdBy=UserRowID
	, Amount=(i.BasicAmount / thirteenthMonthDivisor)
	, Amount14=0
	, Amount15=0
	, Amount16=0
	;

ELSEIF NOT EXISTS(SELECT * FROM firsthalf LIMIT 1)
	AND EXISTS(SELECT * FROM secondhalf LIMIT 1) THEN

	INSERT INTO thirteenthmonthpay
	(
		OrganizationID
		,Created
		,CreatedBy
		,PaystubID
		,Amount
		,Amount14
		,Amount15
		,Amount16
	) SELECT ps.OrganizationID
	, CURRENT_TIMESTAMP()
	, UserRowID
	, ps.RowID
	, (i.BasicAmount / thirteenthMonthDivisor)
	, 0
	, 0
	, 0
	FROM secondhalf i
	INNER JOIN paystub ps ON ps.OrganizationID=OrganizID AND ps.PayPeriodID=i.PayPeriodID AND ps.EmployeeID=i.EmployeeID
	ON DUPLICATE KEY UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	, LastUpdBy=UserRowID
	, Amount=(i.BasicAmount / thirteenthMonthDivisor)
	, Amount14=0
	, Amount15=0
	, Amount16=0
	;

END IF;

















/**********For Fixed/Monthly employees**********/

SET @dateOne=CURDATE();
SET @dateTwo=CURDATE();

SELECT MIN(pp.PayFromDate) `PayFromDate`
, MAX(pp.PayToDate) `PayToDate`
FROM payperiod pp
WHERE pp.`Year`=yearNumber
AND pp.OrganizationID=OrganizID
AND pp.TotalGrossSalary=1
INTO @dateOne, @dateTwo
;

DROP TEMPORARY TABLE IF EXISTS salariesperperiod;
CREATE TEMPORARY TABLE salariesperperiod
SELECT i.*
, pp.RowID `PayPeriodID`, pp.PayFromDate, pp.PayToDate
, pp.Half
FROM (SELECT d.*
		, es.RowID `SalaryID`
		, es.Salary, es.TrueSalary
		, es.BasicPay, (es.TrueSalary / 2) `ActualBasicPay`
		, es.OrganizationID
		, es.EffectiveDateFrom
		, es.EffectiveDateTo
		, e.EmployeeID `EmployeeNo`
		, es.EmployeeID
		FROM dates d
		INNER JOIN employeesalary es ON es.OrganizationID=@orgId AND d.DateValue BETWEEN es.EffectiveDateFrom AND IFNULL(es.EffectiveDateTo, @dateTwo)
		INNER JOIN employee e ON e.RowID=es.EmployeeID AND e.OrganizationID=es.OrganizationID AND e.EmployeeType IN ('Fixed', 'Monthly')
		AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0

		WHERE d.DateValue BETWEEN @dateOne AND @dateTwo
		) i
INNER JOIN payperiod pp ON pp.OrganizationID=i.OrganizationID AND pp.TotalGrossSalary=1 AND i.DateValue BETWEEN pp.PayFromDate AND pp.PayToDate
GROUP BY pp.RowID, i.EmployeeID
ORDER BY i.EmployeeID, pp.OrdinalValue
;

	INSERT INTO thirteenthmonthpay
	(
		OrganizationID
		,Created
		,CreatedBy
		,PaystubID
		,Amount
		,Amount14
		,Amount15
		,Amount16
	) SELECT ps.OrganizationID
	, CURRENT_TIMESTAMP()
	, UserRowID
	, ps.RowID
	, (i.BasicPay / thirteenthMonthDivisor)
	, 0
	, 0
	, 0
	FROM salariesperperiod i
	INNER JOIN paystub ps ON ps.OrganizationID=OrganizID AND ps.PayPeriodID=i.PayPeriodID AND ps.EmployeeID=i.EmployeeID
	WHERE i.PayPeriodID=PayPRowID
	ON DUPLICATE KEY UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	, LastUpdBy=UserRowID
	, Amount=(i.BasicPay / thirteenthMonthDivisor)
	, Amount14=0
	, Amount15=0
	, Amount16=0
	;


END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
