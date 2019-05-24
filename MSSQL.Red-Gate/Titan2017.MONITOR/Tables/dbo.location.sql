CREATE TABLE [dbo].[location]
(
[code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[group_no] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sequence] [numeric] (3, 0) NULL,
[plant] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[secured_location] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[label_on_transfer] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[location] ADD CONSTRAINT [PK__location__03317E3D] PRIMARY KEY CLUSTERED  ([code]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
