-- MySQL stored procedure written by Rowena Valerio
-- IRRI-CIMMYT Crop Research Informatics Laboratory

DELIMITER $$

DROP PROCEDURE IF EXISTS `get_all_dataset`$$

CREATE PROCEDURE `get_all_dataset`()
BEGIN
	DECLARE done1 BOOL default FALSE;
	DECLARE var_rep INT;
	DECLARE var_repname  VARCHAR(50);
	DECLARE var_study INT;
	DECLARE var_ounitid INT;	
	DECLARE var_ounitCount INT;
	DECLARE get_rep_cursor CURSOR  FOR
	SELECT o.represno,cast(o.represno as char(5)), f.studyid, ounitid, COUNT(ounitid) FROM oindex o, effect e, factor f
			WHERE e.represno = o.represno 
			and e.factorid = f.factorid 
			and f.factorid = f.labelid 
			-- AND  f.studyid < 637 and e.represno >1554
			GROUP BY o.represno 
			HAVING COUNT(ounitid) >1 ;
	DECLARE  CONTINUE HANDLER FOR   SQLSTATE '02000'  SET done1 = TRUE;
	
	OPEN get_rep_cursor;
		rep_loop: LOOP
			FETCH get_rep_cursor INTO var_rep,var_repname,var_study, var_ounitid, var_ounitCount;
			IF done1 THEN
				CLOSE get_rep_cursor;
				LEAVE rep_loop;
			END IF;	
	
	CALL get_dataset( var_rep , var_repname);
				
 
	END LOOP;
	
END$$


DELIMITER ;