CREATE TABLE [dbo].[defects]
(
[machine] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[reason] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [numeric] (20, 6) NULL,
[operator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shift] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[work_order] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[data_source] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[defect_date] [datetime] NOT NULL,
[defect_time] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[defects] ADD CONSTRAINT [PK__defects__4999D985] PRIMARY KEY CLUSTERED  ([machine], [defect_date], [defect_time]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
