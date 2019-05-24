CREATE TABLE [dbo].[delfor_releases]
(
[process_date] [datetime] NULL CONSTRAINT [DF__delfor_re__proce__5F7E2DAC] DEFAULT (getdate()),
[release_number] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_to_id] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buyer_part] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type1] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_po] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[model_year] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[forecast_type] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[start_date] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_mgo] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
