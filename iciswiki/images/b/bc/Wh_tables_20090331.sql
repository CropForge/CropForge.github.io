-- 2009 IRRI-CIMMYT CROP RESEARCH INFORMATICS LABORATORY
-- Written by M.C.D. HABITO
-- 


DELIMITER $$
DROP PROCEDURE IF EXISTS `initialize_warehouse`$$

CREATE PROCEDURE `initialize_warehouse`()
BEGIN
--
-- Table structure for table `wh_columns` (MySQL)
--
--
DROP TABLE IF EXISTS `wh_columns`;
CREATE TABLE `wh_columns` (
 `study` int(11) default NULL,              -- the study ID
`dataset` int(11) default NULL,            -- this is the REPRESNO (representation number) 
 `col` int(11) default NULL,                -- column number (1 to n); 0 if coltype = "S" (study particulars) 
`colname` varchar(255) default NULL,       -- column name
`fieldid` int(11) default NULL,            -- contains the FACTORID or VARIATID, depending on coltype
`coltype` char(1) default NULL,            -- "F" (factor) or "V" (variate) or "S" (STUDY particulars; for use in CropFinder)
`valtype` char(1) default NULL,            -- "C" if text, "N" if numeric
`traitid` int(11) default NULL,            -- link to TRAIT table
`scaleid` int(11) default NULL,            -- link to SCALE table
`tmethid` int(11) default NULL            -- link to TMETHOD table
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


--
-- Table structure for table `wh_data` (MySQL)
--
--
DROP TABLE IF EXISTS `wh_data`;
CREATE TABLE `wh_data` (
 `study` int(11) default NULL,                -- link to study ID in wh_columns table
`dataset` int(11) default NULL,              -- link to dataset # in wh_columns table
`ounitid` int(11) default NULL,		     -- link to OINDEX table
`datarow` int(11) default NULL,              -- row number (1 to n)
`datacol` int(11) default NULL,              -- column number (1 to n)
`dataval`	varchar(255) default NULL    -- the data value
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
--
-- Table structure for table `wh_datasets` (MySQL)
--
--
DROP TABLE IF EXISTS `wh_datasets`;
CREATE TABLE `wh_datasets` (
 `study` int(11) default NULL,                -- the study ID 
`dataset` int(11) default NULL,              -- dataset number (a.k.a. REPRESNO)
`maxrow` int(11) default NULL,              -- maximum number of rows for the dataset
`maxcol` int(11) default NULL,              -- maximum number of columns for the dataset
`desc`	varchar(255) default NULL     -- description of the dataset
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

    END$$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS `get_dataval`$$

CREATE PROCEDURE `get_dataval`(
	IN var_ounitid INT, 
	IN var_fieldid INT,
	IN var_coltype CHAR,
	IN var_valtype CHAR,
	IN var_represno INT, 
	IN var_studyid INT, 
	IN var_rownum INT,
	IN var_colnum INT)
BEGIN
 --
INSERT INTO wh_data(study,dataset,ounitid,datarow,datacol) 
VALUES (var_studyid,var_represno,var_ounitid,var_rownum,var_colnum);
--
-- get the factors 
--
 IF var_coltype = 'F' THEN
--
-- text factors
--
 IF var_valtype = 'C' THEN
 UPDATE wh_data as w, level_c as l, oindex
 SET w.dataval = if(substr(l.lvalue,LENGTH(l.lvalue))= char(13),LEFT(l.lvalue,(LENGTH(l.lvalue)-1)), l.lvalue)
 where l.levelno = oindex.levelno 
 AND l.labelid = var_fieldid
 AND oindex.represno = var_represno
 and oindex.ounitid = var_ounitid
 and oindex.represno = w.dataset
 and w.study = var_studyid
 and w.datarow = var_rownum
 and w.datacol = var_colnum;
 ELSE
--
-- numeric factors
--
 UPDATE wh_data as w, level_n as l, oindex
 SET w.dataval = if(substr(l.lvalue,LENGTH(l.lvalue))= char(13),LEFT(l.lvalue,(LENGTH(l.lvalue)-1)), l.lvalue)
 where l.levelno = oindex.levelno 
 AND l.labelid = var_fieldid
 AND oindex.represno = var_represno
 and oindex.ounitid = var_ounitid
 and oindex.represno = w.dataset
 and w.study = var_studyid
 and w.datarow = var_rownum
 and w.datacol = var_colnum;	
 END IF;
 ELSE
--
-- get the variates
--
-- text variates first...
 IF var_valtype = 'C' THEN
 UPDATE wh_data as w, data_c as d	
 SET w.dataval = if(substr(d.dvalue,LENGTH(d.dvalue))= char(13),LEFT(d.dvalue,(LENGTH(d.dvalue)-1)), d.dvalue) 
 WHERE d.variatid = var_fieldid
 and d.ounitid = var_ounitid
 and d.ounitid = w.ounitid
 and w.study = var_studyid
 and w.dataset = var_represno
 and w.datarow = var_rownum
 and w.datacol = var_colnum;
 ELSE
-- then numeric variates...
 UPDATE wh_data as w, data_n as d	
 SET w.dataval = if(substr(d.dvalue,LENGTH(d.dvalue))= char(13),LEFT(d.dvalue,(LENGTH(d.dvalue)-1)), d.dvalue) 
 WHERE d.variatid = var_fieldid
 and d.ounitid = var_ounitid
 and d.ounitid = w.ounitid
 and w.study = var_studyid
 and w.dataset = var_represno
 and w.datarow = var_rownum
 and w.datacol = var_colnum;
 END IF;
 END IF;
 END$$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS `get_dataset_warehouse`$$

CREATE PROCEDURE `get_dataset_warehouse`(IN var_study INT)
BEGIN
 DECLARE bDone BOOL default FALSE;
 DECLARE var_slabelid INT;
 DECLARE var_represno INT;
--
-- CURSOR: get the REPRESNOs given the study
 DECLARE rep_cursor CURSOR FOR SELECT distinct e.represno
 FROM effect e, factor f
 WHERE e.factorid = f.factorid 
 and f.studyid = var_study
 ORDER BY e.represno;
--
--
 DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET bDone = TRUE;
--
--
-- iterate through REPRESNOs given a study...
OPEN rep_cursor;
rep_loop: LOOP
 FETCH rep_cursor INTO var_represno;
 if bDone THEN
	CLOSE rep_cursor;
        LEAVE rep_loop;
 END IF;
--
--
-- ...get data for each represno
--
SELECT f.factorid into var_slabelid FROM factor f
 INNER JOIN effect e ON f.factorid = e.factorid
 AND e.represno = var_represno
 AND f.studyid = var_study
 AND f.scaleid =134;
--
--
  INSERT INTO wh_columns (study,dataset,colname,fieldid,coltype,valtype,traitid,scaleid,tmethid) 
 SELECT distinct f.studyid, o.represno, trim(f.fname), f.labelid, 'F', f.ltype,
 f.traitid,
 f.scaleid,
 f.tmethid  
 from oindex o
 INNER JOIN factor f ON f.factorid = o.factorid
 WHERE f.studyid = var_study AND o.represno = var_represno AND f.labelid != var_slabelid
 order by f.studyid,o.represno,f.factorid;
--
--
 INSERT INTO wh_columns (study,dataset,colname,fieldid,coltype,valtype,traitid,scaleid,tmethid)
 SELECT distinct v.studyid,
 ve.represno,
 trim(v.vname), 
 v.variatid,
 'V',
 v.dtype,
 v.traitid,
 v.scaleid,
 v.tmethid
 FROM variate v INNER JOIN veffect ve ON v.variatid = ve.variatid
 WHERE v.studyid = var_study AND ve.represno = var_represno order by v.studyid,ve.represno,v.variatid;
--
--
UPDATE wh_columns as w, trait as t
set w.colname = trim(t.trname)
where w.coltype = 'V'
AND w.traitid = t.traitid
AND w.dataset = var_represno
and w.study = var_study;
--
--
UPDATE wh_columns as w, scale as s
set w.colname = IF(s.scname IS NULL,w.colname,concat(w.colname,' (',trim(s.scname),')'))
where w.coltype = 'V'
AND w.scaleid = s.scaleid
AND w.dataset = var_represno
and w.study = var_study;
--
--
-- 
 UPDATE wh_columns as w, tmethod as t  
 set w.colname = IF(t.tmname IS NULL, w.colname, concat(w.colname,' ',trim(t.tmname)))
 where w.coltype = "V"   
 AND w.tmethid = t.tmethid
AND w.dataset = var_represno
and w.study = var_study;
--
CALL get_represno(var_represno,var_study);
--
--
--	
END LOOP; 
SET bDone = FALSE;  -- END: rep_cursor
--
--
END$$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS `get_all_dataset_warehouses`$$

CREATE PROCEDURE `get_all_dataset_warehouses`(IN xfromStudy INT, IN xtoStudy INT, IN xdatabase VARCHAR(255))
BEGIN
 DECLARE done1 BOOL default FALSE;
 DECLARE var_study INT;
--
--
 DECLARE get_study_cursor CURSOR  FOR
 SELECT studyid from study
 where studyid >= xfromStudy
 and studyid <= xtoStudy
 order by studyid;
--
 DECLARE  CONTINUE HANDLER FOR SQLSTATE '02000'  SET done1 = TRUE;
--
-- get studyids first
--
 OPEN get_study_cursor;
 study_loop: LOOP
	FETCH get_study_cursor INTO var_study;
 
IF done1 THEN
	CLOSE get_study_cursor;
	LEAVE study_loop;
 END IF;	
 CALL get_dataset_warehouse(var_study);
 END LOOP;
--
--
/*
 DELETE FROM wh_columns where coltype = 'S';
 SET @q2 = concat('INSERT INTO wh_columns (colname,fieldid,coltype,valtype,traitid,scaleid,tmethid) 
 select c.column_name,
 0,
 ''S'',
 IF(c.data_type LIKE ''int%'',''N'',''C''),
 0,
 0,
 0
 from information_schema.columns c
 where c.table_schema = "', xdatabase, '"
 and c.table_name = ''study'' ');
--
--
 PREPARE stmnt FROM @q2;
 EXECUTE stmnt;
 DEALLOCATE PREPARE stmnt;
*/
--
 SELECT concat('Done for studies ',xfromstudy,' TO ',xtostudy) as RESULT;
--
 END$$

DELIMITER ;

DELIMITER$$
DROP PROCEDURE IF EXISTS `addindices_warehouse`$$

CREATE PROCEDURE `addindices_warehouse`()
BEGIN
--
DELETE from wh_data where dataval is null;
--
-- 
CREATE INDEX wh_columns_idx1 ON wh_columns(study);
CREATE INDEX wh_columns_idx2 ON wh_columns(dataset);
CREATE INDEX wh_columns_idx3 ON wh_columns(col);
CREATE INDEX wh_columns_idx4 ON wh_columns(traitid);
CREATE INDEX wh_columns_idx5 ON wh_columns(scaleid);
CREATE INDEX wh_columns_idx6 ON wh_columns(tmethid);
CREATE INDEX wh_columns_idx7 ON wh_columns(fieldid);

CREATE INDEX wh_data_idx1 ON wh_data(study);
CREATE INDEX wh_data_idx2 ON wh_data(dataset);
CREATE INDEX wh_data_idx3 ON wh_data(datarow);
CREATE INDEX wh_data_idx4 ON wh_data(datacol);
-- create indEX on dataval
--
CREATE INDEX wh_data_idx5 ON wh_data(dataval);

END$$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS `sort_warehouse`$$

CREATE PROCEDURE `sort_warehouse`(
	IN xtraitid INT, 
	IN xscaleid INT, 
	IN xmethid INT, 
      IN xstudy INT,
      IN xrepresno INT,
	IN xsort VARCHAR(4))  -- ASC or DESC
BEGIN
 DECLARE var_valuetype CHAR;
 DECLARE xsessionid VARCHAR(255);
--
--
 SELECT TRIM(DATE_FORMAT(now(),'%Y%m%d%H%i%s')) into xsessionid;
--
--
SELECT DISTINCT valtype INTO var_valuetype
from wh_columns 
 where traitid = xtraitid
 and scaleid = xscaleid
 and tmethid = xmethid
 LIMIT 1;
--
--
--
 SET @qry = concat('CREATE TABLE newrow_',xsessionid,'(',
 ' study INT, ',
 ' dataset INT, ',
 ' row INT,  ',
 ' newrow INT NOT NULL AUTO_INCREMENT PRIMARY KEY',
 ') ENGINE=Memory; ');
 PREPARE stmt1 FROM @qry;
 EXECUTE stmt1;
 DEALLOCATE PREPARE stmt1; 
--
--
-- study and represno specified 
IF (xstudy = 0) AND (xrepresno = 0) THEN
	--
	-- data value is numeric
	--
	IF trim(var_valuetype) = 'N' THEN
		 SET @qry = concat('INSERT INTO newrow_',xsessionid,'( study,dataset,row ) ',
		' select wh_data.study,wh_data.dataset,wh_data.datarow',
		' from wh_data,wh_columns	',
		' where wh_data.study = wh_columns.study   ',
		' and wh_data.dataset = wh_columns.dataset ',
		' and wh_data.datacol = wh_columns.col     ',
		' and wh_columns.traitid = ',xtraitid,
		' and wh_columns.scaleid = ',xscaleid,
		' and wh_columns.tmethid = ',xmethid,
		' ORDER BY CAST(wh_data.dataval AS SIGNED) ',xsort);
	--
	-- data value is text
	--
	ELSE
		 SET @qry = concat('INSERT INTO newrow_',xsessionid,'( study,dataset,row ) ',
		' select wh_data.study,wh_data.dataset,wh_data.datarow',
		' from wh_data,wh_columns	',
		' where wh_data.study = wh_columns.study   ',
		' and wh_data.dataset = wh_columns.dataset ',
		' and wh_data.datacol = wh_columns.col     ',
		' and wh_columns.traitid = ',xtraitid,
		' and wh_columns.scaleid = ',xscaleid,
		' and wh_columns.tmethid = ',xmethid,
		' ORDER BY wh_data.dataval ',xsort);
	END IF;
ELSE
--
-- (QUERY within one dataset)
--
	--
	-- data value is numeric
	--
	IF trim(var_valuetype) = 'N' THEN
		SET @qry = concat('INSERT INTO newrow_',xsessionid,'( study,dataset,row ) ',
		' select wh_data.study,wh_data.dataset,wh_data.datarow',
		' from wh_data,wh_columns	',
		' where wh_data.study = wh_columns.study   ',
		' and wh_data.dataset = wh_columns.dataset ',
		' and wh_data.datacol = wh_columns.col     ',
		' and wh_columns.traitid = ',xtraitid,
		' and wh_columns.scaleid = ',xscaleid,
		' and wh_columns.tmethid = ',xmethid,
		' ORDER BY CAST(wh_data.dataval AS SIGNED) ',xsort);

	ELSE
	--
	-- data value is text
	--
 		SET @qry = concat('INSERT INTO newrow_',xsessionid,'( study,dataset,row ) ',
		' select wh_data.study,wh_data.dataset,wh_data.datarow',
		' from wh_data,wh_columns	',
		' where wh_columns.study = ',xstudy,
		' AND wh_columns.dataset = ',xrepresno, 
		' AND wh_data.study = wh_columns.study   ',
		' and wh_data.dataset = wh_columns.dataset ',
		' and wh_data.datacol = wh_columns.col     ',
		' and wh_columns.traitid = ',xtraitid,
		' and wh_columns.scaleid = ',xscaleid,
		' and wh_columns.tmethid = ',xmethid,
		' ORDER BY wh_data.dataval ',xsort);
	END IF;
END IF;

 PREPARE stmt1 FROM @qry;
 EXECUTE stmt1;
 DEALLOCATE PREPARE stmt1; 

IF (xstudy = 0) AND (xrepresno = 0) THEN
  SET @qry = CONCAT('SELECT w.study,w.dataset,n.newrow,w.datacol,w.dataval from newrow_',trim(xsessionid),' as n, wh_data as w   ',
' where n.study = w.study',
' and n.dataset = w.dataset',
' and n.row = w.datarow',
' order by n.newrow ');
ELSE
--
-- (QUERY within one dataset)
SET @qry = CONCAT('SELECT w.study,w.dataset,n.newrow,w.datacol,w.dataval from newrow_',trim(xsessionid),' as n, wh_data as w   ',
' where w.study = ',xstudy,
' and w.dataset = ',xrepresno,
' and n.study = w.study',
' and n.dataset = w.dataset',
' and n.row = w.datarow',
' order by n.newrow ');
END IF;
--
--
 PREPARE stmt1 FROM @qry;
 EXECUTE stmt1;
 DEALLOCATE PREPARE stmt1; 
--
--
END$$

DELIMITER ;


DELIMITER $$

DROP PROCEDURE IF EXISTS `get_column_values_per_obsunit`$$

CREATE PROCEDURE `get_column_values_per_obsunit`(
 IN var_ounitid INT, 
 IN var_represno INT, 
 IN var_study INT,
 IN row_num INT,
 OUT col_num INT)
BEGIN
 DECLARE done1 BOOL default FALSE;
 DECLARE var_fieldid INT;
 DECLARE var_coltype CHAR;
 DECLARE var_valtype CHAR;
 DECLARE iCountColumn INT default 0;
--
--
 DECLARE fieldid_cursor CURSOR FOR SELECT c.fieldid, c.coltype, c.valtype
 FROM wh_columns c
 WHERE c.study = var_study
 AND c.dataset = var_represno 
 order by c.study, c.dataset, c.coltype, c.fieldid;
--
--
 DECLARE  CONTINUE HANDLER FOR SQLSTATE '02000'  SET done1 = TRUE;
--
 OPEN fieldid_cursor;
 SET iCountColumn = 0;
 fieldid_loop: LOOP
 FETCH fieldid_cursor INTO var_fieldid,var_coltype,var_valtype;
 IF done1 THEN
	CLOSE fieldid_cursor;
	LEAVE fieldid_loop;
 END IF;
--
SET iCountColumn = iCountColumn + 1;
--
IF row_num = 1 THEN
		UPDATE wh_columns SET col = iCountColumn
		where fieldid = var_fieldid 
		and coltype = var_coltype
		and valtype = var_valtype
		and study = var_study 
		and dataset = var_represno;
END IF;
--
--
 CALL get_dataval(var_ounitid,var_fieldid,var_coltype,var_valtype,var_represno,var_study,row_num,iCountColumn);
 --
 END LOOP; 
 SET done1 = FALSE;
 SET col_num = iCountColumn;

 END$$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS `get_represno`$$

CREATE PROCEDURE `get_represno`(IN var_represno INT, IN var_study INT)
BEGIN
 DECLARE done1 BOOL default FALSE;
 DECLARE var_obsunit INT;
 DECLARE r INT DEFAULT 0;
 DECLARE c INT DEFAULT 0;
--
--
--
--
 DECLARE obs_cursor CURSOR FOR SELECT distinct o.ounitid
 FROM factor f, oindex o
 WHERE f.studyid = var_study
 and o.represno = var_represno
 AND o.factorid = f.factorid  
 ORDER BY o.ounitid;
--
--
 DECLARE  CONTINUE HANDLER FOR SQLSTATE '02000'  SET done1 = TRUE;
--
-- clean up table WH_DATASETS
--
 delete from wh_datasets where study = var_study and dataset = var_represno;
--
--
-- CREATE records in WH_DATA for each data cell
 OPEN obs_cursor;
 SET r = 0;
 row_loop:LOOP	
	FETCH obs_cursor INTO var_obsunit;
	
	IF done1 THEN
		LEAVE row_loop;
		CLOSE obs_cursor;
	END IF;
	--
        SET r = r + 1;
	CALL get_column_values_per_obsunit(var_obsunit,var_represno,var_study,r,c);
	--
 END LOOP row_loop;
 SET done1 = false;
--
-- populate WH_DATASETS table
--
 insert into wh_datasets
 select var_study,var_represno,r,c,'-';
--
--
--
END$$

DELIMITER ;