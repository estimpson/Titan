CREATE TABLE [dbo].[StampingSetup_PO_Import]
(
[RawPart] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PoDate] [datetime2] NULL,
[Quantity] [int] NULL,
[ImportDateTime] [datetime2] NOT NULL CONSTRAINT [DF__StampingS__Impor__04FA9675] DEFAULT (sysdatetime())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StampingSetup_PO_Import] ADD CONSTRAINT [uc_po_import] UNIQUE NONCLUSTERED  ([RawPart], [PoDate], [Quantity]) ON [PRIMARY]
GO
