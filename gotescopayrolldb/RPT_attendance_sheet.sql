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

-- Dumping structure for procedure gotescopayrolldb_server.RPT_attendance_sheet
DROP PROCEDURE IF EXISTS `RPT_attendance_sheet`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `RPT_attendance_sheet`(IN `OrganizationID` INT, IN `FromDate` DATE, IN `ToDate` DATE)
    DETERMINISTIC
BEGIN

SELECT
CONCAT(ee.EmployeeID,' / ',ee.LastName,',',ee.FirstName, IF(ee.MiddleName='','',','),INITIALS(ee.MiddleName,'. ','1')) `DatCol1`
, UCASE(SUBSTRING(DATE_FORMAT(ete.`Date`,'%W'),1,3)) `DatCol2`
, DATE_FORMAT(ete.`Date`,'%m/%e/%y') `DatCol3`
, IFNULL(CONCAT(TIME_FORMAT(sh.TimeFrom,'%l'), IF(TIME_FORMAT(sh.TimeFrom,'%i') > 0, CONCAT(':', TIME_FORMAT(sh.TimeFrom,'%i')),''),'to', TIME_FORMAT(sh.TimeTo,'%l'), IF(TIME_FORMAT(sh.TimeTo,'%i') > 0, CONCAT(':', TIME_FORMAT(sh.TimeTo,'%i')),'')),'') `DatCol4`
,REPLACE(TIME_FORMAT(etd.TimeIn,'%l:%i %p'),'M','') `DatCol5`
,'' `DatCol6`
,'' `DatCol7`
,REPLACE(TIME_FORMAT(etd.TimeOut,'%l:%i %p'),'M','') `DatCol8`
, IFNULL(ete.TotalHoursWorked,0) 'TotalHoursWorked', IFNULL(ete.HoursLate,0) `DatCol9`
, IFNULL(ete.HoursLate, 0) `DatCol10`
, IFNULL(ete.UndertimeHours,0) `DatCol11`
, IFNULL(ete.NightDifferentialHours,0) `DatCol12`
, IFNULL(ete.OvertimeHoursWorked,0) `DatCol13`
, IFNULL(ete.NightDifferentialOTHours,0) `DatCol14`
,etd.TimeScheduleType `DatCol15`
FROM employeetimeentry ete
INNER JOIN employee e ON e.RowID=ete.EmployeeID AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
LEFT JOIN employeeshift esh ON esh.RowID=ete.EmployeeShiftID
LEFT JOIN shift sh ON sh.RowID=esh.ShiftID
INNER JOIN employeetimeentrydetails etd ON etd.EmployeeID=ete.EmployeeID AND etd.OrganizationID=ete.OrganizationID AND etd.`Date`=ete.`Date`
LEFT JOIN employee ee ON ee.RowID=ete.EmployeeID
WHERE ete.`Date` BETWEEN FromDate AND ToDate AND ete.OrganizationID=OrganizationID
AND etd.RowID IS NOT NULL
GROUP BY ete.RowID
ORDER BY ete.`Date`,ee.LastName;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
