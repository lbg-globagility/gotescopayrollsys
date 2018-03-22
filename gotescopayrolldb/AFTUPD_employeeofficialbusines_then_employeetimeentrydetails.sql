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

-- Dumping structure for trigger gotescopayrolldb_server.AFTUPD_employeeofficialbusines_then_employeetimeentrydetails
DROP TRIGGER IF EXISTS `AFTUPD_employeeofficialbusines_then_employeetimeentrydetails`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `AFTUPD_employeeofficialbusines_then_employeetimeentrydetails` AFTER UPDATE ON `employeeofficialbusiness` FOR EACH ROW BEGIN



DECLARE eob_dayrange INT(11);

DECLARE prev_dayrange INT(11);

DECLARE i INT(11);

DECLARE viewID INT(11);

DECLARE etetn_RowID INT(11);

DECLARE OLD_OffBusStartDate DATE DEFAULT OLD.OffBusStartDate;

DECLARE one_datetimestamp DATETIME DEFAULT CURRENT_TIMESTAMP();

DECLARE sh_time_from
        ,sh_time_to DATETIME;

DECLARE date_from
        ,date_to DATE;

SET prev_dayrange = COALESCE(DATEDIFF(COALESCE(OLD.OffBusEndDate,OLD.OffBusStartDate),OLD.OffBusStartDate),0) + 1;

SET eob_dayrange = COALESCE(DATEDIFF(COALESCE(NEW.OffBusEndDate,NEW.OffBusStartDate),NEW.OffBusStartDate),0) + 1;

SET i=0;
	
	SELECT
	pp.PayFromDate
	, pp.PayToDate
	FROM payperiod pp
	INNER JOIN employee e
	        ON e.RowID=NEW.EmployeeID
			     AND e.PayFrequencyID=pp.TotalGrossSalary
	WHERE (pp.PayFromDate >= NEW.OffBusStartDate OR pp.PayToDate >= NEW.OffBusStartDate)
	AND (pp.PayFromDate <= NEW.OffBusEndDate OR pp.PayToDate <= NEW.OffBusEndDate)
	AND pp.OrganizationID=NEW.OrganizationID
	LIMIT 1
	INTO date_from
	     ,date_to;
	
	SELECT MIN(i.Created)
	FROM (SELECT etd.Created
	      FROM employeetimeentrydetails etd
	      WHERE etd.EmployeeID = NEW.EmployeeID
	      AND etd.OrganizationID = NEW.OrganizationID
			AND etd.`Date` BETWEEN date_from AND date_to
	      # AND etd.`Date` BETWEEN '2018-09-28' AND '2018-10-27'
	      GROUP BY etd.Created
	      ORDER BY etd.Created DESC
	      ) i
	INTO one_datetimestamp;

	IF one_datetimestamp IS NULL THEN SET one_datetimestamp = CURRENT_TIMESTAMP(); END IF;
	
IF (OLD.OffBusStatus != 'Approved' AND NEW.OffBusStatus = 'Approved')
   OR (OLD.OffBusStartTime != NEW.OffBusStartTime
	    OR OLD.OffBusEndTime != NEW.OffBusEndTime
		 OR OLD.OffBusStartDate != NEW.OffBusStartDate
		 OR OLD.OffBusEndDate != NEW.OffBusEndDate) THEN
	
	IF NEW.OffBusStatus = 'Approved' THEN
		
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
		
		SELECT CURRENT_TIMESTAMP() INTO one_datetimestamp;
		
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
			,TimeIn = IFNULL(NEW.OffBusStartTime, etd.TimeIn)
			,TimeOut = IFNULL(NEW.OffBusEndTime, etd.TimeOut);
			
	END IF;
	
ELSEIF prev_dayrange > eob_dayrange AND NEW.OffBusStatus = 'Approved' THEN

	simple_loop: LOOP
	
		IF i >= prev_dayrange THEN
			LEAVE simple_loop;
		ELSE
			
			SELECT SUM(RowID) FROM employeetimeentrydetails WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND Date=DATE_ADD(NEW.OffBusStartDate, INTERVAL i DAY) LIMIT 1 INTO etetn_RowID;
			
			IF i < eob_dayrange THEN
				UPDATE employeetimeentrydetails etd SET
				etd.LastUpd=one_datetimestamp
				,etd.LastUpdBy=NEW.LastUpdBy
				,etd.TimeIn=IFNULL(NEW.OffBusStartTime, etd.TimeIn)
				,etd.TimeOut=IFNULL(NEW.OffBusEndTime, etd.TimeOut)
				,etd.`Date`=DATE_ADD(NEW.OffBusStartDate, INTERVAL i DAY)
				,etd.TimeScheduleType='F'
				,etd.TimeEntryStatus=IF(NEW.OffBusStartTime IS NULL,'missing clock in',IF(NEW.OffBusEndTime IS NULL,'missing clock out','')) WHERE RowID=etetn_RowID;
			ELSE
				DELETE FROM employeetimeentrydetails WHERE RowID=etetn_RowID;
			END IF;
			
		END IF;
		
		SET i=i+1;
	
	END LOOP simple_loop;

ELSEIF prev_dayrange = eob_dayrange AND NEW.OffBusStatus = 'Approved' THEN

simple_loop: LOOP

	IF i >= eob_dayrange THEN
		LEAVE simple_loop;
	ELSE
		
		SELECT SUM(RowID) FROM employeetimeentrydetails WHERE EmployeeID=NEW.EmployeeID AND OrganizationID=NEW.OrganizationID AND Date=DATE_ADD(NEW.OffBusStartDate, INTERVAL i DAY) LIMIT 1 INTO etetn_RowID;
		
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
		) SELECT IFNULL(etetn_RowID, NULL)
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
			LastUpd=one_datetimestamp
			,LastUpdBy=NEW.LastUpdBy
			,TimeIn = IFNULL(NEW.OffBusStartTime, etd.TimeIn)
			,TimeOut = IFNULL(NEW.OffBusEndTime, etd.TimeOut)
			,`Date`=DATE_ADD(NEW.OffBusStartDate, INTERVAL i DAY)
			,TimeEntryStatus=IF(NEW.OffBusStartTime IS NULL,'missing clock in',IF(NEW.OffBusEndTime IS NULL,'missing clock out',''));
		
	END IF;
	
	SET i=i+1;

END LOOP simple_loop;

END IF;





SELECT RowID FROM `view` WHERE ViewName='Official Business filing' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO viewID;

IF OLD.OffBusStartTime!=NEW.OffBusStartTime THEN

INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed
) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'OffBusStartTime',NEW.RowID,OLD.OffBusStartTime,NEW.OffBusStartTime,'Update');

END IF;

IF OLD.OffBusEndTime!=NEW.OffBusEndTime THEN

INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed
) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'OffBusEndTime',NEW.RowID,OLD.OffBusEndTime,NEW.OffBusEndTime,'Update');

END IF;

IF OLD.OffBusType!=NEW.OffBusType THEN

INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed
) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'OffBusType',NEW.RowID,OLD.OffBusType,NEW.OffBusType,'Update');

END IF;

IF OLD.OffBusStartDate!=NEW.OffBusStartDate THEN

INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed
) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'OffBusStartDate',NEW.RowID,OLD.OffBusStartDate,NEW.OffBusStartDate,'Update');

END IF;

IF OLD.OffBusEndDate!=NEW.OffBusEndDate THEN

INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed
) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'OffBusEndDate',NEW.RowID,OLD.OffBusEndDate,NEW.OffBusEndDate,'Update');

END IF;

IF OLD.Reason!=NEW.Reason THEN

INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed
) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'Reason',NEW.RowID,OLD.Reason,NEW.Reason,'Update');

END IF;

IF OLD.Comments!=NEW.Comments THEN

INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed
) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'Comments',NEW.RowID,OLD.Comments,NEW.Comments,'Update');

END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
