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




	/*SELECT#els.*,
		INSUP_employeeloanschedulebacktrack(els.OrganizationID, user_rowid, els.EmployeeID, els.PayStubRowId, els.RowID, els.PayPeriodID, 0, 0, '')
	   #, CONCAT_WS(', ', els.OrganizationID, user_rowid, els.EmployeeID, els.PayStubID, els.RowID, els.PayPeriodID, 0, 0, '') `Result`
		FROM employeeloanschedules els
		INNER JOIN product p ON p.RowID=els.LoanTypeID AND p.`Category`= 'Loan Type' AND p.ActiveData = '1'
		WHERE els.OrganizationID = og_rowid
		AND els.PayPeriodID = pp_rowid
		# AND els.PayStubID IS NOT NULL
		AND els.PayStubRowId IS NOT NULL
		;*/
		
CALL `LoanPrediction`(og_rowid)
;
/*INSERT INTO employeeloanschedulebacktrack
(
	OrganizationID
	,CreatedBy
	,EmployeeID
	,PayStubID
	,LoanschedID
	,Balance
	,CountPayPeriodLeft
	,DeductedAmount
	,`Status`
	
)*/ SELECT og_rowid
	, user_rowid
	, ii.EmployeeID
	, ii.`PaystubPrimaID`
	, ii.RowID
	, ii.LoanBalance
#	, ROUND((ii.LoanBalance / ii.TotalLoanAmount) * ii.NoOfPayPeriod, 2)
	, (ii.NoOfPayPeriod - ii.OrdinalIndex)
#	, ii.DeductionAmount
	, ii.ProperDeductAmount
	, ii.`Status`
	FROM (SELECT i.*
			, ps.RowID `PaystubPrimaID`
			FROM loanpredict i
			LEFT JOIN paystub ps ON ps.EmployeeID=i.EmployeeID AND ps.PayPeriodID=i.PayPeriodID AND ps.OrganizationID=i.OrganizationID
			WHERE i.PayPeriodID = pp_rowid
			AND i.OrganizationID = og_rowid
			AND i.LoanTypeID = IFNULL(loantypeid, i.LoanTypeID)
			) ii
/*	WHERE ii.`PaystubPrimaID` IS NOT NULL
ON DUPLICATE KEY UPDATE
	LastUpd = CURRENT_TIMESTAMP()
	,LastUpdBy = user_rowid
	,PayStubID = ii.`PaystubPrimaID`
	,LoanschedID = ii.RowID
	,Balance = ii.LoanBalance
#	,CountPayPeriodLeft = ROUND((ii.LoanBalance / ii.TotalLoanAmount) * ii.NoOfPayPeriod, 2)
	,CountPayPeriodLeft = (ii.NoOfPayPeriod - ii.OrdinalIndex)
	,DeductedAmount = ii.ProperDeductAmount
	,`Status` = ii.`Status`*/
;

/*

*/

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
