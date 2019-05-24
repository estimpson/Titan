CREATE TABLE [dbo].[category]
(
[code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[markup] [numeric] (20, 6) NULL,
[multiplier] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[premium] [numeric] (20, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[category] ADD CONSTRAINT [PK__category__08B54D69] PRIMARY KEY CLUSTERED  ([code]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
