CREATE TABLE [dbo].[effective_change_notice]
(
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[effective_date] [datetime] NOT NULL,
[operator] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[notes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[engineering_level] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[effective_change_notice] ADD CONSTRAINT [PK__effective_change__55FFB06A] PRIMARY KEY CLUSTERED  ([part], [effective_date]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
