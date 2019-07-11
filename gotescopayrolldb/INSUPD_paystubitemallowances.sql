/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP PROCEDURE IF EXISTS `INSUPD_paystubitemallowances`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSUPD_paystubitemallowances`(
	IN `og_rowid` INT,
	IN `e_rowid` INT,
	IN `pp_rowid` INT,
	IN `user_rowid` INT
)
    DETERMINISTIC
BEGIN

DECLARE ps_rowid
        ,MonthCount
		  ,default_min_hrswork INT(11);

DECLARE date_from
        , date_to DATE;

SET default_min_hrswork = 8;
SET MonthCount = 12;

SELECT ps.RowID
,ps.PayFromDate
,ps.PayToDate
FROM paystub ps
WHERE ps.OrganizationID = og_rowid
AND ps.EmployeeID = e_rowid
AND ps.PayPeriodID = pp_rowid
INTO ps_rowid
     ,date_from
     ,date_to;

SET @timediffcount = 0.00;
SET @ecola_rowid = 0.00;
SET @day_pay1 = 0.00;

SELECT p.RowID
FROM product p
WHERE p.OrganizationID = og_rowid
AND p.PartNo = 'Ecola'
LIMIT 1
INTO @ecola_rowid;

# SET SESSION low_priority_updates = ON;# LOW_PRIORITY 

# INSERT LOW_PRIORITY INTO paystubitem(`ProductID`,`OrganizationID`,`Created`,`CreatedBy`,`PayStubID`,`PayAmount`,`Undeclared`)
INSERT INTO paystubitem(`ProductID`,`OrganizationID`,`Created`,`CreatedBy`,`PayStubID`,`PayAmount`,`Undeclared`)
	SELECT
	ii.ProductID
	,og_rowid
	,CURRENT_TIMESTAMP()
	,user_rowid
	,ps_rowid
	,ROUND(ii.`TotalAllowanceAmount`, 2)
	,'0'
	FROM
	(
		# SELECT i.*,SUM(i.TotalAllowanceAmt) AS TotalAllowanceAmount FROM paystubitem_sum_daily_allowance_group_prodid i WHERE i.EmployeeID=e_rowid AND i.ProductID != ecola_rowid AND i.OrganizationID=og_rowid AND i.`Date` BETWEEN date_from AND date_to GROUP BY i.ProductID
			
		SELECT i.ProductID, SUM(TotalAllowanceAmount) `TotalAllowanceAmount`
		FROM (SELECT
				# i.*
				i.EmployeeID
				,i.`Date`
				,0 `Equatn`
				,0 `timediffcount`
				,pr.PayType
				,0 `AllowanceAmount`
				, i.ProductID
				,i.TotalAllowanceAmt `TotalAllowanceAmount`
				FROM paystubitem_sum_daily_allowance_group_prodid i
				INNER JOIN employee e ON e.RowID=e_rowid AND e.RowID=i.EmployeeID AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0
				INNER JOIN product p ON p.RowID=i.ProductID #AND p.`Status`=0
				INNER JOIN employeetimeentry et ON et.EmployeeID=e.RowID AND et.`Date`=i.`Date` AND et.OrganizationID=i.OrganizationID
				INNER JOIN payrate pr ON pr.RowID=et.PayRateID
				INNER JOIN payperiod pp ON pp.RowID=pp_rowid
				WHERE i.`Date` BETWEEN pp.PayFromDate AND pp.PayToDate
				AND i.TotalAllowanceAmt != 0
				AND i.OrganizationID=og_rowid
				) i
			GROUP BY i.ProductID

	) ii
	WHERE ii.ProductID IS NOT NULL
ON
DUPLICATE
KEY
UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=user_rowid
	,PayAmount=ROUND(ii.`TotalAllowanceAmount`, 2);

#######################################################################

SET @timediffcount = 0.00;

SET @day_pay = 0.00;

# ***************************************************** # ***************************************************** #

# INSERT LOW_PRIORITY INTO paystubitem(`ProductID`,`OrganizationID`,`Created`,`CreatedBy`,`PayStubID`,`PayAmount`,`Undeclared`)
INSERT INTO paystubitem(`ProductID`,`OrganizationID`,`Created`,`CreatedBy`,`PayStubID`,`PayAmount`,`Undeclared`)
	SELECT i.ProductID
	,og_rowid
	,CURRENT_TIMESTAMP()
	,user_rowid
	,ps_rowid
	,ROUND(i.`AllowanceAmount`, 2)
	,0
	FROM (SELECT i.ProductID
	      ,i.EmployeeID
	      # ,( i.AllowanceAmount - (SUM(i.HoursToLess) * ((i.AllowanceAmount / (i.WorkDaysPerYear / (i.PAYFREQDIV * 12))) / 8)) ) `AllowanceAmount`
			,i.AllowanceAmount - TRIM(SUM(i.HoursToLess * (i.DailyAllowance / default_min_hrswork)))+0 `AllowanceAmount`
	      FROM paystubitem_sum_semimon_allowance_group_prodid i
			WHERE i.OrganizationID=og_rowid
			AND i.EmployeeID=e_rowid
			# AND i.TaxableFlag = FALSE
			AND i.`Date` BETWEEN date_from AND date_to
			# GROUP BY i.EmployeeID,ii.RowID,ii.ProductID
			GROUP BY i.ProductID, i.TaxableFlag) i
ON
DUPLICATE
KEY
UPDATE
	LastUpd=CURRENT_TIMESTAMP()
	,LastUpdBy=user_rowid
	,PayAmount=ROUND(i.`AllowanceAmount`, 2);

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
