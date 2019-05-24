CREATE TABLE [dbo].[gt_bom_info]
(
[parent_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [numeric] (20, 6) NULL,
[extended_quantity] [numeric] (20, 6) NULL,
[machine] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[process_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[setup_time] [numeric] (20, 6) NULL,
[class] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[due_datetime] [datetime] NULL,
[dropdead_datetime] [datetime] NULL,
[runtime] [numeric] (20, 6) NULL,
[group_technology] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[week_no] [int] NULL,
[new_row_id] [int] NULL,
[bom_level] [int] NULL
) ON [PRIMARY]
GO
