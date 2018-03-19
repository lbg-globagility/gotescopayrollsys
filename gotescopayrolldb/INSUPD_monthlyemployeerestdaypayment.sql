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

-- Dumping structure for procedure gotescopayrolldb.INSUPD_monthlyemployeerestdaypayment
DROP PROCEDURE IF EXISTS `INSUPD_monthlyemployeerestdaypayment`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSUPD_monthlyemployeerestdaypayment`(IN `og_rowid` INT, IN `e_rowid` INT, IN `pp_rowid` INT, IN `user_rowid` INT)
    DETERMINISTIC
BEGIN

DECLARE ps_rowid INT(11);

DECLARE date_from
        , date_to DATE;

SELECT ps.RowID
,ps.PayFromDate
,ps.PayToDate
FROM paystub ps
WHERE ps.OrganizationID = og_rowid
AND ps.EmployeeID = e_rowid
AND ps.PayPeriodID = pp_rowid
INTO ps_rowid
     ,date_from
     ,date_to;

# SET SESSION low_priority_updates = ON;# LOW_PRIORITY 

# INSERT LOW_PRIORITY INTO `paystubitem` (`OrganizationID`, `Created`, `CreatedBy`, `LastUpd`, `LastUpdBy`, `PayStubID`, `ProductID`, `PayAmount`, `Undeclared`)
INSERT INTO `paystubitem` (`OrganizationID`, `Created`, `CreatedBy`, `LastUpd`, `LastUpdBy`, `PayStubID`, `ProductID`, `PayAmount`, `Undeclared`)
SELECT p.OrganizationID
,CURRENT_TIMESTAMP()
,user_rowid
,CURRENT_TIMESTAMP()
,user_rowid
,ps_rowid
,p.RowID
,IFNULL(i.`AddtlRestDayPayment`, 0)
,FALSE
FROM product p
LEFT JOIN (SELECT
           SUM(i.AddtlRestDayPayment) `AddtlRestDayPayment`
			  FROM monthlyemployee_restday_payment i
			  INNER JOIN employee e ON e.RowID=i.EmployeeID AND e.OrganizationID=i.OrganizationID AND e.RowID=e_rowid
			  WHERE i.`Date` BETWEEN date_from AND date_to
			  AND i.OrganizationID=og_rowid) i ON i.`AddtlRestDayPayment` IS NOT NULL
WHERE p.PartNo='Restday pay'
AND p.OrganizationID=og_rowid
ON 
DUPLICATE 
KEY 
UPDATE 
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=user_rowid
	,ProductID=p.RowID
	,PayAmount=IFNULL(i.`AddtlRestDayPayment`, 0)
	,Undeclared=FALSE
;

# INSERT LOW_PRIORITY INTO `paystubitem` (`OrganizationID`, `Created`, `CreatedBy`, `LastUpd`, `LastUpdBy`, `PayStubID`, `ProductID`, `PayAmount`, `Undeclared`)
INSERT INTO `paystubitem` (`OrganizationID`, `Created`, `CreatedBy`, `LastUpd`, `LastUpdBy`, `PayStubID`, `ProductID`, `PayAmount`, `Undeclared`)
SELECT p.OrganizationID
,CURRENT_TIMESTAMP()
,user_rowid
,CURRENT_TIMESTAMP()
,user_rowid
,ps_rowid
,p.RowID
,IFNULL(i.`AddtlRestDayPayment`, 0)
,TRUE
FROM product p
LEFT JOIN (SELECT
           (i.ActualPercentage * SUM(i.AddtlRestDayPayment)) `AddtlRestDayPayment`
			  FROM monthlyemployee_restday_payment i
			  INNER JOIN employee e ON e.RowID=i.EmployeeID AND e.OrganizationID=i.OrganizationID AND e.RowID=e_rowid
			  WHERE i.`Date` BETWEEN date_from AND date_to
			  AND i.OrganizationID=og_rowid) i ON i.`AddtlRestDayPayment` IS NOT NULL
WHERE p.PartNo='Restday pay'
AND p.OrganizationID=og_rowid
ON 
DUPLICATE 
KEY 
UPDATE 
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=user_rowid
	,ProductID=p.RowID
	,PayAmount=IFNULL(i.`AddtlRestDayPayment`, 0)
	,Undeclared=TRUE
;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
