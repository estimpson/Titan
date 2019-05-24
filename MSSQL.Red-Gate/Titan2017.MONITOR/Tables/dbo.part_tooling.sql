CREATE TABLE [dbo].[part_tooling]
(
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tool_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[qty_part_per_tool] [numeric] (20, 6) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_tooling] ADD CONSTRAINT [PK__part_tooling__70B3A6A6] PRIMARY KEY CLUSTERED  ([part], [tool_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
