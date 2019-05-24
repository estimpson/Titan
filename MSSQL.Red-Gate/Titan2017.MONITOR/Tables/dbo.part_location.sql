CREATE TABLE [dbo].[part_location]
(
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[location] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[days_onhand] [numeric] (20, 6) NULL,
[maximum] [numeric] (20, 6) NULL,
[minimum] [numeric] (20, 6) NULL,
[reorder_qty] [numeric] (20, 6) NULL,
[destination] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_location] ADD CONSTRAINT [PK__part_location__6CE315C2] PRIMARY KEY CLUSTERED  ([part], [location]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
