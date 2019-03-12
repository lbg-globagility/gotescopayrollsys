/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP FUNCTION IF EXISTS `INSUPD_position_view`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `INSUPD_position_view`(`pv_RowID` INT, `pv_PositionID` INT, `pv_OrganizationID` INT, `pv_CreatedBy` INT, `pv_LastUpdBy` INT, `pv_ViewID` INT, `pv_Creates` CHAR(1), `pv_ReadOnly` CHAR(1), `pv_Updates` CHAR(1), `pv_Deleting` CHAR(1)) RETURNS int(11)
    DETERMINISTIC
BEGIN

DECLARE pvRowID INT(11);

DECLARE strView TEXT;

INSERT INTO position_view
(
	RowID
	,PositionID
	,ViewID
	,Creates
	,OrganizationID
	,ReadOnly
	,Updates
	,Deleting
	,Created
	,CreatedBy
	,LastUpdBy
) VALUES (
	pv_RowID
	,pv_PositionID
	,pv_ViewID
	,pv_Creates
	,pv_OrganizationID
	,pv_ReadOnly
	,pv_Updates
	,pv_Deleting
	,CURRENT_TIMESTAMP()
	,pv_CreatedBy
	,pv_CreatedBy
) ON
DUPLICATE
KEY
UPDATE 
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=pv_LastUpdBy
	,Creates=pv_Creates
	,ReadOnly=pv_ReadOnly
	,Updates=pv_Updates
	,Deleting=pv_Deleting;SELECT @@Identity AS id INTO pvRowID;

SET @jobPositionName = '';

SELECT PositionName FROM `position` WHERE RowID=pv_PositionID INTO @jobPositionName;

UPDATE position_view pv
INNER JOIN `position` pos ON pos.RowID=pv.PositionID AND pos.PositionName=@jobPositionName
SET pv.Creates=pv_Creates
, pv.Updates=pv_Updates
, pv.Deleting=pv_Deleting
, pv.ReadOnly=pv_ReadOnly
, pv.LastUpd=CURRENT_TIMESTAMP()
, pv.LastUpdBy=IFNULL(pv.LastUpdBy, pv.CreatedBy)
WHERE NOT pv.PositionID = pv_PositionID
AND pv.ViewID=pv_ViewID
;

RETURN pvRowID;



END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
