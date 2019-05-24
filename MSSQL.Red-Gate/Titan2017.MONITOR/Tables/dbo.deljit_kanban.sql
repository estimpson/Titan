CREATE TABLE [dbo].[deljit_kanban]
(
[release_number] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_to_id] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[supplier] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buyer_part] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[model_year] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[kanban_line] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[line_id] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[begin_kanban] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[end_kanban] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
