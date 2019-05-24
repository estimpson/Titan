CREATE TABLE [dbo].[edi_ff_layout]
(
[transaction_set] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[overlay_group] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[line] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[field] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[field_description] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[data_type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[position] [int] NOT NULL,
[length] [int] NOT NULL,
[segment] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[version] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[version_date] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[edi_ff_layout] ADD CONSTRAINT [PK__edi_ff_layout__532343BF] PRIMARY KEY CLUSTERED  ([transaction_set], [overlay_group], [line], [field]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
