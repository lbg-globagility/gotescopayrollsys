/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `VIEW_paystubitem`;
DELIMITER //
CREATE PROCEDURE `VIEW_paystubitem`(
	IN `paystitm_PayStubID` INT
)
    DETERMINISTIC
BEGIN

	SELECT
	paystitm.RowID `paystitmID`
	, paystitm.PayStubID
	, paystitm.ProductID
	, SUBSTRING_INDEX(p.PartNo,'.',-1) `Item`
	, paystitm.PayAmount
	FROM paystubitem paystitm
	INNER JOIN product p ON p.RowID=paystitm.ProductID AND p.ActiveData = TRUE
	INNER JOIN category c ON c.RowID=p.CategoryID AND c.CategoryName != 'Leave type'
	WHERE paystitm.PayStubID = paystitm_PayStubID
	AND paystitm.Undeclared = FALSE
	
UNION
	SELECT
	paystitm.RowID `paystitmID`
	, paystitm.PayStubID
	, paystitm.ProductID
	, SUBSTRING_INDEX(p.PartNo,'.',-1) `Item`
	, paystitm.PayAmount
	FROM paystubitem paystitm
	INNER JOIN product p ON p.RowID=paystitm.ProductID AND p.ActiveData = TRUE
	INNER JOIN category c ON c.RowID=p.CategoryID AND c.CategoryName = 'Leave type'
	WHERE paystitm.PayStubID = paystitm_PayStubID
	AND paystitm.Undeclared = TRUE
;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
