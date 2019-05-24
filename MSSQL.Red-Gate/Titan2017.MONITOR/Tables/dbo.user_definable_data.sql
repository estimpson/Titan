CREATE TABLE [dbo].[user_definable_data]
(
[module] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sequence] [int] NOT NULL,
[code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[user_definable_data] ADD CONSTRAINT [PK__user_definable_d__787EE5A0] PRIMARY KEY CLUSTERED  ([module], [sequence], [code]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
