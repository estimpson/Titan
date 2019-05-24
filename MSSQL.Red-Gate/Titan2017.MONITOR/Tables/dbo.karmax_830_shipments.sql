CREATE TABLE [dbo].[karmax_830_shipments]
(
[release_no] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_number_bfr] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[supplier_id] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_to] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_part] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ecl] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_po_lin] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_to_id_2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_qty_shipped] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipped_date] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipper_id_ship] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[received_date] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_qty_received] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipper_id_rec] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cytd] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cytd_start_dt] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cytd_end_date] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
