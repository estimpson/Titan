CREATE TABLE [dbo].[pbcatcol]
(
[pbc_tnam] [char] (129) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pbc_tid] [int] NULL,
[pbc_ownr] [char] (129) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pbc_cnam] [char] (129) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pbc_cid] [smallint] NULL,
[pbc_labl] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_lpos] [smallint] NULL,
[pbc_hdr] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_hpos] [smallint] NULL,
[pbc_jtfy] [smallint] NULL,
[pbc_mask] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_case] [smallint] NULL,
[pbc_hght] [smallint] NULL,
[pbc_wdth] [smallint] NULL,
[pbc_ptrn] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_bmap] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_init] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_cmnt] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_edit] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_tag] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pbcatc_x] ON [dbo].[pbcatcol] ([pbc_tnam], [pbc_ownr], [pbc_cnam]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
