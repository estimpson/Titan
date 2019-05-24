CREATE TABLE [dbo].[PMOOMMTHD]
(
[OBJT] [int] NOT NULL,
[ABST] [int] NULL,
[ARAY] [int] NULL,
[ATMT] [int] NULL,
[BDYT] [int] NULL,
[DISP] [int] NULL,
[EVNT] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FINL] [int] NULL,
[PRCN] [int] NULL,
[PSCN] [int] NULL,
[QURY] [int] NULL,
[RNLY] [int] NULL,
[RTTP] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SPEC] [int] NULL,
[STTC] [int] NULL,
[THRW] [int] NULL,
[VISI] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WDTP] [int] NULL,
[WMTD] [int] NULL,
[WSFS] [int] NULL,
[WSIM] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WSIS] [int] NULL,
[WSOM] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WSOS] [int] NULL,
[WSSF] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMOOMMTHD_PK] ON [dbo].[PMOOMMTHD] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
