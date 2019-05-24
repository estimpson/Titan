CREATE TABLE [dbo].[m_gmc_862_line_feed_kanban]
(
[schedule_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[release_number] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_to_type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_to] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_part] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dock_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[line_feed] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[beg_kanban] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[end_kanban] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
