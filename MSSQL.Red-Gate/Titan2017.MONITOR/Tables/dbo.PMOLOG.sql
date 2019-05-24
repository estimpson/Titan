CREATE TABLE [dbo].[PMOLOG]
(
[OBJT] [int] NOT NULL,
[OTYP] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OUSR] [int] NOT NULL,
[ODAT] [datetime] NOT NULL,
[NAME] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CODE] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VRSN] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LCTN] [int] NULL,
[OCMT] [int] NULL,
[BRNC] [int] NULL,
[CLSS] [int] NULL,
[POID] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMOLOG_PK] ON [dbo].[PMOLOG] ([OBJT], [OTYP], [ODAT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
