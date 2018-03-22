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

-- Dumping structure for view gotescopayrolldb_server.employeesalary_withdailyrate
DROP VIEW IF EXISTS `employeesalary_withdailyrate`;
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `employeesalary_withdailyrate`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `employeesalary_withdailyrate` AS SELECT esa.*
	 ,ROUND(
	 (esa.Salary
	  / (e.WorkDaysPerYear
	     / 12 # count of months per year
		  )), 6) `DailyRate`
	, ROUND(esa.Salary, 6) `MonthlySalary`
	FROM employeesalary esa
	INNER JOIN employee e ON e.RowID=esa.EmployeeID AND e.EmployeeType IN ('Monthly', 'Fixed')
	
UNION
	SELECT esa.*
	, ROUND(esa.BasicPay, 6) `DailyRate`
	, ROUND( (esa.BasicPay * (e.WorkDaysPerYear / 12)) , 6) `MonthlySalary`
	FROM employeesalary esa
	INNER JOIN employee e ON e.RowID=esa.EmployeeID AND e.EmployeeType = 'Daily' ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
