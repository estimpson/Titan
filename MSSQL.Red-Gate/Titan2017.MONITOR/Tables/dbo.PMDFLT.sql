CREATE TABLE [dbo].[PMDFLT]
(
[OBJT] [int] NOT NULL,
[VALE] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMDFLT_PK] ON [dbo].[PMDFLT] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
