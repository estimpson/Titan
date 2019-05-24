CREATE TABLE [dbo].[temp_pops]
(
[name] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[area] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[temp_pops] ADD CONSTRAINT [PK__temp_pops__6C190EBB] PRIMARY KEY CLUSTERED  ([name], [number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
