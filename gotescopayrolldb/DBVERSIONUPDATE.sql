/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `DBVERSIONUPDATE`;
DELIMITER //
CREATE PROCEDURE `DBVERSIONUPDATE`()
BEGIN

DECLARE lov_type TEXT DEFAULT 'Report List';

DECLARE new_report TEXT DEFAULT CONCAT_WS(',', 'Filed Leaves Report', 'Employee Leave Balance Summary', 'Employee Loan Summary Report');

DECLARE default_user INT(11) DEFAULT 0;

DELETE FROM listofval WHERE `Type`=lov_type; ALTER TABLE listofval AUTO_INCREMENT = 0;

INSERT INTO listofval(
	DisplayValue
	, LIC
	, `Type`
	, ParentLIC
	, Active
	, Description
	, Created
	, CreatedBy
	, LastUpd
	, OrderBy
	, LastUpdBy
) SELECT rl.ReportName
	, rl.ReportName
	, lov_type
	, ''
	, 'Yes'
	, ''
	, CURRENT_TIMESTAMP()
	, default_user
	, CURRENT_TIMESTAMP()
	, 1
	, default_user
	FROM reportlist rl
	ON DUPLICATE KEY UPDATE LastUpd=CURRENT_TIMESTAMP();

SET @is_exists = EXISTS(SELECT v.RowID FROM `view` v WHERE FIND_IN_SET(v.ViewName, new_report) > 0);

IF @is_exists = FALSE THEN

	INSERT INTO `view`(ViewName, OrganizationID)
	SELECT rl.ReportName, og.RowID
	FROM organization og
	INNER JOIN reportlist rl ON FIND_IN_SET(rl.ReportName, new_report) > 0
	ON DUPLICATE KEY UPDATE `view`.OrganizationID=og.RowID
	;

END IF;
	
INSERT INTO position_view(
	PositionID
	,ViewID
	,Creates
	,OrganizationID
	,ReadOnly
	,Updates
	,Deleting
	,Created
	,CreatedBy
	,LastUpd
	,LastUpdBy
	) SELECT pos.RowID
	, v.RowID
	, 'N'
	, v.OrganizationID
	, 'Y'
	, 'N'
	, 'N'
	, CURRENT_TIMESTAMP()
	, default_user
	, CURRENT_TIMESTAMP()
	, default_user
	FROM `view` v
	INNER JOIN `position` pos ON pos.RowID > 0
	WHERE FIND_IN_SET(v.ViewName, new_report) > 0
	ON DUPLICATE KEY UPDATE LastUpd=CURRENT_TIMESTAMP();

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
