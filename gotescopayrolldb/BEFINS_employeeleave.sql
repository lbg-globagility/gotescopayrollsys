/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP TRIGGER IF EXISTS `BEFINS_employeeleave`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `BEFINS_employeeleave` BEFORE INSERT ON `employeeleave` FOR EACH ROW BEGIN

DECLARE selected_leavebal DECIMAL(11,2) DEFAULT 0;

DECLARE hasLatestPaystub, isFirstPeriod, isCelebratesRegularization BOOL DEFAULT FALSE;

/*********************************************************
START METHOD `SET_OfficialValidHours_AND_OfficialValidDays`
*********************************************************/
IF NEW.Status2 = 'Pending' AND NEW.`Status` = 'Approved' THEN
	
	SET NEW.Status2 = NEW.`Status`;

END IF;

SELECT
EXISTS(SELECT ps.RowID
		FROM paystub ps
		INNER JOIN paystubitem psi ON psi.PayStubID=ps.RowID AND psi.Undeclared = '1'
		INNER JOIN product p ON p.RowID=psi.ProductID AND p.PartNo = NEW.LeaveType
		INNER JOIN category c ON c.RowID=p.CategoryID AND c.CategoryName='Leave Type'
		WHERE ps.EmployeeID=NEW.EmployeeID
		AND NEW.LeaveStartDate BETWEEN ps.PayFromDate AND ps.PayToDate
		LIMIT 1)
INTO hasLatestPaystub;

IF NEW.`Status` = 'Approved' THEN
	
	SET NEW.Status2 = NEW.`Status`;
	
	SET @offcl_validdays = TIMESTAMPDIFF(DAY, NEW.LeaveStartDate, NEW.LeaveEndDate);
	
	IF IFNULL(@offcl_validdays,-1) >= 0 THEN
		SET @offcl_validdays = @offcl_validdays + 1;
	END IF;
	
	SET NEW.OfficialValidDays = @offcl_validdays;
	
	SELECT
	EXISTS(SELECT pp.RowID
			FROM payperiod pp
			INNER JOIN (SELECT e.RowID, e.PayFrequencyID FROM employee e WHERE e.RowID=NEW.EmployeeID) e ON e.RowID = NEW.EmployeeID
			WHERE pp.OrdinalValue = 1
			AND pp.OrganizationID=NEW.OrganizationID
			AND (NEW.LeaveStartDate BETWEEN pp.PayFromDate AND pp.PayToDate
			     OR NEW.LeaveEndDate BETWEEN pp.PayFromDate AND pp.PayToDate)
			AND pp.TotalGrossSalary = e.PayFrequencyID
			LIMIT 1)
	INTO isFirstPeriod;
	
	SELECT
	EXISTS(SELECT e.RowID
			FROM employee e
			INNER JOIN payperiod pp ON pp.OrganizationID=e.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID AND NEW.LeaveStartDate BETWEEN pp.PayFromDate AND pp.PayToDate
			WHERE e.RowID=NEW.EmployeeID
			AND e.DateRegularized BETWEEN pp.PayFromDate AND pp.PayToDate)
	INTO isCelebratesRegularization;

	IF (hasLatestPaystub = FALSE AND isFirstPeriod = TRUE)
		OR isCelebratesRegularization = TRUE THEN
	
		SELECT i.`LeaveAllowance`
		FROM (SELECT e.RowID,e.LeaveAllowance FROM employee e WHERE e.RowID=NEW.EmployeeID AND NEW.LeaveType='Vacation leave'
			UNION
				SELECT e.RowID,e.SickLeaveAllowance `LeaveAllowance` FROM employee e WHERE e.RowID=NEW.EmployeeID AND NEW.LeaveType='Sick leave'
			UNION
				SELECT e.RowID,e.AdditionalVLAllowance `LeaveAllowance` FROM employee e WHERE e.RowID=NEW.EmployeeID AND NEW.LeaveType='Additional VL'
			UNION
				SELECT e.RowID,e.OtherLeaveAllowance `LeaveAllowance` FROM employee e WHERE e.RowID=NEW.EmployeeID AND NEW.LeaveType='Others leave'
			UNION
				SELECT e.RowID,e.MaternityLeaveAllowance `LeaveAllowance` FROM employee e WHERE e.RowID=NEW.EmployeeID AND LOCATE('aternity', NEW.LeaveType) > 0
				) i
		INTO selected_leavebal;
	
	ELSE
	
		SELECT psi.PayAmount
		FROM paystub ps
		INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID AND NEW.LeaveStartDate BETWEEN pp.PayFromDate AND pp.PayToDate
		
		INNER JOIN payperiod ppd ON ppd.`Year`=pp.`Year` AND ppd.OrganizationID=pp.OrganizationID AND ppd.TotalGrossSalary=pp.TotalGrossSalary AND ppd.OrdinalValue = (pp.OrdinalValue - 1)
		INNER JOIN paystub pstub ON pstub.EmployeeID=ps.EmployeeID AND pstub.OrganizationID=ps.OrganizationID AND pstub.PayPeriodID=ppd.RowID
		
		INNER JOIN paystubitem psi ON psi.PayStubID=pstub.RowID AND psi.Undeclared = '1'
		INNER JOIN product p ON p.RowID=psi.ProductID AND p.PartNo = NEW.LeaveType
		INNER JOIN category c ON c.RowID=p.CategoryID AND c.CategoryName='Leave Type'
		
		WHERE ps.EmployeeID=NEW.EmployeeID
		AND ps.OrganizationID=NEW.OrganizationID
		LIMIT 1
		INTO selected_leavebal;
		
		IF selected_leavebal IS NULL THEN SET selected_leavebal = 0; END IF;
		
	END IF;
	
	SET @offcl_validhrs = 0.0;
	
	SET @min_perhour = 60; SET @sec_permin = 60;
	
	SET @appropriate_end_date = CURDATE();
	
	IF IS_TIMERANGE_REACHTOMORROW(NEW.LeaveStartTime, NEW.LeaveEndTime) = TRUE THEN
		SET @appropriate_end_date = ADDDATE(NEW.LeaveStartDate, INTERVAL 1 DAY);
		
	ELSE
		SET @appropriate_end_date = NEW.LeaveStartDate;
		
	END IF;

	SET @offcl_validhrs =	(TIMESTAMPDIFF(SECOND
														,CONCAT_DATETIME(NEW.LeaveStartDate, NEW.LeaveStartTime)
														,CONCAT_DATETIME(@appropriate_end_date, NEW.LeaveEndTime))
									/ (@min_perhour * @sec_permin));
	
	SET @shift_rowid = NULL;
	
	IF @offcl_validdays > 1 THEN
	
		SELECT sh.RowID
		FROM employeeshift esh
		INNER JOIN shift sh ON sh.RowID=esh.ShiftID
		WHERE esh.EmployeeID=NEW.EmployeeID
		AND esh.OrganizationID=NEW.OrganizationID
		AND (esh.EffectiveFrom <= NEW.LeaveStartDate OR esh.EffectiveTo <= NEW.LeaveStartDate)
		AND (NEW.LeaveEndDate <= esh.EffectiveFrom OR NEW.LeaveEndDate <= esh.EffectiveTo)
		LIMIT 1
		INTO @shift_rowid;
	
	ELSEIF @offcl_validdays = 1 THEN
	
		SELECT sh.RowID
		FROM employeeshift esh
		INNER JOIN shift sh ON sh.RowID=esh.ShiftID
		WHERE esh.EmployeeID=NEW.EmployeeID
		AND esh.OrganizationID=NEW.OrganizationID
		AND NEW.LeaveStartDate BETWEEN esh.EffectiveFrom AND esh.EffectiveTo
		LIMIT 1
		INTO @shift_rowid;
	
	END IF;
	
	SET @break_hrs = NULL;

	SELECT IF(IS_TIMERANGE_REACHTOMORROW(sh.BreakTimeFrom, sh.BreakTimeTo)
				, (TIMESTAMPDIFF(SECOND
										,CONCAT_DATETIME(CURDATE(), sh.BreakTimeFrom)
										,CONCAT_DATETIME(ADDDATE(CURDATE(), INTERVAL 1 DAY), sh.BreakTimeTo))
					/ (@min_perhour * @sec_permin))
				, COMPUTE_TimeDifference(sh.BreakTimeFrom, sh.BreakTimeTo)) `Result`
	FROM shift sh
	WHERE sh.RowID=@shift_rowid
	AND sh.TimeFrom=NEW.LeaveStartTime
	AND sh.TimeTo	=NEW.LeaveEndTime
	LIMIT 1
	INTO @break_hrs;
	
	SET @break_hrs = IFNULL(@break_hrs, 0);
	
	SET @validhrs_multip_validdays = (@offcl_validhrs - @break_hrs) * @offcl_validdays;

	IF (selected_leavebal - @validhrs_multip_validdays) < 0 THEN
		# SET @validhrs_multip_validdays = @validhrs_multip_validdays + (selected_leavebal - @validhrs_multip_validdays);
		# SET NEW.OfficialValidHours = (selected_leavebal - @validhrs_multip_validdays);
		SET NEW.OfficialValidHours = (IFNULL(@offcl_validhrs, 0) - IFNULL(@break_hrs, 0)) * -1;
	ELSE
	
		# SET NEW.OfficialValidHours = @validhrs_multip_validdays;
		# SET NEW.OfficialValidHours = (IFNULL(@offcl_validhrs, 0) - IFNULL(@break_hrs, 0)) * IFNULL(@offcl_validdays, 0);
		SET NEW.OfficialValidHours = (IFNULL(@offcl_validhrs, 0) - IFNULL(@break_hrs, 0));
	END IF;
	
ELSE

	SET NEW.OfficialValidHours = 0;
	
	SET NEW.OfficialValidDays = 0;
	
END IF;
/*********************************************************
END METHOD `SET_OfficialValidHours_AND_OfficialValidDays`
*********************************************************/

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
