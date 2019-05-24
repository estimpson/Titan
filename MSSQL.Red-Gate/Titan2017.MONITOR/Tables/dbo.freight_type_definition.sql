CREATE TABLE [dbo].[freight_type_definition]
(
[type_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[freight_type_definition] ADD CONSTRAINT [PK__freight_type_def__6FB49575] PRIMARY KEY CLUSTERED  ([type_name]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
