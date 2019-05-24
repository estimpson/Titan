CREATE TABLE [dbo].[edi_830_AuTH2]
(
[release_no] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[supplier] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_to] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_part] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ecl] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_po] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[auth_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[auth_date1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[auth_qty1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[auth_qty2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[auth_date2] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
