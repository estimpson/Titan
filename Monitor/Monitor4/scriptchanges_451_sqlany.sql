if exists(select 1 from sysobjects where name = 'cdivw_inv_inquiry')
	drop view cdivw_inv_inquiry
go

create view cdivw_inv_inquiry (	
	invoice_number,   
	id,   
	date_shipped,   
	destination,   
	customer,   
	ship_via,   
	invoice_printed,   
	notes,   
	type,   
	shipping_dock,   
	status,   
	aetc_number,   
	freight_type,   
	printed,   
	bill_of_lading_number,   
	model_year_desc,   
	model_year,   
	location,   
	staged_objs,   
	plant,   
	invoiced,   
	freight,   
	tax_percentage,   
	total_amount,   
	gross_weight,   
	net_weight,   
	tare_weight,   
	responsibility_code,   
	trans_mode,   
	pro_number,   
	time_shipped,   
	truck_number,   
	seal_number,   
	terms,   
	tax_rate,   
	staged_pallets,   
	container_message,   
	picklist_printed,   
	dropship_reconciled,   
	date_stamp,   
	platinum_trx_ctrl_num,   
	posted,   
	scheduled_ship_time, 
	part) as  
select	shipper.invoice_number,   
	shipper.id,   
	shipper.date_shipped,   
	shipper.destination,   
	shipper.customer,   
	shipper.ship_via,   
	shipper.invoice_printed,   
	shipper.notes,   
	shipper.type,   
	shipper.shipping_dock,   
	shipper.status,   
	shipper.aetc_number,   
	shipper.freight_type,   
	shipper.printed,   
	shipper.bill_of_lading_number,   
	shipper.model_year_desc,   
	shipper.model_year,   
	shipper.location,   
	shipper.staged_objs,   
	shipper.plant,   
	shipper.invoiced,   
	shipper.freight,   
	shipper.tax_percentage,   
	shipper.total_amount,   
	shipper.gross_weight,   
	shipper.net_weight,   
	shipper.tare_weight,   
	shipper.responsibility_code,   
	shipper.trans_mode,   
	shipper.pro_number,   
	shipper.time_shipped,   
	shipper.truck_number,   
	shipper.seal_number,   
	shipper.terms,   
	shipper.tax_rate,   
	shipper.staged_pallets,   
	shipper.container_message,   
	shipper.picklist_printed,   
	shipper.dropship_reconciled,   
	shipper.date_stamp,   
	shipper.platinum_trx_ctrl_num,   
	shipper.posted,   
	shipper.scheduled_ship_time,  
	shipper_detail.part_original
from	shipper 
	left outer join shipper_detail on shipper_detail.shipper = shipper.id
where	isnull(shipper.type,'') not in ('V','O') and
	isnull(shipper_detail.qty_packed,0) > 0 
go


if exists(select 1 from sysobjects where name = 'cdisp_ovproc')
	drop procedure cdisp_ovproc
go
create procedure cdisp_ovproc (@order_no integer ) as
begin	
	SELECT	oh.order_no,
		oh.destination,
		oh.customer_part,
		oh.our_cum,
		ohi.the_cum their_cum,
		sd.date_shipped our_shipped_date,
		ohi.shipped_date their_shipped_date,
		sd.qty_packed our_shipped,
		ohi.shipped their_shipped,
		ohi.order_date,
		odi.part_number,
		odi.type,
		odi.due_date,
		odi.sequence,
		IsNull ( ( select Max ( od.quantity ) from order_detail od where od.order_no = odi.order_no and od.due_date = odi.due_date and od.notes = odi.notes), 0 ) old_quantity,
		IsNull ( quantity, 0 ) quantity,
		' ' checked,
		odi.status,
		Left ( odi.notes, 3 ) notes,
		ohi.review_date,
		ohi.reviewed_by
	FROM	order_detail_inserted  odi
		JOIN order_header oh ON odi.order_no = oh.order_no
		JOIN order_header_inserted ohi ON odi.order_no = ohi.order_no AND
			ohi.order_date = (
				SELECT	Max ( ohi2.order_date )
				  FROM	order_header_inserted ohi2
				 WHERE	ohi2.order_no = odi.order_no )
		LEFT OUTER JOIN shipper_detail sd ON sd.order_no = oh.order_no AND
			sd.shipper = oh.shipper AND
			sd.part_original = oh.blanket_part AND
			sd.date_shipped =
			(	SELECT	Max ( date_shipped )
				FROM	shipper_detail sd1
				WHERE	sd1.order_no = oh.order_no AND
					sd1.shipper = oh.shipper AND
					sd1.part_original = oh.blanket_part )
	WHERE	oh.order_no = @order_no
	UNION 
	SELECT	oh.order_no,
		oh.destination,
		oh.customer_part,
		oh.our_cum,
		ohi.the_cum their_cum,
		sd.date_shipped our_shipped_date,
		ohi.shipped_date their_shipped_date,
		sd.qty_packed our_shipped,
		ohi.shipped their_shipped,
		ohi.order_date,
		od.part_number,
		od.type,
		od.due_date,
		( select Max ( odi.sequence ) from order_detail_inserted odi where odi.order_no = od.order_no and odi.due_date = od.due_date and odi.notes = od.notes),
		IsNull ( quantity, 0 ),
		IsNull ( ( select Max ( odi.quantity ) from order_detail_inserted odi where odi.order_no = od.order_no and odi.due_date = od.due_date and odi.notes = od.notes), 0 ),
		' ',
		( select Max ( odi.status ) from order_detail_inserted odi where odi.order_no = od.order_no and odi.due_date = od.due_date and odi.notes = od.notes),
		Left ( od.notes, 3 ),
		ohi.review_date,
		ohi.reviewed_by
	FROM	order_detail od
		JOIN order_header oh ON od.order_no = oh.order_no
		JOIN order_header_inserted ohi ON od.order_no = ohi.order_no AND
			ohi.order_date = (
				SELECT	Max ( ohi2.order_date )
				  FROM	order_header_inserted ohi2
				 WHERE	ohi2.order_no = od.order_no )
		LEFT OUTER JOIN shipper_detail sd ON sd.order_no = oh.order_no AND
			sd.shipper = oh.shipper AND
			sd.part_original = oh.blanket_part AND
			sd.date_shipped =
			(	SELECT	Max ( date_shipped )
				FROM	shipper_detail sd1
				WHERE	sd1.order_no = oh.order_no AND
					sd1.shipper = oh.shipper AND
					sd1.part_original = oh.blanket_part )
	WHERE	oh.order_no = @order_no
	ORDER BY 1, 13, 16 desc
end
go

update admin set version = '4.5.1'
go
commit
go
