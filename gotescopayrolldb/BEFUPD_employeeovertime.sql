/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP TRIGGER IF EXISTS `BEFUPD_employeeovertime`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `BEFUPD_employeeovertime` BEFORE UPDATE ON `employeeovertime` FOR EACH ROW BEGIN

DECLARE ot_aftr_shifttime TIME DEFAULT NULL;

DECLARE ot_befr_shifttime TIME DEFAULT NULL;

DECLARE eshiftID INT(11);

DECLARE is_whole_shift_ndiff BOOL DEFAULT FALSE;

SELECT
sh.TimeFrom
,sh.TimeTo
FROM employeeshift esh
INNER JOIN shift sh ON sh.RowID=esh.ShiftID
WHERE esh.EmployeeID=NEW.EmployeeID
AND esh.OrganizationID=NEW.OrganizationID
AND (esh.EffectiveFrom >= NEW.OTStartDate OR esh.EffectiveTo >= NEW.OTStartDate)
AND (esh.EffectiveFrom <= NEW.OTEndDate OR esh.EffectiveTo <= NEW.OTEndDate)
LIMIT 1
INTO ot_befr_shifttime
		,ot_aftr_shifttime;

IF ot_befr_shifttime IS NOT NULL
	AND ot_aftr_shifttime IS NOT NULL THEN

	IF HOUR(NEW.OTStartTime) = HOUR(ot_aftr_shifttime) THEN
	
		SET NEW.OTStartTime = TIME(TIME_FORMAT(NEW.OTStartTime,@@time_format));

	END IF;
	
END IF;

IF NEW.LastUpdBy IS NULL THEN
	SET NEW.LastUpdBy = 1;
END IF;

/*
ALTER TABLE `employeeovertime`
	ADD COLUMN `OfficialValidHours` DECIMAL(10,2) NULL DEFAULT '0' AFTER `OTEndTime`;
ALTER TABLE `employeeovertime`
	ADD COLUMN `OfficialValidNightDiffHours` DECIMAL(10,2) NULL DEFAULT '0' AFTER `OfficialValidHours`;
*/

SELECT esh.ShiftID FROM employeeshift esh WHERE esh.OrganizationID=NEW.OrganizationID AND esh.EmployeeID=NEW.EmployeeID AND (esh.EffectiveFrom >= NEW.OTStartDate OR esh.EffectiveTo >= NEW.OTStartDate) AND (esh.EffectiveFrom <= NEW.OTEndDate OR esh.EffectiveTo <= NEW.OTEndDate) ORDER BY esh.EffectiveFrom,esh.EffectiveTo LIMIT 1 INTO eshiftID;

IF eshiftID IS NOT NULL THEN
	# SET NEW.OTStartTime = 
	SET @OTStartTime = (SELECT IF(ADDTIME(sh.TimeTo, SEC_TO_TIME(60)) = NEW.OTStartTime OR sh.TimeTo = NEW.OTStartTime, ADDTIME(sh.TimeTo,SEC_TO_TIME(1)), TIME_FORMAT(NEW.OTStartTime, @@time_format)) FROM shift sh WHERE sh.RowID=eshiftID);
	
	SET eshiftID = NULL;
END IF;

IF NEW.OTStatus = 'Approved' THEN

	SELECT CONCAT_DATETIME(NEW.OTStartDate, sh.TimeFrom) `TimeFrom`
	,CONCAT_DATETIME(ADDDATE(NEW.OTStartDate, INTERVAL IS_TIMERANGE_REACHTOMORROW(sh.TimeFrom, sh.TimeTo) DAY), sh.TimeTo) `TimeTo`
	, FALSE
	FROM employeeshift esh
	LEFT JOIN shift sh ON sh.RowID=esh.ShiftID
	WHERE esh.EmployeeID=NEW.EmployeeID
	AND esh.OrganizationID=NEW.OrganizationID
	AND NEW.OTStartDate BETWEEN esh.EffectiveFrom AND esh.EffectiveTo
	LIMIT 1
	INTO @sh_timestamp_start
	     ,@sh_timestamp_end
		  ,is_whole_shift_ndiff;
	
	SET @min_per_hour = 60; SET @sec_per_min = 60;
	
	SET @valid_ot_hrs = 0.0;
	
	SET @etd_timelog_in = NULL; SET @etd_timelog_out = NULL;
	
	SELECT etd.TimeStampIn
	,etd.TimeStampOut
	FROM employeetimeentrydetails etd
	WHERE etd.EmployeeID=NEW.EmployeeID
	AND etd.OrganizationID=NEW.OrganizationID
	AND etd.`Date` BETWEEN NEW.OTStartDate AND NEW.OTEndDate
	ORDER BY IFNULL(etd.LastUpd, etd.Created) DESC
	LIMIT 1
	INTO @etd_timelog_in
			,@etd_timelog_out;
	
	SET @ot_timestamp_start = CONCAT_DATETIME(NEW.OTStartDate, NEW.OTStartTime);
	SET @ot_timestamp_end = CONCAT_DATETIME(ADDDATE(NEW.OTStartDate, INTERVAL IS_TIMERANGE_REACHTOMORROW(NEW.OTStartTime, NEW.OTEndTime) DAY), NEW.OTEndTime);
	
	SET @raw_value = (TIMESTAMPDIFF(SECOND
	                                , @ot_timestamp_start
											  , @ot_timestamp_end)
							/ (@min_per_hour * @sec_per_min));
	
	IF TIME_FORMAT(@sh_timestamp_end, @@time_format) <= TIME_FORMAT(@ot_timestamp_start, @@time_format)
	   AND TIME_FORMAT(@sh_timestamp_end, @@time_format) <= TIME_FORMAT(@ot_timestamp_end, @@time_format)
		AND DATE(@sh_timestamp_start) < DATE(@sh_timestamp_end)
		/*AND (TIME(@sh_timestamp_end) <= TIME(@ot_timestamp_start)
		     OR TIME(@sh_timestamp_end) < TIME(@ot_timestamp_end)
		     )*/
		THEN
		
		SET @ot_timestamp_start = ADDDATE(@ot_timestamp_start, INTERVAL 1 DAY);
		SET @ot_timestamp_end = ADDDATE(@ot_timestamp_end, INTERVAL 1 DAY);
	END IF;

	SET @valid_ot_hrs = (TIMESTAMPDIFF(SECOND
												  , @ot_timestamp_start
												  , @ot_timestamp_end)
								/ (@min_per_hour * @sec_per_min));
	
	IF @sh_timestamp_end <= @ot_timestamp_start
	   AND @sh_timestamp_end <= @ot_timestamp_end THEN # satisfies an overtime after shift
	   
		SET @valid_ot_hrs = (TIMESTAMPDIFF(SECOND
	                                      , GREATEST(@ot_timestamp_start, @sh_timestamp_end)
	                                      , LEAST(@ot_timestamp_end, @etd_timelog_out)
													  #, IF(@ot_timestamp_end < @etd_timelog_out, @ot_timestamp_end, @etd_timelog_out)
													  )
									/ (@min_per_hour * @sec_per_min));
		# SELECT @ot_timestamp_start, @ot_timestamp_end, @etd_timelog_in, @etd_timelog_out, @sh_timestamp_start, @sh_timestamp_end, @valid_ot_hrs, GREATEST(@ot_timestamp_start, @sh_timestamp_end), LEAST(@ot_timestamp_end, @etd_timelog_out) INTO OUTFILE 'D:/New Downloads/result.txt';
	ELSEIF @sh_timestamp_start >= @ot_timestamp_start
	       AND @sh_timestamp_start >= @ot_timestamp_end THEN # satisfies an overtime before shift
	
		SET @valid_ot_hrs = (TIMESTAMPDIFF(SECOND
	                                      , GREATEST(@ot_timestamp_start, @etd_timelog_in)
	                                      , LEAST(@ot_timestamp_end, @sh_timestamp_start)
													  /*, IF(@etd_timelog_in > @ot_timestamp_start, @etd_timelog_in, @ot_timestamp_start)
													  , @ot_timestamp_end*/
													  )
									/ (@min_per_hour * @sec_per_min));
									
	END IF;
	
	# SET NEW.Reason = @valid_ot_hrs;
	
	SET NEW.OfficialValidHours = IFNULL(@valid_ot_hrs, @raw_value);
	
	IF NEW.OfficialValidHours < 0 THEN
		SET NEW.OfficialValidHours = 0; END IF;
	
	
	SET @og_ndiff_timefrom = TIME('22:00'); SET @og_ndiff_timeto = TIME('06:00');
	
	SELECT
	CONCAT_DATETIME(NEW.OTStartDate, og.NightDifferentialTimeFrom) `NightDifferentialTimeFrom`
	,CONCAT_DATETIME(ADDDATE(NEW.OTStartDate
	                         , INTERVAL IS_TIMERANGE_REACHTOMORROW(og.NightDifferentialTimeFrom, og.NightDifferentialTimeTo) DAY)
						  , og.NightDifferentialTimeTo) `NightDifferentialTimeTo`
	FROM organization og
	INNER JOIN employee e ON e.RowID=NEW.EmployeeID AND e.CalcNightDiffOT = TRUE
	WHERE og.RowID=NEW.OrganizationID
	AND is_whole_shift_ndiff = FALSE
	INTO @og_ndiff_timefrom
			,@og_ndiff_timeto;
			
	SET @valid_ndiff_hrs = 0;
	   
	IF @sh_timestamp_start >= @ot_timestamp_start
	   AND @sh_timestamp_start >= @ot_timestamp_end THEN
	   
	   SET @valid_ndiff_hrs = (TIMESTAMPDIFF(SECOND
	                                      , GREATEST(@ot_timestamp_end, @etd_timelog_in)
	                                      , SUBDATE(@og_ndiff_timeto, INTERVAL 1 DAY)
													  )
									/ (@min_per_hour * @sec_per_min));
	
	ELSEIF @sh_timestamp_end <= @ot_timestamp_start
	       AND @sh_timestamp_end <= @ot_timestamp_end THEN
	       
	   SET @valid_ndiff_hrs = (TIMESTAMPDIFF(SECOND
	                                      , @og_ndiff_timefrom
	                                      , LEAST(@ot_timestamp_end, @etd_timelog_out, @og_ndiff_timeto)
													  )
									/ (@min_per_hour * @sec_per_min));
	
	END IF;
	SET @valid_ndiff_hrs = IF(IFNULL(@valid_ndiff_hrs, 0) < 0, 0, IFNULL(@valid_ndiff_hrs, 0));
	
	/*SET @valid_ndiff_hrs = (TIMESTAMPDIFF(SECOND
	                                      , IF(@og_ndiff_timefrom > @ot_timestamp_start, @og_ndiff_timefrom, @ot_timestamp_start)
													  , IF(@og_ndiff_timeto > @ot_timestamp_end, @ot_timestamp_end, @og_ndiff_timeto))
									/ (@min_per_hour * @sec_per_min));*/
	
	SET NEW.OfficialValidNightDiffHours = IFNULL(@valid_ndiff_hrs, 0);

	IF NEW.OfficialValidNightDiffHours < 0 THEN
		SET NEW.OfficialValidNightDiffHours = 0; END IF;
	
ELSE

	SET NEW.OfficialValidHours = 0;
	SET NEW.OfficialValidNightDiffHours = 0;

END IF;

IF NEW.OTStatus IS NULL THEN
	SET NEW.OTStatus = 'Pending'; END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
