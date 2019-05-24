CREATE TABLE [dbo].[shipper_container]
(
[shipper] [int] NOT NULL,
[container_type] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[quantity] [int] NULL,
[weight] [numeric] (20, 6) NULL,
[group_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[shipper_container] ADD CONSTRAINT [PK_shipper_container] PRIMARY KEY CLUSTERED  ([shipper], [container_type]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
