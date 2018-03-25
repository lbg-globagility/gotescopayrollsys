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

-- Dumping structure for trigger gotescopayrolldb_server.AFTUPD_product
DROP TRIGGER IF EXISTS `AFTUPD_product`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `AFTUPD_product` AFTER UPDATE ON `product` FOR EACH ROW BEGIN

IF NEW.`Category` = 'Allowance Type' THEN
	
	UPDATE employeeallowance ea
	INNER JOIN product p ON p.RowID=ea.ProductID
	SET ea.TaxableFlag=p.`Status`
	,ea.LastUpdBy=NEW.LastUpdBy
	WHERE ea.ProductID=NEW.RowID;

END IF;

IF OLD.Strength != NEW.Strength THEN

	UPDATE employeeloanschedule els
	SET els.Nondeductible=NEW.Strength
	,els.LastUpd=CURRENT_TIMESTAMP()
	,els.LastUpdBy=NEW.LastUpdBy
	WHERE els.LoanTypeID=NEW.RowID;

END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
