SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [custom].[Monday]
as
select
	ThisMonday = dateadd(week, datediff(week, '2001-01-01', getdate()), '2001-01-01')
GO
