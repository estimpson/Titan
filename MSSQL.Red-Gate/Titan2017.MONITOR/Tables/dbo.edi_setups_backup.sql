CREATE TABLE [dbo].[edi_setups_backup]
(
[destination] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[supplier_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trading_partner_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[release_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[auto_create_asn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[asn_overlay_group] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[equipment_description] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pool_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pool_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[material_issuer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id_code_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_model_year] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_po] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prev_cum_in_asn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parent_destination] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[edi_setups_backup] ADD CONSTRAINT [PK__edi_setups__7D78A4E7] PRIMARY KEY CLUSTERED  ([destination]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
