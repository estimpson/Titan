CREATE TABLE [dbo].[part_customer]
(
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[customer] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[customer_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[customer_standard_pack] [numeric] (20, 6) NOT NULL,
[taxable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_unit] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upc_code] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blanket_price] [numeric] (20, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_customer] ADD CONSTRAINT [part_customer_x] PRIMARY KEY CLUSTERED  ([part], [customer]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_customer] ADD CONSTRAINT [fk_part_customer1] FOREIGN KEY ([part]) REFERENCES [dbo].[part] ([part])
GO
