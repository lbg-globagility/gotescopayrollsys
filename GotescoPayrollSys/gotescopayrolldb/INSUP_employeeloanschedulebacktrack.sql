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

-- Dumping structure for function gotescopayrolldb_oct19.INSUP_employeeloanschedulebacktrack
DROP FUNCTION IF EXISTS `INSUP_employeeloanschedulebacktrack`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `INSUP_employeeloanschedulebacktrack`(`OrganizID` INT, `UserRowID` INT, `EmpRowID` INT, `PaystubRowID` INT, `LoanSchedRowID` INT, `LoanBalance` DECIMAL(12,6), `LoanPayPeriodLeft` DECIMAL(12,6), `AmountPerDeduct` DECIMAL(12,6), `Estatus` CHAR(12)) RETURNS int(11)
    DETERMINISTIC
BEGIN

DECLARE returnvalue INT(11);

INSERT INTO employeeloanschedulebacktrack
(
	OrganizationID
	,CreatedBy
	,EmployeeID
	,PayStubID
	,LoanschedID
	,Balance
	,CountPayPeriodLeft
	,DeductedAmount
	,`Status`
) VALUES (
	OrganizID
	,UserRowID
	,EmpRowID
	,PaystubRowID
	,LoanSchedRowID
	,LoanBalance
	,LoanPayPeriodLeft
	,AmountPerDeduct
	,Estatus
) ON
DUPLICATE
KEY
UPDATE
	LastUpdBy		=UserRowID
	,PayStubID		=PaystubRowID
	,Balance			=LoanBalance
	,DeductedAmount=AmountPerDeduct
	,`Status`		=Estatus;
SELECT @@identity `PrimKey` INTO returnvalue;

IF returnvalue IS NULL THEN
	SET returnvalue = 0;
END IF;

RETURN returnvalue;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
