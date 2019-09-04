CREATE TABLE [FTP].[LogHeaders]
(
[Status] [int] NOT NULL CONSTRAINT [DF__LogHeader__Statu__73BA3083] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__LogHeaders__Type__74AE54BC] DEFAULT ((0)),
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__LogHeader__RowCr__75A278F5] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__LogHeader__RowCr__76969D2E] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__LogHeader__RowMo__778AC167] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__LogHeader__RowMo__787EE5A0] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [FTP].[LogHeaders] ADD CONSTRAINT [PK__LogHeade__FFEE7451480119FF] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
