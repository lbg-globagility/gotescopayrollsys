/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP VIEW IF EXISTS `paystubadjustment_peritem`;
DROP TABLE IF EXISTS `paystubadjustment_peritem`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `paystubadjustment_peritem` AS SELECT #paystubadjustment_peritem

adj.RowID
, adj.OrganizationID
, adj.Created
, adj.CreatedBy
, adj.LastUpd
, adj.LastUpdBy
, adj.PayStubID
, adj.ProductID
, ROUND(SUM(adj.PayAmount), 2) `PayAmount`
, adj.`Comment`
, FALSE `IsActual`

, GROUP_CONCAT(p.PartNo) `AdjustmentName`
, GROUP_CONCAT(adj.PayAmount) `AdjustmentAmount`

FROM paystubadjustment adj
INNER JOIN product p ON p.RowID=adj.ProductID
WHERE adj.PayAmount > 0
GROUP BY adj.PayStubID ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
