CREATE TABLE [dbo].[PMBPMDCSN]
(
[OBJT] [int] NOT NULL,
[EXPA] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXPR] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMBPMDCSN_PK] ON [dbo].[PMBPMDCSN] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
