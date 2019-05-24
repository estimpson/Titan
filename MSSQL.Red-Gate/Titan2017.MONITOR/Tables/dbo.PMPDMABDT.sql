CREATE TABLE [dbo].[PMPDMABDT]
(
[OBJT] [int] NOT NULL,
[ABST] [int] NULL,
[DTTP] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FINL] [int] NULL,
[JVDT] [int] NULL,
[JVNM] [int] NULL,
[MLEN] [int] NULL,
[OFIL] [int] NULL,
[OSIZ] [int] NULL,
[OTYP] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PREC] [int] NULL,
[PRIV] [int] NULL,
[CNAM] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAND] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMPDMABDT_PK] ON [dbo].[PMPDMABDT] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
