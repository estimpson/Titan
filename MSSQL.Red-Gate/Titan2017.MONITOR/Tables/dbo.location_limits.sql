CREATE TABLE [dbo].[location_limits]
(
[trans_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[location_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[location_limits] ADD CONSTRAINT [PK__location_limits__00200768] PRIMARY KEY CLUSTERED  ([trans_code], [location_code]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
