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

-- Dumping structure for trigger gotescopayrolldb_server.AFTDEL_paystub
DROP TRIGGER IF EXISTS `AFTDEL_paystub`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `AFTDEL_paystub` AFTER DELETE ON `paystub` FOR EACH ROW BEGIN

DECLARE ordinal_val
        ,deleted_year INT(11);

DECLARE is_userupdateleavebalancelog BOOL DEFAULT FALSE;

SELECT pp.OrdinalValue
,pp.`Year`
FROM payperiod pp
WHERE pp.RowID=OLD.PayPeriodID
INTO ordinal_val
     ,deleted_year;

IF ordinal_val = 1 THEN

	SET ordinal_val = 1;
	
	SELECT
	EXISTS(SELECT RowID
	       FROM userupdateleavebalancelog
			 WHERE OrganizationID=OLD.OrganizationID
			 AND YearValue=deleted_year
			 )
	INTO is_userupdateleavebalancelog;
	
	IF is_userupdateleavebalancelog = TRUE THEN
		
		DELETE
		FROM userupdateleavebalancelog
		WHERE OrganizationID=OLD.OrganizationID
		AND YearValue=deleted_year;
		
		CALL EXEC_userupdateleavebalancelog(OLD.OrganizationID, OLD.CreatedBy);
		
	END IF;
	
END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
