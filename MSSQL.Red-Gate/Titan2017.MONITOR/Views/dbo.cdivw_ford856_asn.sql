SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[cdivw_ford856_asn] 
	(audit_trail_serial, 
	audit_trail_quantity, 
	edi_setups_prev_cum_in_asn,
	shipper_detail_customer_part, 
	shipper_detail_alternative_qty, 
	shipper_detail_alternative_unit, 
	shipper_detail_net_weight, 
	shipper_detail_gross_weight, 
	shipper_detail_accum_shipped, 
	shipper_detail_shipper, 
	shipper_detail_customer_po,
	DOR,
	accum2,
	shipper_id)
as
select	audit_trail.serial, 
	audit_trail.quantity, 
	edi_setups.prev_cum_in_asn,
	shipper_detail.customer_part, 
	shipper_detail.alternative_qty, 
	shipper_detail.alternative_unit, 
	shipper_detail.net_weight, 
	shipper_detail.gross_weight, 
	shipper_detail.accum_shipped, 
	shipper_detail.shipper, 
	shipper_detail.customer_po,
	(CASE WHEN substring(shipper_detail.note,1,3) = 'DLR' THEN substring(shipper_Detail.note,1,16)
		ELSE ''
	END) as DOR,
	(SELECT isNULL(max(sd2.accum_shipped),0)
	FROM	shipper_detail sd2
	WHERE	sd2.order_no = shipper_detail.order_no and
		convert(datetime,sd2.date_shipped,101) = (SELECT max(convert(datetime,sd3.date_shipped,101))
					FROM	shipper_detail sd3
					WHERE	sd3.order_no = shipper_detail.order_no and
					convert(datetime,sd3.date_shipped,101) < convert(datetime,shipper_detail.date_shipped,101))) as accum2,
	shipper.id						
FROM	audit_trail, 
	edi_setups, 
	shipper_detail,
	shipper 
WHERE 	( audit_trail.shipper = convert(varchar,shipper.id)) and
	( shipper.destination = edi_setups.destination) and
	( audit_trail.part = shipper_detail.part_original ) and 
	( shipper_detail.shipper = shipper.id )
GO
