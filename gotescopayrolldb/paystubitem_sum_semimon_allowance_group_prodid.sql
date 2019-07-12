/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `paystubitem_sum_semimon_allowance_group_prodid`;
DROP TABLE IF EXISTS `paystubitem_sum_semimon_allowance_group_prodid`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `paystubitem_sum_semimon_allowance_group_prodid` AS SELECT
et.RowID `RowID`
, p.RowID `ProductID`
, ea.EmployeeID `EmployeeID`
, ea.OrganizationID `OrganizationID`
, d.DateValue `Date`
, 0 `Column1`
, IF(LCASE(e.EmployeeType)='', es.BasicPay, (es.Salary / (e.WorkDaysPerYear / 12))) `Column2`
, 0 `TotalAllowanceAmt`
, ea.TaxableFlag `TaxableFlag`
, (IFNULL(et.HoursTardy, 0) + IFNULL(et.HoursUndertime, 0) + IF(IFNULL(et.Absent, 0) > 0, IFNULL(sh.WorkHours, 8), 0)) `HoursToLess`
, IFNULL(et.HoursTardy, 0) `LateHours`
, IFNULL(et.HoursUndertime, 0) `UndertimeHours`
, IF(IFNULL(et.Absent, 0) > 0, IFNULL(sh.WorkHours, 8), 0) `AbsentHours`
, ea.AllowanceAmount `AllowanceAmount`
, e.WorkDaysPerYear `WorkDaysPerYear`
, p.`Fixed` `Fixed`
, 2 `PAYFREQDIV`
#, IFNULL(sh.DivisorToDailyRate, 8) `DivisorToDailyRate`
, 8 `DivisorToDailyRate`
, (ea.AllowanceAmount / (e.WorkDaysPerYear / (12*2))) `DailyAllowance`
, 0 `Result`
FROM employeeallowance ea
INNER JOIN employee e ON e.RowID=ea.EmployeeID
INNER JOIN product p ON p.RowID=ea.ProductID
INNER JOIN category c ON c.RowID=p.CategoryID AND c.CategoryName='Allowance type'

INNER JOIN dates d ON d.DateValue BETWEEN ea.EffectiveStartDate AND ea.EffectiveEndDate
LEFT JOIN employeetimeentry et ON et.EmployeeID=e.RowID AND et.`Date`=d.DateValue AND et.OrganizationID=ea.OrganizationID
LEFT JOIN employeesalary es ON es.RowID=et.EmployeeSalaryID
LEFT JOIN employeeshift esh ON esh.RowID=et.EmployeeShiftID
LEFT JOIN shift sh ON sh.RowID=esh.ShiftID
WHERE ea.AllowanceFrequency='Semi-monthly'
#AND ea.OrganizationID=6
#AND d.DateValue BETWEEN '2019-06-16' AND LAST_DAY('2019-06-16')
#AND ea.EmployeeID=155
ORDER BY ea.EmployeeID, d.DateValue ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
