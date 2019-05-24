CREATE TABLE [dbo].[Label_ObjectPrintHistory]
(
[Serial] [int] NOT NULL,
[LabelDataChecksum] [int] NOT NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__Label_Obj__RowCr__2DDCB077] DEFAULT (getdate()),
[RowCreateUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Label_Obj__RowCr__2ED0D4B0] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__Label_Obj__RowMo__2FC4F8E9] DEFAULT (getdate()),
[RowModifiedUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Label_Obj__RowMo__30B91D22] DEFAULT (suser_name()),
[LabelData] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Label_ObjectPrintHistory] ADD CONSTRAINT [PK_Label_ObjectPrintHistory] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
