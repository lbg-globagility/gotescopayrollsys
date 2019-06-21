/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP FUNCTION IF EXISTS `GET_PhilHealthContribNewImplement`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `GET_PhilHealthContribNewImplement`(
	`amount_worked` DECIMAL(15,4),
	`is_employee_share` BOOL
) RETURNS decimal(15,4)
    DETERMINISTIC
BEGIN

DECLARE return_value
        , _amount
		  
        , value1
        , value2 
		  
        , min_contrib
        , max_contrib DECIMAL(15, 4);


SELECT (amount_worked
        * (nph.Rate * 0.01)
		  ) `Result`
, nph.MinimumContribution
, nph.MaximumContribution
FROM newphilhealthimplement nph
LIMIT 1
INTO _amount
     , min_contrib
     , max_contrib;

IF min_contrib > _amount THEN
	SET _amount = min_contrib;
ELSEIF max_contrib < _amount THEN
	SET _amount = max_contrib;
END IF;

/*SET value1 = (_amount / 2);
SET value2 = (_amount - value1);*/
SET value1 = _amount;
SET value2 = value1;

IF is_employee_share THEN
	SET return_value = LEAST(value1, value2);
ELSE
	SET return_value = GREATEST(value1, value2);
END IF;
        
RETURN IFNULL(return_value, 0);

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
