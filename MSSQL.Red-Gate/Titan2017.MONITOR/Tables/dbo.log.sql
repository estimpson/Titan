CREATE TABLE [dbo].[log]
(
[spid] [int] NOT NULL,
[id] [int] NOT NULL,
[message] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[log] ADD CONSTRAINT [PK__log__4B7734FF] PRIMARY KEY CLUSTERED  ([spid], [id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
