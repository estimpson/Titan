CREATE TABLE [dbo].[PMRQMRQMT]
(
[OBJT] [int] NOT NULL,
[FOPT] [int] NULL,
[NMSP] [int] NULL,
[PRTY] [float] NULL,
[RISK] [int] NULL,
[RTYP] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SELD] [int] NULL,
[STTS] [int] NULL,
[UCOD] [int] NULL,
[VRFM] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WKD2] [float] NULL,
[WKD3] [float] NULL,
[WKD4] [float] NULL,
[WKLD] [float] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [PMRQMRQMT_PK] ON [dbo].[PMRQMRQMT] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
