CREATE TABLE [dbo].[issues_sub_category]
(
[category] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sub_category] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[default_value] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[issues_sub_category] ADD CONSTRAINT [PK__issues_sub_categ__42E1EEFE] PRIMARY KEY CLUSTERED  ([category], [sub_category]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[issues_sub_category] ADD CONSTRAINT [FK__issues_su__categ__373B3228] FOREIGN KEY ([category]) REFERENCES [dbo].[issues_category] ([category])
GO
ALTER TABLE [dbo].[issues_sub_category] ADD CONSTRAINT [fk_issues_category_sub_category] FOREIGN KEY ([category]) REFERENCES [dbo].[issues_category] ([category])
GO
