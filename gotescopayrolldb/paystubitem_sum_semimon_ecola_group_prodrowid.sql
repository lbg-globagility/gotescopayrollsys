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

-- Dumping structure for view gotescopayrolldb_server.paystubitem_sum_semimon_ecola_group_prodrowid
DROP VIEW IF EXISTS `paystubitem_sum_semimon_ecola_group_prodrowid`;
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `paystubitem_sum_semimon_ecola_group_prodrowid`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `paystubitem_sum_semimon_ecola_group_prodrowid` AS SELECT i.*
	,et.RowID `etRowID`
	,d.DateValue `Date`
	FROM v_employeesemimonthlyallowance i
	INNER JOIN dates d
	        ON d.DateValue BETWEEN i.EffectiveStartDate AND i.EffectiveEndDate
	INNER JOIN employee e
	        ON e.RowID=i.EmployeeID
			     AND e.OrganizationID=i.OrganizationID
			     AND e.EmploymentStatus = 'Regular'
	INNER JOIN payfrequency pf
	        ON pf.RowID=e.PayFrequencyID
	INNER JOIN product p
	        ON p.RowID=i.ProductID AND LOCATE('ecola', LCASE(p.PartNo)) > 0
	INNER JOIN employeetimeentry et
	       ON et.OrganizationID=i.OrganizationID
	          AND et.EmployeeID=28
	          AND et.`Date`=d.DateValue
	          # AND et.`Date` BETWEEN i.EffectiveStartDate AND i.EffectiveEndDate
	          AND (IFNULL(et.HoursLate, 0) + IFNULL(et.UndertimeHours, 0)) > 0
				     OR IFNULL(et.Absent, 0) > 0
	LEFT JOIN employeeshift esh
	       ON esh.RowID=et.EmployeeShiftID
	LEFT JOIN shift sh
	       ON sh.RowID=esh.ShiftID
	INNER JOIN dates dd
	        ON dd.DateValue BETWEEN i.EffectiveStartDate AND i.EffectiveEndDate ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
