CREATE TABLE [dbo].[PMPDMVIWC]
(
[OBJT] [int] NOT NULL,
[CCMT] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CCOD] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CDTP] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CNAM] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRUL] [int] NULL,
[DISP] [int] NULL,
[DTTP] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DVAL] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FRMT] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVAL] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOWR] [int] NULL,
[LVAL] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MLEN] [int] NULL,
[NMDF] [int] NULL,
[PREC] [int] NULL,
[SRUL] [int] NULL,
[UNIT] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPPR] [int] NULL,
[VALS] [int] NULL,
[CCOM] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMPDMVIWC_PK] ON [dbo].[PMPDMVIWC] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
