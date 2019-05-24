CREATE TABLE [dbo].[alternative_parts]
(
[main_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[alt_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[alternative_parts] ADD CONSTRAINT [PK__alternative_part__0F624AF8] PRIMARY KEY CLUSTERED  ([main_part], [alt_part]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
