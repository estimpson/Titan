CREATE TABLE [dbo].[PMPRJACTN]
(
[OBJT] [int] NOT NULL,
[AMKD] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ATYP] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DFNM] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DKND] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTYP] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOST] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAND] [int] NULL,
[MTPL] [int] NULL,
[MULT] [int] NULL,
[OKND] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OMKD] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCPT] [int] NULL,
[TLGE] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[XEMS] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [PMPRJACTN_PK] ON [dbo].[PMPRJACTN] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
