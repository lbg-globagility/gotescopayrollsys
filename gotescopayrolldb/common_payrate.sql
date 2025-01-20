/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP PROCEDURE IF EXISTS `common_payrate`;
DELIMITER //
CREATE PROCEDURE `common_payrate`()
BEGIN

DECLARE _i INT DEFAULT 0;

SET @_userId=(SELECT u.RowID FROM `user` u LIMIT 1);

SET @i = 2025;

SET @_count = (SELECT COUNT(og.RowID) FROM `organization` og WHERE og.NoPurpose=FALSE);

SET _i = 0;

WHILE (@i BETWEEN 2025 AND 2030) DO

	WHILE (_i < @_count) DO
	
		SET @_orgId=(SELECT og.RowID FROM `organization` og WHERE og.NoPurpose=FALSE order BY og.RowID LIMIT _i, 1);
		
		SET @_result=INSUPD_payrate(NULL,@_orgId,@_userId,@_userId,CONCAT(@i,'-01-01'),'Regular Holiday','New Year\'s Day',2.00,2.60,2.20,2.86,2.60,3.38);
	
		SET @_result=INSUPD_payrate(NULL,@_orgId,@_userId,@_userId,CONCAT(@i,'-02-25'),'Special Non-Working Holiday','People Power Anniversary',1.30,1.69,1.43,1.859,1.50,1.95);
		
		SET @_result=INSUPD_payrate(NULL,@_orgId,@_userId,@_userId,CONCAT(@i,'-04-09'),'Regular Holiday','The Day of Valor',2.00,2.60,2.20,2.86,2.60,3.38);
		SET @_result=INSUPD_payrate(NULL,@_orgId,@_userId,@_userId,CONCAT(@i,'-05-01'),'Regular Holiday','Labor Day',2.00,2.60,2.20,2.86,2.60,3.38);
		SET @_result=INSUPD_payrate(NULL,@_orgId,@_userId,@_userId,CONCAT(@i,'-06-12'),'Regular Holiday','Independence Day',2.00,2.60,2.20,2.86,2.60,3.38);
		
		SET @_result=INSUPD_payrate(NULL,@_orgId,@_userId,@_userId,CONCAT(@i,'-08-21'),'Special Non-Working Holiday','Ninoy Aquino Day',1.30,1.69,1.43,1.859,1.50,1.95);
		
		SET @_result=INSUPD_payrate(NULL,@_orgId,@_userId,@_userId,CONCAT(@i,'-11-01'),'Special Non-Working Holiday','All Saints\' Day',1.30,1.69,1.43,1.859,1.50,1.95);
		SET @_result=INSUPD_payrate(NULL,@_orgId,@_userId,@_userId,CONCAT(@i,'-11-30'),'Regular Holiday','Bonifacio Day',2.00,2.60,2.20,2.86,2.60,3.38);
		SET @_result=INSUPD_payrate(NULL,@_orgId,@_userId,@_userId,CONCAT(@i,'-12-24'),'Special Non-Working Holiday','Christmas Eve',1.30,1.69,1.43,1.859,1.50,1.95);
		SET @_result=INSUPD_payrate(NULL,@_orgId,@_userId,@_userId,CONCAT(@i,'-12-25'),'Regular Holiday','Christmas Day',2.00,2.60,2.20,2.86,2.60,3.38);
		SET @_result=INSUPD_payrate(NULL,@_orgId,@_userId,@_userId,CONCAT(@i,'-12-30'),'Regular Holiday','Rizal Day',2.00,2.60,2.20,2.86,2.60,3.38);
		
		SET @_result=INSUPD_payrate(NULL,@_orgId,@_userId,@_userId,CONCAT(@i,'-12-31'),'Special Non-Working Holiday','New Year\'s Eve',1.30,1.69,1.43,1.859,1.50,1.95);
		
		SET _i = _i + 1;
	
	END WHILE;

/* NEEDS OBSERVANCE**
#	SELECT INSUPD_payrate(NULL,1,1,1,'2018-02-16','Special Non-Working Holiday','Chinese Lunar New Year's Day',1.30,1.69,1.43,1.86,1.50,1.95) UNION 

#	SELECT INSUPD_payrate(NULL,1,1,1,'2018-03-29','Regular Holiday','Maundy Thursday',2.00,2.60,2.20,2.86,2.60,3.38) UNION 
#	SELECT INSUPD_payrate(NULL,1,1,1,'2018-03-30','Regular Holiday','Good Friday',2.00,2.60,2.20,2.86,2.60,3.38) UNION 
#	SELECT INSUPD_payrate(NULL,1,1,1,'2018-04-01','Special Non-Working Holiday','Easter Sunday',1.30,1.69,1.43,1.86,1.50,1.95) UNION 

#	SELECT INSUPD_payrate(NULL,1,1,1,'2018-06-16','Regular Holiday','Eidul-Fitar',2.00,2.60,2.20,2.86,2.60,3.38) UNION 

#	SELECT INSUPD_payrate(NULL,1,1,1,'2018-08-27','Special Non-Working Holiday','National Heroes Day',1.30,1.69,1.43,1.86,1.50,1.95) UNION 

#	SELECT INSUPD_payrate(NULL,1,1,1,'2018-08-29','Regular Holiday','National Heroes Day',2.00,2.60,2.20,2.86,2.60,3.38) UNION 
*/

	SET @i = @i + 1;

END WHILE;
	
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
