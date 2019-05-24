CREATE TABLE [dbo].[part_class_type_cross_ref]
(
[class] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_class_type_cross_ref] ADD CONSTRAINT [PK__part_class_type___0D4FE554] PRIMARY KEY CLUSTERED  ([class], [type]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_class_type_cross_ref] ADD CONSTRAINT [FK__part_clas__class__0E44098D] FOREIGN KEY ([class]) REFERENCES [dbo].[part_class_definition] ([class])
GO
ALTER TABLE [dbo].[part_class_type_cross_ref] ADD CONSTRAINT [FK__part_class__type__0F382DC6] FOREIGN KEY ([type]) REFERENCES [dbo].[part_type_definition] ([type])
GO
