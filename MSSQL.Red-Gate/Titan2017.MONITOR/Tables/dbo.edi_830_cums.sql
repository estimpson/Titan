CREATE TABLE [dbo].[edi_830_cums]
(
[customer_part] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[destination] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_po] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_cum] [numeric] (20, 6) NULL,
[our_cum] [numeric] (20, 6) NULL
) ON [PRIMARY]
GO
