CREATE TABLE [dbo].[PMPDMMEAS]
(
[OBJT] [int] NOT NULL,
[FRML] [int] NULL,
[IFRM] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMPDMMEAS_PK] ON [dbo].[PMPDMMEAS] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
