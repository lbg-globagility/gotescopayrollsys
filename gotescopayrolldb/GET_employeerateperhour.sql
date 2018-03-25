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

-- Dumping structure for function gotescopayrolldb_server.GET_employeerateperhour
DROP FUNCTION IF EXISTS `GET_employeerateperhour`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `GET_employeerateperhour`(`EmpID` INT, `OrgID` INT, `paramDate` DATE) RETURNS decimal(12,2)
    DETERMINISTIC
BEGIN

DECLARE hoursofduty DECIMAL(11,3);

DECLARE empBasicPay DECIMAL(11,3);

DECLARE dailyrate DECIMAL(11,3);

DECLARE rateperhour DECIMAL(11,3);

DECLARE numofweekthisyear INT(11) DEFAULT 53;
	
DECLARE shiftRowID INT(11);

DECLARE PayFreqID INT(11);

DECLARE emptype VARCHAR(100);

DECLARE timedifference TIME;

DECLARE orgnumberofworkingdays INT(11);

SELECT GET_empworkdaysperyear(EmpID) INTO orgnumberofworkingdays;


SELECT ShiftID FROM employeeshift WHERE EmployeeID=EmpID AND OrganizationID=OrgID AND paramDate BETWEEN DATE(COALESCE(EffectiveFrom,DATE_FORMAT(CURRENT_TIMESTAMP(),'%Y-%m-%d'))) AND DATE(COALESCE(EffectiveTo,ADDDATE(CURRENT_TIMESTAMP(), INTERVAL 1 MONTH))) AND DATEDIFF(paramDate,EffectiveFrom) >= 0 AND COALESCE(RestDay,0)=0 ORDER BY DATEDIFF(DATE_FORMAT(paramDate,'%Y-%m-%d'),EffectiveFrom) LIMIT 1 INTO shiftRowID;

SELECT SUBSTRING_INDEX(TIMEDIFF(TimeFrom,IF(TimeFrom>TimeTo,ADDTIME(TimeTo,'24:00:00'),TimeTo)),'-',-1) FROM shift WHERE RowID=shiftRowID INTO timedifference;

SET hoursofduty = ((TIME_TO_SEC(COALESCE(timedifference,'00:00:00')) / 60) / 60);


SELECT BasicPay FROM employeesalary WHERE EmployeeID=EmpID AND OrganizationID=OrgID AND paramDate BETWEEN DATE(COALESCE(EffectiveDateFrom,DATE_FORMAT(CURRENT_TIMESTAMP(),'%Y-%m-%d'))) AND DATE(COALESCE(EffectiveDateTo,ADDDATE(CURRENT_TIMESTAMP(), INTERVAL 1 MONTH))) AND DATEDIFF(paramDate,EffectiveDateFrom) >= 0 ORDER BY DATEDIFF(DATE_FORMAT(paramDate,'%Y-%m-%d'),EffectiveDateFrom) LIMIT 1 INTO empBasicPay;

SET empBasicPay = COALESCE(empBasicPay,0);

SELECT PayFrequencyID,WEEKOFYEAR(LAST_DAY(CONCAT(YEAR(paramDate),'-12-01'))) FROM organization WHERE RowID=OrgID INTO PayFreqID,numofweekthisyear;

SELECT PayFrequencyID,EmployeeType FROM employee WHERE RowID=EmpID INTO PayFreqID,emptype;



IF emptype IN ('Fixed','Monthly') THEN
		
		IF PayFreqID = 1 THEN
				SET dailyrate = IF(DAY(LAST_DAY(ADDDATE(MAKEDATE(YEAR(paramDate),1), INTERVAL 1 MONTH))) <= 28, (empBasicPay * 24) / orgnumberofworkingdays, (empBasicPay * 24) / (orgnumberofworkingdays + 1));
	
		ELSEIF PayFreqID = 2 THEN
				SET dailyrate = IF(DAY(LAST_DAY(ADDDATE(MAKEDATE(YEAR(paramDate),1), INTERVAL 1 MONTH))) <= 28, (empBasicPay * 12) / orgnumberofworkingdays, (empBasicPay * 12) / (orgnumberofworkingdays + 1));
	
		ELSEIF PayFreqID = 3 THEN
				SET dailyrate = empBasicPay;
	
		ELSEIF PayFreqID = 4 THEN
				SET dailyrate = IF(DAY(LAST_DAY(ADDDATE(MAKEDATE(YEAR(paramDate),1), INTERVAL 1 MONTH))) <= 28, (empBasicPay * numofweekthisyear) / orgnumberofworkingdays, (empBasicPay * numofweekthisyear) / (orgnumberofworkingdays + 1));
	
		END IF;
		
			SET rateperhour = dailyrate / hoursofduty;
		
ELSEIF emptype = 'Daily' THEN
		
			SET dailyrate = empBasicPay;
		
			SET rateperhour = dailyrate / hoursofduty;
		
ELSEIF emptype = 'Hourly' THEN
		SET rateperhour = empBasicPay;
		
		



END IF;
		
RETURN COALESCE(rateperhour,0);

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
