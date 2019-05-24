CREATE TABLE [dbo].[part_type_definition]
(
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_flag] [binary] (8) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_type_definition] ADD CONSTRAINT [PK__part_type_defini__7484378A] PRIMARY KEY CLUSTERED  ([type]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
