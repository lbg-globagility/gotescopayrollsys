/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `MASSUPD_CORRECT_LEAVEBALANCE`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `MASSUPD_CORRECT_LEAVEBALANCE`(IN `og_rowid` INT, IN `number_year` INT, IN `leave_typeid` INT)
BEGIN

DECLARE emp_count
        ,_index
		  ,e_rowid INT(11) DEFAULT 0;

DECLARE leaveAllowance
		  ,sickLeaveAllowance
		  ,maternityLeaveAllowance
		  ,additionalVLAllowance
		  ,otherLeaveAllowance DECIMAL(11, 2);

DECLARE leavename TEXT;

SELECT COUNT(e.RowID)
FROM employee e
WHERE e.OrganizationID=og_rowid
AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
#AND e.RowID=81
INTO emp_count
;

SELECT PartNo FROM product WHERE RowID=leave_typeid INTO leavename;

WHILE _index < emp_count DO
	
	SELECT e.RowID
	, e.LeaveAllowance
	, e.SickLeaveAllowance
	, e.MaternityLeaveAllowance
	, e.AdditionalVLAllowance
	, e.OtherLeaveAllowance
	FROM employee e
	WHERE e.OrganizationID=og_rowid
	AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
#	AND e.RowID=81
	ORDER BY CONCAT(e.LastName, e.FirstName)
	LIMIT _index, 1
	INTO e_rowid
	     ,leaveAllowance
		  ,sickLeaveAllowance
		  ,maternityLeaveAllowance
		  ,additionalVLAllowance
		  ,otherLeaveAllowance;
		
	SET @og_rowid = og_rowid;
	SET @number_year = number_year;
	
	# Additional VL,Maternity/paternity leave,Others,Sick leave,Vacation leave
	SET @leavebal = 0.00;
	
	CASE leavename
	WHEN 'Vacation leave' THEN SET @leavebal=leaveAllowance;
	WHEN 'Sick leave' THEN SET @leavebal=sickLeaveAllowance;
	WHEN 'Additional VL' THEN SET @leavebal=additionalVLAllowance;
	WHEN 'Others' THEN SET @leavebal=otherLeaveAllowance;
	ELSE SET @leavebal=maternityLeaveAllowance;
	END CASE;
	
	SET @leavetypeid = leave_typeid;

	SET @ordinalvalue = 0;
	
	/**/ UPDATE paystubitem si
	INNER JOIN (
			SELECT x.*
			, MIN(x.`Result`) `LeastLeaveBal`
			, (@ordinalvalue := MAX(x.OrdinalValue)) `MaxOrdinalValue`
			FROM (SELECT ii.*
					, (@leavebal := (@leavebal - ii.OfficialValidHours)) `Result`
					FROM (SELECT elv.*
					      , pp.RowID `PayPeriodID`
							, psi.PayStubID
							, psi.PayAmount
							, pp.OrdinalValue
							FROM employee e
							LEFT JOIN employeeleave elv ON elv.EmployeeID=e.RowID AND elv.`Status`='Approved' AND elv.LeaveTypeID = @leavetypeid
							INNER JOIN dates d ON d.DateValue BETWEEN elv.LeaveStartDate AND elv.LeaveEndDate
							INNER JOIN payperiod pp ON pp.OrganizationID=e.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID AND d.DateValue BETWEEN pp.PayFromDate AND pp.PayToDate AND pp.`Year`=@number_year
							LEFT JOIN paystub ps ON ps.EmployeeID=e.RowID AND ps.PayPeriodID=pp.RowID AND ps.OrganizationID=e.OrganizationID
							LEFT JOIN paystubitem psi ON psi.PayStubID=ps.RowID AND psi.ProductID=elv.LeaveTypeID AND psi.Undeclared=FALSE
							WHERE e.RowID=e_rowid
							AND e.OrganizationID=@og_rowid
							ORDER BY d.DateValue
					      ) ii
			      ) x
					GROUP BY x.PayPeriodID
	     ) i ON i.PayStubID=si.PayStubID
	            AND si.ProductID=leave_typeid
	            AND si.Undeclared=FALSE
	SET si.PayAmount=i.`LeastLeaveBal`
	, si.LastUpd=CURRENT_TIMESTAMP()
	, si.LastUpdBy=IFNULL(si.LastUpdBy, si.CreatedBy)/**/
	;
	
	/**/ UPDATE paystubitem psi
	INNER JOIN payperiod pp ON pp.OrganizationID=og_rowid AND pp.OrdinalValue > @ordinalvalue AND pp.`Year`=number_year
	INNER JOIN paystub ps ON ps.OrganizationID=og_rowid AND ps.EmployeeID=e_rowid AND ps.PayPeriodID=pp.RowID AND ps.RowID=psi.PayStubID
	
	INNER JOIN payperiod ppd ON ppd.OrdinalValue=@ordinalvalue AND ppd.OrganizationID=ps.OrganizationID AND ppd.`Year`=pp.`Year`
	INNER JOIN paystub pst ON pst.EmployeeID=ps.EmployeeID AND pst.PayPeriodID=ppd.RowID AND pst.OrganizationID=ps.OrganizationID
	INNER JOIN paystubitem si ON si.PayStubID=pst.RowID AND si.ProductID=leave_typeid AND si.Undeclared=psi.Undeclared
	
	SET psi.PayAmount = si.PayAmount
	, si.PayAmount = si.PayAmount
	, psi.LastUpd=CURRENT_TIMESTAMP()
	, psi.LastUpdBy=IFNULL(psi.LastUpdBy, psi.CreatedBy)
	WHERE psi.ProductID=leave_typeid
	# AND psi.Undeclared=FALSE
	;
	
	
	
	
	
	
	
	
	
	CASE leavename
	WHEN 'Vacation leave' THEN
		SET @leavebal=leaveAllowance;
		
		UPDATE employee e
		INNER JOIN (SELECT MIN(x.`Result`) `LeastLeaveBal`
						FROM (SELECT ii.*
								, (@leavebal := (@leavebal - ii.OfficialValidHours)) `Result`
								FROM (SELECT elv.*
								      , pp.RowID `PayPeriodID`
										, psi.PayStubID
										, psi.PayAmount
										, pp.OrdinalValue
										FROM employee e
										LEFT JOIN employeeleave elv ON elv.EmployeeID=e.RowID AND elv.`Status`='Approved' AND elv.LeaveTypeID = @leavetypeid
										INNER JOIN dates d ON d.DateValue BETWEEN elv.LeaveStartDate AND elv.LeaveEndDate
										INNER JOIN payperiod pp ON pp.OrganizationID=e.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID AND d.DateValue BETWEEN pp.PayFromDate AND pp.PayToDate AND pp.`Year`=@number_year
										LEFT JOIN paystub ps ON ps.EmployeeID=e.RowID AND ps.PayPeriodID=pp.RowID AND ps.OrganizationID=e.OrganizationID
										LEFT JOIN paystubitem psi ON psi.PayStubID=ps.RowID AND psi.ProductID=elv.LeaveTypeID AND psi.Undeclared=FALSE
										WHERE e.RowID=e_rowid
										AND e.OrganizationID=@og_rowid
										ORDER BY d.DateValue
								      ) ii
						       ) x ) llb ON llb.`LeastLeaveBal` IS NOT NULL
		SET e.LeaveBalance = llb.`LeastLeaveBal`
		WHERE e.RowID=e_rowid;
		
	WHEN 'Sick leave' THEN
		SET @leavebal=sickLeaveAllowance;
		
		UPDATE employee e
		INNER JOIN (SELECT MIN(x.`Result`) `LeastLeaveBal`
						FROM (SELECT ii.*
								, (@leavebal := (@leavebal - ii.OfficialValidHours)) `Result`
								FROM (SELECT elv.*
								      , pp.RowID `PayPeriodID`
										, psi.PayStubID
										, psi.PayAmount
										, pp.OrdinalValue
										FROM employee e
										LEFT JOIN employeeleave elv ON elv.EmployeeID=e.RowID AND elv.`Status`='Approved' AND elv.LeaveTypeID = @leavetypeid
										INNER JOIN dates d ON d.DateValue BETWEEN elv.LeaveStartDate AND elv.LeaveEndDate
										INNER JOIN payperiod pp ON pp.OrganizationID=e.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID AND d.DateValue BETWEEN pp.PayFromDate AND pp.PayToDate AND pp.`Year`=@number_year
										LEFT JOIN paystub ps ON ps.EmployeeID=e.RowID AND ps.PayPeriodID=pp.RowID AND ps.OrganizationID=e.OrganizationID
										LEFT JOIN paystubitem psi ON psi.PayStubID=ps.RowID AND psi.ProductID=elv.LeaveTypeID AND psi.Undeclared=FALSE
										WHERE e.RowID=e_rowid
										AND e.OrganizationID=@og_rowid
										ORDER BY d.DateValue
								      ) ii
						       ) x ) llb ON llb.`LeastLeaveBal` > 0
		SET e.SickLeaveBalance = llb.`LeastLeaveBal`
		WHERE e.RowID=e_rowid;
		
	WHEN 'Additional VL' THEN
		SET @leavebal=additionalVLAllowance;
		
		UPDATE employee e
		INNER JOIN (SELECT MIN(x.`Result`) `LeastLeaveBal`
						FROM (SELECT ii.*
								, (@leavebal := (@leavebal - ii.OfficialValidHours)) `Result`
								FROM (SELECT elv.*
								      , pp.RowID `PayPeriodID`
										, psi.PayStubID
										, psi.PayAmount
										, pp.OrdinalValue
										FROM employee e
										LEFT JOIN employeeleave elv ON elv.EmployeeID=e.RowID AND elv.`Status`='Approved' AND elv.LeaveTypeID = @leavetypeid
										INNER JOIN dates d ON d.DateValue BETWEEN elv.LeaveStartDate AND elv.LeaveEndDate
										INNER JOIN payperiod pp ON pp.OrganizationID=e.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID AND d.DateValue BETWEEN pp.PayFromDate AND pp.PayToDate AND pp.`Year`=@number_year
										LEFT JOIN paystub ps ON ps.EmployeeID=e.RowID AND ps.PayPeriodID=pp.RowID AND ps.OrganizationID=e.OrganizationID
										LEFT JOIN paystubitem psi ON psi.PayStubID=ps.RowID AND psi.ProductID=elv.LeaveTypeID AND psi.Undeclared=FALSE
										WHERE e.RowID=e_rowid
										AND e.OrganizationID=@og_rowid
										ORDER BY d.DateValue
								      ) ii
						       ) x ) llb ON llb.`LeastLeaveBal` > 0
		SET e.AdditionalVLBalance = llb.`LeastLeaveBal`
		WHERE e.RowID=e_rowid;
		
	WHEN 'Others' THEN
		SET @leavebal=otherLeaveAllowance;
		
		UPDATE employee e
		INNER JOIN (SELECT MIN(x.`Result`) `LeastLeaveBal`
						FROM (SELECT ii.*
								, (@leavebal := (@leavebal - ii.OfficialValidHours)) `Result`
								FROM (SELECT elv.*
								      , pp.RowID `PayPeriodID`
										, psi.PayStubID
										, psi.PayAmount
										, pp.OrdinalValue
										FROM employee e
										LEFT JOIN employeeleave elv ON elv.EmployeeID=e.RowID AND elv.`Status`='Approved' AND elv.LeaveTypeID = @leavetypeid
										INNER JOIN dates d ON d.DateValue BETWEEN elv.LeaveStartDate AND elv.LeaveEndDate
										INNER JOIN payperiod pp ON pp.OrganizationID=e.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID AND d.DateValue BETWEEN pp.PayFromDate AND pp.PayToDate AND pp.`Year`=@number_year
										LEFT JOIN paystub ps ON ps.EmployeeID=e.RowID AND ps.PayPeriodID=pp.RowID AND ps.OrganizationID=e.OrganizationID
										LEFT JOIN paystubitem psi ON psi.PayStubID=ps.RowID AND psi.ProductID=elv.LeaveTypeID AND psi.Undeclared=FALSE
										WHERE e.RowID=e_rowid
										AND e.OrganizationID=@og_rowid
										ORDER BY d.DateValue
								      ) ii
						       ) x ) llb ON llb.`LeastLeaveBal` > 0
		SET e.OtherLeaveBalance = llb.`LeastLeaveBal`
		WHERE e.RowID=e_rowid;
		
	ELSE
		SET @leavebal=maternityLeaveAllowance;
		
		UPDATE employee e
		INNER JOIN (SELECT MIN(x.`Result`) `LeastLeaveBal`
						FROM (SELECT ii.*
								, (@leavebal := (@leavebal - ii.OfficialValidHours)) `Result`
								FROM (SELECT elv.*
								      , pp.RowID `PayPeriodID`
										, psi.PayStubID
										, psi.PayAmount
										, pp.OrdinalValue
										FROM employee e
										LEFT JOIN employeeleave elv ON elv.EmployeeID=e.RowID AND elv.`Status`='Approved' AND elv.LeaveTypeID = @leavetypeid
										INNER JOIN dates d ON d.DateValue BETWEEN elv.LeaveStartDate AND elv.LeaveEndDate
										INNER JOIN payperiod pp ON pp.OrganizationID=e.OrganizationID AND pp.TotalGrossSalary=e.PayFrequencyID AND d.DateValue BETWEEN pp.PayFromDate AND pp.PayToDate AND pp.`Year`=@number_year
										LEFT JOIN paystub ps ON ps.EmployeeID=e.RowID AND ps.PayPeriodID=pp.RowID AND ps.OrganizationID=e.OrganizationID
										LEFT JOIN paystubitem psi ON psi.PayStubID=ps.RowID AND psi.ProductID=elv.LeaveTypeID AND psi.Undeclared=FALSE
										WHERE e.RowID=e_rowid
										AND e.OrganizationID=@og_rowid
										ORDER BY d.DateValue
								      ) ii
						       ) x ) llb ON llb.`LeastLeaveBal` > 0
		SET e.MaternityLeaveBalance = llb.`LeastLeaveBal`
		WHERE e.RowID=e_rowid;
	END CASE;
	
	SET _index = _index + 1;
END WHILE;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
