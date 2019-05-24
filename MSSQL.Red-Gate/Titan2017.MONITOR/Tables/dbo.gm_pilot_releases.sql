CREATE TABLE [dbo].[gm_pilot_releases]
(
[customer_part] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_to_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_po] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[model_year] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[release_no] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [numeric] (20, 6) NULL,
[release_date] [datetime] NULL,
[forecast_type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
