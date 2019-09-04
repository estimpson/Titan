CREATE TABLE [FTP].[LogDetails]
(
[FLHRowID] [int] NOT NULL,
[Line] [int] NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__LogDetail__Statu__6E01572D] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__LogDetails__Type__6EF57B66] DEFAULT ((0)),
[Command] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CommandOutput] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__LogDetail__RowCr__6FE99F9F] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__LogDetail__RowCr__70DDC3D8] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__LogDetail__RowMo__71D1E811] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__LogDetail__RowMo__72C60C4A] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [FTP].[LogDetails] ADD CONSTRAINT [PK__LogDetai__FFEE7451AF413C77] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [FTP].[LogDetails] ADD CONSTRAINT [UQ__LogDetai__3D42B08D9F71832B] UNIQUE NONCLUSTERED  ([FLHRowID], [Line]) ON [PRIMARY]
GO
ALTER TABLE [FTP].[LogDetails] ADD CONSTRAINT [FK__LogDetail__FLHRo__282DF8C2] FOREIGN KEY ([FLHRowID]) REFERENCES [FTP].[LogHeaders] ([RowID])
GO
ALTER TABLE [FTP].[LogDetails] ADD CONSTRAINT [FK__LogDetail__FLHRo__797309D9] FOREIGN KEY ([FLHRowID]) REFERENCES [FTP].[LogHeaders] ([RowID])
GO
