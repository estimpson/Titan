SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE	VIEW	[dbo].[vwft_EDI_DESADV_PlasticOmnium_Detail]

AS

SELECT	CONVERT(varchar(10),Shipper.id) AS ShipperID,
		'4' AS PackLevelCode,
		CONVERT(varchar(15), Shipper.staged_objs) AS StagedObjects,
		'CONT90' AS PackType,
		CONVERT(varchar(10),(SELECT COUNT(1) FROM shipper_detail sd2 WHERE sd2.part_original<= shipper_detail.part_original AND sd2.shipper = shipper_detail.shipper)) AS LineID,
		shipper_detail.customer_part AS Customerpart,
		CONVERT(varchar(15), CONVERT(int,shipper_detail.alternative_qty)) AS QtyShipped,
		CONVERT(varchar(15), CONVERT(int,shipper_detail.accum_shipped)) AS AccumQtyShipped,
		--ISNULL(SUBSTRING(shipper_detail.customer_po, 1, DATALENGTH(dbo.shipper_detail.customer_po)-3),'') AS CustomerPO,
		--ISNULL(SUBSTRING(shipper_detail.customer_po,DATALENGTH(dbo.shipper_detail.customer_po)-2, 10),'') AS CustomerPOLine,
		shipper_detail.customer_po AS CustomerPO,
		'' AS CustomerPOLine,
		order_header.model_year AS ModelYear		
		
FROM	dbo.shipper
JOIN	dbo.shipper_detail ON dbo.shipper.id = dbo.shipper_detail.shipper
JOIN	order_header ON dbo.shipper_detail.order_no = dbo.order_header.order_no
JOIN	dbo.edi_setups ON dbo.shipper.destination = dbo.edi_setups.destination


GO
