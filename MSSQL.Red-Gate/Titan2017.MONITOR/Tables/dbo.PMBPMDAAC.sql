CREATE TABLE [dbo].[PMBPMDAAC]
(
[OBJT] [int] NOT NULL,
[CRAC] [int] NULL,
[DLAC] [int] NULL,
[RDAC] [int] NULL,
[UPAC] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMBPMDAAC_PK] ON [dbo].[PMBPMDAAC] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
