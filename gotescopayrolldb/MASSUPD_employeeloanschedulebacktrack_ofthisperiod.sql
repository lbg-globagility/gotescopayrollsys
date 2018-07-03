/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `MASSUPD_employeeloanschedulebacktrack_ofthisperiod`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `MASSUPD_employeeloanschedulebacktrack_ofthisperiod`(
	IN `og_rowid` INT,
	IN `pp_rowid` INT,
	IN `user_rowid` INT

,
	IN `loantypeid` INT



)
    DETERMINISTIC
BEGIN

DECLARE isexist, _index, _count, p_id, anyint
        , i_index, i_count
        , e_index, e_count, e_rowid, pstub_rowid INT(11) DEFAULT 0;

DECLARE loanstatus_inprogress TEXT DEFAULT 'In Progress';

SELECT COUNT(p.RowID)
FROM product p
WHERE p.OrganizationID = og_rowid
AND p.`Category` = 'Loan Type'
AND p.ActiveData = '1'
INTO _count;

SELECT COUNT(e.RowID)
FROM employee e
WHERE e.OrganizationID=og_rowid
AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
INTO e_count;

SET @has_loans = FALSE;

WHILE _index < _count DO
		
	SELECT p.RowID
	FROM product p
	WHERE p.OrganizationID = og_rowid
	AND p.`Category` = 'Loan Type'
	AND p.ActiveData = '1'
	LIMIT _index, 1
	INTO p_id;
	
	/*SET p_id = loantypeid;
	
	SET e_index = 0;
	
	WHILE e_index < e_count DO
			
		SET e_index = e_index + 1;
	END WHILE;*/
		
		/*SELECT e.RowID
		, ps.RowID
		FROM employee e
		LEFT JOIN paystub ps ON ps.EmployeeID=e.RowID AND ps.OrganizationID=e.OrganizationID AND ps.PayPeriodID=pp_rowid
		WHERE e.OrganizationID = og_rowid
		AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
		LIMIT e_index, 1
		INTO e_rowid
		     , pstub_rowid;*/
		
		SET @has_loans = EXISTS(SELECT els.RowID
		FROM employeeloanschedules els
		WHERE els.OrganizationID=og_rowid
		AND els.LoanTypeID=p_id
		AND els.PayPeriodID=pp_rowid
		AND els.PayStubID IS NOT NULL
		LIMIT 1);
	
	IF @has_loans THEN
	
	/**/SELECT els.RowID,
		INSUP_employeeloanschedulebacktrack(els.OrganizationID, user_rowid, els.EmployeeID, els.PayStubID, els.RowID, els.PayPeriodID, 0, 0, '')
		# els.OrganizationID, user_rowid, els.EmployeeID, els.PayStubID, els.RowID, els.PayPeriodID
		FROM employeeloanschedules els
		WHERE els.OrganizationID = og_rowid
		AND els.LoanTypeID = p_id
		AND els.PayPeriodID = pp_rowid
		AND els.PayStubID IS NOT NULL
		# INTO anyint, anyint
		;
		
		SET @_rowid = 0;
		SET @isnotequal = FALSE;
		SET @bal = 0.00;
		SET @decrem = 0;

		/**/INSERT INTO paystubitem(OrganizationID, Created, CreatedBy, PayStubID, ProductID, PayAmount, Undeclared)
		SELECT
			og_rowid, CURRENT_TIMESTAMP(), user_rowid, i.PayStubID, p_id
			, i.`CorrectedDeductionAmount`
			, FALSE
		FROM (SELECT
		
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
				
				, els.PayStubID
				, p.Strength `Nondeductible`
				, els.PayPeriodID
				
				FROM employeeloanschedules els
				INNER JOIN product p ON p.RowID = els.LoanTypeID AND p.RowID = p_id
				WHERE els.OrganizationID = og_rowid
				# AND els.PayPeriodID = pp_rowid
				AND IF(els.SubstituteEndDate IS NULL, els.`Status`, loanstatus_inprogress) IN (loanstatus_inprogress, 'Complete')
				/*AND els.EmployeeID = e_rowid
				AND els.PayStubID = pstub_rowid*/
				ORDER BY els.RowID, els.`Year`, els.`Month`
				) i
				WHERE i.PayStubID IS NOT NULL
				AND i.PayPeriodID = pp_rowid
		/**/ON DUPLICATE KEY UPDATE
		LastUpd=CURRENT_TIMESTAMP()
		, LastUpdBy = user_rowid
		, PayAmount = i.`CorrectedDeductionAmount`
		;
	END IF;
	
		SET _index = _index + 1;
END WHILE;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
