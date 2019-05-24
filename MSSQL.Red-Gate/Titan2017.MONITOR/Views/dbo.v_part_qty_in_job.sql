SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view
  [dbo].[v_part_qty_in_job]
  as select workorder_detail.part,workorder_detail.plant,sum(balance) s_balance from workorder_detail group by workorder_detail.part,workorder_detail.plant
GO
