CREATE TABLE [dbo].[report_list]
(
[report] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[report_list] ADD CONSTRAINT [PK__report_list__7948ECA7] PRIMARY KEY CLUSTERED  ([report]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
