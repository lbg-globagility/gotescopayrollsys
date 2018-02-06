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

-- Dumping structure for procedure gotescopayrolldb_latest.RECOMPUTE_thirteenthmonthpay
DROP PROCEDURE IF EXISTS `RECOMPUTE_thirteenthmonthpay`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `RECOMPUTE_thirteenthmonthpay`(IN `OrganizID` INT, IN `PayPRowID` INT, IN `UserRowID` INT)
    DETERMINISTIC
BEGIN

DECLARE ispayperiodendofmonth TEXT;

DECLARE newvalue DECIMAL(11,6);

DECLARE payp_month TEXT;

DECLARE payp_year INT;

DECLARE emppayfreqID INT(11);

DECLARE paypmonthlyID VARCHAR(50);

DECLARE last_date DATE;

DECLARE month_firstdate DATE;


SELECT pyp.`Half`, pyp.`Month`, pyp.`Year`, pyp.TotalGrossSalary
,pyp.PayToDate
FROM payperiod pyp
WHERE pyp.RowID=PayPRowID INTO ispayperiodendofmonth, payp_month, payp_year, emppayfreqID
,last_date;

SELECT pp.PayFromDate FROM payperiod pp WHERE pp.OrganizationID=OrganizID AND pp.`Year`=payp_year AND pp.`Month`=payp_month AND pp.TotalGrossSalary=emppayfreqID ORDER BY pp.PayFromDate,pp.PayToDate LIMIT 1 INTO month_firstdate;

SELECT pp.PayToDate FROM payperiod pp WHERE pp.OrganizationID=OrganizID AND pp.`Year`=payp_year AND pp.`Month`=payp_month AND pp.TotalGrossSalary=emppayfreqID ORDER BY pp.PayFromDate DESC,pp.PayToDate DESC LIMIT 1 INTO last_date;

SELECT GROUP_CONCAT(RowID) FROM payperiod pp WHERE pp.OrganizationID=OrganizID AND pp.TotalGrossSalary=1 AND pp.`Year`=payp_year AND pp.`Month`=payp_month ORDER BY pp.PayFromDate DESC, pp.PayToDate DESC INTO paypmonthlyID;



IF ispayperiodendofmonth = '0' THEN

	INSERT INTO thirteenthmonthpay
	(
		RowID
		,OrganizationID
		,Created
		,CreatedBy
		,PaystubID
		,Amount
		,Amount14
		,Amount15
		,Amount16
	) SELECT 
		GET_prev13monthRowID(OrganizID, PayPRowID, ii.EmployeeID)
		,OrganizID
		,CURRENT_TIMESTAMP()
		,UserRowID
		,ps.RowID
		,ii.BasicAmount / 12.0
		,0
		,0
		,0
		FROM
		(
			SELECT
			SUM(ete.RegularHoursAmount) AS BasicAmount
			,ete.EmployeeID
			FROM employeetimeentry ete
			INNER JOIN (SELECT * FROM employee WHERE OrganizationID=OrganizID AND EmployeeType='Daily' AND PayFrequencyID=emppayfreqID) e ON e.RowID=ete.EmployeeID
			WHERE ete.OrganizationID=OrganizID
			AND ete.`Date` BETWEEN month_firstdate AND last_date
			GROUP BY ete.EmployeeID
		UNION
			SELECT
			SUM(es.Salary) AS BasicAmount
			,e.RowID AS EmployeeID
			FROM employee e
			INNER JOIN employeesalary es ON es.EmployeeID=e.RowID AND last_date BETWEEN es.EffectiveDateFrom AND IFNULL(es.EffectiveDateTo,last_date)
			WHERE e.PayFrequencyID=emppayfreqID
			AND e.OrganizationID=OrganizID
			AND e.EmployeeType IN ('Monthly','Fixed')
		) ii
		INNER JOIN paystub ps ON ps.OrganizationID=OrganizID AND ps.PayPeriodID=PayPRowID AND ps.EmployeeID=ii.EmployeeID
	ON
	DUPLICATE
	KEY
	UPDATE
		LastUpd=CURRENT_TIMESTAMP()
		,LastUpdBy=UserRowID
		,Amount=ii.BasicAmount / 12.0
		,Amount14=0
		,Amount15=0
		,Amount16=0;
		
	
		

END IF;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
