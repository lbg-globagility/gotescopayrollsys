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

-- Dumping structure for procedure gotescopayrolldb_server.VIEW_payperiodofyear
DROP PROCEDURE IF EXISTS `VIEW_payperiodofyear`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `VIEW_payperiodofyear`(IN `payp_OrganizationID` INT, IN `param_Date` DATE)
    DETERMINISTIC
BEGIN

SET @_year = YEAR(IFNULL(param_Date, CURDATE()));

SELECT payp.RowID
,DATE_FORMAT(payp.PayFromDate,'%c/%e/%Y')
,DATE_FORMAT(payp.PayToDate,'%c/%e/%Y')
,payp.PayFromDate
,payp.PayToDate
,IFNULL(payp.TotalGrossSalary,0) `TotalGrossSalary`
,IFNULL(payp.TotalNetSalary,0) `TotalNetSalary`
,IFNULL(payp.TotalEmpSSS,0) `TotalEmpSSS`
,IFNULL(payp.TotalEmpWithholdingTax,0) `TotalEmpWithholdingTax`
,IFNULL(payp.TotalCompSSS,0) `TotalCompSSS`
,IFNULL(payp.TotalEmpPhilhealth,0) `TotalEmpPhilhealth`
,IFNULL(payp.TotalCompPhilhealth,0) `TotalCompPhilhealth`
,IFNULL(payp.TotalEmpHDMF,0) `TotalEmpHDMF`
,IF(payp.TotalGrossSalary = 4, 'WEEKLY', 'SEMI-MONTHLY') `TotalCompHDMF`
,IF(DATE_FORMAT(NOW(),'%Y-%m-%d') BETWEEN payp.PayFromDate AND payp.PayToDate,'0',IF(DATE_FORMAT(NOW(),'%Y-%m-%d') > payp.PayFromDate,'-1','1')) `now_origin`
,payp.Half `eom`
FROM payperiod payp
INNER JOIN paystub payst ON payst.PayPeriodID=payp.RowID
WHERE payp.OrganizationID=payp_OrganizationID
AND payp.`Year`=@_year
GROUP BY payst.PayPeriodID
ORDER BY payp.PayFromDate DESC,payp.PayToDate DESC;









END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
