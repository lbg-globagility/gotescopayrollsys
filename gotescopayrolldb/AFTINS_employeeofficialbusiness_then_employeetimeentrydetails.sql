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

-- Dumping structure for trigger gotescopayrolldb_server.AFTINS_employeeofficialbusiness_then_employeetimeentrydetails
DROP TRIGGER IF EXISTS `AFTINS_employeeofficialbusiness_then_employeetimeentrydetails`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `AFTINS_employeeofficialbusiness_then_employeetimeentrydetails` AFTER INSERT ON `employeeofficialbusiness` FOR EACH ROW BEGIN

DECLARE eob_dayrange INT(11);

DECLARE i INT(11) DEFAULT 0;

DECLARE etetn_RowID INT(11);

DECLARE one_datetimestamp DATETIME DEFAULT CURRENT_TIMESTAMP();

DECLARE viewID INT(11);

DECLARE sh_time_from
        ,sh_time_to DATETIME;

DECLARE date_from
        ,date_to DATE;

SET eob_dayrange = DATEDIFF(COALESCE(NEW.OffBusEndDate,NEW.OffBusStartDate),NEW.OffBusStartDate) + 1;
SET one_datetimestamp = (SELECT etd.Created FROM employeetimeentrydetails etd INNER JOIN (SELECT pp.RowID,pp.PayFromDate, pp.PayToDate FROM employee e INNER JOIN payperiod pp ON pp.TotalGrossSalary=e.PayFrequencyID AND pp.OrganizationID=e.OrganizationID AND NEW.OffBusStartDate BETWEEN pp.PayFromDate AND pp.PayToDate WHERE e.RowID=NEW.EmployeeID AND e.OrganizationID=NEW.OrganizationID LIMIT 1) i ON i.RowID IS NOT NULL OR i.RowID IS NULL WHERE etd.EmployeeID=NEW.EmployeeID AND etd.OrganizationID=NEW.OrganizationID AND etd.`Date` BETWEEN i.PayFromDate AND i.PayToDate LIMIT 1);
SET one_datetimestamp = IFNULL(one_datetimestamp,CURRENT_TIMESTAMP());
SET i=0;

	IF NEW.OffBusStatus = 'Approved' THEN
		
		SELECT
		pp.PayFromDate
		, pp.PayToDate
		FROM payperiod pp
		INNER JOIN employee e
		        ON e.RowID=NEW.EmployeeID
				     AND e.PayFrequencyID=pp.TotalGrossSalary
		WHERE (pp.PayFromDate >= NEW.OffBusStartDate OR pp.PayToDate >= NEW.OffBusStartDate)
		AND (pp.PayFromDate <= NEW.OffBusEndDate OR pp.PayToDate <= NEW.OffBusEndDate)
		LIMIT 1
		INTO date_from
		     ,date_to;
		
	SELECT CONCAT_DATETIME(NEW.OffBusStartDate, sh.TimeFrom) `ShifTimeFrom`
	,CONCAT_DATETIME(ADDDATE(NEW.OffBusStartDate, INTERVAL IS_TIMERANGE_REACHTOMORROW(sh.TimeFrom, sh.TimeTo) DAY), sh.TimeTo) `ShifTimeTo`
	FROM employeeshift esh
	LEFT JOIN shift sh ON sh.RowID=esh.ShiftID AND sh.OrganizationID=esh.OrganizationID
	WHERE esh.EmployeeID=NEW.EmployeeID
	AND esh.OrganizationID=NEW.OrganizationID
	AND (esh.EffectiveFrom >= NEW.OffBusStartDate OR esh.EffectiveTo >= NEW.OffBusStartDate)
	AND (esh.EffectiveFrom <= NEW.OffBusEndDate OR esh.EffectiveTo <= NEW.OffBusEndDate)
	LIMIT 1
	INTO sh_time_from
	     ,sh_time_to;
		
		SELECT MIN(i.Created)
		FROM (SELECT etd.Created
		      FROM employeetimeentrydetails etd
		      WHERE etd.EmployeeID = NEW.EmployeeID
		      AND etd.OrganizationID = NEW.OrganizationID
		      AND etd.`Date` BETWEEN date_from AND date_to
		      GROUP BY etd.Created
		      ORDER BY etd.Created DESC
		      ) i
		INTO one_datetimestamp;
		
		IF one_datetimestamp IS NULL THEN SET one_datetimestamp = CURRENT_TIMESTAMP(); END IF;
		
		INSERT INTO employeetimeentrydetails
		(
			RowID
			,OrganizationID
			,Created
			,CreatedBy
			,EmployeeID
			,TimeIn
			,TimeOut
			,`Date`
			,TimeScheduleType
			,TimeEntryStatus
		) SELECT etd.RowID
			,NEW.OrganizationID
			,one_datetimestamp
			,NEW.CreatedBy
			,NEW.EmployeeID
			,NEW.OffBusStartTime
			,NEW.OffBusEndTime
			,d.DateValue
			,''
			,''
			FROM dates d
			LEFT JOIN (SELECT etd.*
			            ,CONCAT_DATETIME(etd.`Date`, etd.TimeIn) `TimeStampIn`
			            ,CONCAT_DATETIME(ADDDATE(etd.`Date`, INTERVAL IS_TIMERANGE_REACHTOMORROW(etd.TimeIn, etd.TimeOut) DAY), etd.TimeOut) `TimeStampOut`
			            FROM employeetimeentrydetails etd
			            WHERE etd.OrganizationID=NEW.OrganizationID
			            AND etd.EmployeeID=NEW.EmployeeID
			            AND etd.`Date` BETWEEN NEW.OffBusStartDate AND NEW.OffBusEndDate
			            ) etd
			        ON etd.EmployeeID=NEW.EmployeeID
					     AND etd.OrganizationID=NEW.OrganizationID
						  AND etd.`Date`=d.DateValue
			WHERE d.DateValue BETWEEN NEW.OffBusStartDate AND NEW.OffBusEndDate
		ON
		DUPLICATE
		KEY
		UPDATE
			LastUpd = CURRENT_TIMESTAMP()
			,LastUpdBy = NEW.CreatedBy			
			,TimeIn = IFNULL(NEW.OffBusStartTime,etd.TimeIn)
			,TimeOut = IFNULL(NEW.OffBusEndTime,etd.TimeOut);
		
	
	
	END IF;
		
SELECT RowID FROM `view` WHERE ViewName='Official Business filing' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO viewID;

INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed
) VALUES (CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'OffBusStartTime',NEW.RowID,'',NEW.OffBusStartTime,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'OffBusEndTime',NEW.RowID,'',NEW.OffBusEndTime,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'OffBusType',NEW.RowID,'',NEW.OffBusType,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'OffBusStartDate',NEW.RowID,'',NEW.OffBusStartDate,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'OffBusEndDate',NEW.RowID,'',NEW.OffBusEndDate,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'Reason',NEW.RowID,'',NEW.Reason,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'Comments',NEW.RowID,'',NEW.Comments,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'EmployeeID',NEW.RowID,'',NEW.EmployeeID,'Insert');







END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
