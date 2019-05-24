CREATE TABLE [dbo].[limit_parts]
(
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[limit_parts] ADD CONSTRAINT [PK__limit_parts__0A9D95DB] PRIMARY KEY CLUSTERED  ([part]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
