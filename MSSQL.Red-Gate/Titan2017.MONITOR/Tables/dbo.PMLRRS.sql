CREATE TABLE [dbo].[PMLRRS]
(
[OBJT] [int] NOT NULL,
[RCNT] [int] NULL,
[RDAT] [datetime] NULL,
[RLAB] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [PMLRRS_PK] ON [dbo].[PMLRRS] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
