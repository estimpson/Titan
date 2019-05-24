CREATE TABLE [dbo].[destination_package]
(
[destination] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[package] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[customer_box_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cum] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[destination_package] ADD CONSTRAINT [PK__destination_pack__02FC7413] PRIMARY KEY CLUSTERED  ([destination], [package]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[destination_package] ADD CONSTRAINT [FK__destinati__desti__56E8E7AB] FOREIGN KEY ([destination]) REFERENCES [dbo].[destination] ([destination])
GO
ALTER TABLE [dbo].[destination_package] ADD CONSTRAINT [FK__destinati__packa__57DD0BE4] FOREIGN KEY ([package]) REFERENCES [dbo].[package_materials] ([code])
GO
ALTER TABLE [dbo].[destination_package] ADD CONSTRAINT [fk_destination_package_destination] FOREIGN KEY ([destination]) REFERENCES [dbo].[destination] ([destination])
GO
