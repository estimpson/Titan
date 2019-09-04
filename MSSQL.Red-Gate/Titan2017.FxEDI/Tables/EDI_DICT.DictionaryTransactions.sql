CREATE TABLE [EDI_DICT].[DictionaryTransactions]
(
[DictionaryVersion] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TransactionType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TransactionDescription] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DictionaryRowID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [EDI_DICT].[DictionaryTransactions] ADD CONSTRAINT [PK__Dictiona__37603A1DC8CFEA1C] PRIMARY KEY CLUSTERED  ([DictionaryRowID]) ON [PRIMARY]
GO
