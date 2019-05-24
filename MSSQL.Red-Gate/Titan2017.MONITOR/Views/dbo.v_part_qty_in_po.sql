SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







create view
  [dbo].[v_part_qty_in_po]
  as select po_detail.part_number,po_detail.plant,sum(standard_qty) s_qty from po_detail group by po_detail.part_number,po_detail.plant
GO
