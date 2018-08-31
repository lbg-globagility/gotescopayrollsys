/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `employee_activeperiod`;
DROP TABLE IF EXISTS `employee_activeperiod`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `employee_activeperiod` AS # Below are employees still in service
	SELECT e.RowID `RowId`
	, pp.RowID `PayPeriodId`
	, IF(_start.RowID = pp.RowID
	     , 'Initial period'
		  , 'Succeeding period of initial year') `Description`
	FROM employee e
	INNER JOIN payperiod _start
	        ON _start.OrganizationID=e.OrganizationID
			     AND _start.TotalGrossSalary=e.PayFrequencyID			     
			     AND e.StartDate BETWEEN _start.PayFromDate AND _start.PayToDate
			     
	INNER JOIN payperiod pp
	        ON pp.OrganizationID=e.OrganizationID
			     AND pp.TotalGrossSalary=e.PayFrequencyID
				  AND pp.`Year` = _start.`Year`
				  AND pp.OrdinalValue >= _start.OrdinalValue
	WHERE FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0

UNION
	SELECT e.RowID `RowId`
	, pp.RowID `PayPeriodId`
	, 'Served period(s)' `Description`
	FROM employee e
	INNER JOIN payperiod _start
	        ON _start.OrganizationID=e.OrganizationID
			     AND _start.TotalGrossSalary=e.PayFrequencyID			     
			     AND e.StartDate BETWEEN _start.PayFromDate AND _start.PayToDate
			     
	INNER JOIN payperiod pp
	        ON pp.OrganizationID=e.OrganizationID
			     AND pp.TotalGrossSalary=e.PayFrequencyID
				  AND pp.`Year` >= (_start.`Year`+1)
	WHERE FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0

# Below are employees quit already
UNION
	SELECT e.EmployeeId `RowId`
	, pp.RowID `PayPeriodId`
	, IF(_start.RowID = pp.RowID
	     , 'Initial period'
		  , 'Succeeding period of initial year') `Description`
	FROM employee_quitperiod e
	INNER JOIN employee ee ON ee.RowID=e.EmployeeId
	INNER JOIN payperiod _start
	        ON _start.OrganizationID=e.OrganizationID
			     AND _start.TotalGrossSalary=ee.PayFrequencyID			     
			     AND ee.StartDate BETWEEN _start.PayFromDate AND _start.PayToDate
			     
	INNER JOIN payperiod pp
	        ON pp.OrganizationID=e.OrganizationID
			     AND pp.TotalGrossSalary=e.PayFrequencyID
				  AND pp.`Year` = _start.`Year`
				  AND pp.OrdinalValue >= _start.OrdinalValue

UNION
	SELECT e.EmployeeId `RowId`
	, pp.RowID `PayPeriodId`
	, 'Served period(s)' `Description`
	FROM employee_quitperiod e
	INNER JOIN employee ee ON ee.RowID=e.EmployeeId
	
	INNER JOIN payperiod quit ON quit.RowID=e.PayPeriodId
	
	INNER JOIN payperiod _start
	        ON _start.OrganizationID=e.OrganizationID
			     AND _start.TotalGrossSalary=ee.PayFrequencyID			     
			     AND ee.StartDate BETWEEN _start.PayFromDate AND _start.PayToDate
	
	INNER JOIN payperiod pp
	        ON pp.OrganizationID=e.OrganizationID
			     AND pp.TotalGrossSalary=e.PayFrequencyID
				  AND pp.`Year` BETWEEN (_start.`Year`+ 1) AND (quit.`Year`-1)

UNION
	SELECT e.EmployeeId `RowId`
	, pp.RowID `PayPeriodId`
	, 'Year of quit, and rest served period' `Description`
	FROM employee_quitperiod e
	INNER JOIN payperiod quit ON quit.RowID=e.PayPeriodId
	INNER JOIN payperiod pp
	        ON pp.OrganizationID=e.OrganizationID
			     AND pp.TotalGrossSalary=e.PayFrequencyID
				  AND pp.`Year` = quit.`Year`
				  AND pp.OrdinalValue <= quit.OrdinalValue ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
