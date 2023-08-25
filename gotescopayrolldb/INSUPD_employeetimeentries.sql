/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP FUNCTION IF EXISTS `INSUPD_employeetimeentries`;
DELIMITER //
CREATE FUNCTION `INSUPD_employeetimeentries`(
	`etent_RowID` INT,
	`etent_OrganizationID` INT,
	`etent_CreatedBy` INT,
	`etent_LastUpdBy` INT,
	`etent_Date` DATE,
	`etent_EmployeeShiftID` INT,
	`etent_EmployeeID` INT,
	`etent_EmployeeSalaryID` INT,
	`etent_EmployeeFixedSalaryFlag` CHAR(50),
	`etent_RegularHoursWorked` DECIMAL(11,6),
	`etent_OvertimeHoursWorked` DECIMAL(11,6),
	`etent_UndertimeHours` DECIMAL(11,6),
	`etent_NightDifferentialHours` DECIMAL(11,6),
	`etent_NightDifferentialOTHours` DECIMAL(11,6),
	`etent_HoursLate` DECIMAL(11,6),
	`etent_PayRateID` INT,
	`etent_TotalDayPay` DECIMAL(11,6),
	`etent_TotalHoursWorked` DECIMAL(11,6),
	`etent_RegularHoursAmount` DECIMAL(11,6),
	`etent_OvertimeHoursAmount` DECIMAL(11,6),
	`etent_UndertimeHoursAmount` DECIMAL(11,6),
	`etent_NightDiffHoursAmount` DECIMAL(11,6),
	`etent_NightDiffOTHoursAmount` DECIMAL(11,6),
	`etent_HoursLateAmount` DECIMAL(11,6),
	`leavePayment` DECIMAL(11,6),
	`isSetRestdayToAbsent` TINYINT
) RETURNS int(11)
    DETERMINISTIC
BEGIN

DECLARE etentID INT(11);

DECLARE is_valid_for_holipayment BOOL DEFAULT FALSE;

DECLARE default_payrate DECIMAL(11,4) DEFAULT 1.0;

SET @specialNonWorkingHoliday = 'Special Non-Working Holiday';
SET @legalHoliday = 'Regular Holiday';

SELECT EXISTS(SELECT pr.RowID
					FROM payrate pr
					INNER JOIN employee e ON e.RowID = etent_EmployeeID AND e.CalcSpecialHoliday = TRUE AND e.EmployeeType IN ('Daily', 'Monthly')
					WHERE pr.RowID = etent_PayRateID
					AND pr.PayType = @specialNonWorkingHoliday
					AND IS_WORKINGDAY_PRESENT_DURINGHOLI(pr.OrganizationID, e.RowID, pr.`Date`, TRUE) = TRUE
					
				/*UNION
					SELECT pr.RowID
					FROM payrate pr
					INNER JOIN employee e ON e.RowID = etent_EmployeeID AND e.CalcSpecialHoliday = TRUE AND e.EmployeeType='Monthly'
					WHERE pr.RowID = etent_PayRateID
					AND pr.PayType = @specialNonWorkingHoliday*/
					
				UNION
					SELECT pr.RowID
					FROM payrate pr
					INNER JOIN employee e ON e.RowID = etent_EmployeeID AND e.CalcHoliday = TRUE
					WHERE pr.RowID = etent_PayRateID
					AND pr.PayType = @legalHoliday
					AND IS_WORKINGDAY_PRESENT_DURINGHOLI(pr.OrganizationID, e.RowID, pr.`Date`, TRUE) = TRUE
					)
INTO is_valid_for_holipayment;

SET is_valid_for_holipayment = IFNULL(is_valid_for_holipayment,FALSE);

INSERT INTO employeetimeentry 
(
	# RowID,
	OrganizationID
	,Created
	,CreatedBy
	,LastUpdBy
	,`Date`
	,EmployeeShiftID
	,EmployeeID
	,EmployeeSalaryID
	,EmployeeFixedSalaryFlag
	,TotalHoursWorked
	,RegularHoursWorked
	,RegularHoursAmount
	,OvertimeHoursWorked
	,OvertimeHoursAmount
	,UndertimeHours
	,HoursUndertime
	,UndertimeHoursAmount
	,NightDifferentialHours
	,NightDiffHoursAmount
	,NightDifferentialOTHours
	,NightDiffOTHoursAmount
	,HoursLate
	,HoursTardy
	,HoursLateAmount
	,LateFlag
	,PayRateID
	,TotalDayPay
	,IsValidForHolidayPayment
	,`IsSetRestdayToAbsent`
) VALUES (
	# etent_RowID,
	etent_OrganizationID
	,CURRENT_TIMESTAMP()
	,etent_CreatedBy
	,etent_CreatedBy
	,etent_Date
	,etent_EmployeeShiftID
	,etent_EmployeeID
	,etent_EmployeeSalaryID
	,etent_EmployeeFixedSalaryFlag
	,etent_TotalHoursWorked
	,etent_RegularHoursWorked
	,	etent_RegularHoursAmount
	,etent_OvertimeHoursWorked
	,	etent_OvertimeHoursAmount
	,etent_UndertimeHours
	,etent_UndertimeHours
	,	etent_UndertimeHoursAmount
	,etent_NightDifferentialHours
	,	etent_NightDiffHoursAmount
	,etent_NightDifferentialOTHours
	,	etent_NightDiffOTHoursAmount
	,etent_HoursLate
	,etent_HoursLate
	,	etent_HoursLateAmount
	,IF(etent_HoursLateAmount = 0, '0', '1')
	,etent_PayRateID
	# ,	etent_TotalDayPay
	, IF((etent_RegularHoursAmount + etent_OvertimeHoursAmount + etent_NightDiffHoursAmount + etent_NightDiffOTHoursAmount) = 0
	     , etent_TotalDayPay + etent_NightDiffOTHoursAmount
	     , (etent_RegularHoursAmount + etent_OvertimeHoursAmount + etent_NightDiffHoursAmount + etent_NightDiffOTHoursAmount + leavePayment))
	,is_valid_for_holipayment
	,isSetRestdayToAbsent
) ON 
DUPLICATE 
KEY 
UPDATE 
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=etent_LastUpdBy
	,TotalHoursWorked = etent_TotalHoursWorked
	,RegularHoursWorked = etent_RegularHoursWorked
	,RegularHoursAmount = etent_RegularHoursAmount
	,OvertimeHoursWorked = etent_OvertimeHoursWorked
	,OvertimeHoursAmount = etent_OvertimeHoursAmount
	,UndertimeHours = etent_UndertimeHours
	,HoursUndertime=etent_UndertimeHours
	,UndertimeHoursAmount = etent_UndertimeHoursAmount
	,NightDifferentialHours = etent_NightDifferentialHours
	,NightDiffHoursAmount = etent_NightDiffHoursAmount
	,NightDifferentialOTHours = etent_NightDifferentialOTHours
	,NightDiffOTHoursAmount = etent_NightDiffOTHoursAmount
	,HoursLate = etent_HoursLate
	,HoursTardy = etent_HoursLate
	,HoursLateAmount = etent_HoursLateAmount
	,LateFlag = IF(etent_HoursLateAmount = 0, '0', '1')
	# ,TotalDayPay = etent_TotalDayPay
	,TotalDayPay = IF((etent_RegularHoursAmount + etent_OvertimeHoursAmount + etent_NightDiffHoursAmount + etent_NightDiffOTHoursAmount) = 0
	     , etent_TotalDayPay + etent_NightDiffOTHoursAmount
	     , (etent_RegularHoursAmount + etent_OvertimeHoursAmount + etent_NightDiffHoursAmount + etent_NightDiffOTHoursAmount + leavePayment))
	     
	,EmployeeShiftID = etent_EmployeeShiftID
	,EmployeeSalaryID=etent_EmployeeSalaryID
	,IsValidForHolidayPayment=is_valid_for_holipayment
	,`IsSetRestdayToAbsent`=isSetRestdayToAbsent;SELECT @@Identity AS id INTO etentID;
	
RETURN etentID;

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
