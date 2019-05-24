CREATE TABLE [dbo].[PMDIAG]
(
[OBJT] [int] NOT NULL,
[DFLG] [int] NULL,
[DPRF] [int] NULL,
[MTYP] [int] NULL,
[PGMG] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PGOR] [int] NULL,
[PGSC] [int] NULL,
[PGSZ] [int] NULL,
[PPSC] [int] NULL,
[PPSZ] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SDGM] [int] NULL,
[CPRF] [int] NULL,
[CSIZ] [int] NULL,
[FOOT] [int] NULL,
[HEAD] [int] NULL,
[LTYP] [int] NULL,
[NMBR] [int] NULL,
[RHSZ] [int] NULL,
[RPRF] [int] NULL,
[SERW] [int] NULL,
[SFRC] [int] NULL,
[UDPS] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMDIAG_PK] ON [dbo].[PMDIAG] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
