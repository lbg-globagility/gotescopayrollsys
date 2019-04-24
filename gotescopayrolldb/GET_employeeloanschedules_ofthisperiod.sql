/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `GET_employeeloanschedules_ofthisperiod`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `GET_employeeloanschedules_ofthisperiod`(
	IN `org_rowid` INT,
	IN `payperiod_rowid` INT


)
    DETERMINISTIC
BEGIN

CALL `LoanPrediction`(org_rowid);

SELECT
SUM(ii.`ProperDeductAmount`) `DeductionAmount`
, ii.EmployeeID
, ii.`Nondeductible`
FROM (SELECT i.*
		FROM loanpredict i
		WHERE i.PayperiodID=payperiod_rowid
		AND LCASE(i.`Status`) IN ('in progress', 'complete')
		AND i.DiscontinuedDate IS NULL
	UNION
		SELECT i.*
		FROM loanpredict i
		WHERE i.PayperiodID=payperiod_rowid
		AND LCASE(i.`Status`) = 'cancelled'
		AND i.DiscontinuedDate IS NOT NULL
		) ii
WHERE ii.PayperiodID=payperiod_rowid
GROUP BY ii.EmployeeID, ii.`Nondeductible`
;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
