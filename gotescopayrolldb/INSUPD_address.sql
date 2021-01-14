/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP FUNCTION IF EXISTS `INSUPD_address`;
DELIMITER //
CREATE FUNCTION `INSUPD_address`(`ad_RowID` INT, `ad_UserRowID` INT, `ad_StreetAddress1` VARBINARY(150), `ad_StreetAddress2` VARBINARY(150), `ad_Barangay` VARBINARY(150), `ad_CityTown` VARBINARY(150), `ad_State` VARBINARY(150), `ad_Country` VARBINARY(150), `ad_ZipCode` VARBINARY(150)) RETURNS int(11)
    DETERMINISTIC
BEGIN

DECLARE returnvalue INT(11);



INSERT INTO address
(
	RowID
	,StreetAddress1
	,StreetAddress2
	,CityTown
	,Country
	,State
	,CreatedBy
	,LastUpdBy
	,Created
	,ZipCode
	,Barangay
) VALUES (
	ad_RowID
	,ad_StreetAddress1
	,ad_StreetAddress2
	,ad_CityTown
	,ad_Country
	,ad_State
	,ad_UserRowID
	,ad_UserRowID
	,CURRENT_TIMESTAMP()
	,ad_ZipCode
	,ad_Barangay
) ON
DUPLICATE
KEY
UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=ad_UserRowID
	,StreetAddress1 = ad_StreetAddress1
	,StreetAddress2 = ad_StreetAddress2
	,CityTown = ad_CityTown
	,Country = ad_Country
	,State = ad_State
	,ZipCode = ad_ZipCode
	,Barangay = ad_Barangay;SELECT @@Identity AS ID INTO returnvalue;

RETURN returnvalue;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
