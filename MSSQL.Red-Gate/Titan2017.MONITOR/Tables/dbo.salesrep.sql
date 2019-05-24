CREATE TABLE [dbo].[salesrep]
(
[salesrep] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[commission_rate] [numeric] (7, 4) NOT NULL,
[commission_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[salesrep] ADD CONSTRAINT [salesrep_x] PRIMARY KEY CLUSTERED  ([salesrep]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
