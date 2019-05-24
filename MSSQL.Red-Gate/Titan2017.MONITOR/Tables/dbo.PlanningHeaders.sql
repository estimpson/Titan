CREATE TABLE [dbo].[PlanningHeaders]
(
[Status] [int] NOT NULL CONSTRAINT [DF__PlanningH__Statu__63449CEF] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__PlanningHe__Type__6438C128] DEFAULT ((0)),
[RawDocumentGUID] [uniqueidentifier] NULL,
[DocumentImportDT] [datetime] NULL,
[TradingPartner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Version] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Release] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ControlNumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocumentDT] [datetime] NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__PlanningH__RowCr__652CE561] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__PlanningH__RowCr__6621099A] DEFAULT (user_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__PlanningH__RowMo__67152DD3] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__PlanningH__RowMo__6809520C] DEFAULT (user_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanningHeaders] ADD CONSTRAINT [PK__PlanningHeaders__625078B6] PRIMARY KEY NONCLUSTERED  ([RowID]) ON [PRIMARY]
GO
