if not exists (select 1 from dbo.syscolumns, dbo.sysobjects where dbo.sysobjects.id = dbo.syscolumns.id and dbo.sysobjects.name = 'order_detail' and dbo.syscolumns.name = 'promise_date')
	alter table order_detail add promise_date datetime null
go

if not exists (select 1 from dbo.syscolumns, dbo.sysobjects where dbo.sysobjects.id = dbo.syscolumns.id and dbo.sysobjects.name = 'po_detail' and dbo.syscolumns.name = 'other_charge')
	alter table po_detail add other_charge numeric(20,6) null
go

if not exists (select 1 from dbo.syscolumns, dbo.sysobjects where dbo.sysobjects.id = dbo.syscolumns.id and dbo.sysobjects.name = 'po_detail_history' and dbo.syscolumns.name = 'other_charge')
	alter table po_detail_history add other_charge numeric(20,6) null
go

Print	'Po detail part index'
if not exists(select 1 from sysindexes where tname = 'po_detail' and iname = 'podpart')
	create index podpart on po_detail (part_number)
go

Print	'Po detail part index'
if not exists(select 1 from sysindexes where tname = 'workorder_detail' and iname = 'wodpart')
	create index wodpart on workorder_detail (part)
go

---------------------------------------------------------------
--	View : mvw_new
---------------------------------------------------------------
if exists(select 1 from sysobjects where name = 'mvw_new')
	drop view mvw_new
go
create view mvw_new (	
	type,   
	part,   
	due,   
	qnty,   
	source,   
	origin,   
	machine,   
	run_time,   
	std_start_date,   
	endgap_start_date,
	startgap_start_date,
	setup,   
	process,
	id,   
	week_no,
	plant,
	eruntime,
	flag)
as
select	part.class type,
	bom.part,
	mps.dead_start due,
	(	case when bom.type = 'T'
			then bom.std_qty
			else mps.qnty * bom.std_qty
		end ) extended_qty,
	mps.source,
	mps.origin,
	IsNull ( part_machine.machine, '' ),
	IsNull ( (	case	when bom.type = 'T' then bom.std_qty
				else mps.qnty * bom.std_qty
			end ) / part_machine.parts_per_hour + (
			case	when parameters.include_setuptime = 'Y' then isnull(part_machine.setup_time,0)
				else 0
			end ), 0 ) runtime,
	IsNull ( dateadd ( mi, - 60 * (( 24.00 / parameters.workhours_in_day ) * 
		((case	when bom.type = 'T' then bom.std_qty
			else mps.qnty * bom.std_qty
		end ) / part_machine.parts_per_hour + 
		(case	when parameters.include_setuptime = 'Y' then isnull(part_machine.setup_time,0)
		 	else 0
		end ))), mps.dead_start ), mps.dead_start ) std_start_date,
	
	IsNull ( dateadd ( mi, - 60 * (( 24.00 / parameters.workhours_in_day ) * 
		((case	when bom.type = 'T' then bom.std_qty
			else mps.qnty * bom.std_qty
		end ) / part_machine.parts_per_hour + 
		(case	when parameters.include_setuptime = 'Y' then isnull(part_machine.setup_time,0)
		 	else 0
		end ) +
		(case	when part_machine.overlap_type = 'S' then ( part_inventory.standard_pack / part_machine.parts_per_hour ) 
			when part_machine.overlap_type = 'T' then part_machine.overlap_time 
		end ))), mps.due ), mps.dead_start ) endgap_start_date,
	
	IsNull ( dateadd ( mi, - 60 * (( 24.00 / parameters.workhours_in_day ) * 
		((case	when parameters.include_setuptime = 'Y' then isnull(part_machine.setup_time,0)
		 	else 0
		end ) +
		(case	when part_machine.overlap_type = 'S' then ( part_inventory.standard_pack / part_machine.parts_per_hour ) 
			when part_machine.overlap_type = 'T' then part_machine.overlap_time
		end ))), mps.dead_start ), convert( datetime, '1900-01-01' ) ) startgap_start_date,
	
	IsNull ( part_machine.setup_time, 0 ),
	part_machine.process_id,
	mps.id,
	datediff ( wk, parameters.fiscal_year_begin, mps.dead_start ),
	mps.plant,
	(60 * (( 24.00 / parameters.workhours_in_day ) * 
		((case	when bom.type = 'T' then bom.std_qty
			else mps.qnty * bom.std_qty
		end ) / part_machine.parts_per_hour + 
		(case	when parameters.include_setuptime = 'Y' then isnull(part_machine.setup_time,0)
		 	else 0
		end )))) eruntime,
	mvw_demand.flag
from	master_prod_sched mps
	join mvw_demand on mps.origin = mvw_demand.first_key and
	mps.source = mvw_demand.second_key
	join mvw_billofmaterial bom on mps.part = bom.parent_part
	join part on bom.part = part.part
	join part_inventory part_inventory on mps.part = part_inventory.part			
	left outer join part_machine on bom.part = part_machine.part and
		part_machine.sequence = 1
	cross join parameters
go

print	'msp_explode_demand changes'
if exists (select 1 from sysobjects where name = 'msp_explode_demand')
	drop procedure msp_explode_demand
go

create procedure	msp_explode_demand
as
-----------------------------------------------------------------------------------
--	msp_explode_demand :
--
--
--
--	Process :
--	
--	1.	Delete MPS
--	2.	Write the current set of releases to MPS
--	3.	Loop on @current_level
--	4.	Insert children of @current_level to MPS
--	5.	call msp_assign_quantity
--	6. 	Set the flags on the releases
--
--	Development Team - 07/20/1999 
--	Development Team - 08/26/1999	Modified update order_detail statement for performance.
--	Development Team - 09/15/1999	Included paranthesis to compute dead_start correctly
--	Development Team - 01/07/1999	Changed bill_of_material view to mvw_billofmaterial to suppress substitute_parts
--	GPH		 - 04/04/2000	Included overlap time as part of the dropdead date computation & part_inventory join
--					was included to get the standard pack quantity
-----------------------------------------------------------------------------------

--	Declarations

declare	@current_level	integer

--	Initialize
select	@current_level = 1

--	1.	Delete MPS
delete	master_prod_sched

--	2.	Write the current set of releases to MPS
insert	master_prod_sched (
		type,   
		part,   
		due,   
		qnty,   
		source,   
		origin,   
		machine,   
		run_time,   
		dead_start,   
		job,   
		setup,   
		status,   
		process,   
		qty_assigned,   
		due_time,   
		start_time,   
		id,   
		parent_id,   
		week_no,
		plant )
select	part.class,
	mvw_demand.part,
	mvw_demand.due_dt,
	mvw_demand.std_qty,
	mvw_demand.second_key,
	mvw_demand.first_key,
	IsNull ( part_machine.machine, '' ),
	IsNull ( mvw_demand.std_qty / part_machine.parts_per_hour + (
		case	when parameters.include_setuptime = 'Y' then part_machine.setup_time
			else 0
		end ), 0 ) runtime,
	IsNull ( dateadd ( mi, - 60 * (( 24.00 / parameters.workhours_in_day ) * ( mvw_demand.std_qty / part_machine.parts_per_hour +
		(case	when parameters.include_setuptime = 'Y' then part_machine.setup_time
		 	else 0
		end ) -
		isnull((case	when part_machine.overlap_type = 'S' then isnull( ( part_inventory.standard_pack / part_machine.parts_per_hour ),0) 
			when part_machine.overlap_type = 'T' then isnull( part_machine.overlap_time, 0 ) 
		 	else 0
		end ),0))), mvw_demand.due_dt ), mvw_demand.due_dt ) dropdate_date,
	'' job,
	IsNull ( part_machine.setup_time, 0 ),
	'S' status,
	part_machine.process_id,
	0 qty_assigned,
	mvw_demand.due_dt dropdate_time,
	IsNull ( dateadd ( mi, - 60 * (( 24.00 / parameters.workhours_in_day ) * ( mvw_demand.std_qty / part_machine.parts_per_hour + 
		(case	when parameters.include_setuptime = 'Y' then part_machine.setup_time
		 	else 0
		end ) -
		isnull((case	when part_machine.overlap_type = 'S' then isnull( ( part_inventory.standard_pack / part_machine.parts_per_hour ),0) 
			when part_machine.overlap_type = 'T' then isnull( part_machine.overlap_time, 0 ) 
		 	else 0
		end ),0))), mvw_demand.due_dt ), mvw_demand.due_dt ) start_time,
	@current_level id,
	0 parent_id,
	datediff ( wk, parameters.fiscal_year_begin, mvw_demand.due_dt ),
	mvw_demand.plant
from	mvw_demand
	join part on mvw_demand.part = part.part
	join part_inventory part_inventory on mvw_demand.part = part_inventory.part	
	left outer join part_machine on mvw_demand.part = part_machine.part and
		part_machine.sequence = 1
	cross join parameters

--	3.	Loop on @current_level
while @@rowcount > 0
begin -- (1B)

	select	@current_level = @current_level + 1

--	4.	Insert children of @current_level to MPS
	insert	master_prod_sched (
			type,   
			part,   
			due,   
			qnty,   
			source,   
			origin,   
			machine,   
			run_time,   
			dead_start,   
			job,   
			setup,   
			status,   
			process,   
			qty_assigned,   
			due_time,   
			start_time,   
			id,   
			parent_id,   
			week_no,
			plant )
	select	type,   
		part, 
		isnull(dateadd ( mi, eruntime, 
			(case	when endgap_start_date < std_start_date or endgap_start_date < startgap_start_date then endgap_start_date 
				when startgap_start_date > std_start_date then startgap_start_date 
				else std_start_date
			end)),mvw_new.due) due,
		qnty,   
		source,   
		origin,   
		machine,   
		run_time,   
		(case	when endgap_start_date < std_start_date or endgap_start_date < startgap_start_date then endgap_start_date 
			when startgap_start_date > std_start_date then startgap_start_date 
			else std_start_date
		end) dead_start,
		'' job,
		setup, 
		'S' status,  
		process,   
		0 qty_assigned,
		isnull(dateadd ( mi, eruntime, 
			(case	when endgap_start_date < std_start_date or endgap_start_date < startgap_start_date then endgap_start_date 
				when startgap_start_date > std_start_date then startgap_start_date 
				else std_start_date
			end)),mvw_new.due) dropdate_time,
		(case	when endgap_start_date < std_start_date or endgap_start_date < startgap_start_date then endgap_start_date 
			when startgap_start_date > std_start_date then startgap_start_date 
			else std_start_date
		end) start_time,
		@current_level id,
		0 parent_id,	
		week_no,
		plant			
	from	mvw_new
	where	mvw_new.id = @current_level - 1
end -- (1B)

--	5. 	call msp_assign_quantity
	execute msp_assign_quantity 

go

print	'msp_assign_quantity changes'

if exists ( select 1 from dbo.sysobjects where name = 'msp_assign_quantity' )
	drop procedure msp_assign_quantity
go

create procedure msp_assign_quantity (
        @part   varchar (25) = null )
as
---------------------------------------------------------------------------
--      msp_assign_quantity :

--      1.      Declarations
--      2.      Declare the required cursors (2)
--      3.      Loop through each part & assign quantities for each part 
--      4.      Reset assigned quantities
--      5.      Assign PO/WO quantities in due order for each part
---------------------------------------------------------------------------

--      1.      Declarations
declare @std_qty numeric (20,6),
        @qnty   numeric(20,6),
        @ai_row integer,
        @cpart	varchar(25)

--      2.      Declare the required cursors (2)
if isnull ( @part, '') = ''
begin

--      3.      Declare cursor for unique parts
        select  @part = min ( distinct mvw_replenish.part )
	from	mvw_replenish
	where	mvw_replenish.part > isnull(@part,'')
	order   by 1

        while @part > ''
        begin -- 1ab

	        execute msp_assign_quantity @part

	        select  @part = min ( mvw_replenish.part )
		from	mvw_replenish
		where	mvw_replenish.part > @part
		order   by 1
        
        end -- 1ab
end
else
begin
        select  @std_qty = convert(numeric(20,6),sum ( std_qty ))
        from    mvw_replenish
        where   part = @part

        declare parts_due cursor for
        select  ai_row, qnty
        from    master_prod_sched
        where   part = @part  
        order by due

        --      3.      Loop through each part & assign quantities for each part 

        begin transaction -- 1t

        --      4.      Reset assigned quantities
        
        update  master_prod_sched
        set     qty_assigned = 0
        where   part = @part

        open parts_due
        
        fetch parts_due into @ai_row, @qnty

        --      5.      Assign PO/WO quantities in due order for each part

        while @@sqlstatus = 0 and @std_qty > 0 
        begin -- 2b

               if @qnty >= @std_qty
                begin 
                        update master_prod_sched
                        set     qty_assigned = @std_qty
                        where ai_row = @ai_row

                        select @std_qty=0
                end
                else
                begin 
                        update master_prod_sched
                        set     qty_assigned = @qnty
                        where ai_row = @ai_row

                        select @std_qty=@std_qty - @qnty
                end

                fetch parts_due into @ai_row, @qnty
                
        end -- 2b
        
        close parts_due

        commit transaction  -- 1t
end
go

if exists (select 1 from sysobjects where id = object_id ( 'msp_low_level' ) )
	drop procedure msp_low_level
go

create procedure msp_low_level
(	@part	varchar (25) )
as

--	1.	Declare local variables.
declare @current_level int
declare @count int
declare @countnew int
declare	@childpart varchar (25)

--	2.	Create temporary table for exploding components.
create table #stack 
(
	part	varchar (25),
	stack_level	int,
	quantity numeric (20, 6)
) 

--	4.	Initialize stack with part or list of top parts.
select @current_level = 1
if @part =  '' 
	insert into #stack
	select part, @current_level, 1
	from part
	where part not in ( select part from bill_of_material ) 

else
	insert into #stack
	values ( @part, @current_level, 1 )
	
select	@count = isnull(count(1),0)
from	#stack	
where	stack_level = @current_level

--	5.	If rows found, loop through current level, adding children.
while @count > 0
begin
	declare	childparts cursor for
	select	part
	from	#stack
	where	stack_level = @current_level

--	6.	Add components for each part at current level using cursor.
	open childparts

	fetch	childparts
	into	@childpart

	while @@sqlstatus = 0
	begin

--	7.	Store level and total usage at this level for components.
		insert	#stack
		select	bom.part,
			@current_level + 1,
			bom.quantity * (
			select	sum ( isnull(#stack.quantity,0) )
			from	#stack
			where	#stack.part = @childpart and
				#stack.stack_level = @current_level )
		from	bill_of_material as bom
		where	bom.parent_part = @childpart

		fetch	childparts
		into	@childpart

	end

	close	childparts

	--	9.	Deallocate components cursor.
	--deallocate childparts


--	8.	Continue incrementing level as long as new components are added.
	select @current_level = @current_level + 1
		
	select	@count = isnull(count(1),0)
	from	#stack	
	where	stack_level = @current_level
	
end	

--	10.	Return result set.
select part, max ( stack_level ), sum ( quantity )
from #stack
group by part
order by max ( stack_level )

--	11.	Return.
if @@rowcount > 0
	return 0
else
	return 100
go

update admin set version = '4.5.2'
go
commit
go
