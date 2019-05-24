CREATE TABLE [dbo].[PMILMXDOC]
(
[OBJT] [int] NOT NULL,
[PTYP] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[XMLF] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[XSDF] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [PMILMXDOC_PK] ON [dbo].[PMILMXDOC] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
