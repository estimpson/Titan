CREATE TABLE [dbo].[PMATTR]
(
[ATTR] [int] NOT NULL,
[CLSS] [int] NOT NULL,
[DSID] [int] NOT NULL,
[NAME] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CODE] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CTYP] [int] NOT NULL,
[FLGS] [int] NOT NULL,
[TNAM] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CNAM] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPRC] [int] NULL,
[ATYP] [int] NULL,
[LBND] [int] NULL,
[UBND] [int] NULL,
[ENUM] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMATTR_PK] ON [dbo].[PMATTR] ([ATTR]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
