CREATE TABLE [dbo].[part_machine_tool_list]
(
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[machine] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[station_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[station_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tool] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tool_qty] [int] NOT NULL,
[parts_per_tool] [int] NOT NULL,
[tool_list_no] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_machine_tool_list] ADD CONSTRAINT [PK__part_machine_too__729BEF18] PRIMARY KEY CLUSTERED  ([part], [machine], [station_id], [tool]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
