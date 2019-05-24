CREATE TABLE [dbo].[interface_utilities]
(
[transaction_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sequence] [int] NOT NULL,
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[parameters] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[interface_utilities] ADD CONSTRAINT [PK__interface_utilit__0C85DE4D] PRIMARY KEY CLUSTERED  ([transaction_type], [sequence]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
