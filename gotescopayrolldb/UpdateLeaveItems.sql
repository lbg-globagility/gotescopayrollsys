/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `UpdateLeaveItems`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateLeaveItems`(
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



#SELECT ii.* FROM paystub ps

UPDATE paystub ps
INNER JOIN (SELECT
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
				
				, SUM(et.VacationLeaveHours) `VacationLeaveHours`
				, SUM(et.SickLeaveHours) `SickLeaveHours`
				, SUM(et.OtherLeaveHours) `OtherLeaveHours`
				, SUM(et.AdditionalVLHours) `AdditionalVLHours`
				, SUM(et.MaternityLeaveHours) `MaternityLeaveHours`
				
				FROM employeetimeentry et
				INNER JOIN employee e ON e.RowID=et.EmployeeID
				INNER JOIN payperiod pp
                    ON et.`Date` BETWEEN pp.PayFromDate AND pp.PayToDate
                       AND (pp.PayFromDate >= thisYearPayDateFrom AND pp.PayToDate <= thisYearPayDateTo)
							  AND pp.TotalGrossSalary=e.PayFrequencyID
							  AND pp.OrganizationID=et.OrganizationID
				WHERE (et.VacationLeaveHours + et.SickLeaveHours + et.OtherLeaveHours + et.AdditionalVLHours + et.MaternityLeaveHours) > 0
				AND et.OrganizationID = orgId
				GROUP BY pp.RowID, e.RowID
				ORDER BY e.RowID, pp.`Year`, pp.OrdinalValue) i
				) ii ON ps.EmployeeID = ii.EmployeeID AND ps.PayPeriodID = ii.PayPeriodID

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
;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
