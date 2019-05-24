CREATE TABLE [dbo].[plant_part]
(
[plant] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[min_onhand] [numeric] (20, 6) NULL,
[min_onorder] [numeric] (20, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[plant_part] ADD CONSTRAINT [PK__plant_part__76969D2E] PRIMARY KEY CLUSTERED  ([plant], [part]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
