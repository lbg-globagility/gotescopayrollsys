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

-- Dumping structure for trigger gotescopayrolldb_server.BEFUPD_payperiod
DROP TRIGGER IF EXISTS `BEFUPD_payperiod`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `BEFUPD_payperiod` BEFORE UPDATE ON `payperiod` FOR EACH ROW BEGIN

DECLARE payfreq_divisor INT(11);

IF NEW.TotalGrossSalary = 1 THEN
	
	SELECT PAYFREQUENCY_DIVISOR(pf.PayFrequencyType) FROM payfrequency pf WHERE pf.RowID=NEW.TotalGrossSalary INTO payfreq_divisor;
	
	SET NEW.OrdinalValue = (NEW.`Month` * payfreq_divisor) - (NEW.`Half` * 1);

ELSEIF NEW.TotalGrossSalary = 4 THEN
	
	SET @ordinal_value = 0; SET @number = 0;
	
	SELECT x.`MyNumber`
	FROM (SELECT pp.RowID
			,(@number := @number + 1) `MyNumber`
			FROM payperiod pp
			WHERE pp.OrganizationID=NEW.OrganizationID
			AND pp.TotalGrossSalary=NEW.TotalGrossSalary
			AND pp.`Year`=NEW.`Year`
			ORDER BY pp.PayFromDate) x
	WHERE x.RowID=NEW.RowID
	LIMIT 1
	INTO @ordinal_value;

	SET NEW.OrdinalValue = @ordinal_value;
	
END IF;



IF IFNULL(NEW.MinimumWageValue,0) <= 0 THEN
	SET NEW.MinimumWageValue = 481.0;
END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
