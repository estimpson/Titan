CREATE TABLE [dbo].[DiscretePONumbersShipped]
(
[OrderNo] [int] NULL,
[ShipDate] [datetime] NULL,
[Qty] [numeric] (20, 6) NULL,
[DiscretePONumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipper] [int] NULL
) ON [PRIMARY]
GO
