CREATE TABLE [dbo].[m_titan_po_notes]
(
[po_number] [int] NOT NULL,
[note] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[m_titan_po_notes] ADD CONSTRAINT [m_titan_po_notes_x] PRIMARY KEY CLUSTERED  ([po_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
