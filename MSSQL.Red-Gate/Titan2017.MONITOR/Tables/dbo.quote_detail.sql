CREATE TABLE [dbo].[quote_detail]
(
[quote_number] [int] NOT NULL,
[sequence] [smallint] NOT NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[group_no] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[product_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[price] [numeric] (20, 6) NULL,
[mode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [numeric] (20, 6) NULL,
[cost] [numeric] (20, 6) NULL,
[notes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dimension_qty_string] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[quote_detail] ADD CONSTRAINT [PK__quote_detail__0CBAE877] PRIMARY KEY CLUSTERED  ([quote_number], [sequence]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[quote_detail] ADD CONSTRAINT [FK__quote_det__quote__4E88ABD4] FOREIGN KEY ([quote_number]) REFERENCES [dbo].[quote] ([quote_number])
GO
