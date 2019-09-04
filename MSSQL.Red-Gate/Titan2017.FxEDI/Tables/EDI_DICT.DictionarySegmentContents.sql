CREATE TABLE [EDI_DICT].[DictionarySegmentContents]
(
[DictionaryVersion] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ContentType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Segment] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ElementOrdinal] [int] NOT NULL,
[ElementCode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ElementUsage] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DictionaryRowID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [EDI_DICT].[DictionarySegmentContents] ADD CONSTRAINT [PK__Dictiona__37603A1D9E06FA99] PRIMARY KEY CLUSTERED  ([DictionaryRowID]) ON [PRIMARY]
GO
