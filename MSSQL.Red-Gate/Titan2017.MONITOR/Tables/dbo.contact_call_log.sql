CREATE TABLE [dbo].[contact_call_log]
(
[contact] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[start_date] [datetime] NOT NULL,
[call_subject] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[call_content] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[stop_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[contact_call_log] ADD CONSTRAINT [PK__contact_call_log__44D52468] PRIMARY KEY CLUSTERED  ([contact], [start_date]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
