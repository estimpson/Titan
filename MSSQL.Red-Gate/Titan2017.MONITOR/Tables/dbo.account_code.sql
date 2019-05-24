CREATE TABLE [dbo].[account_code]
(
[account_no] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account_code] ADD CONSTRAINT [PK__account_code__308E3499] PRIMARY KEY CLUSTERED  ([account_no]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
