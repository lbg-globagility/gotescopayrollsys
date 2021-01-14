/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `RELEASE_thirteenthmonthpay`;
DELIMITER //
CREATE PROCEDURE `RELEASE_thirteenthmonthpay`(
	IN `OrganizID` INT,
	IN `PayPeriodRowID` INT,
	IN `UserRowID` INT







)
    DETERMINISTIC
BEGIN

DECLARE twentyFour INT DEFAULT 24;

DECLARE annual_first_date, annual_last_date DATE;

DECLARE final_year, payFrequencyID INT(11);

SET @orgId=OrganizID;

SELECT
pp.`Year`
, pp.TotalGrossSalary
, pp.PayToDate
FROM payperiod pp
WHERE pp.RowID=PayPeriodRowID
INTO final_year
	, payFrequencyID
	, annual_last_date;

/**********************/

SELECT
pp.PayFromDate, pp.PayToDate
FROM payperiod pp
WHERE pp.RowID=PayPeriodRowID
INTO @dateOne, @dateTwo
;

DROP TEMPORARY TABLE IF EXISTS annualperiods;
CREATE TEMPORARY TABLE annualperiods
SELECT i.*
FROM (SELECT a.*
		FROM (SELECT pp.*
				FROM payperiod pp
				WHERE pp.RowID=PayPeriodRowID
				) a
	UNION
		SELECT b.*
		FROM (SELECT pp.*
				FROM payperiod pp
				WHERE pp.OrganizationID=OrganizID
				AND pp.TotalGrossSalary=1
				AND pp.PayFromDate < @dateOne
				AND pp.PayToDate < @dateTwo
				ORDER BY pp.`Year` DESC, pp.OrdinalValue DESC
				LIMIT 30
				) b
		) i
ORDER BY i.PayFromDate DESC, i.PayToDate DESC
LIMIT twentyFour
;

SELECT
	MIN(q.PayFromDate)
FROM annualperiods q
INTO annual_first_date
;

/***********
***********/
UPDATE paystub ps
INNER JOIN payperiod pp
	ON pp.`Year`=final_year
	AND pp.OrganizationID=ps.OrganizationID
	AND pp.TotalGrossSalary=payFrequencyID
SET ps.ThirteenthMonthInclusion=FALSE
WHERE ps.OrganizationID=OrganizID
AND ps.ThirteenthMonthInclusion=TRUE
;
UPDATE paystubactual ps
INNER JOIN payperiod pp
	ON pp.`Year`=final_year
	AND pp.OrganizationID=ps.OrganizationID
	AND pp.TotalGrossSalary=payFrequencyID
SET ps.ThirteenthMonthInclusion=FALSE
WHERE ps.OrganizationID=OrganizID
AND ps.ThirteenthMonthInclusion=TRUE
;

DROP TEMPORARY TABLE IF EXISTS thirteenthmonthofdaily;
CREATE TEMPORARY TABLE thirteenthmonthofdaily
SELECT tmp.*
,SUM(tmp.Amount) AS tmpAmount
#, annual_first_date, annual_last_date
, ps.EmployeeID
FROM thirteenthmonthpay tmp
INNER JOIN paystub ps
	ON ps.RowID=tmp.PaystubID
	AND ps.OrganizationID=tmp.OrganizationID
INNER JOIN annualperiods pp ON pp.RowID=ps.PayPeriodID
INNER JOIN employee e
	ON e.RowID=ps.EmployeeID
	AND e.EmployeeType='Daily'
	AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
WHERE tmp.OrganizationID=OrganizID
GROUP BY ps.EmployeeID
;

/**/ UPDATE paystub ps
INNER JOIN thirteenthmonthofdaily ii ON ii.EmployeeID=ps.EmployeeID
SET ps.`ThirteenthMonthPay` = ii.tmpAmount
, ps.ThirteenthMonthInclusion = TRUE
, ps.TotalGrossSalary = (ps.TotalGrossSalary + ii.tmpAmount)
, ps.LastUpd = CURRENT_TIMESTAMP()
, ps.LastUpdBy = UserRowID
WHERE ps.OrganizationID=OrganizID
AND ps.PayPeriodID=PayPeriodRowID
;

UPDATE paystubactual ps
INNER JOIN thirteenthmonthofdaily ii ON ii.EmployeeID=ps.EmployeeID
SET ps.`ThirteenthMonthPay` = ii.tmpAmount
, ps.ThirteenthMonthInclusion = TRUE
, ps.TotalGrossSalary = (ps.TotalGrossSalary + ii.tmpAmount)
WHERE ps.OrganizationID=OrganizID
AND ps.PayPeriodID=PayPeriodRowID
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

DROP TEMPORARY TABLE IF EXISTS annualcompletion;
CREATE TEMPORARY TABLE annualcompletion
SELECT ps.EmployeeID
, COUNT(ps.RowID) `CountPeriods`
, i.*
FROM annualperiods i
LEFT JOIN paystub ps ON ps.OrganizationID=i.OrganizationID AND ps.PayPeriodID=i.RowID
GROUP BY ps.EmployeeID
HAVING ps.EmployeeID IS NOT NULL
;

DROP TEMPORARY TABLE IF EXISTS thirteenthmonthpayment;
CREATE TEMPORARY TABLE thirteenthmonthpayment
SELECT i.*
, ii.CountPeriods
, (ii.CountPeriods / twentyFour) `Result`
, i.Salary * (ii.CountPeriods / twentyFour) `DeclaredThirteenthMonthPayment`
, i.TrueSalary * (ii.CountPeriods / twentyFour) `ActualThirteenthMonthPayment`
FROM salariesperperiod i
INNER JOIN annualcompletion ii ON ii.EmployeeID=i.EmployeeID
WHERE @dateTwo BETWEEN i.PayFromDate AND i.PayToDate
;

/**/ UPDATE paystub ps
INNER JOIN thirteenthmonthpayment ii ON ii.EmployeeID=ps.EmployeeID
SET ps.`ThirteenthMonthPay` = ii.DeclaredThirteenthMonthPayment
, ps.ThirteenthMonthInclusion = TRUE
, ps.TotalGrossSalary = (ps.TotalGrossSalary + ii.DeclaredThirteenthMonthPayment)
, ps.LastUpd = CURRENT_TIMESTAMP()
, ps.LastUpdBy = UserRowID
WHERE ps.OrganizationID=OrganizID
AND ps.PayPeriodID=PayPeriodRowID
;

UPDATE paystubactual ps
INNER JOIN thirteenthmonthpayment ii ON ii.EmployeeID=ps.EmployeeID
SET ps.`ThirteenthMonthPay` = ii.ActualThirteenthMonthPayment
, ps.ThirteenthMonthInclusion = TRUE
, ps.TotalGrossSalary = (ps.TotalGrossSalary + ii.DeclaredThirteenthMonthPayment)
WHERE ps.OrganizationID=OrganizID
AND ps.PayPeriodID=PayPeriodRowID
;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
