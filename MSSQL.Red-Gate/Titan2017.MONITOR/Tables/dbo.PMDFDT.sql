CREATE TABLE [dbo].[PMDFDT]
(
[OBJT] [int] NOT NULL,
[ACTP] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTSR] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LGIN] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MTYP] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSWD] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [PMDFDT_PK] ON [dbo].[PMDFDT] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
