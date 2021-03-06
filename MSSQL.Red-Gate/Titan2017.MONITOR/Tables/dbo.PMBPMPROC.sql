CREATE TABLE [dbo].[PMBPMPROC]
(
[OBJT] [int] NOT NULL,
[ACTN] [int] NULL,
[ACTP] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMM] [int] NULL,
[DRTN] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FOPT] [int] NULL,
[ITYP] [int] NULL,
[LTYP] [int] NULL,
[LXPR] [int] NULL,
[NMSP] [int] NULL,
[REUS] [int] NULL,
[TMOT] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMBPMPROC_PK] ON [dbo].[PMBPMPROC] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
