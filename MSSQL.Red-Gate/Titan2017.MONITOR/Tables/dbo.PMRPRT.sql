CREATE TABLE [dbo].[PMRPRT]
(
[OBJT] [int] NOT NULL,
[AVSN] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CSSF] [int] NULL,
[FPAU] [int] NULL,
[FPDT] [int] NULL,
[FPTT] [int] NULL,
[FPVS] [int] NULL,
[FTRF] [int] NULL,
[FTRS] [int] NULL,
[HDRF] [int] NULL,
[HDRS] [int] NULL,
[HFAU] [int] NULL,
[HFDT] [int] NULL,
[HFPG] [int] NULL,
[HFSM] [int] NULL,
[HFTT] [int] NULL,
[HFVS] [int] NULL,
[HIFM] [int] NULL,
[HTDP] [int] NULL,
[RPSM] [int] NULL,
[SNUM] [int] NULL,
[GEPT] [int] NULL,
[HLPN] [int] NULL,
[HLRN] [int] NULL,
[HOMF] [int] NULL,
[HPBK] [int] NULL,
[HTCW] [int] NULL,
[HTMP] [int] NULL,
[RTMP] [int] NULL,
[SEPT] [int] NULL,
[USHF] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMRPRT_PK] ON [dbo].[PMRPRT] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
