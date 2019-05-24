CREATE TABLE [dbo].[package_materials_copy]
(
[code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[returnable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[weight] [numeric] (12, 6) NOT NULL,
[stackable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[package_materials_copy] ADD CONSTRAINT [PK__package_material__50FB042B] PRIMARY KEY CLUSTERED  ([code]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
