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

-- Dumping structure for procedure gotescopayrolldb_oct19.GET_emp_leaveamounts
DROP PROCEDURE IF EXISTS `GET_emp_leaveamounts`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `GET_emp_leaveamounts`(IN `e_rowid` INT)
    DETERMINISTIC
BEGIN

/*SELECT GROUP_CONCAT(ii.COLUMN_NAME)
FROM information_schema.`COLUMNS` ii
WHERE ii.TABLE_SCHEMA='gotescopayrolldb_oct19_marm'
AND ii.TABLE_NAME='employee'
AND ii.DATA_TYPE='decimal';*/

SELECT
LeaveBalance,SickLeaveBalance,MaternityLeaveBalance,OtherLeaveBalance

,LeaveAllowance,SickLeaveAllowance,MaternityLeaveAllowance,OtherLeaveAllowance

,LeavePerPayPeriod,SickLeavePerPayPeriod,MaternityLeavePerPayPeriod,OtherLeavePerPayPeriod

,AdditionalVLAllowance,AdditionalVLBalance,AdditionalVLPerPayPeriod,LeaveTenthYearService,LeaveFifteenthYearService,LeaveAboveFifteenthYearService

FROM employee
WHERE RowID = e_rowid;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
