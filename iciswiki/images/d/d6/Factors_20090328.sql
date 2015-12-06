-- CROPFINDER USE CASE:
-- FACTORS table
-- mhabito 2008-2009

DELIMITER $$
DROP PROCEDURE IF EXISTS create_factors$$
CREATE PROCEDURE create_factors(IN xcrop VARCHAR(50),IN xdatabase VARCHAR(50))
BEGIN
 DECLARE noMoreRows INT DEFAULT 0;
 DECLARE v_fname VARCHAR(255);
 DECLARE v_ftype VARCHAR(10);
 DECLARE cursor_fname CURSOR FOR SELECT distinct rtrim(fieldname),datatype from fieldsetup where tablename ='Factors' order by rtrim(fieldname);
 DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET noMoreRows = 1;
 
DROP TABLE IF EXISTS factors;
 
CREATE TABLE factors (ounitid int not null, studyid int not null);
 
 OPEN cursor_fname;
 REPEAT
 FETCH cursor_fname INTO v_fname, v_ftype;
 IF NOT noMoreRows THEN
 IF upper(xcrop) = 'RICE' and ((rtrim(v_fname) = 'GID') OR (rtrim(v_fname)= 'GRPNO') OR (rtrim(v_fname)= 'ICIS_LOCID') OR (rtrim(v_fname)= 'PLOTNO' 'YEAR') )THEN
 SET @qry = concat('ALTER TABLE factors ADD COLUMN `',rtrim(v_fname),'` DOUBLE PRECISION');
 ELSEIF upper(xcrop) = 'WHEAT' and (rtrim(v_fname)='MARKER') THEN
 IF rtrim(v_ftype) = 'Text' THEN
 SET @qry = concat('ALTER TABLE factors ADD COLUMN `',rtrim(v_fname),'_C` VARCHAR(255)');
 ELSE
 SET @qry = concat('ALTER TABLE factors ADD COLUMN `',rtrim(v_fname),'_N` DOUBLE PRECISION');
 END IF;
 ELSEIF rtrim(v_ftype) = 'Text' THEN
 SET @qry = concat('ALTER TABLE factors ADD COLUMN `',rtrim(v_fname),'` VARCHAR(255)');
 ELSEIF rtrim(v_ftype) = 'Real' THEN
 SET @qry = concat('ALTER TABLE factors ADD COLUMN `',rtrim(v_fname),'` DOUBLE PRECISION');
 END IF;
 
 PREPARE stmt1 FROM @qry;
 EXECUTE stmt1;
 DEALLOCATE PREPARE stmt1; 
 END IF;
 UNTIL noMoreRows END REPEAT;
 CLOSE cursor_fname;

 delete from factors;
 INSERT INTO factors (studyid,ounitid)
 SELECT distinct f.studyid, o.ounitid
 from oindex as o inner join level_n as l on o.levelno = l.levelno inner join factor as f on f.labelid = l.labelid 
 UNION
 SELECT distinct f.studyid, o.ounitid
 from oindex as o inner join level_c as l on o.levelno = l.levelno inner join factor as f on f.labelid = l.labelid
 order by ounitid,studyid; 

-- create indices on ounitid and studyid
--
 CREATE INDEX ounitid on factors (ounitid);
 CREATE INDEX studyid on factors (studyid); 
--
--
-- populate the FACTORS table
--
CALL populate_factors();

END$$

DELIMITER ;


DELIMITER $$

DROP PROCEDURE IF EXISTS `populate_factors`$$

CREATE PROCEDURE `populate_factors`()
BEGIN
 DECLARE noMoreRows INT DEFAULT 0;
 DECLARE v_fname VARCHAR(255);
 DECLARE v_ftype VARCHAR(10);
 DECLARE cursor_factors CURSOR FOR SELECT distinct rtrim(fieldname),datatype from fieldsetup where tablename ='Factors' order by rtrim(fieldname);
 DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET noMoreRows = 1;
--
--
OPEN cursor_factors;
 REPEAT
 FETCH cursor_factors into v_fname,v_ftype;
 IF NOT noMoreRows THEN
 --
 IF trim(v_ftype) = 'Text' THEN
 SET @v_cmd = CONCAT('update factors as f, oindex as o, level_c as l, factor as fa set f.`',rtrim(v_fname),'` = l.lvalue ',
 ' where o.ounitid = f.ounitid and l.levelno = o.levelno and fa.labelid = l.labelid ',
 ' and rtrim(fa.fname) = "',rtrim(v_fname),'"');
 ELSE
 --
 SET @v_cmd = CONCAT('update factors as f, oindex as o, level_n as l, factor as fa set f.`',rtrim(v_fname),'` = l.lvalue ',
 ' where o.ounitid = f.ounitid and l.levelno = o.levelno and fa.labelid = l.labelid ',
 ' and rtrim(fa.fname) = "',rtrim(v_fname),'"');
 END IF;
 SELECT @v_cmd;
 PREPARE stmt1 FROM @v_cmd;
 EXECUTE stmt1;
 DEALLOCATE PREPARE stmt1; 
 END IF;
 UNTIL noMoreRows END REPEAT;
 CLOSE cursor_factors;

 END$$

DELIMITER ;
