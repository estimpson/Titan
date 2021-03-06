CREATE TABLE [dbo].[PMTMP3]
(
[SESS] [int] NOT NULL,
[NUM1] [int] NULL,
[NUM2] [int] NULL,
[NUM3] [int] NULL,
[NUM4] [int] NULL,
[STR1] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STR2] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PMTMP3_SESS] ON [dbo].[PMTMP3] ([SESS], [NUM1]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PMTMP3_NUM2] ON [dbo].[PMTMP3] ([SESS], [NUM2]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PMTMP3_NUM3] ON [dbo].[PMTMP3] ([SESS], [NUM3]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
