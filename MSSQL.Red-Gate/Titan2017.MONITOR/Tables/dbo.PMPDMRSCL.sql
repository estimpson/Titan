CREATE TABLE [dbo].[PMPDMRSCL]
(
[OBJT] [int] NOT NULL,
[DTTP] [int] NULL,
[ISEL] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [PMPDMRSCL_PK] ON [dbo].[PMPDMRSCL] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
