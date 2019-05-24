CREATE TABLE [dbo].[department]
(
[code] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[department] ADD CONSTRAINT [PK__department__5AEE82B9] PRIMARY KEY CLUSTERED  ([code]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
