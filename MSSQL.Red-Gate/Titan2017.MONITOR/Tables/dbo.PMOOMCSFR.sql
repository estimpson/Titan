CREATE TABLE [dbo].[PMOOMCSFR]
(
[OBJT] [int] NOT NULL,
[ABST] [int] NULL,
[CTYP] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXTS] [int] NULL,
[FINL] [int] NULL,
[FOOT] [int] NULL,
[GENE] [int] NULL,
[HEAD] [int] NULL,
[IMPT] [int] NULL,
[MULT] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PADT] [int] NULL,
[PCOD] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERS] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRCN] [int] NULL,
[PSCN] [int] NULL,
[STEP] [int] NULL,
[THRW] [int] NULL,
[VISI] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMOOMCSFR_PK] ON [dbo].[PMOOMCSFR] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
