CREATE TABLE [dbo].[PMFLDR]
(
[OBJT] [int] NOT NULL,
[XNAM] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDR] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[APLY] [int] NULL,
[ATFM] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTH] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AVSN] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BLCD] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ELFM] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FNLD] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FOPT] [int] NULL,
[LANG] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MOPT] [int] NULL,
[MULT] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NMSP] [int] NULL,
[NSPS] [int] NULL,
[PCTI] [int] NULL,
[PREG] [int] NULL,
[PSTG] [int] NULL,
[TNSP] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VERS] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[XSID] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADAT] [datetime] NULL,
[PFIX] [int] NULL,
[PTYP] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TPLT] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMFLDR_PK] ON [dbo].[PMFLDR] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
