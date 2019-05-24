CREATE TABLE [dbo].[T_EmpRep_Temp]
(
[date_stamp] [datetime] NOT NULL,
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[quantity] [numeric] (20, 6) NULL,
[remarks] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[operator] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[std_quantity] [numeric] (20, 6) NULL,
[Part_qty] AS ([quantity]*[std_quantity])
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_EmpRep_Temp] ADD CONSTRAINT [PK_EmpRep_Temp] PRIMARY KEY CLUSTERED  ([operator]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Format', N'Short Date', 'SCHEMA', N'dbo', 'TABLE', N'T_EmpRep_Temp', 'COLUMN', N'date_stamp'
GO
EXEC sp_addextendedproperty N'MS_DisplayControl', N'109', 'SCHEMA', N'dbo', 'TABLE', N'T_EmpRep_Temp', 'COLUMN', N'Part_qty'
GO
EXEC sp_addextendedproperty N'MS_Format', N'', 'SCHEMA', N'dbo', 'TABLE', N'T_EmpRep_Temp', 'COLUMN', N'Part_qty'
GO
EXEC sp_addextendedproperty N'MS_IMEMode', N'0', 'SCHEMA', N'dbo', 'TABLE', N'T_EmpRep_Temp', 'COLUMN', N'Part_qty'
GO
