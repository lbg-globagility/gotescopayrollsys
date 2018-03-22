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

-- Dumping structure for function gotescopayrolldb_server.GET_PROPER_IMPORDATETIME
DROP FUNCTION IF EXISTS `GET_PROPER_IMPORDATETIME`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `GET_PROPER_IMPORDATETIME`(`og_rowid` INT, `e_rowid` INT, `date_from` DATE, `date_to` DATE) RETURNS datetime
    DETERMINISTIC
BEGIN

DECLARE returnvalue DATETIME;

SELECT MIN(i.Created)
FROM (SELECT ted.Created
      FROM employeetimeentrydetails ted
      
      INNER JOIN (SELECT ppd.RowID
						, ppd.PayFromDate
						, ppd.PayToDate
						FROM payperiod ppd
						INNER JOIN employee e
						        ON e.RowID = e_rowid
						           AND e.PayFrequencyID = ppd.TotalGrossSalary
						WHERE (ppd.PayFromDate >= date_from OR ppd.PayToDate >= date_from)
						AND (ppd.PayFromDate <= date_to OR ppd.PayToDate <= date_to)
						LIMIT 1
                  ) pp ON pp.RowID IS NOT NULL
      
      WHERE ted.EmployeeID = e_rowid
      AND ted.OrganizationID = og_rowid
		AND ted.`Date` BETWEEN pp.PayFromDate AND pp.PayToDate
      GROUP BY ted.Created
      ORDER BY ted.Created
      ) i
INTO returnvalue;
      
RETURN returnvalue;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
