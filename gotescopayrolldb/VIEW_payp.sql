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

-- Dumping structure for procedure gotescopayrolldb_server.VIEW_payp
DROP PROCEDURE IF EXISTS `VIEW_payp`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `VIEW_payp`(IN `payp_OrganizationID` INT, IN `param_Date` DATE, IN `isotherformat` CHAR(1), IN `PayFreqType` TEXT)
    DETERMINISTIC
BEGIN

IF param_Date IS NULL THEN

	SET param_Date = MAKEDATE(YEAR(CURDATE()), 1);

END IF;

IF isotherformat = '0' THEN


	
	IF PayFreqType = 'SEMI-MONTHLY' THEN
	
		SELECT payp.RowID
		,payp.PayFromDate
		,payp.PayToDate
		,COALESCE(DATE_FORMAT(payp.PayFromDate,'%m/%d/%Y'),'') 'Pay period from'
		,COALESCE(DATE_FORMAT(payp.PayToDate,'%m/%d/%Y'),'') 'Pay period to'
		,COALESCE(payp.TotalGrossSalary,0) 'TotalGrossSalary'
		,payp.`Month` 'TotalNetSalary'
		,COALESCE(payp.TotalEmpSSS,0) 'TotalEmpSSS'
		,COALESCE(payp.TotalEmpWithholdingTax,0) 'TotalEmpWithholdingTax'
		,COALESCE(payp.TotalCompSSS,0) 'TotalCompSSS'
		,COALESCE(payp.TotalEmpPhilhealth,0) 'TotalEmpPhilhealth'
		,COALESCE(payp.TotalCompPhilhealth,0) 'TotalCompPhilhealth'
		,COALESCE(payp.TotalEmpHDMF,0) 'TotalEmpHDMF'
		,COALESCE(payp.TotalCompHDMF,0) 'TotalCompHDMF'
		,IF(DATE_FORMAT(NOW(),'%Y-%m-%d') BETWEEN payp.PayFromDate AND payp.PayToDate,'0',IF(DATE_FORMAT(NOW(),'%Y-%m-%d') > payp.PayFromDate,'-1','1')) 'now_origin'
		,payp.`Half` AS eom
		,SSSContribSched
		,PhHContribSched
		,HDMFContribSched
		,payp.MinimumWageValue AS PayPeriodMinWageValue
		FROM payperiod payp
		WHERE payp.OrganizationID=payp_OrganizationID
		AND TotalGrossSalary=1
		AND `Year` = YEAR(param_Date)
		ORDER BY payp.PayFromDate,payp.PayToDate;
		
		


	ELSEIF PayFreqType = 'WEEKLY' THEN
	
		SELECT payp.RowID
		,payp.PayFromDate
		,payp.PayToDate
		,COALESCE(DATE_FORMAT(payp.PayFromDate,'%m/%d/%Y'),'') 'Pay period from'
		,COALESCE(DATE_FORMAT(payp.PayToDate,'%m/%d/%Y'),'') 'Pay period to'
		,COALESCE(payp.TotalGrossSalary,0) 'TotalGrossSalary'
		,payp.`Month` 'TotalNetSalary'
		,COALESCE(payp.TotalEmpSSS,0) 'TotalEmpSSS'
		,COALESCE(payp.TotalEmpWithholdingTax,0) 'TotalEmpWithholdingTax'
		,COALESCE(payp.TotalCompSSS,0) 'TotalCompSSS'
		,COALESCE(payp.TotalEmpPhilhealth,0) 'TotalEmpPhilhealth'
		,COALESCE(payp.TotalCompPhilhealth,0) 'TotalCompPhilhealth'
		,COALESCE(payp.TotalEmpHDMF,0) 'TotalEmpHDMF'
		,COALESCE(payp.TotalCompHDMF,0) 'TotalCompHDMF'
		,IF(DATE_FORMAT(NOW(),'%Y-%m-%d') BETWEEN payp.PayFromDate AND payp.PayToDate,'0',IF(DATE_FORMAT(NOW(),'%Y-%m-%d') > payp.PayFromDate,'-1','1')) 'now_origin'
		,IF(payp.Half = '2', '1', IF(payp.Half = '0', payp.Half, 'A')) AS eom
		,SSSContribSched
		,PhHContribSched
		,HDMFContribSched
		,payp.MinimumWageValue AS PayPeriodMinWageValue
		FROM payperiod payp
		WHERE payp.OrganizationID=payp_OrganizationID 
		AND TotalGrossSalary=4
		AND `Year` = YEAR(param_Date)
		ORDER BY payp.PayFromDate,payp.PayToDate;
	
	
		
	END IF;

ELSE

	IF PayFreqType = 'SEMI-MONTHLY' THEN
		
		SELECT
		FALSE 'CheckBox'
		,payp.PayFromDate
		,payp.PayToDate
		,COALESCE(DATE_FORMAT(payp.PayFromDate,'%m/%d/%Y'),'') 'Pay period from'
		,COALESCE(DATE_FORMAT(payp.PayToDate,'%m/%d/%Y'),'') 'Pay period to'
		,payp.RowID
		,COALESCE(payp.TotalGrossSalary,0) 'TotalGrossSalary'
		FROM payperiod payp
		WHERE payp.OrganizationID=payp_OrganizationID
		AND TotalGrossSalary=1
		AND `Year` = YEAR(param_Date)
		ORDER BY payp.PayFromDate,payp.PayToDate;



	ELSEIF PayFreqType = 'WEEKLY' THEN
	
		SELECT
		FALSE 'CheckBox'
		,payp.PayFromDate
		,payp.PayToDate
		,COALESCE(DATE_FORMAT(payp.PayFromDate,'%m/%d/%Y'),'') 'Pay period from'
		,COALESCE(DATE_FORMAT(payp.PayToDate,'%m/%d/%Y'),'') 'Pay period to'
		,payp.RowID
		,COALESCE(payp.TotalGrossSalary,0) 'TotalGrossSalary'
		FROM payperiod payp
		WHERE payp.OrganizationID=payp_OrganizationID
		AND TotalGrossSalary=4
		AND `Year` = YEAR(param_Date)
		ORDER BY payp.PayFromDate,payp.PayToDate;



	END IF;
	
END IF;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
