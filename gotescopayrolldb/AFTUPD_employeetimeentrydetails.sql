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

-- Dumping structure for trigger gotescopayrolldb_server.AFTUPD_employeetimeentrydetails
DROP TRIGGER IF EXISTS `AFTUPD_employeetimeentrydetails`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `AFTUPD_employeetimeentrydetails` AFTER UPDATE ON `employeetimeentrydetails` FOR EACH ROW BEGIN

DECLARE emp_group_name VARCHAR(50);

DECLARE anyint INT(11);

DECLARE sh_timefrom TIME;

DECLARE sh_timeto TIME;

DECLARE isShiftRestDay CHAR(1);

DECLARE day_of_rest CHAR(1);

DECLARE has_already_OTapproved CHAR(1);

DECLARE au_ViewID INT(11);

DECLARE ot_status VARCHAR(50) DEFAULT 'Pending';

SELECT IFNULL(d.AutomaticOvertimeFiling,'0')
,e.DayOfRest
FROM employee e
LEFT JOIN position p ON p.RowID=e.PositionID
LEFT JOIN `division` d ON d.RowID=p.DivisionId
WHERE e.RowID=NEW.EmployeeID
INTO emp_group_name
		,day_of_rest;

IF emp_group_name = '1' THEN
	SET emp_group_name = emp_group_name;
	SET ot_status = 'Approved';
	
	SELECT sh.TimeFrom
	,sh.TimeTo
	,esh.RestDay
	FROM employeeshift esh
	INNER JOIN shift sh ON sh.RowID=esh.ShiftID
	WHERE esh.EmployeeID=NEW.EmployeeID
	AND esh.OrganizationID=NEW.OrganizationID
	AND NEW.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo
	INTO sh_timefrom
			,sh_timeto
			,isShiftRestDay;
	
	SELECT EXISTS(SELECT RowID FROM employeeovertime WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND NEW.`Date` BETWEEN OTStartDate AND OTEndDate) INTO has_already_OTapproved;

	IF isShiftRestDay IS NOT NULL && has_already_OTapproved = '0' THEN
	
		IF DAYOFWEEK(NEW.`Date`) != day_of_rest THEN
			
			IF TIME(ADDTIME(sh_timeto,'00:15:59')) < NEW.TimeOut THEN
				
				SELECT INSUPD_employeeOT(NULL,NEW.OrganizationID,NEW.CreatedBy,NEW.CreatedBy,NEW.EmployeeID,'Overtime',ADDTIME(sh_timeto,'00:00:01'),NEW.TimeOut,NEW.`Date`,NEW.`Date`,ot_status,'','',NULL) INTO anyint;
				
			END IF;
			
			IF NEW.TimeIn < SUBTIME(sh_timefrom, '00:00:01') THEN
			
				SELECT INSUPD_employeeOT(NULL,NEW.OrganizationID,NEW.CreatedBy,NEW.CreatedBy,NEW.EmployeeID,'Overtime',NEW.TimeIn,SUBTIME(sh_timefrom, '00:00:01'),NEW.`Date`,NEW.`Date`,ot_status,'','',NULL) INTO anyint;

			END IF;
			
		END IF;
		
	END IF;

END IF;

	SELECT RowID
	FROM `view`
	WHERE ViewName='Employee Time Entry Logs'
	AND OrganizationID=NEW.OrganizationID
	LIMIT 1
	INTO au_ViewID;

	SELECT INS_audittrail_RETRowID(NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,au_ViewID,'TimeIn',NEW.RowID,OLD.TimeIn,NEW.TimeIn,'Update') INTO anyint;

	SELECT INS_audittrail_RETRowID(NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,au_ViewID,'TimeOut',NEW.RowID,OLD.TimeOut,NEW.TimeOut,'Update') INTO anyint;
	
	SELECT INS_audittrail_RETRowID(NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,au_ViewID,'Date',NEW.RowID,OLD.`Date`,NEW.`Date`,'Update') INTO anyint;
	
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
