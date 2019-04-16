/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `VIEW_position_view`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `VIEW_position_view`(IN `pv_OrganizationID` INT, IN `pv_PositionID` INT)
    DETERMINISTIC
BEGIN
	
	SELECT
	/*i.`pv_RowID`
	,i.`ViewName`
	,i.`Creates`
	,i.`Updates`
	,i.`Deleting`
	,i.`ReadOnly`
	,i.`vw_RowID`
	,i.`Result`*/
	i.*
	FROM (SELECT 
			pv.RowID `pv_RowID`
			,v.ViewName
			,IF(COALESCE(pv.Creates,'N')='Y',1,0) `Creates`
			,IF(COALESCE(pv.Updates,'N')='Y',1,0) `Updates`
			,IF(COALESCE(pv.Deleting,'N')='Y',1,0) `Deleting`
			,IF(COALESCE(pv.ReadOnly,'N')='Y',1,0) `ReadOnly`
			,v.RowID `vw_RowID`
			,'Report' `Result`
			FROM position_view pv
			INNER JOIN `view` v ON v.RowID=pv.ViewID # AND v.OrganizationID=pv.OrganizationID
			INNER JOIN listofval l ON l.DisplayValue=v.ViewName AND l.`Type`='Report List'
			WHERE pv.OrganizationID=pv_OrganizationID
			AND pv.PositionID=pv_PositionID
			
		UNION
			SELECT 
			pv.RowID `pv_RowID`
			,v.ViewName
			,IF(COALESCE(pv.Creates,'N')='Y',1,0) `Creates`
			,IF(COALESCE(pv.Updates,'N')='Y',1,0) `Updates`
			,IF(COALESCE(pv.Deleting,'N')='Y',1,0) `Deleting`
			,IF(COALESCE(pv.ReadOnly,'N')='Y',1,0) `ReadOnly`
			,v.RowID `vw_RowID`
			,'Non-report' `Result`
			FROM position_view pv
			INNER JOIN `view` v ON v.RowID=pv.ViewID AND v.ViewName NOT IN (SELECT l.DisplayValue
			                                                                FROM listofval l
																								 WHERE l.`Type`='Report List')
			WHERE pv.OrganizationID=pv_OrganizationID
			AND pv.PositionID=pv_PositionID
			# ORDER BY v.ViewName
			) i
	# GROUP BY i.`pv_RowID`
	ORDER BY i.`Result`, i.`ViewName`
	;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
