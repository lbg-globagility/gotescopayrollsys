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

-- Dumping structure for function gotescopayrolldb_server.IS_WORKINGDAY_PRESENT_DURINGHOLI
DROP FUNCTION IF EXISTS `IS_WORKINGDAY_PRESENT_DURINGHOLI`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `IS_WORKINGDAY_PRESENT_DURINGHOLI`(`organiz_id` INT, `emp_rowid` INT, `et_date` DATE, `will_check_before_orelse_after` BOOL) RETURNS tinyint(4)
    DETERMINISTIC
BEGIN

DECLARE returnvalue TINYINT DEFAULT 0;

SET @default_payrate = 1.0;

SET @default_specholi_payrate = 1.3;

SET @default_regholi_payrate = 2.0;

IF will_check_before_orelse_after = TRUE THEN

	/*SELECT EXISTS(	SELECT et.RowID
						FROM employeetimeentry et
						INNER JOIN employee e
								ON e.RowID=et.EmployeeID AND e.RowID=emp_rowid
						INNER JOIN payrate pr
								ON pr.RowID=et.PayRateID AND pr.`PayRate`=@default_payrate
						INNER JOIN employeeshift esh
								ON esh.RowID=et.EmployeeShiftID AND esh.RestDay=0
						WHERE et.OrganizationID=organiz_id
						AND et.`Date` = SUBDATE(et_date, INTERVAL 1 DAY)
						AND et.TotalDayPay > 0
						
					UNION
						SELECT et.RowID
						FROM employeetimeentry et
						INNER JOIN employee e
								ON e.RowID=et.EmployeeID AND e.RowID=emp_rowid
						INNER JOIN payrate pr
								ON pr.RowID=et.PayRateID AND pr.`PayRate`=@default_payrate
						INNER JOIN payrate prtom ON prtom.OrganizationID=et.OrganizationID AND prtom.`Date`=ADDDATE(pr.`Date`, INTERVAL 1 DAY) AND prtom.`PayRate` > @default_payrate
						INNER JOIN employeeshift esh
								ON esh.RowID=et.EmployeeShiftID AND esh.RestDay=0
						WHERE et.OrganizationID=organiz_id
						AND et.`Date` BETWEEN SUBDATE(et_date, INTERVAL 5 DAY) AND SUBDATE(et_date, INTERVAL 1 DAY)
						AND et.TotalDayPay > 0
						
					UNION
						SELECT et.RowID
						FROM employeetimeentry et
						INNER JOIN employee e
								ON e.RowID=et.EmployeeID AND e.RowID=emp_rowid
						INNER JOIN payrate pr
								ON pr.RowID=et.PayRateID AND pr.`PayRate`!=@default_payrate AND pr.DayBefore=et.`Date`
						INNER JOIN employeeshift esh
								ON esh.RowID=et.EmployeeShiftID AND esh.RestDay=0
						WHERE et.OrganizationID=organiz_id
						AND et.`Date` BETWEEN SUBDATE(et_date, INTERVAL 5 DAY) AND SUBDATE(et_date, INTERVAL 1 DAY)
						AND et.TotalDayPay > 0
						
					) `Result`
	INTO returnvalue;*/

	SELECT EXISTS(
		SELECT et.RowID
		FROM employeetimeentry et
		INNER JOIN (SELECT ete.RowID
		            FROM employeetimeentry ete
						INNER JOIN employee e
						ON e.RowID=ete.EmployeeID AND e.OrganizationID=ete.OrganizationID AND e.RowID=emp_rowid
						INNER JOIN employeeshift esh ON esh.RowID=ete.EmployeeShiftID
						INNER JOIN payrate pr ON pr.RowID=ete.PayRateID AND pr.`PayRate`=@default_payrate
						WHERE ete.OrganizationID=organiz_id
						AND ete.`Date` < et_date
						ORDER BY ete.`Date` DESC
						LIMIT 1) ett ON ett.RowID=et.RowID
		# INNER JOIN employee e
		        # ON e.RowID=et.EmployeeID AND e.OrganizationID=et.OrganizationID AND e.RowID=emp_rowid
		# INNER JOIN employeeshift esh ON esh.RowID=et.EmployeeShiftID
		WHERE et.TotalDayPay > 0
		ORDER BY et.`Date` DESC
		LIMIT 1
	) `Result`
	INTO returnvalue;
	
ELSE

	SELECT EXISTS(
						SELECT CONCAT(etd.RowID,'ETD') `Result`
						FROM employeetimeentrydetails etd
						INNER JOIN employee e
								ON e.RowID=etd.EmployeeID AND e.RowID=emp_rowid
						INNER JOIN payrate pr ON pr.OrganizationID=etd.OrganizationID AND pr.`Date`=etd.`Date` AND pr.`PayRate` != @default_regholi_payrate #pr.`PayRate`=@default_payrate
						INNER JOIN employeeshift esh
								ON esh.RestDay=0 AND esh.OrganizationID=etd.OrganizationID AND esh.EmployeeID=etd.EmployeeID AND etd.`Date` BETWEEN esh.EffectiveFrom AND esh.EffectiveTo
						WHERE etd.OrganizationID=organiz_id
						AND etd.`Date` BETWEEN ADDDATE(et_date, INTERVAL 1 DAY) AND ADDDATE(et_date, INTERVAL 1 WEEK)
					
					UNION
						SELECT CONCAT(elv.RowID,'ELV') `Result`
						FROM employeeleave elv
						INNER JOIN dates d ON d.DateValue BETWEEN ADDDATE(et_date, INTERVAL 1 DAY) AND ADDDATE(et_date, INTERVAL 1 WEEK)
						WHERE elv.EmployeeID=emp_rowid
						AND elv.OrganizationID=organiz_id
						AND d.DateValue BETWEEN elv.LeaveStartDate AND elv.LeaveEndDate
						AND elv.`Status`='Approved'
					) `Result`
	INTO returnvalue;

END IF;

SET returnvalue = IFNULL(returnvalue,0);

RETURN returnvalue;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
