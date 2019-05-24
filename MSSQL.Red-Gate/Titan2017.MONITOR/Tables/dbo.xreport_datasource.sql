CREATE TABLE [dbo].[xreport_datasource]
(
[datasource_name] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[library_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[xreport_datasource] ADD CONSTRAINT [PK__xreport_datasour__531856C7] PRIMARY KEY CLUSTERED  ([datasource_name]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
