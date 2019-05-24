SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO













CREATE PROCEDURE  [dbo].[Ftsp_LabelRawMaterial] (@serial VARCHAR(25)) --2901027
AS

BEGIN

SET NOCOUNT ON
SET ANSI_WARNINGS OFF

 

 -- [dbo].[Ftsp_LabelRawMaterial] 2903811
 SELECT ObjectStatus ,
       ObjectSerial ,
       ObjectOperator ,
        ObjectQuantity ,
        partpart ,
        partname ,
        partcrossref ,
       objectlot FROM (
 
 SELECT 
	     ObjectStatus = ( CASE 
										object.status 
										WHEN 'A'
										 THEN 'APP'
										 WHEN 'R'
										 THEN 'REJ'
										 ELSE 'HLD'
										 END ),

			ObjectSerial =  object.serial							,
			ObjectOperator =  object.operator,
			ObjectQuantity = object.quantity,
			partpart	= part.part,
			partname = part.name,
			partcrossref = part.cross_ref,
			objectlot = object.lot
  
		  
  FROM  object
  		JOIN   part ON part.part = object.part
		  AND object.serial = CONVERT(INT, @serial) ) ObjectSerial


	END




















GO
