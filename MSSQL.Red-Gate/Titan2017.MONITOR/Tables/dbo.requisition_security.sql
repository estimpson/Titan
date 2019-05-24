CREATE TABLE [dbo].[requisition_security]
(
[operator_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[password] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[security_level] [int] NULL,
[dollar] [numeric] (20, 6) NULL,
[approver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approver_password] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[backup_approver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[backup_approver_password] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[backup_approver_end_date] [datetime] NULL,
[dollar_week_limit] [numeric] (20, 6) NULL,
[account_group_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[project_group_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[self_dollar_limit] [numeric] (20, 6) NULL,
[name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[requisition_security] ADD CONSTRAINT [PK__requisition_secu__261B931E] PRIMARY KEY CLUSTERED  ([operator_code]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
