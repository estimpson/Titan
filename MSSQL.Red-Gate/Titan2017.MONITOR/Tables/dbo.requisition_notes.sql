CREATE TABLE [dbo].[requisition_notes]
(
[code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[notes] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[requisition_notes] ADD CONSTRAINT [PK__requisition_note__2AD55B43] PRIMARY KEY CLUSTERED  ([code]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
