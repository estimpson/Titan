CREATE TABLE [dbo].[unit_sub]
(
[unit_group] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sequence] [numeric] (3, 0) NOT NULL,
[sub_unit] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[name_1] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[name_2] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[short_name] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[symbol] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[factor] [numeric] (6, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[unit_sub] ADD CONSTRAINT [PK__unit_sub__03C67B1A] PRIMARY KEY CLUSTERED  ([unit_group], [sequence]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
