CREATE TABLE [dbo].[textron_order_auth]
(
[release_no] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_to] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_part] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[monitor_order_no] [int] NULL,
[monitor_last_shipper] [int] NULL,
[customer_last_shipper] [int] NULL,
[monitor_last_ship_qty] [numeric] (20, 6) NULL,
[cust_last_rec_qty] [numeric] (20, 6) NULL,
[cust_last_rec_date] [datetime] NULL,
[customer_stated_cum] [numeric] (20, 6) NULL,
[monitor_cum] [numeric] (20, 6) NULL,
[customer_auth_cum] [numeric] (20, 6) NULL,
[supplier] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
