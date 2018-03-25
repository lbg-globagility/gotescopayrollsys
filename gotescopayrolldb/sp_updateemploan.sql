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

-- Dumping structure for procedure gotescopayrolldb_server.sp_updateemploan
DROP PROCEDURE IF EXISTS `sp_updateemploan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateemploan`(IN `I_Lastupd` DATETIME, IN `I_Lastupdby` INT(10), IN `I_LoanNumber` VARCHAR(50), IN `I_DedEffectiveDateFrom` DATE, IN `I_DedEffectiveDateTo` DATE, IN `I_TotalLoanAmount` DECIMAL(10,2), IN `I_DeductionSchedule` VARCHAR(50), IN `I_DeductionAmount` DECIMAL(10,2), IN `I_Status` VARCHAR(50), IN `I_DeductionPercentage` DECIMAL(10,2), IN `I_NoOfPayPeriod` DECIMAL(10,2), IN `I_Comments` VARCHAR(2000), IN `I_RowID` INT(10), IN `I_LoanTypeID` INT)
    DETERMINISTIC
BEGIN
UPDATE employeeloanschedule els
SET
	els.LastUpd = I_LastUpd,
	els.LastUpdBy = I_LastUpdBy,
	els.LoanNumber = I_LoanNumber,
	els.DedEffectiveDateFrom = I_DedEffectiveDateFrom,
	els.DedEffectiveDateTo = PAYTODATE_OF_NoOfPayPeriod(I_DedEffectiveDateFrom, els.NoOfPayPeriod, els.EmployeeID, I_DeductionSchedule),
	els.TotalLoanAmount = I_TotalLoanAmount,
	els.DeductionSchedule = I_DeductionSchedule,
	els.DeductionAmount = I_DeductionAmount,
	els.`Status` = I_Status,
	els.DeductionPercentage = I_DeductionPercentage,
	els.NoOfPayPeriod = I_NoOfPayPeriod,
	els.Comments = I_Comments,
	els.LoanTypeID = I_LoanTypeID
	,els.TotalBalanceLeft = els.TotalLoanAmount
	,els.DeductionAmount = (els.TotalLoanAmount / els.NoOfPayPeriod)
	,els.LoanPayPeriodLeft = els.NoOfPayPeriod
WHERE RowID = I_RowID
AND els.TotalLoanAmount = els.TotalBalanceLeft;
END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
