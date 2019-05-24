CREATE TABLE [dbo].[company]
(
[id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[name] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_3] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company] ADD CONSTRAINT [PK__company__36B12243] PRIMARY KEY CLUSTERED  ([id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
