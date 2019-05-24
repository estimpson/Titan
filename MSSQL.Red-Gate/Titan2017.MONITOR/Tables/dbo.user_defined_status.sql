CREATE TABLE [dbo].[user_defined_status]
(
[display_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[base] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[user_defined_status] ADD CONSTRAINT [PK__user_defined_sta__04E4BC85] PRIMARY KEY CLUSTERED  ([display_name]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
