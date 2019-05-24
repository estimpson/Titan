CREATE TABLE [dbo].[PMAMAP]
(
[OBJT] [int] NOT NULL,
[CRTR] [int] NULL,
[DELA] [int] NULL,
[DELB] [int] NULL,
[INSA] [int] NULL,
[INSB] [int] NULL,
[SELA] [int] NULL,
[SELB] [int] NULL,
[DELT] [int] NULL,
[EXPR] [int] NULL,
[INSR] [int] NULL,
[REVB] [int] NULL,
[SLCT] [int] NULL,
[UPDT] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMAMAP_PK] ON [dbo].[PMAMAP] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
