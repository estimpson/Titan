CREATE TABLE [dbo].[part_class_definition]
(
[class] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[class_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_flag] [binary] (8) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_class_definition] ADD CONSTRAINT [PK__part_class_defin__691284DE] PRIMARY KEY CLUSTERED  ([class]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
