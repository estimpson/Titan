CREATE TABLE [dbo].[edi_CAMIDELFOR_Detail]
(
[RelProcID] [int] NULL,
[Relno] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcessingIndicator] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipToID] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DockCode] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAMIPart] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAMIOrderNo] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanStatusInd] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchedFreq] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchedPattern] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qty] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DelDate] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModelYear] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
