SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_EDI_BENTELER_830_RELEASES]
AS
SELECT TOP 100000		ReleaseNo = RTRIM(r1.ReleaseNo) ,
									ShipToID =( SELECT TOP 1 R2.ShipToID FROM edi_benteler830_Releases R2 WHERE R2.ReleaseNo= R1.ReleaseNo AND R2.CustomerPart = R1.CustomerPart AND R2.CustomerPO = R1.CustomerPO  AND LEN(RTRIM(r2.ShipToID))<9 ) ,
									CustomerPart = RTRIM(R1.CustomerPart),
									CustomerPO = RTRIM(r1.CustomerPO) ,
									Quantity = CONVERT(NUMERIC(20,6),RTRIM(R1.Quantity)) ,
									ShipDate  = convert(DATETIME,RTRIM(R1.ShipDate))
									
FROM 
dbo.edi_benteler830_Releases R1
WHERE LEN(RTRIM(r1.ShipToID))>=9  
ORDER BY R1.CustomerPart, r1.ShipDate
GO
