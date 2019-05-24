if exists ( select 1 from sysobjects where name = 'cdisp_wo_status')
        drop procedure cdisp_wo_status
go
create procedure cdisp_wo_status ( @qty_comp_percent integer = null)
as
begin
	create table #wo_bom	( 
			work_order	varchar(10),
			due_date	datetime,
			machine_no	varchar(10),
			sequence	integer,
			start_date	datetime,
			end_date	datetime,
			wod_part	varchar(25),
			bom_part	varchar(25),
			qty_required	numeric(20,6),
			qty_completed	numeric(20,6),
			bom_std_qty	numeric(20,6),
			assumed_issue_qty numeric(20,6),
			parts_per_hour	numeric(20,6),
			crew_size	integer)
			
	create table	#sf_labor_hours( 
				work_order	varchar(10),
				part		varchar(25),
				labor		numeric(20,6))

	create table	#wo_at	( 
				work_order	varchar(10),
				at_part		varchar(25),
				at_std_qty	numeric(20,6))
				
	if isnull(@qty_comp_percent,0) = 0 
		select @qty_comp_percent = 0 

	Insert	#wo_bom
	select 	wo.work_order, 
		wo.due_date, 
		machine_no, 
		wo.sequence, 
		wo.start_date, 
		wo.end_date, 
		wod.part, 
		bom.part, 
		wod.qty_required, 
		wod.qty_completed,
		bom.std_qty, 
		(wod.qty_completed*bom.std_qty) as assumed_issue_qty,
		pm.parts_per_hour,
		pm.crew_size
	from	work_order 	wo
		join workorder_detail wod on wod.workorder = wo.work_order
		join bill_of_material bom on bom.parent_part = wod.part
		join part_machine pm on pm.part = wod.part and pm.machine = wo.machine_no
	where	(wod.qty_completed/wod.qty_required)*100 >= @qty_comp_percent
	order by wo.work_order,
		wo.sequence,
		wod.part
	
	Insert	#sf_labor_hours
	select	work_order,
		part,
		sum(labor_hours)
	from	shop_floor_time_log
	where	work_order in (select distinct work_order from #wo_bom)
	group by work_order, part
	
			
	insert	#wo_at
	Select	at.workorder,
		at.part,
		sum(at.std_quantity)
	from	audit_trail	at
	where	at.type in ('M', 'N') and
		at.workorder in (Select distinct work_order from #wo_bom)
	group by at.workorder,
		at.part
	
	Select	sflh.work_order,
		sflh.part,
		sflh.labor,
		wobo.work_order,
		wobo.due_date,
		wobo.machine_no,
		wobo.sequence,
		wobo.start_date,
		wobo.end_date,
		wobo.wod_part,
		wobo.bom_part,
		wobo.qty_required,
		wobo.qty_completed,
		wobo.bom_std_qty,
		wobo.assumed_issue_qty,
		wobo.parts_per_hour,
		wobo.crew_size,
		woat.work_order,
		woat.at_part,
		woat.at_std_qty,
		prm.company_name, 
		prm.company_logo
	from	#wo_bom wobo 
		join #wo_at  woat on woat.work_order = wobo.work_order and  woat.at_part = wobo.bom_part
		left outer join #sf_labor_hours sflh on sflh.work_order = wobo.work_order and sflh.part = wobo.wod_part
		cross join parameters prm
end
go

if exists(select 1 from sysobjects where name = 'multireleases')
	drop table multireleases
go
create table multireleases 
(
	id	integer not null,
	part	varchar(25) not null,
	rel_no	varchar(30) not null,
	quantity decimal(20,6),
	rel_date datetime not null,	
	constraint multirelease_pk primary key (id, part, rel_date)
)
go

if exists(select 1 from sysobjects where name = 'cdivw_getreleases')
	drop view cdivw_getreleases
go
create view cdivw_getreleases (	
	order_no,
	part,
	due_date,
	release_no,
	quantity,
	committedqty)
as
select	od.order_no, od.part_number, convert(varchar(10), od.due_date, 110) due, od.release_no, od.quantity, od.committed_qty
from	order_detail od
	join order_header oh on oh.order_no = od.order_no
where	isnull(oh.status,'O') = 'O' and
	od.committed_qty < od.quantity and 
	od.release_no > ''
group by od.order_no, od.part_number, convert(varchar(10), od.due_date, 110), od.release_no, od.quantity, od.committed_qty
go

if not exists (select 1 from dbo.syscolumns, dbo.sysobjects where dbo.sysobjects.id = dbo.syscolumns.id and dbo.sysobjects.name = 'order_header' and dbo.syscolumns.name = 'order_status')
	alter table order_header add order_status char(1) null default 'A'
go

if not exists (select 1 from dbo.syscolumns, dbo.sysobjects where dbo.sysobjects.id = dbo.syscolumns.id and dbo.sysobjects.name = 'po_header' and dbo.syscolumns.name = 'next_seqno')
	alter table po_header add next_seqno integer null
go

if not exists (select 1 from dbo.syscolumns, dbo.sysobjects where dbo.sysobjects.id = dbo.syscolumns.id and dbo.sysobjects.name = 'po_detail' and dbo.syscolumns.name = 'promise_date')
	alter table po_detail add promise_date datetime null
go

if not exists (select 1 from dbo.syscolumns, dbo.sysobjects where dbo.sysobjects.id = dbo.syscolumns.id and dbo.sysobjects.name = 'po_detail_history' and dbo.syscolumns.name = 'promise_date')
	alter table po_detail_history add promise_date datetime null
go

update po_header 
set next_seqno = isnull ( (select max(row_id) + 1 from po_detail  
where po_detail.po_number = po_header.po_number ), 0 )
go

if exists(select 1 from sysobjects where name = 'msp_build_prod_grid')
	drop procedure msp_build_prod_grid
go
create procedure msp_build_prod_grid @start_dt datetime, @mode char (1)
as
create table #mps (
	ai_row	integer )

insert	#mps (
	ai_row )
select	ai_row
from	master_prod_sched
order by part, due

if	@mode = 'D'
	select	mps.part,
		mps.due,
		mps.plant,
		mps.qnty,
		mps.qty_assigned,
		0 qty_onhand,
		mps.origin,
		part.product_line,
		part.class,
		part.commodity,
		part_machine.activity,
		( case
			when	due < @start_dt then -1
			when	due < dateadd ( day, 14, @start_dt ) and due >= @start_dt then datediff ( day, @start_dt, due )
			else	14
		end ) bucket_no,
		( case
			when	due < @start_dt then qnty 
			else 0
		end ) demandpast,
		( case
			when	due < dateadd ( day, 1, @start_dt ) and due >= @start_dt then qnty  
			else 0
		end ) demand1,
		( case
			when	due < dateadd ( day, 2, @start_dt ) and due >= dateadd ( day, 1, @start_dt ) then qnty 
			else 0
		end ) demand2,
		( case
			when	due < dateadd ( day, 3, @start_dt ) and due >= dateadd ( day, 2, @start_dt ) then qnty 
			else 0
		end ) demand3,
		( case
			when	due < dateadd ( day, 4, @start_dt ) and due >= dateadd ( day, 3, @start_dt ) then qnty 
			else 0
		end ) demand4,
		( case
			when	due < dateadd ( day, 5, @start_dt ) and due >= dateadd ( day, 4, @start_dt ) then qnty 
			else 0
		end ) demand5,
		( case
			when	due < dateadd ( day, 6, @start_dt ) and due >= dateadd ( day, 5, @start_dt ) then qnty 
			else 0
		end ) demand6,
		( case
			when	due < dateadd ( day, 7, @start_dt ) and due >= dateadd ( day, 6, @start_dt ) then qnty 
			else 0
		end ) demand7,
		( case
			when	due < dateadd ( day, 8, @start_dt ) and due >= dateadd ( day, 7, @start_dt ) then qnty 
			else 0
		end ) demand8,
		( case
			when	due < dateadd ( day, 9, @start_dt ) and due >= dateadd ( day, 8, @start_dt ) then qnty 
			else 0
		end ) demand9,
		( case
			when	due < dateadd ( day, 10, @start_dt ) and due >= dateadd ( day, 9, @start_dt ) then qnty 
			else 0
		end ) demand10,
		( case
			when	due < dateadd ( day, 11, @start_dt ) and due >= dateadd ( day, 10, @start_dt ) then qnty 
			else 0
		end ) demand11,
		( case
			when	due < dateadd ( day, 12, @start_dt ) and due >= dateadd ( day, 11, @start_dt ) then qnty 
			else 0
		end ) demand12,
		( case
			when	due < dateadd ( day, 13, @start_dt ) and due >= dateadd ( day, 12, @start_dt ) then qnty 
			else 0
		end ) demand13,
		( case
			when	due < dateadd ( day, 14, @start_dt ) and due >= dateadd ( day, 13, @start_dt ) then qnty 
			else 0
		end ) demand14,
		( case
			when	due >= dateadd ( day, 14, @start_dt ) then qnty 
			else 0
		end ) demandfuture,
		part.type,
		0,
		part.engineering_level,
		part.group_technology,
		mps.source,
		mps.qty_assigned queue
	from	#mps
		join master_prod_sched mps on #mps.ai_row = mps.ai_row
		join part on mps.part = part.part
		left outer join part_machine on mps.part = part_machine.part and
			part_machine.sequence = 1
else
	select	mps.part,
		mps.due,
		mps.plant,
		mps.qnty,
		mps.qty_assigned,
		0 qty_onhand,
		mps.origin,
		part.product_line,
		part.class,
		part.commodity,
		part_machine.activity,
		( case
			when	due < @start_dt then -1
			when	due < dateadd ( week, 14, @start_dt ) and due >= @start_dt then datediff ( day, @start_dt, due ) / 7
			else	14
		end ) bucket_no,
		( case
			when	due < @start_dt then qnty 
			else 0
		end ) demandpast,
		( case
			when	due < dateadd ( week, 1, @start_dt ) and due >= @start_dt then qnty 
			else 0
		end ) demand1,
		( case
			when	due < dateadd ( week, 2, @start_dt ) and due >= dateadd ( week, 1, @start_dt ) then qnty 
			else 0
		end ) demand2,
		( case
			when	due < dateadd ( week, 3, @start_dt ) and due >= dateadd ( week, 2, @start_dt ) then qnty 
			else 0
		end ) demand3,
		( case
			when	due < dateadd ( week, 4, @start_dt ) and due >= dateadd ( week, 3, @start_dt ) then qnty 
			else 0
		end ) demand4,
		( case
			when	due < dateadd ( week, 5, @start_dt ) and due >= dateadd ( week, 4, @start_dt ) then qnty 
			else 0
		end ) demand5,
		( case
			when	due < dateadd ( week, 6, @start_dt ) and due >= dateadd ( week, 5, @start_dt ) then qnty 
			else 0
		end ) demand6,
		( case
			when	due < dateadd ( week, 7, @start_dt ) and due >= dateadd ( week, 6, @start_dt ) then qnty 
			else 0
		end ) demand7,
		( case
			when	due < dateadd ( week, 8, @start_dt ) and due >= dateadd ( week, 7, @start_dt ) then qnty 
			else 0
		end ) demand8,
		( case
			when	due < dateadd ( week, 9, @start_dt ) and due >= dateadd ( week, 8, @start_dt ) then qnty 
			else 0
		end ) demand9,
		( case
			when	due < dateadd ( week, 10, @start_dt ) and due >= dateadd ( week, 9, @start_dt ) then qnty 
			else 0
		end ) demand10,
		( case
			when	due < dateadd ( week, 11, @start_dt ) and due >= dateadd ( week, 10, @start_dt ) then qnty 
			else 0
		end ) demand11,
		( case
			when	due < dateadd ( week, 12, @start_dt ) and due >= dateadd ( week, 11, @start_dt ) then qnty 
			else 0
		end ) demand12,
		( case
			when	due < dateadd ( week, 13, @start_dt ) and due >= dateadd ( week, 12, @start_dt ) then qnty 
			else 0
		end ) demand13,
		( case
			when	due < dateadd ( week, 14, @start_dt ) and due >= dateadd ( week, 13, @start_dt ) then qnty 
			else 0
		end ) demand14,
		( case
			when	due >= dateadd ( week, 14, @start_dt ) then qnty 
			else 0
		end ) demandfuture,
		part.type,
		0,
		part.engineering_level,
		part.group_technology,
		mps.source,
		mps.qty_assigned queue
	from	#mps
		join master_prod_sched mps on #mps.ai_row = mps.ai_row
		join part on mps.part = part.part
		left outer join part_machine on mps.part = part_machine.part and
			part_machine.sequence = 1
go

if exists (select 1 from sysobjects where name = 'msp_update_orders')
	drop procedure msp_update_orders
GO

create procedure msp_update_orders (
	@shipper integer )
as
---------------------------------------------------------------------------------------
--	This procedure updates orders based on shipped line items.
--
--	Modifications:	01 MAR 1999, Harish P. Gubbi	Original.
--			02 JUL 1999, Harish P. Gubbi	Updating releases for normal orders.
--			03 JUL 1999, Harish P. Gubbi	Re-sequencing for normal orders.
--			07 JUL 1999, Eric E. Stimpson	Reformatted.
--			04 AUG 1999, Eric E. Stimpson	Removed loop through blanket order releases.
--			03 SEP 1999, Eric E. Stimpson	Removed references to @accumshipped from blanket order processing.
--			21 FEB 2001, Harish G. P	Changed the column to get the right std qty for normal orders	
--			31 MAR 2001, Harish G. P	Changed the column to from pack_line_qty to qty_packed for normal orders	
--			06 MAR 2002, Harish G. P	Included a new variable to store od.quantity & use the same in the equation
--							 to calculate new shipqty
--			10 FEB 2003, Harish G. P	Included order type check while closing the order
--
--	Parameters:	@shipper
--			@operator
--			@returnvalue
--
--	Returns:	  0	success
--
--	Process:
--	1.	Declare all the required local variables.
--	2.	Update accum shipped on shipper detail and blanket order header.
--	3.	Remove mps records and releases for fully shipped releases.
--	4.	Remove mps records and mark releases for partially shipped releases.
--	5.	Declare cursor for lineitems shipped against normal orders.
--	6.	Loop through lineitems.
--	7.	Declare cursor for releases.
--	8.	Loop through all releases for this part and suffix in due_date order.
--	9.	Check if release was fully shipped.
--	10.	Remove mps records and releases for fully shipped release.
--	11.	Remove mps records and mark releases for partially shipped release.
--	12.	Get next release.
--	13.	Get next lineitem.
--	14.	Declare cursor for shipped orders.
--	15.	Loop through orders.
--	16.	Check order for remaining releases.
--	17.	Resequence remaining releases.
--	18.	Initialize new sequence.
--	19.	Mark remaining releases to process.
--	20.	Declare cursor for remainingreleases.
--	21.	Loop through all remaining releases.
--	22.	Set new sequence.
--	23.	Get next remaining release.
--	24.	Get next shipped order.
--	25.	Return.
---------------------------------------------------------------------------------------

--	1.	Declare all the required local variables.
declare @part		varchar (25),
	@orderno	numeric (8,0),
	@stdqty		numeric (20,6),
	@suffix		integer,
	@ordertype	char (1),
	@ourcum		numeric (20,6),
	@accumshipped	numeric (20,6),
	@sequence	numeric (5,0),
	@relstdqty	numeric (20,6),
	@shipqty	numeric (20,6),	
	@releasedt	datetime,
	@releaseno	varchar (20),
	@rowid		integer,
	@newsequence	integer,
	@odqty		numeric(20,6),
	@odunit		char(2),
	@stdunit	char(2),
	@factor		numeric(20,6)

--	2.	Update accum shipped on shipper detail and blanket order header.
update	shipper_detail
set	accum_shipped = order_header.our_cum + shipper_detail.alternative_qty
from	shipper_detail
	join shipper on shipper_detail.shipper = shipper.id
	join order_header on shipper_detail.order_no = order_header.order_no
where	shipper_detail.shipper = @shipper and
	order_header.order_type = 'B'

update	order_header
set	our_cum = order_header.our_cum + shipper_detail.alternative_qty
from	shipper_detail
	join shipper on shipper_detail.shipper = shipper.id
	join order_header on shipper_detail.order_no = order_header.order_no
where	shipper_detail.shipper = @shipper and
	order_header.order_type = 'B'

--	3.	Remove mps records and releases for fully shipped releases.
delete	master_prod_sched
from	master_prod_sched
	join order_detail on origin = order_detail.order_no and
		source = order_detail.row_id
	join order_header on order_detail.order_no = order_header.order_no
	join shipper_detail on shipper_detail.order_no = order_header.order_no
	join shipper on shipper_detail.shipper = shipper.id
where	shipper_detail.shipper = @shipper and
	order_header.order_type = 'B' and
	order_detail.the_cum <= order_header.our_cum

delete	order_detail
from	order_detail
	join order_header on order_detail.order_no = order_header.order_no
	join shipper_detail on shipper_detail.order_no = order_header.order_no
	join shipper on shipper_detail.shipper = shipper.id
where	shipper_detail.shipper = @shipper and
	order_header.order_type = 'B' and
	order_detail.the_cum <= order_header.our_cum

--	Added on 12/05/03 from here
declare	odlines cursor for
select	od.order_no, od.part_number, od.quantity, od.unit, od.sequence, piv.standard_unit
from	order_detail od
	join order_header oh on oh.order_no = od.order_no
	join part_inventory piv on piv.part = od.part_number
where	od.quantity = od.std_qty and
	od.unit <> piv.standard_unit and
	oh.order_no in ( select order_no from shipper_detail where shipper = @shipper)

open odlines

fetch	odlines
into	@orderno, @part, @odqty, @odunit, @sequence, @stdunit

while ( @@fetch_status = 0 )
begin -- (1aa)

	--	Get the standard quantity conversion factor.
	select	@factor = IsNull
			( (	select	conversion
				  from	unit_conversion,
					part_unit_conversion
				 where	part_unit_conversion.part = @part AND
					part_unit_conversion.code = unit_conversion.code AND
					unit_conversion.unit1 = @odunit AND
					unit_conversion.unit2 = @stdunit), -1 )

	if @factor > 0
	begin 
		--	Calculate the standard quantity.
		select	@stdqty = @odqty * @factor
	
		--	update order detail
		update	order_detail
		set	std_qty = @stdqty
		where	order_no = @orderno and
			part_number = @part and
			sequence = @sequence
	end		
	
	fetch	odlines
	into	@orderno, @part, @odqty, @odunit, @sequence, @stdunit
end -- (1aa)
close	odlines
deallocate odlines
--	Added on 12/05/03 till here	

--	4.	Remove mps records and mark releases for partially shipped releases.
delete	master_prod_sched
from	master_prod_sched
	join order_detail on origin = order_detail.order_no and
		source = order_detail.row_id
	join order_header on order_detail.order_no = order_header.order_no
	join shipper_detail on shipper_detail.order_no = order_header.order_no
	join shipper on shipper_detail.shipper = shipper.id
where	shipper_detail.shipper = @shipper and
	order_header.order_type = 'B' and
	order_detail.our_cum < order_header.our_cum and
	order_detail.the_cum > order_header.our_cum

update	order_detail
set	std_qty = order_detail.the_cum - order_header.our_cum,
	quantity = order_detail.the_cum - order_header.our_cum,
	our_cum = order_header.our_cum,
	flag=1
from	order_detail
	join order_header on order_detail.order_no = order_header.order_no
	join shipper_detail on shipper_detail.order_no = order_header.order_no
	join shipper on shipper_detail.shipper = shipper.id
where	shipper_detail.shipper = @shipper and
	order_header.order_type = 'B' and
	order_detail.our_cum < order_header.our_cum and
	order_detail.the_cum > order_header.our_cum

--	Added on 12/05/03 from here
declare	odlines cursor for
select	od.order_no, od.part_number, od.quantity, od.unit, od.sequence, piv.standard_unit
from	order_detail od
	join order_header oh on oh.order_no = od.order_no
	join part_inventory piv on piv.part = od.part_number
where	od.quantity = od.std_qty and
	od.unit <> piv.standard_unit and
	oh.order_no in ( select order_no from shipper_detail where shipper = @shipper)

open odlines

fetch	odlines
into	@orderno, @part, @odqty, @odunit, @sequence, @stdunit

while ( @@fetch_status = 0 )
begin -- (1aa)

	--	Get the standard quantity conversion factor.
	select	@factor = IsNull
			( (	select	conversion
				  from	unit_conversion,
					part_unit_conversion
				 where	part_unit_conversion.part = @part AND
					part_unit_conversion.code = unit_conversion.code AND
					unit_conversion.unit1 = @odunit AND
					unit_conversion.unit2 = @stdunit), -1 )

	if @factor > 0
	begin 
		--	Calculate the standard quantity.
		select	@stdqty = @odqty * @factor
	
		--	update order detail
		update	order_detail
		set	std_qty = @stdqty
		where	order_no = @orderno and
			part_number = @part and
			sequence = @sequence
	end		
	
	fetch	odlines
	into	@orderno, @part, @odqty, @odunit, @sequence, @stdunit
end -- (1aa)
close	odlines
deallocate odlines
--	Added on 12/05/03 till here

--	5.	Declare cursor for lineitems shipped against normal orders.
declare lineitems cursor for
	select	shipper_detail.part_original,
		shipper_detail.order_no,
		shipper_detail.qty_packed,
		shipper_detail.suffix,
		order_header.order_type,
		order_header.our_cum,
		shipper_detail.alternative_qty
	from	shipper_detail
		join shipper on shipper_detail.shipper = shipper.id
		join order_header on shipper_detail.order_no = order_header.order_no
	where	shipper_detail.shipper = @shipper and
		shipper.type is null and
		order_header.order_type = 'N'

--	6.	Loop through lineitems.
open lineitems

fetch	lineitems
into	@part,
	@orderno,
	@stdqty,
	@suffix,
	@ordertype,
	@ourcum,
	@shipqty

while ( @@fetch_status = 0 )
begin -- (1aB)

--	7.	Declare cursor for releases.
	declare releases insensitive cursor for
	select	sequence,
		std_qty,
		row_id,
		quantity
	from	order_detail
	where	order_no = @orderno and
		part_number = @part and
		IsNull ( suffix, 0 ) = IsNull ( @suffix, 0 )
	order by due_date

--	8.	Loop through all releases for this part and suffix in due_date order.
	open releases

	fetch	releases
	into	@sequence,
		@relstdqty,
		@rowid,
		@odqty

	while ( @@fetch_status = 0 and @stdqty > 0 )
	begin -- (2aB)

--	9.	Check if release was fully shipped.

		if @relstdqty <= @stdqty
		begin -- (3aB)

--	10.	Remove mps records and releases for fully shipped release.

			delete	master_prod_sched
			from	master_prod_sched
			where	origin = @orderno and
				source = @rowid
			
			delete	order_detail
			where	order_no = @orderno and
				sequence = @sequence

			select	@stdqty = @stdqty - @relstdqty,
				@shipqty = @shipqty - @odqty
		end -- (3aB)
		else
		begin -- (3bB)
--	11.	Remove mps records and mark releases for partially shipped release.

			delete	master_prod_sched
			from	master_prod_sched
			where	origin = @orderno and
				source = @rowid

			update	order_detail
			set	std_qty = @relstdqty - @stdqty,
				quantity = order_detail.quantity - @shipqty
			where	order_no = @orderno and
				sequence = @sequence

			select	@stdqty = 0
		end -- (3bB)

--	12.	Get next release.

		fetch	releases
		into	@sequence,
			@relstdqty,
			@rowid,
			@odqty
	end -- (2aB)
	close releases
	deallocate releases
	
--	13.	Get next lineitem.

	fetch	lineitems
	into	@part,
		@orderno,
		@stdqty,
		@suffix,
		@ordertype,
		@ourcum,
		@shipqty
end -- (1aB)
close lineitems
deallocate lineitems

--	14.	Declare cursor for shipped orders.

declare orders cursor for
	select distinct shipper_detail.order_no
	from	shipper_detail
		join shipper on shipper_detail.shipper = shipper.id
		join order_header on shipper_detail.order_no = order_header.order_no
	where	shipper_detail.shipper = @shipper and
		shipper.type is null

--	15.	Loop through orders.

open orders

fetch	orders
into	@orderno

while ( @@fetch_status = 0 )
begin -- (1bB)

--	16.	Check order for remaining releases.

	if not exists (
		select	sequence
		from	order_detail
		where	order_no = @orderno )
		update	order_header
		set	status='C'
		where	order_no = @orderno and isnull(order_type,'B') = 'N'
	
	else
--	17.	Resequence remaining releases.

	begin -- (2bB)

--	18.	Initialize new sequence.

		select	@newsequence = 0

--	19.	Mark remaining releases to process.

		update	order_detail
		set	sequence = - sequence
		where	order_no = @orderno

--	20.	Declare cursor for remainingreleases.

		declare remainingreleases insensitive cursor for
			select	sequence
			from	order_detail
			where	order_no = @orderno
			order by part_number,
				due_date

--	21.	Loop through all remaining releases.

		open remainingreleases

		fetch	remainingreleases
		into	@sequence
		
		while ( @@fetch_status = 0 )
		begin -- (3cB)

--	22.	Set new sequence.

			select	@newsequence = @newsequence + 1
			
			update	order_detail
			set	sequence = @newsequence
			where	order_no = @orderno and
				sequence = @sequence

--	23.	Get next remaining release.

			fetch	remainingreleases
			into	@sequence
		end -- (3cB)
		close remainingreleases
		deallocate remainingreleases
	end -- (2bB)

--	24.	Recalculate committed quantity.
	execute msp_calculate_committed_qty @orderno

--	24.	Get next shipped order.

	fetch	orders
	into	@orderno

end -- (1bB)
close orders
deallocate orders

--	25.	Return.
return 0

GO

-- at the end
print '
----------------------------
--	Updating the version
---------------------------- 
'
update admin set version = '4.5'
go
