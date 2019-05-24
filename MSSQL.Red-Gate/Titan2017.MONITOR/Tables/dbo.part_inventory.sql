CREATE TABLE [dbo].[part_inventory]
(
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[standard_pack] [numeric] (20, 6) NULL,
[unit_weight] [numeric] (20, 6) NULL,
[standard_unit] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cycle] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[abc] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[saftey_stock_qty] [numeric] (20, 6) NULL,
[primary_location] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location_group] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipa] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[label_format] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shelf_life_days] [numeric] (3, 0) NULL,
[material_issue_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[safety_part] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upc_code] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dim_code] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[configurable] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[next_suffix] [int] NULL,
[drop_ship_part] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_inventory] ADD CONSTRAINT [PK_part_inventory] PRIMARY KEY CLUSTERED  ([part]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_inventory] ADD CONSTRAINT [fk_part_inventory1] FOREIGN KEY ([part]) REFERENCES [dbo].[part] ([part])
GO
