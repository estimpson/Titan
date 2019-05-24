CREATE TABLE [dbo].[unit_measure]
(
[unit] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[unit_measure] ADD CONSTRAINT [PK__unit_measure__1DE57479] PRIMARY KEY CLUSTERED  ([unit]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
