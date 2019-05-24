CREATE TABLE [dbo].[user_definable_module_labels]
(
[module] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sequence] [int] NOT NULL,
[label] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[calculated_field] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[user_definable_module_labels] ADD CONSTRAINT [user_definable_module_labels_x] PRIMARY KEY CLUSTERED  ([module], [sequence]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
