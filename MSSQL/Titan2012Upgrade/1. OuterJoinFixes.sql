use Monitor
go

alter view dbo.cdivw_msf_inv
(	description
,	unit
,	onhand
,	wo_quantity
,	batch_quantity
,	bom_part
,	bom_qty
,	work_order
)
as
	select
		max(name) description
	,	max(unit_measure) unit
	,	max(isnull(on_hand, 0)) onhand
	,	sum(isnull(quantity, 0) * isnull(qty_required, 0)) wo_quantity
	,	sum(isnull(mfg_lot_size, 0) * isnull(quantity, 0)) batch_quantity
	,	max(bill_of_material.part) bom_part
	,	sum(isnull(quantity, 0)) bom_qty
	,	max(work_order.work_order)
	from
		dbo.bill_of_material
		join dbo.work_order
			join dbo.machine_policy
				on work_order.machine_no = machine
				   and material_substitution = 'N'
			join dbo.workorder_detail
				on workorder_detail.workorder = work_order.work_order
			on bill_of_material.parent_part = workorder_detail.part
		join dbo.part
			on bill_of_material.part = part.part
		left join dbo.part_online
			on bill_of_material.part = part_online.part
		join part_mfg
			on bill_of_material.part = part_mfg.part
	where
		bill_of_material.substitute_part <> 'Y'
	group by
		bill_of_material.part
	,	work_order.work_order
go

alter procedure dbo.msp_titanform_release
	@po_number varchar(15)
as begin
	select
		vendor.contact
	,	po_header.po_number
	,	po_header.release_no
	,	vendor.buyer
	,	po_detail.part_number
	,	po_detail.description
	,	po_detail.balance
	,	po_detail.date_due
	,	destination.name
	,	destination.destination
	,	destination.address_1
	,	destination.address_2
	,	destination.address_3
	,	destination.address_4
	,	destination.address_5
	,	parameters.company_name
	,	parameters.address_1
	,	parameters.address_2
	,	parameters.address_3
	,	po_header.vendor_code
	,	vendor.name
	,	po_header.ship_to_destination
	,	vendor.contact
	,	po_detail.unit_of_measure
	,	vendor.address_1
	,	vendor.address_2
	,	vendor.address_3
	,	vendor.address_4
	,	vendor.address_5
	,	po_detail.notes
	,	po_header.notes
	,	part_vendor.vendor_part
	from
		dbo.po_detail
		join dbo.po_header
			join dbo.vendor
				on vendor.code = dbo.po_header.vendor_code
			on po_header.po_number = po_detail.po_number
		left join dbo.destination
			on po_header.ship_to_destination = destination.destination
		join dbo.part_vendor
			join dbo.part
				on part.part = part_vendor.part
				   and part.class = 'P'
			on po_header.vendor_code = part_vendor.vendor
			   and part_vendor.part = po_detail.part_number
		cross join parameters
	where
		po_header.po_number = convert(int, @po_number)
end
go

alter procedure dbo.msp_form_release
	@po_number varchar(15)
as begin
	select
		vendor.contact
	,	po_header.po_number
	,	po_header.release_no
	,	vendor.buyer
	,	po_detail.part_number
	,	po_detail.description
	,	po_detail.balance
	,	po_detail.date_due
	,	destination.name
	,	destination.destination
	,	destination.address_1
	,	destination.address_2
	,	destination.address_3
	,	destination.address_4
	,	destination.address_5
	,	parameters.company_name
	,	parameters.address_1
	,	parameters.address_2
	,	parameters.address_3
	,	po_header.vendor_code
	,	vendor.name
	,	po_header.ship_to_destination
	,	vendor.contact
	,	po_detail.unit_of_measure
	,	vendor.address_1
	,	vendor.address_2
	,	vendor.address_3
	,	vendor.address_4
	,	vendor.address_5
	,	po_detail.notes
	,	po_header.notes
	from
		dbo.po_detail
		join dbo.po_header
			join dbo.vendor
				on vendor.code = dbo.po_header.vendor_code
			on po_header.po_number = po_detail.po_number
		left join dbo.destination
			on po_header.ship_to_destination = destination.destination
		cross join parameters
	where
		po_header.po_number = convert(int, @po_number)
end
go

