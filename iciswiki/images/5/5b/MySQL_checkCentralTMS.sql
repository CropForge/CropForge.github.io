DELIMITER $$;

DROP PROCEDURE IF EXISTS `grc_local_dms`.`checkCentralTMS`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `checkCentralTMS`(IN centraldb varchar(50), IN localdb varchar(50) )
BEGIN
	SET @updateTrait = concat('update ',localdb,'.trait lt, ',centraldb,'.trait ct  
				set lt.traitid  = ct.traitid
				where 	lt.trname = ct.trname');
	 PREPARE stmnt1 FROM @updateTrait;
	 EXECUTE stmnt1;
	 DEALLOCATE PREPARE stmnt1;
	
	SET @updateScale = concat('update ',localdb,'.scale ls, ',centraldb,'.scale cs  
				set ls.scaleid  = cs.scaleid, ls.traitid = cs.traitid
				where 	ls.scname = cs.scname and ls.traitid = cs.traitid');
	 PREPARE stmnt1 FROM @updateScale;
	 EXECUTE stmnt1;
	 DEALLOCATE PREPARE stmnt1;
	SET @updateMethod = concat('update ',localdb,'.tmethod lt, ',centraldb,'.tmethod ct  
				set lt.tmethid  = ct.tmethid, lt.traitid = ct.traitid
				where lt.tmname = ct.tmname and lt.traitid = ct.traitid');
	 PREPARE stmnt1 FROM @updateMethod;
	 EXECUTE stmnt1;
	 DEALLOCATE PREPARE stmnt1;
		
END$$

DELIMITER ;$$