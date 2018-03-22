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

-- Dumping structure for procedure gotescopayrolldb_server.view_employee_paystub
DROP PROCEDURE IF EXISTS `view_employee_paystub`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `view_employee_paystub`(IN `organizid` INT, IN `str_search` VARCHAR(50), IN `page_number` INT, IN `maxdisplay_count` INT, IN `is_display_last` BOOL, IN `payfreq_rowid` INT)
    DETERMINISTIC
BEGIN

IF is_display_last = TRUE THEN
	SET @proper_empcount = (SELECT COUNT(e.RowID) FROM employee e WHERE e.OrganizationID=organizid AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated'));

	SET @avg_countper_page = ROUND( (@proper_empcount / maxdisplay_count), 0);
	
	# SET page_number = (@avg_countper_page * maxdisplay_count);
	SET page_number = (@proper_empcount - (@proper_empcount MOD maxdisplay_count));
END IF;

IF LENGTH(str_search) > 0 THEN

	SELECT e.RowID
	,e.EmployeeID
	,e.LastName
	,e.FirstName
	,e.MiddleName
	,e.EmployeeType
	,e.EmploymentStatus
	,IFNULL(pos.PositionName, '') `PositionName`
	,pf.PayFrequencyType `PayFrequencyType`
	,CONCAT(CONCAT_WS(', ', e.LastName, e.FirstName, e.MiddleName)
				,'?'
				,CONCAT_WS(', ', CONCAT('ID# ', e.EmployeeID), pos.PositionName, CONCAT(e.EmployeeType, ' salary'))) `DisplayInfo`
	
	FROM (SELECT e.* FROM employee e WHERE e.EmployeeID = str_search AND e.OrganizationID=organizid
		UNION
			SELECT e.* FROM employee e WHERE e.LastName = str_search AND e.OrganizationID=organizid
		UNION
			SELECT e.* FROM employee e WHERE e.FirstName = str_search AND e.OrganizationID=organizid
		UNION
			SELECT e.* FROM employee e WHERE e.MiddleName = str_search AND e.OrganizationID=organizid
			) e
			
	LEFT JOIN `position` pos ON pos.RowID=e.PositionID
	
	INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID AND pf.RowID = IFNULL(payfreq_rowid, pf.RowID)
	
	WHERE e.OrganizationID=organizid
			AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
			
	ORDER BY CONCAT(e.LastName,e.FirstName,e.MiddleName)
	
	LIMIT page_number, maxdisplay_count;

ELSE

	SELECT e.RowID
	,e.EmployeeID
	,e.LastName
	,e.FirstName
	,e.MiddleName
	,e.EmployeeType
	,e.EmploymentStatus
	,IFNULL(pos.PositionName, '') `PositionName`
	,pf.PayFrequencyType `PayFrequencyType`
	,CONCAT(CONCAT_WS(', ', e.LastName, e.FirstName, e.MiddleName)
				,'?'
				,CONCAT_WS(', ', CONCAT('ID# ', e.EmployeeID), pos.PositionName, CONCAT(e.EmployeeType, ' salary'))) `DisplayInfo`
	
	FROM employee e
	
	LEFT JOIN `position` pos ON pos.RowID=e.PositionID
	
	INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID AND pf.RowID = IFNULL(payfreq_rowid, pf.RowID)
	
	WHERE e.OrganizationID=organizid
			AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
			
	ORDER BY CONCAT(e.LastName,e.FirstName,e.MiddleName)
	
	LIMIT page_number, maxdisplay_count;

END IF;
	
END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
