CREATE TABLE [dbo].[PMPDMVIEW]
(
[OBJT] [int] NOT NULL,
[DTYP] [int] NULL,
[FOOT] [int] NULL,
[GENE] [int] NULL,
[HEAD] [int] NULL,
[OPTS] [int] NULL,
[OTYP] [int] NULL,
[TSQL] [int] NULL,
[USAG] [int] NULL,
[USQL] [int] NULL,
[VSQL] [int] NULL,
[TTYP] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[XELT] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[XSCH] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMPDMVIEW_PK] ON [dbo].[PMPDMVIEW] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
