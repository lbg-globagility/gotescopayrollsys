/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP TRIGGER IF EXISTS `AFTINS_paystub_then_paystubitem`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
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

DECLARE isOneYearService BOOL DEFAULT FALSE;

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

DECLARE firstPayDateFrom, firstPayDateTo DATE;

SELECT RowID FROM product WHERE OrganizationID=NEW.OrganizationID AND LCASE(PartNo)='ecola' AND `Category`='Allowance type' LIMIT 1 INTO ecola_rowid;

SELECT TRIM(SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(ii.COLUMN_COMMENT,',',2)),',',-1)) FROM information_schema.`COLUMNS` ii WHERE ii.TABLE_SCHEMA='gotescopayrolldatabaseoct3' AND ii.COLUMN_NAME='Status' AND ii.TABLE_NAME='employeeloanschedule' INTO loan_inprogress_status;

SELECT pr.`Half`, pp.PayFromDate, pp.PayToDate
FROM payperiod pr
INNER JOIN payperiod pp ON pp.OrganizationID=pr.OrganizationID AND pp.TotalGrossSalary=pr.TotalGrossSalary AND pp.`Year`=pr.`Year` AND pp.OrdinalValue=1
WHERE pr.RowID=NEW.PayPeriodID
INTO IsrbxpayrollFirstHalfOfMonth, firstPayDateFrom, firstPayDateTo;

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
	

SELECT RowID FROM product WHERE PartNo='.PAGIBIG' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, NEW.TotalEmpHDMF) INTO anyint;

SELECT RowID FROM product WHERE PartNo='.PhilHealth' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, NEW.TotalEmpPhilhealth) INTO anyint;

SELECT RowID FROM product WHERE PartNo='.SSS' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, NEW.TotalEmpSSS) INTO anyint;

SELECT RowID FROM product WHERE PartNo='Absent' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
SELECT SUM(Absent) FROM employeetimeentry WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO anyamount;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;

SELECT RowID FROM product WHERE PartNo='Tardiness' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
SELECT SUM(HoursLateAmount) FROM employeetimeentry WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO anyamount;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;

SELECT RowID FROM product WHERE PartNo='Undertime' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
SELECT SUM(UndertimeHoursAmount) FROM employeetimeentry WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO anyamount;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;





SELECT RowID FROM product WHERE PartNo='Holiday pay' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;


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

SELECT RowID FROM product WHERE PartNo='Night differential' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
SELECT SUM(NightDiffHoursAmount) FROM employeetimeentry WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO anyamount;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;

SELECT RowID FROM product WHERE PartNo='Night differential OT' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
SELECT SUM(NightDiffOTHoursAmount) FROM employeetimeentry WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO anyamount;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;

SELECT RowID FROM product WHERE PartNo='Overtime' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
SELECT SUM(OvertimeHoursAmount) FROM employeetimeentry WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO anyamount;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;










SELECT RowID FROM product WHERE PartNo='Gross Income' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, NEW.TotalGrossSalary) INTO anyint;

SELECT RowID FROM product WHERE PartNo='Net Income' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, NEW.TotalNetSalary) INTO anyint;

SELECT RowID FROM product WHERE PartNo='Taxable Income' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, NEW.TotalTaxableSalary) INTO anyint;

SELECT RowID FROM product WHERE PartNo='Withholding Tax' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
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

/*INSERT INTO paystubitem(ProductID,OrganizationID,Created,CreatedBy,PayStubID,PayAmount,Undeclared)
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
		SELECT ii.AllowanceAmount - (SUM(i.HoursToLess) * ((ii.AllowanceAmount / (i.WorkDaysPerYear / (i.PAYFREQDIV * 12))) / 8)) AS TotalAllowanceAmount,ii.ProductID
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
	,PayAmount=ii.TotalAllowanceAmount;*/
		

SET @timediffcount = 0.00;

SELECT RowID FROM product WHERE OrganizationID=NEW.OrganizationID AND LCASE(PartNo)='ecola' AND `Category`='Allowance type' LIMIT 1 INTO @ecola_rowid;

SET @day_pay = 0.0;SET @day_pay1 = 0.0;SET @day_pay2 = 0.0;

#######################################################################OVER HERE
/*INSERT INTO paystubitem(ProductID,OrganizationID,Created,CreatedBy,PayStubID,PayAmount,Undeclared)
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
	,PayAmount=ii.TotalAllowanceAmount;*/
#######################################################################OVER HERE
	
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

################################################################################
/*INSERT INTO paystubitem(ProductID,OrganizationID,Created,CreatedBy,PayStubID,PayAmount,Undeclared)
	SELECT i.ProductID
	,NEW.OrganizationID
	,CURRENT_TIMESTAMP()
	,NEW.LastUpdBy
	,NEW.RowID
	,i.AllowanceAmount
	,0
	FROM (SELECT i.ProductID
	      ,i.EmployeeID
	      ,( i.AllowanceAmount - (SUM(i.HoursToLess) * ((i.AllowanceAmount / (i.WorkDaysPerYear / (i.PAYFREQDIV * 12))) / 8)) ) `AllowanceAmount`
	      FROM paystubitem_sum_semimon_allowance_group_prodid i
			WHERE i.OrganizationID=NEW.OrganizationID
			AND i.EmployeeID=NEW.EmployeeID
			# AND i.TaxableFlag = FALSE
			AND i.`Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate
			# GROUP BY i.EmployeeID,ii.RowID,ii.ProductID
			GROUP BY i.ProductID, i.TaxableFlag) i
ON
DUPLICATE
KEY
UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=NEW.LastUpdBy
	,PayAmount=i.AllowanceAmount;*/
################################################################################

IF FALSE THEN # IF IsrbxpayrollFirstHalfOfMonth = '0' THEN

	SET @dailyallowanceamount = 0.00;

	SET @timediffcount = 0.00;
	
	INSERT INTO paystubitem(ProductID,OrganizationID,Created,CreatedBy,PayStubID,PayAmount,Undeclared)
		SELECT
		ii.ProductID
		,NEW.OrganizationID
		,CURRENT_TIMESTAMP()
		,NEW.CreatedBy
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
	,els.LoanTypeID
	,IFNULL(els.DeductionAmount,0)
	,FALSE
	FROM (SELECT els.*
			FROM employeeloanschedule els
			WHERE els.EmployeeID=NEW.EmployeeID
			AND els.OrganizationID=NEW.OrganizationID
			AND LCASE(els.`Status`) IN ('in progress', 'complete')
			AND els.DiscontinuedDate IS NULL
			AND els.DeductionSchedule IN ('Per pay period',payperiod_type)
			AND (els.DedEffectiveDateFrom >= NEW.PayFromDate OR els.DedEffectiveDateTo >= NEW.PayFromDate)
			AND (els.DedEffectiveDateFrom <= NEW.PayToDate OR els.DedEffectiveDateTo <= NEW.PayToDate)
		UNION
			SELECT els.*
			FROM employeeloanschedule els
			WHERE els.EmployeeID=NEW.EmployeeID
			AND els.OrganizationID=NEW.OrganizationID
			AND LCASE(els.`Status`) = 'cancelled'
			AND els.DiscontinuedDate IS NOT NULL
			AND els.DeductionSchedule IN ('Per pay period',payperiod_type)
			AND (els.DedEffectiveDateFrom >= NEW.PayFromDate OR els.DiscontinuedDate >= NEW.PayFromDate)
			AND (els.DedEffectiveDateFrom <= NEW.PayToDate OR els.DiscontinuedDate <= NEW.PayToDate)
			) els
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
	, NEW.CreatedBy
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
				AND (eb.EffectiveStartDate IS NOT NULL AND eb.EffectiveEndDate IS NOT NULL)
				AND (eb.EffectiveStartDate >= pp.PayFromDate OR eb.EffectiveEndDate >= pp.PayFromDate)
				AND (eb.EffectiveStartDate <= pp.PayToDate OR eb.EffectiveEndDate <= pp.PayToDate)
				
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

SELECT e.StartDate,e.EmployeeType,pf.PayFrequencyType FROM employee e INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID WHERE e.RowID=NEW.EmployeeID AND e.OrganizationID=NEW.OrganizationID LIMIT 1 INTO e_startdate,e_type,pftype;

SELECT (e_startdate BETWEEN NEW.PayFromDate AND NEW.PayToDate) INTO IsFirstTimeSalary;

SET @monthlyType='monthly';

SET @monthCount=12;
SET @defaultWorkHours=8;
SET @isRestDay=FALSE;

	DROP TEMPORARY TABLE IF EXISTS attendanceperiodofemployee;
	CREATE TEMPORARY TABLE attendanceperiodofemployee
	SELECT
	et.`RowID`
	, et.`OrganizationID`
	, et.`Date`
	, @dailyRate := TRIM(es.DailyRate * es.Percentage)+0 `DailyRate`
	, @hourlyRate := TRIM(@dailyRate / @defaultWorkHours)+0 `HourlyRate`
	, esh.RowID `EmployeeShiftID`
	, et.`EmployeeID`
	, et.`EmployeeSalaryID`
	, et.`EmployeeFixedSalaryFlag`
	
	, (@isRestDay := IFNULL(esh.RestDay, FALSE)) `IsRestDay`
	, IF(@isRestDay, et.RegularHoursWorked, 0) `RestDayHours`
	, IF(@isRestDay
			, IF(LCASE(e.EmployeeType)=@monthlyType AND e.CalcRestDay=TRUE, ROUND(et.RegularHoursAmount * ((pr.RestDayRate-pr.`PayRate`) / pr.RestDayRate), 2), et.RegularHoursAmount)
			, 0) `RestDayPay`

	, IF(@isRestDay, 0, et.`RegularHoursWorked`) `RegularHoursWorked`
	, IF(@isRestDay, 0, et.`RegularHoursAmount`) `RegularHoursAmount`
	, et.`TotalHoursWorked`
	, et.`OvertimeHoursWorked`
	, et.`OvertimeHoursAmount`
	, ett.HoursUndertime `UndertimeHours`
#	, TRIM(ett.HoursUndertime * @hourlyRate)+0 `UndertimeHoursAmount`
	, et.UndertimeHoursAmount
	, et.`NightDifferentialHours`
	, et.`NightDiffHoursAmount`
	, et.`NightDifferentialOTHours`
	, et.`NightDiffOTHoursAmount`
	, ett.HoursTardy `HoursLate`
#	, TRIM(ett.HoursTardy * @hourlyRate)+0 `HoursLateAmount`
	, et.HoursLateAmount
	, et.`LateFlag`
	, et.`PayRateID`
	, et.`VacationLeaveHours`
	, et.`SickLeaveHours`
	, et.`MaternityLeaveHours`
	, et.`OtherLeaveHours`
	, et.`AdditionalVLHours`
	, et.`TotalDayPay`
	, et.`Absent`
	, IF(et.Absent > 0, sh.WorkHours, 0) `AbsentHours`
	, et.`TaxableDailyAllowance`
	, et.`HolidayPayAmount`
	, et.`TaxableDailyBonus`
	, et.`NonTaxableDailyBonus`
	, ett.`IsValidForHolidayPayment`
#	, @trueSalary := TRIM(es.Percentage * es.Salary)+0 `ActualSalary`
	, ROUND(( (`et`.`VacationLeaveHours` + `et`.`SickLeaveHours` + `et`.`OtherLeaveHours` + `et`.`AdditionalVLHours`) * if(`e`.`EmployeeType` = 'Daily', (`es`.`TrueSalary` / @defaultWorkHours), ((`es`.`TrueSalary` / (`e`.`WorkDaysPerYear` / @monthCount)) / @defaultWorkHours)) ), 2) `Leavepayment`
	, IFNULL(sh.WorkHours, 0) `WorkHours`
	, et.`AddedHolidayPayAmount`
	, es.Percentage `ActualSalaryRate`
	
	FROM employeetimeentryactual et
	INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.RowID=NEW.EmployeeID
	INNER JOIN employeetimeentry ett ON ett.EmployeeID=e.RowID AND ett.`Date`=et.`Date` AND ett.OrganizationID=et.OrganizationID
	INNER JOIN payrate pr ON pr.RowID=ett.PayRateID
	LEFT JOIN employeesalary_withdailyrate es ON es.RowID=et.EmployeeSalaryID
	LEFT JOIN employeeshift esh ON esh.EmployeeID=e.RowID AND esh.OrganizationID=et.OrganizationID AND et.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo
	LEFT JOIN shift sh ON sh.RowID=esh.ShiftID
	WHERE et.OrganizationID=NEW.OrganizationID
	AND et.`Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate
	;


















IF e_type IN ('Fixed','Monthly') AND IsFirstTimeSalary = '1' THEN
	
	IF e_type = 'Monthly' THEN
	
		SELECT SUM(TotalDayPay),EmployeeSalaryID FROM attendanceperiodofemployee INTO totalworkamount,empsalRowID;
		
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
	
	IF e_type IN ('Fixed','Monthly') THEN
	
		SELECT (TrueSalary / PAYFREQUENCY_DIVISOR(pftype)) FROM employeesalary es WHERE es.EmployeeID=NEW.EmployeeID AND es.OrganizationID=NEW.OrganizationID AND (es.EffectiveDateFrom >= NEW.PayFromDate OR IFNULL(es.EffectiveDateTo,NEW.PayToDate) >= NEW.PayFromDate) AND (es.EffectiveDateFrom <= NEW.PayToDate OR IFNULL(es.EffectiveDateTo,NEW.PayToDate) <= NEW.PayToDate) ORDER BY es.EffectiveDateFrom DESC LIMIT 1 INTO totalworkamount;

		SELECT ( (totalworkamount - (SUM(et.HoursLateAmount) + SUM(et.UndertimeHoursAmount) + SUM(et.Absent))) + SUM(et.OvertimeHoursAmount) + SUM(IFNULL(et.RestDayPay, 0)) + SUM(IFNULL(et.NightDiffHoursAmount, 0)) + SUM(IFNULL(et.NightDiffOTHoursAmount, 0)) + SUM(IFNULL(et.AddedHolidayPayAmount,0)) ) FROM attendanceperiodofemployee et INTO totalworkamount;

		IF totalworkamount IS NULL THEN
			
			SELECT SUM(HoursLateAmount + UndertimeHoursAmount + Absent) FROM employeetimeentry WHERE OrganizationID=NEW.OrganizationID AND EmployeeID=NEW.EmployeeID AND `Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate INTO totalworkamount;
				
			SET totalworkamount = IFNULL(totalworkamount,0);
			
			SELECT totalworkamount + (totalworkamount * actualrate) INTO totalworkamount;
			
		END IF;
		
		SET totalworkamount = IFNULL(totalworkamount,0);
		
	ELSEIF e_type = 'Fixed employee' THEN
	
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

SELECT SUM(pa.PayAmount)
FROM paystubadjustmentactual pa
WHERE pa.PayStubID = NEW.RowID
INTO @tot_actual_adj; SET @tot_actual_adj = IFNULL(@tot_actual_adj, 0);

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
	,(actualgross - (NEW.TotalEmpSSS + NEW.TotalEmpPhilhealth + NEW.TotalEmpHDMF + NEW.TotalEmpWithholdingTax)) - NEW.TotalLoans + (@tot_actual_adj)
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
	,TotalNetSalary=(((actualgross - (NEW.TotalEmpSSS + NEW.TotalEmpPhilhealth + NEW.TotalEmpHDMF + NEW.TotalEmpWithholdingTax)) - NEW.TotalLoans) + (@tot_actual_adj))
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
	,TotalAdjustments=@tot_actual_adj
	,ThirteenthMonthInclusion=NEW.ThirteenthMonthInclusion
	,NondeductibleTotalLoans=NEW.NondeductibleTotalLoans;
	
	




#SELECT EXISTS(SELECT RowID FROM employee WHERE RowID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND (DateRegularized <= NEW.PayFromDate OR DateRegularized <= NEW.PayToDate)) INTO isOneYearService;
SET isOneYearService = TRUE;
IF isOneYearService = TRUE THEN
	SELECT RowID FROM product WHERE PartNo='Vacation leave' AND `Category`='Leave Type' AND OrganizationID=NEW.OrganizationID INTO product_rowid;
	SELECT
	e.LeaveAllowance, e.SickLeaveAllowance, e.MaternityLeaveAllowance, e.OtherLeaveAllowance, e.AdditionalVLAllowance
	FROM employee e
#	LEFT JOIN payperiod pp ON pp.RowID=NEW.PayPeriodID
	WHERE e.RowID=NEW.EmployeeID
#	AND e.OrganizationID=NEW.OrganizationID
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
	
	
	
	SELECT RowID FROM product WHERE PartNo='Maternity/paternity leave' AND `Category`='Leave Type' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
	
	
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, (ml_per_payp - MAX(i.`MaternityLeaveHours`)))
	FROM (SELECT SUM(et.MaternityLeaveHours) `MaternityLeaveHours`
			FROM employeetimeentry et
			WHERE et.EmployeeID=NEW.EmployeeID
			AND et.OrganizationID=NEW.OrganizationID
			AND et.`Date` BETWEEN firstPayDateFrom AND NEW.PayToDate
		UNION
			SELECT 0 `MaternityLeaveHours`) i
	INTO anyint;
	
	SELECT RowID FROM product WHERE PartNo='Others' AND OrganizationID=NEW.OrganizationID AND `Category`='Leave Type' LIMIT 1 INTO product_rowid;
	
	
	
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, (othr_per_payp - MAX(i.`OtherLeaveHours`)))
	FROM (SELECT SUM(et.OtherLeaveHours) `OtherLeaveHours`
			FROM employeetimeentry et
			WHERE et.EmployeeID=NEW.EmployeeID
			AND et.OrganizationID=NEW.OrganizationID
			AND et.`Date` BETWEEN firstPayDateFrom AND NEW.PayToDate
		UNION
			SELECT 0 `OtherLeaveHours`) i
	INTO anyint;
	
	SELECT RowID FROM product WHERE PartNo='Sick leave' AND `Category`='Leave Type' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
	
	
	
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, (sl_per_payp - MAX(i.`SickLeaveHours`)))
	FROM (SELECT SUM(et.SickLeaveHours) `SickLeaveHours`
			FROM employeetimeentry et
			WHERE et.EmployeeID=NEW.EmployeeID
			AND et.OrganizationID=NEW.OrganizationID
			AND et.`Date` BETWEEN firstPayDateFrom AND NEW.PayToDate
		UNION
			SELECT 0 `SickLeaveHours`) i
	INTO anyint;
	
	SELECT RowID FROM product WHERE PartNo='Vacation leave' AND `Category`='Leave Type' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
	
	
	
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, (vl_per_payp - MAX(i.`VacationLeaveHours`)))
	FROM (SELECT SUM(et.VacationLeaveHours) `VacationLeaveHours`
			FROM employeetimeentry et
			WHERE et.EmployeeID=NEW.EmployeeID
			AND et.OrganizationID=NEW.OrganizationID
			AND et.`Date` BETWEEN firstPayDateFrom AND NEW.PayToDate
		UNION
			SELECT 0 `VacationLeaveHours`) i
	INTO anyint;

	SELECT RowID FROM product WHERE PartNo='Additional VL' AND `Category`='Leave Type' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
	
	
	
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, (addvl_per_payp - MAX(i.`AdditionalVLHours`)))
	FROM (SELECT SUM(et.AdditionalVLHours) `AdditionalVLHours`
			FROM employeetimeentry et
			WHERE et.EmployeeID=NEW.EmployeeID
			AND et.OrganizationID=NEW.OrganizationID
			AND et.`Date` BETWEEN firstPayDateFrom AND NEW.PayToDate
		UNION
			SELECT 0 `AdditionalVLHours`) i
	INTO anyint;
	
ELSE

	SET anyamount = 0;
	
	SELECT RowID FROM product WHERE PartNo='Maternity/paternity leave' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;
	
	SELECT RowID FROM product WHERE PartNo='Others' AND OrganizationID=NEW.OrganizationID AND `Category`='Leave Type' LIMIT 1 INTO product_rowid;
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;
	
	SELECT RowID FROM product WHERE PartNo='Sick leave' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;
	
	SELECT RowID FROM product WHERE PartNo='Vacation leave' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;

	SELECT RowID FROM product WHERE PartNo='Additional VL' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO product_rowid;
	
	SELECT INSUPD_paystubitem(NULL, NEW.OrganizationID, NEW.CreatedBy, NEW.CreatedBy, NEW.RowID, product_rowid, anyamount) INTO anyint;
	
END IF;

/*INSERT INTO `paystubitem` (`OrganizationID`, `Created`, `CreatedBy`, `LastUpd`, `LastUpdBy`, `PayStubID`, `ProductID`, `PayAmount`, `Undeclared`)
SELECT p.OrganizationID
,CURRENT_TIMESTAMP()
,NEW.LastUpdBy
,CURRENT_TIMESTAMP()
,NEW.LastUpdBy
,NEW.RowID
,p.RowID
,IFNULL(i.`AddtlRestDayPayment`, 0)
,FALSE
FROM product p
LEFT JOIN (SELECT
           SUM(i.AddtlRestDayPayment) `AddtlRestDayPayment`
			  FROM monthlyemployee_restday_payment i
			  INNER JOIN employee e ON e.RowID=i.EmployeeID AND e.OrganizationID=i.OrganizationID AND e.RowID=NEW.EmployeeID
			  WHERE i.`Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate
			  AND i.OrganizationID=NEW.OrganizationID) i ON i.`AddtlRestDayPayment` IS NOT NULL
WHERE p.PartNo='Restday pay'
AND p.OrganizationID=NEW.OrganizationID
ON 
DUPLICATE 
KEY 
UPDATE 
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=NEW.LastUpdBy
	,ProductID=p.RowID
	,PayAmount=IFNULL(i.`AddtlRestDayPayment`, 0)
	,Undeclared=FALSE
;

INSERT INTO `paystubitem` (`OrganizationID`, `Created`, `CreatedBy`, `LastUpd`, `LastUpdBy`, `PayStubID`, `ProductID`, `PayAmount`, `Undeclared`)
SELECT p.OrganizationID
,CURRENT_TIMESTAMP()
,NEW.LastUpdBy
,CURRENT_TIMESTAMP()
,NEW.LastUpdBy
,NEW.RowID
,p.RowID
,IFNULL(i.`AddtlRestDayPayment`, 0)
,TRUE
FROM product p
LEFT JOIN (SELECT
           (i.ActualPercentage * SUM(i.AddtlRestDayPayment)) `AddtlRestDayPayment`
			  FROM monthlyemployee_restday_payment i
			  INNER JOIN employee e ON e.RowID=i.EmployeeID AND e.OrganizationID=i.OrganizationID AND e.RowID=NEW.EmployeeID
			  WHERE i.`Date` BETWEEN NEW.PayFromDate AND NEW.PayToDate
			  AND i.OrganizationID=NEW.OrganizationID) i ON i.`AddtlRestDayPayment` IS NOT NULL
WHERE p.PartNo='Restday pay'
AND p.OrganizationID=NEW.OrganizationID
ON 
DUPLICATE 
KEY 
UPDATE 
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=NEW.LastUpdBy
	,ProductID=p.RowID
	,PayAmount=IFNULL(i.`AddtlRestDayPayment`, 0)
	,Undeclared=TRUE
;*/

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
