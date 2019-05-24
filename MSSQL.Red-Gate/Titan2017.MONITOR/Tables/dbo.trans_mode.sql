CREATE TABLE [dbo].[trans_mode]
(
[code] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trans_mode] ADD CONSTRAINT [PK__trans_mode__78B3EFCA] PRIMARY KEY CLUSTERED  ([code]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
