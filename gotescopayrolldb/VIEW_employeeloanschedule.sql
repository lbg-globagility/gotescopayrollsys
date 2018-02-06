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

-- Dumping structure for procedure gotescopayrolldb_latest.VIEW_employeeloanschedule
DROP PROCEDURE IF EXISTS `VIEW_employeeloanschedule`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `VIEW_employeeloanschedule`(IN `OrganizID` INT, IN `EmpRowID` INT)
    DETERMINISTIC
BEGIN

DECLARE cancelled_status VARCHAR(50) DEFAULT '';

SELECT TRIM(SUBSTRING_INDEX(ii.COLUMN_COMMENT,',',-1)) FROM information_schema.`COLUMNS` ii WHERE ii.TABLE_SCHEMA='gotescopayrolldatabaseoct3' AND ii.COLUMN_NAME='Status' AND ii.TABLE_NAME='employeeloanschedule' INTO cancelled_status;

SELECT
els.LoanNumber
,els.TotalLoanAmount
,els.TotalBalanceLeft
,els.DeductionAmount
,els.DeductionPercentage
,els.DeductionSchedule
,els.Noofpayperiod
,els.LoanPayPeriodLeft
,DATE_FORMAT(els.DedEffectiveDateFrom,'%c/%e/%Y') AS DedEffectiveDateFrom
,els.Comments
,els.RowID

,els.`Status`
,IFNULL(p.PartNo,'') AS `Loan Type`
,(els.`Status` != cancelled_status AND els.LoanPayPeriodLeft > 0) AS Cancellable
FROM employeeloanschedule els
LEFT JOIN product p ON p.RowID=els.LoanTypeID AND p.OrganizationID=els.OrganizationID

WHERE els.OrganizationID=OrganizID
AND els.EmployeeID=EmpRowID
ORDER BY els.LoanNumber,TIME_FORMAT(els.Created,'%p%H%i%s'),DATE_FORMAT(els.Created,'%Y%c%e');






END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
