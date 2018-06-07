/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `moduleviews`;
DROP TABLE IF EXISTS `moduleviews`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `moduleviews` AS SELECT CONVERT('Agency' USING utf8) `ViewName`
UNION SELECT CONVERT('Agency Fee' USING utf8)
UNION SELECT CONVERT('Alpha list' USING utf8)
UNION SELECT CONVERT('Attendance sheet' USING utf8)
UNION SELECT CONVERT('Division' USING utf8)
UNION SELECT CONVERT('Duty shifting' USING utf8)
UNION SELECT CONVERT('Employee 13th Month Pay Report' USING utf8)
UNION SELECT CONVERT('Employee Allowance' USING utf8)
UNION SELECT CONVERT('Employee Attachment' USING utf8)
UNION SELECT CONVERT('Employee Award' USING utf8)
UNION SELECT CONVERT('Employee Bonus' USING utf8)
UNION SELECT CONVERT('Employee Certification' USING utf8)
UNION SELECT CONVERT('Employee Dependents' USING utf8)
UNION SELECT CONVERT('Employee Disciplinary Action' USING utf8)
UNION SELECT CONVERT('Employee Educational Background' USING utf8)
UNION SELECT CONVERT('Employee Leave' USING utf8)
# UNION SELECT CONVERT('Employee Leave Ledger' USING utf8)
UNION SELECT CONVERT('Employee Loan History' USING utf8)
UNION SELECT CONVERT('Employee Loan Report' USING utf8)
UNION SELECT CONVERT('Employee Loan Schedule' USING utf8)
UNION SELECT CONVERT('Employee Medical Profile' USING utf8)
UNION SELECT CONVERT('Employee Overtime' USING utf8)
UNION SELECT CONVERT('Employee Pay Slip' USING utf8)
UNION SELECT CONVERT('Employee Personal Information' USING utf8)
UNION SELECT CONVERT('Employee Personal Profile' USING utf8)
UNION SELECT CONVERT('Employee Previous Employer' USING utf8)
UNION SELECT CONVERT('Employee Promotion' USING utf8)
UNION SELECT CONVERT('Employee Salary' USING utf8)
UNION SELECT CONVERT('Employee Shift' USING utf8)
UNION SELECT CONVERT('Employee Time Entry' USING utf8)
UNION SELECT CONVERT('Employee Time Entry logs' USING utf8)
UNION SELECT CONVERT('Employee\'s Employment Record' USING utf8)
UNION SELECT CONVERT('Employee\'s History of Salary Increase' USING utf8)
UNION SELECT CONVERT('Employee\'s Identification Number' USING utf8)
UNION SELECT CONVERT('Employee\'s Offenses' USING utf8)
UNION SELECT CONVERT('Employee\'s payroll Ledger' USING utf8)
UNION SELECT CONVERT('Excessive Tardiness report' USING utf8)
UNION SELECT CONVERT('List of value' USING utf8)
UNION SELECT CONVERT('Login Form' USING utf8)
UNION SELECT CONVERT('Official Business filing' USING utf8)
UNION SELECT CONVERT('Organization' USING utf8)
UNION SELECT CONVERT('PAGIBIG Monthly Report' USING utf8)
UNION SELECT CONVERT('Pay rate' USING utf8)
UNION SELECT CONVERT('Payroll Summary Report' USING utf8)
UNION SELECT CONVERT('PhilHealth Contribution Table' USING utf8)
UNION SELECT CONVERT('PhilHealth Monthly Report' USING utf8)
UNION SELECT CONVERT('Position' USING utf8)
UNION SELECT CONVERT('Post Employment Clearance' USING utf8)
UNION SELECT CONVERT('SSS Contribution Table' USING utf8)
UNION SELECT CONVERT('SSS Monthly Report' USING utf8)
UNION SELECT CONVERT('Tax Monthly Report' USING utf8)
UNION SELECT CONVERT('User Privilege' USING utf8)
UNION SELECT CONVERT('Users' USING utf8)
UNION SELECT CONVERT('Withholding Tax Table' USING utf8) 
UNION SELECT CONVERT('Filed Leaves Report' USING utf8)
UNION SELECT CONVERT('Employee Leave Balance Summary' USING utf8) ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
