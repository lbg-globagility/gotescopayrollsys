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

-- Dumping structure for procedure gotescopayrolldb_server.DBoard_EmployeeLackRequirements
DROP PROCEDURE IF EXISTS `DBoard_EmployeeLackRequirements`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `DBoard_EmployeeLackRequirements`(IN `OrganizID` INT)
    DETERMINISTIC
BEGIN

SET @anyvchar = '';

SELECT
e.EmployeeID
,CONCAT(e.LastName,',',e.FirstName,',',INITIALS(e.MiddleName,'.','1')) 'Employee Fullname'
,CONCAT(IF(IFNULL(eck.PerformanceAppraisal,0)='1','',(@anyvchar := 'no Performance appraisal'))
,IF(IFNULL(eck.BIRTIN,0)='1','',',no BIR TIN')
,IF(IFNULL(eck.Diploma,0)='1','',',no Diploma')
,IF(IFNULL(eck.IDInfoSlip,0)='1','',',no ID Info slip')
,IF(IFNULL(eck.PhilhealthID,0)='1','',',no Philhealth ID')
,IF(IFNULL(eck.HDMFID,0)='1','',',no HDMF ID')
,IF(IFNULL(eck.SSSNo,0)='1','',',no SSS No')
,IF(IFNULL(eck.TranscriptOfRecord,0)='1','',',no Transcript of record')
,IF(IFNULL(eck.BirthCertificate,0)='1','',',no Birth certificate')
,IF(IFNULL(eck.EmployeeContract,0)='1','',',no Employee contract')
,IF(IFNULL(eck.MedicalExam,0)='1','',',no Medical exam')
,IF(IFNULL(eck.NBIClearance,0)='1','',',no NBI clearance')
,IF(IFNULL(eck.COEEmployer,0)='1','',',no COE employer')
,IF(IFNULL(eck.MarriageContract,0)='1','',',no Marriage contract')
,IF(IFNULL(eck.HouseSketch,0)='1','',',no House sketch')
,IF(IFNULL(eck.TrainingAgreement,0)='1','',',no fdsfsd')
,IF(IFNULL(eck.HealthPermit,0)='1','',',no Health permit')
,IF(IFNULL(eck.ValidID,0)='1','',',no SSS loan certificate')
,IF(IFNULL(eck.Resume,0)='1','',',no Resume')
,IF(IFNULL(eck.PAGIBIGLoan,0)='1','',',no HDMF Loan')
,IF(IFNULL(eck.Clearance,0)='1','',',no Clearance')) AS LackRequirements
FROM employeechecklist eck
INNER JOIN (SELECT RowID,CONCAT(IFNULL(PerformanceAppraisal,0),',',IFNULL(BIRTIN,0),',',IFNULL(Diploma,0),',',IFNULL(IDInfoSlip,0),',',IFNULL(PhilhealthID,0),',',IFNULL(HDMFID,0),',',IFNULL(SSSNo,0),',',IFNULL(TranscriptOfRecord,0),',',IFNULL(BirthCertificate,0),',',IFNULL(EmployeeContract,0),',',IFNULL(MedicalExam,0),',',IFNULL(NBIClearance,0),',',IFNULL(COEEmployer,0),',',IFNULL(MarriageContract,0),',',IFNULL(HouseSketch,0),',',IFNULL(TrainingAgreement,0),',',IFNULL(HealthPermit,0),',',IFNULL(ValidID,0),',',IFNULL(Resume,0),',',IFNULL(PAGIBIGLoan,0),',',IFNULL(Clearance,0)) AS ConcatColumn FROM employeechecklist) echk ON echk.RowID = eck.RowID AND LOCATE(0,echk.ConcatColumn) > 0
LEFT JOIN employee e ON e.RowID=eck.EmployeeID
WHERE eck.OrganizationID=OrganizID
ORDER BY e.LastName,e.FirstName;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
