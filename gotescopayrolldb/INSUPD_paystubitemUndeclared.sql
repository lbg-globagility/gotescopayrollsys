/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP FUNCTION IF EXISTS `INSUPD_paystubitemUndeclared`;
DELIMITER //
CREATE FUNCTION `INSUPD_paystubitemUndeclared`(`pstubitm_RowID` INT, `pstubitm_OrganizationID` INT, `pstubitm_CreatedBy` INT, `pstubitm_LastUpdBy` INT, `pstubitm_PayStubID` INT, `pstubitm_ProductID` INT, `pstubitm_PayAmount` DECIMAL(11,2)) RETURNS int(11)
    DETERMINISTIC
BEGIN

DECLARE paypID INT(11);

DECLARE paypDateTo DATE;

DECLARE pay_fromdate DATE;

DECLARE amountloan DECIMAL(11,2);

DECLARE deductamount DECIMAL(11,2);

DECLARE selectedEmployeeID VARCHAR(100);

DECLARE psi_undeclaredID INT(11);

DECLARE SSSContribProductRowID INT(11);
		
DECLARE WeeklyPayFreqID INT(11);
		
DECLARE isWeeklySSSContribSched CHAR(1);
		
DECLARE SSSContribAmount DECIMAL(11,2);

DECLARE pstubtimID INT(11);

DECLARE pstubtimRowID INT(11);

DECLARE loan_interestID INT(11);

DECLARE _value DECIMAL(11, 2);

SELECT RowID FROM paystubitem WHERE OrganizationID=pstubitm_OrganizationID AND PayStubID=pstubitm_PayStubID AND ProductID=pstubitm_ProductID AND IFNULL(Undeclared,'0')='0' INTO pstubtimRowID;

SET @is_exists = FALSE;

SELECT
EXISTS(SELECT p.RowID
       FROM product p
		 # INNER JOIN category c ON c.RowID=p.CategoryID AND c.OrganizationID=p.OrganizationID AND c.CategoryName IN ('Deductions', 'Miscellaneous', 'Totals')
		 WHERE p.OrganizationID=pstubitm_OrganizationID
		 AND LOCATE('.', p.PartNo) = 0
		 AND p.`Category` IN ('Deductions', 'Miscellaneous', 'Totals')
		 AND p.RowID = pstubitm_ProductID
		 ORDER BY p.`Category`)
INTO @is_exists;

IF @is_exists = TRUE THEN
	
	SELECT (pstubitm_PayAmount * GET_employeeundeclaredsalarypercent(ps.EmployeeID, ps.OrganizationID, ps.PayFromDate, ps.PayToDate))
	FROM paystub ps
	WHERE ps.RowID=pstubitm_PayStubID
	INTO _value;
	
ELSE

	SET _value = pstubitm_PayAmount;

END IF;

INSERT INTO paystubitem
(
	# RowID,
	OrganizationID
	,Created
	,CreatedBy
	,PayStubID
	,ProductID
	,PayAmount
	,Undeclared
) VALUES (
	# IF(pstubitm_RowID IS NULL, pstubtimRowID, pstubitm_RowID),
	pstubitm_OrganizationID
	,CURRENT_TIMESTAMP()
	,pstubitm_CreatedBy
	,pstubitm_PayStubID
	,pstubitm_ProductID
	,_value
	,TRUE
) ON 
DUPLICATE 
KEY 
UPDATE 
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=pstubitm_LastUpdBy
	,ProductID=pstubitm_ProductID
	,PayAmount=_value
	,Undeclared=TRUE; SELECT @@Identity AS id INTO pstubtimID;
	
RETURN pstubtimID;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
