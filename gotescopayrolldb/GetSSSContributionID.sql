/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP FUNCTION IF EXISTS `GetSSSContributionID`;
DELIMITER //
CREATE FUNCTION `GetSSSContributionID`(`employeeType` TEXT,
	`workDaysPerYear` DECIMAL(10,2),
	`salaryAmount` DECIMAL(10,2),
	`salaryEffectiveDateFrom` DATE,
	`salaryEffectiveDateTo` DATE



) RETURNS decimal(10,0)
    DETERMINISTIC
BEGIN

DECLARE returnValue DECIMAL DEFAULT NULL;

DECLARE dailyType TEXT DEFAULT 'daily';
DECLARE monthCount INT DEFAULT 12;

IF LCASE(employeeType) = dailyType THEN
	SET salaryAmount = (salaryAmount * workDaysPerYear) / monthCount;
END IF;

SELECT sss.RowID
FROM paysocialsecurity sss
WHERE salaryAmount BETWEEN sss.RangeFromAmount AND sss.RangeToAmount
#AND (sss.EffectiveDateFrom <= salaryEffectiveDateFrom OR sss.EffectiveDateTo <= salaryEffectiveDateFrom)
#AND (sss.EffectiveDateFrom >= salaryEffectiveDateTo OR sss.EffectiveDateTo >= salaryEffectiveDateTo)
AND ((salaryEffectiveDateFrom BETWEEN sss.EffectiveDateFrom AND sss.EffectiveDateTo)
		OR (salaryEffectiveDateTo BETWEEN sss.EffectiveDateFrom AND sss.EffectiveDateTo))
LIMIT 1
INTO returnValue
;

#SELECT salaryAmount, returnValue INTO OUTFILE 'D:/TEST.txt';

RETURN returnValue;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
