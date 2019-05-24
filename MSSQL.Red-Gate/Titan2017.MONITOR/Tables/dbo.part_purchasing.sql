CREATE TABLE [dbo].[part_purchasing]
(
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[buyer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[min_order_qty] [numeric] (20, 6) NULL,
[reorder_trigger_qty] [numeric] (20, 6) NULL,
[min_on_hand_qty] [numeric] (20, 6) NULL,
[primary_vendor] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_purchasing] ADD CONSTRAINT [PK__part_purchasing__49C3F6B7] PRIMARY KEY CLUSTERED  ([part]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_purchasing] WITH NOCHECK ADD CONSTRAINT [fk_part_purchasing_part] FOREIGN KEY ([part]) REFERENCES [dbo].[part] ([part])
GO
ALTER TABLE [dbo].[part_purchasing] ADD CONSTRAINT [fk_part_purchasing1] FOREIGN KEY ([part]) REFERENCES [dbo].[part] ([part])
GO
