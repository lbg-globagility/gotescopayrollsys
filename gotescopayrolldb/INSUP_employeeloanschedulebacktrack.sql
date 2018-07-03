/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP FUNCTION IF EXISTS `INSUP_employeeloanschedulebacktrack`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `INSUP_employeeloanschedulebacktrack`(
	`OrganizID` INT,
	`UserRowID` INT,
	`EmpRowID` INT,
	`PaystubRowID` INT,
	`LoanSchedRowID` INT,
	`LoanBalance` DECIMAL(12,6),
	`LoanPayPeriodLeft` DECIMAL(12,6),
	`AmountPerDeduct` DECIMAL(12,6),
	`Estatus` CHAR(12)









) RETURNS int(11)
    DETERMINISTIC
BEGIN

DECLARE returnvalue
        ,payperiod_rowid INT(11);

DECLARE loanstatus_inprogress TEXT;

SET payperiod_rowid = LoanBalance;

SELECT 'In Progress'
/*TRIM(SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(ii.COLUMN_COMMENT,',',2)),',',-1))
FROM information_schema.`COLUMNS` ii
WHERE ii.TABLE_SCHEMA='gotescopayrolldb'
AND ii.COLUMN_NAME='Status'
AND ii.TABLE_NAME='employeeloanschedule'*/
INTO loanstatus_inprogress;

SET @_rowid = 0;
SET @isnotequal = FALSE;
SET @bal = 0.00;
SET @decrem = 0;

INSERT INTO employeeloanschedulebacktrack
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
	
) SELECT
	OrganizID
	, UserRowID
	, i.EmployeeID
	, PaystubRowID
	, LoanSchedRowID
	, i.RunningBalance
	, i.DecrementNumOfPayperiod
	, i.CorrectedDeductionAmount
	, i.`Estatus`

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
		
		, IF(@decrem = 0
		     , 'Complete'
			  , 'In Progress'
			  ) `Estatus`
		
		, els.PayPeriodID
		
		FROM employeeloanschedules els
		WHERE els.OrganizationID = OrganizID
		# AND els.PayPeriodID = payperiod_rowid
		AND els.PayStubID = PaystubRowID
		AND els.EmployeeID = EmpRowID
		AND els.RowID = LoanSchedRowID
		AND IF(els.SubstituteEndDate IS NULL, els.`Status`, loanstatus_inprogress) IN ('In Progress', 'Complete')
		ORDER BY els.RowID, els.`Year`, els.`Month`
		) i
		WHERE i.PayPeriodID = payperiod_rowid
ON
DUPLICATE
KEY
UPDATE
	LastUpd			=CURRENT_TIMESTAMP()
	,LastUpdBy		=UserRowID
	,PayStubID		=PaystubRowID
	,Balance			=i.RunningBalance
	,DeductedAmount=i.CorrectedDeductionAmount
	,CountPayPeriodLeft=i.DecrementNumOfPayperiod
	,`Status`		=i.`Estatus`
	;
SELECT @@identity `PrimKey` INTO returnvalue;

IF returnvalue IS NULL THEN
	SET returnvalue = 0;
END IF;

RETURN returnvalue;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
