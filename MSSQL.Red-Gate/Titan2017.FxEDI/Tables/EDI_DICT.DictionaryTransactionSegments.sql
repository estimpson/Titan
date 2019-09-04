CREATE TABLE [EDI_DICT].[DictionaryTransactionSegments]
(
[DictionaryVersion] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TransactionType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SegmentOrdinal] [int] NOT NULL,
[SegmentCode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Usage] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OccurrencesMin] [int] NOT NULL,
[OccurrencesMax] [int] NOT NULL,
[DictionaryRowID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [EDI_DICT].[DictionaryTransactionSegments] ADD CONSTRAINT [PK__Dictiona__37603A1DC3DEE9C6] PRIMARY KEY CLUSTERED  ([DictionaryRowID]) ON [PRIMARY]
GO
