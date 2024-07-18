/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP PROCEDURE IF EXISTS `UpdateLeaveItems`;
DELIMITER //
CREATE PROCEDURE `UpdateLeaveItems`(
	IN `orgId` INT,
	IN `startingPeriodId` INT
)
BEGIN

DECLARE vacationId, sickId, otherId, addtlId, maternityId INT(11) DEFAULT NULL;

DECLARE yearPeriod, payFrequencyId INT(11);

DECLARE payDateFrom, thisYearPayDateFrom, thisYearPayDateTo DATE;

DECLARE twiceAMonthPeriodCount INT(11) DEFAULT 24;

SELECT pp.PayFromDate, pp.`Year`, pp.TotalGrossSalary
FROM payperiod pp
WHERE pp.RowID = startingPeriodId
INTO payDateFrom, yearPeriod, payFrequencyId;

SELECT MIN(ii.PayFromDate) `PayFromDate`
, MAX(ii.PayToDate) `PayToDate`
FROM (SELECT i.*
		FROM (SELECT pp.*
				FROM payperiod pp
				WHERE pp.OrganizationID=orgId
				AND pp.TotalGrossSalary=payFrequencyId
				AND pp.`Year`=yearPeriod
			UNION
				SELECT pp.*
				FROM payperiod pp
				WHERE pp.OrganizationID=orgId
				AND pp.TotalGrossSalary=payFrequencyId
				AND pp.`Year`=yearPeriod+1
				) i
		WHERE i.PayFromDate >= payDateFrom
		ORDER BY i.`Year`, i.OrdinalValue
		LIMIT twiceAMonthPeriodCount
		) ii
INTO thisYearPayDateFrom
     , thisYearPayDateTo
;









SELECT p.RowID, pp.RowID, piii.RowID, piv.RowID, pv.RowID
FROM product p
INNER JOIN category c ON c.RowID=p.CategoryID AND c.CategoryName='Leave type'

INNER JOIN product pp ON pp.CategoryID=c.RowID AND pp.PartNo='Sick leave'
INNER JOIN product piii ON piii.CategoryID=c.RowID AND piii.PartNo='Others'
INNER JOIN product piv ON piv.CategoryID=c.RowID AND piv.PartNo='Additional VL'
INNER JOIN product pv ON pv.CategoryID=c.RowID AND pv.PartNo='Maternity/paternity leave'

WHERE p.OrganizationID = orgId
AND p.PartNo = 'Vacation leave'
INTO vacationId
		, sickId
		, otherId
		, addtlId
		, maternityId
;

SET @isSame = FALSE;
SET @eId = 0;

SET @vBal = 0;
SET @sBal = 0;
SET @oBal = 0;
SET @aBal = 0;
SET @mBal = 0;



DROP TEMPORARY TABLE IF EXISTS serviceperiods;
CREATE TEMPORARY TABLE serviceperiods
SELECT
		i.PayPeriodID
		, (@isSame := (@eId = i.EmployeeId)) `IsAnother`
		, IF(@isSame, @eId, @eId := i.EmployeeId) `EmployeeID`
		
		, IF(@isSame, @vBal := @vBal - i.VacationLeaveHours, @vBal := i.LeaveAllowance - i.VacationLeaveHours) `VacationBalanceDecrement`
		
		, IF(@isSame, @sBal := @sBal - i.SickLeaveHours, @sBal := i.SickLeaveAllowance - i.SickLeaveHours) `SickBalanceDecrement`
		
		, IF(@isSame, @oBal := @oBal - i.OtherLeaveHours, @oBal := i.OtherLeaveAllowance - i.OtherLeaveHours) `OtherBalanceDecrement`
		
		, IF(@isSame, @aBal := @aBal - i.AdditionalVLHours, @aBal := i.AdditionalVLAllowance - i.AdditionalVLHours) `AdditionalBalanceDecrement`
		
		, IF(@isSame, @mBal := @mBal - i.MaternityLeaveHours, @mBal := i.MaternityLeaveAllowance - i.MaternityLeaveHours) `MaternityBalanceDecrement`
		
		FROM (SELECT
				pp.RowID `PayPeriodID`
				, e.RowID `EmployeeId`
				
				, pp.PayFromDate, pp.PayToDate
				
				, e.LeaveAllowance
				, e.SickLeaveAllowance
				, e.OtherLeaveAllowance
				, e.AdditionalVLAllowance
				, e.MaternityLeaveAllowance
				
				, SUM(IF(et.VacationLeaveHours < 0, IF(elv1.LeaveType='Vacation leave', elv1.OfficialValidHours, 0), et.VacationLeaveHours)) `VacationLeaveHours`
				, SUM(IF(et.SickLeaveHours < 0, IF(elv2.LeaveType='Sick leave', elv2.OfficialValidHours, 0), et.SickLeaveHours)) `SickLeaveHours`
				, SUM(IF(et.OtherLeaveHours < 0, IF(elv3.LeaveType='Others', elv3.OfficialValidHours, 0), et.OtherLeaveHours)) `OtherLeaveHours`
				, SUM(IF(et.AdditionalVLHours < 0, IF(elv4.LeaveType='Additional VL', elv4.OfficialValidHours, 0), et.AdditionalVLHours)) `AdditionalVLHours`
				, SUM(IF(et.MaternityLeaveHours < 0, IF(elv5.LeaveType='Maternity/paternity leave', elv5.OfficialValidHours, 0), et.MaternityLeaveHours)) `MaternityLeaveHours`
				
				FROM payperiod pp
				LEFT JOIN employeetimeentry et
							ON et.`Date` BETWEEN pp.PayFromDate AND pp.PayToDate
								AND (pp.PayFromDate >= thisYearPayDateFrom AND pp.PayToDate <= thisYearPayDateTo)
								AND et.OrganizationID=pp.OrganizationID
				INNER JOIN employee e ON e.RowID=et.EmployeeID
								AND pp.TotalGrossSalary=e.PayFrequencyID
				
				LEFT JOIN employeeleave elv1 ON elv1.LeaveType='Vacation leave' AND elv1.EmployeeID=e.RowID AND et.`Date` BETWEEN elv1.LeaveStartDate AND elv1.LeaveEndDate AND et.VacationLeaveHours != 0
				LEFT JOIN employeeleave elv2 ON elv2.LeaveType='Sick leave' AND elv2.EmployeeID=e.RowID AND et.`Date` BETWEEN elv2.LeaveStartDate AND elv2.LeaveEndDate AND et.SickLeaveHours != 0
				LEFT JOIN employeeleave elv3 ON elv3.LeaveType='Others' AND elv3.EmployeeID=e.RowID AND et.`Date` BETWEEN elv3.LeaveStartDate AND elv3.LeaveEndDate AND et.OtherLeaveHours != 0
				LEFT JOIN employeeleave elv4 ON elv4.LeaveType='Additional VL' AND elv4.EmployeeID=e.RowID AND et.`Date` BETWEEN elv4.LeaveStartDate AND elv4.LeaveEndDate AND et.AdditionalVLHours != 0
				LEFT JOIN employeeleave elv5 ON elv5.LeaveType='Maternity/paternity leave' AND elv5.EmployeeID=e.RowID AND et.`Date` BETWEEN elv5.LeaveStartDate AND elv5.LeaveEndDate AND et.MaternityLeaveHours != 0
				
				WHERE pp.OrganizationID = orgId
#				AND (et.VacationLeaveHours + et.SickLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours + et.MaternityLeaveHours) > 0
				GROUP BY pp.RowID, e.RowID
#				HAVING SUM(et.VacationLeaveHours + et.SickLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours + et.MaternityLeaveHours) > 0
				ORDER BY e.RowID, pp.`Year`, pp.OrdinalValue) i
;




UPDATE paystub ps
INNER JOIN serviceperiods ii ON ps.EmployeeID = ii.EmployeeID AND ps.PayPeriodID = ii.PayPeriodID

INNER JOIN paystubitem psi ON psi.PayStubID=ps.RowID AND psi.Undeclared=TRUE AND psi.ProductID = vacationId
INNER JOIN paystubitem psii ON psii.PayStubID=ps.RowID AND psii.Undeclared=TRUE AND psii.ProductID = sickId
INNER JOIN paystubitem psiii ON psiii.PayStubID=ps.RowID AND psiii.Undeclared=TRUE AND psiii.ProductID = otherId
INNER JOIN paystubitem psiv ON psiv.PayStubID=ps.RowID AND psiv.Undeclared=TRUE AND psiv.ProductID = addtlId
INNER JOIN paystubitem psv ON psv.PayStubID=ps.RowID AND psv.Undeclared=TRUE AND psv.ProductID = maternityId

SET psi.PayAmount = ii.VacationBalanceDecrement
, psii.PayAmount = ii.SickBalanceDecrement
, psiii.PayAmount = ii.OtherBalanceDecrement
, psiv.PayAmount = ii.AdditionalBalanceDecrement
, psv.PayAmount = ii.MaternityBalanceDecrement

, psi.LastUpd = CURRENT_TIMESTAMP()
, psii.LastUpd = CURRENT_TIMESTAMP()
, psiii.LastUpd = CURRENT_TIMESTAMP()
, psiv.LastUpd = CURRENT_TIMESTAMP()
, psv.LastUpd = CURRENT_TIMESTAMP()
;

/************
*************/
UPDATE paystub ps
INNER JOIN serviceperiods ii ON ps.EmployeeID = ii.EmployeeID AND ps.PayPeriodID = ii.PayPeriodID

INNER JOIN paystubitem psi ON psi.PayStubID=ps.RowID AND psi.Undeclared=FALSE AND psi.ProductID = vacationId
INNER JOIN paystubitem psii ON psii.PayStubID=ps.RowID AND psii.Undeclared=FALSE AND psii.ProductID = sickId
INNER JOIN paystubitem psiii ON psiii.PayStubID=ps.RowID AND psiii.Undeclared=FALSE AND psiii.ProductID = otherId
INNER JOIN paystubitem psiv ON psiv.PayStubID=ps.RowID AND psiv.Undeclared=FALSE AND psiv.ProductID = addtlId
INNER JOIN paystubitem psv ON psv.PayStubID=ps.RowID AND psv.Undeclared=FALSE AND psv.ProductID = maternityId

SET psi.PayAmount = ii.VacationBalanceDecrement
, psii.PayAmount = ii.SickBalanceDecrement
, psiii.PayAmount = ii.OtherBalanceDecrement
, psiv.PayAmount = ii.AdditionalBalanceDecrement
, psv.PayAmount = ii.MaternityBalanceDecrement

, psi.LastUpd = CURRENT_TIMESTAMP()
, psii.LastUpd = CURRENT_TIMESTAMP()
, psiii.LastUpd = CURRENT_TIMESTAMP()
, psiv.LastUpd = CURRENT_TIMESTAMP()
, psv.LastUpd = CURRENT_TIMESTAMP()
;


END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
