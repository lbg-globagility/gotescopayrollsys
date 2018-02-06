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

-- Dumping structure for trigger gotescopayrolldb_latest.AFTINS_paystub_then_paystubitem
DROP TRIGGER IF EXISTS `AFTINS_paystub_then_paystubitem`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `AFTINS_paystub_then_paystubitem` AFTER INSERT ON `paystub` FOR EACH ROW BEGIN

DECLARE viewID INT(11);

DECLARE IsrbxpayrollFirstHalfOfMonth TEXT;

DECLARE anyint INT(11);

DECLARE product_rowid INT(11);

DECLARE anyamount DECIMAL(14,6);

DECLARE allowancetype_IDs VARCHAR(150);

DECLARE loantype_IDs VARCHAR(150);

DECLARE payperiod_type VARCHAR(50);


DECLARE anyvchar VARCHAR(150);


DECLARE vl_per_payp DECIMAL(11,6);

DECLARE sl_per_payp DECIMAL(11,6);

DECLARE ml_per_payp DECIMAL(11,6);

DECLARE othr_per_payp DECIMAL(11,6);

DECLARE addvl_per_payp DECIMAL(11,6);

DECLARE isOneYearService CHAR(1);

DECLARE e_startdate DATE;

DECLARE e_type VARCHAR(50);

DECLARE IsFirstTimeSalary CHAR(1);

DECLARE totalworkamount DECIMAL(11,2);

DECLARE empsalRowID INT(11);

DECLARE actualrate DECIMAL(11,6);

DECLARE actualgross DECIMAL(11,2);

DECLARE pftype VARCHAR(50);

DECLARE MonthCount INT(11) DEFAULT 12;

DECLARE firstdate DATE;

DECLARE loan_inprogress_status VARCHAR(50) DEFAULT '';

DECLARE ecola_rowid INT(11);

DECLARE default_min_hrswork INT(11) DEFAULT 8;

SELECT RowID FROM product WHERE OrganizationID=NEW.OrganizationID AND LCASE(PartNo)='ecola' AND `Category`='Allowance type' INTO ecola_rowid;

SELECT TRIM(SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(ii.COLUMN_COMMENT,',',2)),',',-1)) FROM information_schema.`COLUMNS` ii WHERE ii.TABLE_SCHEMA='gotescopayrolldatabaseoct3' AND ii.COLUMN_NAME='Status' AND ii.TABLE_NAME='employeeloanschedule' INTO loan_inprogress_status;

SELECT pr.`Half` FROM payperiod pr WHERE pr.RowID=NEW.PayPeriodID INTO IsrbxpayrollFirstHalfOfMonth;

SELECT pr.PayFromDate
FROM payperiod pr
INNER JOIN payperiod prt ON prt.RowID=NEW.PayPeriodID
WHERE pr.`Month`=prt.`Month` AND pr.`Year`=prt.`Year` AND pr.TotalGrossSalary=prt.TotalGrossSalary AND pr.OrganizationID=NEW.OrganizationID
ORDER BY pr.PayFromDate,pr.PayToDate
LIMIT 1 INTO firstdate;

IF IsrbxpayrollFirstHalfOfMonth = '0' THEN

	SET payperiod_type = 'End of the month';

ELSE

	SET payperiod_type = 'First half';

END IF;
	

SELECT RowID FROM product WHERE PartNo='.PAGIBIG' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, NEW.TotalEmpHDMF) INTO anyint;

SELECT RowID FROM product WHERE PartNo='.PhilHealth' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, NEW.TotalEmpPhilhealth) INTO anyint;

SELECT RowID FROM product WHERE PartNo='.SSS' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, NEW.TotalEmpSSS) INTO anyint;

SELECT RowID FROM product WHERE PartNo='Absent' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
SELECT SUM(Absent) FROM employeetimeentry WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO anyamount;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;

SELECT RowID FROM product WHERE PartNo='Tardiness' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
SELECT SUM(HoursLateAmount) FROM employeetimeentry WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO anyamount;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;

SELECT RowID FROM product WHERE PartNo='Undertime' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
SELECT SUM(UndertimeHoursAmount) FROM employeetimeentry WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO anyamount;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;





SELECT RowID FROM product WHERE PartNo='Holiday pay' AND OrganizationID=NEW.OrganizationID INTO product_rowid;


SELECT SUM(ete.HolidayPayAmount)
FROM employeetimeentry ete
INNER JOIN employee e ON e.RowID=ete.EmployeeID AND e.OrganizationID=ete.OrganizationID AND (e.CalcSpecialHoliday='1' OR e.CalcHoliday='1')
INNER JOIN payrate pr ON pr.RowID=ete.PayRateID AND pr.PayType!='Regular Day'
WHERE ete.EmployeeID=NEW.EmployeeID AND ete.OrganizationID=NEW.OrganizationID AND ete.`Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO anyamount;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, IFNULL(anyamount,0.0)) INTO anyint;

SELECT SUM(ete.HolidayPayAmount)
FROM employeetimeentryactual ete
INNER JOIN employee e ON e.RowID=ete.EmployeeID AND e.OrganizationID=ete.OrganizationID AND (e.CalcSpecialHoliday='1' OR e.CalcHoliday='1')
INNER JOIN payrate pr ON pr.RowID=ete.PayRateID AND pr.PayType!='Regular Day'
WHERE ete.EmployeeID=NEW.EmployeeID AND ete.OrganizationID=NEW.OrganizationID AND ete.`Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate AND ete.HolidayPayAmount > 0 INTO anyamount;				

INSERT INTO paystubitem(RowID,OrganizationID,Created,CreatedBy,PayStubID,ProductID,PayAmount,Undeclared) VALUES (NULL,NEW.OrganizationID,CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.RowID,product_rowid,anyamount,1) ON DUPLICATE KEY UPDATE LastUpd=CURRENT_TIMESTAMP(),LastUpdBy=NEW.LastUpdBy,PayAmount=anyamount;

SELECT RowID FROM product WHERE PartNo='Night differential' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
SELECT SUM(NightDiffHoursAmount) FROM employeetimeentry WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO anyamount;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;

SELECT RowID FROM product WHERE PartNo='Night differential OT' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
SELECT SUM(NightDiffOTHoursAmount) FROM employeetimeentry WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO anyamount;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;

SELECT RowID FROM product WHERE PartNo='Overtime' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
SELECT SUM(OvertimeHoursAmount) FROM employeetimeentry WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO anyamount;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;










SELECT RowID FROM product WHERE PartNo='Gross Income' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, NEW.TotalGrossSalary) INTO anyint;

SELECT RowID FROM product WHERE PartNo='Net Income' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, NEW.TotalNetSalary) INTO anyint;

SELECT RowID FROM product WHERE PartNo='Taxable Income' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, NEW.TotalTaxableSalary) INTO anyint;

SELECT RowID FROM product WHERE PartNo='Withholding Tax' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, NEW.TotalEmpWithholdingTax) INTO anyint;
















SELECT GROUP_CONCAT(p.RowID)
FROM product p
INNER JOIN category c ON c.CategoryName='Allowance Type' AND c.OrganizationID=NEW.OrganizationID AND c.RowID=p.CategoryID
WHERE p.OrganizationID=NEW.OrganizationID
INTO allowancetype_IDs;

SELECT
GROUP_CONCAT(DISTINCT(ea.ProductID))
FROM employeetimeentry ete
INNER JOIN (SELECT * FROM employeeallowance WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND (EffectiveStartDate >= NEW.PayFromDate OR EffectiveEndDate >= NEW.PayFromDate) AND (EffectiveStartDate <= NEW.PayToDate OR EffectiveEndDate <= NEW.PayToDate)) ea ON ea.RowID > 0
WHERE ete.EmployeeID=NEW.EmployeeID
AND ete.OrganizationID=NEW.OrganizationID
AND ete.`Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate
INTO anyvchar;

SET @dailyallowanceamount = 0.00;

SET @timediffcount = 0.00;

INSERT INTO paystubitem(ProductID,OrganizationID,Created,CreatedBy,PayStubID,PayAmount,Undeclared)
	SELECT
	ii.ProductID
	,NEW.OrganizationID
	,CURRENT_TIMESTAMP()
	,NEW.LastUpdBy
	,NEW.RowID
	,ii.TotalAllowanceAmount
	,'0'
	FROM
	(
		SELECT ii.AllowanceAmount - (SUM(i.HoursToLess) * ((i.AllowanceAmount / (i.WorkDaysPerYear / (i.PAYFREQDIV * 12))) / 8)) AS TotalAllowanceAmount,ii.ProductID
			FROM paystubitem_sum_semimon_allowance_group_prodid i
			INNER JOIN (SELECT ea.*,MIN(d.DateValue) AS DateRange1,MAX(d.DateValue) AS DateRange2 FROM dates d INNER JOIN employeeallowance ea ON ea.ProductID != ecola_rowid AND ea.AllowanceFrequency='Semi-monthly' AND ea.EmployeeID=NEW.EmployeeID AND ea.OrganizationID=NEW.OrganizationID AND d.DateValue BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate WHERE d.DateValue BETWEEN NEW.PayFromDate AND NEW.PayToDate GROUP BY ea.RowID ORDER BY d.DateValue) ii ON i.EmployeeID=ii.EmployeeID AND i.OrganizationID=ii.OrganizationID AND i.`Date` BETWEEN ii.DateRange1 AND ii.DateRange2
		
		GROUP BY ii.RowID
	) ii
	WHERE ii.ProductID IS NOT NULL
ON
DUPLICATE
KEY
UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=NEW.CreatedBy
	,PayAmount=ii.TotalAllowanceAmount;
		

SET @timediffcount = 0.00;

SELECT RowID FROM product WHERE OrganizationID=NEW.OrganizationID AND LCASE(PartNo)='ecola' AND `Category`='Allowance type' LIMIT 1 INTO @ecola_rowid;

SET @day_pay = 0.0;SET @day_pay1 = 0.0;SET @day_pay2 = 0.0;

INSERT INTO paystubitem(ProductID,OrganizationID,Created,CreatedBy,PayStubID,PayAmount,Undeclared)
	SELECT
	ii.ProductID
	,NEW.OrganizationID
	,CURRENT_TIMESTAMP()
	,NEW.LastUpdBy
	,NEW.RowID
	,ii.TotalAllowanceAmount
	,'0'
	FROM
	(
		# SELECT i.*,SUM(i.TotalAllowanceAmt) AS TotalAllowanceAmount FROM paystubitem_sum_daily_allowance_group_prodid i WHERE i.EmployeeID=NEW.EmployeeID AND i.ProductID != ecola_rowid AND i.OrganizationID=NEW.OrganizationID AND i.`Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate GROUP BY i.ProductID
			
		SELECT i.ProductID, SUM(TotalAllowanceAmount) `TotalAllowanceAmount`
		FROM 
			(
			SELECT et.RowID,
			et.EmployeeID
			,et.`Date`
			,(SELECT @timediffcount := sh.DivisorToDailyRate # COMPUTE_TimeDifference(sh.TimeFrom,sh.TimeTo)
			  ) AS Equatn
			,(SELECT @timediffcount := sh.DivisorToDailyRate # IF(@timediffcount < 6,@timediffcount,(@timediffcount - 1.0))
			  ) AS timediffcount
			
			,(et.RegularHoursWorked * (ea.AllowanceAmount / sh.DivisorToDailyRate)) AS TotalAllowanceAmount
			,ea.ProductID
			,'1st statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Day'
			INNER JOIN employee e ON e.RowID=NEW.EmployeeID AND e.OrganizationID=et.OrganizationID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
			INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
			INNER JOIN shift sh ON sh.RowID=es.ShiftID
			INNER JOIN employeeallowance ea ON ea.EmployeeID=e.RowID AND ea.AllowanceFrequency='Daily' AND ea.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
			INNER JOIN product p ON p.RowID=ea.ProductID
											AND p.RowID != @ecola_rowid
			WHERE et.OrganizationID=NEW.OrganizationID AND et.`Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate
		UNION
			SELECT et.RowID,
			et.EmployeeID
			,et.`Date`
			,(@day_pay1 := GET_employeerateperday(et.EmployeeID,et.OrganizationID,et.`Date`)) AS Equatn
			,0 AS timediffcount
			,ea.AllowanceAmount * ((et.HolidayPayAmount + ((et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) * (@day_pay1 / sh.DivisorToDailyRate))) / @day_pay1) AS TotalAllowanceAmount
			,ea.ProductID
			,'2nd statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Holiday'
			INNER JOIN employee e ON e.RowID=NEW.EmployeeID AND e.OrganizationID=et.OrganizationID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') AND e.CalcHoliday='1'
			INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
			INNER JOIN shift sh ON sh.RowID=es.ShiftID
			INNER JOIN employeeallowance ea ON ea.EmployeeID=e.RowID AND ea.AllowanceFrequency='Daily' AND ea.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
			INNER JOIN product p ON p.RowID=ea.ProductID
											#AND p.RowID != @ecola_rowid
											AND LOCATE('cola', p.PartNo) > 0
			WHERE et.OrganizationID=NEW.OrganizationID AND et.`Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate
		UNION
			SELECT et.RowID,
			et.EmployeeID
			,et.`Date`
			,(@day_pay1 := GET_employeerateperday(et.EmployeeID,et.OrganizationID,et.`Date`)) AS Equatn
			,0 AS timediffcount
			,ea.AllowanceAmount * ((et.HolidayPayAmount + ((et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) * (@day_pay1 / sh.DivisorToDailyRate))) / @day_pay1) AS TotalAllowanceAmount
			,ea.ProductID
			,'3rd statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Special Non-Working Holiday'
			INNER JOIN employee e ON e.RowID=NEW.EmployeeID AND e.OrganizationID=et.OrganizationID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') AND e.EmployeeType!='Daily'
			INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
			INNER JOIN shift sh ON sh.RowID=es.ShiftID
			INNER JOIN employeeallowance ea ON ea.EmployeeID=e.RowID AND ea.AllowanceFrequency='Daily' AND ea.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
			INNER JOIN product p ON p.RowID=ea.ProductID
			                        #AND p.RowID != @ecola_rowid
											AND LOCATE('cola', p.PartNo) > 0
			WHERE et.OrganizationID=NEW.OrganizationID AND et.RegularHoursAmount=0 AND et.TotalDayPay > 0 AND et.`Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate
			
		UNION
			SELECT et.RowID,
			et.EmployeeID
			,et.`Date`
			,(@timediffcount := sh.DivisorToDailyRate # COMPUTE_TimeDifference(sh.TimeFrom,sh.TimeTo)
			  ) AS Equatn
			,(@timediffcount := sh.DivisorToDailyRate # IF(@timediffcount < 6,@timediffcount,(@timediffcount - 1.0))
			  ) AS timediffcount
			
			,ea.AllowanceAmount `TotalAllowanceAmount`
			,ea.ProductID
			,'4th statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Day'
			INNER JOIN employee e ON e.RowID=NEW.EmployeeID AND e.OrganizationID=et.OrganizationID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
			INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
			INNER JOIN shift sh ON sh.RowID=es.ShiftID
			INNER JOIN employeeallowance ea ON ea.EmployeeID=e.RowID AND ea.AllowanceFrequency='Daily' AND ea.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
			INNER JOIN product p ON p.RowID=ea.ProductID
											AND p.RowID = @ecola_rowid
			WHERE et.OrganizationID=NEW.OrganizationID AND et.`Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate
			AND et.RegularHoursWorked > 0
					
		UNION
			SELECT et.RowID
			,et.EmployeeID
			,et.`Date`
			,0 `Equatn`
			,0 `timediffcount`
			,ea.AllowanceAmount `TotalAllowanceAmount`
			,ea.ProductID
			,'5th statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr
			        ON pr.RowID=et.PayRateID AND pr.PayType='Regular Holiday'
			INNER JOIN employee e
			        ON e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated') AND e.CalcHoliday='1'
			LEFT JOIN employeeshift es
			       ON es.RowID=et.EmployeeShiftID
			INNER JOIN employeeallowance ea
			        ON ea.EmployeeID=e.RowID AND ea.AllowanceFrequency='Daily' AND ea.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
			INNER JOIN product p
			        ON p.RowID=ea.ProductID
			        AND p.RowID=@ecola_rowid
			WHERE et.EmployeeID=NEW.EmployeeID AND et.OrganizationID=NEW.OrganizationID AND et.`Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate
			AND (et.EmployeeShiftID IS NULL OR es.RestDay=1 OR e.DayOfRest=DAYOFWEEK(et.`Date`))
			
		UNION
			SELECT et.RowID
			,et.EmployeeID
			,et.`Date`
			,0 `Equatn`
			,0 `timediffcount`
			,IF((et.TotalDayPay / IF(e.EmployeeType='Daily', esa.BasicPay, ((esa.Salary * e.WorkDaysPerYear) / MonthCount))) >= 1
	    , ea.AllowanceAmount
		 , (ea.AllowanceAmount * (et.TotalDayPay / IF(e.EmployeeType='Daily', esa.BasicPay, ((esa.Salary * e.WorkDaysPerYear) / MonthCount))))) `TotalAllowanceAmount`
			,ea.ProductID
			,'6th statement' `Result`
			FROM employeetimeentry et
			INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular day'
			INNER JOIN employee e ON e.OrganizationID=et.OrganizationID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
			INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID
			INNER JOIN shift sh ON sh.RowID=es.ShiftID
			INNER JOIN employeeallowance ea ON ea.EmployeeID=e.RowID AND ea.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
			INNER JOIN product p
			        ON p.RowID=ea.ProductID
			        AND p.RowID=@ecola_rowid
			INNER JOIN employeesalary esa ON esa.RowID=et.EmployeeSalaryID
			WHERE et.EmployeeID=NEW.EmployeeID AND et.OrganizationID=NEW.OrganizationID AND et.`Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate
			AND (et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) > 0 AND et.TotalDayPay > 0) i
			GROUP BY i.ProductID
			
	) ii
	WHERE ii.ProductID IS NOT NULL
ON
DUPLICATE
KEY
UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=NEW.LastUpdBy
	,PayAmount=ii.TotalAllowanceAmount;
	
/*INSERT INTO paystubitem(ProductID,OrganizationID,Created,CreatedBy,PayStubID,PayAmount,Undeclared)
	SELECT i.ProductID
	,NEW.OrganizationID
	,CURRENT_TIMESTAMP()
	,NEW.LastUpdBy
	,NEW.RowID
	,i.AllowanceAmount
	,0
	FROM (SELECT et.RowID ,ea.ProductID, SUM(ea.AllowanceAmount) `AllowanceAmount`
			FROM employeetimeentry et
			INNER JOIN employee e ON e.OrganizationID=et.OrganizationID AND e.RowID=et.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
			INNER JOIN employeeallowance ea ON ea.ProductID=ecola_rowid AND ea.AllowanceFrequency='Daily' AND ea.EmployeeID=e.RowID AND ea.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
			WHERE et.EmployeeID=NEW.EmployeeID AND et.OrganizationID=NEW.OrganizationID AND et.TotalDayPay > 0 AND et.`Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate) i
ON
DUPLICATE
KEY
UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=NEW.LastUpdBy
	,PayAmount=i.AllowanceAmount;*/

INSERT INTO paystubitem(ProductID,OrganizationID,Created,CreatedBy,PayStubID,PayAmount,Undeclared)
	SELECT i.ProductID
	,NEW.OrganizationID
	,CURRENT_TIMESTAMP()
	,NEW.LastUpdBy
	,NEW.RowID
	,i.AllowanceAmount
	,0
	FROM (/*SELECT ea.ProductID, ea.AllowanceAmount
			FROM employeeallowance ea WHERE ea.ProductID=ecola_rowid AND ea.AllowanceFrequency='Semi-monthly' AND ea.EmployeeID=NEW.EmployeeID AND ea.OrganizationID=NEW.OrganizationID AND (ea.EffectiveStartDate >= NEW.PayFromDate OR ea.EffectiveEndDate >= NEW.PayFromDate) AND (ea.EffectiveStartDate <= NEW.PayToDate OR ea.EffectiveEndDate <= NEW.PayToDate)*/
			SELECT ii.ProductID
			,(ii.AllowanceAmount - (SUM(i.HoursToLess) * ((i.AllowanceAmount / (i.WorkDaysPerYear / (i.PAYFREQDIV * MonthCount))) / default_min_hrswork))) `AllowanceAmount`
			FROM paystubitem_sum_semimon_allowance_group_prodid i
			INNER JOIN (SELECT ea.*
			            ,MIN(d.DateValue) `DateRange1`
							,MAX(d.DateValue) `DateRange2`
			            FROM dates d
							INNER JOIN employeeallowance ea
							        ON ea.AllowanceFrequency='Semi-monthly'
									     # AND TaxableFlag=IsTaxable
										  AND ea.OrganizationID=NEW.OrganizationID
										  AND ea.EmployeeID=NEW.EmployeeID
										  AND d.DateValue BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
							WHERE d.DateValue BETWEEN NEW.PayFromDate AND NEW.PayToDate
							GROUP BY ea.RowID ORDER BY d.DateValue) ii
			        ON i.EmployeeID=ii.EmployeeID
					     AND i.OrganizationID=ii.OrganizationID
						  AND i.`Date` BETWEEN ii.DateRange1 AND ii.DateRange2
						  AND i.`Fixed`=0
			GROUP BY ii.RowID
			) i
ON
DUPLICATE
KEY
UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=NEW.LastUpdBy
	,PayAmount=i.AllowanceAmount;
	
IF IsrbxpayrollFirstHalfOfMonth = '0' THEN 

	SET @dailyallowanceamount = 0.00;

	SET @timediffcount = 0.00;
	
	INSERT INTO paystubitem(ProductID,OrganizationID,Created,CreatedBy,PayStubID,PayAmount,Undeclared)
		SELECT
		ii.ProductID
		,NEW.OrganizationID
		,CURRENT_TIMESTAMP()
		,NEW.LastUpdBy
		,NEW.RowID
		,ii.TotalAllowanceAmount
		,'0'
		FROM
		(
			SELECT
			DISTINCT(ea.ProductID) AS ProductID
			,(SELECT @dailyallowanceamount := ROUND((ea.AllowanceAmount / (e.WorkDaysPerYear / MonthCount)),2)) AS Column1
			,(SELECT @timediffcount := COMPUTE_TimeDifference(sh.TimeFrom,sh.TimeTo)) AS Column2
			,(SELECT @timediffcount := IF(@timediffcount IN (4,5),@timediffcount,(@timediffcount - 1.0))) AS Column3
			,SUM(@dailyallowanceamount - ( ( (et.HoursLate + et.UndertimeHours) / @timediffcount ) * @dailyallowanceamount )) AS TotalAllowanceAmount
			FROM employeetimeentry et
			INNER JOIN employee e ON e.OrganizationID=NEW.OrganizationID AND e.RowID=NEW.EmployeeID AND e.EmploymentStatus NOT IN ('Resigned','Terminated')
			INNER JOIN employeeshift es ON es.RowID=et.EmployeeShiftID AND es.OrganizationID=NEW.OrganizationID
			INNER JOIN shift sh ON sh.RowID=es.ShiftID
			INNER JOIN employeeallowance ea ON ea.AllowanceFrequency='Monthly' AND ea.EmployeeID=e.RowID AND ea.OrganizationID=NEW.OrganizationID AND et.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
			INNER JOIN product p ON p.RowID=ea.ProductID
			WHERE et.OrganizationID=NEW.OrganizationID AND et.EmployeeID=e.RowID AND et.`Date` BETWEEN firstdate AND NEW.PayToDate
		) ii
		WHERE ii.ProductID IS NOT NULL
	ON
	DUPLICATE
	KEY
	UPDATE
		LastUpd=CURRENT_TIMESTAMP()
		,LastUpdBy=NEW.CreatedBy
		,PayAmount=PayAmount + ii.TotalAllowanceAmount;

END IF;














SELECT GROUP_CONCAT(p.RowID)
FROM product p
INNER JOIN category c ON c.CategoryName='Loan Type' AND c.OrganizationID=NEW.OrganizationID AND c.RowID=p.CategoryID
WHERE p.OrganizationID=NEW.OrganizationID
INTO loantype_IDs;

SELECT
GROUP_CONCAT(DISTINCT(els.LoanTypeID))
FROM employeeloanschedule els
WHERE els.EmployeeID=NEW.EmployeeID
AND els.OrganizationID=NEW.OrganizationID
AND IF(els.SubstituteEndDate IS NULL, els.`Status`, loan_inprogress_status)='In Progress'
AND els.DeductionSchedule IN ('Per pay period',payperiod_type)
AND (els.DedEffectiveDateFrom >= NEW.PayFromDate OR IFNULL(els.SubstituteEndDate,els.DedEffectiveDateTo) >= NEW.PayFromDate)
AND (els.DedEffectiveDateFrom <= NEW.PayToDate OR IFNULL(els.SubstituteEndDate,els.DedEffectiveDateTo) <= NEW.PayToDate)
INTO anyvchar;

INSERT INTO paystubitem(OrganizationID,Created,CreatedBy,PayStubID,ProductID,PayAmount,Undeclared)
	SELECT
	NEW.OrganizationID
	,CURRENT_TIMESTAMP()
	,NEW.CreatedBy
	,NEW.RowID
	,p_loan.RowID
	,IFNULL(els.DeductionAmount,0)
	,'0'
	FROM product p_loan
	INNER JOIN payperiod pp ON pp.RowID=NEW.PayPeriodID
	LEFT JOIN employeeloanschedule els
			ON els.OrganizationID=p_loan.OrganizationID
			AND els.EmployeeID=NEW.EmployeeID AND els.LoanTypeID=p_loan.RowID
			AND (pp.PayFromDate >= els.DedEffectiveDateFrom OR pp.PayToDate >= els.DedEffectiveDateFrom)
			AND (pp.PayFromDate <= els.DedEffectiveDateTo OR pp.PayToDate <= els.DedEffectiveDateTo)
			AND els.DeductionSchedule IN ('Per pay period',payperiod_type)
	WHERE p_loan.OrganizationID=NEW.OrganizationID AND p_loan.`Category`='Loan Type'
ON DUPLICATE KEY UPDATE
	LastUpdBy=NEW.CreatedBy;
	/*SELECT
	NEW.OrganizationID
	,CURRENT_TIMESTAMP()
	,NEW.CreatedBy
	,NEW.RowID
	,els.LoanTypeID
	,els.DeductionAmount
	,'0'
FROM employeeloanschedule els
WHERE els.EmployeeID=NEW.EmployeeID
AND els.OrganizationID=NEW.OrganizationID

AND els.DeductionSchedule IN ('Per pay period',payperiod_type)
AND (els.DedEffectiveDateFrom >= NEW.PayFromDate OR IFNULL(els.SubstituteEndDate,els.DedEffectiveDateTo) >= NEW.PayFromDate)
AND (els.DedEffectiveDateFrom <= NEW.PayToDate OR IFNULL(els.SubstituteEndDate,els.DedEffectiveDateTo) <= NEW.PayToDate)
ON
DUPLICATE
KEY UPDATE
	LastUpd=CURRENT_TIMESTAMP(),LastUpdBy=NEW.CreatedBy;*/

SET loantype_IDs = REPLACE(loantype_IDs,',,',',');

/*INSERT INTO paystubitem(OrganizationID,Created,CreatedBy,PayStubID,ProductID,PayAmount,Undeclared)
	SELECT
	NEW.OrganizationID
	,CURRENT_TIMESTAMP()
	,NEW.CreatedBy
	,NEW.RowID
	,p.RowID
	,0.0
	,'0'
FROM product p
INNER JOIN category c ON c.CategoryName='Loan Type' AND c.OrganizationID=NEW.OrganizationID AND c.RowID=p.CategoryID
WHERE p.OrganizationID=NEW.OrganizationID
AND LOCATE(p.RowID,anyvchar) = 0
ON
DUPLICATE
KEY UPDATE
	LastUpd=CURRENT_TIMESTAMP(),LastUpdBy=NEW.CreatedBy;*/














IF IsrbxpayrollFirstHalfOfMonth = '0' THEN
	                                                                                      
	UPDATE employeeloanschedule SET
	LoanPayPeriodLeft = LoanPayPeriodLeft - 1
	,TotalBalanceLeft = TotalBalanceLeft - DeductionAmount,LastUpd=CURRENT_TIMESTAMP(),LastUpdBy=NEW.CreatedBy
	,PayStubID=NEW.RowID
	WHERE OrganizationID=NEW.OrganizationID
	AND LoanPayPeriodLeft > 0
	AND IF(SubstituteEndDate IS NULL, `Status`, loan_inprogress_status)='In Progress'
	AND EmployeeID=NEW.EmployeeID
	AND DeductionSchedule IN ('End of the month','Per pay period')
	AND (NEW.PayFromDate >= DedEffectiveDateFrom OR NEW.PayToDate >= DedEffectiveDateFrom)
	AND (NEW.PayFromDate <= IFNULL(SubstituteEndDate,DedEffectiveDateTo) OR NEW.PayToDate <= IFNULL(SubstituteEndDate,DedEffectiveDateTo));
	#AND (DedEffectiveDateFrom >= NEW.PayFromDate OR IFNULL(SubstituteEndDate,DedEffectiveDateTo) >= NEW.PayFromDate)
	#AND (DedEffectiveDateFrom <= NEW.PayToDate OR IFNULL(SubstituteEndDate,DedEffectiveDateTo) <= NEW.PayToDate); 
                                       														                
ELSEIF IsrbxpayrollFirstHalfOfMonth = '1' THEN
         
	UPDATE employeeloanschedule SET
	LoanPayPeriodLeft = LoanPayPeriodLeft - 1
	,TotalBalanceLeft = TotalBalanceLeft - DeductionAmount,LastUpd=CURRENT_TIMESTAMP(),LastUpdBy=NEW.CreatedBy
	,PayStubID=NEW.RowID
	WHERE OrganizationID=NEW.OrganizationID
	AND LoanPayPeriodLeft > 0
	AND IF(SubstituteEndDate IS NULL, `Status`, loan_inprogress_status)='In Progress'
	AND EmployeeID=NEW.EmployeeID
	AND DeductionSchedule IN ('First half','Per pay period')
	AND (NEW.PayFromDate >= DedEffectiveDateFrom OR NEW.PayToDate >= DedEffectiveDateFrom)
	AND (NEW.PayFromDate <= IFNULL(SubstituteEndDate,DedEffectiveDateTo) OR NEW.PayToDate <= IFNULL(SubstituteEndDate,DedEffectiveDateTo));
	#AND (DedEffectiveDateFrom >= NEW.PayFromDate OR IFNULL(SubstituteEndDate,DedEffectiveDateTo) >= NEW.PayFromDate)
	#AND (DedEffectiveDateFrom <= NEW.PayToDate OR IFNULL(SubstituteEndDate,DedEffectiveDateTo) <= NEW.PayToDate);   

ELSE

	UPDATE employeeloanschedule SET
	LoanPayPeriodLeft = LoanPayPeriodLeft - 1
	,TotalBalanceLeft = TotalBalanceLeft - DeductionAmount,LastUpd=CURRENT_TIMESTAMP(),LastUpdBy=NEW.CreatedBy
	,PayStubID=NEW.RowID
	WHERE OrganizationID=NEW.OrganizationID
	AND LoanPayPeriodLeft > 0
	AND IF(SubstituteEndDate IS NULL, `Status`, loan_inprogress_status)='In Progress'
	AND EmployeeID=NEW.EmployeeID
	AND DeductionSchedule = 'Per pay period'
	AND (NEW.PayFromDate >= DedEffectiveDateFrom OR NEW.PayToDate >= DedEffectiveDateFrom)
	AND (NEW.PayFromDate <= IFNULL(SubstituteEndDate,DedEffectiveDateTo) OR NEW.PayToDate <= IFNULL(SubstituteEndDate,DedEffectiveDateTo));
	#AND (DedEffectiveDateFrom >= NEW.PayFromDate OR IFNULL(SubstituteEndDate,DedEffectiveDateTo) >= NEW.PayFromDate)
	#AND (DedEffectiveDateFrom <= NEW.PayToDate OR IFNULL(SubstituteEndDate,DedEffectiveDateTo) <= NEW.PayToDate);   

END IF;

SELECT RowID FROM `view` WHERE ViewName='Employee Pay Slip' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO viewID;

INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed
) VALUES (CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'EmployeeID',NEW.RowID,'',NEW.EmployeeID,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'PayPeriodID',NEW.RowID,'',NEW.PayPeriodID,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'TimeEntryID',NEW.RowID,'',NEW.TimeEntryID,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'PayFromDate',NEW.RowID,'',NEW.PayFromDate,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'PayToDate',NEW.RowID,'',NEW.PayToDate,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'TotalGrossSalary',NEW.RowID,'',NEW.TotalGrossSalary,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'TotalNetSalary',NEW.RowID,'',NEW.TotalNetSalary,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'TotalTaxableSalary',NEW.RowID,'',NEW.TotalTaxableSalary,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'TotalEmpSSS',NEW.RowID,'',NEW.TotalEmpSSS,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'TotalEmpWithholdingTax',NEW.RowID,'',NEW.TotalEmpWithholdingTax,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'TotalCompSSS',NEW.RowID,'',NEW.TotalCompSSS,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'TotalEmpPhilhealth',NEW.RowID,'',NEW.TotalEmpPhilhealth,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'TotalCompPhilhealth',NEW.RowID,'',NEW.TotalCompPhilhealth,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'TotalEmpHDMF',NEW.RowID,'',NEW.TotalEmpHDMF,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'TotalCompHDMF',NEW.RowID,'',NEW.TotalCompHDMF,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'TotalVacationDaysLeft',NEW.RowID,'',NEW.TotalVacationDaysLeft,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'TotalLoans',NEW.RowID,'',NEW.TotalLoans,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'TotalBonus',NEW.RowID,'',NEW.TotalBonus,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'TotalAllowance',NEW.RowID,'',NEW.TotalAllowance,'Insert');








/* paystubitem - BONUS (start)*/
INSERT INTO paystubitem
(
	ProductID
	, PayStubID
	, OrganizationID
	, Created
	, CreatedBy
	, PayAmount
	, Undeclared
) SELECT ii.`RowID`
	, NEW.RowID
	, NEW.OrganizationID
	, CURRENT_TIMESTAMP()
	, NEW.LastUpdBy
	, ii.`BonusAmount`
	, '0'
	FROM (SELECT i.*
			FROM
				(SELECT
				p.RowID
				,eb.BonusAmount
				FROM employeebonus eb
				INNER JOIN employee e ON e.RowID=eb.EmployeeID AND e.RowID=NEW.EmployeeID
				INNER JOIN product p ON p.RowID=eb.ProductID AND p.`Category`='Bonus' AND p.ActiveData=1
				INNER JOIN payperiod pp ON pp.RowID=NEW.PayPeriodID
				WHERE eb.OrganizationID=NEW.OrganizationID
				AND eb.AllowanceFrequency IS NOT NULL
				AND ((eb.AllowanceFrequency = 'Semi-monthly' AND pp.TotalGrossSalary=1)
				     OR (eb.AllowanceFrequency = 'Monthly' AND pp.Half=0 AND pp.TotalGrossSalary=1))
				AND IFNULL(eb.BonusAmount, 0) != 0
				AND (eb.EffectiveStartDate IS NOT NULL
				     AND eb.EffectiveEndDate IS NOT NULL)
				AND (eb.EffectiveStartDate >= NEW.PayFromDate OR eb.EffectiveEndDate >= NEW.PayFromDate)
				AND (eb.EffectiveStartDate <= NEW.PayToDate OR eb.EffectiveEndDate <= NEW.PayToDate)
				
			UNION
				SELECT
				p.RowID
				,0 `BonusAmount`
				FROM product p
				WHERE p.`Category`='Bonus' AND p.ActiveData=1 AND p.OrganizationID=NEW.OrganizationID
				) i
			GROUP BY i.RowID
	      ) ii
ON
DUPLICATE
KEY
UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	, LastUpdBy=NEW.LastUpdBy
	, PayAmount=ii.`BonusAmount`;
/* paystubitem - BONUS (end)*/









SELECT GET_employeeundeclaredsalarypercent(NEW.EmployeeID,NEW.OrganizationID,NEW.PayFromDate,NEW.PayToDate) INTO actualrate;

SELECT e.StartDate,e.EmployeeType,pf.PayFrequencyType FROM employee e INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID WHERE e.RowID=NEW.EmployeeID AND e.OrganizationID=NEW.OrganizationID INTO e_startdate,e_type,pftype;

SELECT (e_startdate BETWEEN NEW.PayFromDate AND NEW.PayToDate) INTO IsFirstTimeSalary;

IF e_type IN ('Fixed','Monthly') AND IsFirstTimeSalary = '1' THEN
	
	IF e_type = 'Monthly' THEN
	
		SELECT SUM(TotalDayPay),EmployeeSalaryID FROM employeetimeentryactual WHERE OrganizationID=NEW.OrganizationID AND EmployeeID=NEW.EmployeeID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO totalworkamount,empsalRowID;
		
		IF totalworkamount IS NULL THEN
			
			SELECT SUM(TotalDayPay),EmployeeSalaryID FROM employeetimeentry WHERE OrganizationID=NEW.OrganizationID AND EmployeeID=NEW.EmployeeID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO totalworkamount,empsalRowID;
				
			SET totalworkamount = IFNULL(totalworkamount,0);
			
			SELECT totalworkamount + (totalworkamount * actualrate) INTO totalworkamount;
			
		END IF;
		
		SET totalworkamount = IFNULL(totalworkamount,0);

	ELSEIF e_type = 'Fixed' THEN
	
		SELECT es.BasicPay FROM employeesalary es WHERE es.EmployeeID=NEW.EmployeeID AND es.OrganizationID=NEW.OrganizationID AND (es.EffectiveDateFrom >= NEW.PayFromDate OR IFNULL(es.EffectiveDateTo,NEW.PayToDate) >= NEW.PayFromDate) AND (es.EffectiveDateFrom <= NEW.PayToDate OR IFNULL(es.EffectiveDateTo,NEW.PayToDate) <= NEW.PayToDate) ORDER BY es.EffectiveDateFrom DESC LIMIT 1 INTO totalworkamount;

		SET totalworkamount = IFNULL(totalworkamount,0) * (IF(actualrate < 1, (actualrate + 1), actualrate));

	END IF;
		
ELSEIF e_type IN ('Fixed','Monthly') AND IsFirstTimeSalary = '0' THEN
	
	IF e_type = 'Monthly' THEN
	
		SELECT (TrueSalary / PAYFREQUENCY_DIVISOR(pftype)) FROM employeesalary es WHERE es.EmployeeID=NEW.EmployeeID AND es.OrganizationID=NEW.OrganizationID AND (es.EffectiveDateFrom >= NEW.PayFromDate OR IFNULL(es.EffectiveDateTo,NEW.PayToDate) >= NEW.PayFromDate) AND (es.EffectiveDateFrom <= NEW.PayToDate OR IFNULL(es.EffectiveDateTo,NEW.PayToDate) <= NEW.PayToDate) ORDER BY es.EffectiveDateFrom DESC LIMIT 1 INTO totalworkamount;
		
		SELECT ( (totalworkamount - (SUM(HoursLateAmount) + SUM(UndertimeHoursAmount) + SUM(Absent))) + SUM(OvertimeHoursAmount) ) FROM employeetimeentryactual WHERE OrganizationID=NEW.OrganizationID AND EmployeeID=NEW.EmployeeID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO totalworkamount;
		
		IF totalworkamount IS NULL THEN
			
			SELECT SUM(HoursLateAmount + UndertimeHoursAmount + Absent) FROM employeetimeentry WHERE OrganizationID=NEW.OrganizationID AND EmployeeID=NEW.EmployeeID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO totalworkamount;
				
			SET totalworkamount = IFNULL(totalworkamount,0);
			
			SELECT totalworkamount + (totalworkamount * actualrate) INTO totalworkamount;
			
		END IF;
		
		SET totalworkamount = IFNULL(totalworkamount,0);

	ELSEIF e_type = 'Fixed' THEN
	
		SELECT es.BasicPay FROM employeesalary es WHERE es.EmployeeID=NEW.EmployeeID AND es.OrganizationID=NEW.OrganizationID AND (es.EffectiveDateFrom >= NEW.PayFromDate OR IFNULL(es.EffectiveDateTo,NEW.PayToDate) >= NEW.PayFromDate) AND (es.EffectiveDateFrom <= NEW.PayToDate OR IFNULL(es.EffectiveDateTo,NEW.PayToDate) <= NEW.PayToDate) ORDER BY es.EffectiveDateFrom DESC LIMIT 1 INTO totalworkamount;

		SET totalworkamount = IFNULL(totalworkamount,0) * (IF(actualrate < 1, (actualrate + 1), actualrate));

	END IF;
		
ELSE

	SELECT SUM(TotalDayPay),EmployeeSalaryID FROM employeetimeentryactual WHERE OrganizationID=NEW.OrganizationID AND EmployeeID=NEW.EmployeeID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO totalworkamount,empsalRowID;
	
	IF totalworkamount IS NULL THEN
		
		SELECT SUM(TotalDayPay),EmployeeSalaryID FROM employeetimeentry WHERE OrganizationID=NEW.OrganizationID AND EmployeeID=NEW.EmployeeID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO totalworkamount,empsalRowID;
			
		SET totalworkamount = IFNULL(totalworkamount,0);
		
		SELECT totalworkamount + (totalworkamount * actualrate) INTO totalworkamount;
		
	END IF;
	
	SET totalworkamount = IFNULL(totalworkamount,0);

END IF;

SET actualgross = totalworkamount + NEW.TotalAllowance + NEW.TotalBonus;
					
SET @total_govt_contrib = (NEW.TotalEmpSSS + NEW.TotalEmpPhilhealth + NEW.TotalEmpHDMF);

INSERT INTO paystubactual
(
	RowID
	,OrganizationID
	,PayPeriodID
	,EmployeeID
	,TimeEntryID
	,PayFromDate
	,PayToDate
	,TotalGrossSalary
	,TotalNetSalary
	,TotalTaxableSalary
	,TotalEmpSSS
	,TotalEmpWithholdingTax
	,TotalCompSSS
	,TotalEmpPhilhealth
	,TotalCompPhilhealth
	,TotalEmpHDMF
	,TotalCompHDMF
	,TotalVacationDaysLeft
	,TotalLoans
	,TotalBonus
	,TotalAllowance
	,TotalAdjustments
	,ThirteenthMonthInclusion
	,NondeductibleTotalLoans
) VALUES (
	NEW.RowID
	,NEW.OrganizationID
	,NEW.PayPeriodID
	,NEW.EmployeeID
	,NEW.TimeEntryID
	,NEW.PayFromDate
	,NEW.PayToDate
	,actualgross
	,(actualgross - (NEW.TotalEmpSSS + NEW.TotalEmpPhilhealth + NEW.TotalEmpHDMF + NEW.TotalEmpWithholdingTax)) - NEW.TotalLoans + (NEW.TotalAdjustments * actualrate)
	,(((NEW.TotalTaxableSalary + @total_govt_contrib) * actualrate) - @total_govt_contrib)
	,NEW.TotalEmpSSS
	,NEW.TotalEmpWithholdingTax
	,NEW.TotalCompSSS
	,NEW.TotalEmpPhilhealth
	,NEW.TotalCompPhilhealth
	,NEW.TotalEmpHDMF
	,NEW.TotalCompHDMF
	,NEW.TotalVacationDaysLeft
	,NEW.TotalLoans
	,NEW.TotalBonus
	,NEW.TotalAllowance
	,NEW.TotalAdjustments * actualrate
	,NEW.ThirteenthMonthInclusion
	,NEW.NondeductibleTotalLoans
) ON
DUPLICATE
KEY
UPDATE
	OrganizationID=NEW.OrganizationID
	,PayPeriodID=NEW.PayPeriodID
	,EmployeeID=NEW.EmployeeID
	,TimeEntryID=NEW.TimeEntryID
	,PayFromDate=NEW.PayFromDate
	,PayToDate=NEW.PayToDate
	,TotalGrossSalary=actualgross
	,TotalNetSalary=(actualgross - (NEW.TotalEmpSSS + NEW.TotalEmpPhilhealth + NEW.TotalEmpHDMF + NEW.TotalEmpWithholdingTax)) - NEW.TotalLoans + (NEW.TotalAdjustments * actualrate)
	,TotalTaxableSalary=(((NEW.TotalTaxableSalary + @total_govt_contrib) * actualrate) - @total_govt_contrib)
	,TotalEmpSSS=NEW.TotalEmpSSS
	,TotalEmpWithholdingTax=NEW.TotalEmpWithholdingTax
	,TotalCompSSS=NEW.TotalCompSSS
	,TotalEmpPhilhealth=NEW.TotalEmpPhilhealth
	,TotalCompPhilhealth=NEW.TotalCompPhilhealth
	,TotalEmpHDMF=NEW.TotalEmpHDMF
	,TotalCompHDMF=NEW.TotalCompHDMF
	,TotalVacationDaysLeft=NEW.TotalVacationDaysLeft
	,TotalLoans=NEW.TotalLoans
	,TotalBonus=NEW.TotalBonus
	,TotalAllowance=NEW.TotalAllowance
	,TotalAdjustments=NEW.TotalAdjustments * actualrate
	,ThirteenthMonthInclusion=NEW.ThirteenthMonthInclusion
	,NondeductibleTotalLoans=NEW.NondeductibleTotalLoans;
	
	




SELECT EXISTS(SELECT RowID FROM employee WHERE RowID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND (DateRegularized <= NEW.PayFromDate OR DateRegularized <= NEW.PayToDate)) INTO isOneYearService;
IF isOneYearService = '1' THEN
	SELECT RowID FROM product WHERE PartNo='Vacation leave' AND `Category`='Leave Type' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
	SELECT e.LeaveBalance
	
	,e.SickLeaveBalance
	,e.MaternityLeaveBalance
	,e.OtherLeaveBalance
	,e.AdditionalVLBalance
	FROM employee e
	LEFT JOIN payperiod pp ON pp.RowID=NEW.PayPeriodID
	WHERE e.RowID=NEW.EmployeeID
	AND e.OrganizationID=NEW.OrganizationID
	INTO vl_per_payp
			,sl_per_payp
			,ml_per_payp
			,othr_per_payp
			,addvl_per_payp;
	
	IF vl_per_payp IS NULL THEN
		SET vl_per_payp = 0.0;
	END IF;
	
	IF sl_per_payp IS NULL THEN
		SET sl_per_payp = 0.0;
	END IF;
	
	IF ml_per_payp IS NULL THEN
		SET ml_per_payp = 0.0;
	END IF;
	
	IF othr_per_payp IS NULL THEN
		SET othr_per_payp = 0.0;
	END IF;
	
	
	
	SELECT RowID FROM product WHERE PartNo='Maternity/paternity leave' AND `Category`='Leave Type' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
	
	
	
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, ml_per_payp) INTO anyint;
	
	SELECT RowID FROM product WHERE PartNo='Others' AND OrganizationID=NEW.OrganizationID AND `Category`='Leave Type' INTO product_rowid;
	
	
	
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, othr_per_payp) INTO anyint;
	
	SELECT RowID FROM product WHERE PartNo='Sick leave' AND `Category`='Leave Type' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
	
	
	
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, sl_per_payp) INTO anyint;
	
	SELECT RowID FROM product WHERE PartNo='Vacation leave' AND `Category`='Leave Type' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
	
	
	
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, vl_per_payp) INTO anyint;

	SELECT RowID FROM product WHERE PartNo='Additional VL' AND `Category`='Leave Type' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
	
	
	
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, addvl_per_payp) INTO anyint;
	
ELSE

	SET anyamount = 0;
	
	SELECT RowID FROM product WHERE PartNo='Maternity/paternity leave' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;
	
	SELECT RowID FROM product WHERE PartNo='Others' AND OrganizationID=NEW.OrganizationID AND `Category`='Leave Type' INTO product_rowid;
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;
	
	SELECT RowID FROM product WHERE PartNo='Sick leave' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;
	
	SELECT RowID FROM product WHERE PartNo='Vacation leave' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;

	SELECT RowID FROM product WHERE PartNo='Additional VL' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;
	
END IF;


	


END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
