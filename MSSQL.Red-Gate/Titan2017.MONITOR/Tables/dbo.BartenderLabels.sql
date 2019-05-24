CREATE TABLE [dbo].[BartenderLabels]
(
[LabelFormat] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LabelPath] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BartenderLabels] ADD CONSTRAINT [PK_BartenderLabels] PRIMARY KEY CLUSTERED  ([LabelFormat]) ON [PRIMARY]
GO
