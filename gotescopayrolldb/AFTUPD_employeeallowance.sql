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

-- Dumping structure for trigger gotescopayrolldb_server.AFTUPD_employeeallowance
DROP TRIGGER IF EXISTS `AFTUPD_employeeallowance`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `AFTUPD_employeeallowance` AFTER UPDATE ON `employeeallowance` FOR EACH ROW BEGIN

DECLARE viewID INT(11);

DECLARE totalAllowancePerDay DECIMAL(11,2) DEFAULT 0;

DECLARE empPaymentType TEXT;

DECLARE empWorkDaysPerYear DECIMAL(11,2);

DECLARE ag_RowID INT(11);


SELECT e.AgencyID FROM employee e WHERE e.EmployeeID=NEW.EmployeeID INTO ag_RowID;

SELECT RowID FROM `view` WHERE ViewName='Employee Allowance' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO viewID;




IF NEW.TaxableFlag = '1' THEN
	
	SELECT e.EmployeeType,e.WorkDaysPerYear FROM employee e WHERE e.RowID=NEW.EmployeeID INTO empPaymentType,empWorkDaysPerYear;

	SELECT GET_employeeallowancePerDay(NEW.OrganizationID,NEW.EmployeeID,NEW.TaxableFlag,CURDATE()) INTO totalAllowancePerDay;
	
	
	
		SET empWorkDaysPerYear = ROUND(empWorkDaysPerYear / 12, 0);
	
		SET totalAllowancePerDay = totalAllowancePerDay * empWorkDaysPerYear;
	
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

ELSE

		UPDATE employeesalary es
		INNER JOIN employee e ON e.RowID=es.EmployeeID
		LEFT JOIN paysocialsecurity sss
		       ON IF(e.EmployeeType = 'Daily', (es.BasicPay * (e.WorkDaysPerYear / 12)), es.Salary)
				    BETWEEN sss.RangeFromAmount AND sss.RangeToAmount
		
		LEFT JOIN payphilhealth phh
		       ON IF(e.EmployeeType = 'Daily', (es.BasicPay * (e.WorkDaysPerYear / 12)), es.Salary)
				    BETWEEN phh.SalaryRangeFrom AND phh.SalaryRangeTo
		
		SET
		es.PaySocialSecurityID=sss.RowID
		,es.PayPhilhealthID=phh.RowID
		,es.LastUpdBy=NEW.CreatedBy
		WHERE es.EmployeeID=NEW.EmployeeID
		AND es.OrganizationID=NEW.OrganizationID
		AND (es.EffectiveDateFrom >= NEW.EffectiveStartDate
		     OR IFNULL(es.EffectiveDateTo, ADDDATE(es.EffectiveDateFrom, INTERVAL 99 YEAR)) >= NEW.EffectiveStartDate)
		AND (es.EffectiveDateFrom <= NEW.EffectiveEndDate
		     OR IFNULL(es.EffectiveDateTo, ADDDATE(es.EffectiveDateFrom, INTERVAL 99 YEAR)) <= NEW.EffectiveEndDate);
		
END IF;


IF OLD.ProductID!=NEW.ProductID THEN

	INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed
) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'ProductID',NEW.RowID,OLD.ProductID,NEW.ProductID,'Update');

END IF;

IF OLD.AllowanceFrequency!=NEW.AllowanceFrequency THEN

	INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed
) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'AllowanceFrequency',NEW.RowID,OLD.AllowanceFrequency,NEW.AllowanceFrequency,'Update');

END IF;

IF OLD.EffectiveStartDate!=NEW.EffectiveStartDate THEN

	INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed
) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'EffectiveStartDate',NEW.RowID,OLD.EffectiveStartDate,NEW.EffectiveStartDate,'Update');

END IF;

IF OLD.EffectiveEndDate!=NEW.EffectiveEndDate THEN

	INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed
) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'EffectiveEndDate',NEW.RowID,OLD.EffectiveEndDate,NEW.EffectiveEndDate,'Update');

END IF;

IF OLD.TaxableFlag!=NEW.TaxableFlag THEN

	INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed
) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'TaxableFlag',NEW.RowID,OLD.TaxableFlag,NEW.TaxableFlag,'Update');

END IF;

IF OLD.AllowanceAmount!=NEW.AllowanceAmount THEN

	INSERT INTO audittrail (Created,CreatedBy,LastUpdBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed
) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'AllowanceAmount',NEW.RowID,OLD.AllowanceAmount,NEW.AllowanceAmount,'Update');

END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
