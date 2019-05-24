CREATE TABLE [dbo].[inventory_accuracy_history]
(
[code] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[date_counted] [datetime] NOT NULL,
[accuracy_percentage] [numeric] (5, 2) NOT NULL,
[total_objects] [int] NULL,
[total_discrepency] [int] NULL,
[group_no] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inventory_accuracy_history] ADD CONSTRAINT [PK__inventory_accura__61716316] PRIMARY KEY CLUSTERED  ([code], [date_counted]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
