CREATE TABLE [dbo].[Label_ObjectScanHistory]
(
[Serial] [int] NOT NULL,
[LabelDataChecksum] [int] NOT NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__Label_Obj__RowCr__339589CD] DEFAULT (getdate()),
[RowCreateUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Label_Obj__RowCr__3489AE06] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__Label_Obj__RowMo__357DD23F] DEFAULT (getdate()),
[RowModifiedUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Label_Obj__RowMo__3671F678] DEFAULT (suser_name()),
[LabelData] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Label_ObjectScanHistory] ADD CONSTRAINT [PK_Label_ObjectScanHistory] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
