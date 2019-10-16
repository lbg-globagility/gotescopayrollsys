/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `INSUPD_paystub_proc`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSUPD_paystub_proc`(
	IN `pstub_RowID` INT,
	IN `pstub_OrganizationID` INT,
	IN `pstub_CreatedBy` INT,
	IN `pstub_LastUpdBy` INT,
	IN `pstub_PayPeriodID` INT,
	IN `pstub_EmployeeID` INT,
	IN `pstub_TimeEntryID` INT,
	IN `pstub_PayFromDate` DATE,
	IN `pstub_PayToDate` DATE,
	IN `pstub_TotalGrossSalary` DECIMAL(15,5),
	IN `pstub_TotalNetSalary` DECIMAL(15,5),
	IN `pstub_TotalTaxableSalary` DECIMAL(15,4),
	IN `pstub_TotalEmpSSS` DECIMAL(15,4),
	IN `pstub_TotalEmpWithholdingTax` DECIMAL(15,4),
	IN `pstub_TotalCompSSS` DECIMAL(15,4),
	IN `pstub_TotalEmpPhilhealth` DECIMAL(15,4),
	IN `pstub_TotalCompPhilhealth` DECIMAL(15,4),
	IN `pstub_TotalEmpHDMF` DECIMAL(15,4),
	IN `pstub_TotalCompHDMF` DECIMAL(15,4),
	IN `pstub_TotalVacationDaysLeft` DECIMAL(15,4),
	IN `pstub_TotalLoans` DECIMAL(15,4),
	IN `pstub_TotalBonus` DECIMAL(15,4),
	IN `pstub_TotalAllowance` DECIMAL(15,5),
	IN `pstub_NondeductibleTotalLoans` DECIMAL(15,4)












)
    DETERMINISTIC
BEGIN

DECLARE paystubID INT(11);

DECLARE existingrowrecord INT(11);

DECLARE isexist, _index, _count, p_id, anyint INT(11);
DECLARE i_index, i_count INT(11);

DECLARE SumPayStubAdjustments DECIMAL(15,4) DEFAULT 0;

DECLARE ps_TotalUndeclaredSalary DECIMAL(20,6) DEFAULT 0.0;
DECLARE ps_rowIDs VARCHAR(2000);

SELECT RowID FROM paystub WHERE EmployeeID=pstub_EmployeeID AND OrganizationID=pstub_OrganizationID AND PayFromDate=pstub_PayFromDate AND PayToDate=pstub_PayToDate LIMIT 1 INTO ps_rowIDs;
DELETE FROM paystubactual WHERE RowID != ps_rowIDs AND EmployeeID=pstub_EmployeeID AND OrganizationID=pstub_OrganizationID AND PayFromDate=pstub_PayFromDate AND PayToDate=pstub_PayToDate;

SELECT RowID FROM paystub WHERE PayPeriodID=pstub_PayPeriodID AND EmployeeID=pstub_EmployeeID AND OrganizationID=pstub_OrganizationID AND PayFromDate=pstub_PayFromDate AND PayToDate=pstub_PayToDate LIMIT 1 INTO existingrowrecord;


SELECT SUM(psa.PayAmount) FROM paystubadjustment psa INNER JOIN paystub ps ON ps.EmployeeID=pstub_EmployeeID AND ps.PayPeriodID=pstub_PayPeriodID AND ps.OrganizationID=psa.OrganizationID AND ps.RowID=psa.PayStubID  WHERE psa.OrganizationID=pstub_OrganizationID INTO SumPayStubAdjustments; SET SumPayStubAdjustments = IFNULL(SumPayStubAdjustments, 0);

SELECT GET_employeeundeclaredsalarypercent(pstub_EmployeeID,pstub_OrganizationID,pstub_PayFromDate,pstub_PayToDate) INTO ps_TotalUndeclaredSalary;

IF ps_TotalUndeclaredSalary < 1.0 THEN
	SET ps_TotalUndeclaredSalary = ps_TotalUndeclaredSalary + 1.000000;
ELSEIF ps_TotalUndeclaredSalary > 1.0 THEN
	SET ps_TotalUndeclaredSalary = ps_TotalUndeclaredSalary - 1.000000;
END IF;

SET ps_TotalUndeclaredSalary = CAST(ps_TotalUndeclaredSalary AS DECIMAL(11,6));

SET ps_TotalUndeclaredSalary = (pstub_TotalNetSalary + SumPayStubAdjustments) * ps_TotalUndeclaredSalary;

INSERT INTO paystub
(
	RowID
	,OrganizationID
	,Created
	,CreatedBy
	,PayPeriodID
	,EmployeeID
	,TimeEntryID
	,PayFromDate
	,PayToDate
	,TotalGrossSalary
	,TotalNetSalary
	,TotalTaxableSalary
	,TotalEmpSSS
	,TotalEmpWithholdingTax
	,TotalCompSSS
	,TotalEmpPhilhealth
	,TotalCompPhilhealth
	,TotalEmpHDMF
	,TotalCompHDMF
	,TotalVacationDaysLeft
	,TotalLoans
	,TotalBonus
	,TotalAllowance
	,TotalAdjustments
	,TotalUndeclaredSalary
	,NondeductibleTotalLoans
) VALUES (
	IF(pstub_RowID IS NULL, existingrowrecord, pstub_RowID)
	,pstub_OrganizationID
	,CURRENT_TIMESTAMP()
	,pstub_CreatedBy
	,pstub_PayPeriodID
	,pstub_EmployeeID
	,pstub_TimeEntryID
	,pstub_PayFromDate
	,pstub_PayToDate
	,pstub_TotalGrossSalary
	,pstub_TotalNetSalary + (SumPayStubAdjustments)
	,pstub_TotalTaxableSalary
	,pstub_TotalEmpSSS
	,pstub_TotalEmpWithholdingTax
	,pstub_TotalCompSSS
	,pstub_TotalEmpPhilhealth
	,pstub_TotalCompPhilhealth
	,pstub_TotalEmpHDMF
	,pstub_TotalCompHDMF
	,COALESCE((SELECT COALESCE(LeaveBalance,0) + COALESCE(SickLeaveBalance,0) + COALESCE(MaternityLeaveBalance,0) FROM employee WHERE RowID=pstub_EmployeeID),0)
	,pstub_TotalLoans
	,pstub_TotalBonus
	,pstub_TotalAllowance
	,(SumPayStubAdjustments)
	,ps_TotalUndeclaredSalary
	,pstub_NondeductibleTotalLoans
) ON 
DUPLICATE 
KEY 
UPDATE 
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=pstub_LastUpdBy
	,PayPeriodID=pstub_PayPeriodID
	,EmployeeID=pstub_EmployeeID
	,TimeEntryID=pstub_TimeEntryID
	,PayFromDate=pstub_PayFromDate
	,PayToDate=pstub_PayToDate
	,TotalGrossSalary=pstub_TotalGrossSalary-`ThirteenthMonthPay`
	,TotalNetSalary=pstub_TotalNetSalary + (SumPayStubAdjustments)
	,TotalTaxableSalary=pstub_TotalTaxableSalary
	,TotalEmpSSS=pstub_TotalEmpSSS
	,TotalEmpWithholdingTax=pstub_TotalEmpWithholdingTax
	,TotalCompSSS=pstub_TotalCompSSS
	,TotalEmpPhilhealth=pstub_TotalEmpPhilhealth
	,TotalCompPhilhealth=pstub_TotalCompPhilhealth
	,TotalEmpHDMF=pstub_TotalEmpHDMF
	,TotalCompHDMF=pstub_TotalCompHDMF
	,TotalLoans=pstub_TotalLoans
	,TotalBonus=pstub_TotalBonus
	,TotalAllowance=pstub_TotalAllowance
	,TotalAdjustments=(SumPayStubAdjustments)
	,TotalUndeclaredSalary=ps_TotalUndeclaredSalary
	,NondeductibleTotalLoans=pstub_NondeductibleTotalLoans
	,`ThirteenthMonthPay`=0;
	SELECT @@identity `Id` INTO pstub_RowID;


CALL RECOMPUTE_thirteenthmonthpay(pstub_OrganizationID, pstub_PayPeriodID, pstub_CreatedBy);

CALL INSUPD_monthlyemployeerestdaypayment(pstub_OrganizationID, pstub_EmployeeID, pstub_PayPeriodID, pstub_CreatedBy);

CALL INSUPD_paystubitemallowances(pstub_OrganizationID, pstub_EmployeeID, pstub_PayPeriodID, pstub_CreatedBy);

# CALL LEAVE_gainingbalance(pstub_OrganizationID, pstub_EmployeeID, pstub_LastUpdBy, pstub_PayFromDate, pstub_PayToDate);

# INSERT INTO paystubgeneration(OrganizationID, CreatedBy, LastUpdBy, PayPeriodID, EmployeeID, TimeEntryID, PayFromDate, PayToDate, TotalGrossSalary, TotalNetSalary, TotalTaxableSalary, TotalEmpSSS, TotalEmpWithholdingTax, TotalCompSSS, TotalEmpPhilhealth, TotalCompPhilhealth, TotalEmpHDMF, TotalCompHDMF, TotalVacationDaysLeft, TotalLoans, TotalBonus, TotalAllowance, NondeductibleTotalLoans) VALUES (pstub_OrganizationID,pstub_CreatedBy,pstub_LastUpdBy,pstub_PayPeriodID,pstub_EmployeeID,pstub_TimeEntryID,pstub_PayFromDate,pstub_PayToDate,pstub_TotalGrossSalary,pstub_TotalNetSalary,pstub_TotalTaxableSalary,pstub_TotalEmpSSS,pstub_TotalEmpWithholdingTax,pstub_TotalCompSSS,pstub_TotalEmpPhilhealth,pstub_TotalCompPhilhealth,pstub_TotalEmpHDMF,pstub_TotalCompHDMF,pstub_TotalVacationDaysLeft,pstub_TotalLoans,pstub_TotalBonus,pstub_TotalAllowance,pstub_NondeductibleTotalLoans);

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
