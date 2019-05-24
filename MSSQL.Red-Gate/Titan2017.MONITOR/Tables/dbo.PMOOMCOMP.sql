CREATE TABLE [dbo].[PMOOMCOMP]
(
[OBJT] [int] NOT NULL,
[CTYP] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRSP] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WCMT] [int] NULL,
[WNPX] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WNSP] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WSRV] [int] NULL,
[WSSS] [int] NULL,
[WSTY] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WTNS] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WTXT] [int] NULL,
[WTYP] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WURL] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WXTN] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMOOMCOMP_PK] ON [dbo].[PMOOMCOMP] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
