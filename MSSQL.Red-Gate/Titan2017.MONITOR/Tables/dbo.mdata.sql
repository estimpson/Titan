CREATE TABLE [dbo].[mdata]
(
[pmcode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mcode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[switch] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__mdata__switch__377B294A] DEFAULT ('N'),
[display] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__mdata__display__386F4D83] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mdata] ADD CONSTRAINT [PK__mdata__36870511] PRIMARY KEY CLUSTERED  ([mcode]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
