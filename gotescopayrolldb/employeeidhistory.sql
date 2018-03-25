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

-- Dumping structure for view gotescopayrolldb_server.employeeidhistory
DROP VIEW IF EXISTS `employeeidhistory`;
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `employeeidhistory`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `employeeidhistory` AS SELECT 
aut.RowID
, e.RowID `EmployeeRowID`
, v.OrganizationID
, e.EmployeeID
, e.LastName, e.FirstName, e.MiddleName
, pos.PositionName
, aut.OldValue
, aut.NewValue
, aut.ActionPerformed
, aut.Created
FROM audittrail aut
INNER JOIN `view` v
        ON v.ViewName = 'Employee Personal Profile'
		     # AND v.OrganizationID = 3
		     AND aut.ViewID = v.RowID
INNER JOIN employee e
        ON e.RowID=aut.ChangedRowID
		     AND e.OrganizationID=v.OrganizationID
		     AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
INNER JOIN `position` pos
        ON pos.RowID=e.PositionID
WHERE aut.FieldChanged = 'EmployeeID'
AND aut.ActionPerformed IN ('Insert', 'Update') ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
