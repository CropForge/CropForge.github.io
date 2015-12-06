DELIMITER $$;

DROP PROCEDURE IF EXISTS `grc_local_dms`.`uploadDMSwithQueries`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `uploadDMSwithQueries`(IN centraldb varchar(50), IN localdb varchar(50) )
BEGIN
DECLARE maxStudyid INT;
DECLARE maxLevelno INT;
DECLARE maxLevelc INT;
DECLARE maxLeveln INT;
DECLARE maxLabelid INT;
DECLARE maxTid INT;
DECLARE maxScaleid  INT;
DECLARE maxTmethid INT;
DECLARE maxVariatid INT;
DECLARE maxOunitid INT;
DECLARE maxDmsatid INT;
DECLARE maxEffectid  INT;
DECLARE maxRepresno INT;
DECLARE maxTraitid INT;
-- GET MAXIMUM IDs for each table
 SET @getMax = concat('SELECT MAX(studyid) INTO @maxStudyid FROM ',centraldb,'.study');
	 PREPARE stmnt1 FROM @getMax;
	 EXECUTE stmnt1;
	 DEALLOCATE PREPARE stmnt1;
-- SET @getMax = concat('SELECT MAX(t.levelno) INTO @maxLevelno
-- FROM
-- (SELECT levelno FROM ',centraldb,'.level_c 
-- UNION DISTINCT
-- SELECT  levelno FROM ',centraldb,'.level_n) t');
SET @getMax = concat('SELECT MAX(levelno) INTO @maxLevelc FROM ',centraldb,'.level_c');
	 PREPARE stmnt1 FROM @getMax;
	 EXECUTE stmnt1;
	 DEALLOCATE PREPARE stmnt1;
SET @getMax = concat('SELECT MAX(levelno) INTO @maxLeveln FROM ',centraldb,'.level_n');
	 PREPARE stmnt1 FROM @getMax;
	 EXECUTE stmnt1;
	 DEALLOCATE PREPARE stmnt1;
IF @maxLevelc>@maxLeveln then 
   SET  @maxLevelno = @maxLevelc;
ELSE
   SET @maxLevelno = @maxLeveln;
END IF;
SET @getMax = concat('SELECT MAX(labelid) INTO @maxLabelid FROM ',centraldb,'.factor');
	 PREPARE stmnt1 FROM @getMax;
	 EXECUTE stmnt1;
	 DEALLOCATE PREPARE stmnt1;
SET @getMax = concat('SELECT MAX(tid) INTO @maxTid FROM ',centraldb,'.trait');
	 PREPARE stmnt1 FROM @getMax;
	 EXECUTE stmnt1;
	 DEALLOCATE PREPARE stmnt1;
SET @getMax = concat('SELECT MAX(scaleid) INTO @maxScaleid FROM ',centraldb,'.scale');
	 PREPARE stmnt1 FROM @getMax;
	 EXECUTE stmnt1;
	 DEALLOCATE PREPARE stmnt1;
SET @getMax = concat('SELECT MAX(tmethid) INTO @maxTmethid FROM ',centraldb,'.tmethod');
	 PREPARE stmnt1 FROM @getMax;
	 EXECUTE stmnt1;
	 DEALLOCATE PREPARE stmnt1;
SET @getMax = concat('SELECT MAX(variatid) INTO @maxVariatid FROM ',centraldb,'.variate');
	 PREPARE stmnt1 FROM @getMax;
	 EXECUTE stmnt1;
	 DEALLOCATE PREPARE stmnt1;
SET @getMax = concat('SELECT MAX(ounitid) INTO @maxOunitid FROM ',centraldb,'.oindex');
	 PREPARE stmnt1 FROM @getMax;
	 EXECUTE stmnt1;
	 DEALLOCATE PREPARE stmnt1;
SET @getMax = concat('SELECT MAX(dmsatid) INTO @maxDmsatid FROM ',centraldb,'.dmsattr');
	 PREPARE stmnt1 FROM @getMax;
	 EXECUTE stmnt1;
	 DEALLOCATE PREPARE stmnt1;
SET @getMax = concat('SELECT MAX(effectid) INTO @maxEffectid FROM ',centraldb,'.effect');
	 PREPARE stmnt1 FROM @getMax;
	 EXECUTE stmnt1;
	 DEALLOCATE PREPARE stmnt1;
SET @getMax = concat('SELECT MAX(represno) INTO @maxRepresno FROM ',centraldb,'.effect');
	 PREPARE stmnt1 FROM @getMax;
	 EXECUTE stmnt1;
	 DEALLOCATE PREPARE stmnt1;
SET @getMax = concat('SELECT MAX(traitid) INTO @maxTraitid FROM ',centraldb,'.trait');
	 PREPARE stmnt1 FROM @getMax;
	 EXECUTE stmnt1;
	 DEALLOCATE PREPARE stmnt1;
-- Create all new Tables
CREATE TABLE zNewStudy ( studyid int);
CREATE TABLE zNewLabel ( labelid int);
CREATE TABLE zNewLevel ( levelno int);
CREATE TABLE zNewOunit ( ounitid int);
CREATE TABLE zNewVariate ( variatid int);
CREATE TABLE zNewEffect ( effectid int);
CREATE TABLE zNewRepresno ( represno int);
CREATE TABLE zNewTrait ( traitid int);
CREATE TABLE zNewScale ( scaleid int);
CREATE TABLE zNewTmethod ( tmethid int);
-- INSERT all IDs to the new tables
INSERT INTO zNewStudy 
	SELECT DISTINCT studyid FROM study where studyid<0;
INSERT INTO zNewLabel 
	SELECT DISTINCT labelid FROM factor where labelid<0;
INSERT INTO zNewLevel 
	Select newLevelTable.levelno FROM
	(SELECT levelno FROM level_c  where levelno<0
	UNION DISTINCT
	SELECT  levelno FROM level_n where levelno<0) as newLevelTable;
INSERT INTO zNewOunit 
	SELECT DISTINCT ounitid FROM oindex where ounitid <0;
INSERT INTO zNewVariate 
	SELECT DISTINCT variatid FROM variate where variatid<0;
INSERT INTO zNewEffect 
	SELECT DISTINCT effectid FROM effect where effectid<0;
INSERT INTO zNewRepresno
	SELECT DISTINCT represno FROM effect where represno<0;
INSERT INTO zNewTrait
	SELECT DISTINCT traitid FROM trait where traitid<0;
INSERT INTO zNewScale
	SELECT DISTINCT scaleid FROM scale where scaleid<0;
INSERT INTO zNewTmethod
	SELECT DISTINCT  tmethid FROM tmethod where tmethid<0;
-- ADD new Auto increment column to the tables
ALTER TABLE zNewStudy ADD COLUMN (newStudyid INT, id INT AUTO_INCREMENT NOT NULL PRIMARY KEY);
ALTER TABLE zNewLabel ADD COLUMN (newLabelid INT, id INT AUTO_INCREMENT NOT NULL PRIMARY KEY);
ALTER TABLE zNewLevel ADD COLUMN (newlevelno INT, id INT AUTO_INCREMENT NOT NULL PRIMARY KEY);
ALTER TABLE zNewOunit ADD COLUMN (newOunitid INT, id INT  AUTO_INCREMENT NOT NULL PRIMARY KEY);
ALTER TABLE zNewVariate ADD COLUMN (newVariatid INT , id INT AUTO_INCREMENT NOT NULL PRIMARY KEY);
ALTER TABLE zNewEffect ADD COLUMN (newEffectid INT , id INT AUTO_INCREMENT NOT NULL PRIMARY KEY);
ALTER TABLE zNewRepresno ADD COLUMN (newRepresno INT , id INT AUTO_INCREMENT NOT NULL PRIMARY KEY);
ALTER TABLE zNewTrait ADD COLUMN (newTraitid INT , id INT AUTO_INCREMENT NOT NULL PRIMARY KEY);
ALTER TABLE zNewScale ADD COLUMN (newScaleid INT , id INT AUTO_INCREMENT NOT NULL PRIMARY KEY);
ALTER TABLE zNewTmethod ADD COLUMN (newTmethid INT , id INT AUTO_INCREMENT NOT NULL PRIMARY KEY);
-- Generate new IDs 
UPDATE zNewStudy set newStudyid = id + @maxStudyid;
UPDATE zNewLabel set newLabelid = id + @maxLabelid;
UPDATE zNewLevel set newLevelno = id + @maxLevelno;
UPDATE zNewOunit set newOunitid = id + @maxOunitid;
UPDATE zNewVariate set newVariatid = id + @maxVariatid;
UPDATE zNewEffect set newEffectid = id + @maxEffectid;
UPDATE zNewRepresno set newRepresno = id + @maxRepresno;
UPDATE zNewTrait set newTraitid = id + @maxTraitid;
UPDATE zNewScale set newScaleid = id + @maxScaleid;
UPDATE zNewTmethod set newTmethid = id + @maxTmethid;
-- ADD INDEX to New Tables
alter table zneweffect add index effectid(effectid);
alter table znewlabel add index labelid(labelid);
alter table znewounit add index ounitid(ounitid);
alter table znewlevel add index levelno(levelno);
alter table znewrepresno add index represno(represno);
alter table znewscale add index scaleid(scaleid);
alter table znewstudy add index studyid(studyid);
alter table znewtmethod add index tmethid(tmethid);
alter table znewtrait add index traitid(traitid);
alter table znewvariate add index variatid(variatid);
UPDATE study s, zNewStudy z
SET s.studyid = z.newStudyid
WHERE s.studyid = z.studyid;
-- UPDATE FACTOR
UPDATE  factor f, zNewLabel z
SET f.factorid = z.newLabelid
WHERE f.factorid = z.labelid;
UPDATE  factor f, zNewLabel z
SET f.labelid = z.newLabelid 
WHERE f.labelid = z.labelid;
UPDATE  factor f, zNewStudy z
SET f.studyid = z.newStudyid
WHERE f.studyid = z.studyid;
UPDATE  factor f, zNewTrait z
SET f.traitid = z.newTraitid 
WHERE f.traitid = z.Traitid;
UPDATE  factor f, zNewScale z
SET f.scaleid = z.newScaleid 
WHERE f.scaleid = z.scaleid;
UPDATE  factor f, zNewTmethod z
SET f.tmethid = z.newTmethid 
WHERE f.tmethid = z.Tmethid;
-- UPDATE LEVEL_C
UPDATE  level_c l, zNewLevel z
SET l.levelno = z.newLevelno
WHERE l.levelno = z.levelno;
UPDATE  level_c l, zNewLabel z
SET l.labelid = z.newLabelid
WHERE l.labelid = z.labelid;
UPDATE  level_c l, zNewLabel z
SET l.factorid = z.newLabelid
WHERE l.factorid = z.labelid;
-- UPDATE LEVEL_N
UPDATE  level_n l, zNewLabel z
SET l.factorid = z.newLabelid
WHERE l.factorid = z.labelid;
UPDATE  level_n l, zNewLevel z
SET l.levelno = z.newLevelno
WHERE l.levelno = z.levelno;
UPDATE  level_n l, zNewLabel z
SET l.labelid = z.newLabelid
WHERE l.labelid = z.labelid;
-- UPDATE EFFECT
UPDATE  effect e, zNewEffect z
SET e.effectid = z.newEffectid
WHERE e.effectid = z.effectid;
UPDATE  effect e, zNewLabel z
SET e.factorid = z.newLabelid
WHERE e.factorid = z.labelid;
UPDATE  effect e, zNewRepresno z
SET e.represno = z.newRepresno
WHERE e.represno = z.represno;
-- UPDATE OINDEX
UPDATE  oindex o, zNewOunit z
SET o.ounitid = z.newOunitid
WHERE o.ounitid = z.ounitid;
UPDATE  oindex o, zNewLabel z
SET o.factorid = z.newLabelid
WHERE o.factorid = z.labelid;
UPDATE  oindex o, zNewLevel z
SET o.levelno = z.newLevelno
WHERE o.levelno = z.levelno;
UPDATE  oindex o, zNewRepresno z
SET o.represno = z.newRepresno
WHERE o.represno = z.represno;
-- UPDATE VEFFECT
UPDATE  veffect v, zNewRepresno z
SET v.represno = z.newRepresno
WHERE v.represno = z.represno;
UPDATE veffect v, zNewVariate z
SET v.variatid = z.newVariatid
WHERE v.variatid = z.variatid;
-- UPDATE VARIATE
UPDATE  variate v, zNewVariate z
SET v.variatid = z.newVariatid
WHERE v.variatid = z.variatid;
UPDATE  variate v, zNewStudy z
SET v.studyid = z.newStudyid
WHERE v.studyid = z.studyid;
UPDATE  variate v, zNewTrait z
SET v.traitid = z.newTraitid 
WHERE v.traitid = z.Traitid;
UPDATE  variate v, zNewScale z
SET v.scaleid = z.newScaleid
WHERE v.scaleid = z.scaleid;
UPDATE  variate v, zNewTmethod z
SET v.tmethid = z.newTmethid 
WHERE v.tmethid = z.Tmethid;
-- UPDATE DATA_C
UPDATE data_c d, zNewVariate z
SET d.variatid = z.newVariatid
WHERE d.variatid = z.variatid;
UPDATE  data_c d, zNewOunit z
SET d.ounitid = z.newOunitid
WHERE d.ounitid = z.ounitid;
-- UPDATE DATA_N
UPDATE data_n d, zNewVariate z
SET d.variatid = z.newVariatid
WHERE d.variatid = z.variatid;
UPDATE  data_n d, zNewOunit z
SET d.ounitid = z.newOunitid
WHERE d.ounitid = z.ounitid;
-- UPDATE DMSATTR
UPDATE dmsattr d, zNewVariate z
SET d.dmsatrec = z.newVariatid
WHERE d.dmsatrec = z.variatid
and d.dmsatab = "VARIATE";
UPDATE dmsattr d, zNewLabel z
SET d.dmsatrec = z.newLabelid
WHERE d.dmsatrec = z.labelid
and d.dmsatab = "FACTOR";
-- UPDATE TRAIT
UPDATE  trait t, zNewTrait z
SET t.traitid = z.newTraitid
WHERE t.traitid = z.traitid;
UPDATE  trait t, zNewTrait z
SET t.tid = -(t.tid)+ @maxTraitid
WHERE t.traitid = z.traitid;
-- UPDATE SCALE
UPDATE  scale s, zNewTrait z
SET s.traitid = z.newTraitid
WHERE s.traitid = z.traitid;
UPDATE  scale s, zNewScale z
SET s.scaleid = z.newScaleid
WHERE s.scaleid = z.scaleid;
-- UPDATE TMETHOD
UPDATE  tmethod t, zNewTrait z
SET t.traitid = z.newTraitid
WHERE t.traitid = z.traitid;
UPDATE  tmethod t, zNewTmethod z
SET t.tmethid = z.newTmethid
WHERE t.tmethid = z.tmethid;
-- UPDATE SCALEDIS
UPDATE  scaledis s, zNewScale z
SET s.scaleid = z.newScaleid
WHERE s.scaleid = z.scaleid;
	
-- UPLOAD New values to Central TABLES
	
	SET @upload = concat('INSERT INTO ',centraldb,'.study ( StudyID, SNAME, PMKEY, Title, OBJECTIV, STYPE, SDATE, EDATE, USERID )
        SELECT STUDYID, SNAME, PMKEY, TITLE,OBJECTIV, STYPE, SDATE, EDATE,USERID 
	FROM  ',localdb,'.study');
	PREPARE stmnt1 FROM @upload;
	EXECUTE stmnt1;
	DEALLOCATE PREPARE stmnt1;
	
	SET @upload = concat('INSERT INTO ',centraldb,'.FACTOR ( LABELID, FactorID, StudyID, FNAME, TraitID, ScaleID, TMETHID, LTYPE )
	SELECT LABELID, FACTORID, STUDYID, FNAME,TRAITID,SCALEID,TMETHID,LTYPE 
	FROM  ',localdb,'.FACTOR');
	PREPARE stmnt1 FROM @upload;
	EXECUTE stmnt1;
	DEALLOCATE PREPARE stmnt1;
	SET @upload = CONCAT('INSERT INTO ',centraldb,'.VARIATE ( VARIATID, StudyID, VNAME, TraitID, ScaleID, TMETHID, DTYPE, VTYPE )
	SELECT VARIATID,STUDYID ,VNAME,TRAITID,SCALEID,TMETHID,DTYPE,VTYPE 
	FROM ',localdb,'.VARIATE');
	PREPARE stmnt1 FROM @upload;
	EXECUTE stmnt1;
	DEALLOCATE PREPARE stmnt1;
	SET @upload = CONCAT('INSERT INTO ', centraldb,'.OINDEX ( OUNITID, FACTORID, LEVELNO, REPRESNO )
	SELECT OUNITID,FACTORID,LEVELNO,REPRESNO 
	FROM ',localdb,'.OINDEX');
	PREPARE stmnt1 FROM @upload;
	EXECUTE stmnt1;
	DEALLOCATE PREPARE stmnt1;
	SET @upload = CONCAT('INSERT INTO ',centraldb,'.LEVEL_N ( LABELID, FactorID, LevelNo, LVALUE )
	SELECT LABELID , FACTORID,LEVELNO,LVALUE AS
	FROM ',localdb,'.LEVEL_N');
	PREPARE stmnt1 FROM @upload;
	EXECUTE stmnt1;
	DEALLOCATE PREPARE stmnt1;
	SET @upload = CONCAT('INSERT INTO ',centraldb,'.LEVEL_C ( LABELID, FactorID, LevelNo, LVALUE )
	SELECT LABELID , FACTORID,LEVELNO,LVALUE AS
	FROM ',localdb,'.LEVEL_C');
	PREPARE stmnt1 FROM @upload;
	EXECUTE stmnt1;
	DEALLOCATE PREPARE stmnt1;
	SET @upload = CONCAT('INSERT INTO ',centraldb,'.DATA_N ( OUNITID, VARIATID, DVALUE )
	SELECT OUNITID, VARIATID, DVALUE 
	FROM ',localdb,'.DATA_N');
	PREPARE stmnt1 FROM @upload;
	EXECUTE stmnt1;
	DEALLOCATE PREPARE stmnt1;
	SET @upload = CONCAT('INSERT INTO ',centraldb,'.DATA_C ( OUNITID, VARIATID, DVALUE )
	SELECT OUNITID, VARIATID, DVALUE 
	FROM ',localdb,'.DATA_C');
	PREPARE stmnt1 FROM @upload;
	EXECUTE stmnt1;
	DEALLOCATE PREPARE stmnt1;
	SET @upload = CONCAT('INSERT INTO ',centraldb,'.DMSATTR ( DMSATID, DMSATYPE, DMSATAB, DMSATREC, DMSATVAL )
	SELECT DMSATID, DMSATYPE, DMSATAB, DMSATREC, DMSATVAL
	FROM ', localdb,'.DMSATTR WHERE DMSATAB<>"LISTNMS"');
	PREPARE stmnt1 FROM @upload;
	EXECUTE stmnt1;
	DEALLOCATE PREPARE stmnt1;
 -- k
	SET @upload = CONCAT('INSERT INTO ',centraldb,'.EFFECT ( REPRESNO, FACTORID, EFFECTID )
	SELECT REPRESNO, FACTORID,EFFECTID
	FROM ',localdb,'.EFFECT');
	PREPARE stmnt1 FROM @upload;
	EXECUTE stmnt1;
	DEALLOCATE PREPARE stmnt1;
 
	SET @upload = CONCAT('INSERT INTO ',centraldb,'.VEFFECT ( REPRESNO, VARIATID )
	SELECT REPRESNO, VARIATID
	FROM ',localdb,'.VEFFECT');
	PREPARE stmnt1 FROM @upload;
	EXECUTE stmnt1;
	DEALLOCATE PREPARE stmnt1;
	SET @upload = CONCAT('INSERT INTO ',centraldb,'.TRAIT ( TID, TRAITID, TRNAME, TRABBR, TRDESC, SCALEID, TMETHID, TNSTAT )
	SELECT TID, TRAITID, TRNAME, TRABBR, TRDESC,SCALEID, TMETHID, TNSTAT
	FROM ',localdb,'.TRAIT');
	PREPARE stmnt1 FROM @upload;
	EXECUTE stmnt1;
	DEALLOCATE PREPARE stmnt1;
	SET @upload = CONCAT('INSERT INTO ', centraldb,'.SCALE ( SCALEID, SCNAME, TRAITID, SCTYPE )
	SELECT SCALEID, SCNAME, TRAITID, SCTYPE
	FROM ', localdb,'. SCALE');
	PREPARE stmnt1 FROM @upload;
	EXECUTE stmnt1;
	DEALLOCATE PREPARE stmnt1;
	SET @upload = CONCAT('INSERT INTO ',centraldb,'.TMETHOD ( TMETHID, TMNAME, TRAITID, TMABBR, TMDESC )
	SELECT TMETHID, TMNAME, TRAITID, TMABBR, TMDESC 
	FROM ',localdb,'.TMETHOD');
	PREPARE stmnt1 FROM @upload;
	EXECUTE stmnt1;
	DEALLOCATE PREPARE stmnt1;
END$$

DELIMITER ;$$