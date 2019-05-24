SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE   view [dbo].[cdivw_titan_invform]
	(shipper_id,   
	destination_company,   
	destination_destination,   
	destination_name,   
	destination_address_1,   
	destination_address_2,   
	destination_address_3,   
	destination_address_4,   
	customer_customer,   
	customer_name,   
	customer_address_1,   
	customer_address_2,   
	customer_address_3,   
	customer_address_4,   
	edi_setups_supplier_code,   
	shipper_aetc_number,   
	destination_shipping_fob,   
	shipper_freight_type,   
	carrier_name,   
	shipper_detail_note,   
	order_header_customer_po,   
	shipper_detail_qty_original,   
	shipper_detail_qty_packed,   
	part_part,   
	part_cross_ref,   
	shipper_staged_objs,  
	shipper_gross_weight,   
	shipper_staged_pallets, 
	destination_shipping_note_for_bol,
	shipper_notes,
	shipper_detail_customer_part,
	shipper_tare_weight,
	shipper_net_weight,
	part_name,
	shipper_detail_boxes_staged,
	edi_setups_prev_cum_in_asn,
	shipper_detail_accum_shipped,
	consignee_name,
	consignee_address_1,
	consignee_address_2,
	consignee_address_3,
	consignee_address_4,
	shipper_detail_part_original,
	shipper_detail_customer_po,
	order_header_notes,
	shipper_shipping_dock,
	shipper_date_stamp,
	loose_objects)
as
select	shipper.id,   
	destination.company,   
	destination.destination,   
	destination.name,   
	destination.address_1,   
	destination.address_2,   
	destination.address_3,   
	destination.address_4,   
	customer.customer,   
	customer.name,   
	customer.address_1,   
	customer.address_2,   
	customer.address_3,   
	customer.address_4,   
	edi_setups.supplier_code,   
	shipper.aetc_number,   
	destination_shipping.fob,   
	shipper.freight_type,   
	carrier.name,   
	shipper_detail.note,   
	order_header.customer_po,   
	shipper_detail.qty_original,   
	shipper_detail.qty_packed,   
	part.part,   
	part.cross_ref,   
	shipper.staged_objs,  
	shipper.gross_weight,   
	isNULL(shipper.staged_pallets,0), 
	destination_shipping.note_for_bol,
	shipper.notes,
	shipper_detail.customer_part,
	shipper.tare_weight,
	shipper.net_weight,
	part.name,
	shipper_detail.boxes_staged,
	edi_setups.prev_cum_in_asn,
	shipper_detail.accum_shipped,
	consignee.name,
	consignee.address_1,
	consignee.address_2,
	consignee.address_3,
	consignee.address_4,
	shipper_detail.part_original,
	shipper_detail.customer_po,
	order_header.notes,
	shipper.shipping_dock,
	shipper.date_stamp,
	(Select isnull(count(1),0) from object
	where  object.shipper = shipper.id and
	(parent_serial is NULL or parent_serial =0)and
	object.part<>'PALLET' and
	show_on_shipper='Y') as loose_objects 
from	shipper
	join shipper_detail on shipper_detail.shipper = shipper.id
	left outer join destination on destination.destination = shipper.destination
	left outer join destination as consignee ON consignee.destination = substring((shipper.destination + (CASE WHEN PATINDEX ('%*%',shipper.shipping_dock)>0 THEN SUBSTRING (shipper.shipping_dock,1,PATINDEX ('%*%',shipper.shipping_dock)-1)
												ELSE shipper.shipping_dock END)),1,10)
	left outer join customer on customer.customer = destination.customer
	left outer join destination_shipping on destination_shipping.destination = destination.destination
	left outer join edi_setups on edi_setups.destination = destination.destination
	left outer join order_header on order_header.order_no = shipper_detail.order_no
	join part on part.part = shipper_detail.part_original
	left outer join carrier on carrier.scac = shipper.ship_via






GO
