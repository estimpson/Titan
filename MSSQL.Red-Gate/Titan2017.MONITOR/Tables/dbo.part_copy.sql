CREATE TABLE [dbo].[part_copy]
(
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cross_ref] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[class] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[commodity] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[group_technology] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quality_alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description_short] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description_long] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serial_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[product_line] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[configuration] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[standard_cost] [numeric] (20, 6) NULL,
[user_defined_1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_defined_2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[flag] [int] NULL,
[engineering_level] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drawing_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eng_effective_date] [datetime] NULL,
[low_level_code] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_copy] ADD CONSTRAINT [PK__part_copy__382F5661] PRIMARY KEY CLUSTERED  ([part]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
