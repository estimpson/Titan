CREATE TABLE [dbo].[issues_status]
(
[status] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[default_value] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[issues_status] ADD CONSTRAINT [PK__issues_status__3F115E1A] PRIMARY KEY CLUSTERED  ([status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
