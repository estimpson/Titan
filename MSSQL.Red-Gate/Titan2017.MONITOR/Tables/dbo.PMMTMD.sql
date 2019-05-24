CREATE TABLE [dbo].[PMMTMD]
(
[MTMD] [int] NOT NULL,
[NAME] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CODE] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MAID] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FLGS] [int] NULL,
[ICON] [int] NOT NULL,
[MAVN] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXTN] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OCUS] [int] NULL,
[OCDT] [datetime] NULL,
[OMUS] [int] NULL,
[OMDT] [datetime] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMMTMD_PK] ON [dbo].[PMMTMD] ([MTMD]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
