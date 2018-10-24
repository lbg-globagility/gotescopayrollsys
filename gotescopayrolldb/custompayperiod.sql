/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `custompayperiod`;
CREATE TABLE `custompayperiod` (
	`RowID` INT(11) NOT NULL,
	`OrganizationID` INT(11) NULL,
	`Created` TIMESTAMP NOT NULL,
	`CreatedBy` INT(11) NULL,
	`LastUpd` DATETIME NULL,
	`LastUpdBy` INT(11) NULL,
	`PayFromDate` DATE NULL,
	`PayToDate` DATE NULL,
	`TotalGrossSalary` DECIMAL(10,2) NULL,
	`TotalNetSalary` DECIMAL(10,2) NULL,
	`TotalEmpSSS` DECIMAL(10,2) NULL,
	`TotalEmpWithholdingTax` DECIMAL(10,2) NULL,
	`TotalCompSSS` DECIMAL(10,2) NULL,
	`TotalEmpPhilhealth` DECIMAL(10,2) NULL,
	`TotalCompPhilhealth` DECIMAL(10,2) NULL,
	`TotalEmpHDMF` DECIMAL(10,2) NULL,
	`TotalCompHDMF` DECIMAL(10,2) NULL,
	`Month` INT(11) NULL,
	`Year` CHAR(4) NULL COLLATE 'latin1_swedish_ci',
	`Half` CHAR(1) NULL COLLATE 'latin1_swedish_ci',
	`SSSContribSched` CHAR(1) NULL COLLATE 'latin1_swedish_ci',
	`PhHContribSched` CHAR(1) NULL COLLATE 'latin1_swedish_ci',
	`HDMFContribSched` CHAR(1) NULL COLLATE 'latin1_swedish_ci',
	`OrdinalValue` INT(11) NULL,
	`MinimumWageValue` DECIMAL(11,2) NULL,
	`CustomPayFromDate` DATE NULL,
	`CustomPayToDate` DATE NULL
) ENGINE=MyISAM;

DROP VIEW IF EXISTS `custompayperiod`;
DROP TABLE IF EXISTS `custompayperiod`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `custompayperiod` AS SELECT pp.*
	
	, STR_TO_DATE(CONCAT_WS('-', pp.`Month`, 1, pp.`Year`), '%c-%e-%Y') `CustomPayFromDate`
	, STR_TO_DATE(CONCAT_WS('-', pp.`Month`, 15, pp.`Year`), '%c-%e-%Y') `CustomPayToDate`
	
	FROM payperiod pp
	WHERE pp.TotalGrossSalary = 1
	AND pp.Half = 1
	
UNION
	SELECT pp.*
	
	, STR_TO_DATE(CONCAT_WS('-', pp.`Month`, 16, pp.`Year`), '%c-%e-%Y') `CustomPayFromDate`
	, LAST_DAY( STR_TO_DATE(CONCAT_WS('-', pp.`Month`, 1, pp.`Year`), '%c-%e-%Y') ) `CustomPayToDate`
	
	FROM payperiod pp
	WHERE pp.TotalGrossSalary = 1
	AND pp.Half = 0 ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
