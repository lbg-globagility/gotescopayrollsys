/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP TRIGGER IF EXISTS `BEFINS_employeetimeentry`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `BEFINS_employeetimeentry` BEFORE INSERT ON `employeetimeentry` FOR EACH ROW BEGIN

DECLARE isRest_day CHAR(1);

DECLARE has_shift CHAR(1);

DECLARE perfect_hrs DECIMAL(11,6) DEFAULT 0;

DECLARE absent_amount DECIMAL(11,6);

DECLARE isDateNotHoliday CHAR(1);

DECLARE TaxableDailyAllowanceAmount DECIMAL(11,6);

DECLARE rate_this_date DECIMAL(11,6);
DECLARE hourly_rate DECIMAL(11,6);
DECLARE isSpecialHoliday, isLegalHoliday, itsHoliday BOOL DEFAULT FALSE;
DECLARE isPresentInWorkingDaysPriorToThisDate CHAR(1) DEFAULT '0';
DECLARE payrate_this_date DECIMAL(11,2);

DECLARE e_rateperday DECIMAL(12,6) DEFAULT 0;
DECLARE emp_type VARCHAR(50);

DECLARE default_working_hrs DECIMAL(11,2) DEFAULT 8;

SET @const_monthcount = MONTH(SUBDATE(MAKEDATE(YEAR(CURDATE()), 1), INTERVAL 1 DAY));

SET @e_rateperday = 0.0;

SELECT IF(e.EmployeeType = 'Daily', es.BasicPay, (es.Salary / (e.WorkDaysPerYear / @const_monthcount))) FROM employeesalary es INNER JOIN employee e ON e.RowID=es.EmployeeID AND e.OrganizationID=es.OrganizationID WHERE es.RowID=NEW.EmployeeSalaryID INTO @e_rateperday;

SET e_rateperday = IFNULL(@e_rateperday,0);
# AND pr.PayType='Regular Day' 

SELECT EXISTS(SELECT et.RowID FROM employeetimeentry et INNER JOIN payrate pr ON pr.RowID=et.PayRateID WHERE et.EmployeeID=NEW.EmployeeID AND et.OrganizationID=NEW.OrganizationID AND et.`Date` BETWEEN SUBDATE(NEW.`Date`, INTERVAL 3 DAY) AND SUBDATE(NEW.`Date`, INTERVAL 1 DAY) AND et.EmployeeShiftID IS NOT NULL AND et.TotalDayPay > 0 ORDER BY et.`Date` DESC LIMIT 1) INTO isPresentInWorkingDaysPriorToThisDate;

SELECT (PayType = 'Regular Day'),(LOCATE('Special',PayType) > 0), (PayType='Regular Holiday') FROM payrate WHERE RowID=NEW.PayRateID INTO isDateNotHoliday,isSpecialHoliday,isLegalHoliday;
SET itsHoliday = (isSpecialHoliday OR isLegalHoliday);
SET @myperfectshifthrs = 0.0;

SELECT `PayRate`,e_rateperday, RestDayRate FROM payrate pr WHERE pr.RowID=NEW.PayRateID INTO payrate_this_date,rate_this_date, @restDayRate;SET perfect_hrs = 1;SET @myperfectshifthrs = 1;

SET NEW.VacationLeaveHours = IFNULL(NEW.VacationLeaveHours,0);
SET NEW.SickLeaveHours = IFNULL(NEW.SickLeaveHours,0);
SET NEW.MaternityLeaveHours = IFNULL(NEW.MaternityLeaveHours,0);
SET NEW.OtherLeaveHours = IFNULL(NEW.OtherLeaveHours,0);

/*IF (NEW.VacationLeaveHours + NEW.SickLeaveHours + NEW.MaternityLeaveHours + NEW.OtherLeaveHours) = 0 AND isDateNotHoliday = '0' THEN
	SET NEW.TotalDayPay = IFNULL((SELECT IF(NEW.TotalDayPay > 0 AND NEW.RegularHoursAmount = 0 AND e.CalcHoliday='0', 0, IF(LOCATE('Regular Holi',pr.PayType) > 0 AND isPresentInWorkingDaysPriorToThisDate='1', rate_this_date, IF(e.CalcSpecialHoliday = '1' AND LOCATE('Special',pr.PayType) > 0 AND e.EmployeeType = 'Monthly' AND isSpecialHoliday = '1' AND isPresentInWorkingDaysPriorToThisDate = '1' AND NEW.TotalDayPay = 0 AND NEW.RegularHoursAmount = 0, ((rate_this_date / perfect_hrs) * @myperfectshifthrs), 0))) FROM employee e INNER JOIN payrate pr ON pr.RowID=NEW.PayRateID WHERE e.RowID=NEW.EmployeeID AND e.OrganizationID=NEW.OrganizationID),NEW.TotalDayPay);
	
END IF;*/

SET @myperfectshifthrs = 0;

SELECT (NEW.EmployeeShiftID IS NULL) INTO isRest_day; # EXISTS(SELECT RowID FROM employeeshift WHERE RowID=NEW.EmployeeShiftID AND RestDay='1')

SET @employee_type = '';

SELECT e.EmployeeType, e.CalcRestDay, e.CalcHoliday, e.CalcSpecialHoliday,
IFNULL(esh.RestDay=TRUE, IFNULL(e.DayOfRest=(DAYOFWEEK(NEW.`Date`)-1), FALSE)) `IsRestDay`
FROM employee e
LEFT JOIN employeeshift esh ON esh.RowID=NEW.EmployeeShiftID
WHERE e.RowID=NEW.EmployeeID
INTO @employee_type, @calcRestDay, @calcLegalHoliday, @calcSpecialHoliday, @isRestDay;

SET NEW.RegularHoursWorked = IFNULL(NEW.RegularHoursWorked,0);
SET NEW.RegularHoursAmount = IFNULL(NEW.RegularHoursAmount,0);
SET NEW.TotalHoursWorked = IFNULL(NEW.TotalHoursWorked,0);
SET NEW.OvertimeHoursWorked = IFNULL(NEW.OvertimeHoursWorked,0);
SET NEW.OvertimeHoursAmount = IFNULL(NEW.OvertimeHoursAmount,0);
SET NEW.NightDifferentialHours = IFNULL(NEW.NightDifferentialHours,0);
SET NEW.NightDiffHoursAmount = IFNULL(NEW.NightDiffHoursAmount,0);
SET NEW.NightDifferentialOTHours = IFNULL(NEW.NightDifferentialOTHours,0);
SET NEW.NightDiffOTHoursAmount = IFNULL(NEW.NightDiffOTHoursAmount,0);
SET NEW.TotalDayPay = IFNULL(NEW.TotalDayPay,0);

SET @is_fix_employee_having_no_leavebalance = FALSE;

IF @employee_type = 'Fixed' THEN

	SELECT
	EXISTS(SELECT e.RowID
	       FROM employee e
			 WHERE e.RowID=NEW.EmployeeID
			 AND e.EmployeeType='Fixed'
			 AND (e.LeaveBalance + e.SickLeaveBalance + e.MaternityLeaveBalance + e.OtherLeaveBalance + e.AdditionalVLBalance) <= 0)
	INTO @is_fix_employee_having_no_leavebalance;
	
	IF @is_fix_employee_having_no_leavebalance = TRUE
	   AND NEW.HoursLate > 0 THEN
		
		SET NEW.HoursLate = IFNULL(NEW.HoursLate,0);
		SET NEW.HoursLateAmount = IFNULL(NEW.HoursLateAmount,0);
	ELSE	
		SET NEW.HoursLate = 0;
		SET NEW.HoursLateAmount = 0;
	
	END IF;
	
	IF @is_fix_employee_having_no_leavebalance = TRUE
	   AND NEW.UndertimeHours > 0 THEN
		
		SET NEW.UndertimeHours = IFNULL(NEW.UndertimeHours,0);
		SET NEW.UndertimeHoursAmount = IFNULL(NEW.UndertimeHoursAmount,0);
	ELSE
		SET NEW.UndertimeHours = 0;
		SET NEW.UndertimeHoursAmount = 0;
	
	END IF;

ELSE
	
	SET NEW.HoursLate = IFNULL(NEW.HoursLate,0);
	SET NEW.HoursLateAmount = IFNULL(NEW.HoursLateAmount,0);
	SET NEW.UndertimeHours = IFNULL(NEW.UndertimeHours,0);
	SET NEW.UndertimeHoursAmount = IFNULL(NEW.UndertimeHoursAmount,0);
END IF;

IF isRest_day = '0' THEN

	SELECT EXISTS(SELECT RowID FROM employeeshift esh WHERE esh.EmployeeID=NEW.EmployeeID AND esh.OrganizationID=NEW.OrganizationID AND esh.RestDay='0' AND NEW.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo LIMIT 1) INTO has_shift;
	SET @fullshifthrs = 0.00; SET @breakhrs = 0.00;
		
	IF has_shift = '1' AND isDateNotHoliday = '1' THEN
		
		SELECT IFNULL(sh.DivisorToDailyRate, default_working_hrs),COMPUTE_TimeDifference(sh.TimeFrom,sh.TimeTo),COMPUTE_TimeDifference(sh.BreakTimeFrom,sh.BreakTimeTo)
		FROM employeeshift esh
		INNER JOIN shift sh ON sh.RowID=esh.ShiftID
		WHERE esh.EmployeeID=NEW.EmployeeID AND esh.OrganizationID=NEW.OrganizationID AND esh.RestDay='0' AND NEW.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo
		LIMIT 1
		INTO perfect_hrs,@fullshifthrs,@breakhrs;
		
		SET perfect_hrs = IFNULL(perfect_hrs,0);
		
		IF perfect_hrs > 0 AND perfect_hrs NOT IN (3,4,5) THEN
			
			SET perfect_hrs = perfect_hrs;
			
		END IF;
		
		SET absent_amount = (@fullshifthrs - IFNULL(@breakhrs,0)) * (e_rateperday / perfect_hrs);
		
		IF absent_amount < NEW.Absent AND EXISTS(SELECT RowID FROM employeetimeentrydetails WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND `Date`=NEW.`Date` AND TimeStampIn IS NOT NULL AND TimeStampOut IS NOT NULL LIMIT 1) = TRUE THEN
			SET NEW.Absent = 0.0;# over here
		
			
		ELSEIF (SUBSTRING_INDEX(absent_amount,'.',1) * 1) = (SUBSTRING_INDEX(NEW.HoursLateAmount,'.',1) * 1) THEN
			SET NEW.Absent = 0.0;
		ELSEIF (SUBSTRING_INDEX(absent_amount,'.',1) * 1) = (SUBSTRING_INDEX(NEW.UndertimeHoursAmount,'.',1) * 1) THEN
			SET NEW.Absent = 0.0;
		ELSE
			
			IF NEW.TotalDayPay = 0 THEN
			
				SET NEW.Absent = absent_amount;
				
			ELSE
			
				SET NEW.Absent = 0.0;
				
			END IF;
			
		END IF;
		
	ELSE
	
		IF isDateNotHoliday = '0' THEN
		
			SET @calclegalholi = '0';
			SET @calcspecholi = '0';
			
			SET @daily_pay = 0.00;
			
			SELECT (pr.PayType = 'Regular Holiday' AND e.CalcHoliday = '1' AND e.StartDate <= NEW.`Date`)
			,(pr.PayType = 'Special Non-Working Holiday' AND e.CalcSpecialHoliday = '1' AND e.StartDate <= NEW.`Date`)
			,e.EmployeeType
			#,IF(e.EmployeeType = 'Daily', es.BasicPay, (es.BasicPay (e.WorkDaysPerYear / 24))) `Result`
			#,GET_employeerateperday(NEW.EmployeeID, NEW.OrganizationID, NEW.`Date`) `Result`
			,IF(e.EmployeeType = 'Daily', IFNULL(esa.BasicPay, es.BasicPay), (IFNULL(esa.Salary, es.Salary) / ( e.WorkDaysPerYear / @const_monthcount ))) `Result`
			FROM payrate pr
			INNER JOIN employee e ON e.RowID=NEW.EmployeeID
			INNER JOIN (SELECT * FROM employeesalary WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND NEW.`Date` BETWEEN EffectiveDateFrom AND IFNULL(EffectiveDateTo,NEW.`Date`) LIMIT 1) es ON es.RowID > 0
			LEFT JOIN employeesalary esa ON esa.RowID=NEW.EmployeeSalaryID
			WHERE pr.RowID=NEW.PayRateID
			INTO @calclegalholi
					,@calcspecholi,emp_type
					,@daily_pay;
			
			IF (NEW.VacationLeaveHours + NEW.SickLeaveHours + NEW.MaternityLeaveHours + NEW.OtherLeaveHours) > 0 THEN
				SET NEW.Absent = 0.0;
			ELSEIF has_shift = TRUE AND (NEW.VacationLeaveHours + NEW.SickLeaveHours + NEW.MaternityLeaveHours + NEW.OtherLeaveHours) = 0
					AND NEW.TotalDayPay = 0 THEN
#					AND (@calclegalholi = 0 AND @calcspecholi = 0) THEN
					
					IF isSpecialHoliday = TRUE THEN
						IF NEW.IsValidForHolidayPayment = TRUE
							AND @calcspecholi = TRUE THEN
							
							SET NEW.TotalDayPay = @daily_pay;
							SET NEW.Absent = 0;
						ELSE
							SET NEW.Absent = @daily_pay;
						END IF;
					END IF;
					
					IF isLegalHoliday = TRUE THEN
						IF NEW.IsValidForHolidayPayment = TRUE
							AND @calclegalholi = TRUE THEN
							
							SET NEW.TotalDayPay = @daily_pay;
							SET NEW.Absent = 0;
						ELSE
							SET NEW.Absent = @daily_pay;
						END IF;
					END IF;

			ELSEIF has_shift = '1' AND (NEW.VacationLeaveHours + NEW.SickLeaveHours + NEW.MaternityLeaveHours + NEW.OtherLeaveHours) = 0
					AND NEW.TotalDayPay = 0
					AND @calclegalholi = 1 THEN
					
				IF NEW.IsValidForHolidayPayment = 1 THEN
				
					SET NEW.TotalDayPay = @daily_pay;
					SET NEW.Absent = 0.0;
					
				ELSE
				
					SET NEW.TotalDayPay = 0.0;
					SET NEW.Absent = @daily_pay; # 0 @daily_pay;
					
				END IF;
					
			ELSEIF has_shift = '1' AND (NEW.VacationLeaveHours + NEW.SickLeaveHours + NEW.MaternityLeaveHours + NEW.OtherLeaveHours) = 0
					AND NEW.TotalDayPay = 0 THEN
					
				IF @calcspecholi = 1 AND NEW.IsValidForHolidayPayment = TRUE THEN
					
					IF emp_type = 'Daily' THEN
					
						SET NEW.TotalDayPay = 0.0;
						SET NEW.Absent = @daily_pay; # 0 @daily_pay;
						# SET NEW.Absent = 0.0;
						
					ELSE
					
						SET NEW.TotalDayPay = @daily_pay;#GET_employeerateperday(NEW.EmployeeID, NEW.OrganizationID, NEW.`Date`);
						SET NEW.Absent = 0.0;
					
					END IF;
						
				ELSE
			
					SET NEW.TotalDayPay = 0.0;
					# SET NEW.Absent = 0.0;
					SET NEW.Absent = @daily_pay;
				
				END IF;
				
			ELSE#IF NEW.TotalDayPay > 0 THEN
				IF NEW.TotalDayPay < 1 THEN
				
					IF NEW.IsValidForHolidayPayment = 1 THEN
					
						SET NEW.TotalDayPay = @daily_pay;
						SET NEW.Absent = 0.0;
						
					ELSE
					
						SET NEW.TotalDayPay = 0.0;
						SET NEW.Absent = IF(isRest_day = 0, @daily_pay, 0);
						
					END IF;
				
				ELSE
					SET NEW.Absent = 0.0;
						
				END IF;
					
			END IF;
			
		ELSE
			SET NEW.Absent = IFNULL(NEW.Absent,0);
		
		END IF;
			
	END IF;
	
ELSE
	SET @calclegalholi = '0';
	SET @calcspecholi = '0';
	
	SELECT (pr.PayType = 'Regular Holiday' AND e.CalcHoliday = '1' AND e.StartDate <= NEW.`Date`)
	,(pr.PayType = 'Special Non-Working Holiday' AND e.CalcSpecialHoliday = '1')
	,e.EmployeeType
	FROM payrate pr
	INNER JOIN employee e ON e.RowID=NEW.EmployeeID
	WHERE pr.RowID=NEW.PayRateID
	INTO @calclegalholi
			,@calcspecholi,emp_type;
	
	IF @calclegalholi = 1 THEN
	
		SET @e_dayrate = 0.00;
		
		IF emp_type = 'Daily' THEN
			SELECT es.BasicPay FROM employeesalary es WHERE es.RowID=NEW.EmployeeSalaryID INTO @e_dayrate;
		ELSE
			SELECT ( es.BasicPay / (e.WorkDaysPerYear / 24) ) FROM employeesalary es INNER JOIN employee e ON e.RowID=es.EmployeeID WHERE es.RowID=NEW.EmployeeSalaryID INTO @e_dayrate;
		END IF;
		
		IF NEW.IsValidForHolidayPayment = 1 THEN
		
			SET NEW.TotalDayPay = @e_dayrate;
			
		ELSE
			SET NEW.TotalDayPay = 0;
			
		END IF;
		
		SET NEW.Absent = 0;
		
		IF NOT NEW.IsValidForHolidayPayment AND emp_type = 'Monthly' THEN SET NEW.Absent = @e_dayrate; END IF;
	ELSE
		SET NEW.Absent = NULL; SET NEW.Absent = IFNULL(NEW.Absent,0);
	END IF;
	
	/*PAYS THE 100% OF DAILY RATE IF REGULAR HOLIDAY FALLS DURING REST DAY*/
	/*IF EXISTS(SELECT e.RowID FROM employee e WHERE e.EmployeeType='Daily' AND e.RowID=NEW.EmployeeID AND e.OrganizationID=NEW.OrganizationID AND e.DayOfRest=DAYOFWEEK(NEW.`Date`) AND e.CalcHoliday='Y' AND isDateNotHoliday = '0') = 1 THEN
		SET NEW.TotalDayPay = e_rateperday;
	END IF;*/
END IF;
SET NEW.Absent = IFNULL(NEW.Absent,0);

IF isRest_day = '1' AND NEW.EmployeeShiftID IS NOT NULL THEN
	
	SET NEW.EmployeeShiftID = NULL;
	
END IF;

SELECT e_rateperday INTO rate_this_date;
SET NEW.HolidayPayAmount = 0;
IF LCASE(@employee_type)='monthly' THEN
	IF NEW.IsValidForHolidayPayment = 1 THEN
		SET NEW.HolidayPayAmount = rate_this_date;
		SET @_payrateThisDate=payrate_this_date;
		IF @isRestDay AND @calcRestDay THEN
			SET @_payrateThisDate = 0;
		ELSEIF NOT @isRestDay THEN
			IF isSpecialHoliday THEN
				SET @_payrateThisDate = (payrate_this_date MOD 1) / payrate_this_date;
			ELSEIF isLegalHoliday THEN
				SET @_payrateThisDate = (payrate_this_date - 1) / payrate_this_date;
			END IF;
		END IF;

		#SET @additional=((NEW.RegularHoursWorked * (NULLIF(rate_this_date, 0) / default_working_hrs)) * NULLIF((payrate_this_date-1),0));
		SET @additional=((NEW.RegularHoursWorked * (NULLIF(rate_this_date*payrate_this_date, 0) / default_working_hrs)) * @_payrateThisDate);
		SET @additional=IFNULL(@additional,0);
		
#		SET NEW.HolidayPayAmount = NEW.HolidayPayAmount + @additional;
		SET NEW.AddedHolidayPayAmount=@additional;
		
		SET NEW.TotalDayPay=(
		+ NEW.OvertimeHoursAmount
		+ NEW.NightDiffHoursAmount
		+ NEW.NightDiffOTHoursAmount
		+ NEW.HolidayPayAmount);
	ELSE
		SET NEW.HolidayPayAmount = 0;
	END IF;
ELSEIF LCASE(@employee_type)='daily' THEN
	
	IF NEW.IsValidForHolidayPayment=TRUE AND isLegalHoliday=TRUE AND NEW.RegularHoursAmount=0 AND NEW.TotalDayPay=rate_this_date THEN
		SET NEW.HolidayPayAmount = rate_this_date;
	ELSE
		SET NEW.HolidayPayAmount = 0;
	END IF;
	
	SET @isSatisfiedSpecial=EXISTS(SELECT e.RowID
									FROM employee e
									WHERE e.RowID=NEW.EmployeeID
									AND isSpecialHoliday=TRUE AND e.CalcSpecialHoliday=TRUE
									AND NEW.IsValidForHolidayPayment=TRUE);
	SET @isSatisfiedLegal=EXISTS(SELECT e.RowID
									FROM employee e
									WHERE e.RowID=NEW.EmployeeID
									AND isLegalHoliday=TRUE AND e.CalcHoliday=TRUE
									AND NEW.IsValidForHolidayPayment=TRUE);
	SET @isSatisfied = (@isSatisfiedSpecial OR @isSatisfiedLegal);
	IF @isSatisfied=TRUE THEN
		SET @additional=((NEW.RegularHoursWorked * (NULLIF(rate_this_date, 0) / default_working_hrs)) * NULLIF((payrate_this_date-1),0));
		SET @additional=IFNULL(@additional,0);
	
		SET NEW.AddedHolidayPayAmount=@additional;
		
#		IF @isSatisfiedLegal THEN SET NEW.TotalDayPay=NEW.TotalDayPay + @additional; END IF;
		
#		IF @isSatisfiedSpecial THEN ?? END IF;
	ELSE
		SET NEW.AddedHolidayPayAmount=0;
	END IF;
	
END IF;

IF NEW.HolidayPayAmount IS NULL THEN
	SET NEW.HolidayPayAmount = 0;
END IF;

IF NEW.TotalDayPay = 0 AND NEW.HolidayPayAmount > 0 THEN SET NEW.TotalDayPay = NEW.HolidayPayAmount; END IF;

SET @ecola_rowid = 0;

SELECT RowID FROM product WHERE OrganizationID=NEW.OrganizationID AND LCASE(PartNo)='ecola' AND `Category`='Allowance type' INTO @ecola_rowid;

SELECT SUM(ea.AllowanceAmount) FROM employeeallowance ea WHERE ea.ProductID != @ecola_rowid AND ea.AllowanceFrequency='Daily' AND ea.TaxableFlag='1' AND ea.EmployeeID=NEW.EmployeeID AND ea.OrganizationID=NEW.OrganizationID AND NEW.`Date` BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate INTO TaxableDailyAllowanceAmount;

SELECT sh.DivisorToDailyRate
FROM employeeshift esh INNER JOIN shift sh ON sh.RowID=esh.ShiftID WHERE esh.RowID=NEW.EmployeeShiftID INTO rate_this_date;
SET @daily_salary = e_rateperday;
SET NEW.TaxableDailyAllowance = (SELECT (
NULLIF(IF(pr.PayType='Regular Day'
   , IF(NEW.TotalDayPay > NEW.RegularHoursAmount
	     , IF(NEW.RegularHoursAmount=0
		       , ((NEW.VacationLeaveHours + NEW.SickLeaveHours + NEW.MaternityLeaveHours + NEW.OtherLeaveHours) * (NULLIF(@daily_salary, 0) / rate_this_date))
				 , NEW.RegularHoursAmount), NEW.TotalDayPay)
   , IF(pr.PayType='Special Non-Working Holiday' AND e.CalcSpecialHoliday = '1'
        , IF(e.EmployeeType = 'Daily', (NULLIF(NEW.RegularHoursAmount, 0) / pr.`PayRate`), NEW.HolidayPayAmount)
        , IF(pr.PayType='Special Non-Working Holiday' AND e.CalcSpecialHoliday = '0'
             , IF(e.EmployeeType = 'Daily', NEW.RegularHoursAmount, NEW.HolidayPayAmount)
             , IF(pr.PayType='Regular Holiday' AND e.CalcHoliday = '1'
				      , NEW.HolidayPayAmount + ((NEW.VacationLeaveHours + NEW.SickLeaveHours + NEW.MaternityLeaveHours + NEW.OtherLeaveHours) * (NULLIF(@daily_salary, 0) / rate_this_date))
                   , 0)
             )
        )
  ), 0) / @daily_salary) * TaxableDailyAllowanceAmount
											FROM employee e
											INNER JOIN payrate pr ON pr.RowID=NEW.PayRateID
											WHERE e.RowID=NEW.EmployeeID AND e.OrganizationID=NEW.OrganizationID);

IF NEW.TaxableDailyAllowance IS NULL THEN
	SET NEW.TaxableDailyAllowance = 0;
END IF;

IF NEW.TaxableDailyBonus IS NULL THEN
	SET NEW.TaxableDailyBonus = 0;
END IF;

IF NEW.NonTaxableDailyBonus IS NULL THEN
	SET NEW.NonTaxableDailyBonus = 0;
END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
