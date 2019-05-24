SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE	VIEW	[dbo].[vwFT_EDI_DESADV_PlasticOmnium_Header]

AS

SELECT	CONVERT(varchar(25), shipper.id) AS ShipperID,
		(CONVERT(varchar(4), DATEPART(yyyy,shipper.date_shipped))+
		CONVERT(varchar(2), DATEPART(mm,shipper.date_shipped))+
		CONVERT(varchar(2), DATEPART(dd,shipper.date_shipped))+
		CONVERT(varchar(2), DATEPART(hh,shipper.date_shipped))+
		CONVERT(varchar(2), DATEPART(mi,shipper.date_shipped)))AS DocumentDate,
		(CONVERT(varchar(4), DATEPART(yyyy,getdate()))+
		CONVERT(varchar(2), DATEPART(mm,getdate()))+
		CONVERT(varchar(2), DATEPART(dd,getdate()))+
		CONVERT(varchar(2), DATEPART(hh,getdate()))+
		CONVERT(varchar(2), DATEPART(mi,getdate())))AS DesadvDate,
		COALESCE(NULLIF(edi_setups.parent_destination,''),edi_setups.destination) AS ShipToID,
		edi_setups.supplier_code AS SupplierCode,
		'' AS Partial_Complete,
		trading_partner_code AS TradingPartner,
		CONVERT (varchar(10),CONVERT(int,shipper.gross_weight)) AS ShipperGrossWeight,
		CONVERT (varchar(10),CONVERT(int,shipper.net_weight)) AS ShipperNetWeight,
		CONVERT (varchar(10),CONVERT(int,shipper.staged_objs)) AS ShipperStagedObjects,
		CONVERT (varchar(10),COALESCE(bill_of_lading_number, id)) AS BOL,
		material_issuer AS MaterialIssuer,
		shipping_dock AS DockCode,
		trans_mode AS ShipperTransMode,
		ship_via AS ShipperSCAC,
		SUBSTRING(aetc_number,1,1) AS AETCReason,
		SUBSTRING(aetc_number,2,1) AS AETCResponsibility,
		SUBSTRING(aetc_number,3,10) AS AETCNumber,
		truck_number AS TrailerNumber,
		seal_number AS SealNumber,
		shipper.pro_number AS ProNumber	
		
FROM	dbo.shipper
JOIN	dbo.edi_setups ON dbo.shipper.destination = dbo.edi_setups.destination


GO
