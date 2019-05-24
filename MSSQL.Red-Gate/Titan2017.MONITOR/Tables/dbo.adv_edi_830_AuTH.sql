CREATE TABLE [dbo].[adv_edi_830_AuTH]
(
[release_no] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_to] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_part] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ecl] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_po] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[raw_auth] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[raw_start_date] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[raw_end_date] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fab_auth] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fab_start_date] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fab_end_date] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
