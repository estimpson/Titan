SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_EDI_BENTELER_862_AccumATH]
AS
SELECT TOP 100000		ReleaseNo = RTRIM(r1.ReleaseNo) ,
									ShipToID =( SELECT TOP 1 R2.ShipToID FROM edi_benteler862_AccumATH R2 WHERE R2.ReleaseNo= R1.ReleaseNo AND R2.CustomerPart = R1.CustomerPart AND R2.CustomerPO = R1.CustomerPO  AND LEN(RTRIM(r2.ShipToID))<9 ) ,
									CustomerPart = RTRIM(R1.CustomerPart),
									CustomerPO = RTRIM(r1.CustomerPO) ,
									AccumQuantity = CONVERT(NUMERIC(20,6),RTRIM(RIGHT(R1.AccumQuantity,15))) ,
									LASTDate  = convert(DATETIME,RTRIM(R1.LastDate))
									
FROM 
dbo.edi_benteler862_AccumATH R1
WHERE LEN(RTRIM(r1.ShipToID))>=9  AND LEFT(R1.AccumQuantity,2) = '02'
ORDER BY R1.CustomerPart, R1.LastDate
GO
