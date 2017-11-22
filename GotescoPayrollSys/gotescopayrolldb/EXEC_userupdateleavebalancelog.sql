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

-- Dumping structure for procedure gotescopayrolldb_oct19.EXEC_userupdateleavebalancelog
DROP PROCEDURE IF EXISTS `EXEC_userupdateleavebalancelog`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `EXEC_userupdateleavebalancelog`(IN `OrganizID` INT, IN `UserRowID` INT)
    DETERMINISTIC
BEGIN

DECLARE hasupdate TINYINT;

DECLARE minimum_date DATE;

DECLARE maximum_date DATE;

DECLARE custom_maximum_date DATE;

DECLARE curr_year YEAR;

SET curr_year = YEAR(CURDATE());

SELECT EXISTS(SELECT RowID FROM userupdateleavebalancelog uu WHERE uu.OrganizationID=OrganizID AND uu.YearValue=curr_year) INTO hasupdate;

IF hasupdate = 0 THEN
	
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
	WHERE e.OrganizationID=OrganizID;
	
	SELECT MIN(ps.PayFromDate) FROM paystub ps INNER JOIN payperiod pp ON pp.TotalGrossSalary = 1 AND pp.RowID=ps.PayPeriodID AND pp.`Year`=curr_year AND pp.OrganizationID=ps.OrganizationID WHERE ps.OrganizationID=OrganizID INTO minimum_date;
	IF minimum_date IS NULL THEN
		SELECT pp.PayFromDate FROM payperiod pp WHERE pp.OrdinalValue = 1 AND pp.TotalGrossSalary = 1 AND pp.`Year`=curr_year AND pp.OrganizationID=OrganizID INTO minimum_date;
	END IF;
	
	
	SELECT MAX(ps.PayToDate) FROM paystub ps INNER JOIN payperiod pp ON pp.TotalGrossSalary = 1 AND pp.RowID=ps.PayPeriodID AND pp.`Year`=curr_year AND pp.OrganizationID=ps.OrganizationID WHERE ps.OrganizationID=OrganizID INTO maximum_date;
	IF maximum_date IS NULL THEN
		SELECT pp.PayFromDate FROM payperiod pp WHERE pp.OrdinalValue = 24 AND pp.TotalGrossSalary = 1 AND pp.`Year`=curr_year AND pp.OrganizationID=OrganizID INTO maximum_date;
	END IF;

	
	SELECT pp.PayToDate FROM payperiod pp WHERE pp.OrdinalValue = 24 AND pp.TotalGrossSalary = 1 AND pp.`Year`=curr_year AND pp.OrganizationID=OrganizID INTO custom_maximum_date;
	
	IF custom_maximum_date IS NULL THEN
		SET custom_maximum_date = ADDDATE(SUBDATE(minimum_date, INTERVAL 1 DAY), INTERVAL 1 YEAR);
	END IF;
	
	# SET custom_maximum_date = IFNULL(maximum_date, ADDDATE(SUBDATE(minimum_date, INTERVAL 1 DAY), INTERVAL 1 YEAR));
	
	# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ #
	
	SET @paypFrom = CURDATE();
	SET @paypTo = CURDATE();
	
	SELECT pp.PayFromDate, pp.PayToDate FROM payperiod pp WHERE pp.TotalGrossSalary = 1 AND pp.OrdinalValue = 1 AND pp.`Year`=curr_year AND pp.OrganizationID=OrganizID INTO @paypFrom, @paypTo;
	
	# ------------------------------ #
	##################################
	# GAINING OF TYPICAL LEAVE BALANCE
	##################################
	UPDATE employee e
	INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
	INNER JOIN paystub ps ON ps.EmployeeID=e.RowID AND ps.OrganizationID=e.OrganizationID AND e.DateRegularized BETWEEN ps.PayFromDate AND ps.PayToDate
	INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID AND ps.TotalGrossSalary=e.PayFrequencyID AND pp.`Year`=curr_year
	SET
	e.LeavePerPayPeriod =				( e.LeaveAllowance / 24 )
	,e.SickLeavePerPayPeriod =			( e.SickLeaveAllowance / 24 )
	,e.MaternityLeavePerPayPeriod =	( e.MaternityLeaveAllowance / 24 )
	,e.OtherLeavePerPayPeriod =		( e.OtherLeaveAllowance / 24 )
	
	,e.LeaveBalance =				( e.LeaveAllowance / 24 ) * (24 - pp.OrdinalValue)
	,e.SickLeaveBalance =		( e.SickLeaveAllowance / 24 ) * (24 - pp.OrdinalValue)
	,e.MaternityLeaveBalance =	( e.MaternityLeaveAllowance / 24 ) * (24 - pp.OrdinalValue)
	,e.OtherLeaveBalance =		( e.OtherLeaveAllowance / 24 ) * (24 - pp.OrdinalValue)
	
	,e.LastUpd=CURRENT_TIMESTAMP()
	,e.LastUpdBy=UserRowID
	WHERE e.OrganizationID=OrganizID
	AND e.DateRegularized BETWEEN minimum_date AND custom_maximum_date;
	
	UPDATE employee e
	SET
	e.LeaveBalance =				e.LeaveAllowance
	,e.SickLeaveBalance =		e.SickLeaveAllowance
	,e.MaternityLeaveBalance =	e.MaternityLeaveAllowance
	,e.OtherLeaveBalance =		e.OtherLeaveAllowance
	
	,e.LastUpd=CURRENT_TIMESTAMP()
	,e.LastUpdBy=UserRowID
	WHERE e.OrganizationID=OrganizID
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
	
	SET e.AdditionalVLPerPayPeriod=( e.LeaveTenthYearService / 24 )
	,e.LastUpd=CURRENT_TIMESTAMP()
	,e.LastUpdBy=UserRowID
	WHERE e.OrganizationID=OrganizID
	AND ADDDATE(e.DateRegularized,INTERVAL 5 YEAR) <= minimum_date;
	# AND YEAR(ADDDATE(e.DateRegularized,INTERVAL 5 YEAR)) = curr_year;
	# AND IF(ADDDATE(e.DateRegularized,INTERVAL 5 YEAR) BETWEEN @paypFrom AND @paypTo, @paypTo, @paypFrom)
	# BETWEEN ADDDATE(e.DateRegularized,INTERVAL 5 YEAR) AND ADDDATE(e.DateRegularized,INTERVAL 10 YEAR);
	
	UPDATE employee e
	INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
	
	INNER JOIN paystub ps ON ps.EmployeeID=e.RowID AND ps.OrganizationID=e.OrganizationID AND ADDDATE(e.DateRegularized,INTERVAL 5 YEAR) BETWEEN ps.PayFromDate AND ps.PayToDate
	INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID AND ps.TotalGrossSalary=e.PayFrequencyID AND pp.`Year`=curr_year
	
	SET
	e.AdditionalVLBalance = ( e.AdditionalVLPerPayPeriod * (24 - pp.OrdinalValue) )
	,e.LastUpd=CURRENT_TIMESTAMP()
	,e.LastUpdBy=UserRowID
	WHERE e.OrganizationID=OrganizID
	AND YEAR(ADDDATE(e.DateRegularized,INTERVAL 5 YEAR)) = curr_year;
	
	SET @i = 6;
	
	WHILE (@i BETWEEN 6 AND 10) DO
	
		UPDATE employee e
		SET
		e.AdditionalVLBalance = e.LeaveTenthYearService
		,e.LastUpd=CURRENT_TIMESTAMP()
		,e.LastUpdBy=UserRowID
		WHERE e.OrganizationID=OrganizID AND ADDDATE(e.DateRegularized,INTERVAL @i YEAR) BETWEEN minimum_date AND custom_maximum_date;
		
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
	SET e.AdditionalVLPerPayPeriod=( e.LeaveFifteenthYearService / ( PAYFREQUENCY_DIVISOR(pf.PayFrequencyType) * MONTH(SUBDATE(MAKEDATE(curr_year,1), INTERVAL 1 DAY)) ) )
	,e.LastUpd=CURRENT_TIMESTAMP()
	,e.LastUpdBy=UserRowID
	WHERE e.OrganizationID=OrganizID
	AND YEAR(ADDDATE(e.DateRegularized,INTERVAL 10 YEAR)) = curr_year;
	
	UPDATE employee e
	INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
	INNER JOIN paystub ps ON ps.EmployeeID=e.RowID AND ps.OrganizationID=e.OrganizationID AND ADDDATE(e.DateRegularized,INTERVAL 10 YEAR) BETWEEN ps.PayFromDate AND ps.PayToDate
	INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID AND ps.TotalGrossSalary=e.PayFrequencyID AND pp.`Year`=curr_year
	SET
	e.AdditionalVLBalance = ( e.AdditionalVLPerPayPeriod * (24 - pp.OrdinalValue) )
	,e.LastUpd=CURRENT_TIMESTAMP()
	,e.LastUpdBy=UserRowID
	WHERE e.OrganizationID=OrganizID
	AND YEAR(ADDDATE(e.DateRegularized,INTERVAL 10 YEAR)) = curr_year;
	
	SET @i = 11;
	
	WHILE (@i BETWEEN 11 AND 15) DO
	
		UPDATE employee e
		SET
		e.AdditionalVLAllowance = e.LeaveFifteenthYearService
		,e.AdditionalVLBalance = e.LeaveFifteenthYearService
		,e.AdditionalVLPerPayPeriod = (e.LeaveFifteenthYearService / 24)
		,e.LastUpd=CURRENT_TIMESTAMP()
		,e.LastUpdBy=UserRowID
		WHERE e.OrganizationID=OrganizID AND ADDDATE(e.DateRegularized,INTERVAL @i YEAR) BETWEEN minimum_date AND custom_maximum_date;
		
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
	e.AdditionalVLBalance = e.LeaveAboveFifteenthYearService
	,e.AdditionalVLAllowance = e.LeaveAboveFifteenthYearService
	,e.AdditionalVLPerPayPeriod = ( e.LeaveAboveFifteenthYearService / 24 )
	,e.LastUpd=CURRENT_TIMESTAMP()
	,e.LastUpdBy=UserRowID
	WHERE e.OrganizationID=OrganizID
	AND ADDDATE(e.DateRegularized,INTERVAL 15 YEAR) <= minimum_date; # AND minimum_date <= ADDDATE(e.DateRegularized,INTERVAL 15 YEAR)
	
	# ------------------------------ #
	
	# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ #
	
	
	
	
	
	
	
	
	
	
	
	
	
	INSERT INTO userupdateleavebalancelog(OrganizationID,Created,UserID,YearValue) VALUES (OrganizID,CURRENT_TIMESTAMP(),UserRowID,curr_year) ON DUPLICATE KEY UPDATE LastUpd=CURRENT_TIMESTAMP();
	
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
	WHERE e.OrganizationID = OrganizID;
	# AND (ADDDATE(e.StartDate, INTERVAL 2 YEAR) <= curr_year
			# OR ADDDATE(e.StartDate, INTERVAL 1 YEAR) BETWEEN minimum_date AND custom_maximum_date);
			
END IF;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
