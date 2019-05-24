CREATE TABLE [dbo].[unit_conversion]
(
[code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[unit1] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[unit2] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[conversion] [numeric] (20, 14) NOT NULL,
[sequence] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[unit_conversion] ADD CONSTRAINT [unit_conversion_x] PRIMARY KEY CLUSTERED  ([code], [unit1], [unit2]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[unit_conversion] ADD CONSTRAINT [FK__unit_conv__unit1__531856C7] FOREIGN KEY ([unit1]) REFERENCES [dbo].[unit_measure] ([unit])
GO
