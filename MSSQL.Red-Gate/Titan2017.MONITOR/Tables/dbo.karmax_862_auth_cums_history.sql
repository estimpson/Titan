CREATE TABLE [dbo].[karmax_862_auth_cums_history]
(
[release_no] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_number_bfr] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[supplier_id] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_to] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_part] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ecl] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_po_lin] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[raw_auth] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[raw_auth_start_dt] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[raw_auth_end_date] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fab_auth] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fab_auth_start_dt] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fab_auth_end_date] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prior_cum] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prior_cum_start_dt] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prior_cum_end_date] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_to_id_2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
