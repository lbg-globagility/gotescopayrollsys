-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.5.5-10.0.12-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             8.3.0.4694
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for trigger gotescopayrolldb_server.AFTINS_employeeallowance
DROP TRIGGER IF EXISTS `AFTINS_employeeallowance`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `AFTINS_employeeallowance` AFTER INSERT ON `employeeallowance` FOR EACH ROW BEGIN



DECLARE viewID INT(11);

DECLARE totalAllowancePerDay DECIMAL(11,2) DEFAULT 0;

DECLARE empPaymentType TEXT;

DECLARE empWorkDaysPerYear DECIMAL(11,2);

DECLARE ag_RowID INT(11);

SELECT e.AgencyID FROM employee e WHERE e.EmployeeID=NEW.EmployeeID INTO ag_RowID;


IF NEW.TaxableFlag = '1' THEN
	
	SELECT e.EmployeeType,e.WorkDaysPerYear FROM employee e WHERE e.RowID=NEW.EmployeeID INTO empPaymentType,empWorkDaysPerYear;

	SELECT GET_employeeallowancePerDay(NEW.OrganizationID,NEW.EmployeeID,NEW.TaxableFlag,CURDATE()) INTO totalAllowancePerDay;
	
	
	
		SET empWorkDaysPerYear = ROUND(empWorkDaysPerYear / 12, 4);
	
		SET totalAllowancePerDay = empWorkDaysPerYear * totalAllowancePerDay;
	
	IF empPaymentType IN ('Fixed','Monthly') THEN
	
		IF NEW.AllowanceFrequency = 'Semi-monthly' THEN
			
			UPDATE employeesalary es SET
			es.PaySocialSecurityID=(SELECT RowID FROM paysocialsecurity WHERE (es.Salary + (NEW.AllowanceAmount * 2.0)) BETWEEN RangeFromAmount AND RangeToAmount AND es.OverrideDiscardSSSContrib = 0)
			,es.PayPhilhealthID=(SELECT RowID FROM payphilhealth WHERE (es.Salary + (NEW.AllowanceAmount * 2.0)) BETWEEN SalaryRangeFrom AND SalaryRangeTo AND es.OverrideDiscardPhilHealthContrib = 0)
			,es.LastUpdBy=NEW.CreatedBy
			WHERE es.EmployeeID=NEW.EmployeeID
			AND es.OrganizationID=NEW.OrganizationID
			AND (es.EffectiveDateFrom >= NEW.EffectiveStartDate OR IFNULL(es.EffectiveDateTo,NEW.EffectiveEndDate) >= NEW.EffectiveStartDate)
			AND (es.EffectiveDateFrom <= NEW.EffectiveEndDate OR IFNULL(es.EffectiveDateTo,NEW.EffectiveEndDate) <= NEW.EffectiveEndDate);
			
		ELSEIF NEW.AllowanceFrequency = 'Daily' THEN
		
			UPDATE employeesalary es SET
			es.PaySocialSecurityID=(SELECT RowID FROM paysocialsecurity WHERE (es.Salary + totalAllowancePerDay) BETWEEN RangeFromAmount AND RangeToAmount AND es.OverrideDiscardSSSContrib = 0)
			,es.PayPhilhealthID=(SELECT RowID FROM payphilhealth WHERE (es.Salary + totalAllowancePerDay) BETWEEN SalaryRangeFrom AND SalaryRangeTo AND es.OverrideDiscardPhilHealthContrib = 0)
			,es.LastUpdBy=NEW.CreatedBy
			WHERE es.EmployeeID=NEW.EmployeeID
			AND es.OrganizationID=NEW.OrganizationID
			AND (es.EffectiveDateFrom >= NEW.EffectiveStartDate OR IFNULL(es.EffectiveDateTo,NEW.EffectiveEndDate) >= NEW.EffectiveStartDate)
			AND (es.EffectiveDateFrom <= NEW.EffectiveEndDate OR IFNULL(es.EffectiveDateTo,NEW.EffectiveEndDate) <= NEW.EffectiveEndDate);
		
		END IF;
		
	ELSEIF empPaymentType = 'Daily' THEN
	
		UPDATE employeesalary es SET
		es.PaySocialSecurityID=(SELECT RowID FROM paysocialsecurity WHERE (es.BasicPay * empWorkDaysPerYear) + totalAllowancePerDay BETWEEN RangeFromAmount AND RangeToAmount AND es.OverrideDiscardSSSContrib = 0 LIMIT 1)
		,es.LastUpdBy=NEW.CreatedBy
		WHERE es.EmployeeID=NEW.EmployeeID
		AND es.OrganizationID=NEW.OrganizationID
		AND es.EffectiveDateTo IS NULL;
	
		
		
	ELSEIF empPaymentType = 'Hourly' THEN
	
		UPDATE employeesalary es SET
		es.PaySocialSecurityID=(SELECT RowID FROM paysocialsecurity WHERE es.BasicPay + totalAllowancePerDay BETWEEN RangeFromAmount AND RangeToAmount AND es.OverrideDiscardSSSContrib = 0 LIMIT 1)
		,es.LastUpdBy=NEW.CreatedBy
		WHERE es.EmployeeID=NEW.EmployeeID
		AND es.OrganizationID=NEW.OrganizationID
		AND es.EffectiveDateTo IS NULL;
	
		
		
	END IF;

END IF;



SELECT RowID FROM `view` WHERE ViewName='Employee Allowance' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO viewID;

INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed
) VALUES (CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'EmployeeID',NEW.RowID,'',NEW.EmployeeID,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'ProductID',NEW.RowID,'',NEW.ProductID,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'AllowanceFrequency',NEW.RowID,'',NEW.AllowanceFrequency,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'EffectiveStartDate',NEW.RowID,'',NEW.EffectiveStartDate,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'EffectiveEndDate',NEW.RowID,'',NEW.EffectiveEndDate,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'TaxableFlag',NEW.RowID,'',NEW.TaxableFlag,'Insert')
,(CURRENT_TIMESTAMP(),NEW.CreatedBy,NEW.CreatedBy,NEW.OrganizationID,viewID,'AllowanceAmount',NEW.RowID,'',NEW.AllowanceAmount,'Insert');




END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
