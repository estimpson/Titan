CREATE TABLE [dbo].[part_characteristics]
(
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[unit_weight] [numeric] (20, 6) NULL,
[length_x] [numeric] (20, 6) NULL,
[height_y] [numeric] (20, 6) NULL,
[width_z] [numeric] (20, 6) NULL,
[color] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hazardous] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[part_size] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_defined_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[returnable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_characteristics] ADD CONSTRAINT [PK__part_characteris__30F848ED] PRIMARY KEY CLUSTERED  ([part]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_characteristics] WITH NOCHECK ADD CONSTRAINT [fk_part_characteristics_part] FOREIGN KEY ([part]) REFERENCES [dbo].[part] ([part])
GO
ALTER TABLE [dbo].[part_characteristics] ADD CONSTRAINT [fk_part_characteristics1] FOREIGN KEY ([part]) REFERENCES [dbo].[part] ([part])
GO
