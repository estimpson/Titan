CREATE TABLE [dbo].[m_gmc_830_releases]
(
[release_number] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_to_type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_to] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_part] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[qty] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[identifier] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_date] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
