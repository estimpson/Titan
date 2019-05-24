CREATE TABLE [dbo].[PMPDMTABL]
(
[OBJT] [int] NOT NULL,
[CKCN] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRUL] [int] NULL,
[DTYP] [int] NULL,
[FOOT] [int] NULL,
[GENE] [int] NULL,
[HEAD] [int] NULL,
[NBRC] [float] NULL,
[OPTS] [int] NULL,
[SRUL] [int] NULL,
[TSTD] [int] NULL,
[TTYP] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[XELT] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[XSCH] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMPDMTABL_PK] ON [dbo].[PMPDMTABL] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
