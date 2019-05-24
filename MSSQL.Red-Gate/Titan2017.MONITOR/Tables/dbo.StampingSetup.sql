CREATE TABLE [dbo].[StampingSetup]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[FinishedGood] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RawPart] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Supplier] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PoNumber] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StampingSetup] ADD CONSTRAINT [PK__Stamping__3214EC27B7F2AF50] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StampingSetup] ADD CONSTRAINT [UC_StampingSetup] UNIQUE NONCLUSTERED  ([FinishedGood], [RawPart], [Supplier], [PoNumber]) ON [PRIMARY]
GO
