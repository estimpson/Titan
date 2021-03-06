CREATE TABLE [dbo].[po_detail_history]
(
[po_number] [int] NOT NULL,
[vendor_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[part_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit_of_measure] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_due] [datetime] NOT NULL,
[requisition_number] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_recvd_date] [datetime] NULL,
[last_recvd_amount] [numeric] (20, 6) NULL,
[cross_reference_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [numeric] (20, 6) NULL,
[received] [numeric] (20, 6) NULL,
[balance] [numeric] (20, 6) NULL,
[active_release_cum] [numeric] (20, 6) NULL,
[received_cum] [numeric] (20, 6) NULL,
[price] [numeric] (20, 6) NULL,
[row_id] [numeric] (20, 0) NOT NULL,
[invoice_status] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_date] [datetime] NULL,
[invoice_qty] [numeric] (20, 6) NULL,
[invoice_unit_price] [numeric] (20, 6) NULL,
[release_no] [int] NULL,
[ship_to_destination] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[terms] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[week_no] [int] NULL,
[plant] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_number] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[standard_qty] [numeric] (20, 6) NULL,
[sales_order] [int] NULL,
[dropship_oe_row_id] [int] NULL,
[ship_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dropship_shipper] [int] NULL,
[price_unit] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[printed] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[selected_for_print] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deleted] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_via] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[release_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dimension_qty_string] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[taxable] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job_cost_no] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[requisition_id] [int] NULL,
[posted] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alternate_price] [numeric] (20, 6) NULL,
[promise_date] [datetime] NULL,
[other_charge] [numeric] (20, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[po_detail_history] ADD CONSTRAINT [PK_po_detail_history] PRIMARY KEY CLUSTERED  ([po_number], [part_number], [date_due], [row_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[po_detail_history] ADD CONSTRAINT [FK__po_detail__po_nu__222B06A9] FOREIGN KEY ([po_number]) REFERENCES [dbo].[po_header] ([po_number])
GO
ALTER TABLE [dbo].[po_detail_history] ADD CONSTRAINT [FK__po_detail__po_nu__3DD3211E] FOREIGN KEY ([po_number]) REFERENCES [dbo].[po_header] ([po_number])
GO
