CREATE TABLE [dbo].[mold]
(
[mold_number] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cavities] [numeric] (10, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mold] ADD CONSTRAINT [PK__mold__145C0A3F] PRIMARY KEY CLUSTERED  ([mold_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
