if exists (
	select	1
	  from	sysobjects
	 where	id = object_id ( 'CDIsp_karmax_asn_detail' ) )
	drop procedure CDIsp_karmax_asn_detail
go

create procedure CDIsp_karmax_asn_detail  (@shipper integer)
as

Begin

Create table #atr_package_type (
		part			varchar(25),
		package_type		varchar(25),
		pack_qty 			numeric(20,6),
		pack_count		int
		)


Create table #atr_objects(
		serial 		int,
		part		varchar(25),
		package_quantity	varchar(25), 
		package_type	varchar(25)
		)



Insert 	#atr_package_type
Select 	audit_trail.part,
	min('CNT71') as pack_type,
	audit_trail.quantity,
	count(1)

From	audit_trail
		
Where	audit_trail.type = 'S' and
	audit_trail.part <> 'PALLET' and
	audit_trail.shipper = CONVERT(varchar(25), @shipper)

Group By	audit_trail.part,
	audit_trail.quantity



Insert	#atr_objects

Select	audit_trail.serial,
	audit_trail.part,
	audit_trail.quantity,
	'CNT71'

From	audit_trail

Where	audit_trail.type = 'S' and
	audit_trail.part <> 'PALLET'  and
	audit_trail.shipper = CONVERT(varchar(25), @shipper)
	
	
SELECT 		edi_setups.prev_cum_in_asn,
		shipper_detail.customer_part, 
		shipper_detail.alternative_qty, 
		shipper_detail.alternative_unit, 
		shipper_detail.net_weight, 
		shipper_detail.gross_weight, 
		shipper_detail.accum_shipped,
		(SELECT isNULL(max(sd2.accum_shipped),0)
			FROM shipper_detail sd2
         		WHERE  sd2.order_no = shipper_detail.order_no and
                       	convert(varchar(10), sd2.date_shipped, 101) = (SELECT 	max(convert(varchar(10), sd3.date_shipped, 101))
                       					FROM	shipper_detail sd3
                       					WHERE	sd3.order_no = shipper_detail.order_no and
                       					convert(varchar(10), sd3.date_shipped, 101) < convert(varchar(10), shipper_detail.date_shipped, 101))) as accum2, 
		shipper_detail.shipper, 
		shipper_detail.customer_po,
		#atr_package_type.package_type as pack_type,
                       	#atr_package_type.pack_count as pack_count,
                       	#atr_package_type.pack_qty as pack_quantity,
                       	#atr_objects.serial as pack_serial,
                       	order_header.dock_code,
                       	order_header.line_feed_code	
 
FROM 		edi_setups, 
		shipper_detail,
		shipper,
		#atr_package_type,
		#atr_objects,
		order_header 

WHERE		( shipper.destination = edi_setups.destination) and
		( shipper.id = @shipper) and 
		( #atr_package_type.part = shipper_detail.part_original ) and
		( #atr_objects.part = shipper_detail.part_original) and
		( #atr_objects.part = #atr_package_type.part) and
		( #atr_objects.package_quantity = #atr_package_type.pack_qty) and
		( #atr_objects.package_type = #atr_package_type.package_type) and
		( order_header.order_no = shipper_detail.order_no) and		 
		( ( shipper_detail.shipper = @shipper ) ) 

ORDER BY	shipper_detail.customer_part,
		pack_type,
		pack_count,
		pack_quantity,
		pack_serial

End

go

grant execute on CDIsp_karmax_asn_detail to public


