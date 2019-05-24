CREATE TABLE [dbo].[part_unit_conversion]
(
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_unit_conversion] ADD CONSTRAINT [PK__part_unit_conver__2B3F6F97] PRIMARY KEY CLUSTERED  ([part], [code]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_unit_conversion] WITH NOCHECK ADD CONSTRAINT [fk_part_unit_conversion_part] FOREIGN KEY ([part]) REFERENCES [dbo].[part] ([part])
GO
ALTER TABLE [dbo].[part_unit_conversion] ADD CONSTRAINT [fk_part_unit_conversion1] FOREIGN KEY ([part]) REFERENCES [dbo].[part] ([part])
GO
