/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP TRIGGER IF EXISTS `AFTUPD_position`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `AFTUPD_position` AFTER UPDATE ON `position` FOR EACH ROW BEGIN

DECLARE viewID INT(11);

SELECT RowID FROM `view` WHERE ViewName='Position' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO viewID;

IF OLD.PositionName != NEW.PositionName THEN

INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'PositionName',NEW.RowID,OLD.PositionName,NEW.PositionName,'Update');

END IF;

IF OLD.ParentPositionID != NEW.ParentPositionID THEN

INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'ParentPositionID',NEW.RowID,OLD.ParentPositionID,NEW.ParentPositionID,'Update');

END IF;

IF OLD.DivisionId != NEW.DivisionId THEN

INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'DivisionId',NEW.RowID,OLD.DivisionId,NEW.DivisionId,'Update');

END IF;

INSERT INTO position_view
(
	PositionID
	,ViewID
	,Creates
	,OrganizationID
	,ReadOnly
	,Updates
	,Deleting
	,Created
	,CreatedBy
	,LastUpdBy
) SELECT 
	NEW.RowID
	,v.RowID
	,'N'
	,v.OrganizationID
	,'Y'
	,'N'
	,'N'
	,CURRENT_TIMESTAMP()
	,NEW.CreatedBy
	,NEW.CreatedBy
	FROM `view` v
ON
DUPLICATE
KEY
UPDATE
	LastUpd=CURRENT_TIMESTAMP();

IF NEW.DivisionId IS NOT NULL THEN
	
	IF OLD.DivisionId != NEW.DivisionId THEN
	
		UPDATE employeetimeentrydetails etd INNER JOIN position pos ON pos.OrganizationID=NEW.OrganizationID AND pos.DivisionId=NEW.DivisionId INNER JOIN `division` d ON d.RowID=pos.DivisionId AND d.AutomaticOvertimeFiling='1' AND d.OrganizationID=pos.OrganizationID INNER JOIN employee e ON e.OrganizationID=pos.OrganizationID AND e.PositionID=pos.RowID AND e.RowID=etd.EmployeeID SET etd.LastUpd=TIMESTAMPADD(SECOND,1,etd.LastUpd) WHERE etd.EmployeeID=e.RowID AND etd.OrganizationID=NEW.OrganizationID;
		
	END IF;
		
END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
