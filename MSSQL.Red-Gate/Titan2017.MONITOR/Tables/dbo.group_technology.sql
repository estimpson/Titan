CREATE TABLE [dbo].[group_technology]
(
[id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[notes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[source_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[group_technology] ADD CONSTRAINT [PK__group_technology__534D60F1] PRIMARY KEY CLUSTERED  ([id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
