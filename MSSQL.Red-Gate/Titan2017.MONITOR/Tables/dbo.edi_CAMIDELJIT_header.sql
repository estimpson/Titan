CREATE TABLE [dbo].[edi_CAMIDELJIT_header]
(
[RelProcID] [int] NOT NULL IDENTITY(1, 1),
[Relno] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RelFunction] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RelDate] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocName] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocPurpose] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mapped] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
