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

-- Dumping structure for procedure gotescopayrolldb_latest.VIEW_employeeloan_indate
DROP PROCEDURE IF EXISTS `VIEW_employeeloan_indate`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `VIEW_employeeloan_indate`(IN `eloan_EmployeeID` INT, IN `eloan_OrganizationID` INT, IN `effectivedatefrom` DATE, IN `effectivedateto` DATE)
    DETERMINISTIC
BEGIN

/*DECLARE isEndOfMonth CHAR(1);

DECLARE month_type VARCHAR(150);


SELECT pp.`Half` FROM payperiod pp WHERE pp.OrganizationID=eloan_OrganizationID AND pp.PayFromDate=effectivedatefrom AND pp.PayToDate=effectivedateto AND pp.TotalGrossSalary=1 INTO isEndOfMonth;

SET month_type = IF(isEndOfMonth = '0', 'End of the month', 'First half');


SELECT 
IFNULL(eloan.LoanNumber,'') 'LoanNumber'
,IFNULL(eloan.TotalLoanAmount,0.00) 'TotalLoanAmount'
,IFNULL(eloan.TotalBalanceLeft,0.00) 'TotalBalanceLeft'
,IFNULL(eloan.DeductionAmount,0.00) 'DeductionAmount'
,IFNULL(eloan.DeductionPercentage,0.00) 'DeductionPercentage'
,IFNULL(eloan.DeductionSchedule,'') 'DeductionSchedule'
,IFNULL(eloan.NoOfPayPeriod,0) 'NoOfPayPeriod'
,IFNULL(eloan.Comments,'') 'Comments'
,eloan.RowID
,IFNULL(eloan.`Status`,'') 'Status'
,IFNULL(p.PartNo,'') `PartNo`
,IF(IFNULL(p.Strength,0) = 0, 'No', 'Yes') `IsNondeductible`
 FROM employeeloanschedule eloan
 LEFT JOIN product p ON eloan.LoanTypeID=p.RowID
 WHERE eloan.EmployeeID=eloan_EmployeeID
 AND eloan.OrganizationID=eloan_OrganizationID
 AND eloan.DeductionSchedule IN (month_type,'Per pay period')
 AND (eloan.DedEffectiveDateFrom >= effectivedatefrom OR eloan.DedEffectiveDateTo >= effectivedatefrom)
 		AND (eloan.DedEffectiveDateFrom <= effectivedateto OR eloan.DedEffectiveDateTo <= effectivedateto);*/
 		
# ####################################

/*
AND IF(eloan.DedEffectiveDateFrom < effectivedateto
		,IF(MONTH(eloan.DedEffectiveDateFrom) = MONTH(effectivedateto)
			,IF(DAY(eloan.DedEffectiveDateFrom) BETWEEN DAY(effectivedatefrom) AND DAY(effectivedateto)
				,eloan.DedEffectiveDateFrom BETWEEN effectivedatefrom AND effectivedateto
				,eloan.DedEffectiveDateFrom<=effectivedateto)
			,eloan.DedEffectiveDateFrom<=effectivedateto)
		,eloan.DedEffectiveDateFrom<=effectivedateto);
*/

# ####################################

SELECT
IFNULL(els.LoanNumber,'') `LoanNumber`
,IFNULL(els.TotalLoanAmount,0) `TotalLoanAmount`
,IFNULL(els.TotalBalanceLeft,0) `TotalBalanceLeft`
,IFNULL(psi.PayAmount,0) `DeductionAmount`
,IFNULL(els.DeductionPercentage,0) `DeductionPercentage`
,IFNULL(els.DeductionSchedule,'') `DeductionSchedule`
,IFNULL(els.NoOfPayPeriod,0) `NoOfPayPeriod`
,IFNULL(els.Comments,'') `Comments`
,IFNULL(els.RowID,'') `RowID`
,IFNULL(els.`Status`,'') `Status`
,p.PartNo
,p.Strength
FROM paystub ps
INNER JOIN employee e ON e.RowID=ps.EmployeeID
INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID AND pp.TotalGrossSalary=e.PayFrequencyID AND pp.PayFromDate=effectivedatefrom AND pp.PayToDate=effectivedateto
INNER JOIN product p ON p.OrganizationID=ps.OrganizationID AND p.`Category`='Loan type'
LEFT JOIN paystubitem psi ON psi.PayStubID=ps.RowID AND psi.ProductID=p.RowID AND psi.PayAmount > 0

LEFT JOIN employeeloanschedule els ON els.EmployeeID=e.RowID AND els.OrganizationID=e.OrganizationID AND els.LoanTypeID=p.RowID AND els.DedEffectiveDateFrom >= pp.PayFromDate AND pp.PayToDate <= els.DedEffectiveDateTo

WHERE ps.EmployeeID=eloan_EmployeeID
AND ps.OrganizationID=eloan_OrganizationID
AND psi.RowID IS NOT NULL;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
