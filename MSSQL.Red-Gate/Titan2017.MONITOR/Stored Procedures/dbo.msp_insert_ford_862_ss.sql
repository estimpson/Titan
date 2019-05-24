SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure
[dbo].[msp_insert_ford_862_ss]
as
begin transaction /* (1T)*/
/*-------------------------------------------------------------------------------------*/
/*      This procedure inserts to m_in_shipschedule from ford862_ship_schedule.*/
/*      Modified:       02 March 1999, Pheidippides McKenzie*/
/*      Returns:        0       success*/
/*                      100     no rows found*/
/*-------------------------------------------------------------------------------------*/
/*      Insert records*/
insert into m_in_ship_schedule
  select RTrim(customer_part),
    RTrim(ship_to),'','','','A',
    convert(decimal(20,6),quantity),'S',
    convert(datetime,ship_date)
    from ford862_ship_schedule
    where customer_part>''
    and ship_to>''
/*      Check for rows*/
if @@rowcount=0
  begin /* (1aB)*/
    commit transaction /* (1T)*/
    return 100
  end /* (1aB)*/
else
  begin /* (1bB)*/
    commit transaction /* (1T)*/
    return 0
  end -- (1bB)

GO
