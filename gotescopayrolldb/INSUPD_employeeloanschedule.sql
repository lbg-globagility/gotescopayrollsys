/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP FUNCTION IF EXISTS `INSUPD_employeeloanschedule`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `INSUPD_employeeloanschedule`(`els_RowID` INT, `els_OrganizID` INT, `els_UserRowID` INT, `els_EmployeeID` INT, `els_LoanNumber` VARCHAR(50), `els_DedEffectiveDateFrom` DATE, `els_DedEffectiveDateTo` DATE, `els_TotalLoanAmount` DECIMAL(11,6), `els_DeductionSchedule` VARCHAR(50), `els_TotalBalanceLeft` DECIMAL(11,6), `els_DeductionAmount` DECIMAL(11,6), `els_Status` VARCHAR(50), `els_LoanTypeID` INT, `els_DeductionPercentage` DECIMAL(11,6), `els_NoOfPayPeriod` INT, `els_LoanPayPeriodLeft` INT, `els_Comments` VARCHAR(2000), `els_ReferenceLoanID` INT) RETURNS int(11)
    DETERMINISTIC
BEGIN

DECLARE returnvalue INT(11);

DECLARE els_Nondeductible CHAR(1);

SELECT Strength FROM product WHERE RowID=els_LoanTypeID INTO els_Nondeductible;

INSERT INTO employeeloanschedule
(
	RowID
	,OrganizationID
	,Created
	,CreatedBy
	,EmployeeID
	,LoanNumber
	,DedEffectiveDateFrom
	,DedEffectiveDateTo
	,TotalLoanAmount
	,DeductionSchedule
	,TotalBalanceLeft
	,DeductionAmount
	,`Status`
	,LoanTypeID
	,DeductionPercentage
	,NoOfPayPeriod
	,LoanPayPeriodLeft
	,Comments
	,Nondeductible
	,ReferenceLoanID
) VALUES (
	els_RowID
	,els_OrganizID
	,CURRENT_TIMESTAMP()
	,els_UserRowID
	,els_EmployeeID
	,els_LoanNumber
	,els_DedEffectiveDateFrom
	,els_DedEffectiveDateTo
	,els_TotalLoanAmount
	,els_DeductionSchedule
	,els_TotalLoanAmount
	,els_DeductionAmount
	,els_Status
	,els_LoanTypeID
	,els_DeductionPercentage
	,els_NoOfPayPeriod
	,els_NoOfPayPeriod
	,IFNULL(els_Comments,'')
	,els_Nondeductible
	,els_ReferenceLoanID
) ON
DUPLICATE
KEY
UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=els_UserRowID
	,LoanNumber=els_LoanNumber
	,DedEffectiveDateFrom=els_DedEffectiveDateFrom
	,DedEffectiveDateTo=els_DedEffectiveDateTo
	,DeductionSchedule=els_DeductionSchedule
	,LoanTypeID=els_LoanTypeID
	,DeductionPercentage=els_DeductionPercentage
	,Comments=IFNULL(els_Comments,'')
	,Nondeductible=els_Nondeductible; SELECT @@Identity AS ID INTO returnvalue;

IF returnvalue IS NULL THEN
	IF els_RowID IS NULL THEN
		SET returnvalue = 0;
	ELSE
		SET returnvalue = els_RowID;
	END IF;
END IF;

RETURN returnvalue;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
