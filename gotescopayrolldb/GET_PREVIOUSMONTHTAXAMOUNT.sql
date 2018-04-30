/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `GET_PREVIOUSMONTHTAXAMOUNT`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `GET_PREVIOUSMONTHTAXAMOUNT`(IN `PayPeriod_RowID` INT)
    DETERMINISTIC
BEGIN

DECLARE ogRowID INT(11);

DECLARE priormonth_endcutoff_RowID INT(11);

SELECT pp.OrganizationID
FROM payperiod pp
WHERE pp.RowID=PayPeriod_RowID
INTO ogRowID;

SELECT pp.RowID
FROM payperiod pp
INNER JOIN payperiod pyp ON pyp.RowID=PayPeriod_RowID
WHERE pp.TotalGrossSalary=pyp.TotalGrossSalary AND pp.OrganizationID=pyp.OrganizationID AND pp.`Month` < pyp.`Month` AND pp.`Year` = pyp.`Year` AND pp.Half = '0'
ORDER BY pp.PayFromDate DESC,pp.PayToDate DESC
LIMIT 1
INTO priormonth_endcutoff_RowID;

SELECT e.RowID AS eRowID
,IFNULL(ps.TotalEmpWithholdingTax,0) AS TotalEmpWithholdingTax
FROM employee e
LEFT JOIN paystub ps ON ps.EmployeeID=e.RowID AND ps.OrganizationID=e.OrganizationID AND ps.PayPeriodID=IFNULL(priormonth_endcutoff_RowID,0)
WHERE e.OrganizationID=ogRowID;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
