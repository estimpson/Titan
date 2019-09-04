CREATE TABLE [EDI_DICT].[DictionaryElementValueCodes]
(
[DictionaryVersion] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ElementCode] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ValueCode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DictionaryRowID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [EDI_DICT].[DictionaryElementValueCodes] ADD CONSTRAINT [PK__Dictiona__37603A1D023A93C6] PRIMARY KEY CLUSTERED  ([DictionaryRowID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_DEVC_1] ON [EDI_DICT].[DictionaryElementValueCodes] ([DictionaryVersion], [ElementCode], [ValueCode]) INCLUDE ([Description]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_DEVC_2] ON [EDI_DICT].[DictionaryElementValueCodes] ([ElementCode], [ValueCode], [DictionaryVersion]) INCLUDE ([Description]) ON [PRIMARY]
GO
