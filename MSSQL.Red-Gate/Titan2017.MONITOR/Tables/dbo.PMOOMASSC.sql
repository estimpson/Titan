CREATE TABLE [dbo].[PMOOMASSC]
(
[OBJT] [int] NOT NULL,
[FRZA] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FRZB] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INDA] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INDB] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INIA] [int] NULL,
[INIB] [int] NULL,
[MULA] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MULB] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NAVA] [int] NULL,
[NAVB] [int] NULL,
[ORDA] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDB] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRSA] [int] NULL,
[PRSB] [int] NULL,
[ROLA] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ROLB] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VISA] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VISB] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VLTA] [int] NULL,
[VLTB] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMOOMASSC_PK] ON [dbo].[PMOOMASSC] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
