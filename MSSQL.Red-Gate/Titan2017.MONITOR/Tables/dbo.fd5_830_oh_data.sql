CREATE TABLE [dbo].[fd5_830_oh_data]
(
[ship_to] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buyer] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_to] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consignee] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ford_part] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ford_po] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ecl] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[euro_fin_code] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[issue_date] [datetime] NULL,
[effective_date] [datetime] NULL,
[customer_order_no] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[part_status] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expeditor] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exp_phone] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plant_dock] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plant_dock_phone] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[note] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
