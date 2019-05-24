CREATE TABLE [dbo].[T_EmpRep]
(
[date_stamp] [datetime] NOT NULL,
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[operator] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Part_qty] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_EmpRep] ADD CONSTRAINT [PK__T_EmpRep__67C95AEA] PRIMARY KEY CLUSTERED  ([operator]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Format', N'Short Date', 'SCHEMA', N'dbo', 'TABLE', N'T_EmpRep', 'COLUMN', N'date_stamp'
GO
EXEC sp_addextendedproperty N'MS_DisplayControl', N'109', 'SCHEMA', N'dbo', 'TABLE', N'T_EmpRep', 'COLUMN', N'Part_qty'
GO
EXEC sp_addextendedproperty N'MS_Format', N'', 'SCHEMA', N'dbo', 'TABLE', N'T_EmpRep', 'COLUMN', N'Part_qty'
GO
