SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO












CREATE PROCEDURE  [dbo].[Ftsp_LabelQuickReceive] (@Shipper VARCHAR(25)) --2901027
AS

BEGIN

SET NOCOUNT ON
SET ANSI_WARNINGS OFF
 

 -- [dbo].[Ftsp_LabelQuickReceive] 88538
 DECLARE @Note VARCHAR(50) ,
					@ShipperID INT

 
 SELECT 	     @Note =  (SELECT  'QUICK RECEIVE');
SELECT		 @ShipperID = (SELECT @Shipper);

										
		SELECT Note = @Note,
					 ShipperID =  @ShipperID
			FROM dbo.parameters
					


	END



















GO
