/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `LEAVE_gainingbalance`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `LEAVE_gainingbalance`(IN `OrganizID` INT, IN `EmpRowID` INT, IN `UserRowID` INT, IN `minimum_date` DATE, IN `custom_maximum_date` DATE)
    DETERMINISTIC
BEGIN

DECLARE maximum_date DATE;

DECLARE curr_year YEAR;

DECLARE count_semi_monthly_period_peryear INT DEFAULT 24;

DECLARE e_indx, e_count, count_leavetype, _i, leavetypeid, payFreqId INT DEFAULT 0;

DECLARE i INT DEFAULT 0;

DECLARE payDateFrom, payDateTo DATE;

DECLARE thisYearPayDateFrom, thisYearPayDateTo DATE;

SET payDateFrom = minimum_date;
SET payDateTo = custom_maximum_date;

UPDATE employee e
INNER JOIN payfrequency pf
        ON pf.RowID=e.PayFrequencyID
/*INNER JOIN paystub ps
        ON ps.EmployeeID=e.RowID AND ps.OrganizationID=e.OrganizationID AND e.DateRegularized BETWEEN ps.PayFromDate AND ps.PayToDate*/
INNER JOIN payperiod pp
        ON pp.TotalGrossSalary = e.PayFrequencyID
		     AND pp.OrganizationID = e.OrganizationID
			  AND pp.PayFromDate = payDateFrom
			  AND pp.PayToDate = payDateTo
SET
e.LeavePerPayPeriod =				( e.LeaveAllowance / count_semi_monthly_period_peryear )
, e.SickLeavePerPayPeriod =			( e.SickLeaveAllowance / count_semi_monthly_period_peryear )
, e.MaternityLeavePerPayPeriod =	( e.MaternityLeaveAllowance / count_semi_monthly_period_peryear )
, e.OtherLeavePerPayPeriod =		( e.OtherLeaveAllowance / count_semi_monthly_period_peryear )

, e.LeaveBalance =				( e.LeaveAllowance / count_semi_monthly_period_peryear ) * ((count_semi_monthly_period_peryear - pp.OrdinalValue) + 1)
, e.SickLeaveBalance =		( e.SickLeaveAllowance / count_semi_monthly_period_peryear ) * ((count_semi_monthly_period_peryear - pp.OrdinalValue) + 1)
, e.MaternityLeaveBalance =	( e.MaternityLeaveAllowance / count_semi_monthly_period_peryear ) * ((count_semi_monthly_period_peryear - pp.OrdinalValue) + 1)
, e.OtherLeaveBalance =		( e.OtherLeaveAllowance / count_semi_monthly_period_peryear ) * ((count_semi_monthly_period_peryear - pp.OrdinalValue) + 1)

, e.LastUpd=CURRENT_TIMESTAMP()
, e.LastUpdBy=IFNULL(e.LastUpdBy, e.CreatedBy)
WHERE e.OrganizationID = OrganizID
AND e.DateRegularized BETWEEN payDateFrom AND payDateTo
AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
;

SELECT MIN(ppd.PayFromDate)
, MAX(ppd.PayToDate)
FROM payperiod pp
INNER JOIN payperiod ppd ON ppd.OrganizationID=pp.OrganizationID AND ppd.TotalGrossSalary=pp.TotalGrossSalary AND ppd.`Year`=pp.`Year`
WHERE pp.OrganizationID = OrganizID
AND pp.TotalGrossSalary = 1
AND pp.PayFromDate = payDateFrom
AND pp.PayToDate = payDateTo
INTO thisYearPayDateFrom
     , thisYearPayDateTo
;

UPDATE employee e
INNER JOIN (SELECT et.RowID,et.EmployeeID
				,SUM(et.VacationLeaveHours) `VacationLeaveHours`
				,SUM(et.SickLeaveHours) `SickLeaveHours`
				,SUM(et.MaternityLeaveHours) `MaternityLeaveHours`
				,SUM(et.OtherLeaveHours) `OtherLeaveHours`
				,SUM(et.AdditionalVLHours) `AdditionalVLHours`
				FROM employeetimeentry et
				WHERE et.OrganizationID = OrganizID
				AND (et.VacationLeaveHours + et.SickLeaveHours + et.MaternityLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours) != 0
				AND et.`Date` BETWEEN thisYearPayDateFrom AND thisYearPayDateTo
				GROUP BY et.EmployeeID) ete ON ete.RowID IS NOT NULL AND ete.EmployeeID = e.RowID
SET
e.LeaveBalance = e.LeaveAllowance - IFNULL(ete.VacationLeaveHours,0)
, e.SickLeaveBalance = e.SickLeaveAllowance - IFNULL(ete.SickLeaveHours,0)
, e.MaternityLeaveBalance = e.MaternityLeaveAllowance - IFNULL(ete.MaternityLeaveHours,0)
, e.OtherLeaveBalance = e.OtherLeaveAllowance - IFNULL(ete.OtherLeaveHours,0)
, e.AdditionalVLBalance = e.AdditionalVLAllowance - IFNULL(ete.AdditionalVLHours,0)

, e.LastUpd = ADDDATE(e.LastUpd, INTERVAL 1 SECOND)
, e.LastUpdBy = IFNULL(e.LastUpdBy, e.CreatedBy)
WHERE e.OrganizationID = OrganizID
AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
