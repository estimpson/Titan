CREATE TABLE [dbo].[part_online]
(
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[on_hand] [numeric] (20, 6) NULL,
[on_demand] [numeric] (20, 6) NULL,
[on_schedule] [numeric] (20, 6) NULL,
[bom_net_out] [numeric] (20, 6) NULL,
[min_onhand] [numeric] (20, 6) NULL,
[max_onhand] [numeric] (20, 6) NULL,
[default_vendor] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default_po_number] [int] NULL,
[kanban_po_requisition] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[kanban_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_online] ADD CONSTRAINT [PK__part_online__3E52440B] PRIMARY KEY CLUSTERED  ([part]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_online] WITH NOCHECK ADD CONSTRAINT [fk_part_online_part] FOREIGN KEY ([part]) REFERENCES [dbo].[part] ([part])
GO
ALTER TABLE [dbo].[part_online] ADD CONSTRAINT [fk_part_online1] FOREIGN KEY ([part]) REFERENCES [dbo].[part] ([part])
GO
