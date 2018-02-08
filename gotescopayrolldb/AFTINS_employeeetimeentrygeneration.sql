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

-- Dumping structure for trigger gotescopayrolldb_latest.AFTINS_employeeetimeentrygeneration
DROP TRIGGER IF EXISTS `AFTINS_employeeetimeentrygeneration`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `AFTINS_employeeetimeentrygeneration` AFTER INSERT ON `employeeetimeentrygeneration` FOR EACH ROW BEGIN

DECLARE _count
        ,indx
        ,anyint INT(11);

DECLARE _indx
        ,_anyint
        ,_anycount INT(11);

/*CALL MASS_generate_employeetimeentry
(
	NEW.OrgRowID
	,'Semi-monthly'
	,NEW.UserRowID
	,NEW.Pay_datefrom
	,NEW.Pay_dateto
);*/

# CALL MASS_generate_employeetimeentry(NEW.OrgRowID, 'Semi-monthly', NEW.UserRowID, NEW.Pay_datefrom, NEW.Pay_dateto, NEW.DivisionRowID);

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
		INNER JOIN employee e ON e.OrganizationID=NEW.OrgRowID AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
		INNER JOIN `position` pos ON pos.RowID=e.PositionID
		INNER JOIN division dv ON dv.RowID=pos.DivisionId AND dv.RowID=IFNULL(NEW.DivisionRowID, dv.RowID)
		INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID AND pf.PayFrequencyType='Semi-monthly'
		WHERE d.DateValue BETWEEN NEW.Pay_datefrom AND NEW.Pay_dateto
		ORDER BY e.RowID,d.DateValue
		# ORDER BY d.DateValue
	)
INTO @existz;

/*SET _anycount = DATEDIFF(NEW.Pay_dateto, NEW.Pay_datefrom);

SELECT COUNT(e.RowID)
FROM employee e
WHERE e.OrganizationID=NEW.OrgRowID
AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
INTO _count;

SET indx = 0;

WHILE indx < _count DO
	
	SELECT e.RowID
	FROM employee e
	WHERE e.OrganizationID=NEW.OrgRowID
	AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
	LIMIT _indx, 1
	INTO @e_rowid;

	SET _indx = 0;
	
	WHILE _indx < _anycount DO
	
		SELECT
		GENERATE_employeetimeentry
			(
				@e_rowid
				,NEW.OrgRowID
				,d.DateValue
				,NEW.UserRowID
			)
		FROM dates d
		WHERE d.DateValue BETWEEN NEW.Pay_datefrom AND NEW.Pay_dateto
		ORDER BY d.DateValue
		LIMIT _indx, 1
		INTO _anyint;
	
		SET _indx = (_indx + 1);

	END WHILE;
	
	SET indx = (indx + 1);

END WHILE;*/

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
