CREATE TABLE [dbo].[xreport_library]
(
[name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[report] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[datasource] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[xlabelformat] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[xreport_library] ADD CONSTRAINT [PK__xreport_library__55009F39] PRIMARY KEY CLUSTERED  ([name], [report]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
