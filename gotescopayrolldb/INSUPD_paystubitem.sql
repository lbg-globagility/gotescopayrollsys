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

-- Dumping structure for function gotescopayrolldb_latest.INSUPD_paystubitem
DROP FUNCTION IF EXISTS `INSUPD_paystubitem`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `INSUPD_paystubitem`(`pstubitm_RowID` INT, `pstubitm_OrganizationID` INT, `pstubitm_CreatedBy` INT, `pstubitm_LastUpdBy` INT, `pstubitm_PayStubID` INT, `pstubitm_ProductID` INT, `pstubitm_PayAmount` DECIMAL(11,2)) RETURNS int(11)
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


SELECT RowID FROM paystubitem WHERE OrganizationID=pstubitm_OrganizationID AND PayStubID=pstubitm_PayStubID AND ProductID=pstubitm_ProductID AND Undeclared=FALSE INTO pstubtimRowID;

/*
INSERT INTO paystubitem
(
	RowID
	,OrganizationID
	,Created
	,CreatedBy
	,PayStubID
	,ProductID
	,PayAmount
	,Undeclared
) VALUES (
	IF(pstubitm_RowID IS NULL, pstubtimRowID, pstubitm_RowID)
	,pstubitm_OrganizationID
	,CURRENT_TIMESTAMP()
	,pstubitm_CreatedBy
	,pstubitm_PayStubID
	,pstubitm_ProductID
	,pstubitm_PayAmount
	,FALSE
) ON 
DUPLICATE 
KEY 
UPDATE 
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=pstubitm_LastUpdBy
	,ProductID=pstubitm_ProductID
	,PayAmount=pstubitm_PayAmount
	,Undeclared=FALSE; SELECT @@Identity AS id INTO pstubtimID;
*/

SET @is_exists = FALSE;

SELECT
EXISTS(SELECT p.RowID
       FROM product p
		 # INNER JOIN category c ON c.RowID=p.CategoryID AND c.OrganizationID=p.OrganizationID AND c.CategoryName IN ('Deductions', 'Miscellaneous', 'Totals')
		 WHERE p.OrganizationID = pstubitm_OrganizationID
		 AND LOCATE('.', p.PartNo) = 0
		 AND p.`Category` IN ('Deductions', 'Miscellaneous', 'Totals')
		 # Taxable Income , Withholding Tax
		 AND p.PartNo != 'Withholding Tax'
		 AND p.RowID = pstubitm_ProductID)
INTO @is_exists;

INSERT INTO paystubitem
(
	OrganizationID
	,Created
	,CreatedBy
	,PayStubID
	,ProductID
	,PayAmount
	,Undeclared
) SELECT
	pstubitm_OrganizationID
	,CURRENT_TIMESTAMP()
	,pstubitm_CreatedBy
	,pstubitm_PayStubID
	,pstubitm_ProductID
	, i.`Amount`
	, i.`Result`
  FROM (SELECT p.RowID `ProductID`
        ,pstubitm_PayAmount `Amount`
        ,FALSE `Result`
		  FROM product p
		  WHERE p.RowID=pstubitm_ProductID
		UNION
		  SELECT p.RowID `ProductID`
        ,(pstubitm_PayAmount * IF(@is_exists = TRUE, GET_employeeundeclaredsalarypercent(ps.EmployeeID, ps.OrganizationID, ps.PayFromDate, ps.PayToDate), 1))`Amount`
		  ,TRUE `Result`
		  FROM product p
		  INNER JOIN paystub ps ON ps.RowID=pstubitm_PayStubID
		  WHERE p.RowID=pstubitm_ProductID) i
ON 
DUPLICATE 
KEY 
UPDATE 
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=pstubitm_LastUpdBy
	,ProductID=pstubitm_ProductID
	,PayAmount=i.`Amount`
	,Undeclared=i.`Result`;
	
	SELECT @@Identity AS id INTO pstubtimID;
	
# SELECT INSUPD_paystubitemUndeclared(NULL, pstubitm_OrganizationID, pstubitm_CreatedBy, pstubitm_CreatedBy, pstubitm_PayStubID, pstubitm_ProductID, pstubitm_PayAmount) INTO @anyint; # pstubitm_PayAmount psi_undeclaredID 493.15

	SELECT PayPeriodID,EmployeeID,PayToDate,PayFromDate FROM paystub WHERE RowID=pstubitm_PayStubID INTO paypID,selectedEmployeeID,paypDateTo,pay_fromdate;
	
	IF pstubitm_ProductID IN (SELECT RowID FROM product WHERE `Category`='Loan Type' AND OrganizationID=pstubitm_OrganizationID) AND pstubitm_RowID IS NULL THEN
	
		SELECT DeductionPercentage,DeductionAmount FROM employeeloanschedule WHERE `Status`='In Progress' AND OrganizationID=pstubitm_OrganizationID AND EmployeeID=selectedEmployeeID AND LoanTypeID=pstubitm_ProductID AND IF(paypDateTo <= DedEffectiveDateTo, paypDateTo <= DedEffectiveDateTo, IF(paypDateTo <= DedEffectiveDateFrom, paypDateTo <= DedEffectiveDateFrom, IF(paypDateTo >= DedEffectiveDateTo, paypDateTo >= DedEffectiveDateTo, TRUE))) LIMIT 1 INTO amountloan,deductamount;
			
	SELECT RowID FROM product WHERE Category='Loan Interest' AND LastSoldCount=pstubitm_ProductID AND OrganizationID=pstubitm_OrganizationID LIMIT 1 INTO loan_interestID;

		IF loan_interestID IS NOT NULL THEN
			
			INSERT INTO paystubitem 
			(
				RowID
				,OrganizationID
				,Created
				,CreatedBy
				,PayStubID
				,ProductID
				,PayAmount
				,Undeclared
			) VALUES (
				IF(pstubitm_RowID IS NULL, pstubtimRowID, pstubitm_RowID)
				,pstubitm_OrganizationID
				,CURRENT_TIMESTAMP()
				,pstubitm_CreatedBy
				,pstubitm_PayStubID
				,loan_interestID
				,IFNULL((deductamount - (deductamount / (1 + amountloan))),0.00)
				,'0'
			) ON
			DUPLICATE
			KEY
			UPDATE
				LastUpd=CURRENT_TIMESTAMP()
				,LastUpdBy=pstubitm_LastUpdBy
				,Undeclared='0';
			
		END IF;
		
	END IF;
	
RETURN pstubtimID;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
