-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.5.5-10.0.12-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win32
-- HeidiSQL Version:             8.3.0.4694
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for procedure gotescopayrolldb_latest.GET_employee_bonusofthisperiod
DROP PROCEDURE IF EXISTS `GET_employee_bonusofthisperiod`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `GET_employee_bonusofthisperiod`(IN `OrganizID` INT, IN `AllowanceFrequenzy` VARCHAR(50), IN `IsTaxable` CHAR(1), IN `DatePayFrom` DATE, IN `DatePayTo` DATE)
    DETERMINISTIC
BEGIN



DECLARE isEndOfMonth CHAR(1);

DECLARE MonthCount DECIMAL(11,2) DEFAULT 12.0;

DECLARE firstdate DATE;

DECLARE thismonth VARCHAR(2);

DECLARE thisyear INT(11);

SET @timediffcount = 0.00;

IF AllowanceFrequenzy = 'Semi-monthly' THEN
	
	SET @dailyallowanceamount = 0.000000;
	
	SELECT
	eb.BonusAmount AS TotalBonusAmount
	,eb.EmployeeID
	,eb.ProductID
	FROM employeebonus eb
	INNER JOIN employee e ON e.OrganizationID=OrganizID AND e.RowID=eb.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
	WHERE eb.`AllowanceFrequency`=AllowanceFrequenzy
	AND eb.TaxableFlag=IsTaxable
	AND eb.EmployeeID=e.RowID
	AND eb.OrganizationID=OrganizID
	AND (eb.EffectiveStartDate >= DatePayFrom OR eb.EffectiveEndDate >= DatePayFrom)
	AND (eb.EffectiveStartDate <= DatePayTo OR eb.EffectiveEndDate <= DatePayTo);

ELSEIF AllowanceFrequenzy = 'Monthly' THEN

	SELECT (`Half` = 0),`Month`,`Year` FROM payperiod WHERE OrganizationID=OrganizID AND PayFromDate=DatePayFrom AND PayToDate=DatePayTo LIMIT 1 INTO isEndOfMonth,thismonth,thisyear;
	
	
	
	IF isEndOfMonth = '1' THEN
	
		SELECT PayFromDate FROM payperiod WHERE OrganizationID=OrganizID AND `Month`=thismonth AND `Year`=thisyear ORDER BY PayFromDate,PayToDate LIMIT 1 INTO firstdate;
					
		SELECT
		eb.BonusAmount AS TotalBonusAmount
		,eb.EmployeeID
		,eb.ProductID
		FROM employeebonus eb
		INNER JOIN employee e ON e.OrganizationID=OrganizID AND e.RowID=eb.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
		WHERE eb.`AllowanceFrequency`=AllowanceFrequenzy
		AND eb.TaxableFlag=IsTaxable
		AND eb.OrganizationID=OrganizID
		AND (eb.EffectiveStartDate >= firstdate OR eb.EffectiveEndDate >= firstdate)
		AND (eb.EffectiveStartDate <= DatePayTo OR eb.EffectiveEndDate <= DatePayTo);

	ELSE
		SELECT 0 AS TotalBonusAmount, '' AS EmployeeID, 0 AS ProductID;
		
	END IF;
	
ELSEIF AllowanceFrequenzy = 'One time' THEN
	
	SELECT
	eb.BonusAmount AS TotalBonusAmount
	,eb.EmployeeID
	,eb.ProductID
	FROM employeebonus eb
	INNER JOIN employee e ON e.OrganizationID=OrganizID AND e.RowID=eb.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
	WHERE eb.`AllowanceFrequency`=AllowanceFrequenzy
	AND eb.TaxableFlag=IsTaxable
	AND eb.EmployeeID=e.RowID
	AND eb.OrganizationID=OrganizID
	AND eb.EffectiveStartDate BETWEEN DatePayFrom AND DatePayTo;

ELSEIF AllowanceFrequenzy = 'Daily' THEN
	
	SELECT
	0 AS TotalBonusAmount
	,0 AS EmployeeID
	,0 AS ProductID;

ELSEIF AllowanceFrequenzy = 'Else condition' THEN

	SET @day_pay = 0.0;

	SELECT
	et.EmployeeID
	,et.`Date`
	,(SELECT @timediffcount := COMPUTE_TimeDifference(sh.TimeFrom,sh.TimeTo)) AS Equatn
	,(SELECT @timediffcount := IF(@timediffcount < 6,@timediffcount,(@timediffcount - 1.0))) AS timediffcount
	
	,(et.RegularHoursWorked * (ea.AllowanceAmount / sh.DivisorToDailyRate)) AS TotalBonusAmount
	,es.ShiftID
	FROM employeetimeentry et
	INNER JOIN employee e ON e.OrganizationID=OrganizID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
	INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
	INNER JOIN shift sh ON sh.RowID=es.ShiftID
	INNER JOIN employeebonus ea ON ea.AllowanceFrequency=AllowanceFrequenzy AND ea.TaxableFlag=IsTaxable AND ea.EmployeeID=e.RowID AND ea.OrganizationID=OrganizID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
	INNER JOIN product p ON p.RowID=ea.ProductID
	WHERE et.OrganizationID=OrganizID AND et.`Date` BETWEEN DatePayFrom AND DatePayTo
UNION ALL
	SELECT
	et.EmployeeID
	,et.`Date`
	,0 AS Equatn
	,0 AS timediffcount
	,ea.AllowanceAmount AS TotalBonusAmount
	,0 AS ShiftID
	FROM employeetimeentry et
	INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND LOCATE('Regular Holi',pr.PayType) > 0
	INNER JOIN employee e ON e.OrganizationID=OrganizID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
	INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
	INNER JOIN shift sh ON sh.RowID=es.ShiftID
	INNER JOIN employeebonus ea ON ea.AllowanceFrequency=AllowanceFrequenzy AND IF(IsTaxable='1', (ea.TaxableFlag=IsTaxable), FALSE) AND ea.EmployeeID=e.RowID AND ea.OrganizationID=OrganizID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
	INNER JOIN product p ON p.RowID=ea.ProductID AND LOCATE('cola',p.PartNo) > 0
	WHERE et.OrganizationID=OrganizID AND et.RegularHoursAmount=0 AND et.TotalDayPay > 0 AND et.`Date` BETWEEN DatePayFrom AND DatePayTo;
	
	

	
END IF;
	
END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
