CREATE TABLE [dbo].[PMPCTF]
(
[OBJT] [int] NOT NULL,
[CTNT] [int] NULL,
[PPTH] [int] NULL,
[PTID] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PTYP] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMPCTF_PK] ON [dbo].[PMPCTF] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
