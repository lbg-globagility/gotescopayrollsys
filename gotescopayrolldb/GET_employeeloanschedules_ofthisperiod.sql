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

DECLARE loanstatus_inprogress TEXT;

SELECT TRIM(SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(ii.COLUMN_COMMENT,',',2)),',',-1))
FROM information_schema.`COLUMNS` ii
WHERE ii.TABLE_SCHEMA='gotescopayrolldb'
AND ii.COLUMN_NAME='Status'
AND ii.TABLE_NAME='employeeloanschedule'
INTO loanstatus_inprogress;

SET @_rowid = 0;
SET @isnotequal = FALSE;
SET @bal = 0.00;
SET @decrem = 0;

SELECT

	SUM(i.`CorrectedDeductionAmount`) `DeductionAmount`
	, i.EmployeeID
	, i.`Nondeductible`
	
FROM (SELECT
		# els.*
		els.EmployeeID
		
		, (@isnotequal := (@_rowid != els.RowID)) `IsNotEqual`
		
		, IF(@isnotequal
		     , (@_rowid := els.RowID)
			  , @_rowid
			  ) `CustomRowID`
		
		,IF(@isnotequal = TRUE
		    , (@bal := (els.TotalLoanAmount - els.DeductionAmount))
			 , ROUND((@bal := (@bal - els.DeductionAmount)), 6)
			 ) `RunningBalance`
		
		,IF(@isnotequal = TRUE
		    , (@decrem := els.NoOfPayPeriod - 1)
			 , (@decrem := @decrem - 1)
			 ) `DecrementNumOfPayperiod`
		
		, IF(@bal != 0 AND @decrem = 0
		     , ROUND((els.DeductionAmount + (@bal)), 6)
			  , els.DeductionAmount
			  ) `CorrectedDeductionAmount`
		
		, p.Strength `Nondeductible`
		
		FROM employeeloanschedules els
		INNER JOIN product p ON p.RowID=els.LoanTypeID
		WHERE els.OrganizationID = org_rowid
		AND els.PayPeriodID = payperiod_rowid
		AND IF(els.SubstituteEndDate IS NULL, els.`Status`, loanstatus_inprogress) IN ('In Progress', 'Complete')
		ORDER BY els.RowID, els.`Year`, els.`Month`
		) i
GROUP BY i.EmployeeID, i.`Nondeductible`
;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
