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

-- Dumping structure for procedure gotescopayrolldb.LEAVE_gainingbalance
DROP PROCEDURE IF EXISTS `LEAVE_gainingbalance`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `LEAVE_gainingbalance`(IN `OrganizID` INT, IN `EmpRowID` INT, IN `UserRowID` INT, IN `minimum_date` DATE, IN `custom_maximum_date` DATE)
    DETERMINISTIC
BEGIN

DECLARE maximum_date DATE;

DECLARE curr_year YEAR;

DECLARE count_semi_monthly_period_peryear INT DEFAULT 24;

DECLARE e_indx INT DEFAULT 0;

# SET @sleep_count = SLEEP(3);

SELECT pp.`Year` FROM payperiod pp WHERE pp.OrganizationID = OrganizID AND pp.TotalGrossSalary = 1 AND pp.PayFromDate = minimum_date AND pp.PayToDate = custom_maximum_date LIMIT 1 INTO curr_year;

IF curr_year = YEAR(CURDATE()) THEN

	SELECT
	MIN(pp.PayFromDate) `MinPayDateFrom`
	, MAX(pp.PayToDate) `MinPayDateTo`
	FROM paystub ps
	INNER JOIN employee e ON e.RowID=ps.EmployeeID AND e.OrganizationID=ps.OrganizationID
	INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID AND pp.TotalGrossSalary=e.PayFrequencyID AND pp.OrganizationID=ps.OrganizationID AND pp.`Year` = curr_year
	WHERE ps.OrganizationID=OrganizID
	AND ps.EmployeeID=EmpRowID
	# GROUP BY e.RowID, pp.`Year`
	# ORDER BY pp.`Year` DESC
	INTO minimum_date
	     ,maximum_date
	;
	/*SELECT MIN(ps.PayFromDate)
	FROM paystub ps
	INNER JOIN payperiod pp
	        ON pp.TotalGrossSalary = 1
			     AND pp.RowID=ps.PayPeriodID
				  AND pp.`Year`=curr_year
				  AND pp.OrganizationID=ps.OrganizationID
	WHERE ps.OrganizationID=OrganizID
	AND ps.EmployeeID=EmpRowID
	INTO minimum_date;*/
	IF minimum_date IS NULL THEN
		SELECT pp.PayFromDate FROM payperiod pp WHERE pp.OrdinalValue = 1 AND pp.TotalGrossSalary = 1 AND pp.`Year`=curr_year AND pp.OrganizationID=OrganizID INTO minimum_date;
	END IF;
	
	
	/*SELECT MAX(ps.PayToDate)
	FROM paystub ps
	INNER JOIN payperiod pp
	        ON pp.TotalGrossSalary = 1
			     AND pp.RowID=ps.PayPeriodID
				  AND pp.`Year`=curr_year
				  AND pp.OrganizationID=ps.OrganizationID
	WHERE ps.OrganizationID=OrganizID
	AND ps.EmployeeID=EmpRowID
	INTO maximum_date;*/
	IF maximum_date IS NULL THEN
		SELECT pp.PayFromDate FROM payperiod pp WHERE pp.OrdinalValue = count_semi_monthly_period_peryear AND pp.TotalGrossSalary = 1 AND pp.`Year`=curr_year AND pp.OrganizationID=OrganizID INTO maximum_date;
	END IF;

	
	SELECT pp.PayToDate FROM payperiod pp WHERE pp.OrdinalValue = count_semi_monthly_period_peryear AND pp.TotalGrossSalary = 1 AND pp.`Year`=curr_year AND pp.OrganizationID=OrganizID INTO custom_maximum_date;
	
	IF custom_maximum_date IS NULL THEN
		SET custom_maximum_date = ADDDATE(SUBDATE(minimum_date, INTERVAL 1 DAY), INTERVAL 1 YEAR);
	END IF;
	
	# SET custom_maximum_date = IFNULL(maximum_date, ADDDATE(SUBDATE(minimum_date, INTERVAL 1 DAY), INTERVAL 1 YEAR));
	
	# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ #
	
	SET @paypFrom = CURDATE();
	SET @paypTo = CURDATE();
	
	SELECT pp.PayFromDate, pp.PayToDate FROM payperiod pp WHERE pp.TotalGrossSalary = 1 AND pp.OrdinalValue = 1 AND pp.`Year`=curr_year AND pp.OrganizationID=OrganizID INTO @paypFrom, @paypTo;
	
	SET @e_count = (SELECT COUNT(RowID) FROM employee WHERE OrganizationID=OrganizID AND EmploymentStatus NOT IN ('Terminated', 'Resigned'));
	
	WHILE (e_indx < @e_count) DO
		
		SELECT e.RowID
		FROM employee e
		WHERE OrganizationID=OrganizID
		AND EmploymentStatus NOT IN ('Terminated', 'Resigned')
		LIMIT e_indx, 1
		INTO EmpRowID;
			
		UPDATE employee e
		SET
		e.LeaveBalance=0
		,e.SickLeaveBalance=0
		,e.MaternityLeaveBalance=0
		,e.OtherLeaveBalance=0
		,e.AdditionalVLBalance=0
		,e.AdditionalVLPerPayPeriod=0
		,e.AdditionalVLAllowance=0
		,e.LastUpd=CURRENT_TIMESTAMP()
		,e.LastUpdBy=UserRowID
		WHERE e.OrganizationID = OrganizID
		AND e.RowID = EmpRowID;
		
		# ------------------------------ #
		##################################
		# GAINING OF TYPICAL LEAVE BALANCE
		##################################
		UPDATE employee e
		INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
		INNER JOIN paystub ps ON ps.EmployeeID=e.RowID AND ps.OrganizationID=e.OrganizationID AND e.DateRegularized BETWEEN ps.PayFromDate AND ps.PayToDate
		INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID AND ps.TotalGrossSalary=e.PayFrequencyID AND pp.`Year`=curr_year
		SET
		e.LeavePerPayPeriod =				( e.LeaveAllowance / count_semi_monthly_period_peryear )
		,e.SickLeavePerPayPeriod =			( e.SickLeaveAllowance / count_semi_monthly_period_peryear )
		,e.MaternityLeavePerPayPeriod =	( e.MaternityLeaveAllowance / count_semi_monthly_period_peryear )
		,e.OtherLeavePerPayPeriod =		( e.OtherLeaveAllowance / count_semi_monthly_period_peryear )
		
		,e.LeaveBalance =				( e.LeaveAllowance / count_semi_monthly_period_peryear ) * (count_semi_monthly_period_peryear - pp.OrdinalValue)
		,e.SickLeaveBalance =		( e.SickLeaveAllowance / count_semi_monthly_period_peryear ) * (count_semi_monthly_period_peryear - pp.OrdinalValue)
		,e.MaternityLeaveBalance =	( e.MaternityLeaveAllowance / count_semi_monthly_period_peryear ) * (count_semi_monthly_period_peryear - pp.OrdinalValue)
		,e.OtherLeaveBalance =		( e.OtherLeaveAllowance / count_semi_monthly_period_peryear ) * (count_semi_monthly_period_peryear - pp.OrdinalValue)
		
		,e.LastUpd=CURRENT_TIMESTAMP()
		,e.LastUpdBy=UserRowID
		WHERE e.OrganizationID=OrganizID
		AND e.RowID = EmpRowID
		AND e.DateRegularized BETWEEN minimum_date AND custom_maximum_date;
		
		SET @custom_curr_time_stamp = CURRENT_TIMESTAMP();
		
		UPDATE employee e
		SET
		e.LeaveBalance =				e.LeaveAllowance
		,e.SickLeaveBalance =		e.SickLeaveAllowance
		,e.MaternityLeaveBalance =	e.MaternityLeaveAllowance
		,e.OtherLeaveBalance =		e.OtherLeaveAllowance
		
		,e.LastUpd=@custom_curr_time_stamp
		,e.LastUpdBy=UserRowID
		WHERE e.OrganizationID=OrganizID
		AND e.RowID = EmpRowID
		AND e.DateRegularized < minimum_date
			OR e.DateRegularized < custom_maximum_date;
		
		# ------------------------------ #
		
		
		# ------------------------------ #
		##########################################
		# YEARS OF SERVICE IS BETWEEN 5TH AND 10TH
		##########################################
		UPDATE employee e
		INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
		
		INNER JOIN paystub ps ON ps.EmployeeID=e.RowID AND ps.OrganizationID=e.OrganizationID AND ADDDATE(e.DateRegularized,INTERVAL 5 YEAR) BETWEEN ps.PayFromDate AND ps.PayToDate
		INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID AND ps.TotalGrossSalary=e.PayFrequencyID AND pp.`Year`=curr_year
		
		SET e.AdditionalVLPerPayPeriod=( e.LeaveTenthYearService / count_semi_monthly_period_peryear )
		,e.LastUpd=CURRENT_TIMESTAMP()
		,e.LastUpdBy=UserRowID
		WHERE e.OrganizationID=OrganizID
		AND e.RowID = EmpRowID
		AND ADDDATE(e.DateRegularized,INTERVAL 5 YEAR) <= minimum_date
		AND e.LastUpd != @custom_curr_time_stamp
		;
		# AND YEAR(ADDDATE(e.DateRegularized,INTERVAL 5 YEAR)) = curr_year;
		# AND IF(ADDDATE(e.DateRegularized,INTERVAL 5 YEAR) BETWEEN @paypFrom AND @paypTo, @paypTo, @paypFrom)
		# BETWEEN ADDDATE(e.DateRegularized,INTERVAL 5 YEAR) AND ADDDATE(e.DateRegularized,INTERVAL 10 YEAR);
		
		UPDATE employee e
		INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
		
		INNER JOIN paystub ps ON ps.EmployeeID=e.RowID AND ps.OrganizationID=e.OrganizationID AND ADDDATE(e.DateRegularized,INTERVAL 5 YEAR) BETWEEN ps.PayFromDate AND ps.PayToDate
		INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID AND ps.TotalGrossSalary=e.PayFrequencyID AND pp.`Year`=curr_year
		
		SET
		e.AdditionalVLBalance =		( e.AdditionalVLPerPayPeriod * (count_semi_monthly_period_peryear - pp.OrdinalValue) )
		,e.AdditionalVLAllowance = ( e.AdditionalVLPerPayPeriod * (count_semi_monthly_period_peryear - pp.OrdinalValue) )
		,e.LastUpd=CURRENT_TIMESTAMP()
		,e.LastUpdBy=UserRowID
		WHERE e.OrganizationID=OrganizID
		AND e.RowID = EmpRowID
		AND YEAR(ADDDATE(e.DateRegularized,INTERVAL 5 YEAR)) = curr_year
		AND e.LastUpd != @custom_curr_time_stamp;
		
		SET @i = 6;
		
		WHILE (@i BETWEEN 6 AND 10) DO
		
			UPDATE employee e
			SET
			e.AdditionalVLBalance =		e.LeaveTenthYearService
			,e.AdditionalVLAllowance = e.LeaveTenthYearService
			,e.LastUpd=CURRENT_TIMESTAMP()
			,e.LastUpdBy=UserRowID
			WHERE e.RowID = EmpRowID
			AND e.OrganizationID=OrganizID AND ADDDATE(e.DateRegularized,INTERVAL @i YEAR) BETWEEN minimum_date AND custom_maximum_date
			AND e.LastUpd != @custom_curr_time_stamp;
			
			SET @i = @i + 1;
			
		END WHILE;
		# ------------------------------ #
		
		
		# ------------------------------ #
		###########################################
		# YEARS OF SERVICE IS BETWEEN 10TH AND 15TH
		###########################################
		UPDATE employee e
		INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
		INNER JOIN paystub ps ON ps.EmployeeID=e.RowID AND ps.OrganizationID=e.OrganizationID AND ADDDATE(e.DateRegularized,INTERVAL 10 YEAR) BETWEEN ps.PayFromDate AND ps.PayToDate
		INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID AND ps.TotalGrossSalary=e.PayFrequencyID AND pp.`Year`=curr_year
		SET
		e.AdditionalVLPerPayPeriod=( e.LeaveFifteenthYearService / ( PAYFREQUENCY_DIVISOR(pf.PayFrequencyType) * MONTH(SUBDATE(MAKEDATE(curr_year,1), INTERVAL 1 DAY)) ) )
		,e.LastUpd=CURRENT_TIMESTAMP()
		,e.LastUpdBy=UserRowID
		WHERE e.OrganizationID=OrganizID
		AND e.RowID = EmpRowID
		AND YEAR(ADDDATE(e.DateRegularized,INTERVAL 10 YEAR)) = curr_year
		AND e.LastUpd != @custom_curr_time_stamp;
		
		UPDATE employee e
		INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
		INNER JOIN paystub ps ON ps.EmployeeID=e.RowID AND ps.OrganizationID=e.OrganizationID AND ADDDATE(e.DateRegularized,INTERVAL 10 YEAR) BETWEEN ps.PayFromDate AND ps.PayToDate
		INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID AND ps.TotalGrossSalary=e.PayFrequencyID AND pp.`Year`=curr_year
		SET
		e.AdditionalVLBalance = 	( e.AdditionalVLPerPayPeriod * (count_semi_monthly_period_peryear - pp.OrdinalValue) )
		,e.AdditionalVLAllowance = ( e.AdditionalVLPerPayPeriod * (count_semi_monthly_period_peryear - pp.OrdinalValue) )
		,e.LastUpd=CURRENT_TIMESTAMP()
		,e.LastUpdBy=UserRowID
		WHERE e.OrganizationID=OrganizID
		AND e.RowID = EmpRowID
		AND YEAR(ADDDATE(e.DateRegularized,INTERVAL 10 YEAR)) = curr_year
		AND e.LastUpd != @custom_curr_time_stamp;
		
		SET @i = 11;
		
		WHILE (@i BETWEEN 11 AND 15) DO
		
			UPDATE employee e
			SET
			e.AdditionalVLAllowance =		e.LeaveFifteenthYearService
			,e.AdditionalVLBalance =		e.LeaveFifteenthYearService
			,e.AdditionalVLPerPayPeriod = (e.LeaveFifteenthYearService / count_semi_monthly_period_peryear)
			,e.LastUpd=CURRENT_TIMESTAMP()
			,e.LastUpdBy=UserRowID
			WHERE e.RowID = EmpRowID
			AND e.OrganizationID=OrganizID AND ADDDATE(e.DateRegularized,INTERVAL @i YEAR) BETWEEN minimum_date AND custom_maximum_date
		AND e.LastUpd != @custom_curr_time_stamp;
			
			SET @i = @i + 1;
			
		END WHILE;
		# ------------------------------ #
		
		
		# ------------------------------ #
		#####################################
		# YEARS OF SERVICE IS GREATER THAN 15
		#####################################

		UPDATE employee e
		INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
		# INNER JOIN payperiod pp ON pp.`Year`=curr_year AND pp.TotalGrossSalary=e.PayFrequencyID AND pp.OrganizationID=e.OrganizationID AND ADDDATE(e.DateRegularized,INTERVAL 15 YEAR) BETWEEN pp.PayFromDate AND pp.PayToDate
		SET
		e.AdditionalVLBalance =			e.LeaveAboveFifteenthYearService
		,e.AdditionalVLAllowance =		e.LeaveAboveFifteenthYearService
		,e.AdditionalVLPerPayPeriod = ( e.LeaveAboveFifteenthYearService / count_semi_monthly_period_peryear )
		,e.LastUpd=CURRENT_TIMESTAMP()
		,e.LastUpdBy=UserRowID
		WHERE e.OrganizationID=OrganizID
		AND e.RowID = EmpRowID
		AND ADDDATE(e.DateRegularized,INTERVAL 15 YEAR) <= minimum_date
		AND e.LastUpd != @custom_curr_time_stamp;
		# AND minimum_date <= ADDDATE(e.DateRegularized,INTERVAL 15 YEAR)
		
		# ------------------------------ #
		
		# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ #
		
		UPDATE employee e
		INNER JOIN (SELECT et.RowID,et.EmployeeID
						,SUM(et.VacationLeaveHours) `VacationLeaveHours`
						,SUM(et.SickLeaveHours) `SickLeaveHours`
						,SUM(et.MaternityLeaveHours) `MaternityLeaveHours`
						,SUM(et.OtherLeaveHours) `OtherLeaveHours`
						,SUM(et.AdditionalVLHours) `AdditionalVLHours`
						FROM employeetimeentry et
						WHERE et.OrganizationID = OrganizID
						AND (et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) > 0
						AND et.`Date` BETWEEN minimum_date AND custom_maximum_date
						GROUP BY et.EmployeeID) ete ON ete.RowID IS NOT NULL AND ete.EmployeeID=e.RowID
		SET
		e.LeaveBalance = e.LeaveBalance - IFNULL(ete.VacationLeaveHours,0)
		,e.SickLeaveBalance = e.SickLeaveBalance - IFNULL(ete.SickLeaveHours,0)
		,e.MaternityLeaveBalance = e.MaternityLeaveBalance - IFNULL(ete.MaternityLeaveHours,0)
		,e.OtherLeaveBalance = e.OtherLeaveBalance - IFNULL(ete.OtherLeaveHours,0)
		,e.AdditionalVLBalance = e.AdditionalVLBalance - IFNULL(ete.AdditionalVLHours,0)
		,e.LastUpd = CURRENT_TIMESTAMP()
		,e.LastUpdBy = UserRowID
		WHERE e.OrganizationID = OrganizID
		AND e.RowID = EmpRowID
		AND e.LastUpd != @custom_curr_time_stamp;
		
		SET e_indx = (e_indx + 1);
		
	END WHILE;
	
	# INSERT INTO `listofval` (`DisplayValue`, `LIC`, `Type`, `ParentLIC`, `Active`, `Description`, `Created`, `CreatedBy`, `LastUpd`, `OrderBy`, `LastUpdBy`) VALUES ('1', '2', 'Invented', '', 'Yes', 'some', '2016-04-19 17:47:13', 1, '2016-04-19 17:47:13', 1, 1) ON DUPLICATE KEY UPDATE LastUpd=CURRENT_TIMESTAMP();

	
END IF;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
