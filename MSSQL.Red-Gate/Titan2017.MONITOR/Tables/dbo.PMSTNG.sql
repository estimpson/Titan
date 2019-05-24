CREATE TABLE [dbo].[PMSTNG]
(
[OBJT] [int] NOT NULL,
[FNAM] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STNG] [int] NULL,
[XTRN] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [PMSTNG_PK] ON [dbo].[PMSTNG] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
