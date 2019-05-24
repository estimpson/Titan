CREATE TABLE [dbo].[company_info]
(
[name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[phone] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_info] ADD CONSTRAINT [PK__company_info__25869641] PRIMARY KEY CLUSTERED  ([name]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
