-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.5.5-10.0.12-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             8.3.0.4694
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for view gotescopayrolldb_server.employeesimpleview
DROP VIEW IF EXISTS `employeesimpleview`;
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `employeesimpleview`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `employeesimpleview` AS SELECT e.RowID
, e.EmployeeID
, e.LastName
, e.FirstName
, e.MiddleName
, e.OrganizationID
, PROPERCASE(CONCAT_WS(', ', e.LastName, e.FirstName)) `FullName`
FROM employee e
INNER JOIN organization og ON og.RowID=e.OrganizationID AND og.NoPurpose=0
WHERE FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0 ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
