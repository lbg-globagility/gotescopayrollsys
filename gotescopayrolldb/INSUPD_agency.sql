/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP FUNCTION IF EXISTS `INSUPD_agency`;
DELIMITER //
CREATE FUNCTION `INSUPD_agency`(`ag_RowID` INT, `ag_OrganizationID` INT, `ag_UserRowID` INT, `ag_AgencyName` VARCHAR(50), `ag_AgencyFee` DECIMAL(11,2), `ag_AddressID` INT) RETURNS int(11)
    DETERMINISTIC
BEGIN

DECLARE returnvalue INT(11);



INSERT INTO agency
(
	RowID
	,OrganizationID
	,Created
	,CreatedBy
	,LastUpdBy
	,AgencyName
	,`AgencyFee`
	,AddressID
) SELECT
	ag_RowID
	,og.RowID
	,CURRENT_TIMESTAMP()
	,ag_UserRowID
	,ag_UserRowID
	,ag_AgencyName
	,ag_AgencyFee
	,ag_AddressID
	FROM organization og
	WHERE og.RowID != ag_OrganizationID
ON
DUPLICATE
KEY
UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy = ag_UserRowID
	,AgencyName = ag_AgencyName
	,`AgencyFee` = ag_AgencyFee
	,AddressID = ag_AddressID;
	
INSERT INTO agency
(
	RowID
	,OrganizationID
	,Created
	,CreatedBy
	,LastUpdBy
	,AgencyName
	,`AgencyFee`
	,AddressID
) VALUES (
	ag_RowID
	,ag_OrganizationID
	,CURRENT_TIMESTAMP()
	,ag_UserRowID
	,ag_UserRowID
	,ag_AgencyName
	,ag_AgencyFee
	,ag_AddressID
) ON
DUPLICATE
KEY
UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=ag_UserRowID
	,AgencyName = ag_AgencyName
	,`AgencyFee` = ag_AgencyFee
	,AddressID = ag_AddressID;SELECT @@Identity AS ID INTO returnvalue;

RETURN returnvalue;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
