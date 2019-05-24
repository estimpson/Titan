CREATE TABLE [dbo].[customer_service_status]
(
[status_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[default_value] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[customer_service_status] ADD CONSTRAINT [PK__customer_service__498EEC8D] PRIMARY KEY CLUSTERED  ([status_name]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
