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

-- Dumping structure for procedure gotescopayrolldb_server.GETVIEW_previousemployeetimeentry
DROP PROCEDURE IF EXISTS `GETVIEW_previousemployeetimeentry`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `GETVIEW_previousemployeetimeentry`(IN `OrganizID` INT, IN `prev_payperiodID` INT, IN `WeeklySSSSchedPayPeriodID` INT)
    DETERMINISTIC
BEGIN

DECLARE payfreqID INT(11);

DECLARE payperiodcount INT(11);

DECLARE isSSSContribSched CHAR(1);

DECLARE customdatefrom DATE;

DECLARE paydate_to DATE;

DECLARE this_month VARCHAR(2);

DECLARE this_year INT(11);

DECLARE isEndOfTheMonth CHAR(1);

DECLARE ogRowID INT(11);

DECLARE tax_sched_text VARCHAR(50);

SELECT OrganizationID, `Month`, `Year`, (`Half` = '0'),TotalGrossSalary FROM payperiod WHERE RowID=WeeklySSSSchedPayPeriodID INTO ogRowID, this_month, this_year, isEndOfTheMonth, payfreqID;

SELECT RowID FROM payperiod WHERE `Month`=this_month AND `Year`=this_year AND OrganizationID=OrganizID AND RowID!=WeeklySSSSchedPayPeriodID ORDER BY PayFromDate,PayToDate LIMIT 1 INTO prev_payperiodID;

# SELECT TotalGrossSalary,PayToDate FROM payperiod WHERE RowID=prev_payperiodID INTO payfreqID,paydate_to;

SELECT WithholdingDeductionSchedule FROM organization WHERE RowID=ogRowID INTO tax_sched_text;

SET @prev_payperiod_rowid = NULL;

SELECT pp.RowID
FROM payperiod pp
INNER JOIN payperiod pyp
        ON pyp.RowID=WeeklySSSSchedPayPeriodID
			  AND pyp.Half=IF(tax_sched_text = 'End of the month'
                           , '0'
									, IF(tax_sched_text = 'First half', '1', pp.Half))
           AND IF(tax_sched_text = 'End of the month'
                  , (pyp.OrdinalValue > pp.OrdinalValue)
					   , IF(tax_sched_text = 'First half'
					        , (pyp.OrdinalValue < pp.OrdinalValue)
						     , TRUE))
WHERE pp.OrganizationID=pyp.OrganizationID
AND pp.TotalGrossSalary=pyp.TotalGrossSalary
AND pp.`Month`=pyp.`Month`
AND pp.`Year`=pyp.`Year`
# ORDER BY pp.PayFromDate DESC, pp.PayToDate DESC
LIMIT 1
INTO @prev_payperiod_rowid;

SELECT SSSContribSched FROM payperiod WHERE RowID=WeeklySSSSchedPayPeriodID INTO isSSSContribSched;

IF payfreqID = 1 THEN

	SELECT
	ete.EmployeeID
	,SUM(ete.RegularHoursWorked) `RegularHoursWorked`
	,SUM(ete.RegularHoursAmount) `RegularHoursAmount`
	,SUM(ete.TotalHoursWorked) `TotalHoursWorked`
	,SUM(ete.OvertimeHoursWorked) `OvertimeHoursWorked`
	,SUM(ete.OvertimeHoursAmount) `OvertimeHoursAmount`
	,SUM(ete.UndertimeHours) `UndertimeHours`
	,SUM(ete.UndertimeHoursAmount) `UndertimeHoursAmount`
	,SUM(ete.NightDifferentialHours) `NightDifferentialHours`
	,SUM(ete.NightDiffHoursAmount) `NightDiffHoursAmount`
	,SUM(ete.NightDifferentialOTHours) `NightDifferentialOTHours`
	,SUM(ete.NightDiffOTHoursAmount) `NightDiffOTHoursAmount`
	,SUM(ete.HoursLate) `HoursLate`
	,SUM(ete.HoursLateAmount) `HoursLateAmount`
	,SUM(ete.VacationLeaveHours) `VacationLeaveHours`
	,SUM(ete.SickLeaveHours) `SickLeaveHours`
	,SUM(ete.MaternityLeaveHours) `MaternityLeaveHours`
	,SUM(ete.OtherLeaveHours) `OtherLeaveHours`
	,SUM(ete.AdditionalVLHours) `AdditionalVLHours`
	,SUM(ete.TotalDayPay) `TotalDayPay`
	,SUM(ete.Absent) `Absent`
	,SUM(ete.TaxableDailyAllowance) `TaxableDailyAllowance`
	,SUM(ete.HolidayPayAmount) `HolidayPayAmount`
	,SUM(ete.TaxableDailyBonus) `TaxableDailyBonus`
	,SUM(ete.NonTaxableDailyBonus) `NonTaxableDailyBonus`
	,IFNULL(ps.TotalGrossSalary
	        - (ps.TotalBonus + ps.TotalAllowance + SUM(ete.OvertimeHoursAmount)
			     + SUM(ete.NightDiffHoursAmount)
				  + SUM(ete.NightDiffOTHoursAmount))
	        , 0) `TotalGrossSalary`
	FROM employeetimeentry ete
	INNER JOIN payperiod pyp ON pyp.RowID=@prev_payperiod_rowid
	INNER JOIN employee e ON e.RowID=ete.EmployeeID
	LEFT JOIN paystub ps
	       ON ps.EmployeeID=ete.EmployeeID
			    AND ps.OrganizationID=ete.OrganizationID
				 AND ps.PayPeriodID=pyp.RowID
	WHERE ete.`Date` BETWEEN pyp.PayFromDate AND pyp.PayToDate
	AND ete.OrganizationID=OrganizID
	AND e.PayFrequencyID=payfreqID
	GROUP BY ete.EmployeeID;

	IF tax_sched_text = 'End of the month' THEN

		IF isEndOfTheMonth = '1' THEN
			
			SELECT RowID FROM payperiod WHERE `Month`=this_month AND `Year`=this_year AND OrganizationID=OrganizID
			AND `Half`='1'
			ORDER BY PayFromDate,PayToDate LIMIT 1 INTO prev_payperiodID;

		ELSE

			SET prev_payperiodID = NULL;
			/*
			SELECT
			ete.EmployeeID
			,SUM(ete.RegularHoursWorked) `RegularHoursWorked`
			,SUM(ete.RegularHoursAmount) `RegularHoursAmount`
			,SUM(ete.TotalHoursWorked) `TotalHoursWorked`
			,SUM(ete.OvertimeHoursWorked) `OvertimeHoursWorked`
			,SUM(ete.OvertimeHoursAmount) `OvertimeHoursAmount`
			,SUM(ete.UndertimeHours) `UndertimeHours`
			,SUM(ete.UndertimeHoursAmount) `UndertimeHoursAmount`
			,SUM(ete.NightDifferentialHours) `NightDifferentialHours`
			,SUM(ete.NightDiffHoursAmount) `NightDiffHoursAmount`
			,SUM(ete.NightDifferentialOTHours) `NightDifferentialOTHours`
			,SUM(ete.NightDiffOTHoursAmount) `NightDiffOTHoursAmount`
			,SUM(ete.HoursLate) `HoursLate`
			,SUM(ete.HoursLateAmount) `HoursLateAmount`
			,SUM(ete.VacationLeaveHours) `VacationLeaveHours`
			,SUM(ete.SickLeaveHours) `SickLeaveHours`
			,SUM(ete.MaternityLeaveHours) `MaternityLeaveHours`
			,SUM(ete.OtherLeaveHours) `OtherLeaveHours`
			,SUM(ete.AdditionalVLHours) `AdditionalVLHours`
			,SUM(ete.TotalDayPay) `TotalDayPay`
			,SUM(ete.Absent) `Absent`
			,SUM(ete.TaxableDailyAllowance) `TaxableDailyAllowance`
			,SUM(ete.HolidayPayAmount) `HolidayPayAmount`
			,SUM(ete.TaxableDailyBonus) `TaxableDailyBonus`
			,SUM(ete.NonTaxableDailyBonus) `NonTaxableDailyBonus`
			FROM employeetimeentry ete
			INNER JOIN payperiod pyp ON pyp.RowID=prev_payperiodID
			INNER JOIN employee e ON e.RowID=ete.EmployeeID
			WHERE ete.`Date` IS NULL#BETWEEN '1900-01-01' AND '1900-01-01'
			AND ete.OrganizationID < 0
			AND e.PayFrequencyID=payfreqID
			GROUP BY ete.EmployeeID;
         */
		END IF;

	ELSEIF tax_sched_text = 'First half' THEN
	
		SELECT
		ete.EmployeeID
		,SUM(ete.RegularHoursWorked) `RegularHoursWorked`
		,SUM(ete.RegularHoursAmount) `RegularHoursAmount`
		,SUM(ete.TotalHoursWorked) `TotalHoursWorked`
		,SUM(ete.OvertimeHoursWorked) `OvertimeHoursWorked`
		,SUM(ete.OvertimeHoursAmount) `OvertimeHoursAmount`
		,SUM(ete.UndertimeHours) `UndertimeHours`
		,SUM(ete.UndertimeHoursAmount) `UndertimeHoursAmount`
		,SUM(ete.NightDifferentialHours) `NightDifferentialHours`
		,SUM(ete.NightDiffHoursAmount) `NightDiffHoursAmount`
		,SUM(ete.NightDifferentialOTHours) `NightDifferentialOTHours`
		,SUM(ete.NightDiffOTHoursAmount) `NightDiffOTHoursAmount`
		,SUM(ete.HoursLate) `HoursLate`
		,SUM(ete.HoursLateAmount) `HoursLateAmount`
		,SUM(ete.VacationLeaveHours) `VacationLeaveHours`
		,SUM(ete.SickLeaveHours) `SickLeaveHours`
		,SUM(ete.MaternityLeaveHours) `MaternityLeaveHours`
		,SUM(ete.OtherLeaveHours) `OtherLeaveHours`
		,SUM(ete.AdditionalVLHours) `AdditionalVLHours`
		,SUM(ete.TotalDayPay) `TotalDayPay`
		,SUM(ete.Absent) `Absent`
		,SUM(ete.TaxableDailyAllowance) `TaxableDailyAllowance`
		,SUM(ete.HolidayPayAmount) `HolidayPayAmount`
		,SUM(ete.TaxableDailyBonus) `TaxableDailyBonus`
		,SUM(ete.NonTaxableDailyBonus) `NonTaxableDailyBonus`
	   ,IFNULL(ps.TotalGrossSalary
	           - (ps.TotalBonus + ps.TotalAllowance + SUM(ete.OvertimeHoursAmount)
			        + SUM(ete.NightDiffHoursAmount)
				     + SUM(ete.NightDiffOTHoursAmount))
	           , 0) `TotalGrossSalary`
		FROM employeetimeentry ete
		INNER JOIN payperiod pyp ON pyp.RowID=prev_payperiodID
		INNER JOIN employee e ON e.RowID=ete.EmployeeID
		LEFT JOIN paystub ps
	          ON ps.EmployeeID=e.RowID
			       AND ps.OrganizationID=ete.OrganizationID
				    AND ps.PayPeriodID=pyp.RowID
		WHERE ete.`Date` BETWEEN pyp.PayFromDate AND pyp.PayToDate
		AND ete.OrganizationID=OrganizID
		AND e.PayFrequencyID=payfreqID
		GROUP BY ete.EmployeeID;

	END IF;
		
ELSEIF payfreqID = 4 THEN
	
	IF isSSSContribSched = '1' THEN
			
		SET customdatefrom = SUBDATE(paydate_to, INTERVAL 3 WEEK);

		SET customdatefrom = ADDDATE(customdatefrom, INTERVAL 1 DAY);
	
		SELECT
		ete.*
		FROM employeetimeentry ete
		INNER JOIN employee e ON e.RowID=ete.EmployeeID
		WHERE ete.OrganizationID=OrganizID
		AND e.PayFrequencyID=payfreqID
		AND ete.`Date` BETWEEN customdatefrom AND paydate_to;

	ELSE

		SELECT
		ete.*
		FROM employeetimeentry ete
		INNER JOIN payperiod pyp ON pyp.RowID=prev_payperiodID
		INNER JOIN employee e ON e.RowID=ete.EmployeeID
		WHERE ete.OrganizationID=OrganizID
		AND e.PayFrequencyID=payfreqID
		AND ete.Date IN  (SELECT
								ADDDATE(pyp.PayFromDate, INTERVAL g.n DAY) AS WkDate
								FROM generator_16 g
								INNER JOIN payperiod pp ON pp.RowID=prev_payperiodID
								INNER JOIN payperiod pyp ON pyp.OrganizationID=pp.OrganizationID AND CONCAT(pyp.`Year`,pyp.`Month`)=CONCAT(pp.`Year`,pp.`Month`) AND pyp.TotalGrossSalary=pp.TotalGrossSalary AND pyp.PayFromDate < pp.PayFromDate AND pyp.PayToDate < pp.PayToDate
								WHERE g.n <= DATEDIFF(pyp.PayToDate,pyp.PayFromDate)
								ORDER BY ADDDATE(pyp.PayFromDate, INTERVAL g.n DAY));

	END IF;
		
END IF;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
