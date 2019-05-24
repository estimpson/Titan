SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[vw_edi_cami_desadv_header] as
SELECT '' partial_complete,
			'9' purpose_code,
			'MB' ref_no_type,
			'182' resp_agency,
			'12' trans_stage,
			edi_setups.supplier_code,
			edi_setups.material_issuer,   
         shipper.id,   
         shipper.destination,   
         shipper.shipping_dock,   
         shipper.date_shipped,   
         shipper.aetc_number,   
        shipper.bill_of_lading_number,   
         shipper.gross_weight,
         shipper.net_weight,
			shipper.staged_objs,
			shipper.trans_mode,
			shipper.ship_via,
			upper(shipper.truck_number) AS TRAILERNUMBER,
			shipper.seal_number,
         destination.address_6,
			edi_setups.trading_partner_code,
			edi_setups.parent_destination,
			shipper.date_stamp,
			shipperpiecesshipped,
			shipper.pro_number
	 FROM destination,  
         edi_setups,  
         shipper 
	JOIN (Select 		sum(qty_packed) shipperpiecesshipped,
							shipper
							from	shipper_detail
					group by shipper) shipperdetail on shipper.id = shipperdetail.shipper
			
   WHERE ( shipper.destination = edi_setups.destination ) and
			( shipper.destination = destination.destination )
GO
