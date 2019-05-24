CREATE TABLE [dbo].[part_customer_tbp]
(
[customer] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[effect_date] [datetime] NOT NULL,
[price] [numeric] (20, 6) NULL CONSTRAINT [DF__part_cust__price__161A357F] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_customer_tbp] ADD CONSTRAINT [PK__part_customer_tb__15261146] PRIMARY KEY CLUSTERED  ([customer], [part], [effect_date]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
