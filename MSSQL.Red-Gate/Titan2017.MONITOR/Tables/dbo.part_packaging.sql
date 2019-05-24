CREATE TABLE [dbo].[part_packaging]
(
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[quantity] [numeric] (20, 6) NOT NULL,
[manual_tare] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[label_format] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[round_to_whole_number] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_is_object] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inactivity_time] [smallint] NULL,
[threshold_upper] [numeric] (20, 6) NULL,
[threshold_lower] [numeric] (20, 6) NULL,
[unit] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stage_using_weight] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inactivity_amount] [numeric] (20, 6) NULL,
[threshold_upper_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[threshold_lower_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serial_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sequence] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_packaging] ADD CONSTRAINT [PK__part_packaging__628FA481] PRIMARY KEY CLUSTERED  ([part], [code]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_packaging] ADD CONSTRAINT [FK__part_packa__part__7D996BCF] FOREIGN KEY ([part]) REFERENCES [dbo].[part] ([part])
GO
ALTER TABLE [dbo].[part_packaging] WITH NOCHECK ADD CONSTRAINT [fk_part_packaging_part] FOREIGN KEY ([part]) REFERENCES [dbo].[part] ([part])
GO
