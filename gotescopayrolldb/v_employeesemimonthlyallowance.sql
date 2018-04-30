/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `v_employeesemimonthlyallowance`;
DROP TABLE IF EXISTS `v_employeesemimonthlyallowance`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `v_employeesemimonthlyallowance` AS SELECT ea.*
	,(ea.AllowanceAmount
	  / (e.WorkDaysPerYear
	     / (12 # is the number of months per year
		     * PAYFREQUENCY_DIVISOR(pf.PayFrequencyType)))) `DailyAllowance`
	,FALSE `IsFixed`
	FROM employeeallowance ea
	INNER JOIN employee e ON e.RowID=ea.EmployeeID AND e.OrganizationID=ea.OrganizationID AND e.EmployeeType!='Daily' AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
	INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
	INNER JOIN product p ON p.RowID=ea.ProductID AND p.`Fixed`=0
	WHERE ea.AllowanceFrequency='Semi-monthly' 
UNION
	SELECT ea.*
	,(ea.AllowanceAmount
	  / (e.WorkDaysPerYear
	     / (12 # is the number of months per year
		     * PAYFREQUENCY_DIVISOR(pf.PayFrequencyType)))) `DailyAllowance`
	,TRUE `IsFixed`
	FROM employeeallowance ea
	INNER JOIN employee e ON e.RowID=ea.EmployeeID AND e.OrganizationID=ea.OrganizationID AND e.EmployeeType!='Daily' AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
	INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID
	INNER JOIN product p ON p.RowID=ea.ProductID AND p.`Fixed`=1
	WHERE ea.AllowanceFrequency='Semi-monthly' ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
