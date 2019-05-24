SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[cdivw_msf_inv]
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
GO
