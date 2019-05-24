SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











CREATE PROCEDURE  [dbo].[Ftsp_LabelInternal] (@serial VARCHAR(25)) --2901027
AS

BEGIN

SET NOCOUNT ON
SET ANSI_WARNINGS OFF
 

 -- [dbo].[Ftsp_LabelInternal] 2899292

--DECLARE #TempSerial TABLE(
--			objectstatus VARCHAR(50),
--		  	objectoperator VARCHAR(50),
--		  	objectquantity INT,
--		  	partpart VARCHAR(50),
--		  	CrossRef  VARCHAR(100),
--		  	activityroutercode VARCHAR(100),
--		  	activityroutersequence VARCHAR(100),
--			objectpackagetype VARCHAR(100)
--)


-- INSERT #TempSerial
--         ( objectstatus ,
--           objectoperator ,
--           objectquantity ,
--           partpart ,
--           CrossRef ,
--           activityroutercode ,
--           activityroutersequence ,
--           objectpackagetype
--         )

SELECT  	TOP 1 
		objectstatus=	 ( CASE 
										object.status 
										WHEN 'A'
										 THEN 'APP'
										 WHEN 'R'
										 THEN 'REJ'
										 ELSE 'HLD'
										 END ),
		  	objectoperator= object.operator,
		  	objectquantity = object.quantity,
		  	partpart = part.part,
		  	CrossRef = SUBSTRING(part.cross_ref,PATINDEX('%*%',part.cross_ref)+1,35),
		  	activityroutercode = activity_router.code,
		  	activityroutersequence = activity_router.sequence,
			objectpackagetype = object.package_type
		INTO #tempSerial
 FROM  	object,
  		  	part,
		  	activity_router
 WHERE  	object.part = activity_router.part  AND
 			object.part = part.part  AND
 		  	object.serial = CONVERT(INT, @serial) AND
			activity_router.sequence = (Select 	max(sequence) 
												   from  	activity_router ar2
												where		ar2.part = activity_router.part);


DECLARE 
@L_seqnew INT,
@l_seq INT,
@s_parent VARCHAR(50),
@s_next_act VARCHAR(50),
@s_partial VARCHAR(50),
@s_current_desc VARCHAR(100),
@s_next_act_desc VARCHAR(100)

SET @L_seqnew = (SELECT @l_seq + 1	)		

SET  	@s_parent = ( SELECT MIN(bill_of_material_ec.parent_part) /* min is used for case where there are multiple parent parts; activity will be the same*/

FROM 	   bill_of_material_ec
JOIN		#TempSerial ts ON
			ts.partpart = bill_of_material_ec.part
WHERE  	end_datetime is NULL )

SET  @s_next_act =  (SELECT ACTIVITY_ROUTER.CODE
FROM 	ACTIVITY_ROUTER
WHERE  activity_router.parent_part = @s_parent  AND
		 activity_router.sequence = @L_seqnew )
		 
if isnull(@s_next_act,'')=''
	 BEGIN
	SET	@s_next_act =  (SELECT activity
	from	part_machine
	where	part = @s_parent and sequence = 1 )
	END	

SET	@s_partial = (SELECT  'PARTIAL'
FROM		part_packaging pp
JOIN		#TempSerial ts ON ts.partpart = pp.part
AND		pp.code = ts.objectpackagetype
AND		pp.quantity>ts.objectquantity)

IF isNULL(@s_partial, '') = '' 
BEGIN
SET @s_partial = ( SELECT  'STDPACK')
END
			
IF isNULL(@s_next_act, '') = '' 
BEGIN
SET @s_next_act = (SELECT 'SHIP')
END

SET @s_current_desc =(SELECT  ac.NOTES
FROM   ACTIVITY_CODES ac
JOIN		#TempSerial ts ON ts.activityroutercode = ac.code)


SET  @s_next_act_desc = ( SELECT ACTIVITY_CODES.NOTES
FROM   ACTIVITY_CODES
WHERE  activity_codes.code = @s_next_act)

	  SELECT objectserial = @serial,
					objectstatus ,
					objectoperator ,
					objectquantity ,
					partpart ,
					CrossRef ,
					activityroutercode ,
					activityroutersequence ,
					objectpackagetype,
					l_seq = @l_seq,
					L_seqnew = @L_seqnew,
					s_current_desc = @s_current_desc,
					s_next_act = @s_next_act,
					s_next_act_desc = @s_next_act_desc,
					s_parent = @s_parent,
					s_partial = @s_partial

	  FROM #TempSerial


	END


















GO
