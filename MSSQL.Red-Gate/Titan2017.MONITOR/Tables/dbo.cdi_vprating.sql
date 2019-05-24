CREATE TABLE [dbo].[cdi_vprating]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[lrange] [int] NULL,
[hrange] [int] NULL,
[rating] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdi_vprating] ADD CONSTRAINT [PK__cdi_vprating__33AA9866] PRIMARY KEY CLUSTERED  ([id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
