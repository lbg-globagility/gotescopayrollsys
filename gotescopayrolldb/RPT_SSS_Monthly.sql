/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `RPT_SSS_Monthly`;
DELIMITER //
CREATE PROCEDURE `RPT_SSS_Monthly`(IN `OrganizID` INT, IN `paramDate` DATE)
    DETERMINISTIC
BEGIN

DECLARE deduc_sched VARCHAR(50);

DECLARE ii INT(11) DEFAULT -1;

DECLARE indx INT(11) DEFAULT -1;

DECLARE mirr_EmpID INT(11) DEFAULT -1;

DECLARE mirr_Amount DECIMAL(10,2) DEFAULT -1;


DECLARE semimo_paydatefrom DATE;

DECLARE semimo_paydatefrom_cutoff_to DATE;

DECLARE semimo_paydateto DATE;

DECLARE semimo_paydateto_cutoff_from DATE;

DECLARE wk_paydatefrom DATE;

DECLARE wk_paydateto DATE;

DECLARE includeOvertimeInSss BOOL DEFAULT FALSE;

SELECT PagIbigDeductionSchedule FROM organization WHERE RowID=OrganizID INTO deduc_sched;




SELECT pyp.PayFromDate, pyp.PayToDate FROM payperiod pyp WHERE pyp.OrganizationID=OrganizID AND pyp.`Year`=YEAR(paramDate) AND pyp.`Month`=(MONTH(paramDate) * 1) AND pyp.TotalGrossSalary=1 ORDER BY pyp.PayFromDate, pyp.PayToDate LIMIT 1 INTO semimo_paydatefrom, semimo_paydatefrom_cutoff_to;
	
SELECT pyp.PayToDate, pyp.PayFromDate FROM payperiod pyp WHERE pyp.OrganizationID=OrganizID AND pyp.`Year`=YEAR(paramDate) AND pyp.`Month`=(MONTH(paramDate) * 1) AND pyp.TotalGrossSalary=1 ORDER BY pyp.PayFromDate DESC, pyp.PayToDate DESC LIMIT 1 INTO semimo_paydateto, semimo_paydateto_cutoff_from;
	
	
SELECT pyp.PayFromDate FROM payperiod pyp WHERE pyp.OrganizationID=OrganizID AND pyp.`Year`=YEAR(paramDate) AND pyp.`Month`=(MONTH(paramDate) * 1) AND pyp.TotalGrossSalary=4 ORDER BY pyp.PayFromDate, pyp.PayToDate LIMIT 1 INTO wk_paydatefrom;
	
SELECT pyp.PayToDate FROM payperiod pyp WHERE pyp.OrganizationID=OrganizID AND pyp.`Year`=YEAR(paramDate) AND pyp.`Month`=(MONTH(paramDate) * 1) AND pyp.TotalGrossSalary=4 ORDER BY pyp.PayFromDate DESC, pyp.PayToDate DESC LIMIT 1 INTO wk_paydateto;

SET includeOvertimeInSss = EXISTS(SELECT RowID FROM listofval l WHERE l.`Type`='SocialSecuritySystem' AND l.LIC='IncludeOvertime' AND l.DisplayValue=TRUE);

#Dont remove comments, used in testing
/*DROP TEMPORARY TABLE IF EXISTS Temp_SSS_Monthly;
CREATE TEMPORARY TABLE Temp_SSS_Monthly*/
SELECT 
ee.SSSNo `DatCol1`
,@fullName:=CONCAT(ee.LastName,',',ee.FirstName, IF(ee.MiddleName='','',','),INITIALS(ee.MiddleName,'. ','1')) `FullName`
,pss.EmployeeContributionAmount `DatCol3`



, pss.EmployerContributionAmount `DatCol4`
, pss.EmployerECAmount `DatCol5`
, (ps.TotalCompSSS + ps.TotalEmpSSS) `DatCol6`

, @basicPay:=(CASE ee.EmployeeType
	WHEN 'Fixed' THEN IFNULL((SELECT Salary FROM employeesalary
								WHERE EmployeeID = ee.RowID
								AND employeesalary.EffectiveDateFrom <= semimo_paydateto
								AND semimo_paydatefrom <= employeesalary.EffectiveDateTo),0)
	WHEN 'Monthly' THEN
							IF(
								#WHEN first time salary End of the month or First half
								(IF(ee.AgencyID IS NOT NULL, IFNULL(d.SSSDeductSchedAgency,d.SSSDeductSched), d.SSSDeductSched)
									= 'End of the month' AND
								ee.StartDate BETWEEN semimo_paydatefrom_cutoff_to AND semimo_paydateto)
								OR
								(IF(ee.AgencyID IS NOT NULL, IFNULL(d.SSSDeductSchedAgency,d.SSSDeductSched), d.SSSDeductSched)
									= 'First half' AND
								ee.StartDate BETWEEN semimo_paydatefrom AND semimo_paydatefrom_cutoff_to)
								,
								#THEN compute by TotalDayPay
								IFNULL((SELECT SUM(TotalDayPay - OvertimeHoursAmount) FROM employeetimeentry
								WHERE EmployeeID = ee.RowID AND Date BETWEEN semimo_paydatefrom AND semimo_paydateto),0)
								,
								#ELSE
								/*IF(
									#WHEN first time salary Per pay period
									(IF(ee.AgencyID IS NOT NULL, IFNULL(d.SSSDeductSchedAgency,d.SSSDeductSched), d.SSSDeductSched)
									= 'Per pay period' AND
									ee.StartDate BETWEEN semimo_paydatefrom AND semimo_paydateto)
									#THEN check first for all possible combinations of pay
									,*/
								IFNULL((SELECT Salary FROM employeesalary
								WHERE EmployeeID = ee.RowID
								AND employeesalary.EffectiveDateFrom <= semimo_paydateto
								AND semimo_paydatefrom <= employeesalary.EffectiveDateTo),0)
								-
								IFNULL((SELECT SUM(HoursLateAmount + UndertimeHoursAmount + Absent) FROM employeetimeentry
								WHERE EmployeeID = ee.RowID AND Date BETWEEN semimo_paydatefrom AND semimo_paydateto),0)
								+
								IFNULL((SELECT SUM(NightDiffHoursAmount + NightDiffOTHoursAmount + AddedHolidayPayAmount) FROM employeetimeentry
								WHERE EmployeeID = ee.RowID AND Date BETWEEN semimo_paydatefrom AND semimo_paydateto),0)
							)
	WHEN 'Daily' THEN IFNULL((SELECT SUM(TotalDayPay - OvertimeHoursAmount) FROM employeetimeentry
								WHERE EmployeeID = ee.RowID AND Date BETWEEN semimo_paydatefrom AND semimo_paydateto),0)
	END) AS `BasicPay`
, CONCAT_WS(' - ', CAST(@fullName AS CHAR CHARACTER SET utf8), FORMAT(@basicPay, 2)) `DatCol2`

, pss.EmployeeMPFAmount `DatCol7`
, pss.EmployerMPFAmount `DatCol8`

FROM paystub ps
INNER JOIN employee ee ON ee.RowID=ps.EmployeeID AND ee.PayFrequencyID=1 AND FIND_IN_SET(ee.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0

LEFT JOIN `position` po ON po.RowID=ee.PositionID
LEFT JOIN division d ON d.RowID=po.DivisionId

INNER JOIN paysocialsecurity pss ON (pss.EmployeeContributionAmount + pss.EmployeeMPFAmount + pss.EmployerContributionAmount + pss.EmployerECAmount + pss.EmployerMPFAmount)=(ps.TotalEmpSSS + ps.TotalCompSSS) AND LAST_DAY(paramDate) BETWEEN pss.EffectiveDateFrom AND pss.EffectiveDateTo

INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID AND LAST_DAY(paramDate) = LAST_DAY(STR_TO_DATE(CONCAT(pp.`Month`, '-', 1, '-', pp.`Year`), '%c-%e-%Y'))

WHERE ps.OrganizationID=OrganizID
AND (ps.TotalEmpSSS + ps.TotalCompSSS) > 0
order BY CONCAT(ee.LastName, ee.FirstName)
;

#Dont remove comments, used in testing
/*SELECT * FROM Temp_SSS_Monthly;*/
#===
/*SELECT t.*, s.EmployeeContributionAmount, s.EmployerContributionAmount, s.* FROM Temp_SSS_Monthly t
INNER JOIN paysocialsecurity s
ON t.DatCol7 BETWEEN s.RangeFromAmount AND s.RangeToAmount
AND s.EffectiveDateFrom >= '2019-04-01'
AND t.DatCol3 <> s.EmployeeContributionAmount
;*/


END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
