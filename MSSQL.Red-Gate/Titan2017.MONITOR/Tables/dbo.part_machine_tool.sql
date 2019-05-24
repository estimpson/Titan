CREATE TABLE [dbo].[part_machine_tool]
(
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[machine] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tool] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[quantity] [numeric] (20, 6) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_machine_tool] ADD CONSTRAINT [PK__part_machine_too__6ECB5E34] PRIMARY KEY CLUSTERED  ([part], [machine], [tool]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
