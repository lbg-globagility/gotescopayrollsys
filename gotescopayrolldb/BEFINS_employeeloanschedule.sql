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

-- Dumping structure for trigger gotescopayrolldb_oct19.BEFINS_employeeloanschedule
DROP TRIGGER IF EXISTS `BEFINS_employeeloanschedule`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `BEFINS_employeeloanschedule` BEFORE INSERT ON `employeeloanschedule` FOR EACH ROW BEGIN

DECLARE myText TEXT DEFAULT 'Loan number already exists, please input another loan number.';

DECLARE specialty CONDITION FOR SQLSTATE '45000';

DECLARE loannumexist CHAR(1);

SELECT EXISTS(SELECT RowID FROM employeeloanschedule WHERE LoanNumber=NEW.LoanNumber AND OrganizationID=NEW.OrganizationID AND EmployeeID=NEW.EmployeeID AND RowID IS NULL LIMIT 1) INTO loannumexist;

IF loannumexist = '1' THEN

	SIGNAL specialty SET MESSAGE_TEXT = myText;

END IF;

IF NEW.Comments IS NULL THEN
	SET NEW.Comments = '';
END IF;

SET NEW.DedEffectiveDateTo = PAYTODATE_OF_NoOfPayPeriod(NEW.DedEffectiveDateFrom
										,NEW.NoOfPayPeriod
										,NEW.EmployeeID
										,NEW.DeductionSchedule);

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
