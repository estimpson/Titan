CREATE TABLE [dbo].[PMLIBR]
(
[LIBR] [int] NOT NULL,
[NAME] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CODE] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GOID] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VRSN] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NURI] [int] NULL,
[PRFX] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FLGS] [int] NULL,
[PRNT] [int] NULL,
[OCUS] [int] NULL,
[OCDT] [datetime] NULL,
[OMUS] [int] NULL,
[OMDT] [datetime] NULL,
[ICON] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMLIBR_PK] ON [dbo].[PMLIBR] ([LIBR]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
