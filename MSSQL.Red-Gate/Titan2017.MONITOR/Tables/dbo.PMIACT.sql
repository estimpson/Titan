CREATE TABLE [dbo].[PMIACT]
(
[OBJT] [int] NOT NULL,
[DISP] [int] NULL,
[IIMP] [int] NULL,
[PEVT] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PNAM] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RECS] [int] NULL,
[SKLK] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [PMIACT_PK] ON [dbo].[PMIACT] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
