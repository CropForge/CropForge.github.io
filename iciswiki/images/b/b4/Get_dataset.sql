DELIMITER $$

DROP PROCEDURE IF EXISTS `get_dataset`$$

CREATE PROCEDURE `get_dataset`(IN var_represno INT, IN ntable VARCHAR(50))
BEGIN
	DECLARE done1 BOOL default FALSE;
	DECLARE var_fname VARCHAR(50);
	DECLARE var_labelid INT;
	DECLARE var_ltype CHAR;	
	DECLARE var_vname VARCHAR(50);
	DECLARE var_factorid INT;
	DECLARE var_variatid INT;
	DECLARE var_dtype CHAR;
	DECLARE var_slabelid INT;
	
	DECLARE factor_cursor CURSOR  FOR 
	SELECT distinct f.factorid,TRIM(f.fname), f.labelid,  f.ltype
		FROM factor f 
		LEFT JOIN effect e on f.factorid = e.factorid 
		WHERE e.effectid = var_represno  and f.factorid != (SELECT f.factorid FROM factor f
									INNER JOIN effect e ON f.factorid = e.factorid
									and e.effectid = var_represno
									AND f.scaleid =134);
	DECLARE variate_cursor CURSOR FOR
	SELECT distinct v.variatid,TRIM(v.vname), v.dtype
		FROM variate v
		INNER JOIN veffect ve
		ON v.variatid = ve.variatid
		WHERE ve.represno = var_represno;
	
	DECLARE  CONTINUE HANDLER FOR   SQLSTATE '02000'  SET done1 = TRUE;
	
	-- SELECT studyid INTO var_studyid FROM study where sname = var_sname;
	-- SELECT factorid INTO n FROM factor INNER JOIN  study on study.studyid = factor.studyid 
	-- 						WHERE study.studyid = var_studyid and factor.scaleid = 134;
	
	-- SELECT factorid INTO var_slabelid FROM factor WHERE factor.studyid = var_studyid AND factor.scaleid =134;
	SELECT f.factorid into var_slabelid FROM factor f
	INNER JOIN effect e ON f.factorid = e.factorid
	AND e.represno = var_represno
	AND f.scaleid =134;
	
	SET @q1 = concat('CREATE TABLE `', ntable,'` (ounitid INT )');
	PREPARE stmnt1 FROM @q1;
	EXECUTE stmnt1;
	DEALLOCATE PREPARE stmnt1;
 
	-- ADD columns for factor names
	OPEN factor_cursor;
		factor_loop: LOOP
			FETCH factor_cursor INTO var_factorid,var_fname, var_labelid, var_ltype;
			IF done1 THEN
				CLOSE factor_cursor;
				LEAVE factor_loop;
			END IF;					
        	
			IF var_ltype  = 'N' THEN
				SET @q2 = concat('ALTER TABLE `', ntable , '` ADD COLUMN `',var_fname, '` INT');
				PREPARE stmnt FROM @q2;
				EXECUTE stmnt;
				DEALLOCATE PREPARE stmnt;
			ELSE
				SET @q2 = concat('ALTER TABLE `', ntable ,'` ADD COLUMN `',var_fname, '` VARCHAR(255)');
				PREPARE stmnt FROM @q2;
				EXECUTE stmnt;
				DEALLOCATE PREPARE stmnt;
		END IF;
	END LOOP;
	-- ADD columns for the variate names
	SET done1 = FALSE;
	OPEN variate_cursor;
		variate_loop: LOOP
			FETCH variate_cursor INTO var_variatid,var_vname, var_dtype;
			IF done1 THEN
				CLOSE variate_cursor;
				LEAVE variate_loop;
			END IF;	
			IF var_dtype  = 'C' THEN
				SET @q2 = concat('ALTER TABLE `',ntable,'` ADD COLUMN `',var_vname, '` VARCHAR(255)');
				PREPARE stmnt FROM @q2;
				EXECUTE stmnt;
				DEALLOCATE PREPARE stmnt;
			ELSE
				SET @q2 = concat('ALTER TABLE `',ntable,'` ADD COLUMN `',var_vname, '` INT');
				PREPARE stmnt FROM @q2;
				EXECUTE stmnt;
				DEALLOCATE PREPARE stmnt;
			END IF;
		
		END LOOP;
	
	-- Insert OUNITIDs into the new table
		-- SET @q2 = concat('INSERT INTO ', ntable , '(ounitid)  SELECT distinct ounitid from oindex LEFT JOIN factor ON factor.factorid = oindex.factorid
		-- LEFT JOIN  study ON study.studyid = factor.studyid 
		-- WHERE study.studyid = ', var_studyid,' AND factor.labelid != ', var_slabelid);
		SET @q2 = concat('INSERT INTO `', ntable , '` (ounitid) SELECT distinct o. ounitid from oindex o
			INNER JOIN factor f ON f.factorid = o.factorid
			INNER JOIN  effect e ON e.factorid = f.factorid 
			WHERE  o.represno = ', var_represno,'  AND f.labelid != ', var_slabelid);
	PREPARE stmnt FROM @q2;
	EXECUTE stmnt;
	DEALLOCATE PREPARE stmnt;
	
	SET @q2 = concat('CREATE INDEX data_idx1 ON `', ntable , '` (ounitid)' );
	PREPARE stmnt FROM @q2;
	EXECUTE stmnt;
	DEALLOCATE PREPARE stmnt;
	-- GET ALL FACTOR values
	SET done1 = FALSE;
	OPEN factor_cursor;
		fval_loop: LOOP
			FETCH factor_cursor INTO var_factorid,var_fname, var_labelid, var_ltype;
			IF done1 THEN
				CLOSE factor_cursor;
				LEAVE fval_loop;
			END IF;					
        	
		IF var_ltype  = 'C' THEN
			SET @q2 = concat('UPDATE `', ntable, '` INNER JOIN 
					(SELECT if(substr(lvalue,LENGTH(lvalue))= char(13),LEFT(lvalue,(LENGTH(lvalue)-1)), lvalue) as lvalue, oindex.ounitid
					FROM factor,level_c,oindex
					WHERE level_c.levelno = oindex.levelno 
					AND factor.labelid = level_c.labelid
					AND level_c.labelid = ' ,var_labelid,
					') as d
				SET `',var_fname,'` = d.lvalue 
				WHERE `', ntable,'`.ounitid = d.ounitid');
			
			PREPARE stmnt FROM @q2;
			EXECUTE stmnt;
			DEALLOCATE PREPARE stmnt;
	
		ELSE
		
			SET @q2 = concat('UPDATE `', ntable, '` INNER JOIN 
					(SELECT if(substr(lvalue,LENGTH(lvalue))= char(13),LEFT(lvalue,(LENGTH(lvalue)-1)), lvalue) as lvalue, oindex.ounitid
					FROM factor,level_n,oindex
					WHERE level_n.levelno = oindex.levelno 
					AND factor.labelid = level_n.labelid
					AND level_n.labelid = ' ,var_labelid,
					') as d
				SET `',var_fname,'` = d.lvalue 
				WHERE `', ntable,'`.ounitid = d.ounitid');
		PREPARE stmnt FROM @q2;
		EXECUTE stmnt;
		DEALLOCATE PREPARE stmnt;
		END IF;
	
	END LOOP;
	
	-- GET ALL VARIATES
	SET done1 = FALSE; 
	OPEN variate_cursor;
		var_loop: LOOP
			FETCH variate_cursor INTO var_variatid,var_vname, var_dtype;
			IF done1 THEN
				CLOSE variate_cursor;
				LEAVE var_loop;
			END IF;		
			IF var_dtype  = 'N' THEN
			
				SET @q2 = concat( 'UPDATE `', ntable ,'` INNER JOIN 	
							       (SELECT if(substr(dvalue,LENGTH(dvalue))= char(13),LEFT(dvalue,(LENGTH(dvalue)-1)), dvalue) as dvalue, ounitid FROM data_n 
								WHERE data_n.variatid = ',var_variatid,
								') as x 
					SET `',var_vname,'` = x.dvalue
					WHERE `', ntable,'`.ounitid = x.ounitid ');
				PREPARE stmnt FROM @q2;
				EXECUTE stmnt;
				DEALLOCATE PREPARE stmnt;
	
			ELSE
				SET @q2 = concat( 'UPDATE `', ntable ,'` INNER JOIN 	
							       (SELECT if(substr(dvalue,LENGTH(dvalue))= char(13),LEFT(dvalue,(LENGTH(dvalue)-1)), dvalue) as dvalue, ounitid FROM data_c 
								WHERE data_c.variatid = ',var_variatid,
								') as x 
						
						SET `',var_vname,'` = x.dvalue 
					       WHERE `', ntable,'`.ounitid = x.ounitid ');
				PREPARE stmnt FROM @q2;
				EXECUTE stmnt;
				DEALLOCATE PREPARE stmnt;
		END IF;
	END LOOP;
	 
END$$

DELIMITER ;