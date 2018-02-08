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

-- Dumping structure for function gotescopayrolldb_latest.IS_USER_DEPTMNGR
DROP FUNCTION IF EXISTS `IS_USER_DEPTMNGR`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `IS_USER_DEPTMNGR`(`org_rowid` INT, `user_rowid` INT) RETURNS tinyint(1)
    DETERMINISTIC
BEGIN

DECLARE ee_rowid INT(11) DEFAULT NULL;

DECLARE positn_name VARCHAR(50);

/*SELECT pos.PositionName
FROM `user` u
INNER JOIN `position` pos ON pos.RowID=u.PositionID
WHERE u.RowID=user_rowid
INTO positn_name;

SELECT ee.RowID
FROM employee e
INNER JOIN `position` pos ON pos.PositionName=positn_name AND pos.OrganizationID=e.OrganizationID
INNER JOIN employee ee
        ON ee.RowID=e.DeptManager
		     AND ee.PositionID=pos.RowID
			  AND ee.OrganizationID=org_rowid
WHERE e.OrganizationID=org_rowid
LIMIT 1
INTO ee_rowid;*/

SELECT u.DeptMngrID
FROM `user` u
WHERE u.RowID=user_rowid
INTO ee_rowid;

RETURN (ee_rowid IS NOT NULL);

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
