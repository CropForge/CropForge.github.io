-- CROPFINDER USE CASE:
-- FIELDSETUP table
-- mhabito 2008-2009

DELIMITER $$
DROP PROCEDURE IF EXISTS create_fieldsetup$$
CREATE PROCEDURE create_fieldsetup(IN xcrop VARCHAR(50),IN xdatabase VARCHAR(50))
BEGIN
	
--
-- Table structure for table `fieldsetup`
--

DROP TABLE IF EXISTS `fieldsetup`;
CREATE TABLE `fieldsetup` (
  `alignment` varchar(50) default NULL,
  `datatype` varchar(50) default NULL,
  `description` varchar(255) default NULL,
  `fieldid` int(11) default NULL,
  `fieldname` varchar(255) default NULL,
  `fieldtext` varchar(255) default NULL,
  `formatdef` varchar(50) default NULL,
  `groupoftraits` varchar(50) default NULL,
  `multilink` bit(1) default NULL,
  `nulltext` varchar(10) default NULL,
  `outputfield` bit(1) default NULL,
  `outputgroup` varchar(50) default NULL,
  `outputorder` int(11) default NULL,
  `tablename` varchar(50) default NULL,
  `tablealias` varchar(255) default NULL,
  `width` int(11) default NULL,
  `collection` varchar(50) default NULL,
  `nonullvalues` int(11) default NULL,
  `cbovalues` bit(1) default NULL,
  `numtotalregs` int(11) default NULL,
  `units` char(15) default NULL,
  `traitid` int(11) default NULL,
  `scaleid` int(11) default NULL,
  `tmethid` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
--
--
-- get study variates
--
insert into fieldsetup(alignment,datatype,description,fieldname,fieldtext,fieldid,groupoftraits,outputfield,outputgroup,collection,cbovalues,traitid,scaleid,tmethid)
select distinct 'Horizontal' as alignment, 
dtype as datatype, 
'-' as description, 
trim(vname) as fieldname, 
trim(vname) as fieldText,
       v.variatid,
       'Traits' as groupoftraits,
	1 as outputfield,
	'Traits' as outputGroup,
       'IRRI-CIMMYT' as collection , 
	0 as cboValues,
	v.traitid,
	v.scaleid,
	v.tmethid from variate v
order by description;
--
--
-- get info from TRAITS table
--
UPDATE fieldsetup as f, trait as t
set f.description = TRIM(t.trname),
	f.fieldname = replace(TRIM(t.trname),' ','_')
where f.traitid = t.traitid;
--
-- get info from SCALE table
--
--
UPDATE fieldsetup as f, scale as s
set f.description = IF(s.scname is null,f.description,CONCAT(f.description,' (',trim(s.scname),')')) ,
f.fieldname = IF(s.scname is null,f.fieldname,CONCAT(f.fieldname,'_',replace(trim(s.scname),' ','_')))
where f.scaleid = s.scaleid;
--
-- get info from TMETHOD table
--
--
UPDATE fieldsetup as f, tmethod as m
set f.description = IF(m.tmname is null,f.description,CONCAT(f.description,' ',trim(m.tmname))) ,
f.fieldname = IF(m.tmname is null,f.fieldname,CONCAT(f.fieldname,'_',replace(trim(m.tmname),' ','_')))
where f.tmethid = m.tmethid;
--
UPDATE fieldsetup as f
set f.description = replace(trim(f.description),'_',' ');
--
-- append the VARIATID
--
--
UPDATE fieldsetup as f
set f.fieldtext = CONCAT(f.fieldname,'.',cast(f.fieldid as char));
--
--
--
--
update fieldsetup
   set tablename = 'data_n',
       tablealias = CONCAT('data_n','_',rtrim(fieldname))
where datatype = 'N';
--
--
update fieldsetup
   set tablename = 'data_c',
       tablealias = CONCAT('data_c','_',rtrim(fieldname))
where datatype = 'C';
--
--
update fieldsetup
   set datatype = 'Real'
where datatype = 'N';
--
--
update fieldsetup
   set datatype = 'Text'
where datatype = 'C';
--
--
-- get the study factors
--
--
insert into fieldsetup(alignment,datatype,description,fieldname,fieldtext,fieldid,groupoftraits,outputfield,outputgroup,collection,cbovalues,traitid,scaleid,tmethid)
select distinct 'Horizontal' as alignment, ltype as datatype,rtrim(fname) as description,fname as fieldname, 
        concat(trim(fname),'.',cast(labelid as char)) as fieldText,
        labelid,
       'Factors' as groupoftraits,1 as outputfield,'Factors' as outputGroup,
       'IRRI-CIMMYT' as collection ,0 as cboValues, 
	traitid, 
	scaleid,
	tmethid from factor;
--
--
update fieldsetup
   set tablename = 'Factors',
       tablealias = 'Factors'
where datatype = 'N';
--
--
update fieldsetup
   set tablename = 'Factors',
       tablealias = 'Factors'
where datatype = 'C';
--
--
update fieldsetup
   set datatype = 'Real'
where datatype = 'N';
--
--
update fieldsetup
   set datatype = 'Text'
where datatype = 'C';
--
--
-- Do some data cleaning for IRIS...
--
IF upper(trim(xcrop)) = 'RICE' then 
DELETE FROM fieldsetup WHERE tablename = 'Factors' and fieldname = 'GID' and datatype = 'Text'; 
DELETE FROM fieldsetup WHERE tablename = 'Factors' and fieldname = 'GRPNO' and datatype = 'Text'; 
DELETE FROM fieldsetup WHERE tablename = 'Factors' and fieldname = 'ICIS_LOCID' and datatype = 'Text'; 
DELETE FROM fieldsetup WHERE tablename = 'Factors' and fieldname = 'PLOTNO' and datatype = 'Text'; 
DELETE FROM fieldsetup WHERE tablename = 'Factors' and fieldname = 'YEAR' and datatype = 'Text'; 
end if;


insert into fieldsetup(alignment,datatype,description,fieldname,fieldtext,groupoftraits,outputfield,outputgroup,collection,cbovalues)
select distinct 'Horizontal' as alignment,c.data_type as datatype,c.column_name as description,c.column_name as fieldname,
        c.column_name as fieldtext,
       'Study' as groupoftraits,1 as outputfield,'Study' as outputGroup,
       'IRRI-CIMMYT' as collection , 0 as cboValues 
from information_schema.columns c
where c.table_schema = xdatabase
and c.table_name = 'study';

update fieldsetup
   set tablename = 'Study',
       tablealias = 'Study'
where groupoftraits like '%Study%';

update fieldsetup
   set datatype = 'Real'
where datatype LIKE 'int%';

update fieldsetup
   set datatype = 'Text'
where datatype LIKE 'text%' or datatype LIKE 'varchar%';


update fieldsetup
   set fieldid = -999
where fieldid is null;

update fieldsetup
   set traitid = -999
where traitid is null;

update fieldsetup
   set tmethid = -999
where tmethid is null;


update fieldsetup
   set scaleid = -999
where scaleid is null;
 
update fieldsetup
   set width = 10
where width is null;


    END$$

DELIMITER ;