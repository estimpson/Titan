CREATE TABLE [dbo].[PMOOMMSSG]
(
[OBJT] [int] NOT NULL,
[ACTN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BTIM] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COND] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DLAY] [int] NULL,
[ETIM] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MTYP] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OARG] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORVL] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRED] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEQN] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMOOMMSSG_PK] ON [dbo].[PMOOMMSSG] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
