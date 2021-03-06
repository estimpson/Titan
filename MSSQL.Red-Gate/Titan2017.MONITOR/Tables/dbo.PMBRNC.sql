CREATE TABLE [dbo].[PMBRNC]
(
[BRNC] [int] NOT NULL,
[NAME] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CODE] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CMMT] [int] NULL,
[BBRC] [int] NULL,
[OCUS] [int] NOT NULL,
[OCDT] [datetime] NULL,
[OMUS] [int] NULL,
[OMDT] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PMBRNC_BBRC] ON [dbo].[PMBRNC] ([BBRC]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMBRNC_PK] ON [dbo].[PMBRNC] ([BRNC]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMBRNC_CODE] ON [dbo].[PMBRNC] ([CODE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
