CREATE TABLE [EDI_DICT].[DictionarySegmentCodes]
(
[DictionaryVersion] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DictionaryRowID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [EDI_DICT].[DictionarySegmentCodes] ADD CONSTRAINT [PK__Dictiona__37603A1DA690B957] PRIMARY KEY CLUSTERED  ([DictionaryRowID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_DSC_2] ON [EDI_DICT].[DictionarySegmentCodes] ([Code], [DictionaryVersion]) INCLUDE ([Description]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_DSC_1] ON [EDI_DICT].[DictionarySegmentCodes] ([DictionaryVersion], [Code]) INCLUDE ([Description]) ON [PRIMARY]
GO
