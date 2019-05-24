CREATE TABLE [dbo].[titan_test]
(
[id] [int] NOT NULL,
[test] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[titan_test] ADD CONSTRAINT [PK__titan_test__4F12BBB9] PRIMARY KEY CLUSTERED  ([id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [test_ix] ON [dbo].[titan_test] ([test]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
