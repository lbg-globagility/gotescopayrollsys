/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `employeetimeentryactualproper`;
DROP TABLE IF EXISTS `employeetimeentryactualproper`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `employeetimeentryactualproper` AS SELECT et.*
		, (et.RegularHoursAmount * (1 / pr.`PayRate`)) `BasicDayPay`
		, CONCAT(pr.PayType, ' - non-restday') `Type`
		FROM employeetimeentryactual et
		INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID
		INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Day' AND pr.OrganizationID=et.OrganizationID
		WHERE et.EmployeeShiftID IS NOT NULL
		
	UNION
		# Regulary Holiday
		SELECT et.*
		, (et.RegularHoursAmount * (1 / pr.`PayRate`)) `BasicDayPay`
		, CONCAT(pr.PayType, ' - non-restday') `Type`
		FROM employeetimeentryactual et
		INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID
		INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Holiday' AND pr.OrganizationID=et.OrganizationID
		WHERE et.EmployeeShiftID IS NOT NULL
		
	UNION
		# Special non-working holiday
		SELECT et.*
		, (et.RegularHoursAmount * (1 / pr.`PayRate`)) `BasicDayPay`
		, CONCAT(pr.PayType, ' - non-restday') `Type`
		FROM employeetimeentryactual et
		INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID
		INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Special Non-Working Holiday' AND pr.OrganizationID=et.OrganizationID
		WHERE et.EmployeeShiftID IS NOT NULL
		
		
		# ##########################################################################
	UNION
		# Regulary Day
		SELECT et.*
		, (et.RegularHoursAmount * (1 / pr.RestDayRate)) `BasicDayPay`
		, CONCAT(pr.PayType, ' during rest day') `Type`
		FROM employeetimeentryactual et
		INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.CalcRestDay=1 AND e.OrganizationID=et.OrganizationID
		INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Day' AND pr.OrganizationID=et.OrganizationID
		WHERE et.EmployeeShiftID IS NULL
		
	UNION
		# Regulary Holiday
		SELECT et.*
		, (et.RegularHoursAmount * (1 / pr.RestDayRate)) `BasicDayPay`
		, CONCAT(pr.PayType, ' during rest day') `Type`
		FROM employeetimeentryactual et
		INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.CalcRestDay=1 AND e.OrganizationID=et.OrganizationID
		INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Regular Holiday' AND pr.OrganizationID=et.OrganizationID
		WHERE et.EmployeeShiftID IS NULL
		
	UNION
		# Special non-working holiday
		SELECT et.*
		, (et.RegularHoursAmount * (1 / pr.RestDayRate)) `BasicDayPay`
		, CONCAT(pr.PayType, ' during rest day') `Type`
		FROM employeetimeentryactual et
		INNER JOIN employee e ON e.RowID=et.EmployeeID AND e.CalcRestDay=1 AND e.OrganizationID=et.OrganizationID
		INNER JOIN payrate pr ON pr.RowID=et.PayRateID AND pr.PayType='Special Non-Working Holiday' AND pr.OrganizationID=et.OrganizationID
		WHERE et.EmployeeShiftID IS NULL ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
