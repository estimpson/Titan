SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure
[dbo].[msp_process_ford_862_ss]
as
begin transaction /* (1T)*/
/*-------------------------------------------------------------------------------------*/
/*      This procedure sets order header line feeds, dock codes, and reserve dock codes*/
/*      from data read from 862 transaction sets.*/
/*      Modified:       02 March 1999, Pheidippides McKenzie*/
/*      Returns:        0       success*/
/*                      100     no rows found*/
/*-------------------------------------------------------------------------------------*/
execute msp_process_in_ship_sched
select  message  from  log 
commit transaction -- (1T)

GO
