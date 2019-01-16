/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP FUNCTION IF EXISTS `INSUPD_position`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `INSUPD_position`(`pos_RowID` INT, `pos_PositionName` VARCHAR(50), `pos_CreatedBy` INT, `pos_OrganizationID` INT, `pos_LastUpdBy` INT, `pos_ParentPositionID` INT, `pos_DivisionId` INT) RETURNS int(11)
    DETERMINISTIC
BEGIN

DECLARE positID INT(11);	

DECLARE defaultDivisID INT(11);

DECLARE originalPositionName VARCHAR(255);

DECLARE hasId BOOLEAN DEFAULT FALSE;

SET hasId = pos_RowID IS NOT NULL;

IF hasId THEN
	SELECT pos.PositionName
	FROM `position` pos
	WHERE pos.RowID = pos_RowID
	INTO originalPositionName;
END IF;

IF USER_HAS_PRIVILEGE(pos_CreatedBy,pos_OrganizationID,VIEW_privilege('Position',pos_OrganizationID)) = '1' THEN

	INSERT INTO `position`
	(
		RowID
		,PositionName
		,Created
		,CreatedBy
		,OrganizationID
		,LastUpdBy
		,ParentPositionID
		,DivisionId
	) VALUES (
		pos_RowID
		,pos_PositionName
		,CURRENT_TIMESTAMP()
		,pos_CreatedBy
		,pos_OrganizationID
		,pos_LastUpdBy
		,pos_ParentPositionID
		,pos_DivisionId
	) ON 
	DUPLICATE 
	KEY 
	UPDATE 
		PositionName=pos_PositionName
		,LastUpd=CURRENT_TIMESTAMP()
		,LastUpdBy=pos_LastUpdBy
		,ParentPositionID=pos_ParentPositionID
		,DivisionId=pos_DivisionId; SELECT @@identity INTO positID;

	IF hasId THEN

		UPDATE `position` pos
		SET pos.PositionName = pos_PositionName
		, pos.LastUpd=IFNULL(pos.LastUpd, CURRENT_TIMESTAMP())
		, pos.LastUpdBy=IFNULL(pos.LastUpdBy, pos.CreatedBy)
		WHERE pos.OrganizationID != pos_OrganizationID
		AND pos.PositionName = originalPositionName
		;

	ELSE
	
		INSERT INTO `position`
		(	
			PositionName
			,Created
			,CreatedBy
			,OrganizationID
			,LastUpdBy
		) SELECT pos_PositionName
			, CURRENT_TIMESTAMP()
			, pos_CreatedBy
			, i.`OrgId`
			, pos_CreatedBy
		FROM (SELECT og.RowID `OrgId`
				FROM organization og
				WHERE og.RowID != pos_OrganizationID) i
		ON DUPLICATE KEY UPDATE PositionName=pos_PositionName, LastUpdBy=IFNULL(LastUpdBy, CreatedBy), LastUpd=IFNULL(LastUpd, CURRENT_TIMESTAMP());

	END IF;
	
ELSE
	CALL mysqlmsgbox('It seems that your privilege for this module has been modify. Please recheck your privilege.');
END IF;

RETURN positID;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
