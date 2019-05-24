CREATE TABLE [dbo].[machine_process]
(
[machine] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[process] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[machine_process] ADD CONSTRAINT [PK__machine_process__571DF1D5] PRIMARY KEY CLUSTERED  ([machine], [process]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
