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

-- Dumping structure for trigger gotescopayrolldb_oct19.AFTINS_employeetimeentrygeneration
DROP TRIGGER IF EXISTS `AFTINS_employeetimeentrygeneration`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `AFTINS_employeetimeentrygeneration` AFTER INSERT ON `employeeetimeentrygeneration` FOR EACH ROW BEGIN

/*CALL MASS_generate_employeetimeentry
(
	NEW.OrgRowID
	,'Semi-monthly'
	,NEW.UserRowID
	,NEW.Pay_datefrom
	,NEW.Pay_dateto
);*/

# CALL MASS_generate_employeetimeentry(1,'Semi-monthly',1,'2016-12-28','2017-01-12');

SET @existz = 0;

SELECT
	EXISTS
	(
		SELECT
			GENERATE_employeetimeentry
			(
				e.RowID
				,NEW.OrgRowID
				,d.DateValue
				,NEW.UserRowID
			)
		FROM dates d
		INNER JOIN employee e ON e.OrganizationID=NEW.OrgRowID
		INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID AND pf.PayFrequencyType='Semi-monthly'
		WHERE d.DateValue BETWEEN NEW.Pay_datefrom AND NEW.Pay_dateto
		ORDER BY e.RowID,d.DateValue
	)
INTO @existz;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
