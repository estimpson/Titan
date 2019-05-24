CREATE TABLE [dbo].[requisition_group]
(
[group_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[requisition_group] ADD CONSTRAINT [PK__requisition_grou__32767D0B] PRIMARY KEY CLUSTERED  ([group_code]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
