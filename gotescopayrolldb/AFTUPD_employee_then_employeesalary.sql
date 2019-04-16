/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP TRIGGER IF EXISTS `AFTUPD_employee_then_employeesalary`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `AFTUPD_employee_then_employeesalary` AFTER UPDATE ON `employee` FOR EACH ROW BEGIN

DECLARE empBasicPay DECIMAL(11,2);

DECLARE marit_stat CHAR(10);

DECLARE lastdate DATE;

DECLARE prevesalRowID INT(11);

DECLARE thebasicpay DECIMAL(11,2) DEFAULT 0;

DECLARE thedailypay DECIMAL(11,2) DEFAULT 0;

DECLARE thehourlypay DECIMAL(11,2) DEFAULT 0;

DECLARE psssID INT(11);

DECLARE phhID INT(11);

DECLARE preEffDateFromEmpSal DATE DEFAULT CURRENT_DATE();

DECLARE preEffDateFromEmpSallatest DATE DEFAULT CURRENT_DATE();

DECLARE preEffDateToEmpSallatest DATE DEFAULT CURRENT_DATE();

DECLARE emp_chklist_ID INT(11);

DECLARE viewID INT(11);

DECLARE emp_fullmonthsalary DECIMAL(11,2) DEFAULT 0;

DECLARE current_salaryeffectivedate DATE DEFAULT CURRENT_DATE();

DECLARE emp_everydayallowance DECIMAL(11,2) DEFAULT 0;

DECLARE NEW_agency_name VARCHAR(100);

DECLARE OLD_agency_name VARCHAR(100);

DECLARE NEW_agfee DECIMAL(11,2) DEFAULT 0;

DECLARE OLD_agfee DECIMAL(11,2) DEFAULT 0;

DECLARE agfee_percent DECIMAL(11,2) DEFAULT 0;

DECLARE anyint INT(11);

DECLARE month_count INT(11) DEFAULT MONTH(SUBDATE(MAKEDATE(YEAR(CURDATE()),1), INTERVAL 1 DAY));


IF NEW.NoOfDependents != OLD.NoOfDependents OR NEW.MaritalStatus != COALESCE(OLD.MaritalStatus,'') THEN

	IF NEW.EmploymentStatus NOT IN ('Resigned','Terminated') THEN
	
		SELECT IF(NEW.MaritalStatus IN ('Single','Married'),NEW.MaritalStatus,'Zero') INTO marit_stat;
		
		
		
		SELECT RowID,Salary,EffectiveDateFrom FROM employeesalary WHERE EmployeeID=NEW.RowID AND OrganizationID=NEW.OrganizationID AND EffectiveDateTo IS NULL ORDER BY DATEDIFF(DATE_FORMAT(NOW(),'%Y-%m-%d'),EffectiveDateFrom) LIMIT 1 INTO prevesalRowID,empBasicPay,preEffDateFromEmpSal;
		
			SELECT RowID FROM payphilhealth WHERE COALESCE(empBasicPay,0) BETWEEN SalaryRangeFrom AND IF(COALESCE(empBasicPay,0) > SalaryRangeTo, COALESCE(empBasicPay,0) + 1, SalaryRangeTo) ORDER BY SalaryBase DESC LIMIT 1 INTO phhID;
			
			
			
		IF NEW.EmployeeType IN ('Fixed','Monthly') THEN
			IF NEW.PayFrequencyID=1 THEN
				SET thebasicpay = empBasicPay / 2;
				SET thedailypay = 0;
				SET thehourlypay = 0;
			ELSE
				SET thebasicpay = empBasicPay;
				SET thedailypay = 0;
				SET thehourlypay = 0;
			END IF;
			
			SELECT RowID FROM paysocialsecurity WHERE COALESCE(empBasicPay,0) BETWEEN RangeFromAmount AND IF(COALESCE(thebasicpay,0) > RangeToAmount, COALESCE(thebasicpay,0) + 1, RangeToAmount) ORDER BY MonthlySalaryCredit DESC LIMIT 1 INTO psssID;
			
		ELSEIF NEW.EmployeeType = 'Daily' THEN
				SET thebasicpay = empBasicPay;
				SET thedailypay = empBasicPay;
				SET thehourlypay = 0;
				
			SELECT RowID FROM paysocialsecurity WHERE COALESCE(thedailypay,0) BETWEEN RangeFromAmount AND IF(COALESCE(thebasicpay,0) > RangeToAmount, COALESCE(thebasicpay,0) + 1, RangeToAmount) ORDER BY MonthlySalaryCredit DESC LIMIT 1 INTO psssID;
			
		ELSEIF NEW.EmployeeType = 'Hourly' THEN
				SET thebasicpay = empBasicPay;
				SET thedailypay = 0;
				SET thehourlypay = empBasicPay;	
				
			SELECT RowID FROM paysocialsecurity WHERE COALESCE(thehourlypay,0) BETWEEN RangeFromAmount AND IF(COALESCE(thebasicpay,0) > RangeToAmount, COALESCE(thebasicpay,0) + 1, RangeToAmount) ORDER BY MonthlySalaryCredit DESC LIMIT 1 INTO psssID;
			
		END IF;
	
		SELECT CAST(CONCAT(YEAR(NOW()),'-12-',DAY(LAST_DAY(CONCAT(YEAR(NOW()),'-12-00')))) AS DATE) INTO lastdate;
	
		
	
	SET preEffDateFromEmpSallatest = IF(DATEDIFF(CURRENT_DATE(),preEffDateFromEmpSal) = 0, ADDDATE(CURRENT_DATE(), INTERVAL 1 DAY), IF(DATEDIFF(CURRENT_DATE(),preEffDateFromEmpSal) < 0, ADDDATE(preEffDateFromEmpSal, INTERVAL 1 DAY), ADDDATE(CURRENT_DATE(), INTERVAL -1 DAY)));
	
		UPDATE employeesalary SET
		LastUpdBy=NEW.LastUpdBy
		,EffectiveDateTo=preEffDateFromEmpSallatest
		WHERE RowID=prevesalRowID;
		
		
	
		SELECT ADDDATE(EffectiveDateTo, INTERVAL 1 DAY) FROM employeesalary WHERE RowID=prevesalRowID LIMIT 1 INTO preEffDateToEmpSallatest;
		SET @emp_true_sal = (SELECT TrueSalary FROM employeesalary WHERE RowID=prevesalRowID);
		
		SET @default_hdmf_amount = 100;
	
		INSERT INTO employeesalary
		(
			RowID
			,EmployeeID
			,Created
			,CreatedBy
			,OrganizationID
			,PaySocialSecurityID
			,PayPhilhealthID
			,HDMFAmount
			,Salary
			,BasicPay
			,BasicDailyPay
			,BasicHourlyPay
			,FilingStatusID
			,NoofDependents
			,MaritalStatus
			,PositionID
			,EffectiveDateFrom,TrueSalary
		) SELECT
			NULL
			,NEW.RowID
			,CURRENT_TIMESTAMP()
			,NEW.CreatedBy
			,NEW.OrganizationID
			,esa.PaySocialSecurityID
			,esa.PayPhilhealthID
			,IF(esa.HDMFAmount = 0, (@default_hdmf_amount / PAYFREQUENCY_DIVISOR(pf.PayFrequencyType)), esa.HDMFAmount)
			,esa.Salary
			,esa.BasicPay
			,esa.BasicDailyPay
			,esa.BasicHourlyPay
			,esa.`fsrowid`
			,NEW.NoofDependents
			,NEW.MaritalStatus
			,NEW.PositionID
			,preEffDateToEmpSallatest,esa.TrueSalary
			FROM (SELECT es.*
					,fs.RowID `fsrowid`
			      FROM employeesalary es
					INNER JOIN (SELECT RowID, MaritalStatus, MAX(Dependent) `Dependent` FROM filingstatus GROUP BY MaritalStatus) fss ON fss.MaritalStatus=NEW.MaritalStatus
					INNER JOIN filingstatus fs ON fs.MaritalStatus=fss.MaritalStatus AND fs.Dependent=IF(NEW.NoOfDependents > fss.`Dependent`, fss.`Dependent`, NEW.NoOfDependents)
					WHERE es.EmployeeID=NEW.RowID
					AND es.OrganizationID=NEW.OrganizationID
					ORDER BY es.EffectiveDateFrom DESC
					LIMIT 1) esa
			INNER JOIN payfrequency pf ON pf.RowID=NEW.PayFrequencyID
			WHERE esa.EmployeeID IS NOT NULL
		
		UNION
			SELECT
			esal.RowID
			,esal.EmployeeID
			,esal.Created
			,esal.CreatedBy
			,esal.OrganizationID
			,esal.PaySocialSecurityID
			,esal.PayPhilhealthID
			,esal.HDMFAmount
			,esal.Salary
			,esal.BasicPay
			,esal.BasicDailyPay
			,esal.BasicHourlyPay
			,esal.FilingStatusID
			,esal.NoofDependents
			,esal.MaritalStatus
			,esal.PositionID
			,(@second_to_the_latest_date := esal.EffectiveDateFrom)
			,esal.TrueSalary
	      FROM (SELECT *
			      FROM employeesalary
					WHERE EmployeeID=NEW.RowID
					AND OrganizationID=NEW.OrganizationID
					ORDER BY EffectiveDateFrom DESC
					LIMIT 1) esal
			WHERE esal.RowID IS NOT NULL
			
		ON DUPLICATE KEY UPDATE
			LastUpd=CURRENT_TIMESTAMP()
			,LastUpdBy=NEW.LastUpdBy
			,EffectiveDateTo=IF(@second_to_the_latest_date < SUBDATE(preEffDateToEmpSallatest, INTERVAL 1 DAY), SUBDATE(preEffDateToEmpSallatest, INTERVAL 1 DAY), @second_to_the_latest_date);
			
	END IF;



END IF;

IF NEW.EmploymentStatus = 'Resigned' THEN

	UPDATE employeesalary SET
	LastUpdBy=NEW.LastUpdBy
	,EffectiveDateTo=CURRENT_DATE()
	WHERE EmployeeID=NEW.RowID
	AND OrganizationID=NEW.OrganizationID
	AND EffectiveDateTo IS NULL;

END IF;

IF NEW.EmploymentStatus = 'Terminated' THEN

	IF NEW.TerminationDate IS NOT NULL THEN
	
		UPDATE employeesalary SET
		LastUpdBy=NEW.LastUpdBy
		,EffectiveDateTo=NEW.TerminationDate
		WHERE EmployeeID=NEW.RowID
		AND OrganizationID=NEW.OrganizationID
		AND EffectiveDateTo IS NULL;

	END IF;
	
END IF;



	SELECT RowID FROM employeechecklist WHERE EmployeeID=NEW.RowID ORDER BY RowID DESC LIMIT 1 INTO emp_chklist_ID;

INSERT INTO employeechecklist
(
	RowID
	,OrganizationID
	,Created
	,CreatedBy
	,EmployeeID
	,PerformanceAppraisal
	,BIRTIN
	,Diploma
	,IDInfoSlip
	,PhilhealthID
	,HDMFID
	,SSSNo
	,TranscriptOfRecord
	,BirthCertificate
	,EmployeeContract
	,MedicalExam
	,NBIClearance
	,COEEmployer
	,MarriageContract
	,HouseSketch
	,TrainingAgreement
	,HealthPermit
	,ValidID
	,Resume
) VALUES (
	emp_chklist_ID
	,NEW.OrganizationID
	,CURRENT_TIMESTAMP()
	,NEW.CreatedBy
	,NEW.RowID
	,0
	,IF(COALESCE(NEW.TINNo,'   -   -   -') = '   -   -   -', 0, 1)
	,0
	,0
	,IF(COALESCE(NEW.PhilHealthNo,'    -    -') = '    -    -', 0, 1)
	,IF(COALESCE(NEW.HDMFNo,'    -    -') = '    -    -', 0, 1)
	,IF(COALESCE(NEW.SSSNo,'  -       -') = '  -       -', 0, 1)
	,0
	,0
	,0
	,0
	,0
	,0
	,0
	,0
	,0
	,0
	,0
	,0
) ON
DUPLICATE
KEY
UPDATE 
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=NEW.LastUpdBy
	,PerformanceAppraisal=0
	,BIRTIN=IF(COALESCE(NEW.TINNo,'   -   -   -') = '   -   -   -', 0, 1)
	,Diploma=0
	,IDInfoSlip=0
	,PhilhealthID=IF(COALESCE(NEW.PhilHealthNo,'    -    -') = '    -    -', 0, 1)
	,HDMFID=IF(COALESCE(NEW.HDMFNo,'    -    -') = '    -    -', 0, 1)
	,SSSNo=IF(COALESCE(NEW.SSSNo,'  -       -') = '  -       -', 0, 1)
	,TranscriptOfRecord=0
	,BirthCertificate=0
	,EmployeeContract=0
	,MedicalExam=0
	,NBIClearance=0
	,COEEmployer=0
	,MarriageContract=0
	,HouseSketch=0
	,TrainingAgreement=0
	,HealthPermit=0
	,ValidID=0
	,Resume=0;





SELECT RowID FROM `view` WHERE ViewName='Employee Personal Profile' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO viewID;


IF NEW.WorkDaysPerYear != OLD.WorkDaysPerYear THEN

	SELECT
	EffectiveDateFrom
	,Salary
	FROM employeesalary
	WHERE EmployeeID=NEW.RowID
	AND OrganizationID=NEW.OrganizationID
	AND EffectiveDateTo IS NULL
	LIMIT 1
	INTO current_salaryeffectivedate
			,emp_fullmonthsalary;

	IF NEW.EmployeeType IN ('Fixed','Monthly') THEN
		
		SELECT GET_employeeallowancePerDay(NEW.OrganizationID, NEW.RowID, '1', CURDATE()) INTO emp_everydayallowance;
	
		SET emp_everydayallowance = (emp_everydayallowance * NEW.WorkDaysPerYear) / month_count;
			
		SET emp_fullmonthsalary = emp_fullmonthsalary + emp_everydayallowance;

	ELSEIF NEW.EmployeeType = 'Daily' THEN
		
		SELECT GET_employeerateperday(NEW.RowID,NEW.OrganizationID,current_salaryeffectivedate) INTO emp_fullmonthsalary;
		
		SELECT GET_employeeallowancePerDay(NEW.OrganizationID, NEW.RowID, '1', CURDATE()) INTO emp_everydayallowance;

		# SET emp_fullmonthsalary = ((emp_fullmonthsalary + emp_everydayallowance) * NEW.WorkDaysPerYear) / month_count;
		SET emp_fullmonthsalary = (emp_fullmonthsalary * NEW.WorkDaysPerYear) / month_count;
	
	
	END IF;



	SELECT RowID FROM paysocialsecurity WHERE emp_fullmonthsalary BETWEEN RangeFromAmount AND IF(emp_fullmonthsalary > RangeToAmount, (emp_fullmonthsalary + 1), RangeToAmount) ORDER BY MonthlySalaryCredit DESC LIMIT 1 INTO psssID;
	
	SELECT RowID FROM payphilhealth WHERE emp_fullmonthsalary BETWEEN SalaryRangeFrom AND IF(emp_fullmonthsalary > SalaryRangeTo, (emp_fullmonthsalary + 1), SalaryRangeTo) ORDER BY SalaryBase DESC LIMIT 1 INTO phhID;
	
	UPDATE employeesalary SET
	PaySocialSecurityID=psssID
	,PayPhilhealthID=phhID
	,LastUpdBy=NEW.LastUpdBy
	WHERE EmployeeID=NEW.RowID
	AND OrganizationID=NEW.OrganizationID
	AND EffectiveDateTo IS NULL;

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'WorkDaysPerYear',NEW.RowID,OLD.WorkDaysPerYear,NEW.WorkDaysPerYear,'Update');

	SELECT TRIGG_UPD_employeeallowance(NEW.OrganizationID,NEW.LastUpdBy,NEW.RowID,CURDATE(),CURDATE()) INTO anyint;

END IF;


IF OLD.Salutation!=NEW.Salutation THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'Salutation',NEW.RowID,OLD.Salutation,NEW.Salutation,'Update');

END IF;

IF OLD.EmployeeID!=NEW.EmployeeID THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'EmployeeID',NEW.RowID,OLD.EmployeeID,NEW.EmployeeID,'Update');
	
END IF;

IF OLD.FirstName!=NEW.FirstName THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'FirstName',NEW.RowID,OLD.FirstName,NEW.FirstName,'Update');

END IF;

IF OLD.MiddleName!=NEW.MiddleName THEN

INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'MiddleName',NEW.RowID,OLD.MiddleName,NEW.MiddleName,'Update');

END IF;

IF OLD.LastName!=NEW.LastName THEN

INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'LastName',NEW.RowID,OLD.LastName,NEW.LastName,'Update');

END IF;

IF OLD.TINNo!=NEW.TINNo THEN

INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'TINNo',NEW.RowID,OLD.TINNo,NEW.TINNo,'Update');

END IF;

IF OLD.SSSNo!=NEW.SSSNo THEN

INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'SSSNo',NEW.RowID,OLD.SSSNo,NEW.SSSNo,'Update');

END IF;

IF OLD.HDMFNo!=NEW.HDMFNo THEN

INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'HDMFNo',NEW.RowID,OLD.HDMFNo,NEW.HDMFNo,'Update');

END IF;

IF OLD.PhilHealthNo!=NEW.PhilHealthNo THEN

INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'PhilHealthNo',NEW.RowID,OLD.PhilHealthNo,NEW.PhilHealthNo,'Update');

END IF;

IF OLD.EmploymentStatus!=NEW.EmploymentStatus THEN

INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'EmploymentStatus',NEW.RowID,OLD.EmploymentStatus,NEW.EmploymentStatus,'Update');

END IF;

IF OLD.EmailAddress!=NEW.EmailAddress THEN

INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'EmailAddress',NEW.RowID,OLD.EmailAddress,NEW.EmailAddress,'Update');

END IF;

IF OLD.WorkPhone!=NEW.WorkPhone THEN

INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'WorkPhone',NEW.RowID,OLD.WorkPhone,NEW.WorkPhone,'Update');

END IF;

IF OLD.HomePhone!=NEW.HomePhone THEN

INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'HomePhone',NEW.RowID,OLD.HomePhone,NEW.HomePhone,'Update');

END IF;

IF OLD.MobilePhone!=NEW.MobilePhone THEN
	
	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'MobilePhone',NEW.RowID,OLD.MobilePhone,NEW.MobilePhone,'Update');

END IF;

IF OLD.HomeAddress!=NEW.HomeAddress THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'HomeAddress',NEW.RowID,OLD.HomeAddress,NEW.HomeAddress,'Update');

END IF;

IF OLD.Nickname!=NEW.Nickname THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'Nickname',NEW.RowID,OLD.Nickname,NEW.Nickname,'Update');

END IF;

IF OLD.JobTitle!=NEW.JobTitle THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'JobTitle',NEW.RowID,OLD.JobTitle,NEW.JobTitle,'Update');

END IF;

IF OLD.Gender!=NEW.Gender THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'Gender',NEW.RowID,OLD.Gender,NEW.Gender,'Update');

END IF;

IF OLD.EmployeeType!=NEW.EmployeeType THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'EmployeeType',NEW.RowID,OLD.EmployeeType,NEW.EmployeeType,'Update');

END IF;

IF OLD.MaritalStatus!=NEW.MaritalStatus THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'MaritalStatus',NEW.RowID,OLD.MaritalStatus,NEW.MaritalStatus,'Update');

END IF;

IF OLD.Birthdate!=NEW.Birthdate THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'Birthdate',NEW.RowID,OLD.Birthdate,NEW.Birthdate,'Update');

END IF;

IF OLD.StartDate!=NEW.StartDate THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'StartDate',NEW.RowID,OLD.StartDate,NEW.StartDate,'Update');

END IF;

IF OLD.TerminationDate!=NEW.TerminationDate THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'TerminationDate',NEW.RowID,OLD.TerminationDate,NEW.TerminationDate,'Update');

END IF;

IF OLD.PositionID!=NEW.PositionID THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'PositionID',NEW.RowID,OLD.PositionID,NEW.PositionID,'Update');

END IF;

IF OLD.PayFrequencyID!=NEW.PayFrequencyID THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'PayFrequencyID',NEW.RowID,OLD.PayFrequencyID,NEW.PayFrequencyID,'Update');

END IF;

IF OLD.NoOfDependents!=NEW.NoOfDependents THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'NoOfDependents',NEW.RowID,OLD.NoOfDependents,NEW.NoOfDependents,'Update');

END IF;

IF OLD.UndertimeOverride!=NEW.UndertimeOverride THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'UndertimeOverride',NEW.RowID,OLD.UndertimeOverride,NEW.UndertimeOverride,'Update');

END IF;

IF OLD.OvertimeOverride!=NEW.OvertimeOverride THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'OvertimeOverride',NEW.RowID,OLD.OvertimeOverride,NEW.OvertimeOverride,'Update');

END IF;

IF OLD.NewEmployeeFlag!=NEW.NewEmployeeFlag THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'NewEmployeeFlag',NEW.RowID,OLD.NewEmployeeFlag,NEW.NewEmployeeFlag,'Update');

END IF;

IF OLD.LeaveBalance!=NEW.LeaveBalance THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'LeaveBalance',NEW.RowID,OLD.LeaveBalance,NEW.LeaveBalance,'Update');

END IF;

IF OLD.SickLeaveBalance!=NEW.SickLeaveBalance THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'SickLeaveBalance',NEW.RowID,OLD.SickLeaveBalance,NEW.SickLeaveBalance,'Update');

END IF;

IF OLD.MaternityLeaveBalance!=NEW.MaternityLeaveBalance THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'MaternityLeaveBalance',NEW.RowID,OLD.MaternityLeaveBalance,NEW.MaternityLeaveBalance,'Update');

END IF;

IF OLD.LeaveAllowance!=NEW.LeaveAllowance THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'LeaveAllowance',NEW.RowID,OLD.LeaveAllowance,NEW.LeaveAllowance,'Update');

END IF;

IF OLD.SickLeaveAllowance!=NEW.SickLeaveAllowance THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'SickLeaveAllowance',NEW.RowID,OLD.SickLeaveAllowance,NEW.SickLeaveAllowance,'Update');

END IF;

IF OLD.MaternityLeaveAllowance!=NEW.MaternityLeaveAllowance THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'MaternityLeaveAllowance',NEW.RowID,OLD.MaternityLeaveAllowance,NEW.MaternityLeaveAllowance,'Update');
	
END IF;

IF OLD.LeavePerPayPeriod!=NEW.LeavePerPayPeriod THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'LeavePerPayPeriod',NEW.RowID,OLD.LeavePerPayPeriod,NEW.LeavePerPayPeriod,'Update');

END IF;

IF OLD.SickLeavePerPayPeriod!=NEW.SickLeavePerPayPeriod THEN
	
	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'SickLeavePerPayPeriod',NEW.RowID,OLD.SickLeavePerPayPeriod,NEW.SickLeavePerPayPeriod,'Update');

END IF;


IF OLD.MaternityLeavePerPayPeriod!=NEW.MaternityLeavePerPayPeriod THEN
	
	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'MaternityLeavePerPayPeriod',NEW.RowID,OLD.MaternityLeavePerPayPeriod,NEW.MaternityLeavePerPayPeriod,'Update');
	
END IF;

IF OLD.OffsetBalance != NEW.OffsetBalance THEN

	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'OffsetBalance',NEW.RowID,OLD.OffsetBalance,NEW.OffsetBalance,'Update');

END IF;








IF IFNULL(OLD.AgencyID,0) != IFNULL(NEW.AgencyID,0) THEN

	SELECT ag.AgencyName,ag.`AgencyFee` FROM agency ag WHERE ag.RowID=OLD.AgencyID INTO OLD_agency_name,OLD_agfee;

	SET OLD_agency_name = IFNULL(OLD_agency_name,'');
	SET OLD_agfee = IFNULL(OLD_agfee,0.0);

	SELECT ag.AgencyName,ag.`AgencyFee` FROM agency ag WHERE ag.RowID=NEW.AgencyID INTO NEW_agency_name,NEW_agfee;

	SET NEW_agency_name = IFNULL(NEW_agency_name,'');
	SET NEW_agfee = IFNULL(NEW_agfee,0.0);

	SET agfee_percent = NEW_agfee / OLD_agfee;

	
	
	IF agfee_percent != 1.0 THEN
	
		UPDATE agencyfee agf
		SET agf.DailyFee = agf.DailyFee * agfee_percent
		WHERE agf.OrganizationID=NEW.OrganizationID
		AND agf.AgencyID=NEW.AgencyID
		AND agf.EmployeeID=NEW.RowID
		AND agf.EmpPositionID=NEW.PositionID;
		
		
		

		
		
	END IF;
		
	INSERT INTO audittrail (LastUpd,LastUpdBy,CreatedBy,OrganizationID,ViewID,FieldChanged,ChangedRowID,OldValue,NewValue,ActionPerformed) VALUES (CURRENT_TIMESTAMP(),NEW.LastUpdBy,NEW.LastUpdBy,NEW.OrganizationID,viewID,'Agency',NEW.RowID,OLD_agency_name,NEW_agency_name,'Update');

END IF;










IF NEW.AgencyID IS NOT NULL THEN

	SET agfee_percent = 0.0;
	
	UPDATE employeesalary es
	INNER JOIN payphilhealth phh ON phh.SalaryBracket = -1500 AND phh.HiddenData='1'
	INNER JOIN paysocialsecurity pss ON pss.MonthlySalaryCredit = -1500 AND pss.HiddenData='1'
	LEFT JOIN (SELECT * FROM listofval WHERE `Type`='Default Government Contribution' AND `LIC`='HDMF' LIMIT 1) lv ON lv.RowID > 0
	SET es.PaySocialSecurityID = pss.RowID
	,es.PayPhilhealthID = phh.RowID
	,es.HDMFAmount = IF(lv.DisplayValue IS NULL, 100.0, (lv.DisplayValue * 1.0))
	,es.LastUpd = CURRENT_TIMESTAMP()
	,es.LastUpdBy = NEW.LastUpdBy
	WHERE es.EmployeeID=NEW.RowID
	AND es.OrganizationID=NEW.OrganizationID;
	
	SELECT RowID FROM `view` WHERE ViewName='Employee Salary' AND OrganizationID=NEW.OrganizationID LIMIT 1 INTO viewID;


ELSE





	SELECT RowID,Salary,EffectiveDateFrom FROM employeesalary WHERE EmployeeID=NEW.RowID AND OrganizationID=NEW.OrganizationID ORDER BY EffectiveDateFrom DESC LIMIT 1 INTO prevesalRowID,empBasicPay,preEffDateFromEmpSal;
	
	
	
	
	IF NEW.EmployeeType IN ('Fixed','Monthly') THEN
		IF NEW.PayFrequencyID=1 THEN
			SET thebasicpay = empBasicPay / 2.0;
			SET thedailypay = 0;
			SET thehourlypay = 0;
		ELSE
			SET thebasicpay = empBasicPay;
			SET thedailypay = 0;
			SET thehourlypay = 0;
		END IF;
		
		SELECT RowID FROM payphilhealth WHERE IFNULL(empBasicPay,0) BETWEEN SalaryRangeFrom AND SalaryRangeTo ORDER BY SalaryBase DESC LIMIT 1 INTO phhID;
		
		SELECT RowID FROM paysocialsecurity WHERE IFNULL(empBasicPay,0) BETWEEN RangeFromAmount AND RangeToAmount ORDER BY MonthlySalaryCredit DESC LIMIT 1 INTO psssID;
		
	ELSEIF NEW.EmployeeType = 'Daily' THEN
			SET thebasicpay = (empBasicPay * NEW.WorkDaysPerYear) / month_count;
			SET thedailypay = empBasicPay;
			SET thehourlypay = 0;
			
		SELECT RowID FROM payphilhealth WHERE IFNULL(thebasicpay,0) BETWEEN SalaryRangeFrom AND SalaryRangeTo ORDER BY SalaryBase DESC LIMIT 1 INTO phhID;
		
		SELECT RowID FROM paysocialsecurity WHERE IFNULL(thebasicpay,0) BETWEEN RangeFromAmount AND RangeToAmount ORDER BY MonthlySalaryCredit DESC LIMIT 1 INTO psssID;
		
	ELSEIF NEW.EmployeeType = 'Hourly' THEN
			SET thebasicpay = empBasicPay;
			SET thedailypay = 0;
			SET thehourlypay = empBasicPay;	
			
		SELECT RowID FROM paysocialsecurity WHERE COALESCE(thehourlypay,0) BETWEEN RangeFromAmount AND IF(COALESCE(thebasicpay,0) > RangeToAmount, COALESCE(thebasicpay,0) + 1, RangeToAmount) ORDER BY MonthlySalaryCredit DESC LIMIT 1 INTO psssID;
		
	END IF;

	UPDATE employeesalary es
	SET es.PaySocialSecurityID = psssID
	,es.PayPhilhealthID = phhID
	,es.HDMFAmount = 100.0
	,es.LastUpd = CURRENT_TIMESTAMP()
	,es.LastUpdBy = NEW.LastUpdBy
	WHERE es.EmployeeID=NEW.RowID
	AND es.OrganizationID=NEW.OrganizationID;
	
END IF;

SET @sal_count = (SELECT COUNT(RowID) FROM employeesalary es WHERE es.EmployeeID=NEW.RowID AND es.OrganizationID=NEW.OrganizationID);

IF @sal_count = 0 THEN
	INSERT INTO employeesalary
		(
			EmployeeID
			,Created
			,CreatedBy
			,OrganizationID
			,PaySocialSecurityID
			,PayPhilhealthID
			,HDMFAmount
			,Salary
			,BasicPay
			,BasicDailyPay
			,BasicHourlyPay
			,FilingStatusID
			,NoofDependents
			,MaritalStatus
			,PositionID
			,EffectiveDateFrom,TrueSalary
		) VALUES(
			NEW.RowID
			,CURRENT_TIMESTAMP()
			,NEW.CreatedBy
			,NEW.OrganizationID
			,NULL
			,NULL
			,100
			,0
			,0
			,0
			,0
			,(SELECT RowID FROM filingstatus WHERE MaritalStatus=NEW.MaritalStatus AND Dependent=IFNULL(NEW.NoOfDependents,0))# marit_stat
			,COALESCE(NEW.NoOfDependents,0)
			,NEW.MaritalStatus
			,NEW.PositionID
			,NEW.StartDate,0
		);
END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
