/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP TRIGGER IF EXISTS `AFTUPD_paystubadjustment`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `AFTUPD_paystubadjustment` AFTER UPDATE ON `paystubadjustment` FOR EACH ROW BEGIN

DECLARE empRowID INT(11);

DECLARE payperiodRowID INT(11);

SELECT ps.EmployeeID,ps.PayPeriodID FROM paystub ps WHERE ps.RowID=NEW.PayStubID INTO empRowID,payperiodRowID;

/*INSERT INTO paystubadjustmentactual
(
	RowID,
	OrganizationID,
	Created,
	CreatedBy,
	LastUpdBy,
	PayStubID,
	ProductID,
	PayAmount,
	`Comment`
)	SELECT
	NEW.RowID
	,NEW.OrganizationID
	,CURRENT_TIMESTAMP()
	,NEW.CreatedBy
	,NEW.CreatedBy
	,NEW.PayStubID
	,NEW.ProductID
	,NEW.PayAmount * (es.TrueSalary / es.Salary)
	,NEW.`Comment`
	FROM employee e
	INNER JOIN payperiod pp ON pp.RowID=payperiodRowID AND pp.OrganizationID=e.OrganizationID
	INNER JOIN employeesalary es ON es.EmployeeID=e.RowID AND es.OrganizationID=e.OrganizationID AND (es.EffectiveDateFrom >= pp.PayFromDate OR IFNULL(es.EffectiveDateTo,pp.PayToDate) >= pp.PayFromDate) AND (es.EffectiveDateFrom <= pp.PayToDate OR IFNULL(es.EffectiveDateTo,pp.PayToDate) <= pp.PayToDate)
	WHERE e.RowID=empRowID
	AND e.OrganizationID=NEW.OrganizationID
ON
DUPLICATE
KEY
UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=NEW.CreatedBy
	,`Comment`=NEW.`Comment`
	,PayAmount=NEW.PayAmount * (es.TrueSalary / es.Salary);*/

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
