CREATE TABLE [dbo].[NewLabelFormats]
(
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldlabelFormat] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[newLabelFormat] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[destination] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blanket_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDERlabel] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderpalletlabel] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[partlabelFormat] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewBoxlabelFormat] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewPalletlabelFormat] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
