CREATE DEFINER=`root`@`localhost` PROCEDURE `GET_employeeloanschedules_ofthisperiod_not_summed`(
	IN `org_rowid` INT,
	IN `payperiod_rowid` INT
)
LANGUAGE SQL
DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN

CALL `LoanPrediction`(org_rowid);

SELECT
	product.PartNo AS 'ProductName',
	A.DeductionAmount,
	A.ProperDeductAmount,
	A.*
FROM(
	SELECT
	#SUM(ii.`ProperDeductAmount`) `DeductionAmount`
	#, ii.EmployeeID
	#, ii.`Nondeductible`
	*
	FROM (SELECT i.*
			FROM loanpredict i
			WHERE i.PayperiodID=payperiod_rowid
			AND LCASE(i.`Status`) IN ('in progress', 'complete')
			AND i.DiscontinuedDate IS NULL
		UNION
			SELECT i.*
			FROM loanpredict i
			WHERE i.PayperiodID=payperiod_rowid
			AND LCASE(i.`Status`) = 'cancelled'
			AND i.DiscontinuedDate IS NOT NULL
			) ii
	WHERE ii.PayperiodID=payperiod_rowid
	#GROUP BY ii.EmployeeID, ii.`Nondeductible`
)
A
INNER JOIN product
ON A.LoanTypeID = product.RowID
;

END