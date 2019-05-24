if exists(select 1 from sysobjects where name = 'cdisp_gssreport_enhanced')
	drop procedure cdisp_gssreport_enhanced
go
create procedure cdisp_gssreport_enhanced (@destination varchar(10), @mode char(1)=null) as
begin 	
	declare	@part	varchar(25),
		@due	datetime,
		@qty	decimal(20,6),
		@committedqty	decimal(20,6),
		@orderno	numeric(8,0),
		@onhand	decimal(20,6),
		@cpart	varchar(30),
		@customerpo	varchar(30),
		@modelyear	varchar(10),
		@stdate		datetime,
		@rpdue	numeric(20,6),
		@rday1		numeric(20,6),
		@rday2		numeric(20,6),
		@rday3		numeric(20,6),
		@rday4		numeric(20,6),
		@rday5		numeric(20,6),
		@rday6		numeric(20,6),
		@cpdue	numeric(20,6),
		@cday1		numeric(20,6),
		@cday2		numeric(20,6),
		@cday3		numeric(20,6),
		@cday4		numeric(20,6),
		@cday5		numeric(20,6),
		@cday6		numeric(20,6),
		@cnt		integer,
		@sdtstamp	varchar(10),
		@qtyreq		numeric(20,6),
		@multiplier	smallint
		
	create table #ordtemp (
		destination	varchar(10),
		part		varchar(25),
		cpart		varchar(30),
		customerpo	varchar(30),
		modelyear	varchar(10),
		onhand		numeric(20,6),
		rpdue	numeric(20,6),
		rday1		numeric(20,6),
		rday2		numeric(20,6),
		rday3		numeric(20,6),
		rday4		numeric(20,6),
		rday5		numeric(20,6),
		rday6		numeric(20,6),
		cpdue	numeric(20,6),
		cday1		numeric(20,6),
		cday2		numeric(20,6),
		cday3		numeric(20,6),
		cday4		numeric(20,6),
		cday5		numeric(20,6),
		cday6		numeric(20,6))

	select	@stdate = getdate()
	
	If @mode is null
		select	@mode = 'D'
		
	select	@multiplier = 1
	
	if @mode = 'W' or @mode = 'w'
		select	@multiplier = 7
		
	declare	ord_cursor cursor for 
	select	oh.destination,
		od.order_no,
		od.part_number,
		od.due_date, 
		od.customer_part,
		isnull(oh.customer_po,''),
		isnull(oh.model_year,''),
		isnull(sum(od.quantity),0) quantity
	from	order_detail od
		join order_header oh on oh.order_no = od.order_no 
	where	oh.destination = @destination and 
		isnull(oh.status,'O') = 'O' and
		od.due_date < dateadd(dd,(6 * @multiplier),@stdate)
	group by oh.destination, od.order_no, od.part_number, od.due_date, od.customer_part, 
		oh.customer_po, oh.model_year
	order by 1,2,3

	open	ord_cursor
	fetch	ord_cursor into @destination, @orderno, @part, @due, @cpart, @customerpo, @modelyear, @qty
	
	while	(@@fetch_status=0) 
	begin
	
		select	@rpdue=0, @rday1=0, @rday2=0, @rday3=0, @rday4=0, @rday5=0, @rday6=0,
			@cpdue=0, @cday1=0, @cday2=0, @cday3=0, @cday4=0, @cday5=0, @cday6=0,
			@onhand=0, @cnt=0

		select	@onhand = isnull(sum(quantity),0)
		from	object
		where	part = @part and status = 'A'
		
		select	@rpdue	= (case when convert(varchar(10), @due, 111) < convert(varchar(10), @stdate,111) then isnull(@qty,0) else 0 end),
			@rday1	= (case	when convert(varchar(10), @due, 111) = convert(varchar(10), @stdate,111) then isnull(@qty,0)else 0 end),
			@rday2	= (case	when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,(1 * @multiplier),@stdate),111) then isnull(@qty,0) else 0 end),
			@rday3	= (case	when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,(2 * @multiplier),@stdate),111) then isnull(@qty,0) else 0 end),
			@rday4	= (case when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,(3 * @multiplier),@stdate),111) then isnull(@qty,0) else 0 end),
			@rday5	= (case when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,(4 * @multiplier),@stdate),111) then isnull(@qty,0) else 0 end),
			@rday6	= (case when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,(5 * @multiplier),@stdate),111) then isnull(@qty,0) else 0 end)

		declare sd_cursor cursor for
		select	convert(varchar(10),date_stamp,111), 
			qty_required
		from	shipper_detail
			join shipper on shipper.id = shipper_detail.shipper
		where	order_no=@orderno and
			part=@part and
			shipper.type is null and
			(status='O' or status='A' or status='S')
		
		open	sd_cursor
		fetch	sd_cursor into @sdtstamp, @qtyreq
		
		while	(@@fetch_status=0)
		begin
			select	@cpdue = @cpdue + (case when @sdtstamp < convert(varchar(10), @stdate,111) then @qtyreq else 0 end),
				@cday1 = @cday1 + (case when @sdtstamp = convert(varchar(10), @stdate,111) then @qtyreq else 0 end),
				@cday2 = @cday2 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,(1 * @multiplier),@stdate),111) then @qtyreq else 0 end),
				@cday3 = @cday3 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,(2 * @multiplier),@stdate),111) then @qtyreq else 0 end),
				@cday4 = @cday4 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,(3 * @multiplier),@stdate),111) then @qtyreq else 0 end),
				@cday5 = @cday5 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,(4 * @multiplier),@stdate),111) then @qtyreq else 0 end),
				@cday6 = @cday6 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,(5 * @multiplier),@stdate),111) then @qtyreq else 0 end)
		
			fetch	sd_cursor into @sdtstamp, @qtyreq		
		end
		close	sd_cursor
		deallocate sd_cursor
		
		select	@cnt = isnull(count(1),0)
		from	#ordtemp
		where	destination = @destination and
			part	= @part and
			customerpo = @customerpo and
			modelyear = @modelyear
	
		if isnull(@cnt,0)=0 
		begin
			insert	into #ordtemp 
			values	(@destination, @part, @cpart, @customerpo, @modelyear, @onhand,
				@rpdue, @rday1, @rday2, @rday3, @rday4, @rday5, @rday6,
				@cpdue, @cday1, @cday2, @cday3, @cday4, @cday5, @cday6)
		end
		else
		begin
			update	#ordtemp
			set	rpdue	= rpdue + @rpdue,
				rday1	= rday1 + @rday1,
				rday2	= rday2 + @rday2,
				rday3	= rday3 + @rday3,
				rday4	= rday4 + @rday4,
				rday5	= rday5 + @rday5,
				rday6	= rday6 + @rday6,
				cpdue 	= @cpdue,
				cday1	= @cday1,
				cday2	= @cday2,
				cday3	= @cday3,
				cday4	= @cday4,
				cday5	= @cday5,
				cday6	= @cday6
			where	destination = @destination and
				part	= @part and
				customerpo = @customerpo and
				modelyear = @modelyear
		end
		
		fetch	ord_cursor into @destination, @orderno, @part, @due, @cpart, @customerpo, @modelyear, @qty			
	end 
	close	ord_cursor
	deallocate ord_cursor
	
	select	destination, part, cpart, customerpo, modelyear, onhand,
		rpdue, rday1, rday2, rday3, rday4, rday5, rday6,
		cpdue, cday1, cday2, cday3, cday4, cday5, cday6,
		(rpdue - cpdue) dpdue, (rday1 - cday1) dday1, 
		(rday2 - cday2) dday2, (rday3 - cday3) dday3, (rday4 - cday4) dday4, 
		(rday5 - cday5) dday5, (rday6 - cday6) dday6,
		company_name, company_logo		
	from	#ordtemp
		cross join parameters
	order	by 1, 2, 4
end
go

if exists (select * from sysobjects where id = object_id('msp_shipout') )
	drop procedure msp_shipout
GO

create procedure msp_shipout (
	@shipper	integer,
	@invdate	datetime=null )
as
---------------------------------------------------------------------------------------
--	This procedure performs a ship out on a shipper.
--
--	Modifications:	01 MAR 1999, Harish P. Gubbi	Original.
--			08 JUL 1999, Eric E. Stimpson	Reformatted.
--			04 AUG 1999, Eric E. Stimpson	Removed operator and pronumber from parameters.
--			11 AUG 1999, Eric E. Stimpson	Modified audit_trail generation to include pallets.
--			26 SEP 1999, Eric E. Stimpson	Added where condition to #3 to prevent data loss.
--			06 JAN 2000, Eric E. Stimpson	Add EDI shipout procedure.
--			08 JAN 2000, Eric E. Stimpson	Add result set for success.
--			25 JAN 2000, Eric E. Stimpson	Rewrite invoice number assigning to prevent lockup.
--			11 MAY 2000, Chris B. Rogers	added 6a.
--			08 AUG 2002, Harish G P		Included date as an argument and used the same in the script
--			08 AUG 2002, Harish G P		Commented out release dt & no updation on shipper detail
--			02 JAN 2003, Harish G P		Made changes to bill of lading updation
--			04 APR 2003, Harish G P		Changes to the shipper count where clause
--
--	Parameters:	@shipper	Mandatory
--
--	Returns:	0	success
--			100	shipper not staged
--
--	Process:
--	1.	Declare all the required local variables.
--	2.	Update shipper header to show shipped status and date and time shipped.
--	3.	Update shipper detail with date shipped and week no. and release date and no.
--	4.	Generate audit trail records for inventory to be relieved.
--	5.	Call EDI shipout procedure.
--	6.	Relieve inventory.
--	6a.	Update part_vendor table for outside processed part
--	7.	Adjust part online quantities for inventory.
--	8.	Relieve order requirements.
--	9.	Close bill of lading.
--	10.	Assign invoice number.
---------------------------------------------------------------------------------------

--	1.	Declare all the required local variables.
declare	@returnvalue	integer,
	@invoicenumber	integer,
	@cnt		integer,
	@bol		integer

--	2.	Update shipper header to show shipped status and date and time shipped.
if	@invdate is null 
	select	@invdate = GetDate ()
	
update	shipper
set	status = 'C',
	date_shipped = @invdate,
	time_shipped = @invdate
where	id = @shipper and
	status = 'S'

if @@rowcount = 0
	Return -1

--	3.	Update shipper detail with date shipped and week no. and release date and no.
/*
update	shipper_detail
set	date_shipped = shipper.date_shipped,
	week_no = datepart ( wk, shipper.date_shipped ),
	release_date = order_detail.due_date,
	release_no = order_detail.release_no
from	shipper_detail
	join shipper on shipper_detail.shipper = shipper.id
	left outer join order_detail on shipper_detail.order_no = order_detail.order_no and
		shipper_detail.part_original = order_detail.part_number and
		IsNull ( shipper_detail.suffix, 0 ) = IsNull ( order_detail.suffix, 0 ) and
		order_detail.due_date = (
			select	Min ( od2.due_date )
			from	order_detail od2
			where	shipper_detail.order_no = od2.order_no and
				shipper_detail.part_original = od2.part_number and
				IsNull ( shipper_detail.suffix, 0 ) = IsNull ( od2.suffix, 0 ) )
where	shipper = @shipper
*/

update	shipper_detail
set	date_shipped = shipper.date_shipped,
	week_no = datepart ( wk, shipper.date_shipped )
from	shipper_detail
	join shipper on shipper_detail.shipper = shipper.id
where	shipper = @shipper

--	4.	Generate audit trail records for inventory to be relieved.
insert	audit_trail (
	serial,
	date_stamp,
	type,
	part,
	quantity,
	remarks,
	price,
	salesman,
	customer,
	vendor,
	po_number,
	operator,
	from_loc,
	to_loc,
	on_hand,
	lot,
	weight,
	status,
	shipper,
	unit,
	workorder,
	std_quantity,
	cost,
	custom1,
	custom2,
	custom3,
	custom4,
	custom5,
	plant,
	notes,
	gl_account,
	package_type,
	suffix,
	due_date,
	group_no,
	sales_order,
	release_no,
	std_cost,
	user_defined_status,
	engineering_level,
	parent_serial,
	destination,
	sequence,
	object_type,
	part_name,
	start_date,
	field1,
	field2,
	show_on_shipper,
	tare_weight,
	kanban_number,
	dimension_qty_string,
	dim_qty_string_other,
	varying_dimension_code )
	select	object.serial,
		shipper.date_shipped,
		IsNull ( shipper.type, 'S' ),
		object.part,
		IsNull ( object.quantity, 1),
		(	case	shipper.type
				when 'Q' then 'Shipping'
				when 'O' then 'Out Proc'
				when 'V' then 'Ret Vendor'
				else 'Shipping'
			end ),
		IsNull ( shipper_detail.price, 0 ),
		shipper_detail.salesman,
		destination.customer,
		destination.vendor,
		object.po_number,
		IsNull ( shipper_detail.operator, '' ),
		object.location,
		destination.destination,
		part_online.on_hand,
		object.lot,
		object.weight,
		object.status,
		convert ( varchar, @shipper ),
		object.unit_measure,
		object.workorder,
		object.std_quantity,
		object.cost,
		object.custom1,
		object.custom2,
		object.custom3,
		object.custom4,
		object.custom5,
		object.plant,
		shipper_detail.note,
		shipper_detail.account_code,
		object.package_type,
		object.suffix,
		object.date_due,
		shipper_detail.group_no,
		convert ( varchar, shipper_detail.order_no ),
		shipper_detail.release_no,
		object.std_cost,
		object.user_defined_status,
		object.engineering_level,
		object.parent_serial,
		shipper.destination,
		object.sequence,
		object.type,
		object.name,
		object.start_date,
		object.field1,
		object.field2,
		object.show_on_shipper,
		object.tare_weight,
		object.kanban_number,
		object.dimension_qty_string,
		object.dim_qty_string_other,
		object.varying_dimension_code
	from	object
		join shipper on shipper.id = @shipper
		left outer join shipper_detail on shipper_detail.shipper = @shipper and
			object.part = shipper_detail.part_original and
			Coalesce ( object.suffix, (
				select	Min ( sd.suffix )
				from	shipper_detail sd
				where	sd.shipper = @shipper and
					object.part = sd.part_original ), 0 ) = IsNull ( shipper_detail.suffix, 0 )
		join destination on shipper.destination = destination.destination
		left outer join part_online on object.part = part_online.part
	where	object.shipper = @shipper

--	5.	Call EDI shipout procedure.
execute edi_msp_shipout @shipper

--	6.	Relieve inventory.
delete	object
from	object
	join shipper on object.shipper = shipper.id
where	object.shipper = @shipper and
	IsNull ( shipper.type, '' ) <> 'O'

update	object
set	location = shipper.destination,
	destination = shipper.destination,
	status = 'P'
from	object
	join shipper on object.shipper = shipper.id
where	object.shipper = @shipper and
	shipper.type = 'O'

--	6a.	Update part_vendor table for outside processed part
update	part_vendor
set	accum_shipped = isnull(accum_shipped,0) + 
			isnull((select	sum ( object.std_quantity ) 
				from	object
				where	object.shipper = @shipper and
					object.part = pv.part ),0)
from	part_vendor pv,
	shipper s,
	destination d
where	s.id = @shipper and
	s.type = 'O' and
	d.destination = s.destination and
	pv.vendor = d.vendor

--	7.	Adjust part online quantities for inventory.
update	part_online
set	on_hand = (
		select	Sum ( std_quantity )
		from	object
		where	part_online.part = object.part and
			object.status = 'A' )
from	part_online
	join shipper_detail on shipper_detail.shipper = @shipper and
		shipper_detail.part_original = part_online.part

--	8.	Relieve order requirements.
execute @returnvalue = msp_update_orders @shipper

if @returnvalue < 0
	return @returnvalue

--	9.	Close bill of lading.
select	@bol = bill_of_lading_number
from	shipper
where	id = @shipper

select	@cnt = count(1)
from	shipper
where	bill_of_lading_number = @bol and
	(isnull(status,'O') in ('S','O')) 

if isnull(@cnt,0) = 0
	update	bill_of_lading
	set	status = 'C'
	from	bill_of_lading
		join shipper on shipper.id = @shipper and
		bill_of_lading.bol_number = shipper.bill_of_lading_number

--	10.	Assign invoice number.
begin transaction -- (1T)

update	parameters
set	next_invoice = next_invoice + 1

select	@invoicenumber = next_invoice - 1
from	parameters

while exists (
	select	invoice_number
	from	shipper
	where	invoice_number = @invoicenumber )
begin -- (1B)
	select	@invoicenumber = @invoicenumber + 1

end -- (1B)

update	parameters
set	next_invoice = @invoicenumber + 1

update	shipper
set	invoice_number = @invoicenumber
where	id = @shipper

commit transaction -- (1T)

select 0
return 0

GO

if exists(select 1 from sysobjects where name = 'cdivw_getreleaseno')
	drop view cdivw_getreleaseno
go
create view cdivw_getreleaseno (	
	order_no,
	part,
	due_date,
	release_no)
as
select	od.order_no, od.part_number, convert(varchar(10), od.due_date, 110), min(od.release_no)
from	order_detail od
	join order_header oh on oh.order_no = od.order_no
where	od.committed_qty < od.quantity and 
	od.release_no > ''
group by od.order_no, od.part_number, convert(varchar(10), od.due_date, 110)
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
	eruntime)
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
		end )))) eruntime
from	master_prod_sched mps
	join mvw_billofmaterial bom on mps.part = bom.parent_part
	join part on bom.part = part.part
	join part_inventory part_inventory on mps.part = part_inventory.part			
	left outer join part_machine on bom.part = part_machine.part and
		part_machine.sequence = 1
	cross join parameters
go

-- at the end
print '
----------------------------
--	Updating the version
---------------------------- 
'
update admin set version = '4.4.2'
go
