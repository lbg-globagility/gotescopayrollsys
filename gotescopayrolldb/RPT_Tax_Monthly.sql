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

-- Dumping structure for procedure gotescopayrolldb_server.RPT_Tax_Monthly
DROP PROCEDURE IF EXISTS `RPT_Tax_Monthly`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `RPT_Tax_Monthly`(IN `OrganizID` INT, IN `paramDateFrom` DATE, IN `paramDateTo` DATE)
    DETERMINISTIC
BEGIN

DECLARE deduc_sched VARCHAR(50);

SELECT PagIbigDeductionSchedule FROM organization WHERE RowID=OrganizID INTO deduc_sched;

IF deduc_sched = 'First half of next month' THEN

	SELECT
	ee.TINNo `DatCol1`
	,CONCAT(ee.LastName,',',ee.FirstName, IF(ee.MiddleName='','',','),INITIALS(ee.MiddleName,'. ','1')) `DatCol2`
	,FORMAT(SUM(ps.TotalTaxableSalary),2) `DatCol3`
	,FORMAT(SUM(ps.TotalEmpWithholdingTax),2) `DatCol4`
	,0.0 `DatCol5`
	,0.0  `DatCol6`
	FROM paystub ps
	
	INNER JOIN employee ee ON ee.RowID=ps.EmployeeID AND ee.OrganizationID=ps.OrganizationID AND FIND_IN_SET(ee.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
	
	INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID
	
	INNER JOIN payperiod pyp ON pyp.RowID=ps.PayPeriodID AND pyp.OrganizationID=ps.OrganizationID AND pyp.`Month`=(pp.`Month` - 1) AND pyp.`Half`='0'
	
	INNER JOIN product pd ON pd.OrganizationID=ps.OrganizationID AND pd.PartNo='Gross Income'
	
	LEFT JOIN paystubitem psi ON psi.PayStubID=ps.RowID AND psi.ProductID=pd.RowID AND psi.`Undeclared`='0'
	
	WHERE ps.OrganizationID=OrganizID
	AND ps.PayFromDate >= paramDateFrom
	AND ps.PayToDate <= paramDateTo
	GROUP BY ps.EmployeeID
	ORDER BY ee.LastName,ee.FirstName;
	
ELSE

	SELECT
	ee.TINNo `DatCol1`
	,CONCAT(ee.LastName,',',ee.FirstName, IF(ee.MiddleName='','',','),INITIALS(ee.MiddleName,'. ','1')) `DatCol2`
	,FORMAT(SUM(ps.TotalTaxableSalary),2) `DatCol3`
	,FORMAT(SUM(ps.TotalEmpWithholdingTax),2) `DatCol4`
	,(SELECT FORMAT(SUM(TotalTaxableSalary),2) FROM paystub WHERE EmployeeID=ps.EmployeeID AND OrganizationID=OrganizID AND PayFromDate>=MAKEDATE(YEAR(paramDateTo),1) AND PayToDate<=paramDateTo) `DatCol5`
	,(SELECT FORMAT(SUM(TotalEmpWithholdingTax),2) FROM paystub WHERE EmployeeID=ps.EmployeeID AND OrganizationID=OrganizID AND PayFromDate>=MAKEDATE(YEAR(paramDateTo),1) AND PayToDate<=paramDateTo) `DatCol6`
	FROM paystub ps
	LEFT JOIN employee ee ON ee.RowID=ps.EmployeeID AND ee.OrganizationID=ps.OrganizationID AND FIND_IN_SET(ee.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
	
	INNER JOIN product pd ON pd.OrganizationID=OrganizID AND pd.PartNo='Gross Income'
	LEFT JOIN paystubitem psi ON psi.PayStubID=ps.RowID AND psi.ProductID=pd.RowID AND psi.`Undeclared`='0'
	
	WHERE ps.OrganizationID=OrganizID
	AND ps.PayFromDate>=paramDateFrom
	AND ps.PayToDate<=paramDateTo
	GROUP BY ps.EmployeeID
	ORDER BY ee.LastName;
	

END IF;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
