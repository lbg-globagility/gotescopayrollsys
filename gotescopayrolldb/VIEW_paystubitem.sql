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

-- Dumping structure for procedure gotescopayrolldb_server.VIEW_paystubitem
DROP PROCEDURE IF EXISTS `VIEW_paystubitem`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `VIEW_paystubitem`(IN `paystitm_PayStubID` INT)
    DETERMINISTIC
BEGIN

DECLARE primary_datefrom DATE;
DECLARE primary_dateto DATE;

SELECT pyp.PayFromDate
,pp.PayToDate
FROM payperiod pp
INNER JOIN paystub ps ON ps.RowID=paystitm_PayStubID AND ps.PayPeriodID=pp.RowID
INNER JOIN payperiod pyp ON pyp.`Year`=pp.`Year` AND pyp.TotalGrossSalary=pp.TotalGrossSalary AND pyp.OrganizationID=ps.OrganizationID

ORDER BY pyp.PayFromDate,pyp.PayToDate
LIMIT 1
INTO primary_datefrom,primary_dateto;
	
	SELECT paystitm.RowID 'paystitmID'
	,paystitm.PayStubID 'PayStubID'
	,paystitm.ProductID 'ProductID'
	,SUBSTRING_INDEX(p.PartNo,'.',-1) 'Item'
	,paystitm.PayAmount 'PayAmount'
	FROM paystubitem paystitm
	INNER JOIN product p ON p.RowID=paystitm.ProductID AND p.`Category`!='Leave Type'
	WHERE PayStubID=paystitm_PayStubID
	AND Undeclared = '0'
UNION ALL
	SELECT paystitm.RowID 'paystitmID'
	,paystitm.PayStubID 'PayStubID'
	,paystitm.ProductID 'ProductID'
	,SUBSTRING_INDEX(p.PartNo,'.',-1) 'Item'
	,IF(BINARY p.PartNo = BINARY et0.ItemName, (paystitm.PayAmount - IFNULL(et0.LeaveHours,0)),
		IF(BINARY p.PartNo = BINARY et1.ItemName, (paystitm.PayAmount - IFNULL(et1.LeaveHours,0)),
			IF(BINARY p.PartNo = BINARY et2.ItemName, (paystitm.PayAmount - IFNULL(et2.LeaveHours,0)),
				IF(BINARY p.PartNo = BINARY et3.ItemName, (paystitm.PayAmount - IFNULL(et3.LeaveHours,0)),
					(paystitm.PayAmount - IFNULL(et4.LeaveHours,0)))))) AS PayAmount
	
	FROM paystubitem paystitm
	INNER JOIN paystub ps ON ps.RowID=paystitm.PayStubID AND ps.RowID=paystitm_PayStubID
	
	LEFT JOIN (SELECT OrganizationID,EmployeeID,`Date`,SUM(VacationLeaveHours) AS LeaveHours,'Vacation leave' AS ItemName FROM employeetimeentry WHERE VacationLeaveHours > 0 AND `Date` BETWEEN primary_datefrom AND primary_dateto GROUP BY EmployeeID) et0 ON et0.OrganizationID=ps.OrganizationID AND et0.EmployeeID=ps.EmployeeID
	
	
	LEFT JOIN (SELECT OrganizationID,EmployeeID,`Date`,SUM(SickLeaveHours) AS LeaveHours,'Sick leave' AS ItemName FROM employeetimeentry WHERE SickLeaveHours > 0 AND `Date` BETWEEN primary_datefrom AND primary_dateto GROUP BY EmployeeID) et1 ON et1.OrganizationID=ps.OrganizationID AND et1.EmployeeID=ps.EmployeeID
	
	
	LEFT JOIN (SELECT OrganizationID,EmployeeID,`Date`,SUM(MaternityLeaveHours) AS LeaveHours,'Maternity/paternity leave' AS ItemName FROM employeetimeentry WHERE MaternityLeaveHours > 0 AND `Date` BETWEEN primary_datefrom AND primary_dateto GROUP BY EmployeeID) et2 ON et2.OrganizationID=ps.OrganizationID AND et2.EmployeeID=ps.EmployeeID
	
	
	LEFT JOIN (SELECT OrganizationID,EmployeeID,`Date`,SUM(OtherLeaveHours) AS LeaveHours,'Others' AS ItemName FROM employeetimeentry WHERE OtherLeaveHours > 0 AND `Date` BETWEEN primary_datefrom AND primary_dateto GROUP BY EmployeeID) et3 ON et3.OrganizationID=ps.OrganizationID AND et3.EmployeeID=ps.EmployeeID
	
	
	LEFT JOIN (SELECT OrganizationID,EmployeeID,`Date`,SUM(AdditionalVLHours) AS LeaveHours,'Additional VL' AS ItemName FROM employeetimeentry WHERE AdditionalVLHours > 0 AND `Date` BETWEEN primary_datefrom AND primary_dateto GROUP BY EmployeeID) et4 ON et4.OrganizationID=ps.OrganizationID AND et4.EmployeeID=ps.EmployeeID
	
	
	INNER JOIN product p ON p.RowID=paystitm.ProductID AND p.`Category`='Leave Type' AND p.OrganizationID=ps.OrganizationID
	WHERE paystitm.Undeclared='0'
	GROUP BY paystitm.RowID;



END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
