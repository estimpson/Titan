CREATE TABLE [dbo].[PMXSMCMPT]
(
[OBJT] [int] NOT NULL,
[ABST] [int] NULL,
[ATFM] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUSE] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BLCK] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BTPN] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DFVL] [int] NULL,
[ELFM] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FINL] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FIXD] [int] NULL,
[FXVL] [int] NULL,
[GTYP] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ITPN] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBTN] [int] NULL,
[MIXD] [int] NULL,
[MNOC] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MXOC] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NILL] [int] NULL,
[NMSP] [int] NULL,
[PCNT] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PUBL] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RFNM] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUBN] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SYST] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TPNM] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VALE] [int] NULL,
[VALS] [int] NULL,
[XPTH] [int] NULL,
[XSID] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMXSMCMPT_PK] ON [dbo].[PMXSMCMPT] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
