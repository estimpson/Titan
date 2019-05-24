SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure
[dbo].[msp_recalc_tasks_new](@resource_name varchar(10))
/*      I.      Declarations.*/
as /*              A.      Declare variables.*/
begin transaction
declare @sequence integer,
@start datetime,
@workorder varchar(10),
@wostart datetime,
@wostartoffset real,
@runtime real,
@accumruntime real
/*              B.      Declare cursor.*/
declare wocursor CURSOR DYNAMIC for select work_order
    from work_order
    where machine_no=@resource_name order by
    sequence desc,work_order asc
/*              C.      Create temporary storage for machine schedule.*/
create table #schedule(
  begin_dt datetime null,
  runtime real null,
  )
create table #workattimex(
  timex real null,
  accumwork real null,
  )
/*      II.     Prepare work orders.*/
/*              A.      Recalculate balance.*/
update workorder_detail set
  balance=qty_required-qty_completed
  where balance<>qty_required-qty_completed
  and workorder
  =any(select work_order
    from work_order
    where machine_no=@resource_name)
/*              B.      Negate sequence.*/
update work_order set
  sequence=-sequence
  where sequence<0
  and machine_no=@resource_name
update work_order set
  sequence=-sequence
  where machine_no=@resource_name
/*      III.    Initialize variables.*/
/*              A.      Initialize the start date, sequence, wo start and wo start offset.*/
select @start=getdate(),
  @sequence=1,
  @wostartoffset=0,
  @accumruntime=0
select @wostart=@start
/*              B.      Initialize temporary machine schedule.*/
insert into #schedule
  select begin_datetime,
    convert(real,DateDiff(minute,begin_datetime,end_datetime))/60
    from shop_floor_calendar
    where machine=@resource_name
    and begin_datetime>=@start
insert into #schedule
  select @start,
    convert(real,DateDiff(minute,@start,end_datetime)/60)
    from shop_floor_calendar
    where machine=@resource_name
    and @start between begin_datetime and end_datetime
insert into #schedule
  select @start,
    0
/*              C.      Initialize temporary w(tx).  [accumulative work at time x]*/
insert into #workattimex
  select convert(real,DateDiff(minute,
    (select min(trs1.begin_dt)
      from #schedule as trs1),begin_dt))/60,
    IsNull((select sum(runtime)
      from #schedule as trs1
      where trs1.begin_dt<trs.begin_dt),0)
    from #schedule as trs
/*      IV.     Loop through and recalculate work orders.*/
/*              A.      Open list of work orders.*/
open wocursor
/*              B.      Get first work order.*/
FETCH wocursor into @workorder
  /*              C.      Loop while more work orders.*/
while(@@fetch_status=0)
  begin /* (1B)*/
    /*                      1.      Set sequence, start date and time, and runtime for this work order.*/
    update work_order set
      sequence=@sequence,
      start_date=@wostart,
      start_time=@wostart,
      runtime
      =(select  Max (balance/IsNull(pm.parts_per_hour,pmp.parts_per_hour)
        +(case when IsNull(include_setuptime,'N')='Y' then IsNull(IsNull(pm.setup_time,pmp.setup_time),0)
        else 0
        end))
        from workorder_detail as wod left outer join
        part_machine as pm on wod.part=pm.part
        and pm.machine=@resource_name left outer join
        part_machine as pmp on wod.part=pmp.part
        and pmp.sequence=1 cross join
        parameters
        where workorder=@workorder)
      from work_order
      where work_order=@workorder
    /*                      2.      Calculate end_dt for this work order, wo start.*/
    select @runtime=convert(real,runtime)
      from work_order
      where work_order=@workorder
    select @accumruntime=@accumruntime+@runtime
    select @wostartoffset=timex+@accumruntime-accumwork
      from #workattimex
      where accumwork
      =(select  max (accumwork)
        from #workattimex
        where accumwork<@accumruntime)
    select @wostart=DateAdd(minute,@wostartoffset*60,@start)
    update work_order set
      end_date=@wostart,
      end_time=@wostart
      where work_order=@workorder
    /*                      3.      Increment sequence.*/
    select @sequence=@sequence+1
    /*                      4.      Get next work order.*/
    FETCH wocursor into @workorder
  end /* (1B)*/
/*      V.      Close work order list.*/
close wocursor
deallocate wocursor
commit transaction
GO
