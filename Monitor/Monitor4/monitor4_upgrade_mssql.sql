--------------------------------------------------------------
-- filename:	monitor4_upgrade.sql
-- purpose:	convert a 3.3h to 4.x database to the latest 
--		version of 4.x for microsoft sql server 6.5
--------------------------------------------------------------
print '
----------------
-- Table Changes
----------------'

print	'audit_trail_archive'
if exists (select * from sysobjects where name = 'audit_trail_archive')
	drop table audit_trail_archive
GO

CREATE TABLE audit_trail_archive (
	serial int NOT NULL ,
	date_stamp datetime NOT NULL ,
	type char (1) NOT NULL ,
	part varchar (25)  NOT NULL ,
	quantity numeric(20, 6) NOT NULL ,
	remarks varchar (10)  NOT NULL ,
	price numeric(20, 6) NULL ,
	salesman varchar (10)  NULL ,
	customer varchar (10)  NULL ,
	vendor varchar (10)  NULL ,
	po_number varchar (30)  NULL ,
	operator varchar (5)  NOT NULL ,
	from_loc varchar (10)  NULL ,
	to_loc varchar (10)  NULL ,
	on_hand numeric(20, 6) NULL ,
	lot varchar (20)  NULL ,
	weight numeric(20, 6) NULL ,
	status char (1)  NOT NULL ,
	shipper varchar (20)  NULL ,
	flag char (1)  NULL ,
	activity varchar (25)  NULL ,
	unit varchar (2)  NULL ,
	workorder varchar (10)  NULL ,
	std_quantity numeric(20, 6) NULL ,
	cost numeric(20, 6) NULL ,
	control_number varchar (254)  NULL ,
	custom1 varchar (50)  NULL ,
	custom2 varchar (50)  NULL ,
	custom3 varchar (50)  NULL ,
	custom4 varchar (50)  NULL ,
	custom5 varchar (50)  NULL ,
	plant varchar (10)  NULL ,
	invoice_number varchar (15)  NULL ,
	notes varchar (254)  NULL ,
	gl_account varchar (15)  NULL ,
	package_type varchar (20)  NULL ,
	suffix int NULL ,
	due_date datetime NULL ,
	group_no varchar (10)  NULL ,
	sales_order varchar (15)  NULL ,
	release_no varchar (15)  NULL ,
	dropship_shipper int NULL ,
	std_cost numeric(20, 6) NULL ,
	user_defined_status varchar (30)  NULL ,
	engineering_level varchar (10)  NULL ,
	posted char (1)  NULL ,
	parent_serial numeric(10, 0) NULL ,
	origin varchar (20)  NULL ,
	destination varchar (20)  NULL ,
	sequence int NULL ,
	object_type char (1)  NULL ,
	part_name varchar (254)  NULL ,
	start_date datetime NULL ,
	field1 varchar (10)  NULL ,
	field2 varchar (10)  NULL ,
	show_on_shipper char (1)  NULL ,
	tare_weight numeric(20, 6) NULL ,
	kanban_number varchar (6)  NULL ,
	dimension_qty_string varchar (50)  NULL ,
	dim_qty_string_other varchar (50)  NULL ,
	varying_dimension_code numeric(2, 0) NULL 
)
GO


print	'cdisp_archiveaudittrail'

if exists(select 1 from sysobjects where name = 'cdisp_archiveaudittrail')
	drop procedure cdisp_archiveaudittrail
go
create procedure cdisp_archiveaudittrail (@startdt datetime=null, @enddt datetime=null) as
begin
	--	Declarations
	declare	@sdate varchar(20),
		@edate varchar(20),
		@serial	integer,
		@datestamp datetime
		
	
	if @startdt is null 
		select	@startdt = getdate()
	if @enddt is null
		select	@enddt = getdate()
			
	select	@sdate = convert(varchar(10), @startdt, 102) + ' 00:00:00',
		@edate = convert(varchar(10), @enddt, 102) + ' 23:59:59'
	select	@startdt = convert(datetime, @sdate),
		@enddt = convert(datetime, @edate)

	if (select count(1) from sysobjects where name = 'audit_trail_archive') = 1
	begin
		begin tran

		declare	auditt cursor for
		select	serial, date_stamp
		from	audit_trail
		where	date_stamp >= @startdt 
			and date_stamp <= @enddt
		
		open	auditt
		
		fetch	auditt into @serial, @datestamp

		while	@@fetch_status = 0 
		begin
			if (select count(1) from audit_trail where serial = @serial and date_stamp = @datestamp) = 0 
				insert	into audit_trail_archive
				select	* 
				from	audit_trail
				where	serial = @serial
					and date_stamp <= @datestamp
			
			fetch	auditt into @serial, @datestamp
		end	
		
		close	auditt
		deallocate auditt
/*
		insert	into audit_trail_archive
		select	* 
		from	audit_trail
		where	date_stamp >= @startdt 
			and date_stamp <= @enddt
*/			
		delete	audit_trail
		where	date_stamp >= @startdt 
			and date_stamp <= @enddt
			
		commit tran
	end
	select 0
end
go

print 	'part_customer_tbp'

if exists ( select 1 from sysobjects where name = 'part_customer_tbp' ) 
	drop table part_customer_tbp
go
create table part_customer_tbp 
(	customer	varchar(10) not null,
	part	varchar(25) not null, 
	effect_date	datetime not null,
	price	numeric(20,6) null default 0,
	primary key (customer, part, effect_date))
go

print	'cdisp_updatetbprice'

if exists ( select 1 from sysobjects where name = 'cdisp_updatetbprice')
	drop procedure cdisp_updatetbprice
go
create procedure cdisp_updatetbprice as
begin
	declare	@cnt integer,
		@part	varchar(25),
		@customer varchar(10),
		@price	numeric(20,6)
	
	--	Count if any enteries are there for today
	select	@cnt = count(1)
	from	part_customer_tbp
	where	convert(varchar(10), effect_date,101) = convert(varchar(10), getdate(),101)
	
	if isnull(@cnt,0) > 0 
	begin
		begin tran
		--	Declare a cursor for the records from tbp table
		declare tbpcursor cursor for
		select	tbp.part, tbp.customer, tbp.price
		from	part_customer_tbp tbp
			join part_eecustom as p on p.part = tbp.part
		where	convert(varchar(10), tbp.effect_date,101) = convert(varchar(10), getdate(),101) and
			isnull(p.tb_pricing,'0') = '1' 
		
		--	Open cursor
		open	tbpcursor
		
		--	fetch data
		fetch	tbpcursor into @part, @customer, @price
		
		while @@fetch_status = 0 
		begin
			--	Update sales order header
			update	order_header
			set	alternate_price = @price
			where	customer = @customer and 
				blanket_part = @part and
				isnull(status,'O') = 'O'

			--	Update sales order detail
			update	order_detail
			set	order_detail.alternate_price = @price
			from	order_detail
				join order_header on order_header.order_no = order_detail.order_no 
			where	order_detail.part_number = @part and
				order_header.customer = @customer and 
				isnull(order_header.status,'O') = 'O'

			--	Update part standard
			update	part_standard
			set	price = @price
			where	part = @part				

			--	Update part customer
			update	part_customer
			set	blanket_price = @price
			where	part = @part and
				customer = @customer

			--	Update part customer_price_matrix
			update	part_customer_price_matrix
			set	alternate_price = @price
			where	part = @part and
				customer = @customer and
				qty_break = 1

			--	fetch data
			fetch	tbpcursor into @part, @customer, @price
		end
		
		--	Close cursor
		close	tbpcursor
		deallocate tbpcursor
		
		commit tran
	end
end
go

print	'Part Standard changes'

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'os_cost' )
	alter table part_standard add os_cost numeric(20,6) null
go
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'os_cost_cum' )
	alter table part_standard add os_cost_cum numeric(20,6) null
go
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'os_qtd_cost' )
	alter table part_standard add os_qtd_cost numeric(20,6) null
go
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'os_qtd_cost_cum' )
	alter table part_standard add os_qtd_cost_cum numeric(20,6) null
go
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'os_planned_cost' )
	alter table part_standard add os_planned_cost numeric(20,6) null
go
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'os_planned_cost_cum' )
	alter table part_standard add os_planned_cost_cum numeric(20,6) null
go
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'os_frozen_cost' )
	alter table part_standard add os_frozen_cost numeric(20,6) null
go
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'os_frozen_cost_cum' )
	alter table part_standard add os_frozen_cost_cum numeric(20,6) null
go


if exists(select 1 from sysobjects where name = 'cdisp_ovproc')
	drop procedure cdisp_ovproc
go
create procedure cdisp_ovproc (@order_no integer ) as
begin	
	SELECT	oh.order_no,
		oh.destination,
		oh.customer_part,
		oh.our_cum,
		ohi.the_cum their_cum,
		sd.date_shipped our_shipped_date,
		ohi.shipped_date their_shipped_date,
		sd.qty_packed our_shipped,
		ohi.shipped their_shipped,
		ohi.order_date,
		odi.part_number,
		odi.type,
		odi.due_date,
		odi.sequence,
		IsNull ( ( select Max ( od.quantity ) from order_detail od where od.order_no = odi.order_no and od.due_date = odi.due_date and od.notes = odi.notes), 0 ) old_quantity,
		IsNull ( quantity, 0 ) quantity,
		' ' checked,
		odi.status,
		Left ( odi.notes, 3 ) notes,
		ohi.review_date,
		ohi.reviewed_by
	FROM	order_detail_inserted  odi
		JOIN order_header oh ON odi.order_no = oh.order_no
		JOIN order_header_inserted ohi ON odi.order_no = ohi.order_no AND
			ohi.order_date = (
				SELECT	Max ( ohi2.order_date )
				  FROM	order_header_inserted ohi2
				 WHERE	ohi2.order_no = odi.order_no )
		LEFT OUTER JOIN shipper_detail sd ON sd.order_no = oh.order_no AND
			sd.shipper = oh.shipper AND
			sd.part_original = oh.blanket_part AND
			sd.date_shipped =
			(	SELECT	Max ( date_shipped )
				FROM	shipper_detail sd1
				WHERE	sd1.order_no = oh.order_no AND
					sd1.shipper = oh.shipper AND
					sd1.part_original = oh.blanket_part )
	WHERE	oh.order_no = @order_no
	UNION 
	SELECT	oh.order_no,
		oh.destination,
		oh.customer_part,
		oh.our_cum,
		ohi.the_cum their_cum,
		sd.date_shipped our_shipped_date,
		ohi.shipped_date their_shipped_date,
		sd.qty_packed our_shipped,
		ohi.shipped their_shipped,
		ohi.order_date,
		od.part_number,
		od.type,
		od.due_date,
		( select Max ( odi.sequence ) from order_detail_inserted odi where odi.order_no = od.order_no and odi.due_date = od.due_date and odi.notes = od.notes),
		IsNull ( quantity, 0 ),
		IsNull ( ( select Max ( odi.quantity ) from order_detail_inserted odi where odi.order_no = od.order_no and odi.due_date = od.due_date and odi.notes = od.notes), 0 ),
		' ',
		( select Max ( odi.status ) from order_detail_inserted odi where odi.order_no = od.order_no and odi.due_date = od.due_date and odi.notes = od.notes),
		Left ( od.notes, 3 ),
		ohi.review_date,
		ohi.reviewed_by
	FROM	order_detail od
		JOIN order_header oh ON od.order_no = oh.order_no
		JOIN order_header_inserted ohi ON od.order_no = ohi.order_no AND
			ohi.order_date = (
				SELECT	Max ( ohi2.order_date )
				  FROM	order_header_inserted ohi2
				 WHERE	ohi2.order_no = od.order_no )
		LEFT OUTER JOIN shipper_detail sd ON sd.order_no = oh.order_no AND
			sd.shipper = oh.shipper AND
			sd.part_original = oh.blanket_part AND
			sd.date_shipped =
			(	SELECT	Max ( date_shipped )
				FROM	shipper_detail sd1
				WHERE	sd1.order_no = oh.order_no AND
					sd1.shipper = oh.shipper AND
					sd1.part_original = oh.blanket_part )
	WHERE	oh.order_no = @order_no
	ORDER BY 1, 13, 16 desc
end
go

---------------------------------------------------------------------------------------
--	Monitor Order Validation Procedure
---------------------------------------------------------------------------------------

----------------------------
-- msp_createinsertedrelease
----------------------------
if	exists	(
	select	*
	  from	sysobjects
	 where	id = object_id ( 'msp_createinsertedrelease' ) )
	drop procedure	msp_createinsertedrelease
go

create procedure msp_createinsertedrelease
(	@orderno	numeric (8),
	@duedate	datetime,
	@quantity	numeric (20,6),
	@orderqueue	char (1) = null,
	@note		char (255) = null,
	@forecasttype	char (1) = null )
as
---------------------------------------------------------------------------------------
--	This procedure creates inserted releases from passed and static data.
--
--	Modifications:	08 JAN 1999, Eric E. Stimpson
--			25 MAY 1999, Eric E. Stimpson	Modified formatting.
--							Changed decimal to numeric.
--							Modified to update accums.
--							Modified to use sequence.
--			05 JAN 2000, Eric E. Stimpson	Add result set on success.
--							Modify to honor queue independence.
--			25 FEB 2000, Eric E. Stimpson	Fix to get our_cum for new last release.
--
--	Parameters:	@orderno	mandatory
--			@duedate	mandatory
--			@quantity	mandatory
--			@orderqueue	optional
--			@note		optional
--			@forecasttype	optional
--
--	Returns:	  0	success
--			100	order not found
--
--	Process:
--	1. Declare all the required local variables.
--	2. Get blanket order info:  blanket part, plant, accumulative shipped.
--	3. If blanket part not found, return no rows found.
--	4. Get the fiscal year begin date.
--	5. Calculate the week number (from fiscalyearbegin).
--	6. Find the sequence, rowid, and beginning cum of the release to be inserted.
--	7. Modify sequence numbers and accums of all releases which chronologically follow the release to be created.
--	8. Create release.
--	9. Return success.
---------------------------------------------------------------------------------------

--	1. Declare all the required local variables.
declare	@blanketpart		varchar ( 25 ),
	@shipto			varchar (20),
	@customerpart		varchar (35),
	@plant			varchar (10),
	@orderunit		char (2),
	@sequence		tinyint,
	@rowid			tinyint,
	@fiscalyearbegin	datetime,
	@weekno			integer,
	@begincum		numeric (20,6)

--	2. Get blanket order info:  blanket part, plant, accumulative shipped.
select	@blanketpart = blanket_part,
	@shipto = destination,
	@customerpart = customer_part,
	@plant = plant,
	@orderunit = shipping_unit
  from	order_header
 where	order_no = @orderno

--	3. If blanket part not found, return no rows found.
if @blanketpart is null
	return 100

--	4. Get the fiscal year begin date.
select	@fiscalyearbegin = fiscal_year_begin
  from	parameters

--	5. Calculate the week number (from fiscalyearbegin).
select	@weekno = datediff ( dd, @fiscalyearbegin, @duedate ) / 7 + 1

--	6. Find the sequence, rowid, and beginning cum of the release to be inserted.
select	@sequence = isnull ( max ( sequence ) + 1, (
		case when @orderqueue = 'P'
			then 101
			else 1
		end ) ),
	@rowid = isnull ( max ( row_id ) + 1, (
		case when @orderqueue = 'P'
			then 101
			else 1
		end ) ),
	@begincum = isnull ( max ( the_cum ), isnull ( (
		select	our_cum
		  from	order_header
		 where	order_no = @orderno ), 0 ) )
  from	order_detail_inserted
 where	order_no = @orderno and
 	due_date < @duedate and
 	type = @orderqueue

--	7. Modify sequence numbers and accums of all releases which chronologically follow the release to be created.
update	order_detail_inserted
   set	sequence = sequence + 1,
   	row_id = row_id + 1,
   	our_cum = our_cum + @quantity,
	the_cum = the_cum + @quantity
 where	order_no = @orderno and
 	sequence >= @sequence and
 	type = @orderqueue

--	8. Create release.
	insert	order_detail_inserted
	(		order_no,
			sequence,
			part_number,
			type,
			quantity,
			our_cum,
			the_cum,
			unit,
			notes,
			status,
			due_date,
			destination,
			customer_part,
			row_id,
			flag,
			ship_type,
			packline_qty,
			plant,
			week_no )
	values
	(	@orderno,
		@sequence,
		@blanketpart,
		isnull ( @orderqueue, 'F' ),
		@quantity,
		@begincum,
		@begincum + @quantity,
		@orderunit,
		isnull ( @note, 'Release created thru stored procedure' ),
		@forecasttype,
		@duedate,
		@shipto,
		@customerpart,
		@rowid,
		1,
		'N',
		0,
		@plant,
		@weekno )

--	9. Return success.
select 0
return 0
go

---------------------------------------------------------------------------------------
--	Monitor Order Validation Procedure
---------------------------------------------------------------------------------------

----------------------------
-- msp_removeinsertedrelease
----------------------------
if exists (
	select	1
	  from	sysobjects
	 where	id = object_id ( 'msp_removeinsertedrelease' ) )
	drop procedure	msp_removeinsertedrelease
go

create procedure msp_removeinsertedrelease
(	@orderno	numeric (8),
	@sequence	tinyint )
as
---------------------------------------------------------------------------------------
--	This procedure removes inserted releases.
--
--	Modifications:	08 JAN 1999, Eric E. Stimpson	Original.
--			24 MAY 1999, Eric E. Stimpson	Modified formatting.
--							Changed decimal to numeric.
--							Modified to update accums.
--							Modified to update sequence.
--							Modified to use sequence.
--			05 JAN 2000, Eric E. Stimpson	Add result set on success.
--							Modify to honor queue independence.
--	
--	Parameters:	@orderno	mandatory
--			@sequence	mandatory
--			@quantity	mandatory
--
--	Returns:	  0	success
--			100	release not found
--
--	Process:
--	1. Declare all the required local variables.
--	2. Get old quantity and order queue prior to removing release for sequence and accum updating.
--	3. If no rows, return no rows found.
--	4. Remove inserted release.
--	5. Modify sequence numbers and accums of all releases which chronologically follow the removed release.
--	6. Return success.
---------------------------------------------------------------------------------------

--	1. Declare all the required local variables.
declare	@oldquantity		numeric (20,6),
	@orderqueue		char (1)

--	2. Get old quantity and order queue prior to removing release for sequence and accum updating.
select	@oldquantity = quantity,
	@orderqueue = type
  from	order_detail_inserted
 where	order_no = @orderno and
	sequence = @sequence

--	3. If no rows, return no rows found.
if @@rowcount = 0
	return 100

--	4. Remove inserted release.
delete	order_detail_inserted
 where	order_no = @orderno and
	sequence = @sequence

--	5. Modify sequence numbers, row id, and accums of all releases which chronologically follow the removed release.
update	order_detail_inserted
   set	sequence = sequence - 1,
	row_id = row_id - 1,
  	our_cum = our_cum - @oldquantity,
	the_cum = the_cum - @oldquantity
 where	order_no = @orderno and
 	sequence > @sequence and
 	type = @orderqueue

--	6. Return success.
select 0
return 0
go

---------------------------------------------------------------------------------------
--	Monitor Order Validation Procedure
---------------------------------------------------------------------------------------

----------------------------
-- msp_updateinsertedrelease
----------------------------
if exists (
	select	1
	  from	sysobjects
	 where	id = object_id ( 'msp_updateinsertedrelease' ) )
	drop procedure	msp_updateinsertedrelease
go

create procedure msp_updateinsertedrelease
(	@orderno	numeric (8),
	@sequence	tinyint,
	@quantity	numeric (20,6) )
as
---------------------------------------------------------------------------------------
--	This procedure updates inserted releases from passed and static data.
--
--	Modifications:	08 JAN 1999, Eric E. Stimpson	Original.
--			24 MAY 1999, Eric E. Stimpson	Modified formatting.
--							Changed decimal to numeric.
--							Modified to update accums.
--							Modified to use sequence.
--			05 JAN 2000, Eric E. Stimpson	Add result set on success.
--							Modify to honor queue independence.
--	
--	Parameters:	@orderno	mandatory
--			@sequence	mandatory
--			@quantity	mandatory
--
--	Returns:	  0	success
--			 -1	invalid unit for part in order header
--			100	order not found
--
--	Process:
--	1. Declare all the required local variables.
--	2. Get blanket order info:  blanket part, plant, accumulative shipped.
--	3. If blanket part not found, return no rows found.
--	4. Calculate the standard quantity.
--	5. If error calculating standard quantity, then return invalid unit.
--	6. Get old quantity snf order queue prior to change for accum updating later.
--	7. Update release with new quantity.
--	8. Modify accums of all releases which chronologically follow modified release.
--	9. Return success.
---------------------------------------------------------------------------------------

--	1. Declare all the required local variables.
declare	@blanketpart		varchar (25),
	@orderunit		char (2),
	@oldquantity		numeric (20,6),
	@standardquantity	numeric (20,6),
	@returnvalue		integer,
	@orderqueue		char (1)

--	2. Get blanket order info:  blanket part, plant, accumulative shipped.
select	@blanketpart = blanket_part,
	@orderunit = shipping_unit
  from	order_header
 where	order_no = @orderno

--	3. If blanket part not found, return no rows found.
if @blanketpart is null
	return 100

--	4. Calculate the standard quantity.
select	@standardquantity = @quantity

execute	@returnvalue = msp_calculate_std_quantity
		@blanketpart,
		@standardquantity,
		@orderunit

--	5. If error calculating standard quantity, then return invalid unit.
if @returnvalue = -1
	return -1

--	6. Get old quantity and order queue prior to change for accum updating later.
select	@oldquantity = quantity,
	@orderqueue = type
  from	order_detail_inserted
 where	order_no = @orderno and
 	sequence = @sequence

--	7. Update release with new quantity.
update	order_detail_inserted
   set	quantity = @quantity,
	std_qty = @standardquantity,
	the_cum = our_cum + @quantity
 where	order_no = @orderno and
	sequence = @sequence

--	8. Modify accums of all releases which chronologically follow the modified release.
update	order_detail_inserted
   set	our_cum = our_cum + ( @quantity - @oldquantity ),
	the_cum = the_cum + ( @quantity - @oldquantity )
 where	order_no = @orderno and
 	sequence > @sequence and
 	type = @orderqueue

--	9. Return success.
select 0
return 0
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
		
		if @mode = 'D'
			select	@rpdue	= (case when convert(varchar(10), @due, 111) < convert(varchar(10), @stdate,111) then isnull(@qty,0) else 0 end),
				@rday1	= (case	when convert(varchar(10), @due, 111) = convert(varchar(10), @stdate,111) then isnull(@qty,0)else 0 end),
				@rday2	= (case	when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,(1 * @multiplier),@stdate),111) then isnull(@qty,0) else 0 end),
				@rday3	= (case	when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,(2 * @multiplier),@stdate),111) then isnull(@qty,0) else 0 end),
				@rday4	= (case when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,(3 * @multiplier),@stdate),111) then isnull(@qty,0) else 0 end),
				@rday5	= (case when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,(4 * @multiplier),@stdate),111) then isnull(@qty,0) else 0 end),
				@rday6	= (case when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,(5 * @multiplier),@stdate),111) then isnull(@qty,0) else 0 end)
		else
			if datepart(wk,@due) < datepart(wk, @stdate) 
				select	@rpdue = isnull(@qty,0)
			else if datepart(wk,@due) = datepart(wk, @stdate) 
				select	@rday1 = isnull(@qty,0)
			else if datepart(wk,@due) = datepart(wk, dateadd(dd,(1 * @multiplier),@stdate))
				select	@rday2 = isnull(@qty,0)
			else if datepart(wk,@due) = datepart(wk, dateadd(dd,(2 * @multiplier),@stdate))
				select	@rday3 = isnull(@qty,0)
			else if datepart(wk,@due) = datepart(wk, dateadd(dd,(3 * @multiplier),@stdate))
				select	@rday4 = isnull(@qty,0)
			else if datepart(wk,@due) = datepart(wk, dateadd(dd,(4 * @multiplier),@stdate))
				select	@rday5 = isnull(@qty,0)
			else if datepart(wk,@due) = datepart(wk, dateadd(dd,(5 * @multiplier),@stdate))
				select	@rday6 = isnull(@qty,0)						

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
			if @mode = 'D'
				select	@cpdue = @cpdue + (case when @sdtstamp < convert(varchar(10), @stdate,111) then @qtyreq else 0 end),
					@cday1 = @cday1 + (case when @sdtstamp = convert(varchar(10), @stdate,111) then @qtyreq else 0 end),
					@cday2 = @cday2 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,(1 * @multiplier),@stdate),111) then @qtyreq else 0 end),
					@cday3 = @cday3 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,(2 * @multiplier),@stdate),111) then @qtyreq else 0 end),
					@cday4 = @cday4 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,(3 * @multiplier),@stdate),111) then @qtyreq else 0 end),
					@cday5 = @cday5 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,(4 * @multiplier),@stdate),111) then @qtyreq else 0 end),
					@cday6 = @cday6 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,(5 * @multiplier),@stdate),111) then @qtyreq else 0 end)
			else		
				if datepart(wk,@sdtstamp) < datepart(wk, @stdate) 
					select	@cpdue = isnull(@qtyreq,0)
				else if datepart(wk,@sdtstamp) = datepart(wk, @stdate) 
					select	@cday1 = isnull(@qtyreq,0)
				else if datepart(wk,@sdtstamp) = datepart(wk, dateadd(dd,(1 * @multiplier),@stdate)) 	
					select	@cday2 = isnull(@qtyreq,0)
				else if datepart(wk,@sdtstamp) = datepart(wk, dateadd(dd,(2 * @multiplier),@stdate)) 	
					select	@cday3 = isnull(@qtyreq,0)
				else if datepart(wk,@sdtstamp) = datepart(wk, dateadd(dd,(3 * @multiplier),@stdate)) 	
					select	@cday4 = isnull(@qtyreq,0)
				else if datepart(wk,@sdtstamp) = datepart(wk, dateadd(dd,(4 * @multiplier),@stdate)) 	
					select	@cday5 = isnull(@qtyreq,0)
				else if datepart(wk,@sdtstamp) = datepart(wk, dateadd(dd,(5 * @multiplier),@stdate)) 	
					select	@cday6 = isnull(@qtyreq,0)
		
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

if exists(select 1 from sysobjects where name = 'cdisp_jobcomplnrepo')
	drop procedure cdisp_jobcomplnrepo
go
create procedure cdisp_jobcomplnrepo (@stdate datetime, @eddate datetime)
as
begin
	declare	@sstdate varchar(20),
		@seddate varchar(20)
		
	select	@sstdate = convert(varchar(10), @stdate, 101) + ' 00:00:00',
		@seddate = convert(varchar(10), @eddate, 101) + ' 23:59:59'
		
	select	@stdate = convert(datetime, @sstdate),
		@eddate = convert(datetime, @seddate)
		
	select	audit_trail.std_quantity,
		audit_trail.part,
		part.cross_ref,
		parameters.company_name,
		part.product_line,
		parameters.company_logo  
	from	audit_trail
		join part on part.part = audit_trail.part
		cross join parameters  
	where	( audit_trail.date_stamp >= @stdate ) AND  
		( audit_trail.date_stamp <= @eddate) AND  
		( audit_trail.type = 'J' ) AND  
		( part.type = 'F' ) 
end
go

if exists(select 1 from sysobjects where name = 'cdivw_partlist')
	drop view cdivw_partlist
go
create view cdivw_partlist 
(	part,   
	name,   
	cross_ref,   
	class,   
	type,   
	commodity,   
	group_technology,   
	product_line,   
	drawing_number,
	user_defined_1,
	user_defined_2,
	pc_user_defined_1,   
	standard_unit,   
	primary_location,   
	label_format,   
	unit_weight,   
	standard_pack,
	PMUD1,
	PMUD2,
	PMUD3,
	company_name,
	logo)
as	
SELECT	part.part,   
	part.name,   
	part.cross_ref,   
	part.class,   
	part.type,   
	part.commodity,   
	part.group_technology,   
	part.product_line,   
	part.drawing_number,
	part.user_defined_1,
	part.user_defined_2,
	part_characteristics.user_defined_1,   
	part_inventory.standard_unit,   
	part_inventory.primary_location,   
	part_inventory.label_format,   
	part_inventory.unit_weight,   
	part_inventory.standard_pack,
	( Select	label
	from	user_definable_module_labels
	where	sequence = 1 and
	module = 'PM') as PMUD1,
	( Select	label
	from	user_definable_module_labels
	where	sequence = 2 and
	module = 'PM') as PMUD2,
	( Select	label
	from	user_definable_module_labels
	where	sequence = 3 and
	module = 'PM') as PMUD3,
	pmt.company_name company_name,
	pmt.company_logo logo
FROM	part
	join part_inventory on part_inventory.part = part.part
	left outer join part_characteristics on part_characteristics.part = part.part
	cross join parameters pmt
go

if exists ( select 1 from sysobjects where name = 'cdivw_vendorlist')
	drop view cdivw_vendorlist
go
create view cdivw_vendorlist
(	code,   
	name,   
	contact,   
	phone,   
	terms,   
	ytd_sales,   
	balance,   
	frieght_type,   
	fob,   
	buyer,   
	plant,   
	ship_via,   
	address_1,   
	address_2,   
	address_3,   
	fax,   
	outside_processor,   
	address_4,   
	address_5,   
	address_6,
	kanban,
	status,
	custom1,
	custom2,
	custom3,
	custom4,
	custom5,
	VNDUD1,
	VNDUD2,
	VNDUD3,
	VNDUD4,
	VNDUD5,
	company_name, 
	logo 
) as
SELECT	vendor.code,   
	vendor.name,   
	vendor.contact,   
	vendor.phone,   
	vendor.terms,   
	vendor.ytd_sales,   
	vendor.balance,   
	vendor.frieght_type,   
	vendor.fob,   
	vendor.buyer,   
	vendor.plant,   
	vendor.ship_via,   
	vendor.address_1,   
	vendor.address_2,   
	vendor.address_3,   
	vendor.fax,   
	vendor.outside_processor,   
	vendor.address_4,   
	vendor.address_5,   
	vendor.address_6,
	vendor.kanban,
	vendor.status,
	vendor_custom.custom1,
	vendor_custom.custom2,
	vendor_custom.custom3,
	vendor_custom.custom4,
	vendor_custom.custom5,
	( Select	label
	from	user_definable_module_labels
	where	sequence = 1 and
	module = 'VM') as VNDUD1,
	( Select	label
	from	user_definable_module_labels
	where	sequence = 2 and
	module = 'VM') as VNDUD2,
	( Select	label
	from	user_definable_module_labels
	where	sequence = 3 and
	module = 'VM') as VNDUD3,
	( Select	label
	from	user_definable_module_labels
	where	sequence = 4 and
	module = 'VM') as VNDUD4,
	( Select	label
	from	user_definable_module_labels
	where	sequence = 5 and
	module = 'VM') as VNDUD5,
	pmt.company_name company_name, 
	pmt.company_logo logo
FROM	vendor
	left outer join vendor_custom on vendor_custom.code = vendor.code
	cross join parameters pmt
go

if exists(select 1 from sysobjects where name = 'cdivw_so_inquiry')
	drop view cdivw_so_inquiry
go

create view cdivw_so_inquiry (	
	order_no,   
	customer,   
	order_date,   
	contact,   
	destination,   
	blanket_part,
	model_year,   
	customer_part,   
	box_label,   
	pallet_label,   
	standard_pack,   
	our_cum,   
	the_cum,   
	order_type,   
	amount,   
	shipped,   
	deposit,   
	artificial_cum,   
	shipper,   
	status,   
	location,   
	ship_type,   
	unit,   
	revision,   
	customer_po,   
	blanket_qty,   
	price,   
	price_unit,   
	salesman,   
	zone_code,   
	term,   
	dock_code,   
	package_type,   
	plant,   
	notes,   
	shipping_unit,   
	line_feed_code,   
	fab_cum,   
	raw_cum,   
	fab_date,   
	raw_date,   
	po_expiry_date,   
	begin_kanban_number,   
	end_kanban_number,   
	line11,   
	line12,   
	line13,   
	line14,   
	line15,   
	line16,   
	line17,   
	custom01,   
	custom02,   
	custom03,   
	cs_status ) as
select	distinct order_header.order_no,   
	order_header.customer,   
	order_header.order_date,   
	order_header.contact,   
	order_header.destination,   
	isnull(order_header.blanket_part, order_detail.part_number) as blanket_part,
	order_header.model_year,   
	order_header.customer_part,   
	order_header.box_label,   
	order_header.pallet_label,   
	order_header.standard_pack,   
	order_header.our_cum,   
	order_header.the_cum,   
	order_header.order_type,   
	order_header.amount,   
	order_header.shipped,   
	order_header.deposit,   
	order_header.artificial_cum,   
	order_header.shipper,   
	order_header.status,   
	order_header.location,   
	order_header.ship_type,   
	order_header.unit,   
	order_header.revision,   
	order_header.customer_po,   
	order_header.blanket_qty,   
	order_header.price,   
	order_header.price_unit,   
	order_header.salesman,   
	order_header.zone_code,   
	order_header.term,   
	order_header.dock_code,   
	order_header.package_type,   
	order_header.plant,   
	order_header.notes,   
	order_header.shipping_unit,   
	order_header.line_feed_code,   
	order_header.fab_cum,   
	order_header.raw_cum,   
	order_header.fab_date,   
	order_header.raw_date,   
	order_header.po_expiry_date,   
	order_header.begin_kanban_number,   
	order_header.end_kanban_number,   
	order_header.line11,   
	order_header.line12,   
	order_header.line13,   
	order_header.line14,   
	order_header.line15,   
	order_header.line16,   
	order_header.line17,   
	order_header.custom01,   
	order_header.custom02,   
	order_header.custom03,   
	order_header.cs_status
from	order_header 
	left outer join order_detail on order_detail.order_no = order_header.order_no
go
	
if exists(select 1 from sysobjects where name = 'cdivw_po_inquiry')
	drop view cdivw_po_inquiry
go
create view cdivw_po_inquiry (
 	po_number,   
	vendor_code,   
	po_date,   
	date_due,   
	terms,   
	fob,   
	ship_via,   
	ship_to_destination,   
	status,   
	type,   
	description,   
	plant,   
	freight_type,   
	buyer,   
	printed,   
	total_amount,   
	shipping_fee,   
	sales_tax,   
	blanket_orderded_qty,   
	blanket_frequency,   
	blanket_duration,   
	blanket_qty_per_release,   
	blanket_part,   
	blanket_vendor_part,   
	price,   
	std_unit,   
	ship_type,   
	flag,   
	release_no,   
	release_control,   
	tax_rate,   
	scheduled_time) as  
select	distinct po_header.po_number,   
	po_header.vendor_code,   
	po_header.po_date,   
	po_header.date_due,   
	po_header.terms,   
	po_header.fob,   
	po_header.ship_via,   
	po_header.ship_to_destination,   
	po_header.status,   
	po_header.type,   
	po_header.description,   
	po_header.plant,   
	po_header.freight_type,   
	po_header.buyer,   
	po_header.printed,   
	po_header.total_amount,   
	po_header.shipping_fee,   
	po_header.sales_tax,   
	po_header.blanket_orderded_qty,   
	po_header.blanket_frequency,   
	po_header.blanket_duration,   
	po_header.blanket_qty_per_release,   
	isnull(po_header.blanket_part, po_detail.part_number) as blanket_part,   
	po_header.blanket_vendor_part,   
	po_header.price,   
	po_header.std_unit,   
	po_header.ship_type,   
	po_header.flag,   
	po_header.release_no,   
	po_header.release_control,   
	po_header.tax_rate,   
	po_header.scheduled_time  
from	po_header
	left outer join po_detail on po_detail.po_number = po_header.po_number
go
	
if exists(select 1 from sysobjects where name = 'cdivw_inv_inquiry')
	drop view cdivw_inv_inquiry
go

create view cdivw_inv_inquiry (	
	invoice_number,   
	id,   
	date_shipped,   
	destination,   
	customer,   
	ship_via,   
	invoice_printed,   
	notes,   
	type,   
	shipping_dock,   
	status,   
	aetc_number,   
	freight_type,   
	printed,   
	bill_of_lading_number,   
	model_year_desc,   
	model_year,   
	location,   
	staged_objs,   
	plant,   
	invoiced,   
	freight,   
	tax_percentage,   
	total_amount,   
	gross_weight,   
	net_weight,   
	tare_weight,   
	responsibility_code,   
	trans_mode,   
	pro_number,   
	time_shipped,   
	truck_number,   
	seal_number,   
	terms,   
	tax_rate,   
	staged_pallets,   
	container_message,   
	picklist_printed,   
	dropship_reconciled,   
	date_stamp,   
	platinum_trx_ctrl_num,   
	posted,   
	scheduled_ship_time, 
	part) as  
select	shipper.invoice_number,   
	shipper.id,   
	shipper.date_shipped,   
	shipper.destination,   
	shipper.customer,   
	shipper.ship_via,   
	shipper.invoice_printed,   
	shipper.notes,   
	shipper.type,   
	shipper.shipping_dock,   
	shipper.status,   
	shipper.aetc_number,   
	shipper.freight_type,   
	shipper.printed,   
	shipper.bill_of_lading_number,   
	shipper.model_year_desc,   
	shipper.model_year,   
	shipper.location,   
	shipper.staged_objs,   
	shipper.plant,   
	shipper.invoiced,   
	shipper.freight,   
	shipper.tax_percentage,   
	shipper.total_amount,   
	shipper.gross_weight,   
	shipper.net_weight,   
	shipper.tare_weight,   
	shipper.responsibility_code,   
	shipper.trans_mode,   
	shipper.pro_number,   
	shipper.time_shipped,   
	shipper.truck_number,   
	shipper.seal_number,   
	shipper.terms,   
	shipper.tax_rate,   
	shipper.staged_pallets,   
	shipper.container_message,   
	shipper.picklist_printed,   
	shipper.dropship_reconciled,   
	shipper.date_stamp,   
	shipper.platinum_trx_ctrl_num,   
	shipper.posted,   
	shipper.scheduled_ship_time,  
	shipper_detail.part_original
from	shipper 
	left outer join shipper_detail on shipper_detail.shipper = shipper.id
where	isnull(shipper.type,'') not in ('V','O') and
	isnull(shipper_detail.qty_packed,0) > 0 
go

if exists(select 1 from sysobjects where name='cdisp_chgcomponentpart')
	drop procedure cdisp_chgcomponentpart
go
create procedure cdisp_chgcomponentpart (@oldpart varchar(25), @newpart varchar(25))
as
begin
--	part,bill_of_material_ec
--	part,activity_router
--	part,part_machine
--	part,part_machine_tool
--	part,part_machine_tool_list
	
	--	Declaration
	declare	@cnt smallint
	
	--	Verify the new part exists
	select	@cnt = count(1)
	from	part
	where	part = @newpart
	
	if isnull(@cnt,0) = 1
	begin
		begin transaction
		--	change part_machine_tool_list
		update	part_machine_tool_list
		set	part = @newpart
		where	part = @oldpart
		
		--	change part_machine_tool
		update	part_machine_tool
		set	part = @newpart,
			tool = @newpart
		where	part = @oldpart

		--	change part_machine
		update	part_machine
		set	part = @newpart
		where	part = @oldpart
		
		--	change activity_router 
		update	activity_router
		set	part = @newpart,
			parent_part = @newpart
		where	part = @oldpart and parent_part = @oldpart 
		
		--	change bill_of_material_ec
		update	bill_of_material_ec
		set	part = @newpart
		where	part = @oldpart and end_datetime is null

		update	bill_of_material_ec
		set	parent_part = @newpart
		where	parent_part = @oldpart and end_datetime is null
		
		commit transaction
	end 	
end
go

if exists(select 1 from sysobjects where name='cdisp_changedescription')
	drop procedure cdisp_changedescription
go
create procedure cdisp_changedescription (@part varchar(25), @partdescription varchar(100))
as
begin
--	part_name,shipper_detail
--	part_name,part_vendor
--	description,po_detail
--	description,po_header
--	name,object
--	product_name,quote_detail
--	product_name,order_detail
--	product_name,order_detail_inserted
--	name,part

	begin transaction

	--	Update shipper detail with new part description on open shippers
	update	shipper_detail
	set	part_name = @partdescription
	from	shipper_detail
		join shipper on shipper.id = shipper_detail.shipper
	where	shipper_detail.part_original = @part and
		isnull(shipper.status,'O') in ('O', 'S')
		
	--	update part_vendor with new part description 
	update	part_vendor
	set	part_name = @partdescription
	where	part = @part
	
	--	Update po detail with new part description on open POs
	update	po_detail
	set	description = @partdescription
	from	po_detail
		join po_header on po_header.po_number = po_detail.po_number
	where	po_detail.part_number = @part and
		isnull(po_header.status,'A') = 'A'

	--	Update po header with new part description on open POs
	update	po_header
	set	description = @partdescription
	where	po_header.blanket_part = @part and
		isnull(po_header.status,'A') = 'A'

	--	Update object with new part description on active objects
	update	object
	set	name = @partdescription
	from	object
	where	object.part = @part and
		isnull(object.status,'A') = 'A'

	--	Update shipper detail with new part description on open shippers
	update	quote_detail
	set	product_name = @partdescription
	from	quote_detail
		join quote on quote.quote_number = quote_detail.quote_number
	where	quote_detail.part = @part and
		isnull(quote.status,'O') = 'O'

	--	Update shipper detail with new part description on open shippers
	update	order_detail
	set	product_name = @partdescription
	from	order_detail
		join order_header on order_header.order_no = order_detail.order_no
	where	order_detail.part_number = @part and
		isnull(order_header.status,'O') = 'O'

	--	Update shipper detail with new part description on open shippers
	update	order_detail_inserted
	set	product_name = @partdescription
	from	order_detail_inserted
		join order_header_inserted on order_header_inserted.order_no= order_detail_inserted.order_no
	where	order_detail_inserted.part_number = @part and
		isnull(order_header_inserted.status,'O') = 'O'

	--	Update object with new part description on active objects
	update	part
	set	name = @partdescription
	from	part
	where	part.part = @part
	
	commit transaction
end
go

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

if exists ( select 1 from sysobjects where name = 'cdivw_msf_inv')
	drop view cdivw_msf_inv
go
create view cdivw_msf_inv 
	(description,
	unit,
	onhand,
	wo_quantity,
	batch_quantity,
	bom_part,
	bom_qty,
	work_order)
as	
SELECT	Max ( name ) description,   
	Max ( unit_measure ) unit,   
	Max ( isnull(on_hand,0) ) onhand,   
	Sum ( isnull(quantity,0) * isnull(qty_required,0) ) wo_quantity,   
	Sum ( isnull(mfg_lot_size,0) * isnull(quantity,0) ) batch_quantity,   
	Max ( bill_of_material.part ) bom_part,
	Sum ( isnull(quantity,0) ) bom_qty,
	max ( work_order.work_order)
FROM	bill_of_material,   
	workorder_detail,
	work_order,
	part,   
	part_online,   
	part_mfg  
WHERE ( bill_of_material.parent_part = workorder_detail.part ) and  
	( bill_of_material.part = part.part ) and
	( work_order.machine_no = (select machine from machine_policy where machine = work_order.machine_no and material_substitution = 'N')) and	
	( bill_of_material.substitute_part <> 'Y'  ) and  
	( part_online.part =* part.part ) and  
	( workorder_detail.part = part_mfg.part ) and 
	( workorder_detail.workorder = work_order.work_order )
GROUP BY bill_of_material.part, work_order.work_order 
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

if exists(select 1 from sysobjects where name = 'cdisp_gssreport')
	drop procedure cdisp_gssreport
go
create procedure cdisp_gssreport (@destination varchar(10), @mode char(1)=null) as
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
		@cpdue		numeric(20,6),
		@cday1		numeric(20,6),
		@cday2		numeric(20,6),
		@cday3		numeric(20,6),
		@cday4		numeric(20,6),
		@cday5		numeric(20,6),
		@cday6		numeric(20,6),
		@cnt		integer,
		@sdtstamp	varchar(10),
		@qtyreq		numeric(20,6)
		
	create table #ordtemp (
		destination	varchar(10),
		part		varchar(25),
		cpart		varchar(30),
		customerpo	varchar(30),
		modelyear	varchar(10),
		onhand		numeric(20,6),
		rpdue		numeric(20,6),
		rday1		numeric(20,6),
		rday2		numeric(20,6),
		rday3		numeric(20,6),
		rday4		numeric(20,6),
		rday5		numeric(20,6),
		rday6		numeric(20,6),
		cpdue		numeric(20,6),
		cday1		numeric(20,6),
		cday2		numeric(20,6),
		cday3		numeric(20,6),
		cday4		numeric(20,6),
		cday5		numeric(20,6),
		cday6		numeric(20,6))

	select	@stdate = getdate()
	
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
		od.due_date < dateadd(dd,6,@stdate)
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
			@rday2	= (case	when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,1,@stdate),111) then isnull(@qty,0) else 0 end),
			@rday3	= (case	when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,2,@stdate),111) then isnull(@qty,0) else 0 end),
			@rday4	= (case when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,3,@stdate),111) then isnull(@qty,0) else 0 end),
			@rday5	= (case when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,4,@stdate),111) then isnull(@qty,0) else 0 end),
			@rday6	= (case when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,5,@stdate),111) then isnull(@qty,0) else 0 end)

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
				@cday2 = @cday2 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,1,@stdate),111) then @qtyreq else 0 end),
				@cday3 = @cday3 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,2,@stdate),111) then @qtyreq else 0 end),
				@cday4 = @cday4 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,3,@stdate),111) then @qtyreq else 0 end),
				@cday5 = @cday5 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,4,@stdate),111) then @qtyreq else 0 end),
				@cday6 = @cday6 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,5,@stdate),111) then @qtyreq else 0 end)
		
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
	
	if @mode ='E' or @mode='e'
	begin
		select	destination, part, cpart, customerpo, modelyear, onhand,
			rpdue, rday1, rday2, rday3, rday4, rday5, rday6,
			cpdue, cday1, cday2, cday3, cday4, cday5, cday6,
			(rpdue - cpdue) as 'dpdue', (rday1 - cday1) as 'dday1', 
			(rday2 - cday2) as 'dday2', (rday3 - cday3) as 'dday3', (rday4 - cday4) as 'dday4', 
			(rday5 - cday5) as 'dday5', (rday6 - cday6) as 'dday6',
			company_name, company_logo		
		from	#ordtemp
			cross join parameters
		where	(rpdue - cpdue) <> 0 or (rday1 - cday1) <> 0 or
			(rday2 - cday2) <> 0 or (rday3 - cday3) <> 0 or
			(rday4 - cday4) <> 0 or	(rday5 - cday5) <> 0 or
			(rday6 - cday6) <> 0 
		order	by 1, 2, 4
	end
	else
	begin
		select	destination, part, cpart, customerpo, modelyear, onhand,
			rpdue, rday1, rday2, rday3, rday4, rday5, rday6,
			cpdue, cday1, cday2, cday3, cday4, cday5, cday6,
			(rpdue - cpdue) as 'dpdue', (rday1 - cday1) as 'dday1', 
			(rday2 - cday2) as 'dday2', (rday3 - cday3) as 'dday3', (rday4 - cday4) as 'dday4', 
			(rday5 - cday5) as 'dday5', (rday6 - cday6) as 'dday6',
			company_name, company_logo		
		from	#ordtemp
			cross join parameters
		order	by 1, 2, 4
	end	
end
go

--	cdipohistory table creation
if exists ( select 1 from sysobjects where name = 'cdipohistory')
	drop table cdipohistory
go	
create table cdipohistory
	(id	integer not null identity primary key,
	po_number integer , 
	vendor	varchar(10), 
	part	varchar(25), 
	uom	varchar(2),
	date_due datetime, 
	type varchar(1), 
	last_recvd_date datetime, 
	last_recvd_amount decimal(20,6), 
	quantity decimal(20,6),
	received decimal(20,6), 
	balance decimal(20,6),
	price decimal(20,6), 
	row_id integer,
	release_no integer,
	raccuracy char(1) null default 'A',
	premium_freight char(1) null default 'N',
	premium_amount decimal(20,2) null)
go

--	Table to store the percentages and points to evalute vendor performance
if exists ( select 1 from sysobjects where name = 'cdi_ppdcr')
	drop table cdi_ppdcr
go
create table cdi_ppdcr 
	(id	integer not null identity primary key,
	p_age	integer,
	pointsd	integer)
go

--	Data being inserted into the points table
insert	into cdi_ppdcr (p_age, pointsd) values (100, 0)
go
insert	into cdi_ppdcr (p_age, pointsd) values (99, 1)
go
insert	into cdi_ppdcr (p_age, pointsd) values (98, 2)
go
insert	into cdi_ppdcr (p_age, pointsd) values (97, 3)
go
insert	into cdi_ppdcr (p_age, pointsd) values (96, 4)
go
insert	into cdi_ppdcr (p_age, pointsd) values (95, 5)
go
insert	into cdi_ppdcr (p_age, pointsd) values (94, 6)
go
insert	into cdi_ppdcr (p_age, pointsd) values (93, 7)
go
insert	into cdi_ppdcr (p_age, pointsd) values (92, 8)
go
insert	into cdi_ppdcr (p_age, pointsd) values (91, 9)
go
insert	into cdi_ppdcr (p_age, pointsd) values (90, 10)
go
insert	into cdi_ppdcr (p_age, pointsd) values (89, 50)
go
insert	into cdi_ppdcr (p_age, pointsd) values (88, 75)
go
insert	into cdi_ppdcr (p_age, pointsd) values (87, 100)
go
	
--	Table to hold the rating based on the points	
if exists (select 1 from sysobjects where name = 'cdi_vprating')
	drop table cdi_vprating
go
create table cdi_vprating 
	(id	integer not null identity primary key,
	lrange	integer,
	hrange	integer,
	rating	varchar(25))
go

--	Data being inserted into the rating table
insert into cdi_vprating ( lrange, hrange, rating) values (97, 100, 'Exceptional')
go
insert into cdi_vprating ( lrange, hrange, rating) values (90, 96, 'Acceptable')
go
insert into cdi_vprating ( lrange, hrange, rating) values (86, 89, 'At Risk')
go
insert into cdi_vprating ( lrange, hrange, rating) values (0, 85, 'Unacceptable')
go

--	For a given data range get vendor, po#, part, due_date & quantity, release_control
--	the data from the cdipohistory table
if exists ( select 1 from sysobjects where name = 'cdisp_vpr')
	drop procedure cdisp_vpr
go

create procedure cdisp_vpr (@stdate datetime, @eddate datetime=null) as
begin
--	Declarations
	declare	@ponumber integer,
		@vendor	varchar(10),	
		@part	varchar(25),
		@due	datetime,
		@qty	decimal(20,6),
		@qtyrec	decimal(20,6),
		@recdt	datetime,
		@sad	integer,
		@ra	integer,
		@sadpag	integer,
		@rapag	integer,		
		@psad	integer,
		@pra	integer,
		@vrating integer,
		@vpoints integer,		
		@rating	varchar(25),
		@relcontrol char(1),
		@tcount	smallint,
		@racount smallint,
		@sacount smallint

--	Temp table creation		
	create table #vprdata
		(vendor	varchar(10),
		part	varchar(25),		
		due	datetime,
		qty	decimal(20,6),
		recdt	datetime,
		qtyrec	decimal(20,6),
		sad	integer,
		ra	integer,		
		psad	integer,
		pra	integer,
		vrating	smallint,
		rating	varchar(25),
		ponumber integer)

--	Another temp table required in the process
	create table #recdata	
		(lastrecvddate datetime,
		raccuracy char(1))	
		
--	Validate enddate		
	if @eddate is null
		select	@eddate = getdate()	

--	Arrive at the proper datetime for both start and time 
	select	@stdate = convert(datetime, (convert(varchar(10),@stdate,111) + ' 00:00:00')),
		@eddate = convert(datetime, (convert(varchar(10),@eddate,111) + ' 23:23:59'))

--	Declare a cursor to extract data for the specified date range	
	declare vprcursor cursor for
	select	distinct b.vendor,
		b.po_number, 
		b.part, 
		b.date_due,
		b.quantity,
		poh.release_control
	from	cdipohistory b 
		join po_header poh on poh.po_number = b.po_number
	where	b.date_due >= @stdate and b.date_due <= @eddate
	group	by b.vendor, b.po_number, b.part, b.date_due, b.quantity, poh.release_control
	
--	Open cursor	
	Open	vprcursor

--	Fetch data
	fetch	vprcursor into @vendor, @ponumber, @part, @due, @qty, @relcontrol

--	Process all rows, each row at a time	
	while	(@@fetch_status = 0) 
	begin
		--	Initialize
		select	@qtyrec=0, @sad=0, @ra=0, @psad=-1, @pra=-1, @vrating=0, 
			@rating=''
			
		--	Get the total qty received for a given part, vendor and date
		select	@qtyrec = (case @relcontrol
					when 'A' then isnull(max(received),0) 
					else isnull(sum(last_recvd_amount),0) 
				   end),
			@recdt	= max(last_recvd_date)
		from	cdipohistory
		where	vendor = @vendor and
			po_number = @ponumber and
			part = @part and
			date_due = @due

		-- 	Get the latest quantity			
		select	@qty = isnull(quantity, @qty)
		from	cdipohistory
		where	vendor = @vendor and
			po_number = @ponumber and
			part = @part and
			date_due = @due and
			last_recvd_date = @recdt
			
		--	Delete the temp table
		delete	#recdata
		
		--	insert into #recdata temp table	
		insert	into #recdata
		select	convert(varchar(10),b.last_recvd_date, 101),
			max(b.raccuracy)
		from	cdipohistory b 
		where	b.date_due >= @stdate and b.date_due <= @eddate and
			b.vendor = @vendor and po_number = @ponumber and part = @part
		group	by b.vendor, b.po_number, b.part, convert(varchar(10),b.last_recvd_date, 101)

		--	Get the total count of the records in the recdata temp table
		select	@tcount = isnull(count(1),1)
		from	#recdata
		
		--	Count the number of accurate entries
		select	@racount = isnull(count(1),0)
		from	#recdata
		where	isnull(raccuracy,'A') = 'A'

		--	Compute the scheduled adherance
		if (@qtyrec < @qty) or (@recdt > @due)
			select	@sad = 0
		else
			select	@sad = convert(integer, (isnull(@qtyrec,0) / isnull(@qty,1)) * 100)
			
		--	Compute receiving accuracy	
		select	@sadpag = convert(integer, (isnull(@qtyrec,0) / isnull(@qty,1)) * 100),
			@rapag	= convert(integer, ((isnull(@racount,0) / isnull(@tcount,1)) * 100))
			
		select	@ra = convert(integer, ((isnull(@racount,0) / isnull(@tcount,1)) * 100))
		
		--	Determine the points for schedule adherence daily %
		select	@psad = isnull(pointsd,-1)
		from	cdi_ppdcr
		where	p_age = @sad
		
		--	Determine the points for receiving accuracy %
		select	@pra = isnull(pointsd,-1)
		from	cdi_ppdcr
		where	p_age = @ra

		--	Validate the points
		if isnull(@psad,-1) < 0 
			select @psad = 100
			
		if isnull(@pra,-1) < 0 
			select @pra = 100
				
		--	Compute the rating value 		
		select	@vrating = 100 - (@psad + @pra),
			@vpoints = 100 - (@psad + @pra)

		--	validate rating
		if isnull(@vrating,-1) < 0 
			select @vrating = 0

		--	Determine rating	
		select	@rating = rating
		from	cdi_vprating
		where	@vrating >= lrange and
			@vrating <= hrange

		--	Insert data into temp table
		insert	into #vprdata 
		values	(@vendor, @part, @due, @qty, @recdt, @qtyrec, @sadpag, @rapag, 
			@psad, @pra, @vpoints, @rating, @ponumber)
		
		--	Get next set of data
		fetch	vprcursor into @vendor, @ponumber, @part, @due, @qty, @relcontrol
		
	end
--	Close cursor
	close	vprcursor
	deallocate vprcursor
	

--	Display results	
	select  vendor, part, due, qty, recdt, qtyrec, 0, sad, ra, 
		psad, pra, vrating, rating, ponumber,
		company_name, company_logo
	from	#vprdata
		cross join parameters
	order	by vendor, part
end
go

print '
--------------------
--	Table: mdata
--------------------
'

if exists ( select 1 from sysobjects where name = 'mdata' )
	drop table mdata
go
create table mdata 
	(pmcode varchar(20) not null,
	mcode varchar(20) not null primary key,
	mname varchar(50) null, 
	switch char(1) null default 'N',
	display char(1) null default 'N')
go

insert into mdata values ( '00','01','The Monitor','N','Y')
insert into mdata values ( '01','0101','The Monitor/Inventory','N','Y')
insert into mdata values ( '01','0102','The Monitor/Sales','N','Y')
insert into mdata values ( '01','0103','The Monitor/Purchase','N','Y')
insert into mdata values ( '01','0104','The Monitor/Production','N','Y')
insert into mdata values ( '01','0105','The Monitor/Setups','N','Y')

insert into mdata values ( '0101','010101','TMI/Objects','N','N')
insert into mdata values ( '0101','010102','TMI/Audit Trail','N','N')
insert into mdata values ( '0101','010103','TMI/Parts','N','N')
insert into mdata values ( '0101','010104','TMI/Outside','N','N')
insert into mdata values ( '0101','010105','TMI/PhyInv','N','N')
insert into mdata values ( '0102','010201','TMO/Sales','N','N')
insert into mdata values ( '0102','010202','TMO/Glbl Ship','N','N')
insert into mdata values ( '0102','010203','TMO/Drop Ship','N','N')
insert into mdata values ( '0102','010204','TMO/Invoice','N','N')
insert into mdata values ( '0102','010205','TMO/EDI','N','N')
insert into mdata values ( '0102','010206','TMO/ASN','N','N')
insert into mdata values ( '0102','010207','TMO/EDI Parm','N','N')
insert into mdata values ( '0102','010208','TMO/Service','N','N')
insert into mdata values ( '0103','010301','TMP/P.O.Schdl','N','N')
insert into mdata values ( '0103','010302','TMP/P.O','N','N')
insert into mdata values ( '0103','010303','TMP/P.O.Inquiry','N','N')
insert into mdata values ( '0104','010401','TMP/Machine','N','N')
insert into mdata values ( '0104','010402','TMP/Production','N','N')
insert into mdata values ( '0104','010403','TMP/Reset','N','N')
insert into mdata values ( '0104','010404','TMP/Policy','N','N')
insert into mdata values ( '0104','010405','TMP/SoftQue','N','N')
insert into mdata values ( '0104','010406','TMP/Manual W.O','N','N')
insert into mdata values ( '0105','010501','TMS/Parms','N','N')
insert into mdata values ( '0105','010502','TMS/Parts','N','N')
insert into mdata values ( '0105','010503','TMS/Locations','N','N')
insert into mdata values ( '0105','010504','TMS/Customers','N','N')
insert into mdata values ( '0105','010505','TMS/Vendors','N','N')
insert into mdata values ( '0105','010506','TMS/Pricing','N','N')
insert into mdata values ( '0105','010507','TMS/Setups','N','N')
insert into mdata values ( '0105','010508','TMS/User','N','N')
go

if not exists ( select 1 from sysobjects where name = 'tdata' )
begin
	create table tdata (
		mcode	varchar(20) not null,
		ucode	varchar(5) not null,
		gcode	varchar(20) null,
		scode	varchar(250) null default '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',
		escode	text null,
		type	char(1) null default 'U',
		primary key  ( mcode, ucode ) 
		)
end		
go

print'
--------------------------------------------
--	Add note column to part_vendor table
--------------------------------------------
'
if exists (select 1 from sysobjects where name = 'part_vendor')
begin
	declare	@fkname	varchar(100),
		@command varchar(255),
		@table varchar(255)
	declare @pkname varchar(50)
	
	declare fks cursor for
		select	so1.name,
			so2.name
		from 	sysreferences sr, 
			sysobjects so1, 
			sysobjects so2,
			sysobjects so3
		where  	sr.fkeyid = so1.id and
			so2.id = sr.constid and
			sr.rkeyid = so3.id and
			so3.name = 'part_vendor'
	
	open fks
	fetch fks into @table,@fkname
	while ( @@fetch_status = 0 )
	begin
		select @command = 'alter table ' + @table + ' drop constraint ' + @fkname
		execute ( @command )
		fetch fks into @table,@fkname
	end
	close fks
	deallocate fks
	
	select	@pkname = so2.name 
	from 	sysobjects so1,
		sysobjects so2,
		sysconstraints sc 
	where 	so1.name = 'part_vendor' and 
		so1.id = sc.id and 
		sc.constid = so2.id

	if isnull(@pkname,'')>''
		execute ( 'alter table part_vendor drop constraint ' + @pkname )
end
go

if exists (select 1 from sysobjects where name = 'part_vendor')
	execute sp_rename part_vendor, part_vendor_temp
go

if not exists (select 1 from sysobjects where name = 'part_vendor')
begin	
	create table part_vendor (
		part varchar (25) NOT NULL ,
		vendor varchar (10) NOT NULL ,
		vendor_part varchar (25) NULL ,
		vendor_standard_pack numeric(20, 6) NULL ,
		accum_received numeric(20, 6) NULL ,
		accum_shipped numeric(20, 6) NULL ,
		outside_process char (1) NULL ,
		qty_over_received numeric(20, 6) NULL ,
		receiving_um varchar (10) NULL ,
		part_name varchar (100) NULL ,
		lead_time numeric(6, 2) NULL ,
		min_on_order numeric(20, 6) NULL ,
		beginning_inventory_date datetime NULL ,
		note	text null)

	insert into part_vendor 
		(part, 
		vendor, 
		vendor_part, 
		vendor_standard_pack, 
		accum_received,
		accum_shipped,
		outside_process,
		qty_over_received,
		receiving_um,
		part_name,
		lead_time,
		min_on_order,
		beginning_inventory_date)
	select	part, 
		vendor, 
		vendor_part, 
		vendor_standard_pack, 
		accum_received,
		accum_shipped,
		outside_process,
		qty_over_received,
		receiving_um,
		part_name,
		lead_time,
		min_on_order,
		beginning_inventory_date
	from	part_vendor_temp

	alter table part_vendor
	add
	constraint PK_part_vendor1 primary key clustered (part,vendor) 

	alter table part_vendor_price_matrix
	add
	constraint FK_part_vendor_price_matrix1 
		foreign key (part,vendor) references part_vendor(part, vendor)	
	
	drop table part_vendor_temp

end
go

print '
------------------------
-- cdivw_blanket_po view
------------------------
'

if exists ( select 1 from sysobjects where name = 'cdivw_blanket_po')
	drop view cdivw_blanket_po
go
create view cdivw_blanket_po (
	po_header_ship_to_destination,   
	po_header_plant,   
	po_header_type,   
	po_header_release_no,   
	vendor_company,   
	vendor_address_1,   
	vendor_address_2,   
	vendor_address_3,   
	vendor_fax,   
	po_header_fob,   
	parameters_company_name,   
	parameters_address_1,   
	parameters_address_2,   
	parameters_address_3,   
	parameters_phone_number,   
	vendor_buyer,   
	vendor_name,   
	part_cross_ref,   
	po_header_po_date,   
	po_header_freight_type,   
	po_header_po_number,   
	po_header_vendor_code,
	po_header_buyer,   
	carrier_name,   
	po_header_terms,   
	po_header_notes,   
	part_vendor_receiving_um,   
	part_vendor_vendor,   
	part_vendor_vendor_part,   
	po_header_blanket_part,   
	part_name,   
	vendor_address_4,   
	vendor_address_5,   
	vendor_address_6,   
	destination_name,   
	destination_address_1,   
	destination_address_2,   
	destination_address_3,   
	destination_address_4,   
	destination_address_5,   
	destination_address_6,   
	vendor_contact,
	part_vendor_note,
	part_vendor_part) as
select	po_header.ship_to_destination,   
	po_header.plant,   
	po_header.type,   
	po_header.release_no,   
	vendor.company,   
	vendor.address_1,   
	vendor.address_2,   
	vendor.address_3,   
	vendor.fax,   
	po_header.fob,   
	parameters.company_name,   
	parameters.address_1,   
	parameters.address_2,   
	parameters.address_3,   
	parameters.phone_number,   
	vendor.buyer,   
	vendor.name,   
	part.cross_ref,   
	po_header.po_date,   
	po_header.freight_type,   
	po_header.po_number,   
	po_header.vendor_code,
	po_header.buyer,   
	carrier.name,   
	po_header.terms,   
	po_header.notes,   
	part_vendor.receiving_um,   
	part_vendor.vendor,   
	part_vendor.vendor_part,   
	po_header.blanket_part,   
	part.name,   
	vendor.address_4,   
	vendor.address_5,   
	vendor.address_6,   
	destination.name,   
	destination.address_1,   
	destination.address_2,   
	destination.address_3,   
	destination.address_4,   
	destination.address_5,   
	destination.address_6,   
	vendor.contact,
	part_vendor.note,
	part_vendor.part
from	po_header  
	left outer join destination ON po_header.ship_to_destination = destination.destination,   
	part,   
	vendor,   
	part_vendor,   
	parameters,   
	carrier
where	( po_header.vendor_code = vendor.code ) and  
	( po_header.vendor_code = part_vendor.vendor ) and  
	( po_header.ship_via = carrier.scac ) and 
	( part_vendor.part = part.part ) and  
	( part_vendor.part in (select part_number from po_detail where po_detail.po_number = po_header.po_number and isnull(selected_for_print,'N') = 'Y' ) )
go


print'
----------------------------
-- cs_quotes_vw view changes 
----------------------------
'
if exists (select * from sysobjects where name = 'cs_quotes_vw')
	drop view cs_quotes_vw
GO

create view
  cs_quotes_vw
  as select quote_number,
    quote_date,
    contact,
    status,
    isnull((select sum(round(quantity*price,2)) from quote_detail where quote_detail.quote_number=quote.quote_number),0) as amount,
    notes,
    expire_date,
    customer,
    destination
    from quote

GO

print'
--------------------------------------------------
--	Add status column to vendor table
--------------------------------------------------
'
if exists (select 1 from sysobjects where name = 'vendor')
begin
	declare @pkname varchar(50)
	select	@pkname = so2.name 
	from 	sysobjects so1,
		sysobjects so2,
		sysconstraints sc 
	where 	so1.name = 'vendor' and 
		so1.id = sc.id and 
		sc.constid = so2.id

	if isnull(@pkname,'')>''
		execute ( 'alter table vendor drop constraint ' + @pkname )

end
GO

if exists (select 1 from sysobjects where name = 'vendor')
	execute sp_rename vendor, vendor_temp
go

if not exists (select 1 from sysobjects where name = 'vendor') 
begin
	create table vendor (
		code varchar (10) NOT NULL ,
		name varchar (35) NOT NULL ,
		outside_processor char (1) NULL ,
		contact varchar (35) NULL ,
		phone varchar (20) NULL ,
		terms varchar (20) NULL ,
		ytd_sales numeric(20, 6) NULL ,
		balance numeric(20, 6) NULL ,
		frieght_type varchar (15) NULL ,
		fob varchar (10) NULL ,
		buyer varchar (30) NULL ,
		plant varchar (10) NULL ,
		ship_via varchar (15) NULL ,
		company varchar (10) NULL ,
		address_1 varchar (50) NULL ,
		address_2 varchar (50) NULL ,
		address_3 varchar (50) NULL ,
		fax varchar (20) NULL ,
		flag int NULL ,
		partial_release_update char (1) NULL ,
		trusted varchar (1) NULL ,
		address_4 varchar (40) NULL ,
		address_5 varchar (40) NULL ,
		address_6 varchar (40) NULL ,
		kanban char (1) NULL ,
		default_currency_unit varchar (3) NULL ,
		show_euro_amount smallint NULL ,
		status varchar(20) null,
		CONSTRAINT PK__vendor__167AF389 PRIMARY KEY  CLUSTERED 
		(
			code
		)
	)

	insert	into vendor 
		(code,
		name,
		outside_processor,
		contact,
		phone,
		terms,
		ytd_sales,
		balance,
		frieght_type,
		fob,
		buyer,
		plant,
		ship_via,
		company,
		address_1,
		address_2,
		address_3,
		fax,
		flag,
		partial_release_update,
		trusted,
		address_4,
		address_5,
		address_6,
		kanban,
		default_currency_unit,
		show_euro_amount)
	select	code,
		name,
		outside_processor,
		contact,
		phone,
		terms,
		ytd_sales,
		balance,
		frieght_type,
		fob,
		buyer,
		plant,
		ship_via,
		company,
		address_1,
		address_2,
		address_3,
		fax,
		flag,
		partial_release_update,
		trusted,
		address_4,
		address_5,
		address_6,
		kanban,
		default_currency_unit,
		show_euro_amount
	from	vendor_temp

	drop table vendor_temp
	
	update vendor set status = 'Approved' where status is null

end	
GO

print'
--------------------------------------------------
--	create vendor_service_status
--	and port data from customer_service_status
--------------------------------------------------
'
if exists (select 1 from sysobjects where name = 'vendor_service_status')
begin
	declare @pkname varchar(50)
	select	@pkname = so2.name 
	from 	sysobjects so1,
		sysobjects so2,
		sysconstraints sc 
	where 	so1.name = 'vendor_service_status' and 
		so1.id = sc.id and 
		sc.constid = so2.id

	if isnull(@pkname,'')>''
		execute ( 'alter table vendor_service_status drop constraint ' + @pkname )

end
GO

if exists (select 1 from sysobjects where name = 'vendor_service_status')
	execute sp_rename vendor_service_status, vendor_service_status_tmp
go

if not exists ( select * from sysobjects where id = object_id('vendor_service_status')) 
begin
	CREATE TABLE vendor_service_status (
		status_name varchar (20) NOT NULL ,
		status_type varchar (1) NOT NULL ,
		default_value varchar (1) NOT NULL ,
		CONSTRAINT PK__vendor_service__status PRIMARY KEY  CLUSTERED 
		(
			status_name
		)
	)

	insert into vendor_service_status
	select * from customer_service_status

	drop table vendor_service_status_tmp
end	
go


print'
--------------------------
-- activity_router changes
--------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'activity_router' )
	execute sp_rename activity_router, activity_router_temp
go

CREATE TABLE activity_router (
	parent_part varchar (25) NOT NULL ,
	sequence numeric(5, 0) NOT NULL ,
	code varchar (25) NOT NULL ,
	part varchar (25) NULL ,
	notes varchar (255) NULL ,
	labor varchar (25) NULL ,
	material char (1) NULL ,
	cost_bill char (1) NULL ,
	group_location varchar (10) NULL ,
	process varchar (25) NULL ,
	doc1 varchar (35) NULL ,
	doc2 varchar (35) NULL ,
	doc3 varchar (35) NULL ,
	doc4 varchar (35) NULL ,
	cost numeric(20, 6) NULL ,
	price numeric(20, 6) NULL ,
	cost_price_factor numeric(20, 6) NULL ,
	time_stamp datetime NULL 
)
GO

alter table activity_router add primary key(parent_part,sequence)
go

if exists ( select 1 from dbo.sysobjects where name = 'activity_router_temp' )
begin
	execute ( '
	insert into activity_router ( parent_part,sequence,code,part,notes,labor,material,cost_bill,group_location,process,doc1,doc2,doc3,doc4,cost,price,cost_price_factor,time_stamp )
		select parent_part,sequence,code,part,notes,labor,material,cost_bill,group_location,process,doc1,doc2,doc3,doc4,cost,price,cost_price_factor,time_stamp from activity_router_temp
	' )
	
	execute ( '
	drop table activity_router_temp
	' )
end
go



print'
----------------------------
-- alternative_parts changes
----------------------------
'
if 	not exists ( select 1 from dbo.systypes st,dbo.syscolumns sc,dbo.sysobjects so where so.name = 'alternative_parts' and sc.id = so.id and sc.name = 'main_part' and st.usertype = sc.usertype and st.name = 'varchar' ) or
	not exists ( select 1 from dbo.systypes st,dbo.syscolumns sc,dbo.sysobjects so where so.name = 'alternative_parts' and sc.id = so.id and sc.name = 'alt_part' and st.usertype = sc.usertype and st.name = 'varchar' )
begin
	if exists ( select 1 from dbo.sysobjects where name = 'alternative_parts' )
		execute sp_rename alternative_parts, alternative_parts_temp
	
	execute ( '
		create table alternative_parts (	
			main_part varchar(25) not null, 
			alt_part varchar(25) not null
		)
	' )
	
	if exists ( select 1 from dbo.sysobjects where name = 'alternative_parts_temp' )
	begin
		execute ( '
			insert into alternative_parts ( main_part, alt_part ) 
				select	main_part, alt_part
		   		from 	alternative_parts_temp 
	    ' )
	
		execute ( '
			drop table alternative_parts_temp
		' )
	end

	alter table alternative_parts add primary key ( main_part, alt_part ) 
end      

go


print'
----------------------
-- audit_trail changes
----------------------
'
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'audit_trail' and sc.id = so.id and sc.name = 'dimension_qty_string' )
	alter table audit_trail add dimension_qty_string varchar(50) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'audit_trail' and sc.id = so.id and sc.name = 'dim_qty_string_other' )
	alter table audit_trail add dim_qty_string_other varchar(50) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'audit_trail' and sc.id = so.id and sc.name = 'varying_dimension_code' )
	alter table audit_trail add varying_dimension_code numeric(2) null
go

begin
	create table #temp_indexes
	(
		index_name		varchar(125),
		index_description	varchar(125),
		index_keys		varchar(125)
	)

	insert into #temp_indexes
	execute sp_helpindex audit_trail

	if not exists ( select 1 from #temp_indexes where index_keys = 'shipper' )
		CREATE  INDEX audit_trail_shipper_ix ON audit_trail(shipper)

	if not exists ( select 1 from #temp_indexes where index_keys like '%workorder%' and index_keys like '%type%' )
		CREATE  INDEX audit_trail_workorder_type_ix ON dbo.audit_trail(workorder, type) WITH  FILLFACTOR = 90

	if not exists ( select 1 from #temp_indexes where index_keys like '%date_stamp%' and index_keys like '%type%' )
		CREATE  INDEX date_type ON dbo.audit_trail(date_stamp, type) WITH  FILLFACTOR = 90

	if not exists ( select 1 from #temp_indexes where index_keys like '%part%' and index_keys like '%type%' and index_keys like '%to_loc%' )
		CREATE  INDEX part_type_to ON dbo.audit_trail(part, type, to_loc) WITH  FILLFACTOR = 90

	if not exists ( select 1 from #temp_indexes where index_keys like '%posted%' and index_keys like '%type%' )
		CREATE  INDEX type_for_objhist_u ON dbo.audit_trail(type, posted)

	drop table #temp_indexes
end
go


print'
-------------------------
-- bill_of_lading changes
-------------------------
'
if not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'bill_of_lading' and sc.id = so.id and sc.name = 'destination' and sc.length = 20 ) or
   not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'bill_of_lading' and sc.id = so.id and sc.name = 'scac_transfer' and sc.length = 35 ) or
   not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'bill_of_lading' and sc.id = so.id and sc.name = 'scac_pickup' and sc.length = 35 )
begin
	if exists ( select 1 from dbo.sysobjects where name = 'bill_of_lading' )
		execute sp_rename bill_of_lading, bill_of_lading_temp
	
	execute ( '
	CREATE TABLE bill_of_lading 
	(
		bol_number int NOT NULL ,
		scac_transfer varchar (35) NULL ,
		scac_pickup varchar (35) NULL ,
		trans_mode varchar (10) NULL ,
		equipment_initial varchar (10) NULL ,
		equipment_description varchar (10) NULL ,
		status char (1) NULL ,
		printed char (1) NULL ,
		gross_weight numeric(7, 2) NULL ,
		net_weight numeric(7, 2) NULL ,
		tare_weight numeric(7, 2) NULL ,
		destination varchar (20) NULL ,
		lading_quantity numeric(20, 6) NULL ,
		total_boxes numeric(20, 6) NULL
	)
	' )
	
	execute ( '
	alter table bill_of_lading add primary key ( bol_number )
	' )
	
	if exists ( select 1 from dbo.sysobjects where name = 'bill_of_lading_temp' )
	begin
		execute ( '
		insert into bill_of_lading ( bol_number, scac_transfer, scac_pickup, trans_mode, equipment_initial, equipment_description, status, printed, gross_weight, net_weight, tare_weight, destination, lading_quantity, total_boxes )
			select bol_number, scac_transfer, scac_pickup, trans_mode, equipment_initial, equipment_description, status, printed, gross_weight, net_weight, tare_weight, destination, lading_quantity, total_boxes from bill_of_lading_temp
		' )
		
		execute ( '
		drop table bill_of_lading_temp
		' )
	end
end
go


print'
---------------------------------------------------
-- bill_of_material --> bill_of_material_ec changes
---------------------------------------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'bill_of_material_ec' )
begin
	execute ( '
		create table bill_of_material_ec (
		       parent_part          varchar(25) not null,
		       part                 varchar(25) not null,
		       start_datetime       datetime not null,
		       end_datetime         datetime null,
		       type                 char(1) not null,
		       quantity             numeric(20,6) not null,
		       unit_measure         varchar(2) not null,
		       reference_no         varchar(50) null,
		       std_qty              numeric(20,6) null,
		       scrap_factor         numeric(20,6) not null,
		       engineering_level    varchar(10) null,
		       operator             varchar(5) null,
		       substitute_part      varchar(25) null,
		       date_changed         datetime not null,
		       note                 varchar(255) null
		)
	' )
	
	execute ( '
		alter table bill_of_material_ec
		       add primary key (parent_part, part, start_datetime)
	' )
	
	execute ( '
		insert into bill_of_material_ec (parent_part, part, start_datetime,
		    end_datetime, type, quantity, unit_measure, reference_no, std_qty,
		    scrap_factor, engineering_level, operator, substitute_part, date_changed,
		    note) 
		select parent_part, part, convert(varchar(10),getdate(),111)+
			" "+convert(varchar(2),datepart(hh,getdate()))+":"+convert(varchar(2),
			datepart(mi,getdate()))+":"+convert(varchar(2),datepart(ss,getdate())),null,
			type,quantity,unit_measure,reference_no,std_qty, 0, null, null, "N", getdate(),null
			from bill_of_material
	' )

	execute ( '
		drop table bill_of_material
	' )
	
	execute ( '
		update 	bill_of_material_ec set
			std_qty = isnull((	select	conversion
			            		from 	unit_conversion uc,
		    		        		 	part_unit_conversion puc
		            			where 	puc.part = bill_of_material_ec.part and
		            				  	puc.code = uc.code and
		            		  			unit1 = bill_of_material_ec.unit_measure and
				            		 	unit2 = ( select standard_unit from part_inventory where part = bill_of_material_ec.part ) ),1) * isnull(bill_of_material_ec.quantity,1)
	' )
end

go


print'
------------------
-- carrier changes
------------------
'
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'carrier' and sc.id = so.id and sc.name = 'phone' )
	alter table carrier add phone varchar(20) null
go



print'
------------------
-- contact changes
------------------
'
if 	exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'contact' and sc.id = so.id and sc.name = 'address_1' ) or
	exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'contact' and sc.id = so.id and sc.name = 'address_2' ) or
	exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'contact' and sc.id = so.id and sc.name = 'address_3' ) or
	not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'contact' and sc.id = so.id and sc.name = 'phone' and sc.length = 20 ) or
	not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'contact' and sc.id = so.id and sc.name = 'customer' ) or
	not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'contact' and sc.id = so.id and sc.name = 'destination' ) or
	not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'contact' and sc.id = so.id and sc.name = 'vendor' )
begin

	if exists ( select 1 from dbo.sysobjects where name = 'contact' )
		execute sp_rename contact, contact_temp
	
	execute ( '
		create table contact
		(
			name      		varchar(35) not null,
		 	title     		varchar(35) null,
		 	notes     		varchar(255) null,
		 	company         varchar(35) null,
		 	phone     		varchar(20) null,
		 	company_id      varchar(10) null,
		 	fax_number      varchar(20) null,
		 	email1          varchar(255) null,
		 	email2          varchar(255) null,
		 	customer	varchar(10) null,
		 	destination	varchar(20) null,
		 	vendor		varchar(10) null
		)
	' )
	
	if exists ( select 1 from dbo.sysobjects where name = 'contact_temp' )
	begin

		declare @column_list varchar(255),
				@column varchar(100)

		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
					dbo.syscolumns sc
			where	so.name = 'contact_temp' and
					so.id = sc.id and
					sc.name not in ( 'address_1','address_2','address_3','phone' )

		select @column_list = ''

		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			if isnull(@column_list,'') > ''
				select @column_list = @column_list + ',' + @column
			else
				select @column_list = @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list

		execute ( '
			insert into contact ( phone,' + @column_list + ' ) 
				select	convert(varchar(20),phone),' + @column_list + '
		   		from 	contact_temp 
		' )

		execute ( '
			drop table contact_temp
		' )
	end
	
	alter table contact add primary key (name)
end
else 
begin
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'contact' and sc.id = so.id and sc.name = 'fax_number' )
		alter table contact add fax_number varchar(20) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'contact' and sc.id = so.id and sc.name = 'email1' )
		alter table contact add email1 varchar(255) null

	if not exists (	select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'contact' and sc.id = so.id and sc.name = 'email2' )
		alter table contact add email2 varchar(255) null

	if not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'contact' and sc.id = so.id and sc.name = 'customer' )
		alter table contact add customer varchar(10) null
	
	if not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'contact' and sc.id = so.id and sc.name = 'destination' )
		alter table contact add destination varchar(20) null
	
	if not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'contact' and sc.id = so.id and sc.name = 'vendor' )
		alter table contact add vendor varchar(10) null
end
go

print'
------------------------------------------------
-- Update contact with data from contact_xref --
------------------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'contact_xref' )
	execute ( '
	update	contact
	set	contact.customer = contact_xref.customer,
		contact.destination = contact_xref.destination,
		contact.vendor = contact_xref.vendor
	from	contact_xref
	where	contact_xref.contact = contact.name
	' )
go


print'
---------------------------------------
-- Drop obsolete tables for contacts --
---------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'contact_grid' )
	drop table contact_grid
go

if exists ( select 1 from dbo.sysobjects where name = 'contact_log' )
	drop table contact_log
go

if exists ( select 1 from dbo.sysobjects where name = 'contact_xref' )
	drop table contact_xref
go




print'
---------------------------
-- contact_call_log changes
---------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'contact_call_log' )
	execute sp_rename contact_call_log, contact_call_log_temp
go
	
create table contact_call_log
(
	contact         varchar(35) not null,
	start_date      datetime not null,
	call_subject    varchar(100) not null,
	call_content    text not null,
	stop_date       datetime null
)
go
	
alter table contact_call_log add primary key (contact, start_date)
go
	
if exists ( select 1 from dbo.sysobjects where name = 'contact_call_log_temp' )
begin
	declare @column_list varchar(255),
			@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
			dbo.syscolumns sc
		where	so.name = 'contact_call_log_temp' and
			so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into contact_call_log ( ' + @column_list + ' ) 
			select	' + @column_list + '
	   		from 	contact_call_log_temp 
	' )

	execute ( '
		drop table contact_call_log_temp
	' )
end
go


print'
-----------------------
-- contact_xref changes
-----------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'contact_xref' )
	execute sp_rename contact_xref, contact_xref_temp
go

create table contact_xref (
	contact              varchar(50) not null,
	customer             varchar(10) not null,
	destination          varchar(20) not null,
	vendor               varchar(10) not null
)
go

if exists ( select 1 from dbo.sysobjects where name = 'contact_xref_temp' )
begin
	declare @column_list varchar(255),
			@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
				dbo.syscolumns sc
		where	so.name = 'contact_xref_temp' and
				so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into contact_xref ( ' + @column_list + ' ) 
			select	' + @column_list + '
	   		from 	contact_xref_temp 
    ' )
		
	execute ( '
		drop table contact_xref_temp
	' )
end
go


print'
------------------------------
-- currency_conversion changes
------------------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'currency_conversion' )
begin
	execute ( '
		create table currency_conversion (
			currency_code varchar(10) not null,
			rate decimal (20,6) not null,
			effective_date datetime not null,
			currency_display_symbol varchar (10) null 
		)
	' )

	execute ( '	
		alter table currency_conversion add primary key ( currency_code, effective_date )
	' )
end
go

if not exists ( select 1 from currency_conversion where currency_code = 'USD' )
	insert into currency_conversion ( currency_code, rate, effective_date, currency_display_symbol )
		values ( 'USD', 1, GetDate(), '$' )
go


print'
--------------------------
-- custom_pbl_link changes
--------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'custom_pbl_link' )
	execute sp_rename custom_pbl_link, custom_pbl_link_temp
go

create table custom_pbl_link (
	button_text          varchar(15) not null,
	menu_text            varchar(25) not null,
	module               varchar(25) not null,
	mdi_microhelp        varchar(254) null,
	open_window          varchar(254) null,
	type                 varchar(254) null,
	command_line         varchar(254) null,
	sql_script           varchar(254) null,
	button_pic           varchar(254) null
)
go

alter table custom_pbl_link
       add primary key (module)
go

if exists ( select 1 from dbo.sysobjects where name = 'custom_pbl_link_temp' )
begin
	execute ( '
		insert into custom_pbl_link (button_text, menu_text, module, mdi_microhelp, 
			open_window, type, command_line, sql_script, button_pic) 
		select button_text,	menu_text, module, mdi_microhelp, open_window, type, command_line, 
			sql_script, button_pic from custom_pbl_link_temp
	' )
		
	execute ( '
		drop table custom_pbl_link_temp
	' )		
end
go



print'
-------------------      
-- customer changes
-------------------      
'
if exists ( select 1 from dbo.sysobjects where name = 'customer_backup' )
	drop table customer_backup
go

if not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'customer' and sc.id = so.id and sc.name = 'phone' and sc.length = 20 ) or
   not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'origin_code' ) or
   not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'sales_manager_code' ) or
   not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'region_code' ) or 
   exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'sales_manager' ) or
   not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'customer' and sc.id = so.id and sc.name = 'modem' and sc.length = 20 ) or
   not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'customer' and sc.id = so.id and sc.name = 'fax' and sc.length = 20 )
begin
	-- drop customer_additional's foreign key pointing to primary key of customer
	declare	@fkname	varchar(100),
			@command varchar(255),
			@table varchar(255)
	
	declare fks cursor for
		select	so1.name,
				so2.name
		from 	dbo.sysreferences sr, 
				dbo.sysobjects so1, 
				dbo.sysobjects so2,
				dbo.sysobjects so3
		where  	sr.fkeyid = so1.id and
				so2.id = sr.constid and
				sr.rkeyid = so3.id and
				so3.name = 'customer'
	open fks
	fetch fks into @table,@fkname
	while ( @@fetch_status = 0 )
	begin
		select @command = 'alter table ' + @table + ' drop constraint ' + @fkname
		execute ( @command )
		fetch fks into @table,@fkname
	end
	close fks
	deallocate fks
	
	if exists ( select 1 from dbo.sysobjects where name = 'customer' )
		execute sp_rename customer, customer_backup
	
	if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where sc.id = so.id and so.name = 'customer_backup' and sc.name = 'empower_flag' )
		execute ( '
		create table customer (
			customer varchar (10) not null ,
			name varchar (50) not null ,
			address_1 varchar (50) null ,
			address_2 varchar (50) null ,
			address_3 varchar (50) null ,
			phone varchar (20) null ,
			fax varchar (20) null ,
			modem varchar (20) null ,
			contact varchar (35) null ,
			profile varchar (255) null ,
			company varchar (10) null ,
			salesrep varchar (10) null ,
			terms varchar (20) null ,
			category varchar (25) null ,
			label_bitmap image null ,
			bitmap_filename varchar (50) null ,
			notes varchar (255) null ,
			create_date datetime null,
			address_4 varchar(40) null,
			address_5 varchar(40) null,
			address_6 varchar(40) null,
			default_currency_unit varchar(3) null,
			show_euro_amount smallint null,
			cs_status varchar(20) null,
			custom1 varchar(25) null,
			custom2 varchar(25) null,
			custom3 varchar(25) null,
			custom4 varchar(25) null,
			custom5 varchar(25) null,
			origin_code varchar(25) null,
			sales_manager_code varchar(10) null,
			region_code varchar(10) null,
			auto_profile char(1) null,
			check_standard_pack char(1) null,
			empower_flag varchar (8) null  
		)
		' )
	else
		execute ( '
		create table customer (
			customer varchar (10) not null ,
			name varchar (50) not null ,
			address_1 varchar (50) null ,
			address_2 varchar (50) null ,
			address_3 varchar (50) null ,
			phone varchar (20) null ,
			fax varchar (20) null ,
			modem varchar (20) null ,
			contact varchar (35) null ,
			profile varchar (255) null ,
			company varchar (10) null ,
			salesrep varchar (10) null ,
			terms varchar (20) null ,
			category varchar (25) null ,
			label_bitmap image null ,
			bitmap_filename varchar (50) null ,
			notes varchar (255) null ,
			create_date datetime null,
			address_4 varchar(40) null,
			address_5 varchar(40) null,
			address_6 varchar(40) null,
			default_currency_unit varchar(3) null,
			show_euro_amount smallint null,
			cs_status varchar(20) null,
			custom1 varchar(25) null,
			custom2 varchar(25) null,
			custom3 varchar(25) null,
			custom4 varchar(25) null,
			custom5 varchar(25) null,
			origin_code varchar(25) null,
			sales_manager_code varchar(10) null,
			region_code varchar(10) null,
			auto_profile char(1) null,
			check_standard_pack char(1) null
		)
		' )
	
	alter table customer add primary key ( customer )
	
	if exists ( select 1 from dbo.sysobjects where name = 'customer_backup' )
	begin
		-- generate column list from system tables for backup table
		-- (make sure to exclude deleted columns)
		declare @column_list1 varchar(255),
			@column_list2 varchar(255),
			@column varchar(100)
			
		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
				dbo.syscolumns sc
			where	so.name = 'customer_backup' and
				so.id = sc.id
	
		select @column_list1 = ''
		select @column_list2 = ''
		
		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			if @column_list1 > ''
			begin
				if 	( select datalength ( @column_list1 ) ) >= 255 or
					( select datalength ( @column_list1 ) + datalength ( @column ) + 1 ) >= 255
				begin
					if @column_list2 > ''
						select @column_list2 = @column_list2 + ',' + @column
					else
						select @column_list2 = ',' + @column
				end
				else
					select @column_list1 = @column_list1 + ',' + @column
			end
			else
				select @column_list1 = @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list

		execute ( 'insert into customer ( ' + @column_list1 + @column_list2 + ' ) select ' + @column_list1 + @column_list2 + ' from customer_backup' )

		execute ( '
		drop table customer_backup
		' )
	end
		
	alter table customer_additional
		add foreign key (customer)
	        references customer
end
else
begin 
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'notes' )
		alter table customer add notes varchar(255) null
		
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'create_date' )
		alter table customer add create_date datetime null
		
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'address_4' )
		alter table customer add address_4 varchar(40) null
		
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'address_5' )
		alter table customer add address_5 varchar(40) null
		
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'address_6' )
		alter table customer add address_6 varchar(40) null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'default_currency_unit' )
		alter table customer add default_currency_unit varchar(3) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'show_euro_amount' )
		alter table customer add show_euro_amount smallint null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'cs_status' )
		alter table customer add cs_status varchar(20) null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'custom1' )
		alter table customer add custom1 varchar(25) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'custom2' )
		alter table customer add custom2 varchar(25) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'custom3' )
		alter table customer add custom3 varchar(25) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'custom4' )
		alter table customer add custom4 varchar(25) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'custom5' )
		alter table customer add custom5 varchar(25) null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'origin_code' )
		alter table customer add origin_code varchar (25) null  
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'sales_manager_code' )
		alter table customer add sales_manager_code varchar (10) null  
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'region_code' )
		alter table customer add region_code varchar (10) null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'auto_profile' )
	begin
		alter table customer add auto_profile char(1) null
		execute ( '
		update customer set auto_profile = "N"
		' )
	end
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer' and sc.id = so.id and sc.name = 'check_standard_pack' )
	begin
		alter table customer add check_standard_pack char(1) null
		execute ( '
		update customer set check_standard_pack = "N"
		' )
	end
end

go


print'
-------------------------------
-- customer_origin_code changes
-------------------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'customer_origin_code' )
	execute ( '
	create table customer_origin_code ( 
		code varchar(25) Not null , 
		description varchar(50) null , 
		Primary key ( code ) )
	' )
go


print'
----------------------------------
-- customer_service_status changes
----------------------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'customer_service_status' )
begin
	execute ( '
		create table customer_service_status 
		(
		 status_name  varchar(20) not null,
		 status_type  varchar(1) not null,
		 default_value varchar(1) not null
		)
	' )

	execute ( '
		alter table customer_service_status add primary key (status_name) 
	' )
end
go

if not exists ( select 1 from customer_service_status where status_name = 'Approved' )
	insert into customer_service_status ( status_name, status_type, default_value )
		values ( 'Approved','A','Y' )
go

if not exists ( select 1 from customer_service_status where status_name = 'Closed' )
	insert into customer_service_status ( status_name, status_type, default_value )
		values ( 'Closed','C','N' )
go

if not exists ( select 1 from customer_service_status where status_name = 'Hold' )
	insert into customer_service_status ( status_name, status_type, default_value )
		values ( 'Hold','H','N' )
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_customer_u' )
	drop trigger mtr_customer_u
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_destination_u' )
	drop trigger mtr_destination_u
go

update customer set cs_status = css.status_name
from customer_service_status css
where customer.cs_status is null and
	css.default_value = 'Y'
go


print'
---------------------------
-- database_changes changes
---------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'database_changes' )
	drop table database_changes
go


print'
-----------------------
-- defect_codes changes
-----------------------
'
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'defect_codes' and sc.id = so.id and sc.name = 'code_group' )
	alter table defect_codes add code_group varchar(25) null
go


print'
------------------
-- defects changes
------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'defects' )
	execute sp_rename defects, defects_temp
go

create table defects (
       machine              varchar(10) not null,
       part                 varchar(25) not null,
       reason               varchar(20) null,
       quantity             numeric(20,6) null,
       operator             varchar(10) null,
       shift                char(1) null,
       work_order           varchar(10) null,
       data_source          varchar(10) null,
       defect_date          datetime not null,
       defect_time          datetime not null
)
go

alter table defects
       add primary key (machine, defect_date, defect_time)
go

if exists ( select 1 from dbo.sysobjects where name = 'defects_temp' )
begin
	execute ( '
		insert into defects (machine, part, reason, quantity, operator, shift, 
		    work_order, data_source, defect_date, defect_time) select machine, part, reason, convert(numeric(20,6)
		    ,quantity), operator, shift, work_order, data_source, defect_date, defect_time from 
		    defects_temp
	' )

	execute ( '
		drop table defects_temp
	' )
end
go

print'
----------------------      
-- destination changes
----------------------      
'
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'destination' and sc.id = so.id and sc.name = 'gl_segment' )
	alter table destination add gl_segment           varchar(50) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'destination' and sc.id = so.id and sc.name = 'address_4' )
	alter table destination add address_4 varchar(40) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'destination' and sc.id = so.id and sc.name = 'address_5' )
	alter table destination add	address_5 varchar(40) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'destination' and sc.id = so.id and sc.name = 'address_6' )
	alter table destination add	address_6 varchar(40) null      
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'destination' and sc.id = so.id and sc.name = 'default_currency_unit' )
	alter table destination add default_currency_unit varchar(3) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'destination' and sc.id = so.id and sc.name = 'show_euro_amount' )
	alter table destination add show_euro_amount smallint null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'destination' and sc.id = so.id and sc.name = 'cs_status' )
	alter table destination add cs_status varchar(20) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'destination' and sc.id = so.id and sc.name = 'region_code' )
	alter table destination add region_code varchar(10) Null
go

update destination set cs_status = css.status_name
from customer_service_status css
where destination.cs_status is null and
	css.default_value = 'Y'
go


print'
-------------------------------
-- destination_shipping changes
-------------------------------
'
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where sc.id = so.id and so.name = 'destination_shipping' and sc.name = 'allow_overstage' )
	alter table destination_shipping add allow_overstage char(1) null
go


print'
-----------------------
-- dim_relation changes
-----------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'dim_relation' )
	execute sp_rename dim_relation, dim_relation_temp
go

create table dim_relation (
       dim_code             varchar(2) not null,
       dimension            varchar(10) null,
       delete_flag          varchar(1) null,
       dim_qty              numeric(9,3) null,
       relationship         varchar(254) null
)
go

alter table dim_relation
       add primary key (dim_code)
go

if exists ( select 1 from dbo.sysobjects where name = 'dim_relation_temp' )
begin
	declare @column_list varchar(255),
			@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
				dbo.syscolumns sc
		where	so.name = 'dim_relation_temp' and
				so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into dim_relation ( ' + @column_list + ' ) 
			select	' + @column_list + '
	   		from 	dim_relation_temp 
    ' )
	
	execute ( '
		drop table dim_relation_temp
	' )
end
go


print'
---------------------
-- dimensions changes
---------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'dimensions' )
	execute sp_rename dimensions, dimensions_temp
go

create table dimensions (
	dim_code varchar (2) not null ,
	dimension varchar (10) not null ,
	delete_flag varchar (1) null ,
	dim_qty numeric(9, 3) null ,
	varying_dimension numeric(1, 0) null 
)
go

alter table dimensions
       add primary key (dim_code, dimension)
go

if exists ( select 1 from dbo.sysobjects where name = 'dimensions_temp' )
begin
	declare @column_list varchar(255),
			@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
				dbo.syscolumns sc
		where	so.name = 'dimensions_temp' and
				so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into dimensions ( ' + @column_list + ' ) 
			select	' + @column_list + '
	   		from 	dimensions_temp 
    ' )
	
	execute ( '
		drop table dimensions_temp
	' )
end
go


print'
-------------------
-- downtime changes
-------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'downtime' )
	execute sp_rename downtime, downtime_temp
go

create table downtime (
       trans_date           datetime not null,
       machine              varchar(10) not null,
       reason_code          varchar(10) null,
       reason_name          varchar(35) null,
       down_time            numeric(20,6) null,
       notes                varchar(255) null,
       employee             varchar(10) null,
       shift                char(1) null,
       job                  varchar(10) null,
       part                 varchar(15) null,
       qty                  numeric(20,6) null,
       type                 char(1) null,
       production_pointer   varchar(10) null,
       data_source          varchar(10) null,
       trans_time           datetime not null
)
go

alter table downtime
       add primary key (trans_date, machine, trans_time)
go

if exists ( select 1 from dbo.sysobjects where name = 'downtime_temp' )
begin
	execute ( '
		insert into downtime (trans_date, machine, reason_code, reason_name, down_time, notes, 
		    employee, shift, job, part, qty, type, production_pointer, data_source, trans_time) 
		    select trans_date, machine, reason_code, reason_name, convert(numeric(20,6),down_time), 
		    notes, employee, shift, job, part, convert(numeric(20,6),qty), type, 
		    production_pointer, data_source, trans_time from downtime_temp
	' )
	
	execute ( '
		drop table downtime_temp
	' )
end
go



print'
-------------------------
-- downtime_codes changes
-------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('downtime_codes'))
	execute sp_rename downtime_codes, downtime_codes_tmp
go

if not exists (select * from dbo.sysobjects where id = object_id('downtime_codes'))
	execute ( '
	CREATE TABLE downtime_codes (
		dt_code varchar (10) NOT NULL ,
		code_group varchar (25) NULL ,
		code_description varchar (35)NULL,
		primary key ( dt_code )
	)
	' )
go

if exists ( select 1 from dbo.sysobjects where name = 'downtime_codes_tmp' )
begin
	execute ( '
	insert into downtime_codes ( dt_code, code_group, code_description )
	select dt_code, code_group, code_description from  downtime_codes_tmp
	' )
	if @@error = 0
		execute ( '
		drop table downtime_codes_tmp
		' )
end
go



print '
---------------------------
-- dw_inquiry_files changes
---------------------------
'

if not exists ( select 1 from dw_inquiry_files where datawindow_name = 'd_unprinted_invoices' )
	insert into dw_inquiry_files (
		datawindow_name,
		screen_title,
		table_name,
		primary_column,
		change_buttons,
		chain_parameter,
		window_chain,
		accept_args,
		sequence,
		retrieve_all,
		modifiable,
		print_button,
		auto_number_on_add,
		graph_chain,
		secondary_column,
		append_title,
		utility_1,
		utility_2,
		util_1_text,
		util_1_icon,
		util_2_text,
		util_2_icon,
		primary_column_3,
		primary_column_4,
		primary_column_5,
		key_other_than_primary,
		normal_open_dblclk,
		parm_field_on_add,
		number_on_retrieve,
		add_chain,
		util1_parameter,
		util2_parameter,
		normal_open_on_add,
		normal_open_with_parm,
		dummy_col )
	VALUES ('d_unprinted_invoices','Invoice Inquiry','shipper','invoice_number','Y',null,'w_invoice_detail','N',
			1,'Y','N','Y','Y',null,'SHIPPER','N',null,null,null,null,null,null,null,null,null,null,'Y',null,'Y','w_invoice_detail',null,null,'Y','N',null)
go

if not exists ( select 1 from dw_inquiry_files where datawindow_name = 'd_po_inquiry' )
	insert into dw_inquiry_files (
		datawindow_name,
		screen_title,
		table_name,
		primary_column,
		change_buttons,
		chain_parameter,
		window_chain,
		accept_args,
		sequence,
		retrieve_all,
		modifiable,
		print_button,
		auto_number_on_add,
		graph_chain,
		secondary_column,
		append_title,
		utility_1,
		utility_2,
		util_1_text,
		util_1_icon,
		util_2_text,
		util_2_icon,
		primary_column_3,
		primary_column_4,
		primary_column_5,
		key_other_than_primary,
		normal_open_dblclk,
		parm_field_on_add,
		number_on_retrieve,
		add_chain,
		util1_parameter,
		util2_parameter,
		normal_open_on_add,
		normal_open_with_parm,
		dummy_col )
	values ('d_po_inquiry','PO Inquiry','po_header','po_number','Y',NULL,'w_po_inquiry','N',
		1,'Y','N','Y','Y',NULL,'PO_HEADER','N',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Y',NULL,'Y','w_po_inquiry',NULL,NULL,'Y','N',NULL)
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'dw_inquiry_files' and sc.id = so.id and sc.name = 'default_operator' )
	alter table dw_inquiry_files add default_operator varchar(10) null
go

update 	dw_inquiry_files
set	default_operator = '='
where	default_operator is null
go

if not exists ( select 1 from dw_inquiry_files where datawindow_name = 'Customer Search' )
	insert into dw_inquiry_files ( datawindow_name, primary_column, default_operator, table_name ) values ( 'Customer Search', 'customer', '=', '' )
go

if not exists ( select 1 from dw_inquiry_files where datawindow_name = 'Quote Search' )
	insert into dw_inquiry_files ( datawindow_name, primary_column, default_operator, table_name  ) values ( 'Quote Search', 'quote_number', '=', '' )
go

if not exists ( select 1 from dw_inquiry_files where datawindow_name = 'Sales Order Search' )
	insert into dw_inquiry_files ( datawindow_name, primary_column, default_operator, table_name  ) values ( 'Sales Order Search', 'order_no', '=', '' )
go

if not exists ( select 1 from dw_inquiry_files where datawindow_name = 'Ship Schedule Search' )
	insert into dw_inquiry_files ( datawindow_name, primary_column, default_operator, table_name  ) values ( 'Ship Schedule Search', 'id', '=', '' )
go

if not exists ( select 1 from dw_inquiry_files where datawindow_name = 'Ship History Search' )
	insert into dw_inquiry_files ( datawindow_name, primary_column, default_operator, table_name  ) values ( 'Ship History Search', 'id', '=', '' )
go

if not exists ( select 1 from dw_inquiry_files where datawindow_name = 'Invoice Search' )
	insert into dw_inquiry_files ( datawindow_name, primary_column, default_operator, table_name  ) values ( 'Invoice Search', 'invoice_number', '=', '' )
go

if not exists ( select 1 from dw_inquiry_files where datawindow_name = 'Issue Search' )
	insert into dw_inquiry_files ( datawindow_name, primary_column, default_operator, table_name  ) values ( 'Issue Search', 'issue_number', '=', '' )
go

if not exists ( select 1 from dw_inquiry_files where datawindow_name = 'Contact Search' )
	insert into dw_inquiry_files ( datawindow_name, primary_column, default_operator, table_name  ) values ( 'Contact Search', 'name', '=', '' )
go

if not exists ( select 1 from dw_inquiry_files where datawindow_name = 'Contact Call Log Search' )
	insert into dw_inquiry_files ( datawindow_name, primary_column, default_operator, table_name  ) values ( 'Contact Call Log Search', 'contact', '=', '' )
go

if not exists ( select 1 from dw_inquiry_files where datawindow_name = 'RMAs Search' )
	insert into dw_inquiry_files ( datawindow_name, primary_column, default_operator, table_name  ) values ( 'RMAs Search', 'id', '=', '' )
go

if not exists ( select 1 from dw_inquiry_files where datawindow_name = 'd_part_inquiry_ct' )
	insert into dw_inquiry_files(datawindow_name, screen_title, table_name, primary_column, change_buttons, chain_parameter, window_chain, accept_args,sequence, retrieve_all, modifiable, print_button, auto_number_on_add, graph_chain,secondary_column, append_title, utility_1, utility_2, util_1_text,util_1_icon, util_2_text, util_2_icon,primary_column_3,primary_column_4,primary_column_5, key_other_than_primary, normal_open_dblclk,parm_field_on_add,number_on_retrieve, add_chain, util1_parameter,util2_parameter, normal_open_on_add, normal_open_with_parm,dummy_col,default_operator) 
	values ('d_part_inquiry_ct','Part Inquiry','part','part','Y',NULL,'w_cost_main','N',
		1,'N','N','Y','Y',NULL,NULL,'N',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Y',NULL,'Y','w_cost_main',NULL,NULL,'Y','N',NULL,'=')
go

if not exists ( select 1 from dw_inquiry_files where datawindow_name = 'd_requisition_inquiry' )
	insert into dw_inquiry_files (
		datawindow_name,
		screen_title,
		table_name,
		primary_column,
		change_buttons,
		chain_parameter,
		window_chain,
		accept_args,
		sequence,
		retrieve_all,
		modifiable,
		print_button,
		auto_number_on_add,
		graph_chain,
		secondary_column,
		append_title,
		utility_1,
		utility_2,
		util_1_text,
		util_1_icon,
		util_2_text,
		util_2_icon,
		primary_column_3,
		primary_column_4,
		primary_column_5,
		key_other_than_primary,
		normal_open_dblclk,
		parm_field_on_add,
		number_on_retrieve,
		add_chain,
		util1_parameter,
		util2_parameter,
		normal_open_on_add,
		normal_open_with_parm,
		dummy_col )
		values (
		'd_requisition_inquiry',
		'Requisition Inquiry',
		'requisition_header',
		'requisition_number',
		'N',
		null,
		'w_requisition',
		'N',
		1,
		'Y',
		'N',
		'Y',
		'N',
		null,
		null,
		'N',
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		'N',
		null,
		'Y',
		null,
		null,
		null,
		'Y',
		'Y',
		null)

go


print'
------------------------
-- edi_ff_layout changes
------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'edi_ff_layout' )
	execute sp_rename edi_ff_layout, edi_ff_layout_temp
go

create table edi_ff_layout (
	transaction_set char (3) not null ,
	overlay_group char (3) not null ,
	line char (2) not null ,
	field char (2) not null ,
	field_description varchar (25) not null ,
	data_type char (2) not null ,
	position int not null ,
	length int not null ,
	segment varchar (6) null ,
	description varchar (25) not null ,
	version varchar (6) not null ,
	version_date datetime not null
)
go

alter table edi_ff_layout add primary key
	(	transaction_set,
		overlay_group,
		line,
		field )
go

if exists ( select 1 from dbo.sysobjects where name = 'edi_ff_layout_temp' )
begin
	declare @column_list varchar(255),
			@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
				dbo.syscolumns sc
		where	so.name = 'edi_ff_layout_temp' and
				so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into edi_ff_layout ( ' + @column_list + ' ) 
			select	' + @column_list + '
	   		from 	edi_ff_layout_temp 
    ' )
	
	execute ( '
		drop table edi_ff_layout_temp
	' )
end
go


print'
-----------------------
-- edi_ff_loops changes
-----------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'edi_ff_loops' )
	execute sp_rename edi_ff_loops, edi_ff_loops_temp
go

create table edi_ff_loops (
	transaction_set char (3) not null ,
	overlay_group char (3) not null ,
	line int not null ,
	max_loops int not null ,
	loop_line int null ,
	line_name varchar (25) null ,
	loop_name varchar (25) null ,
	used char (1) null ,
	loop_used char (1) null
)
go

alter table edi_ff_loops
       add primary key (transaction_set, overlay_group, line)
go

if exists ( select 1 from dbo.sysobjects where name = 'edi_ff_loops_temp' )
begin
	declare @column_list varchar(255),
		@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
			dbo.syscolumns sc
		where	so.name = 'edi_ff_loops_temp' and
			so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list


	execute ( '
		insert into edi_ff_loops ( ' + @column_list + ' ) 
			select	' + @column_list + '
	   		from 	edi_ff_loops_temp 
	' )
	
	execute ( '
		drop table edi_ff_loops_temp
	' )
end
go


print'
----------------------------------
-- effective_change_notice changes
----------------------------------
'
if 	not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'effective_change_notice' and sc.id = so.id and sc.name = 'operator' ) or
	exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'effective_change_notice' and sc.id = so.id and sc.name = 'sequence' ) or
	exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'effective_change_notice' and sc.id = so.id and sc.name = 'who' ) or
	exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'effective_change_notice' and sc.id = so.id and sc.name = 'time_stamp' )
begin
	if exists ( select 1 from dbo.sysobjects where name = 'effective_change_notice' )
		execute sp_rename effective_change_notice, effective_change_notice_temp
	
	execute ( '
		create table effective_change_notice (
		       part                 varchar(25) not null,
		       effective_date       datetime not null,
		       operator             varchar(5) not null,
		       notes                varchar(255) null,
		       engineering_level    varchar(10) null
		)
	' )
	
	if exists ( select 1 from dbo.sysobjects where name = 'effective_change_notice_temp' )
	begin
		declare @column_list varchar(255),
				@column varchar(100)
	
		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
					dbo.syscolumns sc
			where	so.name = 'effective_change_notice_temp' and
					so.id = sc.id and
					sc.name not in ( 'sequence','who','time_stamp' )
	
		select @column_list = ''
	
		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			if isnull(@column_list,'') > ''
				select @column_list = @column_list + ',' + @column
			else
				select @column_list = @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list
	
		if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'effective_change_notice_temp' and sc.id = so.id and sc.name = 'operator' )
			execute ( '
				insert into effective_change_notice ( operator,' + @column_list + ' ) 
					select	"admin",' + @column_list + '
			   		from 	effective_change_notice_temp 
			' )
		else
			execute ( '
				insert into effective_change_notice ( ' + @column_list + ' ) 
					select	' + @column_list + '
			   		from 	effective_change_notice_temp 
			' )
		
		execute ( '
			drop table effective_change_notice_temp
		' )
	end
end
go

begin
	declare @pkname varchar(50)

	select	@pkname = so2.name 
	from 	dbo.sysobjects so1,
		dbo.sysobjects so2,
		dbo.sysconstraints sc 
	where 	so1.name = 'effective_change_notice' and 
		so1.id = sc.id and 
		sc.constid = so2.id

	if isnull(@pkname,'')>''
		execute ( 'alter table effective_change_notice drop constraint ' + @pkname )
end
go

begin
	declare	@count			smallint,
			@part			varchar(25),
			@effective_date	datetime,
			@engineering_level	varchar(10)

	declare duplicates cursor for 
		select 	distinct ecn1.part,
				ecn1.effective_date
		from 	effective_change_notice ecn1
		where	( select count(*) from effective_change_notice ecn2 where ecn2.part = ecn1.part and ecn2.effective_date = ecn1.effective_date ) > 1

	open duplicates
	fetch duplicates into @part, @effective_date
	while ( @@fetch_status = 0 )
	begin
		select	@count = count(*)
		from	effective_change_notice
		where	part = @part and
				effective_date = @effective_date

		while ( @count > 0 )
		begin
			select	@engineering_level = max (engineering_level)
			from	effective_change_notice
			where	part = @part and
					effective_date = @effective_date

			update 	effective_change_notice set
					effective_date = dateadd ( hh,@count,effective_date)
			where 	part = @part and
					effective_date = @effective_date and
					engineering_level = @engineering_level

			select	@count = count(*)
			from	effective_change_notice
			where	part = @part and
					effective_date = @effective_date
		end

		fetch duplicates into @part, @effective_date
	end
	close duplicates
	deallocate duplicates
end
go

alter table effective_change_notice add primary key ( part, effective_date )
go


print'
-------------------
-- employee changes
-------------------
'
if (	select	count(name)
	from 	employee e1
	where 	(	select	count(e2.operator_code) 
			from 	employee e2 
			where 	e2.operator_code = e1.operator_code ) > 1 ) > 1
	print 'Please get rid of any duplicate operator_code values from the employee table and run the employee changes section again.'
else
begin
	if exists ( select 1 from dbo.sysobjects where name = 'employee' )
		execute sp_rename employee, employee_temp
	
	execute ( '
	create table employee (
	       name                 varchar(40) not null,
	       operator_code        varchar(5) not null,
	       password             varchar(5) not null,
	       serial_number        integer null,
	       primary key ( operator_code ),
	       unique ( password )
	)
	' )
	
	if exists ( select 1 from dbo.sysobjects where name = 'employee_temp' )
	begin
		execute ( '
			insert into employee (name, operator_code, password, serial_number) 
				select name, operator_code, password, serial_number from employee_temp
		' )
		
		execute ( '
			drop table employee_temp
		' )
	end
end
go


print'
----------------------------
-- exp_apdata_detail changes
----------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'exp_apdata_detail' )
	execute sp_rename exp_apdata_detail, exp_apdata_detail_temp
go

create table exp_apdata_detail (
       sequence_num         integer null,
       status_code          integer not null,
       trx_ctrl_num         varchar(16) not null,
       trx_type             integer not null,
       sequence_id          integer not null,
       po_ctrl_num          varchar(8) null,
       unit_price           float null,
       amt_freight          float null,
       amt_tax              float null,
       amt_misc             float null,
       gl_exp_acct          varchar(32) not null,
       line_description     varchar(60) null
)
go

alter table exp_apdata_detail
       add primary key (trx_ctrl_num, sequence_id)
go

if exists ( select 1 from dbo.sysobjects where name = 'exp_apdata_detail_temp' )
begin
	execute ( '
		insert into exp_apdata_detail (sequence_num, status_code, trx_ctrl_num, trx_type, sequence_id, 
			po_ctrl_num, unit_price, amt_freight, amt_tax, amt_misc, gl_exp_acct, line_description) select 
		    sequence_num, status_code, trx_ctrl_num, trx_type, sequence_id, po_ctrl_num, unit_price, amt_freight, amt_tax,
		    amt_misc,gl_exp_acct, line_description from exp_apdata_detail_temp
	' )
	
	execute ( '
		drop table exp_apdata_detail_temp
	' )
end
go


print'
----------------------------
-- exp_apdata_header changes
----------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'exp_apdata_header' )
	execute sp_rename exp_apdata_header, exp_apdata_header_temp
go

create table exp_apdata_header (
       sequence_num         integer null,
       status_code          integer null,
       trx_ctrl_num         varchar(16) not null,
       trx_type             integer null,
       doc_ctrl_num         varchar(16) null,
       user_trx_type_code   varchar(8) null,
       batch_code           varchar(16) not null,
       date_applied_j       integer null,
       date_doc_j           integer null,
       vendor_code          varchar(12) null,
       terms_code           varchar(8) null,
       date_applied_d       datetime null,
       date_doc_d           datetime null
)
go

alter table exp_apdata_header
       add primary key (trx_ctrl_num, batch_code)
go

if exists ( select 1 from dbo.sysobjects where name = 'exp_apdata_header_temp' )
begin
	execute ( '
		insert into exp_apdata_header (sequence_num, status_code, trx_ctrl_num, trx_type, 
			doc_ctrl_num, user_trx_type_code, 
		    batch_code, date_applied_j, date_doc_j, vendor_code, terms_code, date_applied_d, date_doc_d)
		    select sequence_num, status_code, trx_ctrl_num, trx_type, doc_ctrl_num, user_trx_type_code, 
		    batch_code, date_applied_j, date_doc_j, vendor_code, terms_code, date_applied_d, date_doc_d from 
		    exp_apdata_header_temp
	' )
	
	execute ( '
		drop table exp_apdata_header_temp
	' )
end
go


print '
----------------------------------
-- freight_type_definition changes
----------------------------------
'
if not exists (select 1 from dbo.sysobjects where id = object_id('freight_type_definition'))
	execute ( '
	create table freight_type_definition (
		type_name	varchar(20) not null primary key
	)
	' )
else if not exists (	select	1 
			from 	dbo.sysobjects so1,
				dbo.sysobjects so2,
				dbo.sysconstraints sc 
			where	so1.name = 'freight_type_definition' and 
				so1.id = sc.id and 
				sc.constid = so2.id )
	alter table freight_type_definition
	       add primary key (type_name)
go


if not exists ( select 1 from freight_type_definition where type_name = 'Collect' )
	insert into freight_type_definition ( type_name )
		values ( 'Collect')
go

if not exists ( select 1 from freight_type_definition where type_name = 'Prepaid' )
	insert into freight_type_definition ( type_name )
		values ( 'Prepaid')
go

if exists ( select 1 from freight_type_definition where type_name = 'Prepaid_billed' )
	delete from freight_type_definition where type_name = 'Prepaid_billed'
go

if not exists ( select 1 from freight_type_definition where type_name = 'Prepaid-Billed' )
	insert into freight_type_definition ( type_name )
		values ( 'Prepaid-Billed')
go

if not exists ( select 1 from freight_type_definition where type_name = 'C.O.D' )
	insert into freight_type_definition ( type_name )
		values ( 'C.O.D')
go

if not exists ( select 1 from freight_type_definition where type_name = 'Third Party Billing' )
	insert into freight_type_definition ( type_name )
		values ( 'Third Party Billing')
go



print'
-----------------------
-- gl_tran_type changes
-----------------------
'
if exists (select 1 from dbo.sysobjects where name = 'gl_tran_type' ) 
	execute sp_rename gl_tran_type, gl_tran_type_temp
go

create table gl_tran_type (
	code varchar (1) not null ,
	name varchar (25) not null
)
go

alter table gl_tran_type add primary key ( code )
go

if exists (select 1 from dbo.sysobjects where name = 'gl_tran_type_temp' ) 
begin
	declare @column_list varchar(255),
			@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
				dbo.syscolumns sc
		where	so.name = 'gl_tran_type_temp' and
				so.id = sc.id 

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into gl_tran_type ( ' + @column_list + ' ) 
			select	' + @column_list + '
	   		from 	gl_tran_type_temp 
    ' )
	
	execute ( '
		drop table gl_tran_type_temp
	' )
end
go

DELETE FROM gl_tran_type
GO

if not exists ( select 1 from gl_tran_type where code = 'A' )
	INSERT INTO gl_tran_type values ('A','Manual Add - Raw')
GO

if not exists ( select 1 from gl_tran_type where code = 'B' )
	INSERT INTO gl_tran_type values ('B','Manual Add - Wip')
GO

if not exists ( select 1 from gl_tran_type where code = 'C' )
	INSERT INTO gl_tran_type values ('C','Manual Add-Finished Goods')
GO

if not exists ( select 1 from gl_tran_type where code = 'D' )
	INSERT INTO gl_tran_type values ('D','Change/Correct Object')
GO

if not exists ( select 1 from gl_tran_type where code = 'E' )
	INSERT INTO gl_tran_type values ('E','Receive Raw')
GO

if not exists ( select 1 from gl_tran_type where code = 'F' )
	INSERT INTO gl_tran_type values ('F','Receive Wip')
GO

if not exists ( select 1 from gl_tran_type where code = 'G' )
	INSERT INTO gl_tran_type values ('G','Return Raw to Vendor')
GO

if not exists ( select 1 from gl_tran_type where code = 'H' )
	INSERT INTO gl_tran_type values ('H','Issue Raw to Wip')
GO

if not exists ( select 1 from gl_tran_type where code = 'I' )
	INSERT INTO gl_tran_type values ('I','Issue Wip')
GO

if not exists ( select 1 from gl_tran_type where code = 'J' )
	INSERT INTO gl_tran_type values ('J','Complete Finished Goods')
GO

if not exists ( select 1 from gl_tran_type where code = 'K' )
	INSERT INTO gl_tran_type values ('K','Scrap Inventory - Raw')
GO

if not exists ( select 1 from gl_tran_type where code = 'L' )
	INSERT INTO gl_tran_type values ('L','Scrap Inventory - Wip')
GO

if not exists ( select 1 from gl_tran_type where code = 'M' )
	INSERT INTO gl_tran_type values ('M','Scrap Inventory - FG')
GO

if not exists ( select 1 from gl_tran_type where code = 'N' )
	INSERT INTO gl_tran_type values ('N','Ship Finished Goods')
GO

if not exists ( select 1 from gl_tran_type where code = 'O' )
	INSERT INTO gl_tran_type values ('O','RMA')
GO

if not exists ( select 1 from gl_tran_type where code = 'P' )
	INSERT INTO gl_tran_type values ('P','Issue Finished')
GO

if not exists ( select 1 from gl_tran_type where code = 'Q' )
	INSERT INTO gl_tran_type values ('Q','Receive Finished')
GO

if not exists ( select 1 from gl_tran_type where code = 'R' )
	INSERT INTO gl_tran_type values ('R','Complete Wip')
GO


print'
----------------
-- forms changes
----------------
'
if exists ( select 1 from dbo.sysobjects where name = 'forms' )
	drop table forms
go


print'
---------------------------
-- group_technology changes
---------------------------
'
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'group_technology' and sc.id = so.id and sc.name = 'source_type' )
	alter table group_technology add source_type varchar(10) null
go


print'
-----------------------
-- gt_comp_list changes
-----------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'gt_comp_list' )
	drop table gt_comp_list
go

create table gt_comp_list (
       spid                 integer not null,
       part_number          varchar(25) not null,
       cur_level            integer not null,
       processed            char(1) not null
)
go


print'
-------------------------------------
-- inventory_accuracy_history changes
-------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'inventory_accuracy_history' )
	execute sp_rename inventory_accuracy_history, inventory_accuracy_history_tmp
go

create table inventory_accuracy_history (
       code                 varchar(15) not null,
       type                 char(1) not null,
       date_counted         datetime not null,
       accuracy_percentage  numeric(5,2) not null,
       total_objects        integer null,
       total_discrepency    integer null,
       group_no             varchar(15) null
)
go

alter table inventory_accuracy_history
       add primary key (code, date_counted)
go

if exists ( select 1 from dbo.sysobjects where name = 'inventory_accuracy_history_tmp' )
begin
	execute ( '
		insert into inventory_accuracy_history (code, type, date_counted, accuracy_percentage, 
		    total_objects, total_discrepency, group_no) select code, type, date_counted, convert(numeric(5,2),accuracy_percentage), 
		    total_objects, total_discrepency, group_no from inventory_accuracy_history_tmp
	' )
	
	execute ( '
		drop table inventory_accuracy_history_tmp
	' )
end
go


print'
-----------------
-- issues changes
-----------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'issues' )
begin
	execute ( '
		create table issues
		(
			issue_number     integer not null,
			issue      	text not null,
		 	status           varchar(25) null,
		 	solution         text null,
		 	start_date       datetime not null,
		 	stop_date        datetime null,
		 	category         varchar(50) not null,
		 	sub_category     varchar(50) null,
		 	priority_level       smallint not null,
		 	product_line     varchar(50) null,
		 	product_code     varchar(50) null,
		 	origin_type      varchar(50) not null,
		 	origin           varchar(50) not null,
		 	assigned_to      varchar(50) null,
		 	authorized_by    varchar(50) null,
		 	documentation_change   varchar(1) null,
		 	fax_sheet        varchar(1) null,
		 	environment      varchar(255) null,
		 	entered_by       varchar(50) null,
		 	product_component      varchar(25) null
		)
	' )
	
	execute ( '
		alter table issues add primary key (issue_number)
	' )
end
go



print'
--------------------------
-- issues_category changes
--------------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'issues_category' )
begin
	execute ( '
		create table issues_category
		(
			category        varchar(50) not null,
			default_value   varchar(1) not null
		)
	' )
	
	execute ( '
		alter table issues_category add primary key (category)
	' )
end
go

	
print'
------------------------
-- issues_status changes
------------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'issues_status' )
begin
	execute ( '
		create table issues_status
		(
			status          varchar(25) not null,
			type     		varchar(1) not null,
			default_value   varchar(1) not null
		)
	' )
	
	execute ( '
		alter table issues_status add primary key (status)
	' )
end
go
	

print'
----------------------
-- issue_types changes
----------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'issue_types' )
	drop table issue_types
go


print'
------------------------
-- label_library changes
------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'label_library' )
	drop table label_library
go


print'
----------------
-- labor changes      
----------------
'
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'current_rate' )
	alter table labor add current_rate numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'varying_rate_1' )
	alter table labor add varying_rate_1 numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'varying_rate_2' )
	alter table labor add varying_rate_2 numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'indirect' )
	alter table labor add indirect numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'sga' )
	alter table labor add sga numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'qted_rate' )
	alter table labor add qted_rate numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'qted_variable' )
	alter table labor add qted_variable numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'qted_indirect' )
	alter table labor add qted_indirect numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'qted_sga' )
	alter table labor add qted_sga numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'plnd_rate' )
	alter table labor add plnd_rate numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'plnd_variable' )
	alter table labor add plnd_variable numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'plnd_indirect' )
	alter table labor add plnd_indirect numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'plnd_sga' )
	alter table labor add plnd_sga numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'frzn_rate' )
	alter table labor add frzn_rate numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'frzn_variable' )
	alter table labor add frzn_variable numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'frzn_indirect' )
	alter table labor add frzn_indirect numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'frzn_sga' )
	alter table labor add frzn_sga numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'labor' and sc.id = so.id and sc.name = 'gl_segment' )
	alter table labor add gl_segment varchar(50) null
go


print'
-------------------
-- location changes
-------------------
'
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'location' and sc.id = so.id and sc.name = 'secured_location' )
	alter table location add secured_location char(1) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'location' and sc.id = so.id and sc.name = 'label_on_transfer' )
begin
	alter table location add label_on_transfer char(1) null
	execute ( '
	update location set label_on_transfer = "N"
	' )
end
go

print'
--------------
-- log changes
--------------
'
IF Not Exists ( SELECT	* FROM dbo.sysobjects WHERE name = 'log' )
	execute ( '
	CREATE TABLE	log
	(	spid	integer	NOT NULL,
		id		integer	NOT NULL,
		message	varchar (255) NOT NULL,
		PRIMARY KEY	( spid, id ) )
	' )
GO


print'
------------------
-- machine changes
------------------
'
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'current_rate' )
	alter table machine add current_rate         numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'standard_rate' )
	alter table machine add standard_rate        numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'varying_rate_1' )
	alter table machine add varying_rate_1      numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'varying_rate_2' )
	alter table machine add varying_rate_2      numeric(20,6) null 
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'indirect' )
	alter table machine add indirect numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'sga' )
	alter table machine add sga numeric(20,6) null                                        
go                                                                                                                                                          

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'qted_rate' )
	alter table machine add qted_rate 					numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'qted_variable' )
	alter table machine add qted_variable 				numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'qted_indirect' )
	alter table machine add qted_indirect 				numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'qted_sga' )
	alter table machine add qted_sga 					numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'plnd_rate' )
	alter table machine add plnd_rate 					numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'plnd_variable' )
	alter table machine add plnd_variable 				numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'plnd_indirect' )
	alter table machine add plnd_indirect 				numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'plnd_sga' )
	alter table machine add plnd_sga 					numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'frzn_rate' )
	alter table machine add frzn_rate 					numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'frzn_variable' )
	alter table machine add frzn_variable 				numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'frzn_indirect' )
	alter table machine add frzn_indirect 				numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'frzn_sga' )
	alter table machine add frzn_sga 					numeric(20, 6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'burden_type' )
	alter table machine add burden_type  varchar(1) null 
go      

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine' and sc.id = so.id and sc.name = 'gl_segment' )
	alter table machine add gl_segment varchar(50) null
go


print'
----------------------------
-- machine_data_1050 changes
----------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'machine_data_1050' )
	execute sp_rename machine_data_1050, machine_data_1050_temp
go

create table machine_data_1050 (
       machine              varchar(10) not null,
       last_reset           datetime null,
       status               char(1) null,
       downtime             numeric(20,6) null,
       cycle                numeric(20,6) null,
       counter              numeric(20,6) null,
       avg_cycle            numeric(20,6) null
)
go

alter table machine_data_1050
       add primary key (machine)
go

if exists ( select 1 from dbo.sysobjects where name = 'machine_data_1050_temp' )
begin
	declare @column_list varchar(255),
			@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
				dbo.syscolumns sc
		where	so.name = 'machine_data_1050_temp' and
				so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into machine_data_1050 ( ' + @column_list + ' )
			select ' + @column_list + ' from machine_data_1050_temp
	' )
	
	execute ( '
		drop table machine_data_1050_temp
	' )
end
go

      
print'
-------------------------
-- machine_policy changes
-------------------------
'
if 	exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine_policy' and sc.id = so.id and sc.name = 'scale_com_port' ) or
	exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine_policy' and sc.id = so.id and sc.name = 'scale_prompt_user' ) or
	exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine_policy' and sc.id = so.id and sc.name = 'scale_type' ) or
	exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'machine_policy' and sc.id = so.id and sc.name = 'scale_attached' )
begin
	if exists ( select 1 from dbo.sysobjects where name = 'machine_policy' )
		execute sp_rename machine_policy, machine_policy_temp

	execute ( '
	create table machine_policy (
	       machine              varchar(10) not null,
	       job_change           char(1) not null,
	       schedule_queue       char(1) not null,
	       start_stop_login     char(1) not null,
	       process_control      char(1) not null,
	       access_inventory_control char(1) not null,
	       material_substitution char(1) not null,
	       change_std_pack      char(1) not null,
	       change_packaging     char(1) not null,
	       change_unit          char(1) not null,
	       job_completion_delete char(1) not null,
	       material_issue_delete char(1) not null,
	       defects_delete       char(1) not null,
	       downtime_delete      char(1) not null,
	       smallest_downtime_increment integer not null,
	       downtime_histogram_days integer not null,
	       work_order_display_window varchar(60) null,
	       packaging_line       char(1) null,
	       operator_required    char(1) null
	)
	' )
	
	execute ( '
	alter table machine_policy
	       add primary key (machine)
	' )
	
	if exists ( select 1 from dbo.sysobjects where name = 'machine_policy_temp' )
	begin
		declare @column_list varchar(255),
				@column varchar(100)

		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
					dbo.syscolumns sc
			where	so.name = 'machine_policy_temp' and
					so.id = sc.id and
					sc.name not in ( 'scale_com_port','scale_prompt_user','scale_type','scale_attached','machine','job_change','schedule_queue','start_stop_login','process_control','access_inventory_control','material_substitution','change_std_pack' )

		select @column_list = ''

		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			if isnull(@column_list,'') > ''
				select @column_list = @column_list + ',' + @column
			else
				select @column_list = @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list

		execute ( '
			insert into machine_policy ( machine,job_change,schedule_queue,start_stop_login,process_control,access_inventory_control,material_substitution,change_std_pack,' + @column_list + ' )
				select machine,job_change,schedule_queue,start_stop_login,process_control,access_inventory_control,material_substitution,change_std_pack,' + @column_list + ' from machine_policy_temp
		' )

		execute ( '
			drop table machine_policy_temp
		' )
	end
end
go

print'
----------------------------
-- master_prod_sched changes
----------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('master_prod_sched') )
        drop table master_prod_sched
GO

CREATE TABLE master_prod_sched (
        type char (1) NULL ,
        part varchar (25) NOT NULL ,
        due datetime NOT NULL ,
        qnty numeric(20, 6) NOT NULL ,
        source int NOT NULL ,
        source2 varchar (15) NULL ,
        origin numeric(8, 0) NOT NULL ,
        rel_date datetime NULL ,
        tool varchar (15) NULL ,
        workcenter varchar (10) NULL ,
        machine varchar (10) NOT NULL ,
        run_time numeric(20, 6) NOT NULL ,
        run_day numeric(20, 6) NULL ,
        dead_start datetime NOT NULL ,
        material varchar (15) NULL ,
        job varchar (15) NOT NULL ,
        material_qnty numeric(20, 6) NULL ,
        setup numeric(20, 6) NOT NULL ,
        location varchar (10) NULL ,
        field1 varchar (10) NULL ,
        field2 varchar (10) NULL ,
        field3 varchar (10) NULL ,
        field4 varchar (10) NULL ,
        field5 varchar (10) NULL ,
        status char (1) NOT NULL ,
        sched_method char (1) NULL ,
        qty_completed numeric(20, 6) NULL ,
        process varchar (25) NULL ,
        tool_num varchar (15) NULL ,
        workorder varchar (10) NULL ,
        qty_assigned numeric(20, 6) NULL ,
        due_time datetime NULL ,
        start_time datetime NULL ,
        id numeric(12, 0) NOT NULL ,
        parent_id numeric(12, 0) NULL ,
        begin_date datetime NULL ,
        begin_time datetime NULL ,
        end_date datetime NULL ,
        end_time datetime NULL ,
        po_number int NULL ,
        po_row_id int NULL ,
        week_no int NULL ,
        plant varchar (15) NULL ,
        ship_type char (1) NULL ,
        ai_row integer NOT NULL identity primary key
)
GO

CREATE  INDEX mps_demand ON master_prod_sched(source, origin)
GO

CREATE  INDEX mps_due ON master_prod_sched(due)
GO

CREATE  INDEX mps_part ON master_prod_sched(part)
GO


print'
-----------------------------
-- m_in_ship_schedule changes
-----------------------------
'
IF Not Exists ( SELECT * FROM dbo.sysobjects WHERE name = 'm_in_ship_schedule' )
	execute ( '
	CREATE TABLE m_in_ship_schedule
	(	customer_part varchar (35) NOT NULL ,
		shipto_id varchar (20) NOT NULL ,
		customer_po varchar (20) NULL ,
		model_year varchar (4) NULL ,
		release_no varchar (30) NOT NULL ,
		quantity_qualifier char (1) NOT NULL ,
		quantity numeric(20, 6) NOT NULL ,
		release_dt_qualifier char (1) NOT NULL ,
		release_dt datetime NOT NULL )
	' )
GO


print'
-----------------
-- object changes
-----------------
'
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.id = sc.id and so.name = 'object' and sc.name = 'origin' and sc.length = 20 )
begin
	if exists (select 1 from dbo.sysobjects where id = object_id('object') )
		execute sp_rename object, object_backup
	
	execute ( '
	create table object (
		serial int not null,
		part varchar (25) not null,
		location varchar (10) not null,
		last_date datetime not null,
		unit_measure varchar (2) null,
		operator varchar (10) not null,
		status char (1) not null,
		destination varchar (20) null,
		station varchar (10) null,
		origin varchar (20) null,
		cost numeric (20,6) null,
		weight numeric (20,6) null,
		parent_serial numeric (10,0) null,
		note varchar (254) null,
		quantity numeric (20,6) null,
		last_time datetime null,
		date_due datetime null,
		customer varchar (15) null,
		sequence int null,
		shipper int null,
		lot varchar (20) null,
		type char (1) null,
		po_number varchar (30) null,
		name varchar (254) null,
		plant varchar (10) null,
		start_date datetime null,
		std_quantity numeric (20,6) null,
		package_type varchar (20) null,
		field1 varchar (10) null,
		field2 varchar (10) null,
		custom1 varchar (50) null,
		custom2 varchar (50) null,
		custom3 varchar (50) null,
		custom4 varchar (50) null,
		custom5 varchar (50) null,
		show_on_shipper char (1) null,
		tare_weight numeric (20,6) null,
		suffix int null,
		std_cost numeric (20,6) null,
		user_defined_status varchar (30) null,
		workorder varchar (10) null,
		engineering_level varchar (10) null,
		kanban_number varchar (6) null,
		dimension_qty_string varchar (50) null,
		dim_qty_string_other varchar (50) null,
		varying_dimension_code numeric (2,0) null,
		posted char (1) null,
		primary key  CLUSTERED 
		(
			serial
		)
	)
	' )
	
	if exists ( select 1 from dbo.sysobjects where name = 'object_backup' )
	begin
		-- generate column list from system tables for backup table
		-- (make sure to exclude deleted columns)
		declare @column_list1 varchar(255),
			@column_list2 varchar(255),
			@column varchar(100)
			
		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
				dbo.syscolumns sc
			where	so.name = 'object_backup' and
				so.id = sc.id
	
		select @column_list1 = ''
		select @column_list2 = ''
		
		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			if @column_list1 > ''
			begin
				if 	( select datalength ( @column_list1 ) ) >= 255 or
					( select datalength ( @column_list1 ) + datalength ( @column ) + 1 ) >= 255
				begin
					if @column_list2 > ''
						select @column_list2 = @column_list2 + ',' + @column
					else
						select @column_list2 = ',' + @column
				end
				else
					select @column_list1 = @column_list1 + ',' + @column
			end
			else
				select @column_list1 = @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list
	
		execute ( 'insert into object ( ' + @column_list1 + @column_list2 + ' ) select ' + @column_list1 + @column_list2 + ' from object_backup' )
	
		-- perform insert from backup table to newly created table
		-- if insert was a success, drop backup table
		if @@error = 0
			execute ( 'drop table object_backup' )
	end
	
end
else
begin

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'object' and sc.id = so.id and sc.name = 'dimension_qty_string' )
		alter table object add dimension_qty_string varchar(50) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'object' and sc.id = so.id and sc.name = 'dim_qty_string_other' )
		alter table object add dim_qty_string_other varchar(50) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'object' and sc.id = so.id and sc.name = 'varying_dimension_code' )
		alter table object add varying_dimension_code numeric(2) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'object' and sc.id = so.id and sc.name = 'posted' )
		alter table object add posted               char(1) null
end
go
      
begin
	create table #temp_indexes
	(
		index_name		varchar(125),
		index_description	varchar(125),
		index_keys		varchar(125)
	)

	insert into #temp_indexes
	execute sp_helpindex object

	if not exists ( select 1 from #temp_indexes where index_keys = 'shipper' )
		CREATE  INDEX ix_object_3 ON object(shipper)
	
	if not exists ( select 1 from #temp_indexes where index_keys = 'part' )
		CREATE  INDEX part ON object(part)
	
	if not exists ( select 1 from #temp_indexes where index_keys = 'status' )
		CREATE  INDEX status_index ON object(status)

	drop table #temp_indexes

end
go

print'
----------------------
-- ole_objects changes
----------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'ole_objects' )
begin
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'ole_objects' and sc.id = so.id and sc.name = 'serial' )
	begin
		execute ( '
		alter table ole_objects add serial integer null
		' )

		execute ( '
		update ole_objects
		set serial = (  select count (*)
		from ole_objects oleobj
		where oleobj.id <= ole_objects.id )
		' )
	end

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'ole_objects' and sc.id = so.id and sc.name = 'parent_type' )
		execute ( '
		alter table ole_objects add parent_type char(1) null
		' )

--	execute ( '
	update ole_objects
	set parent_type = 'I'
	where parent_type is null
--	' )
 
	execute sp_rename ole_objects, ole_objects_temp
end
go

create table ole_objects
(
	id    varchar(255) not null,
	ole_object image null,
	parent_id varchar(100) not null,
	date_stamp datetime null,
	serial  integer not null,
	parent_type char(1) null
)
go

alter table ole_objects add primary key (serial)
go

if exists ( select 1 from dbo.sysobjects where name = 'ole_objects_temp' )
begin
	execute ( '
	insert into ole_objects ( id, ole_object, parent_id, date_stamp, serial )
		select id, convert(image,ole_object), parent_id, date_stamp, serial from ole_objects_temp
	' )
	
	execute ( '
	drop table ole_objects_temp
	' )
end
go

create unique index ole_objects_ui1
on ole_objects ( parent_id, id )
go

update ole_objects
set parent_type = 'I'
where parent_type is null
go




print'
--------------------------------
-- order_header_inserted changes
--------------------------------
'
if not exists (
	select	1 
	from 	dbo.sysobjects 
	where 	id = object_id('order_header_inserted'))

	execute ( '
	create table order_header_inserted (
		order_no numeric (8,0) not null,
		order_date datetime not null,
		blanket_part varchar (25) not null,
		model_year varchar (4) not null,
		customer_part varchar (35) not null,
		standard_pack numeric (20,6) not null,
		our_cum numeric (20,6) not null,
		the_cum numeric (20,6) not null,
		order_type char (1) not null,
		shipped numeric (20,6) not null,
		shipped_date datetime not null,
		shipper int not null,
		status char (1) not null,
		unit varchar (2) not null,
		revision varchar (10) not null,
		customer_po varchar (20) not null,
		blanket_qty numeric (20,6) not null,
		salesman varchar (25) not null,
		zone_code varchar (30) not null,
		dock_code varchar (10) not null,
		package_type varchar (20) not null,
		notes varchar (255) not null,
		shipping_unit varchar (15) not null,
		line_feed_code varchar (30) not null,
		fab_cum numeric (15,2) not null,
		raw_cum numeric (15,2) not null,
		fab_date datetime not null,
		raw_date datetime not null,
		begin_kanban_number varchar (6) not null,
		end_kanban_number varchar (6) not null,
		line11 varchar (21) not null,
		line12 varchar (21) not null,
		line13 varchar (21) not null,
		line14 varchar (21) not null,
		line15 varchar (21) not null,
		line16 varchar (21) not null,
		line17 varchar (21) not null,
		custom01 varchar (30) not null,
		custom02 varchar (30) not null,
		custom03 varchar (30) not null,
		cs_status varchar (20) not null,
		engineering_level varchar (25) not null,
		review_date datetime not null,
		reviewed_by varchar (25) not null,
		primary key
		(
			order_no,
			order_date
		)
	)
	' )
go


print'
------------------------
-- order_detail_inserted
------------------------
'
if not exists (
	select	1
	  from	sysobjects
	 where	id = object_id ( 'order_detail_inserted' ) )

	execute ( '
	create table order_detail_inserted (
		order_no		numeric (8,0) not null,
		sequence		numeric(5,0) not null,
		part_number		varchar (25) not null,
		type			char (1) null,
		product_name		varchar (50) null,
		quantity		numeric (20,6) null,
		price			numeric (20,6) null,
		notes			varchar (255) null,
		assigned		varchar (35) null,
		shipped			numeric (20,6) null,
		invoiced		numeric (20,6) null,
		status			char (1) null,
		our_cum			numeric (20,6) null,
		the_cum			numeric (20,6) null,
		due_date		datetime null,
		destination		varchar (25) null,
		unit			varchar (2) null,
		committed_qty		numeric (20,6) null,
		row_id			integer null,
		group_no		varchar (10) null,
		cost			numeric (20,6) null,
		plant			varchar (10) null,
		release_no		varchar (30) null,
		flag			int null,
		week_no			int null,
		std_qty			numeric (20,6) null,
		customer_part		varchar (30) null,
		ship_type		char (1) null,
		dropship_po		int null,
		dropship_po_row_id	int null,
		suffix			int null,
		packline_qty		numeric (20,6) null,
		packaging_type		varchar (20) null,
		weight			numeric (20,6) null,
		custom01		varchar (30) null,
		custom02		varchar (30) null,
		custom03		varchar (30) null,
		dimension_qty_string	varchar (50) null,
		engineering_level	varchar (25) null,
		box_label		varchar (25) null,
		pallet_label		varchar (25) null,
		alternate_price		decimal (20,6) null)
	' )
go


print'
-----------------------
-- order_header changes
-----------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_order_header_iu' )
	drop trigger mtr_order_header_iu
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_order_header_i' )
	drop trigger mtr_order_header_i
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_order_header_u' )
	drop trigger mtr_order_header_u
GO

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_header' and sc.id = so.id and sc.name = 'box_label' and sc.length = 25 ) or
	not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_header' and sc.id = so.id and sc.name = 'pallet_label' and sc.length = 25 ) or
	not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_header' and sc.id = so.id and sc.name = 'line11' and sc.length = 35 )
begin
	-- drop order_detail foreign key pointing to order_header
	declare	@fkname	varchar(100),
		@command varchar(255),
		@table varchar(255)
	
	declare fks cursor for
		select	so1.name,
			so2.name
		from 	dbo.sysreferences sr, 
			dbo.sysobjects so1, 
			dbo.sysobjects so2,
			dbo.sysobjects so3
		where  	sr.fkeyid = so1.id and
			so2.id = sr.constid and
			sr.rkeyid = so3.id and
			so3.name = 'order_header'
	open fks
	fetch fks into @table,@fkname
	while ( @@fetch_status = 0 )
	begin
		select @command = 'alter table ' + @table + ' drop constraint ' + @fkname
		execute ( @command )
		fetch fks into @table,@fkname
	end
	close fks
	deallocate fks

	if exists ( select 1 from dbo.sysobjects where name = 'order_header' )
		execute sp_rename order_header, order_header_temp
		
	execute ( '
	CREATE TABLE order_header (
		order_no numeric(8, 0) NOT NULL ,
		customer varchar (10) NULL ,
		order_date datetime NULL ,
		contact varchar (35) NULL ,
		destination varchar (20) NULL ,
		blanket_part varchar (25) NULL ,
		model_year varchar (4) NULL ,
		customer_part varchar (35) NULL ,
		box_label varchar (25) NULL ,
		pallet_label varchar (25) NULL ,
		standard_pack numeric(20, 6) NULL ,
		our_cum numeric(20, 6) NULL ,
		the_cum numeric(20, 6) NULL ,
		order_type char (1) NULL ,
		amount numeric(20, 6) NULL ,
		shipped numeric(20, 6) NULL ,
		deposit numeric(20, 6) NULL ,
		artificial_cum char (1) NULL ,
		shipper int NULL ,
		status char (1) NULL ,
		location varchar (10) NULL ,
		ship_type char (1) NULL ,
		unit varchar (2) NULL ,
		revision varchar (10) NULL ,
		customer_po varchar (20) NULL ,
		blanket_qty numeric(20, 6) NULL ,
		price numeric(20, 6) NULL ,
		price_unit char (1) NULL ,
		salesman varchar (25) NULL ,
		zone_code varchar (30) NULL ,
		term varchar (20) NULL ,
		dock_code varchar (10) NULL ,
		package_type varchar (20) NULL ,
		plant varchar (10) NULL ,
		notes varchar (255) NULL ,
		shipping_unit varchar (15) NULL ,
		line_feed_code varchar (30) NULL ,
		fab_cum numeric(15, 2) NULL ,
		raw_cum numeric(15, 2) NULL ,
		fab_date datetime NULL ,
		raw_date datetime NULL ,
		po_expiry_date datetime NULL ,
		begin_kanban_number varchar (6) NULL ,
		end_kanban_number varchar (6) NULL ,
		line11 varchar (35) NULL ,
		line12 varchar (35) NULL ,
		line13 varchar (35) NULL ,
		line14 varchar (35) NULL ,
		line15 varchar (35) NULL ,
		line16 varchar (35) NULL ,
		line17 varchar (35) NULL ,
		custom01 varchar (30) NULL ,
		custom02 varchar (30) NULL ,
		custom03 varchar (30) NULL ,
		quote int NULL ,
		due_date datetime NULL ,
		engineering_level varchar (25) NULL ,
		currency_unit varchar (3) NULL ,
		alternate_price decimal(20, 6) NULL ,
		show_euro_amount smallint NULL ,
		cs_status varchar (20) NULL
	)
	' )
		
	alter table order_header add primary key ( order_no )
	
	if exists ( select 1 from dbo.sysobjects where name = 'order_header_temp' )
	begin
		declare @column_list varchar(255),
			@column varchar(100)
		
		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
				dbo.syscolumns sc
			where	so.name = 'order_header_temp' and
				so.id = sc.id and
				sc.name not in ( 'order_no','customer','order_date','contact','destination','blanket_part','model_year','customer_part',
				'box_label','pallet_label','standard_pack','our_cum','the_cum','order_type','amount','shipped','deposit','artificial_cum',
				'shipper','status','location','ship_type','unit','revision','customer_po','blanket_qty','price','price_unit','salesman',
				'zone_code','term','dock_code','package_type','plant','notes','shipping_unit','line_feed_code','fab_cum','raw_cum','fab_date','raw_date' )
		
		select @column_list = ''
		
		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			if isnull(@column_list,'') > ''
				select @column_list = @column_list + ',' + @column
			else
				select @column_list = @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list
		
		execute ( '
			insert into order_header ( order_no,customer,order_date,contact,destination,blanket_part,model_year,customer_part,
				box_label,pallet_label,standard_pack,our_cum,the_cum,order_type,amount,shipped,deposit,artificial_cum,
				shipper,status,location,ship_type,unit,revision,customer_po,blanket_qty,price,price_unit,salesman,
				zone_code,term,dock_code,package_type,plant,notes,shipping_unit,line_feed_code,fab_cum,raw_cum,fab_date,raw_date,' + @column_list + ' )
				select order_no,customer,order_date,contact,destination,blanket_part,model_year,customer_part,
				box_label,pallet_label,standard_pack,our_cum,the_cum,order_type,amount,shipped,deposit,artificial_cum,
				shipper,status,location,ship_type,unit,revision,customer_po,blanket_qty,price,price_unit,salesman,
				zone_code,term,dock_code,package_type,plant,notes,shipping_unit,line_feed_code,fab_cum,raw_cum,fab_date,raw_date,' + @column_list + ' from order_header_temp
		' )
		
		execute ( '
			drop table order_header_temp
		' )
	end
	
	alter table order_detail add
		constraint fk_order_detail_1
			foreign key (order_no) 
			references order_header (order_no)

	alter table kanban
	add foreign key (order_no)
	references order_header
end
else
begin

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_header' and sc.id = so.id and sc.name = 'quote' )
		alter table order_header add quote                integer null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_header' and sc.id = so.id and sc.name = 'due_date' )
		alter table order_header add due_date datetime null
	      
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_header' and sc.id = so.id and sc.name = 'engineering_level' )
		alter table order_header add engineering_level varchar ( 25 ) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_header' and sc.id = so.id and sc.name = 'currency_unit' )
		alter table order_header add currency_unit varchar(3) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_header' and sc.id = so.id and sc.name = 'alternate_price' )
		alter table order_header add alternate_price decimal(20,6) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_header' and sc.id = so.id and sc.name = 'show_euro_amount' )
		alter table order_header add show_euro_amount smallint null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_header' and sc.id = so.id and sc.name = 'cs_status' )
		alter table order_header add cs_status varchar(20) null
end
go

update order_header set cs_status = css.status_name
from customer_service_status css
where order_header.cs_status is null and
	css.default_value = 'Y'
go

update	order_header
set	alternate_price = price
where	alternate_price is null
go

-- script to set default currency unit
update	order_header
set	currency_unit = 'USD'
where	currency_unit is null
go


begin
	create table #temp_indexes
	(
		index_name		varchar(125),
		index_description	varchar(125),
		index_keys		varchar(125)
	)

	insert into #temp_indexes
	execute sp_helpindex order_header

	if not exists ( select 1 from #temp_indexes where index_keys = 'customer' )
		CREATE  INDEX order_header_customer_ix ON order_header(customer)  WITH FILLFACTOR = 90

	drop table #temp_indexes
end
go



print'
---------------------
-- parameters changes
---------------------
'
if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.id = sc.id and so.name = 'parameters' and sc.name = 'need_suffix' )
begin
	if exists ( select 1 from dbo.sysobjects where name = 'parameters' )
		execute sp_rename parameters, parameters_temp
	
	execute ( '
	CREATE TABLE parameters (
		company_name varchar (50) NOT NULL ,
		next_serial int NOT NULL ,
		default_rows int NULL ,
		next_issue int NULL ,
		sales_order int NULL ,
		shipper int NULL ,
		company_logo varchar (30) NULL ,
		show_program_name char (1) NULL ,
		purchase_order numeric(10, 0) NULL ,
		address_1 varchar (30) NULL ,
		address_2 varchar (30) NULL ,
		address_3 varchar (30) NULL ,
		admin_password varchar (5) NULL ,
		time_interval int NULL ,
		next_invoice int NULL ,
		next_requisition int NULL ,
		delete_scrapped_objects char (1) NULL ,
		ipa char (1) NULL ,
		ipa_beginning_sequence int NULL ,
		audit_trail_delete char (1) NULL ,
		invoice_add char (1) NULL ,
		plant_required char (1) NULL ,
		edit_po_number char (1) NULL ,
		over_receive char (1) NULL ,
		phone_number varchar (15) NULL ,
		shipping_label varchar (30) NULL ,
		bol_number int NULL ,
		verify_packaging char (1) NULL ,
		fiscal_year_begin datetime NULL ,
		sales_tax_account varchar (50) NULL ,
		freight_account varchar (50) NULL ,
		populate_parts char (1) NULL ,
		populate_locations char (1) NULL ,
		populate_machines char (1) NULL ,
		mandatory_lot_inventory char (1) NULL ,
		edi_process_days int NULL ,
		set_asn_uop char (1) NULL ,
		shop_floor_check_u1 char (1) NULL ,
		shop_floor_check_u2 char (1) NULL ,
		shop_floor_check_u3 char (1) NULL ,
		shop_floor_check_u4 char (1) NULL ,
		shop_floor_check_u5 char (1) NULL ,
		shop_floor_check_lot char (1) NULL ,
		lot_control_message varchar (255) NULL ,
		mandatory_qc_notes char (1) NULL ,
		asn_directory varchar (25) NULL ,
		next_db_change int NULL ,
		fix_number int NULL ,
		auto_stage_for_packline char (1) NULL ,
		ask_for_minicop char (1) NULL ,
		issue_file_location varchar (250) NULL ,
		accounting_interface_db varchar (25) NULL ,
		accounting_interface_type varchar (25) NULL ,
		accounting_interface_login varchar (10) NULL ,
		accounting_interface_pwd varchar (10) NULL ,
		accounting_pbl_name varchar (50) NULL ,
		accounting_cust_sync_dp varchar (50) NULL ,
		accounting_vend_sync_db varchar (50) NULL ,
		accounting_ap_dp_header varchar (50) NULL ,
		accounting_ar_dp varchar (50) NULL ,
		accounting_ap_dp_detail varchar (50) NULL ,
		inv_reg_col varchar (25) NULL ,
		scale_part_choice char (1) NULL ,
		accounting_profile varchar (50) NULL ,
		accounting_type varchar (25) NULL ,
		next_voucher int NULL ,
		days_to_process int NULL ,
		include_setuptime char (1) NULL ,
		sunday char (1) NULL ,
		monday char (1) NULL ,
		tuesday char (1) NULL ,
		wednesday char (1) NULL ,
		thursday char (1) NULL ,
		friday char (1) NULL ,
		saturday char (1) NULL ,
		workhours_in_day int NULL ,
		order_type char (1) NULL ,
		pallet_package_type char (1) NULL ,
		clear_after_trans_jc char (1) NULL ,
		dda_required char (1) NULL ,
		dda_formula_type char (1) NULL ,
		shipper_required varchar (1) NULL ,
		calc_mtl_cost varchar (1) NULL ,
		issues_environment_message varchar (255) NULL ,
		base_currency varchar (3) NULL ,
		currency_display_symbol varchar (10) NULL ,
		euro_enabled smallint NULL ,
		requisition char (1) NULL,
		onhand_from_partonline char(1) null,
		consolidate_mps char(1) null,
		daily_horizon int null,
		weekly_horizon int null,
		fortnightly_horizon int null,
		monthly_horizon int null,
		next_workorder int null
	)
	' )
	
	execute ( '
	alter table parameters add primary key ( company_name )
	' )
	
	if exists ( select 1 from dbo.sysobjects where name = 'parameters_temp' )
	begin
		-- generate column list from system tables for backup table
		-- (make sure to exclude deleted columns)
		declare @column_list1 varchar(255),
			@column_list2 varchar(255),
			@column_list3 varchar(255),
			@column_list4 varchar(255),
			@column_list5 varchar(255),
			@column varchar(100)
			
		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
				dbo.syscolumns sc
			where	so.name = 'parameters_temp' and
				so.id = sc.id
				and sc.name not in ( 'need_suffix' )
	
		select @column_list1 = ''
		select @column_list2 = ''
		select @column_list3 = ''
		select @column_list4 = ''
		select @column_list5 = ''
		
		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			if @column_list1 > ''
			begin
				if 	( select datalength ( @column_list1 ) ) >= 255 or
					( select datalength ( @column_list1 ) + datalength ( @column ) + 1 ) >= 255
				begin
					if 	( select datalength ( @column_list2 ) ) >= 255 or
						( select datalength ( @column_list2 ) + datalength ( @column ) + 1 ) >= 255
					begin
						if 	( select datalength ( @column_list3 ) ) >= 255 or
							( select datalength ( @column_list3 ) + datalength ( @column ) + 1 ) >= 255
						begin
							if 	( select datalength ( @column_list4 ) ) >= 255 or
								( select datalength ( @column_list4 ) + datalength ( @column ) + 1 ) >= 255
							begin
								if @column_list5 > ''
									select @column_list5 = @column_list5 + ',' + @column
								else
									select @column_list5 = ',' + @column
							end
							else
							begin
								if @column_list4 > ''
									select @column_list4 = @column_list4 + ',' + @column
								else
									select @column_list4 = ',' + @column
							end
						end
						else
						begin
							if @column_list3 > ''
								select @column_list3 = @column_list3 + ',' + @column
							else
								select @column_list3 = ',' + @column
						end
					end
					else
					begin
						if @column_list2 > ''
							select @column_list2 = @column_list2 + ',' + @column
						else
							select @column_list2 = ',' + @column
					end
				end
				else
					select @column_list1 = @column_list1 + ',' + @column
			end
			else
				select @column_list1 = @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list
	
		execute ( 'insert into parameters ( ' + @column_list1 + @column_list2 + ' ) select ' + @column_list1 + @column_list2 + ' from parameters_temp' )
	
		-- perform insert from backup table to newly created table
		-- if insert was a success, drop backup table
		if @@error = 0
			execute ( 'drop table parameters_temp' )
	end

end
else
begin
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'parameters' and sc.id = so.id and sc.name = 'dda_required' )
		alter table parameters add dda_required         char(1) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'parameters' and sc.id = so.id and sc.name = 'dda_formula_type' )
		alter table parameters add dda_formula_type     char(1) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'parameters' and sc.id = so.id and sc.name = 'shipper_required' )
		alter table parameters add shipper_required varchar (1) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'parameters' and sc.id = so.id and sc.name = 'calc_mtl_cost' )
		alter table parameters add calc_mtl_cost  varchar(1) null 
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'parameters' and sc.id = so.id and sc.name = 'issues_environment_message' )
		alter table parameters add issues_environment_message  varchar(255) null 
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'parameters' and sc.id = so.id and sc.name = 'base_currency' )
		alter table parameters add base_currency varchar(3) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'parameters' and sc.id = so.id and sc.name = 'currency_display_symbol' )
		alter table parameters add currency_display_symbol varchar(10) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'parameters' and sc.id = so.id and sc.name = 'euro_enabled' )
		alter table parameters add euro_enabled smallint null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'parameters' and sc.id = so.id and sc.name = 'requisition' )
		alter table parameters add requisition varchar (1) null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'parameters' and sc.id = so.id and sc.name = 'onhand_from_partonline' )
		alter table parameters add onhand_from_partonline char(1) null
		
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'parameters' and sc.id = so.id and sc.name = 'consolidate_mps' )
		alter table parameters add consolidate_mps char(1) null
		
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'parameters' and sc.id = so.id and sc.name = 'daily_horizon' )
		alter table parameters add daily_horizon int null
		
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'parameters' and sc.id = so.id and sc.name = 'weekly_horizon' )
		alter table parameters add weekly_horizon int null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'parameters' and sc.id = so.id and sc.name = 'fortnightly_horizon' )
		alter table parameters add fortnightly_horizon int null
		
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'parameters' and sc.id = so.id and sc.name = 'monthly_horizon' )
		alter table parameters add monthly_horizon int null
 

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.id = sc.id and so.name = 'parameters' and sc.name = 'next_workorder' )
		alter table parameters add next_workorder int null		
end
go

update parameters set
	base_currency = 'USD',
	currency_display_symbol = '$',
	euro_enabled = 1
where base_currency is null
go

execute ( 'update parameters set next_workorder = isnull ( (select max ( convert ( integer , work_order ) ) from work_order ), 1) where next_workorder is null' )
go

update parameters set requisition = 'N' where requisition is null
go


print'
---------------
-- part changes
---------------
'
if 	not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'part' and sc.id = so.id and sc.name = 'name' and sc.length = 100 )
begin
	declare	@fkname	varchar(100),
			@command varchar(255),
			@table varchar(255)
	
	declare fks cursor for
		select	so1.name,
				so2.name
		from 	dbo.sysreferences sr, 
				dbo.sysobjects so1, 
				dbo.sysobjects so2,
				dbo.sysobjects so3
		where  	sr.fkeyid = so1.id and
				so2.id = sr.constid and
				sr.rkeyid = so3.id and
				so3.name = 'part'
	
	open fks
	fetch fks into @table,@fkname
	while ( @@fetch_status = 0 )
	begin
		select @command = 'alter table ' + @table + ' drop constraint ' + @fkname
		execute ( @command )
		fetch fks into @table,@fkname
	end
	close fks
	deallocate fks

	if exists ( select 1 from dbo.sysobjects where name = 'part' )
		execute sp_rename part, part_temp
	
	execute ( '
		create table part (
			part varchar (25) not null ,
			name varchar (100) not null ,
			cross_ref varchar (50) null ,
			class char (1) not null ,
			type char (1) null ,
			commodity varchar (30) null ,
			group_technology varchar (25) null ,
			quality_alert char (1) null ,
			description_short varchar (50) null ,
			description_long varchar (255) null ,
			serial_type char (1) null ,
			product_line varchar (25) null ,
			configuration char (1) null ,
			standard_cost numeric(20, 6) null ,
			user_defined_1 varchar (30) null ,
			user_defined_2 varchar (30) null ,
			flag int null ,
			engineering_level varchar (10) null ,
			drawing_number varchar (25) null ,
			gl_account_code varchar (50) null ,
			eng_effective_date datetime null ,
			low_level_code int null 
		)
	' )
	
	execute ( '
		alter table part add primary key(part)
	' )
		
	if exists ( select 1 from dbo.sysobjects where name = 'part_temp' )
	begin
		declare @column_list varchar(255),
			@column varchar(100)

		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
					dbo.syscolumns sc
			where	so.name = 'part_temp' and
					so.id = sc.id and
					sc.name not in ( 'part','name','cross_ref','class','type','commodity','group_technology','quality_alert','description_short','description_long','serial_type','product_line','configuration','standard_cost','user_defined_1','user_defined_2','flag' )

		select @column_list = ''

		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			select @column_list = @column_list + ',' + @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list

		execute ( '
			insert into part ( part,name,cross_ref,class,type,commodity,group_technology,quality_alert,description_short,description_long,serial_type,product_line,configuration,standard_cost,user_defined_1,user_defined_2,flag' + @column_list + ' )
				select part,name,cross_ref,class,type,commodity,group_technology,quality_alert,description_short,description_long,serial_type,product_line,configuration,standard_cost,user_defined_1,user_defined_2,flag' + @column_list + ' from part_temp
		' )

		execute ( '	                 
			drop table part_temp
		' )
	end
				
	create index class_index
		on part (class)

	if exists ( select 1 from dbo.sysobjects where name = 'part_characteristics' )
		alter table part_characteristics add
			constraint fk_part_characteristics1
				foreign key (part) 
				references part (part)
	
	if exists ( select 1 from dbo.sysobjects where name = 'part_customer' )
		alter table part_customer add
			constraint fk_part_customer1
				foreign key (part) 
				references part (part)
	
	if exists ( select 1 from dbo.sysobjects where name = 'part_inventory' )
		alter table part_inventory  add
			constraint fk_part_inventory1
				foreign key (part) 
				references part (part)
	
	if exists ( select 1 from dbo.sysobjects where name = 'part_online' )
		alter table part_online add
			constraint fk_part_online1
				foreign key (part) 
				references part (part)
	
	if exists ( select 1 from dbo.sysobjects where name = 'part_packaging' )
		alter table part_packaging add
			constraint fk_part_packaging1
				foreign key (part) 
				references part (part)
	
	if exists ( select 1 from dbo.sysobjects where name = 'part_purchasing' )
		alter table part_purchasing add
			constraint fk_part_purchasing1
				foreign key (part) 
				references part (part)
	
	if exists ( select 1 from dbo.sysobjects where name = 'part_revision' )
		alter table part_revision add
			constraint fk_part_revision1
				foreign key (part) 
				references part (part)
	
	if exists ( select 1 from dbo.sysobjects where name = 'part_standard' )
		alter table part_standard add
			constraint fk_part_standard1
				foreign key (part) 
				references part (part)
	
	if exists ( select 1 from dbo.sysobjects where name = 'part_unit_conversion' )
		alter table part_unit_conversion add
			constraint fk_part_unit_conversion1
				foreign key (part) 
				references part (part)
end
else
begin

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part' and sc.id = so.id and sc.name = 'engineering_level' )
		alter table part add engineering_level    varchar(10) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part' and sc.id = so.id and sc.name = 'drawing_number' )
		alter table part add drawing_number       varchar(25) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part' and sc.id = so.id and sc.name = 'gl_account_code' )
		alter table part add gl_account_code      varchar(50) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part' and sc.id = so.id and sc.name = 'eng_effective_date' )
		alter table part add eng_effective_date   datetime null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part' and sc.id = so.id and sc.name = 'low_level_code' )
		alter table part add low_level_code       integer null
	
end
go


print'
-----------------------------------------------------------
-- update the part table with engineering change level data
-----------------------------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'part_mfg' and type = 'U' )
begin
	if exists ( select 1 from dbo.sysobjects where name = 'mtr_part_i' )
		drop trigger mtr_part_i

	if exists ( select 1 from dbo.sysobjects where name = 'mtr_part_u' )
		drop trigger mtr_part_u

	if exists ( select 1 from dbo.sysobjects where name = 'mtr_part_d' )
		drop trigger mtr_part_d

	execute ( '
	update part set
		engineering_level 	= null,
		drawing_number		= ( select drawing_number from part_mfg where part = part.part ),
		gl_account_code		= ( select gl_account_code from part_mfg where part = part.part ),
		eng_effective_date	= ( select eng_effective_date from part_mfg where part = part.part ),
		low_level_code		= ( select low_level_code from part_mfg where part = part.part )
	' )
	
	execute ( '
	insert into effective_change_notice ( part, effective_date, operator, notes, engineering_level )
		select	part, isnull(eng_effective_date,getdate()), '', '', engineering_level
		from	part_mfg
		where	isnull(engineering_level,'') > '' and
			part in ( select part from part )
	' )
end
go


print'
--------------------------------
-- part_class_definition changes
--------------------------------
'
begin
	declare	@fkname	varchar(100),
		@command varchar(255),
		@table varchar(255)
	
	declare fks cursor for
		select	so1.name,
			so2.name
		from 	dbo.sysreferences sr, 
			dbo.sysobjects so1, 
			dbo.sysobjects so2,
			dbo.sysobjects so3
		where  	sr.fkeyid = so1.id and
			so2.id = sr.constid and
			sr.rkeyid = so3.id and
			so3.name = 'part_class_definition'
	
	open fks
	fetch fks into @table,@fkname
	while ( @@fetch_status = 0 )
	begin
		select @command = 'alter table ' + @table + ' drop constraint ' + @fkname
		execute ( @command )
		fetch fks into @table,@fkname
	end
	close fks
	deallocate fks
end
go

if exists ( select 1 from dbo.sysobjects where name = 'part_class_definition' )
	execute sp_rename part_class_definition, part_class_definition_temp
go

create table part_class_definition (
       class                char(1) not null,
       class_name           varchar(25) not null,
       status_flag          binary(8) null
)
go

alter table part_class_definition
       add primary key (class)
go

if exists ( select 1 from dbo.sysobjects where name = 'part_class_definition_temp' )
begin
	declare @column_list varchar(255),
			@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
			dbo.syscolumns sc
		where	so.name = 'part_class_definition_temp' and
			so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into part_class_definition ( ' + @column_list + ' )
			select ' + @column_list + ' from part_class_definition_temp
	' )

	execute ( '
		drop table part_class_definition_temp
	' )	
end
go

if not exists ( select 1 from part_class_definition where class = 'A' )
	insert into part_class_definition (class,class_name) values ('A','Asset')
go
if not exists ( select 1 from part_class_definition where class = 'C' )
	insert into part_class_definition (class,class_name) values ('C','Consigment')
go
if not exists ( select 1 from part_class_definition where class = 'M' )
	insert into part_class_definition (class,class_name) values ('M','Manufactured')
go
if not exists ( select 1 from part_class_definition where class = 'N' )
	insert into part_class_definition (class,class_name) values ('N','Non-inventory')
go
if not exists ( select 1 from part_class_definition where class = 'P' )
	insert into part_class_definition (class,class_name) values ('P','Purchased')
go
if not exists ( select 1 from part_class_definition where class = 'O' )
	INSERT INTO part_class_definition ( class, class_name ) VALUES ( 'O', 'Obsolete')
go



print'
------------------------
-- part_customer changes
------------------------
'
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.id = sc.id and so.name = 'part_customer' and sc.name = 'blanket_price' )
	alter table part_customer add blanket_price numeric (20,6) null
go


print'
-------------------------------------
-- part_customer_price_matrix changes
-------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_pc_price_matrix_iu'  )
	drop trigger mtr_pc_price_matrix_iu
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_pc_price_matrix_i'  )
	drop trigger mtr_pc_price_matrix_i
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_pc_price_matrix_u'  )
	drop trigger mtr_pc_price_matrix_u
go

if (	select	count(part)
	from 	part_customer_price_matrix pcpm1
	where 	(	select	count(pcpm2.part) 
			from 	part_customer_price_matrix pcpm2 
			where 	pcpm2.part = pcpm1.part and
				pcpm2.customer = pcpm1.customer and
				pcpm2.qty_break = pcpm1.qty_break ) > 1 ) > 1
	print 'Please get rid of any duplicate quantity breaks for each part - customer relationship and run the part_customer_price_matrix changes section again.'
else
begin

	if exists ( select 1 from dbo.sysobjects where name = 'part_customer_price_matrix' )
		execute sp_rename part_customer_price_matrix, part_customer_price_matrix_t

	execute ( '
	create table part_customer_price_matrix 
	(
		part varchar (25) not null ,
		customer varchar (25) not null ,
		code varchar (10) null ,
		price numeric(20, 6) null ,
		qty_break numeric(20, 6) not null ,
		discount numeric(20, 6) null ,
		category varchar (25) null ,
		alternate_price decimal(20, 6) null,
		primary key ( part, customer, qty_break )
	)
	' )

	if exists ( select 1 from dbo.sysobjects where name = 'part_customer_price_matrix_t' )
	begin
		if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where sc.id = so.id and so.name = 'part_customer_price_matrix_t' and sc.name = 'alternate_price' )
			execute ( '
				insert into part_customer_price_matrix (part, customer, code, price, qty_break, discount, category, alternate_price) 
					select part, customer, code, price, isnull(qty_break,0), discount, category, alternate_price from part_customer_price_matrix_t
			' )
		else
			execute ( '
				insert into part_customer_price_matrix (part, customer, code, price, qty_break, discount, category, alternate_price) 
					select part, customer, code, price, isnull(qty_break,0), discount, category, null from part_customer_price_matrix_t
			' )

		execute ( '
			drop table part_customer_price_matrix_t
		' )
		
	end
end
go

update part_customer_price_matrix set alternate_price = price where alternate_price is null
go


print'
--------------------------
-- part_gl_account changes
--------------------------
'
if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_gl_account' and sc.id = so.id and sc.name = 'labor_gl_ac_seg' ) or
   exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_gl_account' and sc.id = so.id and sc.name = 'burden_gl_ac_seg' )
begin
	if exists ( select 1 from dbo.sysobjects where name = 'part_gl_account' )
		execute sp_rename part_gl_account, part_gl_account_temp
	
	execute ( '
	create table part_gl_account ( 
		part varchar (25) NOT NULL ,
		tran_type varchar (2) NOT NULL ,
		gl_account_no_db varchar (50) NULL ,
		gl_account_no_cr varchar (50) NULL ,
		name varchar (50) NULL
	)
	' )
		
	execute ( '
	alter table part_gl_account add primary key (part,tran_type)
	' )
	
	if exists ( select 1 from dbo.sysobjects where name = 'part_gl_account_temp' )
	begin
		execute ( '
		insert into part_gl_account ( part, tran_type, gl_account_no_db, name )
			select part, tran_type, gl_account_no, name from part_gl_account_temp
		' )
		
		execute ( '
		drop table part_gl_account_temp
		' )
	end
end
else if not exists ( select 1 from dbo.sysobjects where name = 'part_gl_account' )
begin
	execute ( '
	create table part_gl_account ( 
		part varchar (25) NOT NULL ,
		tran_type varchar (2) NOT NULL ,
		gl_account_no_db varchar (50) NULL ,
		gl_account_no_cr varchar (50) NULL ,
		name varchar (50) NULL
	)
	' )
		
	execute ( '
	alter table part_gl_account add primary key (part,tran_type)
	' )
end
go


print'
------------------------
-- part_location changes
------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'part_location' )
	execute sp_rename part_location, part_location_temp
go

create table part_location (
	part varchar (25) not null,
	location varchar(10) not null,
	days_onhand numeric(20,6) null,
	maximum numeric(20,6) null,
	minimum numeric(20,6) null,
	reorder_qty numeric(20,6) null,
	destination varchar(10)null
)
go

alter table part_location add primary key (part,location)
go

if exists ( select 1 from dbo.sysobjects where name = 'part_location_temp' )
begin
	declare @column_list varchar(255),
			@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
			dbo.syscolumns sc
		where	so.name = 'part_location_temp' and
			so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into part_location ( ' + @column_list + ' )
			select ' + @column_list + ' from part_location_temp
	' )

	execute ( '
		drop table part_location_temp
	' )	
end
go


print'
-----------------------
-- part_machine changes
-----------------------
'
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_machine' and sc.id = so.id and sc.name = 'mfg_lot_size' )
	alter table part_machine add mfg_lot_size         numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_machine' and sc.id = so.id and sc.name = 'process_id' )
	alter table part_machine add process_id           varchar(25) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_machine' and sc.id = so.id and sc.name = 'parts_per_cycle' )
	alter table part_machine add parts_per_cycle      numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_machine' and sc.id = so.id and sc.name = 'parts_per_hour' )
	alter table part_machine add parts_per_hour       numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_machine' and sc.id = so.id and sc.name = 'cycle_unit' )
	alter table part_machine add cycle_unit           varchar(10) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_machine' and sc.id = so.id and sc.name = 'cycle_time' )
	alter table part_machine add cycle_time           numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_machine' and sc.id = so.id and sc.name = 'overlap_type' )
	alter table part_machine add overlap_type         char(1) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_machine' and sc.id = so.id and sc.name = 'overlap_time' )
	alter table part_machine add overlap_time         numeric(6,2) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_machine' and sc.id = so.id and sc.name = 'labor_code' )
	alter table part_machine add labor_code           varchar(15) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_machine' and sc.id = so.id and sc.name = 'activity' )
	alter table part_machine add activity             varchar(25) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_machine' and sc.id = so.id and sc.name = 'setup_time' )
	alter table part_machine add setup_time           numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_machine' and sc.id = so.id and sc.name = 'crew_size' )
	alter table part_machine add crew_size 			  decimal(20,6) null
go



if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_machine' and sc.id = so.id and sc.name = 'labor_code' and sc.length = 25 )
begin
	if exists ( select 1 from dbo.sysobjects where name = 'part_machine' )
		execute sp_rename part_machine, part_machine_temp
	
	execute ( '
	CREATE TABLE part_machine (
		part varchar (25) NOT NULL ,
		machine varchar (15) NOT NULL ,
		sequence int NULL ,
		mfg_lot_size numeric(20, 6) NULL ,
		process_id varchar (25) NULL ,
		parts_per_cycle numeric(20, 6) NULL ,
		parts_per_hour numeric(20, 6) NULL ,
		cycle_unit varchar (10) NULL ,
		cycle_time numeric(20, 6) NULL ,
		overlap_type char (1) NULL ,
		overlap_time numeric(6, 2) NULL ,
		labor_code varchar (25) NULL ,
		activity varchar (25) NULL ,
		setup_time numeric(20, 6) NULL ,
		crew_size decimal(20, 6) NULL
	)
	' )
	
	alter table part_machine add primary key ( part, machine )
	
	if exists ( select 1 from dbo.sysobjects where name = 'part_machine_temp' )
	begin
		declare @column_list varchar(255),
			@column varchar(100)

		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
				dbo.syscolumns sc
			where	so.name = 'part_machine_temp' and
				so.id = sc.id

		select @column_list = ''

		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			if isnull(@column_list,'') > ''
				select @column_list = @column_list + ',' + @column
			else
				select @column_list = @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list

		execute ( '
			insert into part_machine ( ' + @column_list + ' ) 
				select	' + @column_list + '
		   		from 	part_machine_temp 
		' )

		execute ( '
			drop table part_machine_temp
		' )
	end
		
end
go

-- add unique index for part_machine
if exists ( select 1 from dbo.sysobjects where name = 'mtr_part_machine_i' )
        drop trigger mtr_part_machine_i
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_part_machine_u' )
        drop trigger mtr_part_machine_u
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_part_machine_d' )
        drop trigger mtr_part_machine_d
go

begin 
        declare @number integer, 
                @part varchar (25),
                @sequence integer,
  @machine  varchar (25),
  @msg   varchar (250) 

        declare  duplicate cursor  for
        select part,sequence 
        from part_machine
        where part in ( select part from part_machine
        group by part, sequence
        having count(*) > 1  ) 

        open duplicate
        fetch duplicate into @part, @sequence
 while ( @@fetch_status = 0 ) 
        begin
  select @number = 1 

  declare pm cursor for
  select machine
  from part_machine
  where part = @part
  order by part, sequence

  open pm
  fetch pm into @machine
         while ( @@fetch_status = 0 ) 
  begin
   update part_machine
   set sequence = @number 
   where part = @part and 
   machine = @machine 

   select @number = @number + 1 
   fetch pm into @machine
  end
  close pm
  deallocate pm 
         fetch duplicate into @part, @sequence
  end

        close duplicate
        deallocate duplicate

end 
go

if exists ( select 1 from sysindexes where name = 'part_machine_ui1' )
	drop index part_machine.part_machine_ui1
go



print'
-------------------------------------------------------
-- take outside process vendors from activity router
-- and add to part_machine
-------------------------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'part_mfg' and type = 'U' )
begin
	execute ( '
	insert into part_machine ( part,machine,sequence,mfg_lot_size,process_id,parts_per_cycle,parts_per_hour,cycle_unit,cycle_time,overlap_type,overlap_time,labor_code,activity,setup_time ) 
		select  part_mfg.part, activity_router.group_location, 1,part_mfg.mfg_lot_size,part_mfg.process_id,part_mfg.parts_per_cycle,part_mfg.parts_per_hour, part_mfg.cycle_unit,part_mfg.cycle_time, part_mfg.overlap_type,part_mfg.overlap_time, part_mfg.labor_code,part_mfg.activity, part_mfg.setup_time
	 	from 	activity_router, part_mfg 
		where 	group_location in ( select code from vendor ) and  part_mfg.part = activity_router.part and part_mfg.activity = activity_router.code
	' )
	
	delete from activity_router where ltrim(isnull(parent_part,'')) = '' or ltrim(isnull(part,'')) = ''
	
	insert into activity_router 
		( parent_part, sequence, code, part, notes, labor, material, cost_bill, group_location, process, 
		doc1, doc2, doc3, doc4, cost, price, cost_price_factor, time_stamp)
	select	part, 1, code, part, notes, labor, material, cost_bill, group_location, process, 
		doc1, doc2, doc3, doc4, cost, price, cost_price_factor, time_stamp
	from 	activity_router ar
	where 	parent_part <> part and
		not exists ( select 1 from activity_router where activity_router.parent_part = ar.part and activity_router.part = ar.part )
end
go


print'
------------------------------------------------------------------
-- put part_mfg records into part_machine and create part_mfg view
------------------------------------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'part_mfg' and type = 'U' )
begin
	execute ( '
	update part_machine
	set part_machine.activity = part_mfg.activity,
		part_machine.mfg_lot_size = part_mfg.mfg_lot_size,
		part_machine.process_id = part_mfg.process_id,
		part_machine.parts_per_cycle = part_mfg.parts_per_cycle,
		part_machine.parts_per_hour = part_mfg.parts_per_hour,
		part_machine.cycle_unit = part_mfg.cycle_unit,
		part_machine.cycle_time = part_mfg.cycle_time,
		part_machine.overlap_type = part_mfg.overlap_type,
		part_machine.overlap_time = part_mfg.overlap_time,
		part_machine.labor_code = part_mfg.labor_code,
		part_machine.setup_time = part_mfg.setup_time
	from part_mfg
	where part_mfg.part = part_machine.part
	' )
	
	execute ( '
	drop table part_mfg
	' )

end
go


if not exists ( select 1 from dbo.sysobjects where name = 'part_mfg' )
	execute ( '
	create view part_mfg(part,
	  mfg_lot_size,
	  process_id,
	  parts_per_cycle,
	  parts_per_hour,
	  cycle_unit,
	  cycle_time,
	  overlap_type,
	  overlap_time,
	  engineering_level,
	  drawing_number,
	  labor_code,
	  gl_account_code,
	  activity,
	  setup_time,
	  eng_effective_date)
	  as select part_machine.part,
	    part_machine.mfg_lot_size,
	    part_machine.process_id,
	    part_machine.parts_per_cycle,
	    part_machine.parts_per_hour,
	    part_machine.cycle_unit,
	    part_machine.cycle_time,
	    part_machine.overlap_type,
	    part_machine.overlap_time,
	    part.engineering_level,
	    part.drawing_number,
	    part_machine.labor_code,
	    part.gl_account_code,
	    part_machine.activity,
	    part_machine.setup_time,
	    part.eng_effective_date
	    from part_machine,part
	    where part_machine.sequence=1
	    and part_machine.part=part.part
	' )
go


if exists ( select * from dbo.sysobjects where id = object_id('mtr_part_machine_i'))
	drop trigger mtr_part_machine_i
go
 
if exists ( select * from dbo.sysobjects where id = object_id('mtr_part_machine_u'))
	drop trigger mtr_part_machine_u
go

if exists ( select * from dbo.sysobjects where id = object_id('mtr_part_machine_d'))
	drop trigger mtr_part_machine_d
go


update part_machine set part_machine.parts_per_hour =   isnull ( part_mfg.parts_per_hour, ( case part_mfg.cycle_unit
					 when 'DAY' then 0.042 
					 when 'MINUTE' then 60
					 when 'SECOND' then 3600
					 when 'HOUR' then 1 
 					 end )  *part_mfg.parts_per_cycle/part_mfg.cycle_time)
from part_mfg 
where part_mfg.part = part_machine.part and
	part_mfg.cycle_time >0 and  part_mfg.parts_per_cycle >0 
go


print'
----------------------------
-- part_machine_tool changes
----------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'part_machine_tool' )
	execute sp_rename part_machine_tool, part_machine_tool_temp
go

create table part_machine_tool (
       part                 varchar(25) not null,
       machine              varchar(10) not null,
       tool                 varchar(25) not null,
       quantity             numeric(20,6) not null
)
go

alter table part_machine_tool
       add primary key (part, machine, tool)
go

if exists ( select 1 from dbo.sysobjects where name = 'part_machine_tool_temp' )
begin
	declare @column_list varchar(255),
			@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
			dbo.syscolumns sc
		where	so.name = 'part_machine_tool_temp' and
			so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into part_machine_tool ( ' + @column_list + ' )
			select ' + @column_list + ' from part_machine_tool_temp
	' )

	execute ( '
		drop table part_machine_tool_temp
	' )	
end
go


print'
-----------------------
-- part_tooling changes
-----------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'part_tooling' )
	execute sp_rename part_tooling, part_tooling_temp
go

create table part_tooling (
       part                 varchar(25) not null,
       tool_number          varchar(25) not null,
       qty_part_per_tool    numeric(20,6) not null
)
go


alter table part_tooling
       add primary key (part, tool_number)
go

if exists ( select 1 from dbo.sysobjects where name = 'part_tooling_temp' )
begin
	declare @column_list varchar(255),
			@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
			dbo.syscolumns sc
		where	so.name = 'part_tooling_temp' and
			so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into part_tooling ( ' + @column_list + ' )
			select ' + @column_list + ' from part_tooling_temp
	' )

	execute ( '
		drop table part_tooling_temp
	' )	
end
go


print'
---------------------------------
-- part_machine_tool_list changes
---------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'part_machine_tool_list' )
	execute sp_rename part_machine_tool_list, part_machine_tool_list_temp
go

create table part_machine_tool_list (
       part                 varchar(25) not null,
       machine              varchar(10) not null,
       station_id           varchar(25) not null,
       station_type         char(1) not null,
       tool                 varchar(25) not null,
       tool_qty             integer not null,
       parts_per_tool       integer not null,
       tool_list_no         varchar(50) null
)
go


alter table part_machine_tool_list
       add primary key (part, machine, station_id, tool)
go

if exists ( select 1 from dbo.sysobjects where name = 'part_machine_tool_list_temp' )
begin
	declare @column_list varchar(255),
			@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
			dbo.syscolumns sc
		where	so.name = 'part_machine_tool_list_temp' and
			so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into part_machine_tool_list ( ' + @column_list + ' )
			select ' + @column_list + ' from part_machine_tool_list_temp
	' )

	execute ( '
		drop table part_machine_tool_list_temp
	' )	
end
go


print'
-------------------------------
-- part_type_definition changes
-------------------------------
'
begin
	declare	@fkname	varchar(100),
		@command varchar(255),
		@table varchar(255)
	
	declare fks cursor for
		select	so1.name,
			so2.name
		from 	dbo.sysreferences sr, 
			dbo.sysobjects so1, 
			dbo.sysobjects so2,
			dbo.sysobjects so3
		where  	sr.fkeyid = so1.id and
			so2.id = sr.constid and
			sr.rkeyid = so3.id and
			so3.name = 'part_type_definition'
	
	open fks
	fetch fks into @table,@fkname
	while ( @@fetch_status = 0 )
	begin
		select @command = 'alter table ' + @table + ' drop constraint ' + @fkname
		execute ( @command )
		fetch fks into @table,@fkname
	end
	close fks
	deallocate fks
end
go

if exists ( select 1 from dbo.sysobjects where name = 'part_type_definition' )
	execute sp_rename part_type_definition, part_type_definition_temp
go

create table part_type_definition (
       type                 char(1) not null,
       type_name            varchar(25) not null,
       status_flag          binary(8) null
)
go

alter table part_type_definition
       add primary key (type)
go

if exists ( select 1 from dbo.sysobjects where name = 'part_type_definition_temp' )
begin
	declare @column_list varchar(255),
			@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
			dbo.syscolumns sc
		where	so.name = 'part_type_definition_temp' and
			so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into part_type_definition ( ' + @column_list + ' )
			select ' + @column_list + ' from part_type_definition_temp
	' )

	execute ( '
		drop table part_type_definition_temp
	' )	
end
go

if not exists ( select 1 from part_type_definition where type = 'F' )
	insert into part_type_definition (type,type_name) values ('F','Finished')
go

if not exists ( select 1 from part_type_definition where type = 'R' )
	insert into part_type_definition (type,type_name) values ('R','Raw')
go

if not exists ( select 1 from part_type_definition where type = 'W' )
	insert into part_type_definition (type,type_name) values ('W','Wip')
go
if not exists ( select 1 from part_type_definition where type = 'O' )
	INSERT INTO part_type_definition ( type, type_name ) VALUES ( 'O', 'Obsolete')
go


print'
----------------------
-- part_vendor changes
----------------------
'
if not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'part_vendor' and sc.id = so.id and sc.name = 'part_name' and sc.length = 100 )
begin
	declare	@fkname	varchar(100),
			@command varchar(255),
			@table varchar(255)
	
	declare fks cursor for
		select	so1.name,
			so2.name
		from 	dbo.sysreferences sr, 
			dbo.sysobjects so1, 
			dbo.sysobjects so2,
			dbo.sysobjects so3
		where  	sr.fkeyid = so1.id and
			so2.id = sr.constid and
			sr.rkeyid = so3.id and
			so3.name = 'part_vendor'
	
	open fks
	fetch fks into @table,@fkname
	while ( @@fetch_status = 0 )
	begin
		select @command = 'alter table ' + @table + ' drop constraint ' + @fkname
		execute ( @command )
		fetch fks into @table,@fkname
	end
	close fks
	deallocate fks

	if exists ( select 1 from dbo.sysobjects where name = 'part_vendor' )
		execute sp_rename part_vendor, part_vendor_temp

	execute ( '
		create table part_vendor (
			part varchar (25) not null ,
			vendor varchar (10) not null ,
			vendor_part varchar (25) null ,
			vendor_standard_pack numeric(20, 6) null ,
			accum_received numeric(20, 6) null ,
			accum_shipped numeric(20, 6) null ,
			outside_process char (1) null ,
			qty_over_received numeric(20, 6) null ,
			receiving_um varchar (10) null ,
			part_name varchar (100) null ,
			lead_time numeric(6, 2) null ,
			min_on_order numeric(20, 6) null ,
			beginning_inventory_date datetime null 
		)
	' )

	execute ( '
		alter table part_vendor add primary key(part,vendor)
	' )

	if exists ( select 1 from dbo.sysobjects where name = 'part_vendor_temp' )
	begin
		declare @column_list varchar(255),
				@column varchar(100)
	
		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
				dbo.syscolumns sc
			where	so.name = 'part_vendor_temp' and
				so.id = sc.id and
				sc.name not in ( 'part','vendor','vendor_part','vendor_standard_pack','accum_received','accum_shipped','outside_process' )
	
		select @column_list = ''
	
		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			if isnull(@column_list,'') > ''
				select @column_list = @column_list + ',' + @column
			else
				select @column_list = @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list
	
		execute ( '
			insert into part_vendor ( part,vendor,vendor_part,vendor_standard_pack,accum_received,accum_shipped,outside_process,' + @column_list + ' )
				select part,vendor,vendor_part,vendor_standard_pack,accum_received,accum_shipped,outside_process,' + @column_list + ' from part_vendor_temp
		' )
	
		execute ( '
			drop table part_vendor_temp
		' )	
	end

--	if exists ( select 1 from dbo.sysobjects where name = 'part_vendor_price_matrix' )
--		alter table part_vendor_price_matrix add
--			constraint fk_pv_price_matrix1
--				foreign key (part,vendor) 
--				references part_vendor (part,vendor)
end
else
begin
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_vendor' and sc.id = so.id and sc.name = 'beginning_inventory_date' )
		alter table part_vendor add beginning_inventory_date datetime null
end
go


print'
-------------------
-- partlist changes
-------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'partlist' )
	execute sp_rename partlist, partlist_temp
go

create table partlist (
	part varchar (25) not null 
)
go

if exists ( select 1 from dbo.sysobjects where name = 'partlist_temp' )
begin
	declare @column_list varchar(255),
			@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
			dbo.syscolumns sc
		where	so.name = 'partlist_temp' and
			so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into partlist ( ' + @column_list + ' )
			select ' + @column_list + ' from partlist_temp
	' )

	execute ( '
		drop table partlist_temp
	' )	
end
go


print'
--------------------
-- po_header changes
--------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_po_header_u' )
	drop trigger mtr_po_header_u
go

if not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'po_header' and sc.id = so.id and sc.name = 'description' and sc.length = 100 ) or
   not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'po_header' and sc.id = so.id and sc.name = 'freight_type' and sc.length = 20 )
begin
	declare	@fkname	varchar(100),
		@command varchar(255),
		@table varchar(255)
	
	declare fks cursor for
		select	so1.name,
			so2.name
		from 	dbo.sysreferences sr, 
			dbo.sysobjects so1, 
			dbo.sysobjects so2,
			dbo.sysobjects so3
		where  	sr.fkeyid = so1.id and
			so2.id = sr.constid and
			sr.rkeyid = so3.id and
			so3.name = 'po_header'
	
	open fks
	fetch fks into @table,@fkname
	while ( @@fetch_status = 0 )
	begin
		select @command = 'alter table ' + @table + ' drop constraint ' + @fkname
		execute ( @command )
		fetch fks into @table,@fkname
	end
	close fks
	deallocate fks

	if exists ( select 1 from dbo.sysobjects where name = 'po_header' )
		execute sp_rename po_header, po_header_temp
	
	execute ( '
		create table po_header (
			po_number int not null ,
			vendor_code varchar (10) not null ,
			po_date datetime null ,
			date_due datetime null ,
			terms varchar (20) null ,
			fob varchar (20) null ,
			ship_via varchar (15) null ,
			ship_to_destination varchar (25) null ,
			status char (1) null ,
			type char (1) null ,
			description varchar (100) null ,
			plant varchar (10) null ,
			freight_type varchar (20) null ,
			buyer varchar (30) null ,
			printed char (1) null ,
			notes varchar (255) null ,
			total_amount numeric(20, 6) null ,
			shipping_fee numeric(20, 6) null ,
			sales_tax numeric(20, 6) null ,
			blanket_orderded_qty numeric(20, 6) null ,
			blanket_frequency varchar (15) null ,
			blanket_duration numeric(5, 0) null ,
			blanket_qty_per_release numeric(20, 6) null ,
			blanket_part varchar (25) null ,
			blanket_vendor_part varchar (30) null ,
			price numeric(20, 6) null ,
			std_unit varchar (2) null ,
			ship_type varchar (10) null ,
			flag int null ,
			release_no int null ,
			release_control char (1) null ,
			tax_rate numeric(4, 2) null ,
			scheduled_time datetime null ,
			trusted varchar (1) null ,
			currency_unit varchar(3) null,
			show_euro_amount smallint null
		)
	' )
	
	execute ( '
		alter table po_header add primary key(po_number)
	' )
	
	if exists ( select 1 from dbo.sysobjects where name = 'po_header_temp' )
	begin
		declare @column_list varchar(255),
				@column varchar(100)
	
		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
				dbo.syscolumns sc
			where	so.name = 'po_header_temp' and
				so.id = sc.id and
				sc.name not in ( 'po_number', 'vendor_code', 'po_date', 'date_due', 'terms', 'fob', 'ship_via', 'ship_to_destination', 'status', 'type', 'description',
				'plant', 'freight_type', 'buyer', 'printed', 'notes', 'total_amount', 'shipping_fee', 'sales_tax', 'blanket_orderded_qty', 'blanket_frequency', 'blanket_duration',
				'blanket_qty_per_release', 'blanket_part', 'blanket_vendor_part', 'price', 'std_unit', 'ship_type', 'flag', 'release_no', 'release_control' )
	
		select @column_list = ''
	
		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			select @column_list = @column_list + ',' + @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list
	
		execute ( '
			insert into po_header (  po_number, vendor_code, po_date, date_due, terms, fob, ship_via, ship_to_destination, status, type, description,
				plant, freight_type, buyer, printed, notes, total_amount, shipping_fee, sales_tax, blanket_orderded_qty, blanket_frequency, blanket_duration,
				blanket_qty_per_release, blanket_part, blanket_vendor_part, price, std_unit, ship_type, flag, release_no, release_control ' + @column_list + ' )
			select po_number, vendor_code, po_date, date_due, terms, fob, ship_via, ship_to_destination, status, type, description,
				plant, freight_type, buyer, printed, notes, total_amount, shipping_fee, sales_tax, blanket_orderded_qty, blanket_frequency, blanket_duration,
				blanket_qty_per_release, blanket_part, blanket_vendor_part, price, std_unit, ship_type, flag, release_no, release_control ' + @column_list + ' 
			from po_header_temp
		' )		
		execute ( '
			drop table po_header_temp
		' )
	end
	alter table po_detail add
		constraint fk_po_detail1
			foreign key (po_number) 
			references po_header (po_number)
end
else
begin
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_header' and sc.id = so.id and sc.name = 'tax_rate' )
		alter table po_header add tax_rate             numeric(4,2) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_header' and sc.id = so.id and sc.name = 'scheduled_time' )
		alter table po_header add scheduled_time datetime null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_header' and sc.id = so.id and sc.name = 'trusted' )
		alter table po_header add trusted varchar(1) null 

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_header' and sc.id = so.id and sc.name = 'currency_unit' )
		alter table po_header add currency_unit varchar(3) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_header' and sc.id = so.id and sc.name = 'show_euro_amount' )
		alter table po_header add show_euro_amount smallint null
end
go

update	po_header
set	type = 'N'
where	type is null
go


print'
-----------------------
-- product_line changes
-----------------------
'
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'product_line' and sc.id = so.id and sc.name = 'gl_segment' )
	alter table product_line add gl_segment           varchar(50) null
go


print'
---------------------------
-- production_shift changes
---------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'production_shift' )
	execute sp_rename production_shift, production_shift_temp
go

create table production_shift (
       part                 varchar(25) not null,
       location             varchar(10) not null,
       machine              varchar(10) null,
       tool                 varchar(15) null,
       activity             varchar(10) null,
       date_stamp           datetime null,
       time_stamp           datetime null,
       type                 varchar(1) null,
       production_time      numeric(10,2) null,
       start_time           datetime null,
       stop_time            datetime null,
       production_rate      numeric(10,2) null,
       fixtures_cavities    numeric(10,2) null,
       transaction_number   varchar(10) null,
       transaction_timestamp datetime not null,
       data_source          varchar(10) null,
       acum_production_qty  numeric(20,6) null,
       average_cycle_time   numeric(5) null,
       quantity             numeric(20,6) null,
       work_order_number    varchar(10) null
)
go

alter table production_shift
       add primary key (part, transaction_timestamp)
go

if exists ( select 1 from dbo.sysobjects where name = 'production_shift_temp' )
begin
	execute ( '
		insert into production_shift (part, location, machine, tool, activity, date_stamp, time_stamp, type, 
			production_time, start_time, stop_time, production_rate, fixtures_cavities, transaction_number, 
			transaction_timestamp, data_source, acum_production_qty, average_cycle_time, quantity, 
			work_order_number) select part, location, machine, tool, activity, date_stamp, time_stamp, type, 
			convert(numeric(10,2),production_time), start_time, stop_time, convert(numeric(10,2),
			production_rate), convert(numeric(10,2),fixtures_cavities), 
			transaction_number, transaction_timestamp, data_source, convert(numeric(20,6),acum_production_qty),
			convert(numeric(5),average_cycle_time), convert(numeric(20,6),quantity), 
			work_order_number from production_shift_temp
	' )

	execute ( '
		drop table production_shift_temp
	' )
end
go


print'
-----------------------
-- quote changes
-----------------------
'
if 	exists ( select 1 from dbo.systypes st,dbo.sysobjects so, dbo.syscolumns sc where so.name = 'quote' and sc.id = so.id and sc.name = 'quote_number' and st.usertype = sc.usertype and st.name = 'numeric' ) or
	exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'quote' and sc.id = so.id and sc.name = 'sales_order' )
begin
	declare	@fkname	varchar(100),
		@command varchar(255),
		@table varchar(255)
	
	declare fks cursor for
		select	so1.name,
			so2.name
		from 	dbo.sysreferences sr, 
			dbo.sysobjects so1, 
			dbo.sysobjects so2,
			dbo.sysobjects so3
		where  	sr.fkeyid = so1.id and
			so2.id = sr.constid and
			sr.rkeyid = so3.id and
			so3.name = 'quote'
	
	open fks
	fetch fks into @table,@fkname
	while ( @@fetch_status = 0 )
	begin
		select @command = 'alter table ' + @table + ' drop constraint ' + @fkname
		execute ( @command )
		fetch fks into @table,@fkname
	end
	close fks
	deallocate fks

	if exists ( select 1 from dbo.sysobjects where name = 'quote' )
		execute sp_rename quote, quote_temp

	execute ( '
	create table quote (
	       quote_number         integer not null,
	       customer             varchar(10) null,
	       quote_date           datetime null,
	       contact              varchar(25) null,
	       amount               numeric(20,6) null,
	       status               char(1) null,
	       destination          varchar(25) null,
	       salesman             varchar(35) null,
	       notes                varchar(255) null,
	       expire_date          datetime null,
	       lock_flag            smallint null
	)
	' )

	alter table quote
	       add primary key (quote_number)
	
	if exists ( select 1 from dbo.sysobjects where name = 'quote_temp' )
	begin
		declare @column_list varchar(255),
				@column varchar(100)
	
		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
				dbo.syscolumns sc
			where	so.name = 'quote_temp' and
				so.id = sc.id and
				sc.name not in ( 'quote_number', 'sales_order' )
	
		select @column_list = ''
	
		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			select @column_list = @column_list + ',' + @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list
	
		execute ( '
			insert into quote ( quote_number' + @column_list + ' )
				select convert(integer,quote_number)' + @column_list + ' from quote_temp
		' )
	
		execute ( '
			drop table quote_temp
		' )	
	end
end
else
begin
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'quote' and sc.id = so.id and sc.name = 'expire_date' )
		alter table quote add expire_date datetime null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'quote' and sc.id = so.id and sc.name = 'lock_flag' )
		alter table quote add lock_flag smallint null
end
go



print'
----------------------
-- region_code changes
----------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'region_code' )
	execute ( '
	create table region_code 
	( 
		code varchar(10) Not null , 
		description varchar(50) null , 
		Primary key (code)
	)
	' )
go


print'
----------------------
-- report_list changes
----------------------
'
begin
	declare	@fkname	varchar(100),
		@command varchar(255),
		@table varchar(255)
	
	declare fks cursor for
		select	so1.name,
			so2.name
		from 	dbo.sysreferences sr, 
			dbo.sysobjects so1, 
			dbo.sysobjects so2,
			dbo.sysobjects so3
		where  	sr.fkeyid = so1.id and
			so2.id = sr.constid and
			sr.rkeyid = so3.id and
			so3.name = 'report_list'
	
	open fks
	fetch fks into @table,@fkname
	while ( @@fetch_status = 0 )
	begin
		select @command = 'alter table ' + @table + ' drop constraint ' + @fkname
		execute ( @command )
		fetch fks into @table,@fkname
	end
	close fks
	deallocate fks
end
go

if exists ( select 1 from dbo.sysobjects where name = 'report_list' )
	execute sp_rename report_list, report_list_temp
go

create table report_list (
       report               varchar(25) not null,
       description          varchar(255) null
)
go

alter table report_list
       add primary key (report)
go

if exists ( select 1 from dbo.sysobjects where name = 'report_list_temp' )
begin
	declare @column_list varchar(255),
		@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
			dbo.syscolumns sc
		where	so.name = 'report_list_temp' and
			so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into report_list ( ' + @column_list + ' )
			select ' + @column_list + ' from report_list_temp
	' )

	execute ( '
		drop table report_list_temp
	' )	
end
go

if not exists ( select 1 from report_list where report = 'Label' )
	insert into report_list values ( 'Label', 'Label' )
go

if not exists ( select 1 from report_list where report = 'Report' )
	insert into report_list values ( 'Report', 'Report' )
go
if not exists ( select 1 from report_list where report = 'Bill Of Lading' )
 INSERT INTO report_list ( report, description ) 
 VALUES ( 'Bill Of Lading',
    'Bill Of Lading')
go
if not exists ( select 1 from report_list where report = 'Blanket PO' )
 INSERT INTO report_list ( report, description ) 
 VALUES ( 'Blanket PO',
    'Blanket PO')
go
if not exists ( select 1 from report_list where report = 'Canadian Custom' )
 INSERT INTO report_list ( report, description ) 
 VALUES ( 'Canadian Custom',
    'Customs form')
go
if not exists ( select 1 from report_list where report = 'Invoice' )
 INSERT INTO report_list ( report, description ) 
 VALUES ( 'Invoice',
    'Invoice')
go
if not exists ( select 1 from report_list where report = 'Outside Process' )
 INSERT INTO report_list ( report, description ) 
 VALUES ( 'Outside Process',
    'Outside Process')
go
if not exists ( select 1 from report_list where report = 'Packing List' )
 INSERT INTO report_list ( report, description ) 
 VALUES ( 'Packing List',
    'Pack List')
go
if not exists ( select 1 from report_list where report = 'Packlist Ret Vendor' )
 INSERT INTO report_list ( report, description ) 
 VALUES ( 'Packlist Ret Vendor',
    'Packlist Ret Vendor')
go
if not exists ( select 1 from report_list where report = 'Pick List' )
 INSERT INTO report_list ( report, description ) 
 VALUES ( 'Pick List',
    'Pick List')
go
if not exists ( select 1 from report_list where report = 'PO - Release' )
 INSERT INTO report_list ( report, description ) 
 VALUES ( 'PO - Release',
    'PO - Release')
go
if not exists ( select 1 from report_list where report = 'Quick Shipper' )
 INSERT INTO report_list ( report, description ) 
 VALUES ( 'Quick Shipper',
    'Quick Shipper')
go
if not exists ( select 1 from report_list where report = 'Sales Order - Normal' )
 INSERT INTO report_list ( report, description ) 
 VALUES ( 'Sales Order - Normal',
    'Sales Order - Normal')
go
if not exists ( select 1 from report_list where report = 'Drop Ship' )
 INSERT INTO report_list ( report, description ) 
 VALUES ( 'Drop Ship',
    'Drop Ship')
go
if not exists ( select 1 from report_list where report = 'Smart Label Format' )
 INSERT INTO report_list ( report, description ) 
 VALUES ( 'Smart Label Format',
    'Smart Label Format')
go
if not exists ( select 1 from report_list where report = 'PO - Release' )
 INSERT INTO report_list ( report, description ) 
 VALUES ( 'Normal PO',
    'Normal PO')
go

if not exists ( select 1 from report_list where report = 'Normal PO' )
 INSERT INTO report_list ( report, description ) 
 VALUES ( 'Normal PO',
    'Normal PO')
go
if not exists ( select 1 from report_list where report = 'RMA' )
	insert into report_list ( report, description ) values ( 'RMA',  'RMA')
go

if not exists
(
	select	1
	from	report_list
	where	report = 'Canadian Custom - Quick'
)
	insert into report_list (report,description)
	values ('Canadian Custom - Quick','Canadian Custom - Quick')
go

if not exists
(
	select	1
	from	report_list
	where	report = 'Engineering Certs - Quick'
)
	insert into report_list (report,description)
	values ('Engineering Certs - Quick','Engineering Certs - Quick')
go

if not exists ( select 1 from report_list where report = 'Sales Order - Blanket' )
	insert into report_list ( report, description )
	values ( 'Sales Order - Blanket', 'Sales Order - Blanket' )
go



print'
-----------------------------
-- sales_manager_code changes
-----------------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'sales_manager_code' )
	execute ( '
	create table sales_manager_code 
	( 
		code varchar(10) Not null , 
		description varchar(50) null , 
		Primary key (code)
	)
	' )
go


print'
--------------------------
-- scale_interface changes
--------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'scale_interface' )
	drop table scale_interface
go


print'
--------------------
-- setup_dws changes
--------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'setup_dws' )
	drop table setup_dws
go


print'
------------------
-- shipper changes
------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_shipper_i' )
	drop trigger mtr_shipper_i
go

if exists (
	select	1
	  from	sysobjects
	 where	id = object_id ( 'mtr_shipper_u' ) )
	drop trigger mtr_shipper_u
go

if exists ( select 1 from dbo.systypes st,dbo.syscolumns sc,dbo.sysobjects so where so.name = 'shipper' and sc.id = so.id and sc.name = 'bill_of_lading_number' and st.usertype = sc.usertype and st.name = 'varchar' )
begin
	declare	@fkname	varchar(100),
		@command varchar(255),
		@table varchar(255)
	
	declare fks cursor for
		select	so1.name,
			so2.name
		from 	dbo.sysreferences sr, 
			dbo.sysobjects so1, 
			dbo.sysobjects so2,
			dbo.sysobjects so3
		where  	sr.fkeyid = so1.id and
			so2.id = sr.constid and
			sr.rkeyid = so3.id and
			so3.name = 'shipper' and
			so1.name = 'shipper_detail'
	
	open fks
	fetch fks into @table,@fkname
	while ( @@fetch_status = 0 )
	begin
		select @command = 'alter table ' + @table + ' drop constraint ' + @fkname
		execute ( @command )
		fetch fks into @table,@fkname
	end
	close fks
	deallocate fks

	if exists ( select 1 from dbo.sysobjects where name = 'shipper' )
		execute sp_rename shipper, shipper_temp
	
	execute ( '
		create table shipper (
			id int NOT NULL ,
			destination varchar (20) NOT NULL ,
			shipping_dock varchar (15) NULL ,
			ship_via varchar (20) NULL ,
			status char (1) NULL ,
			date_shipped datetime NULL ,
			aetc_number varchar (20) NULL ,
			freight_type varchar (30) NULL ,
			printed char (1) NULL ,
			bill_of_lading_number integer NULL ,
			model_year_desc varchar (15) NULL ,
			model_year varchar (4) NULL ,
			customer varchar (25) NULL ,
			location varchar (20) NULL ,
			staged_objs int NULL ,
			plant varchar (10) NULL ,
			type char (1) NULL ,
			invoiced char (1) NULL ,
			invoice_number int NULL ,
			freight numeric(15, 6) NULL ,
			tax_percentage numeric(6, 3) NULL ,
			total_amount numeric(15, 6) NULL ,
			gross_weight numeric(20, 6) NULL ,
			net_weight numeric(20, 6) NULL ,
			tare_weight numeric(20, 6) NULL ,
			responsibility_code char (1) NULL ,
			trans_mode varchar (10) NULL ,
			pro_number varchar (35) NULL ,
			notes varchar (254) NULL ,
			time_shipped datetime NULL ,
			truck_number varchar (30) NULL ,
			invoice_printed char (1) NULL ,
			seal_number varchar (25) NULL ,
			terms varchar (25) NULL ,
			tax_rate numeric(20, 6) NULL ,
			staged_pallets int NULL ,
			container_message varchar (100) NULL ,
			picklist_printed char (1) NULL ,
			dropship_reconciled char (1) NULL ,
			date_stamp datetime NULL ,
			platinum_trx_ctrl_num varchar (16) NULL ,
			posted char (1) NULL ,
			scheduled_ship_time datetime NULL ,
			currency_unit varchar (3) NULL ,
			show_euro_amount smallint NULL ,
			cs_status varchar (20) NULL ,
			bol_ship_to varchar (20) NULL ,
			bol_carrier varchar (10) NULL,
			operator varchar (5)  null
		)
	' )
	
	execute ( '	
		alter table shipper add primary key ( id )
	' )

	if exists ( select 1 from dbo.sysobjects where name = 'shipper_temp' )
	begin
		declare @column_list varchar(255),
			@column varchar(100)

		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
				dbo.syscolumns sc
			where	so.name = 'shipper_temp' and
				so.id = sc.id and
				sc.name not in ( 'id','destination','shipping_dock','ship_via','status','date_shipped','aetc_number','freight_type','printed','bill_of_lading_number',
					'model_year_desc','model_year','customer','location','staged_objs','plant','type','invoiced','invoice_number','freight','tax_percentage','total_amount',
					'gross_weight','net_weight','tare_weight','responsibility_code','trans_mode','pro_number','notes','time_shipped','truck_number','invoice_printed',
					'seal_number','terms','tax_rate','staged_pallets','container_message','picklist_printed','dropship_reconciled','date_stamp','platinum_trx_ctrl_num',
					'posted' )

		select @column_list = ''

		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			select @column_list = @column_list + ',' + @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list


		execute ( '
			insert into shipper (id,destination,shipping_dock,ship_via,status,date_shipped,aetc_number,freight_type,printed,bill_of_lading_number,
				model_year_desc,model_year,customer,location,staged_objs,plant,type,invoiced,invoice_number,freight,tax_percentage,total_amount,
				gross_weight,net_weight,tare_weight,responsibility_code,trans_mode,pro_number,notes,time_shipped,truck_number,invoice_printed,
				seal_number,terms,tax_rate,staged_pallets,container_message,picklist_printed,dropship_reconciled,date_stamp,platinum_trx_ctrl_num,
				posted' + @column_list + ' ) select id,destination,shipping_dock,ship_via,status,date_shipped,aetc_number,freight_type,printed,convert(int,bill_of_lading_number),
				model_year_desc,model_year,customer,location,staged_objs,plant,type,invoiced,invoice_number,freight,tax_percentage,total_amount,
				gross_weight,net_weight,tare_weight,responsibility_code,trans_mode,pro_number,notes,time_shipped,truck_number,invoice_printed,
				seal_number,terms,tax_rate,staged_pallets,container_message,picklist_printed,dropship_reconciled,date_stamp,platinum_trx_ctrl_num,
				posted' + @column_list + ' from shipper_temp
		' )
		
		execute ( '
			drop table shipper_temp
		' )
	end
	
	create index bi_shipper_pl1 ON shipper ( status, date_stamp )

	CREATE  INDEX invoicenum_index ON dbo.shipper(invoice_number) WITH  FILLFACTOR = 90

	alter table shipper_detail add
		constraint fk_shipper_detail1
			foreign key (shipper) 
			references shipper (id)
end
else
begin
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'shipper' and sc.id = so.id and sc.name = 'scheduled_ship_time' )
		alter table shipper add scheduled_ship_time  datetime null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'shipper' and sc.id = so.id and sc.name = 'currency_unit' )
		alter table shipper add currency_unit varchar(3) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'shipper' and sc.id = so.id and sc.name = 'show_euro_amount' )
		alter table shipper add show_euro_amount smallint null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'shipper' and sc.id = so.id and sc.name = 'cs_status' )
		alter table shipper add cs_status varchar(20) null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'shipper' and sc.id = so.id and sc.name = 'operator' )
		alter table shipper add operator varchar (5)  null
end
go

update shipper set cs_status = css.status_name
from customer_service_status css
where shipper.cs_status is null and
	css.default_value = 'Y'
go

begin
	create table #temp_indexes
	(
		index_name		varchar(125),
		index_description	varchar(125),
		index_keys		varchar(125)
	)

	insert into #temp_indexes
	execute sp_helpindex shipper

	if not exists ( select 1 from #temp_indexes where index_keys like '%customer%' and index_keys like '%date_shipped%' )
		CREATE  INDEX bwa_shipper_cust_indx ON dbo.shipper(customer, date_shipped) WITH  FILLFACTOR = 90

	drop table #temp_indexes
end
go


print'
------------------------------
-- shop_floor_calendar changes
------------------------------
'
if exists (select 1 from dbo.sysobjects where name = 'shop_floor_calendar')
	execute sp_rename shop_floor_calendar, shop_floor_calendar_t
GO

if not exists (select 1 from dbo.sysobjects where name = 'shop_floor_calendar')
	execute ( '
	CREATE TABLE shop_floor_calendar (
		ai_id	int NOT NULL identity PRIMARY KEY,
		machine varchar (10) NOT NULL ,
		begin_datetime datetime NOT NULL ,
		end_datetime datetime NULL ,
		labor_code varchar (25) NULL ,
		crew_size int NULL
	)
	' )
go

if exists (select 1 from dbo.sysobjects where name = 'shop_floor_calendar_t')
begin
	-- generate column list from system tables for backup table
	-- (make sure to exclude deleted columns)
	declare @column_list1 varchar(255),
		@column_list2 varchar(255),
		@column varchar(100)
		
	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
			dbo.syscolumns sc
		where	so.name = 'shop_floor_calendar_t' and
			so.id = sc.id 
			and sc.name <> 'ai_id'

	select @column_list1 = ''
	select @column_list2 = ''
	
	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if @column_list1 > ''
		begin
			if 	( select datalength ( @column_list1 ) ) >= 255 or
				( select datalength ( @column_list1 ) + datalength ( @column ) + 1 ) >= 255
			begin
				if @column_list2 > ''
					select @column_list2 = @column_list2 + ',' + @column
				else
					select @column_list2 = ',' + @column
			end
			else
				select @column_list1 = @column_list1 + ',' + @column
		end
		else
			select @column_list1 = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( 'insert into shop_floor_calendar ( ' + @column_list1 + @column_list2 + ' ) select ' + @column_list1 + @column_list2 + ' from shop_floor_calendar_t' )

	-- perform insert from backup table to newly created table
	-- if insert was a success, drop backup table
	if @@error = 0
		execute ( 'drop table shop_floor_calendar_t' )
	
end
go

alter table shop_floor_calendar add UNIQUE NONCLUSTERED ( machine,begin_datetime)
go


print'
------------------------------
-- shop_floor_time_log changes
------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'shop_floor_time_log' ) and
   not exists ( select 1 from dbo.sysobjects where name = 'shop_floor_time_log_temp' )
	execute sp_rename shop_floor_time_log, shop_floor_time_log_temp
go

create table shop_floor_time_log (
	log_date datetime not null ,
	shift smallint null ,
	operator varchar (10) not null ,
	activity varchar (25) null ,
	location varchar (10) null ,
	part varchar (25) null ,
	qty numeric(20, 6) null ,
	labor_hours numeric(10, 2) null ,
	work_order varchar (10) null ,
	transaction_date_time datetime not null ,
	status varchar (1) null
)
go

alter table shop_floor_time_log add primary key ( operator,transaction_date_time )
go

if exists ( select 1 from dbo.sysobjects where name = 'shop_floor_time_log_temp' )
begin
	execute ( '
		insert into shop_floor_time_log ( log_date,shift,operator,activity,location,part,qty,labor_hours,work_order,transaction_date_time,status )
			select log_date,shift,operator,activity,location,part,qty,labor_hours,work_order,transaction_date_time,status from shop_floor_time_log_temp
	' )

	execute ( '
		drop table shop_floor_time_log_temp
	' )
end
go


print'
-------------------------
-- temp_bom_stack changes
-------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'temp_bom_stack' )
	drop table temp_bom_stack
go

create table temp_bom_stack (
       part                 varchar(25) null,
       partlevel            smallint null,
       spid                 smallint null
)
go


print'
---------------------------
-- temp_bomec_stack changes
---------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'temp_bomec_stack' )
	drop table temp_bomec_stack
go

create table temp_bomec_stack (
       parent_part          varchar(25) null,
       part                 varchar(25) null,
       item_level           smallint null,
       start_datetime       datetime null,
       end_datetime         datetime null,
       substitute_part      varchar(1) null,
       type                 varchar(1) null,
       spid                 integer not null
)
go


print'
-------------------
-- time_log changes
-------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'time_log' )
	execute sp_rename time_log, time_log_temp
go

create table time_log (
       id                   integer not null,
       employee             varchar(35) null,
       time_logged          numeric(5,2) null,
       notes                varchar(255) null,
       log_date             datetime not null,
       log_time             datetime not null,
       type                 char(1) null,
       source               integer null,
       workorder            varchar(10) null
)
go

alter table time_log
       add primary key (id, log_date, log_time)
go

if exists ( select 1 from dbo.sysobjects where name = 'time_log_temp' )
begin
	execute ( '
		insert into time_log (id, employee, time_logged, notes, log_date, log_time, type, source, workorder) 
			select id, employee, time_logged, notes, log_date, log_time, type, source, workorder from time_log_temp
	' )

	execute ( '
		drop table time_log_temp
	' )
end
go


print'
-------------------
-- unit_sub changes
-------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'unit_sub' )
	execute sp_rename unit_sub, unit_sub_temp
go

create table unit_sub (
       unit_group           varchar(2) not null,
       sequence             numeric(3) not null,
       sub_unit             varchar(10) null,
       name_1               varchar(10) null,
       name_2               varchar(10) null,
       short_name           varchar(2) null,
       symbol               varchar(1) null,
       factor               numeric(6,2) null
)
go


alter table unit_sub
       add primary key (unit_group, sequence)
go

if exists ( select 1 from dbo.sysobjects where name = 'unit_sub_temp' )
begin
	declare @column_list varchar(255),
		@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
			dbo.syscolumns sc
		where	so.name = 'unit_sub_temp' and
			so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into unit_sub ( ' + @column_list + ' )
			select ' + @column_list + ' from unit_sub_temp
	' )

	execute ( '
		drop table unit_sub_temp
	' )	
end
go


print'
----------------------
-- user_definable_data
----------------------
'
if not exists ( select 1 from user_definable_data where module = 'VM' and sequence = 1 and code = ' ' )
	insert into user_definable_data VALUES ('VM',1,' ',' ')
GO

if not exists ( select 1 from user_definable_data where module = 'VM' and sequence = 2 and code = ' ' )
	insert into user_definable_data VALUES ('VM',2,' ',' ')
GO

if not exists ( select 1 from user_definable_data where module = 'VM' and sequence = 3 and code = ' ' )
	insert into user_definable_data VALUES ('VM',3,' ',' ')
GO

if not exists ( select 1 from user_definable_data where module = 'VM' and sequence = 4 and code = ' ' )
	insert into user_definable_data VALUES ('VM',4,' ',' ')
GO

if not exists ( select 1 from user_definable_data where module = 'VM' and sequence = 5 and code = ' ' )
	insert into user_definable_data VALUES ('VM',5,' ',' ')
GO

if not exists ( select 1 from user_definable_data where module = 'CM' and sequence = 1 and code = ' ' )
	INSERT INTO user_definable_data VALUES ( 'CM', 1, ' ', ' ')
GO

if not exists ( select 1 from user_definable_data where module = 'CM' and sequence = 2 and code = ' ' )
	INSERT INTO user_definable_data VALUES ( 'CM', 2, ' ', ' ')
GO

if not exists ( select 1 from user_definable_data where module = 'CM' and sequence = 3 and code = ' ' )
	INSERT INTO user_definable_data VALUES ( 'CM', 3, ' ', ' ')
GO

if not exists ( select 1 from user_definable_data where module = 'CM' and sequence = 4 and code = ' ' )
	INSERT INTO user_definable_data VALUES ( 'CM', 4, ' ', ' ')
GO

if not exists ( select 1 from user_definable_data where module = 'CM' and sequence = 5 and code = ' ' )
	INSERT INTO user_definable_data VALUES ( 'CM', 5, ' ', ' ')
GO


print'
-------------------------------
-- user_definable_module_labels
-------------------------------
'
if not exists ( select 1 from user_definable_module_labels where module = 'VM' and sequence = 1 )
	insert into user_definable_module_labels VALUES ('VM',1,'Custom1:','N')
GO

if not exists ( select 1 from user_definable_module_labels where module = 'VM' and sequence = 2 )
	insert into user_definable_module_labels VALUES ('VM',2,'Custom2:','N')
GO

if not exists ( select 1 from user_definable_module_labels where module = 'VM' and sequence = 3 )
	insert into user_definable_module_labels VALUES ('VM',3,'Custom3:','N')
GO

if not exists ( select 1 from user_definable_module_labels where module = 'VM' and sequence = 4 )
	insert into user_definable_module_labels VALUES ('VM',4,'Custom4:','N')
GO

if not exists ( select 1 from user_definable_module_labels where module = 'VM' and sequence = 5 )
	insert into user_definable_module_labels VALUES ('VM',5,'Custom5:','N')
GO

if not exists ( select 1 from user_definable_module_labels where module = 'CM' and sequence = 1 )
	INSERT INTO user_definable_module_labels VALUES ( 'CM', 1, 'Custom1:', 'N')
GO

if not exists ( select 1 from user_definable_module_labels where module = 'CM' and sequence = 2 )
	INSERT INTO user_definable_module_labels VALUES ( 'CM', 2, 'Custom2:', 'N')
GO

if not exists ( select 1 from user_definable_module_labels where module = 'CM' and sequence = 3 )
	INSERT INTO user_definable_module_labels VALUES ( 'CM', 3, 'Custom3:', 'N')
GO

if not exists ( select 1 from user_definable_module_labels where module = 'CM' and sequence = 4 )
	INSERT INTO user_definable_module_labels VALUES ( 'CM', 4, 'Custom4:', 'N')
GO

if not exists ( select 1 from user_definable_module_labels where module = 'CM' and sequence = 5 )
	INSERT INTO user_definable_module_labels VALUES ( 'CM', 5, 'Custom5:', 'N')
GO

if not exists ( select 1 from user_definable_module_labels where module = 'IT' and sequence = 1 )
	Insert into user_definable_module_labels values ( 'IT', 1, 'Custom1:', 'N')
go

if not exists ( select 1 from user_definable_module_labels where module = 'IT' and sequence = 2 )
	Insert into user_definable_module_labels values ( 'IT', 2, 'Custom2:', 'N')
go

if not exists ( select 1 from user_definable_module_labels where module = 'IT' and sequence = 3 )
	Insert into user_definable_module_labels values ( 'IT', 3, 'Custom3:', 'N')
go

if not exists ( select 1 from user_definable_module_labels where module = 'IT' and sequence = 4 )
	Insert into user_definable_module_labels values ( 'IT', 4, 'Custom4:', 'N')
go

if not exists ( select 1 from user_definable_module_labels where module = 'IT' and sequence = 5 )
	Insert into user_definable_module_labels values ( 'IT', 5, 'Custom5:', 'N')
go


print'
-----------------
-- vendor changes
-----------------
'
if not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'vendor' and sc.id = so.id and sc.name = 'phone' and sc.length = 20 ) or
   not exists ( select 1 from dbo.syscolumns sc,dbo.sysobjects so where so.name = 'vendor' and sc.id = so.id and sc.name = 'fax' and sc.length = 20 )
begin
	if exists ( select 1 from dbo.sysobjects where name = 'vendor' )
		execute sp_rename vendor, vendor_backup
	
	if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.id = sc.id and so.name = 'vendor_backup' and sc.name = 'empower_flag' )
		execute ( '
		create table vendor (
			code varchar (10) not null,
			name varchar (35) not null,
			outside_processor char (1) null,
			contact varchar (35) null,
			phone varchar (20) null,
			terms varchar (20) null,
			ytd_sales numeric (20,6) null,
			balance numeric (20,6) null,
			frieght_type varchar (15) null,
			fob varchar (10) null,
			buyer varchar (30) null,
			plant varchar (10) null,
			ship_via varchar (15) null,
			company varchar (10) null,
			address_1 varchar (50) null,
			address_2 varchar (50) null,
			address_3 varchar (50) null,
			fax varchar (20) null,
			flag int null,
			partial_release_update char (1) null,
			trusted varchar (1) null,
			address_4 varchar (40) null,
			address_5 varchar (40) null,
			address_6 varchar (40) null,
			kanban char (1) null,
			default_currency_unit varchar (3) null,
			show_euro_amount smallint null,
			empower_flag varchar(8) null
		)
		' )
	else
		execute ( '
		create table vendor (
			code varchar (10) not null,
			name varchar (35) not null,
			outside_processor char (1) null,
			contact varchar (35) null,
			phone varchar (20) null,
			terms varchar (20) null,
			ytd_sales numeric (20,6) null,
			balance numeric (20,6) null,
			frieght_type varchar (15) null,
			fob varchar (10) null,
			buyer varchar (30) null,
			plant varchar (10) null,
			ship_via varchar (15) null,
			company varchar (10) null,
			address_1 varchar (50) null,
			address_2 varchar (50) null,
			address_3 varchar (50) null,
			fax varchar (20) null,
			flag int null,
			partial_release_update char (1) null,
			trusted varchar (1) null,
			address_4 varchar (40) null,
			address_5 varchar (40) null,
			address_6 varchar (40) null,
			kanban char (1) null,
			default_currency_unit varchar (3) null,
			show_euro_amount smallint null
		)
		' )
	
	alter table vendor add primary key ( code )
	
	if exists ( select 1 from dbo.sysobjects where name = 'vendor_backup' )
	begin
		declare @column_list varchar(255),
			@column varchar(100)

		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
				dbo.syscolumns sc
			where	so.name = 'vendor_backup' and
					so.id = sc.id and
					sc.name not in ( 'code', 'name', 'outside_processor' )

		select @column_list = ''

		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			if isnull(@column_list,'') > ''
				select @column_list = @column_list + ',' + @column
			else
				select @column_list = @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list

		execute ( '
			insert into vendor ( code,name,outside_processor,' + @column_list + ' ) 
				select	code,name,outside_processor,' + @column_list + '
		   		from 	vendor_backup 
		' )

		execute ( '
			drop table vendor_backup
		' )
	end
		
end
else
begin 
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'vendor' and sc.id = so.id and sc.name = 'address_4' )
		alter table vendor add address_4 varchar(40) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'vendor' and sc.id = so.id and sc.name = 'address_5' )
		alter table vendor add address_5 varchar(40) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'vendor' and sc.id = so.id and sc.name = 'address_6' )
		alter table vendor add address_6 varchar(40) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'vendor' and sc.id = so.id and sc.name = 'kanban' )
		alter table vendor add kanban    char(1) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'vendor' and sc.id = so.id and sc.name = 'trusted' )
		alter table vendor add trusted varchar(1) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'vendor' and sc.id = so.id and sc.name = 'default_currency_unit' )
		alter table vendor add default_currency_unit varchar(3) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'vendor' and sc.id = so.id and sc.name = 'show_euro_amount' )
		alter table vendor add show_euro_amount smallint null
end
go


print'
------------------------
-- vendor_custom changes
------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'vendor_custom' ) 
	execute sp_rename vendor_custom, vendor_custom_temp
go

create table vendor_custom (code varchar (10) not null ,
	custom1 varchar (25) null ,
	custom2 varchar (25) null ,
	custom3 varchar (25) null ,
	custom4 varchar (25) null ,
	custom5 varchar (25) null
)
go

alter table vendor_custom add primary key ( code ) 
go

if exists ( select 1 from dbo.sysobjects where name = 'vendor_custom_temp' )
begin
	declare @column_list varchar(255),
		@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
			dbo.syscolumns sc
		where	so.name = 'vendor_custom_temp' and
			so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into vendor_custom ( ' + @column_list + ' )
			select ' + @column_list + ' from vendor_custom_temp
	' )

	execute ( '
		drop table vendor_custom_temp
	' )	
end
go


print'
------------------------------
-- customer_additional changes
------------------------------
'
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer_additional' and sc.id = so.id and sc.name = 'start_date' )
	alter table customer_additional add start_date           datetime null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer_additional' and sc.id = so.id and sc.name = 'end_date' )
	alter table customer_additional add end_date             datetime null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer_additional' and sc.id = so.id and sc.name = 'closure_rate' )
	alter table customer_additional add closure_rate         numeric(5,2) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer_additional' and sc.id = so.id and sc.name = 'ontime_rate' )
	alter table customer_additional add ontime_rate          numeric(5,2) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'customer_additional' and sc.id = so.id and sc.name = 'return_rate' )
	alter table customer_additional add return_rate          numeric(5,2) null
go


print'
-----------------------
-- issue_detail changes
-----------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'issue_detail' )
begin
	execute ( '
		create table issue_detail
		(
			issue_number    integer not null,
			status_old      varchar(25) not null,
			status_new      varchar(25) not null,
			date_stamp      datetime not null,
			notes     text not null,
			origin          varchar(50) not null
		)
	' )
	
	execute ( '
		alter table issue_detail add primary key (issue_number, date_stamp)
	' )

	execute ( '
		alter table issue_detail
			add foreign key (issue_number) 
			references issues (issue_number)
	' )
end
go


print'
-----------------------------
-- issue_sub_category changes
-----------------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'issues_sub_category' )
begin
	execute ( '
		create table issues_sub_category
		(
			category        varchar(50) not null,
			sub_category    varchar(50) not null,
			default_value   varchar(1) not null
		)
	' )

	execute ( '
		alter table issues_sub_category add primary key (category, sub_category)
	' )

	execute ( '
		alter table issues_sub_category
		 add foreign key (category) 
		 references issues_category (category)
	' )
end
go


print'
-----------------
-- kanban changes
-----------------
'
if exists ( select 1 from dbo.sysobjects where name = 'kanban' ) 
	execute sp_rename kanban, kanban_temp
go

create table kanban (
       kanban_number        varchar(6) not null,
       order_no             numeric(8) not null,
       line11               varchar(21) null,
       line12               varchar(21) null,
       line13               varchar(21) null,
       line14               varchar(21) null,
       line15               varchar(21) null,
       line16               varchar(21) null,
       line17               varchar(21) null,
       status               char(1) not null,
       standard_quantity    numeric(20,6) not null
)
go

alter table kanban
       add primary key (kanban_number, order_no)
go

if exists ( select 1 from dbo.sysobjects where name = 'kanban_temp' )
begin
	execute ( '
		insert into kanban (kanban_number, order_no, line11, line12, line13, line14, 
		    line15, line16, line17, status, standard_quantity) select kanban_number, 
		    convert(numeric(8),order_no), line11, line12, line13, line14, line15, 
		    line16, line17, status, convert(numeric(20,6),standard_quantity) from 
		    kanban_temp
	' )

	execute ( '
		drop table kanban_temp
	' )	
end
go

alter table kanban
	add foreign key (order_no)
	references order_header
go


print'
------------------------------
-- machine_serial_comm changes
------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'machine_serial_comm' ) 
	execute sp_rename machine_serial_comm, machine_serial_comm_temp
go

create table machine_serial_comm (
       machine              varchar(10) not null,
       serial_port          smallint not null,
       serial_prompt        char(1) not null,
       serial_interface     varchar(10) null,
       winwedge_location    varchar(255) null,
       wwconfig_location    varchar(255) null,
       amount_field         smallint null,
       steady_field         smallint null,
       steady_char          varchar(1) null
)
go

alter table machine_serial_comm
       add primary key (machine)
go

if exists ( select 1 from dbo.sysobjects where name = 'machine_serial_comm_temp' )
begin
	declare @column_list varchar(255),
		@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
			dbo.syscolumns sc
		where	so.name = 'machine_serial_comm_temp' and
			so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into machine_serial_comm ( ' + @column_list + ' )
			select ' + @column_list + ' from machine_serial_comm_temp join machine on machine_no = machine
	' )

	execute ( '
		drop table machine_serial_comm_temp
	' )	
end
go

alter table machine_serial_comm
       add foreign key (machine)
                             references machine
go


print'
-----------------------
-- order_detail changes
-----------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_order_detail_i' )
	drop trigger mtr_order_detail_i
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_order_detail_d' )
	drop trigger mtr_order_detail_d
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_order_detail_u' )
	drop trigger mtr_order_detail_u
go

update order_detail set quantity = quantity - 1
go

if ( exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_detail' and sc.id = so.id and sc.name = 'box_label' ) and
	not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_detail' and sc.id = so.id and sc.name = 'box_label' and sc.length = 25 ) ) or
	( exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_detail' and sc.id = so.id and sc.name = 'pallet_label' ) and
	not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_detail' and sc.id = so.id and sc.name = 'pallet_label' and sc.length = 25 ) ) or
	not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.id = sc.id and so.name = 'order_detail' and sc.name = 'product_name' and sc.length = 100 ) or
	not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.id = sc.id and so.name = 'order_detail' and sc.name = 'id' )
begin
	-- drop order_detail foreign key pointing to order_header
	declare	@fkname	varchar(100),
		@command varchar(255),
		@table varchar(255)
	
	declare fks cursor for
		select	so1.name,
			so2.name
		from 	dbo.sysreferences sr, 
			dbo.sysobjects so1, 
			dbo.sysobjects so2,
			dbo.sysobjects so3
		where  	sr.fkeyid = so1.id and
			so2.id = sr.constid and
			sr.rkeyid = so3.id and
			so1.name = 'order_detail'
	open fks
	fetch fks into @table,@fkname
	while ( @@fetch_status = 0 )
	begin
		select @command = 'alter table ' + @table + ' drop constraint ' + @fkname
		execute ( @command )
		fetch fks into @table,@fkname
	end
	close fks
	deallocate fks

	if exists ( select 1 from sysindexes where name = 'destination_part' )
		drop index order_detail.destination_part

	if exists ( select 1 from sysindexes where name = 'rowid' )
		drop index order_detail.rowid

	if exists ( select 1 from dbo.sysobjects where name = 'order_detail' )
		execute sp_rename order_detail, order_detail_temp
		
	execute ( '
	CREATE TABLE order_detail (
		id			integer not null identity,
		order_no		numeric(8, 0) NOT NULL ,
		sequence 		numeric(5,0) NOT NULL ,
		part_number 		varchar (25) NOT NULL ,
		type 			char (1) NULL ,
		product_name 		varchar (100) NULL ,
		quantity 		numeric(20, 6) NULL ,
		price 			numeric(20, 6) NULL ,
		notes 			varchar (255) NULL ,
		assigned 		varchar (35) NULL ,
		shipped 		numeric(20, 6) NULL ,
		invoiced 		numeric(20, 6) NULL ,
		status 			char (1) NULL ,
		our_cum 		numeric(20, 6) NULL ,
		the_cum 		numeric(20, 6) NULL ,
		due_date 		datetime NULL ,
		destination 		varchar (25) NULL ,
		unit 			varchar (2) NULL ,
		committed_qty 		numeric(20, 6) NULL ,
		row_id 			int NULL ,
		group_no 		varchar (10) NULL ,
		cost 			numeric(20, 6) NULL ,
		plant 			varchar (10) NULL ,
		release_no 		varchar (30) NULL ,
		flag 			int NULL ,
		week_no 		int NULL ,
		std_qty 		numeric(20, 6) NULL ,
		customer_part 		varchar (30) NULL ,
		ship_type 		char (1) NULL ,
		dropship_po 		int NULL ,
		dropship_po_row_id	int NULL ,
		suffix 			int NULL ,
		packline_qty 		numeric(20, 6) NULL,
		packaging_type 		varchar (20) NULL ,
		weight 			numeric(20, 6) NULL ,
		custom01 		varchar (30) NULL ,
		custom02 		varchar (30) NULL ,
		custom03 		varchar (30) NULL ,
		dimension_qty_string 	varchar (50) NULL ,
		engineering_level 	varchar (25) NULL ,
		box_label 		varchar (25) NULL ,
		pallet_label 		varchar (25) NULL ,
		alternate_price 	decimal(20, 6) NULL
	)
	' )
	
	alter table order_detail add primary key ( id )	

	if exists ( select 1 from dbo.sysobjects where name = 'order_detail_temp' )
	begin
		declare @column_list varchar(255),
			@column varchar(100)
		
		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
				dbo.syscolumns sc
			where	so.name = 'order_detail_temp' and
				so.id = sc.id and
				sc.name not in ( 'order_no','sequence','part_number','type','product_name','quantity','price','notes','assigned','shipped',
				'invoiced','status','our_cum','the_cum','due_date','destination','unit','committed_qty','row_id','group_no','cost','plant',
				'release_no','flag','week_no','std_qty','customer_part','ship_type','dropship_po','dropship_po_row_id','suffix','packline_qty',
				'packaging_type','weight','custom01','custom02', 'id' )
		
		select @column_list = ''
		
		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			if isnull(@column_list,'') > ''
				select @column_list = @column_list + ',' + @column
			else
				select @column_list = @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list
		
		execute ( '
			insert into order_detail ( order_no,sequence,part_number,type,product_name,quantity,price,notes,assigned,shipped,
				invoiced,status,our_cum,the_cum,due_date,destination,unit,committed_qty,row_id,group_no,cost,plant,
				release_no,flag,week_no,std_qty,customer_part,ship_type,dropship_po,dropship_po_row_id,suffix,packline_qty,
				packaging_type,weight,custom01,custom02,' + @column_list + ' )
				select order_no,sequence,part_number,type,product_name,quantity,price,notes,assigned,shipped,
				invoiced,status,our_cum,the_cum,due_date,destination,unit,committed_qty,row_id,group_no,cost,plant,
				release_no,flag,week_no,std_qty,customer_part,ship_type,dropship_po,dropship_po_row_id,suffix,packline_qty,
				packaging_type,weight,custom01,custom02,' + @column_list + ' from order_detail_temp
		' )
		
		execute ( '
			drop table order_detail_temp
		' )
	end
	
	alter table order_detail add
		constraint fk_order_detail_1
			foreign key (order_no) 
			references order_header (order_no)


end
else
begin
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_detail' and sc.id = so.id and sc.name = 'dimension_qty_string' )
		alter table order_detail add dimension_qty_string varchar(50) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_detail' and sc.id = so.id and sc.name = 'engineering_level' )
		alter table order_detail add engineering_level varchar ( 25 ) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_detail' and sc.id = so.id and sc.name = 'alternate_price' )
		alter table order_detail add alternate_price decimal(20,6) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_detail' and sc.id = so.id and sc.name = 'box_label' )
		alter table order_detail add box_label varchar(25) null  
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'order_detail' and sc.id = so.id and sc.name = 'pallet_label' )
		alter table order_detail add pallet_label varchar(25) null
end
go


begin
	create table #temp_indexes
	(
		index_name		varchar(125),
		index_description	varchar(125),
		index_keys		varchar(125)
	)

	insert into #temp_indexes
	execute sp_helpindex order_detail

	if not exists ( select 1 from #temp_indexes where index_keys like '%destination%' and index_keys like '%part_number%' )
		CREATE  INDEX destination_part ON dbo.order_detail(destination, part_number) WITH  FILLFACTOR = 90
	
	if not exists ( select 1 from #temp_indexes where index_keys like '%order_no%' and index_keys like '%row_id%' )
		CREATE  INDEX order_rowid ON dbo.order_detail(order_no, row_id) WITH  FILLFACTOR = 90
	
	if not exists ( select 1 from #temp_indexes where index_keys = 'row_id' )
		CREATE  INDEX rowid ON dbo.order_detail(row_id) WITH  FILLFACTOR = 90

	drop table #temp_indexes

end
go

update	order_detail
set	alternate_price = price
where	alternate_price is null and
	price is not null
go

update	order_detail
set	order_detail.box_label = oh.box_label,
	order_detail.pallet_label = oh.pallet_label
from	order_header oh
where	order_detail.order_no = oh.order_no and
	oh.order_type = 'B'
go

-- fix row_id in order_detail
delete from master_prod_sched
go

update order_detail set row_id = sequence, flag = 1
go


print'
------------------------------------
-- part_class_type_cross_ref changes
------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'part_class_type_cross_ref' ) 
	execute sp_rename part_class_type_cross_ref, part_class_type_cross_ref_tmp
go

create table part_class_type_cross_ref (
       class                char(1) not null,
       type                 char(1) not null
)
go

alter table part_class_type_cross_ref
       add primary key (class, type)
go

if exists ( select 1 from dbo.sysobjects where name = 'part_class_type_cross_ref_tmp' )
begin
	declare @column_list varchar(255),
		@column varchar(100)

	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
			dbo.syscolumns sc
		where	so.name = 'part_class_type_cross_ref_tmp' and
			so.id = sc.id

	select @column_list = ''

	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into part_class_type_cross_ref ( ' + @column_list + ' )
			select ' + @column_list + ' from part_class_type_cross_ref_tmp
	' )

	execute ( '
		drop table part_class_type_cross_ref_tmp
	' )	
end
go

alter table part_class_type_cross_ref
       add foreign key (class)
                             references part_class_definition
go

alter table part_class_type_cross_ref
       add foreign key (type)
                             references part_type_definition
go

if not exists ( select 1 from part_class_type_cross_ref where class = 'C' and type = 'F' )
	insert into part_class_type_cross_ref values ('C','F')
go

if not exists ( select 1 from part_class_type_cross_ref where class = 'C' and type = 'R' )
	insert into part_class_type_cross_ref values ('C','R')
go

if not exists ( select 1 from part_class_type_cross_ref where class = 'C' and type = 'W' )
	insert into part_class_type_cross_ref values ('C','W')
go

if not exists ( select 1 from part_class_type_cross_ref where class = 'M' and type = 'F' )
	insert into part_class_type_cross_ref values ('M','F')
go

if not exists ( select 1 from part_class_type_cross_ref where class = 'M' and type = 'W' )
	insert into part_class_type_cross_ref values ('M','W')
go

if not exists ( select 1 from part_class_type_cross_ref where class = 'P' and type = 'F' )
	insert into part_class_type_cross_ref values ('P','F')
go

if not exists ( select 1 from part_class_type_cross_ref where class = 'P' and type = 'R' )
	insert into part_class_type_cross_ref values ('P','R')
go

if not exists ( select 1 from part_class_type_cross_ref where class = 'P' and type = 'W' )
	insert into part_class_type_cross_ref values ('P','W')
go

if not exists ( select 1 from part_class_type_cross_ref where class = 'O' and type = 'O' )
	INSERT INTO part_class_type_cross_ref ( class, type ) VALUES ( 'O', 'O')
go


print'
-------------------------
-- part_inventory changes
-------------------------
'
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_inventory' and sc.id = so.id and sc.name = 'dim_code' )
	alter table part_inventory add dim_code             varchar(2) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.id = sc.id and so.name = 'part_inventory' and sc.name = 'configurable' )
	alter table part_inventory add configurable char(1) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.id = sc.id and so.name = 'part_inventory' and sc.name = 'next_suffix' )
	alter table part_inventory add next_suffix integer null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_inventory' and sc.id = so.id and sc.name = 'drop_ship_part' )
	alter table part_inventory add drop_ship_part char(1) null
go



print'
----------------------
-- part_online changes
----------------------
'
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_online' and sc.id = so.id and sc.name = 'min_onhand' )
	alter table part_online add min_onhand dec(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_online' and sc.id = so.id and sc.name = 'max_onhand' )
	alter table part_online add max_onhand dec(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_online' and sc.id = so.id and sc.name = 'default_vendor' )
	alter table part_online add default_vendor varchar(10) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_online' and sc.id = so.id and sc.name = 'default_po_number' )
	alter table part_online add default_po_number int null
go

if not exists
	(	select	1
		from	dbo.sysobjects
			join dbo.syscolumns on dbo.sysobjects.id = dbo.syscolumns.id
		where	dbo.sysobjects.name = 'part_online' and
			dbo.syscolumns.name = 'kanban_po_requisition' )
	alter table part_online add kanban_po_requisition char (1) null
go

if not exists
	(	select	1
		from	dbo.sysobjects
			join dbo.syscolumns on dbo.sysobjects.id = dbo.syscolumns.id
		where	dbo.sysobjects.name = 'part_online' and
			dbo.syscolumns.name = 'kanban_required' )
	alter table part_online add kanban_required char (1) null
go


print'
-------------------------
-- part_packaging changes
-------------------------
'
if	exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_packaging' and sc.id = so.id and sc.name in ( 'scale_interface','type_of_trigger','tolerance','trigger_weight','trigger_prints_label','user_input_trigger','trigger_type','threshold_percent','inactivity_weight' ) ) or
	not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_packaging' and sc.id = so.id and sc.name = 'label_format' and sc.length = 25 )
begin
	if exists ( select 1 from dbo.sysobjects where name = 'part_packaging' )
		execute sp_rename part_packaging, part_packaging_temp

	execute ( '
		create table part_packaging (
		       part                 varchar(25) not null,
		       code                 varchar(20) not null,
		       quantity             numeric(20,6) not null,
		       manual_tare          char(1) null,
		       label_format         varchar(25) null,
		       round_to_whole_number char(1) null,
		       package_is_object    char(1) null,
		       inactivity_time      smallint null,
		       threshold_upper      numeric(20,6) null,
		       threshold_lower      numeric(20,6) null,
		       unit                 varchar(3) null,
		       stage_using_weight   char(1) null,
		       inactivity_amount    numeric(20,6) null,
		       threshold_upper_type varchar(1) null,
		       threshold_lower_type varchar(1) null,
		       serial_type          varchar(25) null
		)
	' )

	alter table part_packaging
	       add primary key (part, code)

	if exists ( select 1 from dbo.sysobjects where name = 'part_packaging_temp' )
	begin
		declare @column_list varchar(255),
				@column varchar(100)
		
		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
					dbo.syscolumns sc
			where	so.name = 'part_packaging_temp' and
					so.id = sc.id and
					sc.name not in ( 'scale_interface','type_of_trigger','tolerance','trigger_weight','trigger_prints_label','user_input_trigger','trigger_type','threshold_percent','inactivity_weight' )
		
		select @column_list = ''
		
		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			if isnull(@column_list,'') > ''
				select @column_list = @column_list + ',' + @column
			else
				select @column_list = @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list
		
		execute ( '
			insert into part_packaging ( ' + @column_list + ' )
				select ' + @column_list + ' from part_packaging_temp
		' )
		
		execute ( '
			drop table part_packaging_temp
		' )
	end


	alter table part_packaging
	       add foreign key (part)
	                             references part
end
else
begin
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_packaging' and sc.id = so.id and sc.name = 'inactivity_amount' )
		alter table part_packaging add inactivity_amount numeric(20, 6) null
	
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_packaging' and sc.id = so.id and sc.name = 'threshold_upper_type' )
		alter table part_packaging add threshold_upper_type varchar (1) null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_packaging' and sc.id = so.id and sc.name = 'threshold_lower_type' )
		alter table part_packaging add threshold_lower_type varchar (1) null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_packaging' and sc.id = so.id and sc.name = 'serial_type' )
		alter table part_packaging add serial_type varchar (25) null
end
go


print'
------------------------
-- part_revision changes
------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'part_revision' ) 
	execute sp_rename part_revision, part_revision_temp
go

create table part_revision (
       part                 varchar(25) not null,
       revision             varchar(10) not null,
       engineering_level    varchar(10) not null,
       effective_datetime   datetime not null,
       notes                varchar(255) null
)
go


alter table part_revision
       add primary key (part, revision, engineering_level)
go

if exists ( select 1 from dbo.sysobjects where name = 'part_revision_temp' )
begin
	declare @column_list varchar(255),
			@column varchar(100)
	
	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
				dbo.syscolumns sc
		where	so.name = 'part_revision_temp' and
				so.id = sc.id
	
	select @column_list = ''
	
	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list
	
	execute ( '
		insert into part_revision ( ' + @column_list + ' )
			select ' + @column_list + ' from part_revision_temp
	' )
	
	execute ( '
		drop table part_revision_temp
	' )
end
go

create index idx_part_revision_eff_dt on part_revision
(
       effective_datetime
)
go

alter table part_revision
       add foreign key (part)
                             references part
go


print'
------------------------
-- part_standard changes
------------------------
'
if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'std_cost' )
	execute sp_rename 'part_standard.std_cost','qtd_cost','column'
else if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'qtd_cost' )
	alter table part_standard add qtd_cost numeric(20,6) null
go

if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'std_material' )
	execute sp_rename 'part_standard.std_material','qtd_material','column'
else if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'qtd_material' )
	alter table part_standard add qtd_material numeric(20,6) null
go

if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'std_labor' )
	execute sp_rename 'part_standard.std_labor','qtd_labor','column'
else if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'qtd_labor' )
	alter table part_standard add qtd_labor numeric(20,6) null
go

if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'std_burden' )
	execute sp_rename 'part_standard.std_burden','qtd_burden','column'
else if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'qtd_burden' )
	alter table part_standard add qtd_burden numeric(20,6) null
go

if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'std_other' )
	execute sp_rename 'part_standard.std_other','qtd_other','column'
else if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'qtd_other' )
	alter table part_standard add qtd_other numeric(20,6) null
go

if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'std_cost_cum' )
	execute sp_rename 'part_standard.std_cost_cum','qtd_cost_cum','column'
else if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'qtd_cost_cum' )
	alter table part_standard add qtd_cost_cum numeric(20,6) null
go

if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'std_material_cum' )
	execute sp_rename 'part_standard.std_material_cum','qtd_material_cum','column'
else if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'qtd_material_cum' )
	alter table part_standard add qtd_material_cum numeric(20,6) null
go

if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'std_labor_cum' )
	execute sp_rename 'part_standard.std_labor_cum','qtd_labor_cum','column'
else if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'qtd_labor_cum' )
	alter table part_standard add qtd_labor_cum numeric(20,6) null
go

if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'std_burden_cum' )
	execute sp_rename 'part_standard.std_burden_cum','qtd_burden_cum','column'
else if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'qtd_burden_cum' )
	alter table part_standard add qtd_burden_cum numeric(20,6) null
go

if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'std_other_cum' )
	execute sp_rename 'part_standard.std_other_cum','qtd_other_cum','column'
else if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'qtd_other_cum' )
	alter table part_standard add qtd_other_cum numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'planned_cost' )
	alter table part_standard add planned_cost numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'planned_material' )
	alter table part_standard add planned_material numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'planned_labor' )
	alter table part_standard add planned_labor numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'planned_burden' )
	alter table part_standard add planned_burden numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'planned_other' )
	alter table part_standard add planned_other numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'planned_cost_cum' )
	alter table part_standard add planned_cost_cum numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'planned_material_cum' )
	alter table part_standard add planned_material_cum numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'planned_labor_cum' )
	alter table part_standard add planned_labor_cum numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'planned_burden_cum' )
	alter table part_standard add planned_burden_cum numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'planned_other_cum' )
	alter table part_standard add planned_other_cum numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'frozen_cost' )
	alter table part_standard add frozen_cost numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'frozen_material' )
	alter table part_standard add frozen_material numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'frozen_burden' )
	alter table part_standard add frozen_burden numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'frozen_labor' )
	alter table part_standard add frozen_labor numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'frozen_other' )
	alter table part_standard add frozen_other numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'frozen_cost_cum' )
	alter table part_standard add frozen_cost_cum numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'frozen_material_cum' )
	alter table part_standard add frozen_material_cum numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'frozen_burden_cum' )
	alter table part_standard add frozen_burden_cum numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'frozen_labor_cum' )
	alter table part_standard add frozen_labor_cum numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'frozen_other_cum' )
	alter table part_standard add frozen_other_cum numeric(20,6) null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'cost_changed_date' )
	alter table part_standard add cost_changed_date datetime null
go

if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'std_changed_date' ) and
	not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'qtd_changed_date' )
	execute sp_rename 'part_standard.std_changed_date','qtd_changed_date','column'
else if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'qtd_changed_date' )
	alter table part_standard add qtd_changed_date datetime null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'planned_changed_date' )
	alter table part_standard add planned_changed_date datetime null
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'frozen_changed_date' )
	alter table part_standard add frozen_changed_date datetime null
go      

if exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'std_changed_date' ) and
	exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'qtd_changed_date' )
begin
	execute sp_rename part_standard, part_standard_temp
	
	execute ( '
	create table part_standard (
		part varchar (25) NOT NULL ,
		price numeric(20, 6) NULL ,
		cost numeric(20, 6) NULL ,
		account_number varchar (50) NULL ,
		material numeric(20, 6) NULL ,
		labor numeric(20, 6) NULL ,
		burden numeric(20, 6) NULL ,
		other numeric(20, 6) NULL ,
		cost_cum numeric(20, 6) NULL ,
		material_cum numeric(20, 6) NULL ,
		burden_cum numeric(20, 6) NULL ,
		other_cum numeric(20, 6) NULL ,
		labor_cum numeric(20, 6) NULL ,
		flag int NULL ,
		premium char (1) NULL ,
		qtd_cost numeric(20, 6) NULL ,
		qtd_material numeric(20, 6) NULL ,
		qtd_labor numeric(20, 6) NULL ,
		qtd_burden numeric(20, 6) NULL ,
		qtd_other numeric(20, 6) NULL ,
		qtd_cost_cum numeric(20, 6) NULL ,
		qtd_material_cum numeric(20, 6) NULL ,
		qtd_labor_cum numeric(20, 6) NULL ,
		qtd_burden_cum numeric(20, 6) NULL ,
		qtd_other_cum numeric(20, 6) NULL ,
		planned_cost numeric(20, 6) NULL ,
		planned_material numeric(20, 6) NULL ,
		planned_labor numeric(20, 6) NULL ,
		planned_burden numeric(20, 6) NULL ,
		planned_other numeric(20, 6) NULL ,
		planned_cost_cum numeric(20, 6) NULL ,
		planned_material_cum numeric(20, 6) NULL ,
		planned_labor_cum numeric(20, 6) NULL ,
		planned_burden_cum numeric(20, 6) NULL ,
		planned_other_cum numeric(20, 6) NULL ,
		frozen_cost numeric(20, 6) NULL ,
		frozen_material numeric(20, 6) NULL ,
		frozen_burden numeric(20, 6) NULL ,
		frozen_labor numeric(20, 6) NULL ,
		frozen_other numeric(20, 6) NULL ,
		frozen_cost_cum numeric(20, 6) NULL ,
		frozen_material_cum numeric(20, 6) NULL ,
		frozen_burden_cum numeric(20, 6) NULL ,
		frozen_labor_cum numeric(20, 6) NULL ,
		frozen_other_cum numeric(20, 6) NULL ,
		cost_changed_date datetime NULL ,
		qtd_changed_date datetime NULL ,
		planned_changed_date datetime NULL ,
		frozen_changed_date datetime NULL 
	)
	' )
	
	alter table part_standard
	       add primary key (part)
	
	if exists ( select 1 from dbo.sysobjects where name = 'part_standard_temp' )
	begin
		execute ( '
			insert into part_standard ( part,price,cost,account_number,material,labor,burden,other,cost_cum,material_cum,burden_cum,other_cum,labor_cum,flag,premium,qtd_cost,qtd_material,qtd_labor,qtd_burden,qtd_other,qtd_cost_cum,qtd_material_cum,qtd_labor_cum,qtd_burden_cum,qtd_other_cum,planned_cost,planned_material,planned_labor,planned_burden,planned_other,planned_cost_cum,planned_material_cum,planned_labor_cum,planned_burden_cum,planned_other_cum,frozen_cost,frozen_material,frozen_burden,frozen_labor,frozen_other,frozen_cost_cum,frozen_material_cum,frozen_burden_cum,frozen_labor_cum,frozen_other_cum,cost_changed_date,qtd_changed_date,planned_changed_date,frozen_changed_date )
				select part,price,cost,account_number,material,labor,burden,other,cost_cum,material_cum,burden_cum,other_cum,labor_cum,flag,premium,qtd_cost,qtd_material,qtd_labor,qtd_burden,qtd_other,qtd_cost_cum,qtd_material_cum,qtd_labor_cum,qtd_burden_cum,qtd_other_cum,planned_cost,planned_material,planned_labor,planned_burden,planned_other,planned_cost_cum,planned_material_cum,planned_labor_cum,planned_burden_cum,planned_other_cum,frozen_cost,frozen_material,frozen_burden,frozen_labor,frozen_other,frozen_cost_cum,frozen_material_cum,frozen_burden_cum,frozen_labor_cum,frozen_other_cum,cost_changed_date,qtd_changed_date,planned_changed_date,frozen_changed_date from part_standard_temp
		' )
		
		execute ( '
			drop table part_standard_temp
		' )
	end

	alter table part_standard
		add foreign key (part)
			references part

end
go


print'
-----------------------------------
-- part_vendor_price_matrix changes
-----------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'part_vendor_price_matrix' )
	execute sp_rename part_vendor_price_matrix, part_vendor_price_matrix_temp
go

create table part_vendor_price_matrix (
       part                 varchar(25) not null,
       vendor               varchar(10) not null,
       price                numeric(20,6) not null,
       break_qty            numeric(20,6) not null,
       code                 varchar(10) null,
	   alternate_price 		decimal(20,6) null
)
go

alter table part_vendor_price_matrix
       add primary key (part, vendor, break_qty)
go

if exists ( select 1 from dbo.sysobjects where name = 'part_vendor_price_matrix_temp' )
begin
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_vendor_price_matrix_temp' and sc.id = so.id and sc.name = 'alternate_price' )
		execute ( '
			insert into part_vendor_price_matrix (part, vendor, price, break_qty, code) 
			    select part, vendor, convert(numeric(20,6),price), convert(numeric(20,6),
			    break_qty), code from part_vendor_price_matrix_temp
		' )
	else
		execute ( '
			insert into part_vendor_price_matrix (part, vendor, price, break_qty, code, alternate_price) 
			    select part, vendor, convert(numeric(20,6),price), convert(numeric(20,6),
			    break_qty), code, alternate_price from part_vendor_price_matrix_temp
		' )

	execute ( '
		drop table part_vendor_price_matrix_temp
	' )
end
go

delete  from part_vendor_price_matrix
where 	( select count(*) from part_vendor pv where pv.part = part_vendor_price_matrix.part and pv.vendor = part_vendor_price_matrix.vendor ) < 1
go

alter table part_vendor_price_matrix
       add foreign key (part, vendor)
                             references part_vendor
go


print'
--------------------
-- po_detail changes
--------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_po_detail_iu' )
	drop trigger mtr_po_detail_iu
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_po_detail_i' )
	drop trigger mtr_po_detail_i
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_po_detail_u' )
	drop trigger mtr_po_detail_u
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail' and sc.id = so.id and sc.name = 'description' and sc.length = 100 ) or
   not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail' and sc.id = so.id and sc.name = 'account_code' and sc.length = 50 ) or
   not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail' and sc.id = so.id and sc.name = 'requisition_id' )
begin
	if exists ( select 1 from dbo.sysobjects where name = 'po_detail' )
		execute sp_rename po_detail, po_detail_temp

	execute ( '
		create table po_detail (
		       po_number            integer not null,
		       vendor_code          varchar(10) not null,
		       part_number          varchar(25) not null,
		       description          varchar(100) null,
		       unit_of_measure      varchar(2) null,
		       date_due             datetime not null,
		       requisition_number   varchar(10) null,
		       status               char(1) null,
		       type                 char(1) null,
		       last_recvd_date      datetime null,
		       last_recvd_amount    numeric(20,6) null,
		       cross_reference_part varchar(25) null,
		       account_code         varchar(50) null,
		       notes                varchar(255) null,
		       quantity             numeric(20,6) null,
		       received             numeric(20,6) null,
		       balance              numeric(20,6) null,
		       active_release_cum   numeric(20,6) null,
		       received_cum         numeric(20,6) null,
		       price                numeric(20,6) null,
		       row_id               numeric(20) not null,
		       invoice_status       char(1) null,
		       invoice_date         datetime null,
		       	invoice_qty          numeric(20,6) null,
		       	invoice_unit_price   numeric(20,6) null,
		       	release_no           integer null,
		       	ship_to_destination  varchar(25) null,
		       	terms                varchar(20) null,
		       	week_no              integer null,
		       	plant                varchar(10) null,
		       	invoice_number       varchar(10) null,
		       	standard_qty         numeric(20,6) null,
		       	sales_order          integer null,
		       	dropship_oe_row_id   integer null,
		       	ship_type            char(1) null,
		       	dropship_shipper     integer null,
		       	price_unit           char(1) null,
		       	printed              char(1) null,
		       	selected_for_print   char(1) null,
		       	deleted              char(1) null,
		       	ship_via             varchar(15) null,
		       	release_type         char(1) null,
		       	dimension_qty_string varchar(50) null,
		       	taxable              char(1) null,
		       	scheduled_time	    datetime null,
		       	truck_number	    	varchar (30) null,
		       	confirm_asn 	    	char (1) null,
			job_cost_no 			varchar(25) null,
			alternate_price decimal(20,6) null,
			requisition_id integer null
		)
	' )

	execute ( '
		alter table po_detail
		       add primary key (po_number, part_number, date_due, row_id)
	' )

	if exists ( select 1 from dbo.sysobjects where name = 'po_detail_temp' )
	begin
		declare @column_list varchar(255),
				@column varchar(100)
		
		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
				dbo.syscolumns sc
			where	so.name = 'po_detail_temp' and
				so.id = sc.id and
				sc.name not in ( 'po_number', 'vendor_code', 'part_number', 'description', 'unit_of_measure', 'date_due',
			    'requisition_number', 'status', 'type', 'last_recvd_date', 'last_recvd_amount', 'cross_reference_part', 
			    'account_code', 'notes', 'quantity', 'received', 'balance', 'active_release_cum', 
			    'received_cum', 'price', 'row_id', 'invoice_status', 'invoice_date', 'invoice_qty', 
			    'invoice_unit_price', 'release_no', 'ship_to_destination', 'terms', 'week_no', 'plant', 'invoice_number', 
			    'standard_qty', 'sales_order', 'dropship_oe_row_id', 'ship_type', 'dropship_shipper', 'price_unit', 'printed', 'selected_for_print', 'deleted', 
			    'ship_via', 'release_type', 'notes_long' )
		
		select @column_list = ''
		
		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			select @column_list = @column_list + ',' + @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list
		
		execute ( '
			insert into po_detail (po_number, vendor_code, part_number, description, unit_of_measure, date_due,
			    requisition_number, status, type, last_recvd_date, last_recvd_amount, cross_reference_part, 
			    account_code, notes, quantity, received, balance, active_release_cum, 
			    received_cum, price, row_id, invoice_status, invoice_date, invoice_qty, 
			    invoice_unit_price, release_no, ship_to_destination, terms, week_no, plant, invoice_number, 
			    standard_qty, sales_order, dropship_oe_row_id, ship_type, dropship_shipper, price_unit, printed, selected_for_print, deleted, 
			    ship_via, release_type ' + @column_list + ' ) select po_number, vendor_code, part_number, description, 
			    unit_of_measure, date_due, requisition_number, status, type, last_recvd_date, convert(numeric(20,6),
			    last_recvd_amount), cross_reference_part, account_code, notes, 
			    convert(numeric(20,6),quantity), convert(numeric(20,6),received), 
			    convert(numeric(20,6),balance), convert(numeric(20,6),active_release_cum), 
			    convert(numeric(20,6),received_cum), convert(numeric(20,6),price), 
			    convert(numeric(20),row_id), invoice_status, invoice_date, convert(numeric(20,6),
			    invoice_qty), convert(numeric(20,6),invoice_unit_price), release_no,
			    ship_to_destination, terms, week_no, plant, invoice_number, convert(numeric(20,6),
			    standard_qty), sales_order, dropship_oe_row_id, ship_type, dropship_shipper, price_unit, printed, selected_for_print,
			    deleted,ship_via, release_type ' + @column_list + ' from po_detail_temp
		' )
	
		execute ( '
			drop table po_detail_temp
		' )
	end

	alter table po_detail
	       add foreign key (po_number)
	                             references po_header
end
else
begin
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail' and sc.id = so.id and sc.name = 'dimension_qty_string' )
		alter table po_detail add dimension_qty_string varchar (50) null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail' and sc.id = so.id and sc.name = 'taxable' )
		alter table po_detail add taxable char (1) null 

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail' and sc.id = so.id and sc.name = 'scheduled_time' )
		alter table po_detail add scheduled_time datetime null 

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail' and sc.id = so.id and sc.name = 'truck_number' )
		alter table po_detail add truck_number varchar (30) null 

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail' and sc.id = so.id and sc.name = 'confirm_asn' )
		alter table po_detail add confirm_asn char (1) null 

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail' and sc.id = so.id and sc.name = 'job_cost_no' )
		alter table po_detail add job_cost_no varchar (25) null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail' and sc.id = so.id and sc.name = 'alternate_price' )
		alter table po_detail add alternate_price decimal(20,6) null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail' and sc.id = so.id and sc.name = 'requisition_id' )
		alter table po_detail add requisition_id integer null
end
go

update	po_detail
set	alternate_price = price
where	alternate_price is null
go

update	po_header
set	currency_unit = 'USD'
where	currency_unit is null
go

update po_detail set po_detail.description = part.name
from po_detail, part
where po_detail.part_number = part.part
go


print'
----------------------------
-- po_detail_history changes
----------------------------
'
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail_history' and sc.id = so.id and sc.name = 'description' and sc.length = 100 ) or
   not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail_history' and sc.id = so.id and sc.name = 'account_code' and sc.length = 50 ) or
   not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail_history' and sc.id = so.id and sc.name = 'requisition_id' )
begin
	if exists ( select 1 from dbo.sysobjects where name = 'po_detail_history' )
		execute sp_rename po_detail_history, po_detail_history_temp

	execute ( '
		create table po_detail_history (
		       po_number            integer not null,
		       vendor_code          varchar(10) not null,
		       part_number          varchar(25) not null,
		       description          varchar(50) null,
		       unit_of_measure      varchar(2) null,
		       date_due             datetime not null,
		       requisition_number   varchar(10) null,
		       status               char(1) null,
		       type                 char(1) null,
		       last_recvd_date      datetime null,
		       last_recvd_amount    numeric(20,6) null,
		       cross_reference_part varchar(25) null,
		       account_code         varchar(100) null,
		       notes                varchar(255) null,
		       quantity             numeric(20,6) null,
		       received             numeric(20,6) null,
		       balance              numeric(20,6) null,
		       active_release_cum   numeric(20,6) null,
		       received_cum         numeric(20,6) null,
		       price                numeric(20,6) null,
		       row_id               numeric(20) not null,
		       invoice_status       char(1) null,
		       invoice_date         datetime null,
		       invoice_qty          numeric(20,6) null,
		       invoice_unit_price   numeric(20,6) null,
		       release_no           integer null,
		       ship_to_destination  varchar(25) null,
		       terms                varchar(20) null,
		       week_no              integer null,
		       plant                varchar(10) null,
		       invoice_number       varchar(10) null,
		       standard_qty         numeric(20,6) null,
		       sales_order          integer null,
		       dropship_oe_row_id   integer null,
		       ship_type            char(1) null,
		       dropship_shipper     integer null,
		       price_unit           char(1) null,
		       printed              char(1) null,
		       selected_for_print   char(1) null,
		       deleted              char(1) null,
		       ship_via             varchar(15) null,
		       release_type         char(1) null,
		       dimension_qty_string varchar(50) null,
		       taxable              char(1) null,
		       job_cost_no 			varchar(25) null,
			requisition_id integer null,
			posted 			char(1) null,
			alternate_price		decimal (20,6) null
		)
	' )

	execute ( '
		alter table po_detail_history
		       add primary key (po_number, part_number, date_due, row_id)
	' )

	if exists ( select 1 from dbo.sysobjects where name = 'po_detail_history_temp' )
	begin
		declare @column_list varchar(255),
				@column varchar(100)
		
		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
				dbo.syscolumns sc
			where	so.name = 'po_detail_history_temp' and
				so.id = sc.id and
				sc.name not in ( 'po_number', 'vendor_code', 'part_number', 'description', 'unit_of_measure', 'date_due',
			    'requisition_number', 'status', 'type', 'last_recvd_date', 'last_recvd_amount', 'cross_reference_part', 
			    'account_code', 'notes', 'quantity', 'received', 'balance', 'active_release_cum', 
			    'received_cum', 'price', 'row_id', 'invoice_status', 'invoice_date', 'invoice_qty', 
			    'invoice_unit_price', 'release_no', 'ship_to_destination', 'terms', 'week_no', 'plant', 'invoice_number', 
			    'standard_qty', 'sales_order', 'dropship_oe_row_id', 'ship_type', 'dropship_shipper', 'price_unit', 'printed', 'selected_for_print', 'deleted', 
			    'ship_via', 'release_type', 'notes_long' )
		
		select @column_list = ''
		
		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			select @column_list = @column_list + ',' + @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list
		
		execute ( '
			insert into po_detail_history (po_number, vendor_code, part_number, description, unit_of_measure, date_due,
			    requisition_number, status, type, last_recvd_date, last_recvd_amount, cross_reference_part, 
			    account_code, notes, quantity, received, balance, active_release_cum, 
			    received_cum, price, row_id, invoice_status, invoice_date, invoice_qty, 
			    invoice_unit_price, release_no, ship_to_destination, terms, week_no, plant, invoice_number, 
			    standard_qty, sales_order, dropship_oe_row_id, ship_type, dropship_shipper, price_unit, printed, selected_for_print, deleted, 
			    ship_via, release_type ' + @column_list + ' ) select po_number, vendor_code, part_number, description, 
			    unit_of_measure, date_due, requisition_number, status, type, last_recvd_date, convert(numeric(20,6),
			    last_recvd_amount), cross_reference_part, account_code, notes, 
			    convert(numeric(20,6),quantity), convert(numeric(20,6),received), 
			    convert(numeric(20,6),balance), convert(numeric(20,6),active_release_cum), 
			    convert(numeric(20,6),received_cum), convert(numeric(20,6),price), 
			    convert(numeric(20),row_id), invoice_status, invoice_date, convert(numeric(20,6),
			    invoice_qty), convert(numeric(20,6),invoice_unit_price), release_no,
			    ship_to_destination, terms, week_no, plant, invoice_number, convert(numeric(20,6),
			    standard_qty), sales_order, dropship_oe_row_id, ship_type, dropship_shipper, price_unit, printed, selected_for_print,
			    deleted,ship_via, release_type ' + @column_list + ' from po_detail_history_temp
		' )

		execute ( '
			drop table po_detail_history_temp
		' )
	end

	alter table po_detail_history
	       add foreign key (po_number)
	                             references po_header
end
else
begin
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail_history' and sc.id = so.id and sc.name = 'dimension_qty_string' )
		alter table po_detail_history add dimension_qty_string varchar (50) null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail_history' and sc.id = so.id and sc.name = 'taxable' )
		alter table po_detail_history add taxable char (1) null 

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail_history' and sc.id = so.id and sc.name = 'job_cost_no' )
		alter table po_detail_history add job_cost_no varchar (25) null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail_history' and sc.id = so.id and sc.name = 'requisition_id' )
		alter table po_detail_history add requisition_id integer null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail_history' and sc.id = so.id and sc.name = 'posted' )
		alter table po_detail_history add posted char(1) null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'po_detail_history' and sc.id = so.id and sc.name = 'alternate_price' )
		alter table po_detail_history add alternate_price decimal(20,6) null
end
go


print'
-----------------------
-- quote_detail changes
-----------------------
'
if 	exists ( select 1 from dbo.systypes st,dbo.sysobjects so, dbo.syscolumns sc where so.name = 'quote_detail' and sc.id = so.id and sc.name = 'quote_number' and st.usertype = sc.usertype and st.name = 'numeric' ) or
	exists ( select 1 from dbo.systypes st,dbo.sysobjects so, dbo.syscolumns sc where so.name = 'quote_detail' and sc.id = so.id and sc.name = 'sequence' and st.usertype = sc.usertype and st.name = 'int' )
begin
	if exists ( select 1 from dbo.sysobjects where name = 'quote_detail' )
		execute sp_rename quote_detail, quote_detail_temp
	
	execute ( '
		create table quote_detail (
		       quote_number         integer not null,
		       sequence             SMALLINT not null,
		       type                 CHAR(1) null,
		       group_no             varchar(10) null,
		       part                 varchar(25) null,
		       product_name         varchar(50) null,
		       price                numeric(20,6) null,
		       mode                 CHAR(1) null,
		       quantity             numeric(20,6) null,
		       cost                 numeric(20,6) null,
		       notes                varchar(255) null,
		       unit                 varchar(2) null,
		       dimension_qty_string varchar(50) null
		)
	' )

	execute ( '
		alter table quote_detail
		       add primary key (quote_number, sequence)
	' )

	if exists ( select 1 from dbo.sysobjects where name = 'quote_detail_temp' )
	begin
		declare @column_list varchar(255),
				@column varchar(100)
		
		declare column_list cursor for
			select	sc.name
			from	dbo.sysobjects so,
				dbo.syscolumns sc
			where	so.name = 'quote_detail_temp' and
				so.id = sc.id 
		
		select @column_list = ''
		
		open column_list
		fetch column_list into @column
		while ( @@fetch_status = 0 )
		begin
			if isnull(@column_list,'') > ''
				select @column_list = @column_list + ',' + @column
			else
				select @column_list = @column
			fetch column_list into @column
		end
		close column_list
		deallocate column_list

		execute ( '
			insert into quote_detail ( ' + @column_list + ' )
				select ' + @column_list + ' from quote_detail_temp
		' )
		
		execute ( '
			drop table quote_detail_temp
		' )
	end

	alter table quote_detail
	       add FOREIGN KEY (quote_number)
	                             REFERENCES quote
end
else
begin
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'quote_detail' and sc.id = so.id and sc.name = 'unit' )
		alter table quote_detail add unit varchar (2) NULL

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'quote_detail' and sc.id = so.id and sc.name = 'dimension_qty_string' )
		alter table quote_detail add dimension_qty_string varchar (50) NULL
end
go


print'
-------------------------
-- report_library changes      
-------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'report_library' )
	execute sp_rename report_library, report_library_temp
go

create table report_library (
	name varchar (25) not null ,
	report varchar (25) not null ,
	type varchar (1) not null ,
	object_name varchar (255) not null ,
	library_name varchar (255) not null ,
	preview varchar (1) null ,
	print_setup varchar (1) null ,
	printer varchar (255) null ,
	copies float null
)
GO

alter table report_library add primary key ( name, report )
go

if exists ( select 1 from dbo.sysobjects where name = 'report_library_temp' )
begin
	declare @column_list varchar(255),
			@column varchar(100)
	
	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
				dbo.syscolumns sc
		where	so.name = 'report_library_temp' and
				so.id = sc.id 
	
	select @column_list = ''
	
	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if isnull(@column_list,'') > ''
			select @column_list = @column_list + ',' + @column
		else
			select @column_list = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( '
		insert into report_library ( ' + @column_list + ' )
			select ' + @column_list + ' from report_library_temp
	' )
	
	execute ( '
		drop table report_library_temp
	' )
end
go

alter table report_library
       add FOREIGN KEY (report)
                             REFERENCES report_list
go

if not exists ( select 1 from report_library where name = 'NOLABEL' )
	insert into report_library VALUES ( 'NOLABEL','Label','W','w_no_label','mst.pbd','Y','Y',' ',1)
go

if exists ( select 1 from report_list where report = 'Purchase Order' )
begin
 UPDATE report_library
 SET  name = 'Normal PO',
      report = 'Normal PO'
 WHERE  report = 'Purchase Order' 

 DELETE FROM report_list 
 WHERE report= 'Purchase Order'
end
go


print'
-------------------------
-- shipper_detail changes
-------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_shipper_detail_d' )
	drop trigger mtr_shipper_detail_d
go

if exists ( select 1 from dbo.sysobjects where name = 'mt_shipper_detail_i' )
	drop trigger mt_shipper_detail_i
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_shipper_detail_i' )
	drop trigger mtr_shipper_detail_i
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_shipper_detail_iu' )
	drop trigger mtr_shipper_detail_iu
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_shipper_detail_u' )
	drop trigger mtr_shipper_detail_u
go

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'shipper_detail' and sc.id = so.id and sc.name = 'part_name' and sc.length = 100 )
begin
	declare	@fkname	varchar(100),
			@command varchar(255),
			@table varchar(255)
	
	declare fks cursor for
		select	so1.name,
				so2.name
		from 	dbo.sysreferences sr, 
				dbo.sysobjects so1, 
				dbo.sysobjects so2,
				dbo.sysobjects so3
		where  	sr.fkeyid = so1.id and
				so2.id = sr.constid and
				sr.rkeyid = so3.id and
				so3.name = 'shipper'
	
	open fks
	fetch fks into @table,@fkname
	while ( @@fetch_status = 0 )
	begin
		select @command = 'alter table ' + @table + ' drop constraint ' + @fkname
		execute ( @command )
		fetch fks into @table,@fkname
	end
	close fks
	deallocate fks

	if exists ( select 1 from dbo.sysobjects where name = 'shipper_detail' )
		execute sp_rename shipper_detail, shipper_detail_temp
	
	execute ( '
		create table shipper_detail (
			shipper int not null ,
			part varchar (35) not null ,
			qty_required numeric(20, 6) null ,
			qty_packed numeric(20, 6) null ,
			qty_original numeric(20, 6) null ,
			accum_shipped numeric(20, 6) null ,
			order_no numeric(8, 0) null ,
			customer_po varchar (25) null ,
			release_no varchar (30) null ,
			release_date datetime null ,
			type char (1) null ,
			price numeric(20, 6) null ,
			account_code varchar (75) null ,
			salesman varchar (10) null ,
			tare_weight numeric(20, 6) null ,
			gross_weight numeric(20, 6) null ,
			net_weight numeric(20, 6) null ,
			date_shipped datetime null ,
			assigned varchar (35) null ,
			packaging_job varchar (15) null ,
			note varchar (254) null ,
			operator varchar (5) null ,
			boxes_staged int null ,
			pack_line_qty numeric(20, 6) null ,
			alternative_qty numeric(20, 6) null ,
			alternative_unit varchar (15) null ,
			week_no int null ,
			taxable char (1) null ,
			price_type char (1) null ,
			cross_reference varchar (25) null ,
			customer_part varchar (30) null ,
			dropship_po int null ,
			dropship_po_row_id int null ,
			dropship_oe_row_id int null ,
			suffix int null ,
			part_name varchar (100) null ,
			part_original varchar (25) null ,
			total_cost numeric(20, 6) null ,
			group_no varchar (10) null ,
			dropship_po_serial int null ,
			dropship_invoice_serial int null ,
			stage_using_weight char (1) null ,
			alternate_price decimal(20,6) null,
			old_suffix integer null,
			old_shipper integer null
		)
	' )
	
	execute ( '
		alter table shipper_detail add primary key(shipper,part)
	' )
	
	if exists ( select 1 from dbo.sysobjects where name = 'shipper_detail_temp' )
	begin
		execute ( '
			insert into shipper_detail ( shipper, part, qty_required, qty_packed, qty_original, accum_shipped, order_no, customer_po, release_no,
				release_date, type, price, account_code, salesman, tare_weight, gross_weight, net_weight, date_shipped, assigned, packaging_job,
				note, operator, boxes_staged, pack_line_qty, alternative_qty, alternative_unit, week_no, taxable, price_type, cross_reference,
				customer_part, dropship_po, dropship_po_row_id, dropship_oe_row_id, suffix, part_name, part_original, total_cost, group_no,
				dropship_po_serial, dropship_invoice_serial, stage_using_weight )
			select shipper, part, qty_required, qty_packed, qty_original, accum_shipped, order_no, customer_po, release_no,
				release_date, type, price, account_code, salesman, tare_weight, gross_weight, net_weight, date_shipped, assigned, packaging_job,
				note, operator, boxes_staged, pack_line_qty, alternative_qty, alternative_unit, week_no, taxable, price_type, cross_reference,
				customer_part, dropship_po, dropship_po_row_id, dropship_oe_row_id, suffix, part_name, part_original, total_cost, group_no,
				dropship_po_serial, dropship_invoice_serial, stage_using_weight 
			from shipper_detail_temp
		' )
		
		execute ( '
			drop table shipper_detail_temp
		' )
	end
	
	alter table shipper_detail add
		CONSTRAINT fk_shipper_detail1
			FOREIGN KEY (shipper) 
			REFERENCES shipper (id)
end
else
begin
	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'shipper_detail' and sc.id = so.id and sc.name = 'alternate_price' )
		alter table shipper_detail add alternate_price decimal(20,6) null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'shipper_detail' and sc.id = so.id and sc.name = 'old_suffix' )
		alter table shipper_detail add old_suffix integer null

	if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'shipper_detail' and sc.id = so.id and sc.name = 'old_shipper' )
		alter table shipper_detail add old_shipper integer null
end
go

update	shipper_detail
set	alternate_price = price
where	alternate_price is null
go

update	shipper
set	currency_unit = 'USD'
where	currency_unit is null
go


print'
---------------------
-- work_order changes
---------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'work_order' )
	execute sp_rename work_order, work_order_temp
go

create table work_order (
       work_order           varchar(10) not null,
       tool                 varchar(10) null,
       due_date             datetime null,
       cycles_required      numeric(10,0) null,
       cycles_completed     numeric(10,0) null,
       machine_no           varchar(10) not null,
       process_id           varchar(25) null,
       customer_part        varchar(25) null,
       setup_time           numeric(6,2) null,
       cycles_hour          numeric(6,0) null,
       standard_pack        numeric(8,0) null,
       sequence             integer not null,
       cycle_time           integer null,
       start_date           datetime null,
       start_time           datetime null,
       end_date             datetime null,
       end_time             datetime null,
       runtime              numeric(20,6) null,
       employee             varchar(35) null,
       type                 CHAR(1) null,
       accum_run_time       numeric(20,6) null,
       cycle_unit           varchar(15) null,
       material_shortage    CHAR(1) null,
       lot_control_activated CHAR(1) null,
       plant                varchar(20) null,
       order_no             numeric(8,0) null,
       destination          varchar(20) null,
       customer             varchar(20) null,
       note                 varchar(255) null
)
go

alter table work_order
       add primary key (work_order)
go

if exists ( select 1 from dbo.sysobjects where name = 'work_order_temp' )
begin
	-- generate column list from system tables for backup table
	-- (make sure to exclude deleted columns)
	declare @column_list1 varchar(255),
		@column_list2 varchar(255),
		@column varchar(100)
		
	declare column_list cursor for
		select	sc.name
		from	dbo.sysobjects so,
			dbo.syscolumns sc
		where	so.name = 'work_order_temp' and
			so.id = sc.id

	select @column_list1 = ''
	select @column_list2 = ''
	
	open column_list
	fetch column_list into @column
	while ( @@fetch_status = 0 )
	begin
		if @column_list1 > ''
		begin
			if 	( select datalength ( @column_list1 ) ) >= 255 or
				( select datalength ( @column_list1 ) + datalength ( @column ) + 1 ) >= 255
			begin
				if @column_list2 > ''
					select @column_list2 = @column_list2 + ',' + @column
				else
					select @column_list2 = ',' + @column
			end
			else
				select @column_list1 = @column_list1 + ',' + @column
		end
		else
			select @column_list1 = @column
		fetch column_list into @column
	end
	close column_list
	deallocate column_list

	execute ( 'insert into work_order ( ' + @column_list1 + @column_list2 + ' ) select ' + @column_list1 + @column_list2 + ' from work_order_temp' )

	-- perform insert from backup table to newly created table
	-- if insert was a success, drop backup table
	if @@error = 0
		execute ( 'drop table work_order_temp' )
end
go

CREATE INDEX machine ON work_order
(
       machine_no
)
go

alter table work_order
       add FOREIGN KEY (process_id)
                             REFERENCES process
go


print'
-----------------------------------
-- workorder_header_history changes
-----------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'workorder_header_history' )
	execute sp_rename workorder_header_history, workorder_header_history_temp
go

create table workorder_header_history (
       work_order           varchar(10) not null,
       tool                 varchar(10) null,
       due_date             datetime null,
       cycles_required      numeric(10) null,
       cycles_completed     numeric(10) null,
       machine_no           varchar(10) not null,
       process_id           varchar(25) null,
       customer_part        varchar(25) null,
       setup_time           numeric(6,2) null,
       cycles_hour          numeric(6) null,
       standard_pack        numeric(8) null,
       sequence             integer not null,
       cycle_time           integer null,
       start_date           datetime null,
       start_time           datetime null,
       end_date             datetime null,
       end_time             datetime null,
       runtime              numeric(20,6) null,
       employee             varchar(35) null,
       type                 CHAR(1) null,
       accum_run_time       numeric(20,6) null,
       cycle_unit           varchar(15) null,
       material_shortage    CHAR(1) null,
       lot_control_activated CHAR(1) null,
       plant                varchar(20) null,
       order_no             numeric(8) null,
       destination          varchar(20) null,
       customer             varchar(20) null,
       note                 varchar(255) null
)
go

alter table workorder_header_history
       add primary key (work_order, machine_no, sequence)
go

if exists ( select 1 from dbo.sysobjects where name = 'workorder_header_history_temp' )
begin
	execute ( '
		insert into workorder_header_history (work_order, tool, cycles_required, 
		    cycles_completed, machine_no, process_id, customer_part, setup_time, 
		    cycles_hour, standard_pack, runtime, employee, type, accum_run_time, 
		    cycle_unit, material_shortage, lot_control_activated, plant, order_no, 
		    destination, customer, note, due_date, sequence, cycle_time, start_date, start_time, end_date, end_time) select work_order, tool, CONVERT(numeric(10),
		    cycles_required), CONVERT(numeric(10),cycles_completed), machine_no, 
		    process_id, customer_part, CONVERT(numeric(6,2),setup_time), 
		    CONVERT(numeric(6),cycles_hour), CONVERT(numeric(8),standard_pack), 
		    CONVERT(numeric(20,6),runtime), employee, type, CONVERT(numeric(20,6),
		    accum_run_time), cycle_unit, material_shortage, lot_control_activated, 
		    plant, CONVERT(numeric(8),order_no), destination, customer, note, 
		    due_date, sequence, cycle_time, start_date, start_time, end_date, end_time
		    from workorder_header_history_temp
	' )

	execute ( '
		drop table workorder_header_history_temp
	' )
end
go

alter table workorder_header_history
       add FOREIGN KEY (process_id)
                             REFERENCES process
go


print'
-----------------------------
-- xreport_datasource changes
-----------------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'xreport_datasource' )
	execute ( '
	CREATE TABLE xreport_datasource
	( 
		datasource_name varchar(8) NOT NULL,
		description  varchar(50) NOT NULL,
		library_name varchar(50),
		dw_name   varchar(50) NOT NULL,
		PRIMARY KEY ( datasource_name ) 
	)
	' )
GO

 
print'
-----------------------------
-- xreport_library changes
-----------------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'xreport_library' )
	execute ( '
	CREATE TABLE xreport_library
	( 
		name   varchar(25) NOT NULL,
		report   varchar(25) NOT NULL,
		datasource  varchar(8) NOT NULL,
		xlabelformat varchar(50) NOT NULL,
		PRIMARY KEY ( name, report ) 
	)
	' )
GO


print'
--------------------
-- m_in_release_plan
--------------------
'
if exists (
	select	1
	  from	sysobjects
	 where	id = Object_id ( 'm_in_release_plan' ) )
	 drop table m_in_release_plan
go

create table m_in_release_plan (
	customer_part varchar (35) NOT NULL ,
	shipto_id varchar (20) NOT NULL ,
	customer_po varchar (20) NULL ,
	model_year varchar (4) NULL ,
	release_no varchar (30) NOT NULL ,
	quantity_qualifier char (1) NOT NULL ,
	quantity numeric(20, 6) NOT NULL ,
	release_dt_qualifier char (1) NOT NULL ,
	release_dt datetime NOT NULL )
go


print'
-------------------------------
-- m_in_release_plan_exceptions
-------------------------------
'
if exists (
	select	1
	  from	sysobjects
	 where	id = object_id ( 'm_in_release_plan_exceptions' ) )
	drop table m_in_release_plan_exceptions
go
	
create table m_in_release_plan_exceptions (
	logid integer not null,
	customer_part varchar (35) not null,
	shipto_id varchar (20) not null,
	customer_po varchar (20) null,
	model_year varchar (4) null,
	release_no varchar (30) not null,
	quantity_qualifier char (1) not null,
	quantity numeric(20, 6) not null,
	release_dt_qualifier char (1) not null,
	release_dt datetime not null )

go


print'
-------------------
-- m_in_customer_po
-------------------
'
if exists (
	select	1
	  from	sysobjects
	 where	id = Object_id ( 'm_in_customer_po' ) )
	 drop table m_in_customer_po
go

create table m_in_customer_po (
	plant varchar (10) NULL,
	shipto_id varchar (20) NOT NULL ,
	customer_po varchar (20) NULL ,
	customer_part varchar (35) NOT NULL ,
	release_no varchar (30) NOT NULL ,
	order_unit char (2) NULL,
	quantity numeric(20, 6) NOT NULL ,
	release_dt_qualifier char (1) NOT NULL ,
	release_dt datetime NOT NULL,
	release_type_qualifier char (1) NOT NULL )
go


print'
------------------------------
-- m_in_customer_po_exceptions
------------------------------
'
if exists (
	select	1
	  from	sysobjects
	 where	id = object_id ( 'm_in_customer_po_exceptions' ) )
	drop table m_in_customer_po_exceptions
go
	
create table m_in_customer_po_exceptions (
	logid			integer not null,
	plant			varchar (10) null,
	shipto_id		varchar (20) not null,
	customer_po		varchar (20) null,
	customer_part		varchar (35) not null,
	release_no		varchar (30) not null,
	order_unit		char (2) null,
	quantity		numeric (20,6) not null,
	release_dt_qualifier	char (1) not null,
	release_dt		datetime not null,
	release_type_qualifier	char (1) not null )

go


print'
---------------------
-- m_in_ship_schedule
---------------------
'
if exists (
	select	1
	  from	sysobjects
	 where	id = Object_id ( 'm_in_ship_schedule' ) )
	 drop table m_in_ship_schedule
go

create table m_in_ship_schedule (
	customer_part varchar (35) NOT NULL ,
	shipto_id varchar (20) NOT NULL ,
	customer_po varchar (20) NULL ,
	model_year varchar (4) NULL ,
	release_no varchar (30) NOT NULL ,
	quantity_qualifier char (1) NOT NULL ,
	quantity numeric(20, 6) NOT NULL ,
	release_dt_qualifier char (1) NOT NULL ,
	release_dt datetime NOT NULL )
go


print'
--------------------------------
-- m_in_ship_schedule_exceptions
--------------------------------
'
if exists (
	select	1
	  from	sysobjects
	 where	id = object_id ( 'm_in_ship_schedule_exceptions' ) )
	drop table m_in_ship_schedule_exceptions
go

create table m_in_ship_schedule_exceptions (
	logid			integer not null,
	customer_part		varchar (35) not null,
	shipto_id		varchar (20) not null,
	customer_po		varchar (20) null,
	model_year		varchar (4) null,
	release_no		varchar (30) not null,
	quantity_qualifier	char (1) not null,
	quantity		numeric (20,6) not null,
	release_dt_qualifier	char (1) not null,
	release_dt		datetime not null)
	
go



print'
---------------------
-- serial_asn changes
---------------------
'
if exists (select * from dbo.sysobjects where id = object_id('serial_asn'))
	drop table serial_asn
GO

CREATE TABLE serial_asn (
	serial int NOT NULL ,
	part varchar (25) NOT NULL ,
	shipper int NOT NULL ,
	package_type varchar (25) NULL 
)

go

CREATE  CLUSTERED  INDEX jwindx ON dbo.serial_asn(serial, part, shipper) WITH  ALLOW_DUP_ROW ,  FILLFACTOR = 90
GO


print '
-------------------------------
-- requisition_security changes
-------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'requisition_security' )
	execute sp_rename requisition_security, requisition_sec_bkup

if not exists ( select 1 from dbo.sysobjects where name = 'requisition_security' )
	execute ( '
	create table  requisition_security
		( operator_code varchar(8) not null,
		password varchar(8) not null,
		security_level integer null,
		dollar numeric(20,6) null,
		approver  varchar (8) null,
		approver_password varchar (8) null,
		backup_approver varchar (8) null,
		backup_approver_password varchar (8) null,
		backup_approver_end_date datetime null,
		dollar_week_limit numeric (20,6) null,
		account_group_code varchar (25) null,
		project_group_code varchar (25) null,
		self_dollar_limit numeric(20,6) null,
		name varchar (40) NULL ,
		primary key (operator_code))
	' )

if exists (	select	1
		from	sysobjects
		where	name = 'requisition_sec_bkup' )
begin
	execute ( '
	insert	requisition_security
		(	operator_code,
			password,
			security_level,
			dollar,
			approver,
			approver_password,
			backup_approver,
			backup_approver_password,
			backup_approver_end_date,
			dollar_week_limit,
			account_group_code,
			self_dollar_limit,
			name )
		select	operator_code,
			password,
			security_level,
			dollar,
			approver,
			approver_password,
			backup_approver,
			backup_approver_password,
			backup_approver_end_date,
			dollar_week_limit,
			account_group_code,
			self_dollar_limit,
			name
		from	requisition_sec_bkup
	' )
	
	if exists
		(	select	1
			from	dbo.sysobjects
				join dbo.syscolumns on dbo.sysobjects.id = dbo.syscolumns.id
			where	dbo.sysobjects.name = 'requisition_sec_bkup' and
				dbo.syscolumns.name = 'job_group_code' )
		execute ( '
		update	requisition_security
		set	requisition_security.project_group_code = (	select	job_group_code
									from	requisition_sec_bkup
									where	requisition_security.operator_code = requisition_sec_bkup.operator_code )
		' )
	else
		execute ( '
		update	requisition_security
		set	requisition_security.project_group_code = (	select	requisition_sec_bkup.project_group_code
									from	requisition_sec_bkup
									where	requisition_security.operator_code = requisition_sec_bkup.operator_code )
		' )
				
	execute ( '
	drop table requisition_sec_bkup
	' )
end
go



print '
-------------------------------------------------------
--  insert a default administrator 
-------------------------------------------------------
'
if not exists ( select 1 from employee where name = 'Mon' ) 
	insert into employee values ( 'Mon', 'Mon', 'mon', 1 ) 
go

if not exists ( select 1 from requisition_Security where operator_code = 'Mon' )
		insert into requisition_security (
		operator_code,
		password,
		security_level,
		dollar,
		approver,
		approver_password,
		backup_approver,
		backup_approver_password,
		backup_approver_end_date,
		dollar_week_limit,
        	account_group_code,
		project_group_code,
		self_dollar_limit,
		name )
		values
		(	'Mon', 
			'mon',
			9,
			0,
			null,
			null,
			null,
			null,
			null,
			0,
			null,
			null,
			0,
			'Monitor' )
else
	update requisition_security
	set security_level = 9
	where operator_code = 'Mon'
go

print '
-------------------------------------------------------
-- insert rows from employee to requisition_security table 
-------------------------------------------------------
'
if exists ( select * from employee where  employee.operator_code not in 
		( select operator_code from requisition_security ) )

		insert into requisition_security (
		operator_code,
		password,
		security_level,
		dollar,
		approver,
		approver_password,
		backup_approver,
		backup_approver_password,
		backup_approver_end_date,
		dollar_week_limit,
        	account_group_code,
		project_group_code,
		self_dollar_limit,
		name )
		select 	operator_code, 
			password,
			1,
			0,
			null,
			null,
			null,
			null,
			null,
			0,
			null,
			null,
			0,
			name
		from employee 
		where  employee.operator_code not in ( select operator_code 
					from requisition_security )

go


update 	requisition_security
set	security_level = 1
where	security_level is null
go



print '
-------------------------------------------------------
--  Modify requisition_header table
-------------------------------------------------------
'
if exists (	select	1
		from	sysobjects
		where	name = 'requisition_header' )
	execute sp_rename requisition_header, requisition_header_bkup
go

create table requisition_header
	(requisition_number integer not null,
	vendor_code varchar(10) null,
	ship_to_destination varchar(25)  null,
	terms varchar(20) null ,
	fob varchar(20) null ,
	requested_date datetime not null,
	requisitioner varchar(8) not null,
	ship_via varchar(15) null ,
	notes text  null,
	approved varchar(1) null ,
	approver varchar(8) null,
	creation_date datetime not null,
	status varchar (10) not null,
	approval_date datetime null,
	freight_type varchar (15) null,
	status_notes  text  null, 
	primary key (requisition_number))
go

if exists (	select	1
		from	sysobjects
		where	name = 'requisition_header_bkup' )
begin
	execute ( '
	insert	requisition_header
		(	requisition_number,
			vendor_code,
			ship_to_destination,
			terms,
			fob,
			requested_date,
			requisitioner,
			ship_via,
			notes,
			approved,
			approver,
			creation_date,
			status,
			approval_date,
			freight_type,
			status_notes )
		select	requisition_number,
			vendor_code,
			ship_to_destination,
			terms,
			fob,
			requested_date,
			requisitioner,
			ship_via,
			notes,
			approved,
			approver,
			creation_date,
			status,
			approval_date,
			freight_type,
			status_notes
		from	requisition_header_bkup
	' )
	
	execute ( '
	drop table requisition_header_bkup
	' )
end
go

print '
-------------------------------------------------------
--  add requisition_detail table
-------------------------------------------------------
'
if exists (	select	1 
		from 	dbo.sysobjects 
		where 	name = 'requisition_detail' )
	execute sp_rename requisition_detail, requisition_detail_bkup
go

create table requisition_detail
	(requisition_number integer not null,
	part_number varchar(25) not null,
	description varchar(50) null ,
	account_no varchar(50)  null,
	deliver_to_operator varchar(10)  null,
	expected_cost numeric(20,6)  null,
	quantity numeric(20,6) not null,
	date_required datetime not null,
	notes text null ,
	row_id integer not null,
	po_number integer null,
	vendor_code varchar (10)  null,
	service_flag varchar (1) null,
	unit_of_measure varchar (2) null, 
	unit_cost decimal (20,6) null, 
	extended_cost decimal (20,6) null,
	status   varchar (10) null,
	status_notes  text  null,
	po_rowid  integer null ,
	project_number varchar (50) NULL , 
	primary key (requisition_number, row_id))
go

if exists (	select	1
		from	sysobjects
		where	name = 'requisition_detail_bkup' )
begin
	execute ( '
	insert into requisition_detail (
		requisition_number,
		part_number,
		description,
		account_no,
		deliver_to_operator,
		expected_cost,
		quantity,
		date_required,
		notes,
		row_id,
		po_number,
		vendor_code,
		service_flag,
		unit_of_measure, 
		unit_cost,
		extended_cost,
		status,
		status_notes,
		po_rowid,
		project_number )
	select	requisition_number,
		part_number,
		description,
		account_no,
		deliver_to_operator,
		expected_cost,
		quantity,
		date_required,
		notes,
		row_id,
		po_number,
		vendor_code,
		service_flag,
		unit_of_measure, 
		unit_cost,
		extended_cost,
		status,
		status_notes,
		po_rowid,
		project_number
	from	requisition_detail_bkup
	' )
	
	execute ( '
	drop table requisition_detail_bkup
	' )
end
go


print '
-------------------------------------------------------
--  add requisition_notes table
-------------------------------------------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'requisition_notes' ) 
	execute ( '
	create table requisition_notes
	       ( code varchar(25) not null,
        	 notes text,
	       primary key ( code)) ' )
go

print '
-------------------------------------------------------
--  add requisition_account_project table
-------------------------------------------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'requisition_account_project' )
begin
	execute ( '
	CREATE TABLE requisition_account_project
	(
		account_number        	varchar(50) NOT NULL,
		project_number        	varchar(50) NOT NULL,
		primary key ( account_number, project_number )
	) ' )
	
	execute ( '

	CREATE  INDEX acct_indx ON dbo.requisition_account_project(account_number) WITH  FILLFACTOR = 90
	' )

end
go

print '
-------------------------------------------------------
--  add requisition_project_number table
-------------------------------------------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'requisition_project_number' )
	execute ( '
	CREATE TABLE requisition_project_number
	(
		project_number        	varchar(50) NOT NULL,
		description   		varchar(255) NULL,
		primary key ( project_number )
	) ' )
go


print '
-------------------------------------------------------
--  add account_code table
-------------------------------------------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'account_code' ) 
	execute ( '
	create table account_code
	       ( account_no varchar(50) NOT null,
		 description varchar (255) null,
	       primary key ( account_no)) ' )
go


print '
-----------------------------------------------------------
--  add requisition_group table
-------------------------------------------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'requisition_group' )
	execute ( '
 	create table requisition_group
	       ( group_code varchar(25) NOT null,
		 description varchar (255) null,
	       primary key ( group_code ))
	' )
go


print '
---------------------------------------------------
--  add requisition_group_account table
-------------------------------------------------------
' 
if not exists ( select 1 from dbo.sysobjects where name = 'requisition_group_account' ) 
begin
	execute ( '
	create table requisition_group_account
		( group_code varchar(25) not null,
		account_no varchar ( 50 ),
		primary key ( group_code, account_no)) 
	' )

	execute ( '
	CREATE  INDEX acct_index ON requisition_group_account(account_no) WITH FILLFACTOR = 90
	' )
end
go

if exists ( select 1 from dbo.sysobjects where name = 'gc_account_code' )
begin
	execute ( '
	insert into requisition_group_account ( group_code, account_no )
		select group_code, account_no from gc_account_code
	' )

	execute ( '
	drop table gc_account_code
	' )
end
go


print '
-------------------------------------------------------
--  add requisition_group_project table
-------------------------------------------------------
'
if not exists ( select 1 from dbo.sysobjects where name = 'requisition_group_project' ) 
begin
	execute ( '
	create table requisition_group_project
		( group_code varchar(25) not null,
		project_number varchar ( 50 )
		primary key ( group_code, project_number)) 
	' )
	
	if exists ( select 1 from dbo.sysobjects where name = 'gc_job_code' )
	begin
		execute ( '
		insert into requisition_group_project ( group_code, project_number )
			select group_code, job_no from gc_job_code
		' )
		
		execute ( '
		drop table gc_job_code
		' )
	end
end
go




print'
---------------
-- View Changes
---------------
'


print'
--------------------
-- View : mvw_demand
--------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mvw_demand' )
	drop view mvw_demand
go

create view mvw_demand (	
	part, 
	due_dt, 
	std_qty,
	first_key,
	second_key,
	plant,
	type,
	flag )			
as
select  od.part_number,
	od.due_date,
	od.std_qty,
	od.order_no,
	od.row_id,
	od.plant,
	od.type,
	od.flag
from 	order_detail od
	join order_header oh on oh.order_no = od.order_no
	join customer_service_status css on css.status_name = oh.cs_status 
	cross join parameters
where	od.ship_type = 'N' and
	css.status_type <> 'C' and
	datediff ( dd, getdate(), od.due_date ) <= parameters.days_to_process
go


print '
----------------------------------------
--	View : mvw_effectivechangenotice
----------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('mvw_effectivechangenotice') )
	drop view mvw_effectivechangenotice
go

Create view mvw_effectivechangenotice(ecn_part,
       effective_date) AS  
select ecn.part,       
       max(ecn.effective_date)
from   effective_change_notice  ecn
group by ecn.part

go


print '
----------------------------
--	View : mvw_eng_level
----------------------------
'

if exists (select * from dbo.sysobjects where id = object_id('mvw_eng_level') )
	drop view mvw_eng_level
go

Create view mvw_eng_level(el_part,
       engineering_level,
       effective_date) AS  
select el.part,
       el.engineering_level,       
       el.effective_date
from   effective_change_notice  el
join   mvw_effectivechangenotice ecn on ecn.ecn_part = el.part and ecn.effective_date = el.effective_date

go


print'
----------------------
-- View: mvw_replenish
----------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mvw_replenish' )
	drop view mvw_replenish
go

create view mvw_replenish (
	part,
	std_qty )
as
select	part_number,
	standard_qty
from	po_detail
where	status <> 'C'
union all
select	part,
	qty_required
from	workorder_detail
go


print'
-------------------------------
-- View: cs_contact_call_log_vw
-------------------------------
'
if exists (select 1 from dbo.sysobjects where name = 'cs_contact_call_log_vw')
	drop view cs_contact_call_log_vw
go

create view cs_contact_call_log_vw
as 
	select	contact_call_log.contact,
		contact_call_log.start_date,
		contact_call_log.stop_date,
		contact_call_log.call_subject,
		contact_call_log.call_content,
		contact.customer as customer,
		contact.destination as destination
	from	contact_call_log,contact
	where	contact_call_log.contact = contact.name

go


print'
-----------------------
-- view: cs_contacts_vw
-----------------------
'
if exists (select 1 from dbo.sysobjects where name = 'cs_contacts_vw')
	drop view cs_contacts_vw
go

create view cs_contacts_vw
as 
	select	contact.name,
		contact.phone,
		contact.fax_number,
		contact.email1,
		contact.email2,
		contact.title,
		contact.notes,
		contact.customer,
		contact.destination
	from	contact
go


print'
-----------------------
-- view: cs_invoices_vw
-----------------------
'
if exists (select 1 from dbo.sysobjects where id = object_id('cs_invoices_vw'))
	drop view cs_invoices_vw
GO

create view cs_invoices_vw  as
SELECT	invoice_number,   
	id,   
	date_shipped,   
	ship_via,   
	invoice_printed,   
	shipper.notes,   
	shipper.type,   
	shipping_dock,   
	status,   
	aetc_number,   
	freight_type,   
	printed,   
	bill_of_lading_number,   
	model_year_desc,   
	model_year,   
	location,   
	staged_objs,   
	shipper.plant,   
	invoiced,   
	freight,   
	tax_percentage,   
	total_amount,   
	gross_weight,   
	net_weight,   
	tare_weight,   
	responsibility_code,   
	trans_mode,   
	pro_number,   
	time_shipped,   
	truck_number,   
	seal_number,   
	shipper.terms,   
	tax_rate,   
	staged_pallets,   
	container_message,   
	picklist_printed,   
	dropship_reconciled,   
	date_stamp,   
	platinum_trx_ctrl_num,   
	posted,   
	scheduled_ship_time,
	customer.name as customer_name,
	destination.name as destination_name,
	shipper.destination,   
	shipper.customer
FROM	shipper
		join destination on destination.destination = shipper.destination
		join customer on customer.customer = destination.customer
WHERE	isnull(invoice_number,0) > 0
go


print'
---------------------
-- view: cs_issues_vw
---------------------
'
if exists (select 1 from dbo.sysobjects where id = object_id('cs_issues_vw'))
	drop view cs_issues_vw
GO

create view cs_issues_vw
as 
	select  issues.issue_number issue_number,
		issues.issue issue,
		issues.status status,
		issues.solution solution,
		issues.start_date start_date,
		issues.stop_date stop_date,
		issues.category category,
		issues.sub_category sub_category,
		issues.priority_level priority_level,
		issues.product_line product_line,
		issues.product_code product_code,
		issues.origin_type origin_type,
		issues.origin origin,
		issues.assigned_to assigned_to,
		issues.authorized_by authorized_by,
		issues.documentation_change documentation_change,
		issues.fax_sheet,   
		issues.environment environment,
		issues.entered_by entered_by,
		issues.product_component product_component, 
		issues_status.type type
	from  issues
		left outer join issues_status on issues_status.status = issues.status

GO


print'
---------------------
-- view: cs_quotes_vw
---------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'cs_quotes_vw' )
	drop view cs_quotes_vw
go

create view
  cs_quotes_vw
  as select quote_number,
    quote_date,
    contact,
    status,
    amount,
    notes,
    expire_date,
    customer,
    destination
    from quote
go


print'
----------------------
-- view: cs_returns_vw
----------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'cs_returns_vw' )
	drop view cs_returns_vw
go

Create View cs_returns_vw as
SELECT 	id,
	status, 
	customer, 
	destination, 
	date_stamp, 
	operator
FROM 	shipper
where 	type = 'R' and status in ( 'O' , 'S' )
go


print '
-------------------------
-- VIEW: cs_rma_detail_vw
-------------------------
'
if exists 
(
	select	1 
	from 	sysobjects 
	where 	id = object_id('cs_rma_detail_vw') 
)
	drop view cs_rma_detail_vw
go

create view cs_rma_detail_vw
as 
select	distinct	shipper,
	part_original,
	isnull(suffix,0) as suffix,
	part,
	qty_required,
	qty_packed,
	shipper_detail.operator,
	price,
	customer as rmacustomer,
	shipper_detail.old_shipper as original_shipper,
	(case 
		when abs(isnull(qty_packed,0)) >= abs(isnull(qty_required,0)) then 'RMA CLOSED & READY FOR INVOICING '
		else 'RMA PENDING & NOT READY FOR INVOICING ' 
	end) RMAstatus
from 	shipper_detail 
	join shipper on id=shipper
go

print'
---------------------------
-- view: cs_ship_history_vw
---------------------------
'
if exists 
( 
	select	1 
	from 	dbo.sysobjects 
	where 	id = object_id('cs_ship_history_vw') 
)
	drop view cs_ship_history_vw
go
    
create view cs_ship_history_vw 
as 
select	distinct shipper,
	part_original,
	isnull(suffix,0) as suffix,
	part,
	qty_required,
	qty_packed,
	shipper.bill_of_lading_number as bol_number,	
	shipper_detail.operator,
	shipper.truck_number,
	shipper.pro_number,
	shipper.ship_via,
	shipper.date_shipped,
	shipper_detail.customer_part,
	shipper_detail.order_no,
	shipper_detail.customer_po,
	shipper.destination,
	shipper.customer,
	customer.name customer_name,
	destination.name destination_name
from 	shipper_detail 
	join shipper on id=shipper
	join destination on destination.destination = shipper.destination
	join customer on customer.customer = destination.customer
where	(shipper.status='Z' or shipper.status='C') and
	(shipper.type='O' or shipper.type='Q' or shipper.type='V' or shipper.type is null)
go

print'
--------------------------
-- view: part_vendor_accum
--------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'part_vendor_accum' )
	drop view part_vendor_accum
GO

create view part_vendor_accum(part,vendor,accum_qty) as 
  select part,vendor,
    (select Isnull(sum(audit_trail.quantity),0) 
  from audit_trail 
  where audit_trail.part=part_vendor.part and 
        audit_trail.vendor=part_vendor.vendor and 
	audit_trail.type='R' and 
	audit_trail.date_stamp>=part_vendor.beginning_inventory_date) 
  from part_vendor
go


print'
------------------------
-- view: cs_customers_vw
------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('cs_customers_vw'))
	drop view cs_customers_vw
GO

create view cs_customers_vw
as 
select	c.customer,
	c.create_date,
	ca.closure_rate*100 as closure_rate,
	ca.ontime_rate*100 as ontime_rate,
	ca.return_rate*100 as return_rate,
	c.cs_status,
	c.name,
	c.address_1,
	c.address_2,
	c.address_3,
	c.address_4,
	c.address_5,
	c.address_6,
	c.phone,
	c.fax,
	c.modem,
	c.contact,
	c.salesrep,
	c.terms,
	c.notes,
	c.default_currency_unit,
	c.show_euro_amount,
	c.custom1,
	c.custom2,
	c.custom3,
	c.custom4,
	c.custom5,
	c.origin_code,
	c.sales_manager_code,
	c.region_code
from	customer as c,
	customer_additional as ca,
	customer_service_status as css
where	c.customer=ca.customer and
	css.status_name = c.cs_status and
	css.status_type <> 'C'
GO



print'
---------------------
-- view: cs_orders_vw
---------------------
'
if exists (select 1 from dbo.sysobjects where id = object_id('cs_orders_vw'))
	drop view cs_orders_vw
GO

create view cs_orders_vw
as 
-----------------------------------------------------------------------------------------
--	GPH	2/22/01	Included isnull function on status column in the where clause and
--		8:30am	also included order no. greater than 0 check as part of the where
--			clause.
-----------------------------------------------------------------------------------------
select 	oh.order_no,
	oh.order_date,
	oh.destination,
	oh.amount,
	oh.status,
	oh.notes,
	oh.customer,
	isnull(min(od.due_date),oh.due_date) due_date
from 	order_header oh
		left outer join order_detail od on oh.order_no = od.order_no,
	customer_service_status as css
where 	css.status_name = oh.cs_status and
	css.status_type <> 'C' and
	isnull(oh.status,'') <> 'C' and
	oh.order_no > 0
group by oh.order_no,
	oh.order_date,
	oh.destination,
	oh.amount,
	oh.status,
	oh.notes,
	oh.customer,
	oh.due_date
GO

print'
---------------------------
-- view: cs_part_profile_vw
---------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'cs_part_profile_vw' )
	drop view cs_part_profile_vw
GO

create view
  cs_part_profile_vw
  as select part,
    customer_part,
    customer_standard_pack,
    customer_unit,
    taxable,
    type,
    customer
    from part_customer
go



print'
-------------------------
-- view: bill_of_material
-------------------------
'
if exists (select 1 from dbo.sysobjects where id = object_id('bill_of_material'))
	drop view bill_of_material
GO

CREATE VIEW bill_of_material
    ( parent_part,
      part,
      type,
      quantity,
      unit_measure,
      reference_no,
      std_qty,
      substitute_part ) AS
  select bill_of_material_ec.parent_part,
         bill_of_material_ec.part,
         bill_of_material_ec.type,
         bill_of_material_ec.quantity * (1 + bill_of_material_ec.scrap_factor),
         bill_of_material_ec.unit_measure,
         bill_of_material_ec.reference_no,
         bill_of_material_ec.std_qty * (1 + bill_of_material_ec.scrap_factor),
         bill_of_material_ec.substitute_part         
    from bill_of_material_ec
   where ( bill_of_material_ec.start_datetime <= getdate() ) AND
         (bill_of_material_ec.end_datetime > getdate() OR
         bill_of_material_ec.end_datetime is null)


GO


print '
------------------------------------
-- VIEW: mvw_pb_resource_list
------------------------------------
'
if exists(select 1 from dbo.sysobjects where name = 'mvw_pb_resource_list' ) 
	drop view mvw_pb_resource_list
go

create view mvw_pb_resource_list (
	resource_name,
	resource_type )
as select machine_no,
	1
from	machine
go


print '
------------------------------------
-- VIEW: mvw_resource_task_list
------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mvw_resource_task_list' )
	drop view mvw_resource_task_list
go
create view mvw_resource_task_list (
	resource_name,
	resource_type,
	task_id,
	task_type,
	task_sequence,
	task_start,
	task_end,
	task_duration,
	task_description,
	task_due,
	task_balance,
	task_yield)
as select resource_name,
	resource_type,
	Convert ( integer, work_order ),
	1,
	sequence,
	convert(datetime,IsNull(convert(varchar,start_date,111),'0001-01-01')+substring(convert(varchar,start_time,109),12,15)),
	convert(datetime,IsNull(convert(varchar,end_date,111),'0001-01-01')+substring(convert(varchar,end_time,109),12,15)),
	DateDiff ( second, start_date, end_date ) runtime,
	(select min(part)
	from workorder_detail
	where workorder=work_order),
	work_order.due_date,
	IsNull (
	(	select	Min ( balance )
		from	workorder_detail
		where	workorder_detail.workorder = work_order.work_order ), 0 ),
	IsNull (
	(	select	min ( on_hand / bom.std_qty )
		from	workorder_detail
			join bill_of_material bom on workorder_detail.part = bom.parent_part
			join part_online on bom.part = part_online.part
		where	workorder_detail.workorder = work_order.work_order and
			bom.std_qty > 0 ), 0 )
from work_order 
     join mvw_pb_resource_list on machine_no=resource_name and resource_type=1
     
go

print '
---------------------------------------
-- VIEW: mvw_resource_shift_list
---------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mvw_resource_shift_list') 
	drop view mvw_resource_shift_list
go

create view mvw_resource_shift_list (
	resource_name,
	shift_Id,
	shift_start,
	shift_end,
	shift_labor,
	shift_crew,
	shift_length)
as select machine,
	ai_id,	
	begin_datetime,
	end_datetime,
	labor_code,
	crew_size,
	convert ( numeric, datediff ( hour, begin_datetime, end_datetime) ) 
from	shop_floor_calendar 
	join mvw_pb_resource_list on machine=resource_name
	and resource_type=1 
where	begin_datetime >= dateadd(dd,-1,getdate())
go

print '
---------------------------------------------------------------
--	View : mvw_billofmaterial
---------------------------------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('mvw_billofmaterial') )
	drop view mvw_billofmaterial
go
create view mvw_billofmaterial
    ( parent_part,
      part,
      type,
      std_qty ) AS
-------------------------------------------------------------------
--	View : mvw_billofmaterial required for super cop processing
--	
--	Harish Gubbi 01/07/2000	Created newly for super cop purposes
-------------------------------------------------------------------
select	bill_of_material_ec.parent_part,
        bill_of_material_ec.part,
        bill_of_material_ec.type,
        bill_of_material_ec.std_qty * (1 + bill_of_material_ec.scrap_factor)
from	bill_of_material_ec
where	(bill_of_material_ec.start_datetime <= getdate() ) AND
	(bill_of_material_ec.end_datetime > getdate() OR
	bill_of_material_ec.end_datetime is null) and
	isnull(bill_of_material_ec.substitute_part,'N') <> 'Y'
go

print '
------------------------------
-- view:	mvw_gss_demand
------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mvw_gss_demand' )
	drop view mvw_gss_demand
go

create view mvw_gss_demand
as
SELECT	order_detail.part_number,   
	order_detail.quantity,   
	order_detail.assigned,   
	order_detail.order_no,   
	order_detail.due_date,   
	order_detail.committed_qty,   
	order_detail.release_no,   
	order_detail.suffix,   
	order_detail.alternate_price as price,
	order_detail.destination
FROM 	order_detail, order_header, customer_service_status  
WHERE 	order_detail.quantity > IsNull ( order_detail.committed_qty, 0 )  and  
	order_detail.ship_type = 'N'  and
	order_header.order_no = order_detail.order_no and
	order_header.cs_status = customer_service_status.status_name and
	customer_service_status.status_type <> 'C'
go


print '
-------------------------------
-- view:	mvw_machinelist
-------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mvw_machinelist' ) 
	drop view mvw_machinelist
go
create view mvw_machinelist 
	(machine,
	sequence,
	part ) 
as
select	part_machine.machine,   
	part_machine.sequence,
	part_machine.part
from	part_machine  
where	part_machine.machine > '' 
--	and part_machine.sequence <= 6 -- needs to be included for guardian
go


print '
-------------------------------
-- view:	mvw_vendorlist
-------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mvw_vendorlist' ) 
	drop view mvw_vendorlist
go
create view mvw_vendorlist 
	(vendor,
	part ) 
as
select	part_vendor.vendor,
	part_vendor.part
from	part_vendor
where	part_vendor.vendor > '' 
go


print'
---------------------------
-- Stored Procedure Changes
---------------------------
'


print'
--------------------------------------------------------------
--	msp_assign_quantity
-------------------------------------------------------------
'
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

        while @@fetch_status = 0 and @std_qty > 0 
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
        deallocate parts_due

        commit transaction  -- 1t
end
go

print'
----------------------------------------
-- procedure:	msp_bol_destination_list
----------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'msp_bol_destination_list' )
	drop procedure msp_bol_destination_list
go

create procedure msp_bol_destination_list ( @shipper integer )
as
begin
	-- declare local variables
	declare @bol_number	integer,
		@destination	varchar(20),
		@count		integer
	
	-- get bill of lading number and destination from the passed shipper
	select	@bol_number = isnull ( bill_of_lading_number, 0 ),
		@destination = destination
	from	shipper
	where	id = @shipper
	
	-- is there already a bill of lading?
	if @bol_number > 0
	begin
		-- get the number of shippers on bol that have destinations different from passed shipper
		select	@count = count(id)
		from	shipper
		where	destination <> @destination and
			bill_of_lading_number = @bol_number

		-- if there is more that 1, return pool_code and editable flag of 0 (FALSE)
		if @count > 0
			select	edi_setups.pool_code code, 
				destination.name name,
				0 editable
			from	edi_setups,
				destination 
			where	destination.destination = edi_setups.pool_code and
				edi_setups.destination=@destination 
			order by code
		-- otherwise, return destination / pool_code and editable flag of 1 (TRUE)
		else
			select	edi_setups.pool_code code, 
				destination.name name,
				1 editable
			from	edi_setups,
				destination 
			where	destination.destination = edi_setups.pool_code and
				edi_setups.destination=@destination 
			UNION  
			select	destination code,
				name,
				1 editable
			from 	destination
			where 	destination.destination = @destination 
			order by code
	end
	else
	-- return destination / pool_code and editable flag of 1 (TRUE)
	begin
		select	edi_setups.pool_code code, 
			destination.name name,
			1 editable
		from	edi_setups,
			destination 
		where	destination.destination = edi_setups.pool_code and
			edi_setups.destination=@destination 
		UNION  
		select	destination code,
			name,
			1 editable
		from 	destination
		where 	destination.destination = @destination 
		order by code
	end
end
go


print'
----------------------------------
--	msp_build_vendor_part_list
----------------------------------
'

if exists ( select 1
            from dbo.sysobjects 
            where name = 'msp_build_vendor_part_list' )
        drop procedure msp_build_vendor_part_list
go

create procedure msp_build_vendor_part_list 
	( 	@mode varchar (1), 
		@st_date datetime, 
		@type varchar (15)= null, 
		@value varchar (15) = null) 
as
begin
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	This stored procedure is used to build the part/vendor list in po processor.
--	This also flags the part/vendor if there are active po releases to the same in the selected date range (week).
--
--	8/30/99 MB Original
--
--	Arguments : 	@mode 	 : 'Part' mode or 'Vendor' Mode on the po processor
--			@st_date : The start date on the po processor window
--			@type 	 : The type of filter selected by user
--			@value 	 : The value to filter for.
--
--	Return :	The set of part/vendor list with the flag value if they have active requirements.
--
--	Process :	
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

if @mode = 'V' 
begin

	if @type = 'All'
	
	        select distinct vendor.code,   
	               	vendor.name,   
	                 ( select distinct count ( vendor_code ) - count ( deleted )   
	                   from         po_detail 
	                   where po_detail.vendor_code = vendor.code and
	                   po_detail.status = 'A' and
	                   po_detail.date_due <= dateadd ( day, 7, @st_date ) ) flag
	        from vendor
	        order by 1 
	
	else if @type = 'DropShip'
	
	        select distinct vendor.code,   
	                vendor.name,   
	                 ( select distinct count ( vendor_code ) - count ( deleted )   
	                   from         po_detail 
	                   where   po_detail.vendor_code = vendor.code and
		                   po_detail.status = 'A' and
	        	           po_detail.date_due <= dateadd ( day, 7, getdate() ) and
				   po_detail.ship_type = 'D' ) flag
		from vendor 
		join po_header on po_header.vendor_code = vendor.code  and
				po_header.ship_type = 'DropShip' 
		order by 1
	
	  else if ( @type = 'Buyer' and @value > '' )
	
	        select distinct vendor.code,   
	               	  vendor.name,   
	                 ( select distinct count ( vendor_code ) - count ( deleted )   
	                   from         po_detail 
	                   where po_detail.vendor_code = vendor.code and
	                   po_detail.status = 'A' and
	                   po_detail.date_due <= dateadd ( day, 7, @st_date ) ) flag
	        from vendor
	        where vendor.buyer = @value 
	       order by 1
		
	else if ( @type = 'Vendor' and @value > '' )
	
	                select distinct vendor.code,   
	                       	 vendor.name,   
		                 ( select distinct count ( vendor_code ) - count ( deleted )   
		                   from         po_detail 
		                   where po_detail.vendor_code = vendor.code and
		                   po_detail.status = 'A' and
		                   po_detail.date_due <= dateadd ( day, 7, @st_date ) ) flag
	                from vendor
		where vendor.code = @value 
		order by 1
	
	else if ( @type = 'Plant' and @value > '' )
	
		select distinct po_header.vendor_code,
		       	vendor.name, 
		       	( select distinct count ( vendor_code ) - count ( deleted )   
	                           	from         po_detail 
	        	           	where po_detail.vendor_code = vendor.code and
	        	   	po_detail.status = 'A' and
	                   	po_detail.date_due <= dateadd ( day, 7, @st_date ) ) flag 
		from po_header
			join vendor on po_header.vendor_code = vendor.code 
		where 	( po_header.plant = @value )  and
		 	( po_header.status = 'A' ) 
			order by 1
	end 
	else if @mode = 'P'
	begin
	
	if @type = 'All' 
	
	        select  distinct part.part, 
		        	part.name,
		        	( select distinct count ( vendor_code ) - count ( deleted )   
		           	from         po_detail 
		           	where po_detail.part_number = part.part and
		           	po_detail.status = 'A' and
		           	po_detail.date_due <= dateadd ( day, 7 , getdate() ) ) flag
	          from part 
	          where ( part.class = 'P' ) OR ( part.class = 'N' ) 
	          order by 1
	
	else if  ( @type = 'Buyer' and @value > '' )
	
		select distinct part.part, 
			       part.name,
			        ( select distinct count ( vendor_code ) - count ( deleted )   
			          from         po_detail 
			          where po_detail.part_number = part.part and
			          po_detail.status = 'A' and
			          po_detail.date_due <= dateadd ( day, 7 , getdate() ) ) flag 
		from part, part_purchasing 
		where ( part.part = part_purchasing.part ) 
		AND (part.class = 'P' OR part.class = 'N') 
		AND ( part_purchasing.buyer = @value ) 
		order by 1
	
	else if ( @type = 'Commodity' and @value > '' )
	
		select distinct part.part,		       
			       part.name,
		                ( select distinct count ( vendor_code ) - count ( deleted )   
		                   from         po_detail 
		                   where po_detail.part_number = part.part and
		                   po_detail.status = 'A' and
		                   po_detail.date_due <= dateadd ( day, 7 , getdate() ) ) flag 
		from part 
		where ( part.commodity = @value ) 
		AND   (part.class = 'P' OR part.class = 'N') 
		order by 1
	
	end
end
go


print'
--------------------------------------
-- procedure:	msp_build_bom_timeline
--------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_build_bom_timeline'))
	drop procedure msp_build_bom_timeline
GO

CREATE PROCEDURE msp_build_bom_timeline (
	@top_part	char ( 25 ) )
AS
--	Procedure:	msp_build_bom_timeline
--	Date:		June 29 1999 - mb

	SELECT	effective_date,
		'*', 
		engineering_level,
		operator,
		notes
	  FROM	effective_change_notice
	 WHERE	part = @top_part 
	 ORDER BY 1

GO


print'
-------------------------------------------------------------------------
--	msp_build_po_grid
-------------------------------------------------------------------------
'
if exists (  select 1 
	from sysobjects 
	where id = object_id ( 'msp_build_po_grid'  )  )
        drop procedure msp_build_po_grid
go

create procedure msp_build_po_grid 
        ( @po_number integer = null,
        @start_dt datetime,
        @part varchar(25)=null,
        @mode varchar(1) ) 
as
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	This procedure builds the PO processor crosstab datawindow for a particular PO or Part
--
--	Arguments :	@po_number	: The po number for which the crosstab is being build
--			@start_dt 	: The start date from which the crosstab is built
--			@part		: The part for which crosstab is built
--			@mode		: The part mode or vendor mode switch.
--
--	MB : 09/09/1999	: Original
--
--	Process :
--		1. Create temp table to get all the parts from po_detail and part_vendor table
--		2. Check if its vendor mode  or part mode
--		3. Check if its a Blanket Purchase Order
--		4.  Insert part list to temp table 
--		5. Select rows from po detail and temp table 	    
--		6. Select the row from Blanket Purchase Order Detail	    
--		7. Select vendor list for the part, different po's
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	1. Create temp table to get all the parts from po_detail and part_vendor table

create table #mps_part ( part varchar (25) )

--	2. Check if its vendor mode  or part mode
if @mode='V'
begin
	--	3. Check if its a Blanket Purchase Order
	if ( select type from po_header where po_number = @po_number ) <>'B' 
	begin
		--	4.  Insert part list to temp table 
		
		insert into #mps_part 
		select	distinct pv.part 
		from	part_vendor pv
			join po_header poh on poh.vendor_code = pv.vendor
			left outer join part p on p.part = pv.part and p.class = 'P'
		where 	poh.po_number = @po_number
		union all
		select 	distinct pod.part_number
		from 	po_detail pod
			left outer join part p on p.part = pod.part_number and p.class = 'P'
		where 	pod.po_number = @po_number and 
			pod.part_number not in ( select	distinct pv.part 
						 from	part_vendor pv
						 join po_header poh on poh.vendor_code = pv.vendor
						 left outer join part p on p.part = pv.part and p.class = 'P'
						 where 	poh.po_number = @po_number)
		--	5. Select rows from po detail and temp table 	    
		select	po_detail.part_number,
			Max(po_detail.date_due),
			date1=Max(@start_dt),
			qty_past_due=(Sum(case when po_detail.date_due<@start_dt then quantity else 0 end)-Sum(case when po_detail.date_due<@start_dt then received else 0 end)),
			qty_date1=(Sum(case when po_detail.date_due<DateAdd(dd,1,@start_dt) and po_detail.date_due>=@start_dt then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,1,@start_dt) and po_detail.date_due>=@start_dt then received else 0 end)),
			qty_date2=(Sum(case when po_detail.date_due<DateAdd(dd,2,@start_dt) and po_detail.date_due>=DateAdd(dd,1,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,2,@start_dt) and po_detail.date_due>=DateAdd(dd,1,@start_dt) then received else 0 end)),
			qty_date3=(Sum(case when po_detail.date_due<DateAdd(dd,3,@start_dt) and po_detail.date_due>=DateAdd(dd,2,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,3,@start_dt) and po_detail.date_due>=DateAdd(dd,2,@start_dt) then received else 0 end)),
			qty_date4=(Sum(case when po_detail.date_due<DateAdd(dd,4,@start_dt) and po_detail.date_due>=DateAdd(dd,3,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,4,@start_dt) and po_detail.date_due>=DateAdd(dd,3,@start_dt) then received else 0 end)),
			qty_date5=(Sum(case when po_detail.date_due<DateAdd(dd,5,@start_dt) and po_detail.date_due>=DateAdd(dd,4,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,5,@start_dt) and po_detail.date_due>=DateAdd(dd,4,@start_dt) then received else 0 end)),
			qty_date6=(Sum(case when po_detail.date_due<DateAdd(dd,6,@start_dt) and po_detail.date_due>=DateAdd(dd,5,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,6,@start_dt) and po_detail.date_due>=DateAdd(dd,5,@start_dt) then received else 0 end)),
			qty_date7=(Sum(case when po_detail.date_due<DateAdd(dd,7,@start_dt) and po_detail.date_due>=DateAdd(dd,6,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,7,@start_dt) and po_detail.date_due>=DateAdd(dd,6,@start_dt) then received else 0 end)),
			Max(po_detail.po_number),
			Max(po_detail.release_type),
			Max(po_detail.release_no),
			flag=  isnull ( (select	max(1) 
					from	po_detail pod
					where	pod.date_due>DateAdd ( dd,7,@start_dt ) and
						pod.po_number = @po_number and
						po_detail.part_number = pod.part_number and
						( pod.deleted = 'N' or pod.deleted  is null ) ), 0 )
		from	po_detail 
			left outer join part p on p.part = po_detail.part_number and p.class = 'P'
		where	po_detail.po_number=@po_number
		group by po_Detail.part_number
	        union
		select  #mps_part.part,
			@start_dt,
			date1=@start_dt,
			qty_past_due=0,
			qty_date1=0,
			qty_date2=0,
			qty_date3=0,
			qty_date4=0,
			qty_date5=0,
			qty_date6=0,
			qty_date7=0,
			@po_number,
			null,
			null,
			flag= 0
		from	#mps_part
			left outer join part p on p.part = #mps_part.part and p.class = 'P'
		where 	#mps_part.part not in ( select distinct part_number  from po_Detail 
						where po_number = @po_number)
		group by #mps_part.part
		order by 1
	end
	else
--	6. Select the row from Blanket Purchase Order Detail	    
		select	max ( po_header.blanket_part),
			Max(po_detail.date_due),
			date1=Max(@start_dt),
			qty_past_due= (Sum(case when po_detail.date_due<@start_dt then quantity else 0 end)-Sum(case when po_detail.date_due<@start_dt then received else 0 end)),
			qty_date1= (Sum(case when po_detail.date_due<DateAdd(dd,1,@start_dt) and po_detail.date_due>=@start_dt then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,1,@start_dt) and po_detail.date_due>=@start_dt then received else 0 end)),
			qty_date2= (Sum(case when po_detail.date_due<DateAdd(dd,2,@start_dt) and po_detail.date_due>=DateAdd(dd,1,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,2,@start_dt) and po_detail.date_due>=DateAdd(dd,1,@start_dt) then received else 0 end)),
			qty_date3= (Sum(case when po_detail.date_due<DateAdd(dd,3,@start_dt) and po_detail.date_due>=DateAdd(dd,2,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,3,@start_dt) and po_detail.date_due>=DateAdd(dd,2,@start_dt) then received else 0 end)),
			qty_date4= (Sum(case when po_detail.date_due<DateAdd(dd,4,@start_dt) and po_detail.date_due>=DateAdd(dd,3,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,4,@start_dt) and po_detail.date_due>=DateAdd(dd,3,@start_dt) then received else 0 end)),
			qty_date5= (Sum(case when po_detail.date_due<DateAdd(dd,5,@start_dt) and po_detail.date_due>=DateAdd(dd,4,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,5,@start_dt) and po_detail.date_due>=DateAdd(dd,4,@start_dt) then received else 0 end)),
			qty_date6= (Sum(case when po_detail.date_due<DateAdd(dd,6,@start_dt) and po_detail.date_due>=DateAdd(dd,5,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,6,@start_dt) and po_detail.date_due>=DateAdd(dd,5,@start_dt) then received else 0 end)),
			qty_date7= (Sum(case when po_detail.date_due<DateAdd(dd,7,@start_dt) and po_detail.date_due>=DateAdd(dd,6,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,7,@start_dt) and po_detail.date_due>=DateAdd(dd,6,@start_dt) then received else 0 end)),
			Max(po_detail.po_number),
			Max(po_detail.release_type),
			Max(po_detail.release_no),
			flag=isnull ( ( select max(1)
					from po_detail
					where po_detail.date_due>DateAdd(dd,7,@start_dt)
					and po_number=@po_number), 0 )
		from	po_header 
			left outer join po_Detail on po_Detail.po_number  = po_header.po_number
			left outer join part p on p.part = po_detail.part_number and p.class = 'P'
		where	po_header.po_number = @po_number
end		
else if @mode='P'
--	7. Select vendor list for the part, different po's
	select	max ( po_detail.vendor_code ),
		Max(po_detail.date_due),
		date1=Max(@start_dt),
		qty_past_due=(Sum(case when po_detail.date_due<@start_dt then quantity else 0 end)-Sum(case when po_detail.date_due<@start_dt then received else 0 end)),
		qty_date1=(Sum(case when po_detail.date_due<DateAdd(dd,1,@start_dt) and po_detail.date_due>=@start_dt then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,1,@start_dt) and po_detail.date_due>=@start_dt then received else 0 end)),
		qty_date2=(Sum(case when po_detail.date_due<DateAdd(dd,2,@start_dt) and po_detail.date_due>=DateAdd(dd,1,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,2,@start_dt) and po_detail.date_due>=DateAdd(dd,1,@start_dt) then received else 0 end)),
		qty_date3=(Sum(case when po_detail.date_due<DateAdd(dd,3,@start_dt) and po_detail.date_due>=DateAdd(dd,2,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,3,@start_dt) and po_detail.date_due>=DateAdd(dd,2,@start_dt) then received else 0 end)),
		qty_date4=(Sum(case when po_detail.date_due<DateAdd(dd,4,@start_dt) and po_detail.date_due>=DateAdd(dd,3,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,4,@start_dt) and po_detail.date_due>=DateAdd(dd,3,@start_dt) then received else 0 end)),
		qty_date5=(Sum(case when po_detail.date_due<DateAdd(dd,5,@start_dt) and po_detail.date_due>=DateAdd(dd,4,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,5,@start_dt) and po_detail.date_due>=DateAdd(dd,4,@start_dt) then received else 0 end)),
		qty_date6=(Sum(case when po_detail.date_due<DateAdd(dd,6,@start_dt) and po_detail.date_due>=DateAdd(dd,5,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,6,@start_dt) and po_detail.date_due>=DateAdd(dd,5,@start_dt) then received else 0 end)),
		qty_date7=(Sum(case when po_detail.date_due<DateAdd(dd,7,@start_dt) and po_detail.date_due>=DateAdd(dd,6,@start_dt) then quantity else 0 end)-Sum(case when po_detail.date_due<DateAdd(dd,7,@start_dt) and po_detail.date_due>=DateAdd(dd,6,@start_dt) then received else 0 end)),
		Max(po_detail.po_number),
		Max(po_detail.release_type),
		Max(po_detail.release_no),
		flag= isnull ( (select max(1) 
				from po_detail pod
				where pod.date_due>DateAdd(dd,7,@start_dt) and
				po_detail.po_number = pod.po_number and
				po_detail.part_number = pod.part_number and
				( pod.deleted = 'N' or pod.deleted  is null ) ), 0 )
	from	po_detail
		left outer join part p on p.part = po_detail.part_number and p.class = 'P'
	where	po_detail.status='A' and
		po_detail.part_number = @part
	group by  po_detail.part_number, po_detail.po_number
drop table #mps_part
go

print'
----------------------------
-- msp_build_rma_exp_objects
----------------------------
'
if exists 
	( select 1
	  from dbo.sysobjects
	  where id = object_id ('msp_build_rma_exp_objects') )
	drop procedure msp_build_rma_exp_objects
go

create procedure msp_build_rma_exp_objects
	( @shipper integer )
as
----------------------------------------------------------------------
--
--
--
--
--
--
--
----------------------------------------------------------------------
begin -- ( 1B)

	select	audit_trail.serial,   
		audit_trail.part,   
		audit_trail.quantity,   
		audit_trail.status,   
		audit_trail.engineering_level,   
		audit_trail.date_stamp,
		audit_trail.object_type,
		audit_trail.type
	from	audit_trail
			join shipper_detail on shipper_detail.shipper = @shipper and audit_trail.part = shipper_detail.part_original
	where	audit_trail.shipper = convert(varchar,shipper_detail.old_shipper)
		and audit_trail.serial not in ( select	serial 
						from	audit_trail 
						where	type = 'U' ) 
		and audit_trail.type = 'S' 

end -- ( 1E) 
go

print'
------------------------------
-- procedure:	msp_calc_costs
------------------------------
'
if exists(select 1 from dbo.sysobjects where name='msp_calc_costs' and type = 'P')
   drop procedure msp_calc_costs
go
create procedure msp_calc_costs (@part varchar(25), @cost_bucket char(1)) as  
begin -- (1b)
--------------------------------------------------------------------------------------------------------------------------
--
--	Procedure 	msp_calc_costs
--	Arguments	part varchar(25)
--			cost bucket char(1) ie S/P/Q/F
--	Purpose		To rollup the cost from it's components for the specified part
--
--	Logic		
--		Declare variables
--		Create Temp tables
--		Initialize
--		Process data in temp table #bom_parts starting from the top part
--			process all component parts
--		processing the costing rollup from the deepest level 
--		process all the rows in the temp table in the reverse order (cost rolls up from inner most to top part)
--			calculate labor & burden
--			update part_standard table with the new values for the current part
--
--	Development	GPH
--------------------------------------------------------------------------------------------------------------------------
--	Declare variables
declare @rowno  int, 
	@rowno_prev int,   
	@parent_part varchar(25),
	@parent_part_prev varchar(25),
	@bom_level integer,                    
	@partno varchar(25),
	@parentpartno varchar(25),
	@part_tmp varchar(25),
	@bom_qty numeric(20,6),
	@bom_type char(1),
	@bomlevel integer,
	@extended_qty numeric(20,6),
	@cost              numeric(20,6),
	@material          numeric(20,6),
	@labor             numeric(20,6),
	@burden            numeric(20,6),
	@other             numeric(20,6),
	@cost_cum          numeric(20,6),
	@material_cum      numeric(20,6),
	@labor_cum         numeric(20,6),
	@burden_cum        numeric(20,6),
	@other_cum         numeric(20,6),
	@mfg_lot_size      numeric(20,6),
	@standard_rate     numeric(20,6),
	@standard_rate_mc  numeric(20,6),  
	@parts_per_hour    numeric(20,6),
	@setup_time        numeric(5,2),
	@machine_no        varchar(10),
	@include_setuptime varchar(1),
	@varying           numeric(20,6),
	@indirect          numeric(20,6),
	@sga               numeric(20,6), 
	@varying_mc        numeric(20,6),
	@indirect_mc       numeric(20,6),
	@sga_mc            numeric(20,6), 
	@crew_size         numeric(20,6), 
	@parttype          varchar(1),
	@calc_mtl_cost     varchar(1),
	@default_vendor    varchar(10),
	@vendor_price      numeric(15,7),
	@qty               numeric(20,6),
	@vendor_uom        varchar(2),
	@std_uom           varchar(2),
	@conversion        numeric(15,7),
	@bom_uom           varchar(2),
	@count             integer

--	Create Temp tables
create table #bom_parts ( 
	rowno integer not null,
	parent_part varchar(25) null,
	part varchar(25) not null,
	bom_qty  numeric(20,6) not null,
	bom_level integer not null,
	bom_uom varchar(2) null)

create table #bom_parts_adnl ( 
	rowno integer not null,
	parent_part varchar(25) null,
	part varchar(25) not null,
	bom_qty  numeric(20,6) not null,
	bom_level integer not null,
	bom_uom varchar(2) null)

create table #duplicate_parts ( 
	parentpart 	varchar(25),
	part		varchar(25))

create table #bom_comp (part varchar(25) not null, 
	bom_qty numeric(20,6) not null,
	bom_uom varchar(2) null) 

begin transaction

	set rowcount 0
	--	Initialize
	select	@rowno=1, @bom_level = isnull(@bom_level,0) + 1

	select	@include_setuptime=include_setuptime,
		@calc_mtl_cost    =calc_mtl_cost
	from	parameters

	insert into #bom_parts values (@rowno, @parent_part, @part, 1, @bom_level, @bom_uom) 
	
	--	Process data in temp table #bom_parts starting from the top part
	set rowcount 1
	select	@partno=part,
		@rowno_prev = rowno,
		@bomlevel = bom_level 
	from	#bom_parts
	where	rowno > 0

	while @@rowcount > 0
	begin -- (2b)
		set rowcount 0  
		if @cost_bucket='S'
			update	part_standard
			set	cost_cum=0, material_cum=0, labor_cum=0, burden_cum=0, other_cum=0, cost=0 
			where	part = @partno
		else if @cost_bucket='Q'
			update	part_standard
			set	qtd_cost_cum=0, qtd_material_cum=0, qtd_labor_cum=0, 
				qtd_burden_cum=0, qtd_other_cum=0, qtd_cost=0 
			where	part = @partno
		else if @cost_bucket='P'
			update	part_standard
			set	planned_cost_cum=0, planned_material_cum=0, planned_labor_cum=0, 
				planned_burden_cum=0, planned_other_cum=0, planned_cost=0 
			where	part = @partno
		else if	@cost_bucket='F' 
			update	part_standard
			set	frozen_cost_cum=0, frozen_material_cum=0, frozen_labor_cum=0, 
				frozen_burden_cum=0, frozen_other_cum=0, frozen_cost=0 
			where	part = @partno

		set rowcount 0 
		--	insert into components temp table for the considered part
		insert into #bom_comp 
		select part, quantity, unit_measure from bill_of_material where parent_part = @partno and substitute_part <> 'Y'
		
		if @@rowcount > 0
		begin -- (3b)
			--	process all component parts		
			set rowcount 0 
			select @bomlevel = isnull(@bomlevel,0) + 1

			set rowcount 1
			select @part_tmp = part, @bom_qty = bom_qty, @bom_uom = bom_uom from #bom_comp

			while @@rowcount > 0
			begin -- (4b)
				set rowcount 0 
				select @rowno = @rowno + 1
				insert #bom_parts values (@rowno, @partno, @part_tmp, @bom_qty, @bomlevel, @bom_uom) 

				set rowcount 0              
				delete from #bom_comp where (part = @part_tmp)   

				set rowcount 1 
				select @part_tmp = part, @bom_qty = bom_qty, @bom_uom = bom_uom from #bom_comp
			end  -- (4e)
			set rowcount 0 
			delete from #bom_comp
			
		end -- (3e)
		
		set rowcount 1
		select	@partno=part,
			@rowno_prev = rowno,
			@bomlevel = bom_level
		from	#bom_parts
		where rowno > @rowno_prev
	end -- (2e)
	
	--	processing the costing rollup from the deepest level 
	set rowcount 0 
	insert	into #bom_parts_adnl
	select	rowno, parent_part, part, bom_qty, bom_level, bom_uom 
	from	#bom_parts
	order by rowno desc
	
	--	process all the rows in the temp table in the reverse order (cost rolls up from inner most to top part)
	set rowcount 1  
	select	@rowno = rowno,
		@parent_part=parent_part,
		@part = part,
		@bom_qty = isnull(bom_qty,1),
		@bom_level = bom_level,
		@bom_uom = bom_uom
	from	#bom_parts_adnl

	while @@rowcount > 0
	begin -- (3b)
		set rowcount 0 
		select	@material=0, @burden=0, @labor=0, @other=0, @cost=0, 
			@material_cum=0, @burden_cum=0, @labor_cum=0, @other_cum=0, @cost_cum=0,
			@standard_rate=0, @varying=0, @indirect=0, @sga=0,
			@standard_rate_mc=0, @varying_mc=0, @indirect_mc=0, @sga_mc=0,
			@conversion=1
			
		if @cost_bucket='S' -- Standard 
		begin 
			select	@material=isnull(ps.material,0.0),
				@labor   =isnull(ps.labor,0.0),
				@burden  =isnull(ps.burden,0.0),
				@other   =isnull(ps.other,0.0),
				@material_cum=isnull(ps.material_cum,0.0),
				@labor_cum   =isnull(ps.labor_cum,0.0),
				@burden_cum  =isnull(ps.burden_cum,0.0),
				@other_cum   =isnull(ps.other_cum,0.0),
				@parttype=(select p.class from part as p where p.part = ps.part),
				@std_uom=(select pi.standard_unit from part_inventory as pi where pi.part = ps.part),
				@default_vendor=(select isnull(pol.default_vendor,'') from part_online as pol where pol.part = ps.part),
				@machine_no=(select pm.machine from part_machine as pm where pm.part = ps.part  and pm.sequence = 1)
			from	part_standard as ps
			where	ps.part=@part

			set rowcount 1 
			select	@parts_per_hour=pmg.parts_per_hour,
				@mfg_lot_size  =pmg.mfg_lot_size,
				@setup_time    =pmg.setup_time,   
				@standard_rate =isnull(l.standard_rate,0),
				@varying       =isnull(l.varying_rate_1,0),
				@indirect      =isnull(l.indirect,0),
				@sga           =0
			from	part_mfg as pmg
				join labor as l on l.id = pmg.labor_code
			where	part=@part
			
			select	@standard_rate_mc=isnull(standard_rate,0),
				@varying_mc      =isnull(varying_rate_1,0),
				@indirect_mc     =isnull(indirect,0),
				@sga_mc          =0
			from	machine
			where	machine_no=@machine_no
		end
		else if @cost_bucket='Q' -- Quoted
		begin
			select	@material=isnull(ps.qtd_material,0.0),
				@labor   =isnull(ps.qtd_labor,0.0),
				@burden  =isnull(ps.qtd_burden,0.0),
				@other   =isnull(ps.qtd_other,0.0),
				@material_cum=isnull(ps.qtd_material_cum,0.0),
				@labor_cum   =isnull(ps.qtd_labor_cum,0.0),
				@burden_cum  =isnull(ps.qtd_burden_cum,0.0),
				@other_cum   =isnull(ps.qtd_other_cum,0.0),
				@parttype=(select p.class from part as p where p.part = ps.part),
				@std_uom=(select pi.standard_unit from part_inventory as pi where pi.part = ps.part),
				@default_vendor=(select isnull(pol.default_vendor,'') from part_online as pol where pol.part = ps.part),
				@machine_no=(select pm.machine from part_machine as pm where pm.part = ps.part  and pm.sequence = 1)
			from	part_standard as ps
			where	ps.part=@part
			
			set rowcount 1 
			select	@parts_per_hour=pmg.parts_per_hour,
				@mfg_lot_size  =pmg.mfg_lot_size,
				@setup_time    =pmg.setup_time,   
				@standard_rate =isnull(l.qted_rate,0),
				@varying       =isnull(l.qted_variable,0),
				@indirect      =isnull(l.qted_indirect,0),
				@sga           =isnull(l.qted_sga,0)
			from	part_mfg as pmg
				join labor as l on l.id = pmg.labor_code
			where	part=@part
			
			select	@standard_rate_mc=isnull(qted_rate,0),
				@varying_mc      =isnull(qted_variable,0),
				@indirect_mc     =isnull(qted_indirect,0),
				@sga_mc          =isnull(qted_sga,0)
			from	machine
			where	machine_no=@machine_no
		end
		else if @cost_bucket='P' -- Planned
		begin  
			select	@material=isnull(ps.planned_material,0.0),
				@labor   =isnull(ps.planned_labor,0.0),
				@burden  =isnull(ps.planned_burden,0.0),
				@other   =isnull(ps.planned_other,0.0),
				@material_cum=isnull(ps.planned_material_cum,0.0),
				@labor_cum   =isnull(ps.planned_labor_cum,0.0),
				@burden_cum  =isnull(ps.planned_burden_cum,0.0),
				@other_cum   =isnull(ps.planned_other_cum,0.0),
				@parttype=(select p.class from part as p where p.part = ps.part),
				@std_uom=(select pi.standard_unit from part_inventory as pi where pi.part = ps.part),
				@default_vendor=(select isnull(pol.default_vendor,'') from part_online as pol where pol.part = ps.part),
				@machine_no=(select pm.machine from part_machine as pm where pm.part = ps.part  and pm.sequence = 1)
			from	part_standard as ps
			where	ps.part=@part

			set rowcount 1 
			select	@parts_per_hour=pmg.parts_per_hour,
				@mfg_lot_size  =pmg.mfg_lot_size,
				@setup_time    =pmg.setup_time,   
				@standard_rate =isnull(l.plnd_rate,0),
				@varying       =isnull(l.plnd_variable,0),
				@indirect      =isnull(l.plnd_indirect,0),
				@sga           =isnull(l.plnd_sga,0)
			from	part_mfg as pmg
				join labor as l on l.id = pmg.labor_code
			where	part=@part
			
			select	@standard_rate=isnull(plnd_rate,0),
				@varying      =isnull(plnd_variable,0),
				@indirect     =isnull(plnd_indirect,0),
				@sga          =isnull(plnd_sga,0)
			from	machine
			where	machine_no=@machine_no
		end 
		else if @cost_bucket='F' -- Frozen
		begin 
			select	@material=isnull(ps.frozen_material,0.0),
				@labor   =isnull(ps.frozen_labor,0.0),
				@burden  =isnull(ps.frozen_burden,0.0),
				@other   =isnull(ps.frozen_other,0.0),
				@material_cum=isnull(ps.frozen_material_cum,0.0),
				@labor_cum   =isnull(ps.frozen_labor_cum,0.0),
				@burden_cum  =isnull(ps.frozen_burden_cum,0.0),
				@other_cum   =isnull(ps.frozen_other_cum,0.0),
				@parttype=(select p.class from part as p where p.part = ps.part),
				@std_uom=(select pi.standard_unit from part_inventory as pi where pi.part = ps.part),
				@default_vendor=(select isnull(pol.default_vendor,'') from part_online as pol where pol.part = ps.part),
				@machine_no=(select pm.machine from part_machine as pm where pm.part = ps.part  and pm.sequence = 1)
			from	part_standard as ps
			where	ps.part=@part
			
			set rowcount 1 
			select	@parts_per_hour=pmg.parts_per_hour,
				@mfg_lot_size  =pmg.mfg_lot_size,
				@setup_time    =pmg.setup_time,   
				@standard_rate =isnull(l.frzn_rate,0),
				@varying       =isnull(l.frzn_variable,0),
				@indirect      =isnull(l.frzn_indirect,0),
				@sga           =isnull(l.frzn_sga,0)
			from	part_mfg as pmg
				join labor as l on l.id = pmg.labor_code
			where	part=@part
			
			select	@standard_rate=isnull(frzn_rate,0),
				@varying      =isnull(frzn_variable,0),
				@indirect     =isnull(frzn_indirect,0),
				@sga          =isnull(frzn_sga,0)
			from	machine
			where	machine_no=@machine_no
		end
		
		if	@calc_mtl_cost='Y' and @parttype='P'
		begin
			set rowcount 1 
			select	@vendor_uom=receiving_um
			from	part_vendor
			where	part=@part and vendor=@default_vendor
			
			if @std_uom <> @vendor_uom
			begin
				set rowcount 1 
				select	@conversion=isnull(uc.conversion,1)
				from	part_unit_conversion as puc
					join unit_conversion as uc on uc.code=puc.code and
					uc.unit1=@std_uom and uc.unit2=@vendor_uom
				where	puc.part = @part
			end

			set rowcount 1
			select	@vendor_price=isnull(price,0)
			from	part_vendor_price_matrix
			where	vendor=@default_vendor and part=@part and break_qty=1
			
			if @cost_bucket='S'
				select @material= isnull(@vendor_price,0) * isnull(@conversion,1)
		end

		if @std_uom <> @bom_uom
		begin 
			set rowcount 1 
			select	@conversion=isnull(conversion,1)
			from	part_unit_conversion as a,unit_conversion as b
			where	a.part = @part and b.code=a.code and unit1=@bom_uom and unit2=@std_uom
			if @conversion is null
				select @conversion=1 
		end
		
		if @mfg_lot_size = 0
			select @mfg_lot_size=null
			
		if @parts_per_hour=0
			select @parts_per_hour=null 
			
		set rowcount 1
		select	@crew_size=isnull(crew_size,1)
		from	part_machine
		where	part=@part and machine=@machine_no and sequence=1

		if @crew_size is null or @crew_size=0
			select @crew_size=1  

		--	calculate labor & burden
		if @cost_bucket='S'
			if @include_setuptime='Y'
			begin
				--	calculate the labor with setuptime
				select @labor=(((1.0/isnull(@parts_per_hour,1.0))+(isnull(@setup_time,0.0)/isnull(@mfg_lot_size,1)))* (isnull(@standard_rate,0) * isnull(@crew_size,1)))
				if @varying>0
					select @labor= @labor + (((1.0/isnull(@parts_per_hour,1.0))+(isnull(@setup_time,0.0)/isnull(@mfg_lot_size,1))) * isnull(@varying,0)  * isnull(@crew_size,1))  
				if @indirect>0
					select @labor= @labor + (((1.0/isnull(@parts_per_hour,1.0))+(isnull(@setup_time,0.0)/isnull(@mfg_lot_size,1))) * isnull(@indirect,0) * isnull(@crew_size,1)) 
				if @sga>0
					select @labor= @labor + (((1.0/isnull(@parts_per_hour,1.0))+(isnull(@setup_time,0.0)/isnull(@mfg_lot_size,1))) * isnull(@sga,0)      * isnull(@crew_size,1)) 
					
				--	calculate the burden with setuptime
				select @burden = (((1.0/isnull(@parts_per_hour,1.0)) + (isnull(@setup_time,0.0)/isnull(@mfg_lot_size,1))) * isnull(@standard_rate_mc,0)) 
				if @varying_mc>0
					select @burden = isnull(@burden,0) + (((1.0/isnull(@parts_per_hour,1.0)) + (isnull(@setup_time,0.0)/isnull(@mfg_lot_size,1))) * isnull(@varying_mc,0))
				if @indirect_mc>0
					select @burden = isnull(@burden,0) + (((1.0/isnull(@parts_per_hour,1.0)) + (isnull(@setup_time,0.0)/isnull(@mfg_lot_size,1))) * isnull(@indirect_mc,0))
				if @sga_mc>0
					select @burden = isnull(@burden,0) + (((1.0/isnull(@parts_per_hour,1.0)) + (isnull(@setup_time,0.0)/isnull(@mfg_lot_size,1))) * isnull(@sga_mc,0))
			end -- ()
			else
			begin
				--	calculate labor without setup time
				select @labor=((1.0/isnull(@parts_per_hour,1.0))* (isnull(@standard_rate,0) * isnull(@crew_size,1)))
				if @varying>0
					select @labor= @labor + ((1.0/isnull(@parts_per_hour,1.0)) * isnull(@varying,0)  * isnull(@crew_size,1))  
				if @indirect>0
					select @labor= @labor + ((1.0/isnull(@parts_per_hour,1.0)) * isnull(@indirect,0) * isnull(@crew_size,1)) 
				if @sga>0
					select @labor= @labor + ((1.0/isnull(@parts_per_hour,1.0)) * isnull(@sga,0)      * isnull(@crew_size,1)) 
					
				--	calculate the burden without setuptime
				select @burden=((1.0/isnull(@parts_per_hour,1.0))* isnull(@standard_rate_mc,0))
				if @varying_mc>0
					select @burden = isnull(@burden,0) + ((1.0/isnull(@parts_per_hour,1.0)) * isnull(@varying_mc,0))
				if @indirect_mc>0
					select @burden = isnull(@burden,0) + ((1.0/isnull(@parts_per_hour,1.0)) * isnull(@indirect_mc,0))
				if @sga_mc>0
					select @burden = isnull(@burden,0) + ((1.0/isnull(@parts_per_hour,1.0)) * isnull(@sga_mc,0))
			end
	
		if @parttype in ('M', 'O')
			select	@material_cum = isnull(@material_cum,0) + isnull(@material,0),
				@labor_cum    = isnull(@labor_cum,0) + isnull(@labor,0),
				@burden_cum   = isnull(@burden_cum,0) + isnull(@burden,0), 
				@other_cum    = isnull(@other_cum,0) + isnull(@other,0)
		else
			if ((select a.flow_route_window 
				from	activity_codes a
					join part_machine b on b.activity = a.code
				where	b.part = @part) = 'w_create_flow_route_outside_version2')
				select	@material_cum = isnull(@material_cum,0) + isnull(@material,0),
					@labor_cum    = isnull(@labor_cum,0) + isnull(@labor,0),
					@burden_cum   = isnull(@burden_cum,0) + isnull(@burden,0), 
					@other_cum    = isnull(@other_cum,0) + isnull(@other,0)
			else    
				select	@material_cum = isnull(@material,0),
					@labor_cum    = isnull(@labor,0),
					@burden_cum   = isnull(@burden,0), 
					@other_cum    = isnull(@other,0)
					
		select	@cost_cum     = isnull(@material_cum,0.0)+
					isnull(@burden_cum,0.0)  +
					isnull(@labor_cum,0.0)   +
					isnull(@other_cum,0.0)
		select	@cost         = isnull(@material,0.0)+
					isnull(@burden,0.0)  +
					isnull(@labor,0.0)   +
					isnull(@other,0.0)
			
		--	update part_standard table with the new values for the current part					
		set rowcount 0 
		if @cost_bucket='S'
		begin  
			update	part_standard 
			set	cost        =isnull(@cost,0.0),
				material    =isnull(@material,0.0),
				labor       =isnull(@labor,0.0),
				burden      =isnull(@burden,0.0),
				other       =isnull(@other,0.0),
				cost_cum    =isnull(@cost_cum,0.0),
				material_cum=isnull(@material_cum,0.0),
				burden_cum  =isnull(@burden_cum,0.0),
				other_cum   =isnull(@other_cum,0.0),
				labor_cum   =isnull(@labor_cum,0.0),
				flag        =1,
				cost_changed_date=getdate() 
			where	part=@part
			
			select @count = count(1) from #duplicate_parts where parentpart=@parent_part and part=@part
			if @count = 0 
			begin  
				insert into #duplicate_parts values ( @parent_part, @part )
				set rowcount 0 
				--	update parent too
				update	part_standard
				set	material_cum=material_cum + (isnull(@material_cum,0.0) * @bom_qty * @conversion),
					labor_cum   =labor_cum    + (isnull(@labor_cum,0.0) * @bom_qty * @conversion),
					burden_cum  =burden_cum   + (isnull(@burden_cum,0.0) * @bom_qty * @conversion),
					other_cum   =other_cum    + (isnull(@other_cum,0.0) * @bom_qty * @conversion)
				where	part=@parent_part
			end          
		end
		else if @cost_bucket='Q'
		begin  
			update	part_standard
			set	qtd_cost        =isnull(@cost,0.0),
				qtd_material    =isnull(@material,0.0),
				qtd_labor       =isnull(@labor,0.0),
				qtd_burden      =isnull(@burden,0.0),
				qtd_other       =isnull(@other,0.0),
				qtd_cost_cum    =isnull(@cost_cum,0.0),
				qtd_material_cum=isnull(@material_cum,0.0),
				qtd_burden_cum  =isnull(@burden_cum,0.0),
				qtd_other_cum   =isnull(@other_cum,0.0),
				qtd_labor_cum   =isnull(@labor_cum,0.0),
				flag        =1,
				qtd_changed_date=getdate() 
			where part=@part
			
			select @count = count(1) from #duplicate_parts where parentpart=@parent_part and part=@part
			if @count = 0 
			begin  
				insert into #duplicate_parts values ( @parent_part, @part )
				set rowcount 0 

				update	part_standard 
				set	qtd_material_cum=qtd_material_cum + (isnull(@material_cum,0.0) * @bom_qty * @conversion),
					qtd_labor_cum   =qtd_labor_cum    + (isnull(@labor_cum,0.0) * @bom_qty * @conversion),
					qtd_burden_cum  =qtd_burden_cum   + (isnull(@burden_cum,0.0) * @bom_qty * @conversion),
					qtd_other_cum   =qtd_other_cum    + (isnull(@other_cum,0.0) * @bom_qty * @conversion)
				where	part=@parent_part
			end         
		end
		else if @cost_bucket='P'
		begin  
			update	part_standard
			set	planned_cost        =isnull(@cost,0.0),
				planned_material    =isnull(@material,0.0),
				planned_labor       =isnull(@labor,0.0),
				planned_burden      =isnull(@burden,0.0),
				planned_other       =isnull(@other,0.0),
				planned_cost_cum    =isnull(@cost_cum,0.0),
				planned_material_cum=isnull(@material_cum,0.0),
				planned_burden_cum  =isnull(@burden_cum,0.0),
				planned_other_cum   =isnull(@other_cum,0.0),
				planned_labor_cum   =isnull(@labor_cum,0.0),
				flag        =1,
				planned_changed_date=getdate() 
			where	part=@part
			
			select @count = count(1) from #duplicate_parts where parentpart=@parent_part and part=@part
			if @count = 0 
			begin  
				insert into #duplicate_parts values ( @parent_part, @part )
				set rowcount 0 

				update	part_standard 
				set	planned_material_cum=planned_material_cum + (isnull(@material_cum,0.0) * @bom_qty * @conversion),
					planned_labor_cum   =planned_labor_cum    + (isnull(@labor_cum,0.0) * @bom_qty * @conversion),
					planned_burden_cum  =planned_burden_cum   + (isnull(@burden_cum,0.0) * @bom_qty * @conversion),
					planned_other_cum   =planned_other_cum    + (isnull(@other_cum,0.0) * @bom_qty * @conversion)
				where	part=@parent_part
			end         
		end
		else if @cost_bucket='F'
		begin
			update part_standard
			set	frozen_cost        =isnull(@cost,0.0),
				frozen_material    =isnull(@material,0.0),
				frozen_labor       =isnull(@labor,0.0),
				frozen_burden      =isnull(@burden,0.0),
				frozen_other       =isnull(@other,0.0),
				frozen_cost_cum    =isnull(@cost_cum,0.0),
				frozen_material_cum=isnull(@material_cum,0.0),
				frozen_burden_cum  =isnull(@burden_cum,0.0),
				frozen_other_cum   =isnull(@other_cum,0.0),
				frozen_labor_cum   =isnull(@labor_cum,0.0),
				flag        =1,
				frozen_changed_date=getdate() 
			where	part=@part
			
			select @count = count(1) from #duplicate_parts where parentpart=@parent_part and part=@part
			if @count = 0 
			begin  
				insert into #duplicate_parts values ( @parent_part, @part )
				set rowcount 0 

				update	part_standard
				set	frozen_material_cum=frozen_material_cum + (isnull(@material_cum,0.0) * @bom_qty * @conversion),
					frozen_labor_cum   =frozen_labor_cum    + (isnull(@labor_cum,0.0) * @bom_qty * @conversion),
					frozen_burden_cum  =frozen_burden_cum   + (isnull(@burden_cum,0.0) * @bom_qty * @conversion),
					frozen_other_cum   =frozen_other_cum    + (isnull(@other_cum,0.0) * @bom_qty * @conversion)
				where	part=@parent_part
			end         
		end

		set rowcount 0 
		delete from #bom_parts_adnl where rowno = @rowno
		
		--	get next set of data 
		set rowcount 1  
		select	@rowno = rowno,
			@parent_part=parent_part,
			@part = part,
			@bom_qty = isnull(bom_qty,1),
			@bom_level = bom_level,
			@bom_uom = bom_uom
		from	#bom_parts_adnl
	end -- (3e)
	drop table #duplicate_parts
	set rowcount 0 
commit transaction  
end -- (1e)
go

------------------------
--	msp_credit_memo
------------------------

if exists ( select 1 
            from sysobjects 
            where id = object_id ('msp_credit_memo') )
        drop procedure msp_credit_memo
go

create procedure msp_credit_memo 
	( @rma integer, 
	  @operator varchar (5),
	  @invoice integer OUTPUT )
as

--------------------------------------------------------------------------------
-- 	This procedure creates invoice for an existing and staged shipper. 
--
--	Modifications :	MB 	07/06/99 11:20 AM Original
--			 	07/13/99 14:19 PM Modified
--
--
-- 	Arguments   :	@rma integer - rma shipper for which credit memo is issued. 
--	            : 	@operator - operator who wants to issue credit memo.
--
-- 	Return      : 	0  successful
--		    : 	-1 if the shipper is closed
-- 
--	Process	    1. Check if the shipper is not closed yet 
--			2. Check if there are rows that need to be deleted from the shipper detail
--			3. Get the shipper and invoice number from parameters table
--			4. Otherwise, just update the shipper and let the sync take care of invoice
--			5. set a value -1 to invoice number in the else portion 
--			
--------------------------------------------------------------------------------
begin -- (1A)

        declare @status      varchar (1),
		@result	     integer 

--	1. check if the shipper is not closed yet 
	select @status = status
	from shipper 
	where id = @rma

	if @status = 'C' 
		return  -1 

--	2. check if there are rows that need to be deleted from the rma shipper detail
	delete shipper_detail
	where  ( qty_packed = 0 and shipper = @rma )

--      3. Get the shipper and invoice number from parameters table if sync invoice shipping is turned off
	if exists ( select 1 from admin where isnull(db_invoice_sync,'N') = 'N' )
	begin
	       	select  @invoice = next_invoice
	        from    parameters 
	
	        begin transaction
	
	               	update shipper
	       	        set   status = 'C',
	                      date_shipped = getdate(),
	               	      time_shipped = getdate(),
	       	              operator = @operator,
	                      invoice_number = @invoice,
	               	      invoice_printed = 'N'     
	       	        where id = @rma
	         
	       	        update parameters 
	                set next_invoice = @invoice + 1
	
	        commit transaction
	end
--		4. Otherwise, just update the shipper and let the sync take care of invoice
	else
	begin
	
	        begin transaction
	
	               	update shipper
	       	        set   status = 'C',
	                      date_shipped = getdate(),
	               	      time_shipped = getdate(),
	       	              operator = @operator,
	               	      invoice_printed = 'N',
	               	      invoice_number = -1
	       	        where id = @rma
	         
	        commit transaction
	end
	
        return 0 

end -- (1A)
go

print'
-------------------------------
-- procedure:	msp_build_costs
-------------------------------
'
if exists (select 1 from dbo.sysobjects where name = 'msp_build_costs')
	drop procedure msp_build_costs
GO

create procedure msp_build_costs as
begin

  declare @part_number varchar(25)  

  create table #part_list(
    part varchar(25) not null)

  insert #part_list(part)
  select part.part
    from part
   where part.class in('M','C','P')

  update part_standard
     set cost_cum=0,
         material_cum=0,
         burden_cum=0,
         other_cum=0,
         labor_cum=0,
         flag=0

  set rowcount 1

  select @part_number = part
    from #part_list

  while @@rowcount > 0
    begin
      set rowcount 0

      execute msp_calc_costs @part_number

      set rowcount 1

      delete from #part_list
       where part = @part_number

      select @part_number = part
        from #part_list

    end

  set rowcount 0

end
return
GO



print'
------------------------------------
-- procedure:	msp_build_grid_popup
------------------------------------
'
if exists (select * from sysobjects where id = object_id('msp_build_grid_popup'))
	drop procedure msp_build_grid_popup
GO
create procedure msp_build_grid_popup (@part varchar(25),@start_dt datetime,@type char(1))
as
begin -- (1b)
	declare	@onhand numeric(20,6),
		@onhand_rem numeric(20,6),
		@min_on_order numeric(20,6),
		@lead_time numeric(6,2),
		@receiving_um varchar(10),
		@parts_per_hour numeric(20,6),
		@qty_required numeric(20,6),
		@work_hours integer,
		@parts_per_day numeric(20,6),
		@po1 numeric(20,6),
		@po2 numeric(20,6),
		@po3 numeric(20,6),
		@po4 numeric(20,6),
		@po5 numeric(20,6),
		@po6 numeric(20,6),
		@po7 numeric(20,6),
		@po8 numeric(20,6),
		@po_past numeric(20,6),
		@po_future numeric(20,6),
		@asgnd_past numeric(20,6),
		@asgnd1 numeric(20,6),
		@asgnd2 numeric(20,6),
		@asgnd3 numeric(20,6),
		@asgnd4 numeric(20,6),
		@asgnd5 numeric(20,6),
		@asgnd6 numeric(20,6),
		@asgnd7 numeric(20,6),
		@asgnd8 numeric(20,6),
		@asgnd_future numeric(20,6),
		@demand_past numeric(20,6),
		@demand1 numeric(20,6),
		@demand2 numeric(20,6),
		@demand3 numeric(20,6),
		@demand4 numeric(20,6),
		@demand5 numeric(20,6),
		@demand6 numeric(20,6),
		@demand7 numeric(20,6),
		@demand8 numeric(20,6),
		@demand_future numeric(20,6),
		@net_sh_past numeric(20,6),
		@net_sh_1 numeric(20,6),
		@net_sh_2 numeric(20,6),
		@net_sh_3 numeric(20,6),
		@net_sh_4 numeric(20,6),
		@net_sh_5 numeric(20,6),
		@net_sh_6 numeric(20,6),
		@net_sh_7 numeric(20,6),
		@net_sh_8 numeric(20,6),
		@net_sh_future numeric(20,6),
		@net_req_past numeric(20,6),
		@net_req_1 numeric(20,6),
		@net_req_2 numeric(20,6),
		@net_req_3 numeric(20,6),
		@net_req_4 numeric(20,6),
		@net_req_5 numeric(20,6),
		@net_req_6 numeric(20,6),
		@net_req_7 numeric(20,6),
		@net_req_8 numeric(20,6),
		@net_req_future numeric(20,6),
		@inv_bal_past numeric(20,6),
		@inv_bal_1 numeric(20,6),
		@inv_bal_2 numeric(20,6),
		@inv_bal_3 numeric(20,6),
		@inv_bal_4 numeric(20,6),
		@inv_bal_5 numeric(20,6),
		@inv_bal_6 numeric(20,6),
		@inv_bal_7 numeric(20,6),
		@inv_bal_8 numeric(20,6),
		@inv_bal_future numeric(20,6),
		@standard_pack numeric(20,6),
		@sug_rel_past numeric(20,6),
		@sug_rel_1 numeric(20,6),
		@sug_rel_2 numeric(20,6),
		@sug_rel_3 numeric(20,6),
		@sug_rel_4 numeric(20,6),
		@sug_rel_5 numeric(20,6),
		@sug_rel_6 numeric(20,6),
		@sug_rel_7 numeric(20,6),
		@sug_rel_8 numeric(20,6),
		@sug_rel_future numeric(20,6),
		@name varchar(50)
	/* select onhand quantity for that part.*/
	--select @onhand=SUM(isnull(quantity,0))
	--  from object
	--  where(part=@part and status='A')
	select	@onhand=isnull(on_hand,0)
	from	part_online
	where	(part=@part)
	select	@onhand=(isnull(@onhand,0))
	select	@onhand_rem=@onhand
	/* select name */
	select	@name=name
	from	part
	where	part=@part
	--  if @type = 'P'
	--   begin -- (2b)
	/* select standard_pack from part_inventory */
	select	@standard_pack=isnull(standard_pack,1)
	from	part_inventory
	where	part=@part
	/* select info from part_vendor */
	select	@min_on_order=min_on_order,
		@lead_time=lead_time,
		@receiving_um=receiving_um
	from	part_vendor
	where	part=@part
	-- verify values in variables
	select	@min_on_order = isnull( @min_on_order, 1 ),
		@receiving_um = isnull( @receiving_um, 'EA')
	/*select po_detail qty for this part..*/
	select	@po_past=isnull(sum(case when po_detail.date_due<@start_dt then quantity else 0 end),0),
		@po1=isnull(sum(case when po_detail.date_due>=@start_dt               and po_detail.date_due<DateAdd(dd,1,@start_dt) then quantity else 0 end),0),
		@po2=isnull(sum(case when po_detail.date_due>=DateAdd(dd,1,@start_dt) and po_detail.date_due<DateAdd(dd,2,@start_dt) then quantity else 0 end),0),
		@po3=isnull(sum(case when po_detail.date_due>=DateAdd(dd,2,@start_dt) and po_detail.date_due<DateAdd(dd,3,@start_dt) then quantity else 0 end),0),
		@po4=isnull(sum(case when po_detail.date_due>=DateAdd(dd,3,@start_dt) and po_detail.date_due<DateAdd(dd,4,@start_dt) then quantity else 0 end),0),
		@po5=isnull(sum(case when po_detail.date_due>=DateAdd(dd,4,@start_dt) and po_detail.date_due<DateAdd(dd,5,@start_dt) then quantity else 0 end),0),
		@po6=isnull(sum(case when po_detail.date_due>=DateAdd(dd,1,@start_dt) and po_detail.date_due<DateAdd(dd,7,@start_dt) then quantity else 0 end),0),
		@po7=isnull(sum(case when po_detail.date_due>=DateAdd(dd,7,@start_dt) and po_detail.date_due<DateAdd(dd,14,@start_dt) then quantity else 0 end),0),
		@po8=isnull(sum(case when po_detail.date_due>=DateAdd(dd,14,@start_dt) and po_detail.date_due<DateAdd(dd,21,@start_dt) then quantity else 0 end),0),
		@po_future=isnull(sum(case when po_detail.date_due>DateAdd(dd,21,@start_dt) then quantity else 0 end),0)
	from	po_detail
	where	part_number=@part and (deleted<>'Y' or deleted is null)
	--   end -- (2e)
	/*select demand quantities for the respective buckets..*/
	select	@demand_past=isnull(sum(case when due<@start_dt then qnty else 0 end),0),
		@demand1=isnull(sum(case when due>=@start_dt               and due<DateAdd(dd,1,@start_dt) then qnty else 0 end),0),
		@demand2=isnull(sum(case when due>=DateAdd(dd,1,@start_dt) and due<DateAdd(dd,2,@start_dt) then qnty else 0 end),0),
		@demand3=isnull(sum(case when due>=DateAdd(dd,2,@start_dt) and due<DateAdd(dd,3,@start_dt) then qnty else 0 end),0),
		@demand4=isnull(sum(case when due>=DateAdd(dd,3,@start_dt) and due<DateAdd(dd,4,@start_dt) then qnty else 0 end),0),
		@demand5=isnull(sum(case when due>=DateAdd(dd,4,@start_dt) and due<DateAdd(dd,5,@start_dt) then qnty else 0 end),0),
		@demand6=isnull(sum(case when due>=DateAdd(dd,1,@start_dt) and due<DateAdd(dd,7,@start_dt) then qnty else 0 end),0),
		@demand7=isnull(sum(case when due>=DateAdd(dd,7,@start_dt) and due<DateAdd(dd,14,@start_dt) then qnty else 0 end),0),
		@demand8=isnull(sum(case when due>=DateAdd(dd,14,@start_dt) and due<DateAdd(dd,21,@start_dt) then qnty else 0 end),0),
		@demand_future=isnull(sum(case when due>=DateAdd(dd,21,@start_dt) then qnty else 0 end),0)
	from	master_prod_sched
	where	part=@part and type=@type
	--group by master_prod_sched.due
	/*  get hard queue qty from work order table*/
	if @type='P'
		select	@qty_Required=sum(qty_required),
			@parts_per_hour=sum(parts_per_hour)
		from	workorder_detail
		where	part=any(select parent_part from bill_of_material_ec where part=@part)
	else
		select	@qty_Required=sum(qty_required),
			@parts_per_hour=max(parts_per_hour)
		from	workorder_Detail
		where	part=@part
	select	@work_hours=workhours_in_day
	from	parameters
	/*calculate parts manufactured per day*/
	select	@parts_per_day=isnull(@parts_per_hour,0)*isnull(@work_hours,0),
		@asgnd_past=0
	if @demand_past>0
		if @parts_per_day>=@qty_required
			select @asgnd_past=isnull((case when @qty_required>=@parts_per_day then @parts_per_day else @qty_required end),0)
		else
			select @asgnd_past=isnull(@qty_required,0)
	else
		select @asgnd_past=0
	if @demand1>0
		select @asgnd1=isnull((case when(@qty_required-@asgnd_past)>@parts_per_day then @parts_per_day else(@qty_required-@asgnd_past) end),0)
	else
		select @asgnd1=0
		--if	@parts_per_day>=@qty_required
		--	select @asgnd1=isnull((case when @qty_required>=@parts_per_day then @parts_per_day else @qty_required end),0)
		--else
		--	select @asgnd1=isnull(@qty_required,0)
		--   else
		--     select @asgnd1=0
	if	@demand2>0
		select @asgnd2=isnull((case when(@qty_required-@asgnd1)>@parts_per_day then @parts_per_day else(@qty_required-@asgnd1) end),0)
	else
		select @asgnd2=0
	if	@demand3>0
		select @asgnd3=isnull((case when(@qty_required-@asgnd2)>@parts_per_day then @parts_per_day else(@qty_required-@asgnd2) end),0)
	else
		select @asgnd3=0
	if @demand4>0
		select @asgnd4=isnull((case when(@qty_required-@asgnd3)>@parts_per_day then @parts_per_day else(@qty_required-@asgnd3) end),0)
	else
		select @asgnd4=0
	if @demand5>0
		select @asgnd5=isnull((case when(@qty_required-@asgnd4)>@parts_per_day then @parts_per_day else(@qty_required-@asgnd4) end),0)
	else
		select @asgnd5=0
	if @demand6>0
		select @asgnd6=isnull((case when(@qty_required-@asgnd5)>@parts_per_day then @parts_per_day else(@qty_required-@asgnd5) end),0)
	else
		select @asgnd6=0
	if @demand7>0
		select @asgnd7=isnull((case when(@qty_required-@asgnd6)>@parts_per_day then @parts_per_day else(@qty_required-@asgnd6) end),0)
	else
		select @asgnd7=0
	if @demand8>0
		select @asgnd8=isnull((case when(@qty_required-@asgnd7)>@parts_per_day then @parts_per_day else(@qty_required-@asgnd7) end),0)
	else
		select @asgnd8=0
	if @demand_future>0
		select @asgnd_future=isnull((case when(@qty_required-@asgnd8)>@parts_per_day then @parts_per_day else(@qty_required-@asgnd8) end),0)
	else
		select @asgnd_future=0
	/* compute net soft hard queue requirment */
	
	select	@net_sh_past=@demand_past-@asgnd_past,
		@net_sh_1=@demand1-@asgnd1,
		@net_sh_2=@demand2-@asgnd2,
		@net_sh_3=@demand3-@asgnd3,
		@net_sh_4=@demand4-@asgnd4,
		@net_sh_5=@demand5-@asgnd5,
		@net_sh_6=@demand6-@asgnd6,
		@net_sh_7=@demand7-@asgnd7,
		@net_sh_8=@demand8-@asgnd8,
		@net_sh_future=@demand_future-@asgnd_future
	/*compute the net requirement..*/
	if @net_sh_past>0
		if @onhand_rem<=@net_sh_past
			select	@net_req_past=(@net_sh_past-@onhand_rem),
				@onhand_rem=0,
				@inv_bal_past=0
		else
			select	@net_req_past=0,
				@onhand_rem=@onhand_rem-@net_sh_past,
				@inv_bal_past=@onhand_rem
	else
		select	@net_req_past=0,
			@inv_bal_past=@onhand_rem
	if @net_sh_1>0
		if @onhand_rem<=@net_sh_1
			select	@net_req_1=(@net_sh_1-@onhand_rem),
				@onhand_rem=0,
				@inv_bal_1=0
		else
			select	@net_req_1=0,
				@onhand_rem=@onhand_rem-@net_sh_1,
				@inv_bal_1=@onhand_rem
	else
		select	@net_req_1=0,
			@inv_bal_1=@onhand_rem
	if @net_sh_2>0
		if @onhand_rem<=@net_sh_2
		        select	@net_req_2=(@net_sh_2-@onhand_rem),
				@onhand_rem=0,
				@inv_bal_2=0
		else
			select	@net_req_2=0,
				@onhand_rem=@onhand_rem-@net_sh_2,
				@inv_bal_2=@onhand_rem
	else
		select	@net_req_2=0,
			@inv_bal_2=@onhand_rem
	if @net_sh_3>0
		if @onhand_rem<=@net_sh_3
		        select	@net_req_3=(@net_sh_3-@onhand_rem),
				@onhand_rem=0,
				@inv_bal_3=0
		else
			select	@net_req_3=0,
				@onhand_rem=@onhand_rem-@net_sh_3,
				@inv_bal_3=@onhand_rem
	else
		select	@net_req_3=0,
			@inv_bal_3=@onhand_rem
	if @net_sh_4>0
		if @onhand_rem<=@net_sh_4
			select	@net_req_4=(@net_sh_4-@onhand_rem),
				@onhand_rem=0,
				@inv_bal_4=0
		else
			select	@net_req_4=0,
				@onhand_rem=@onhand_rem-@net_sh_4,
				@inv_bal_4=@onhand_rem
	else
		select	@net_req_4=0,
			@inv_bal_4=@onhand_rem
	if @net_sh_5>0
		if @onhand_rem<=@net_sh_5
			select	@net_req_5=(@net_sh_5-@onhand_rem),
				@onhand_rem=0,
				@inv_bal_5=0
		else
			select	@net_req_5=0,
				@onhand_rem=@onhand_rem-@net_sh_5,
				@inv_bal_5=@onhand_rem
	else
		select	@net_req_5=0,
			@inv_bal_5=@onhand_rem
	/* reset the onhand rem to distribute it to the weekly buckets..*/
	--   select @onhand_rem=@onhand
	/*weekly buckets*/
	if @net_sh_6>0
		if @onhand_rem<=@net_sh_6
			select	@net_req_6=(@net_sh_6-@onhand_rem),
				@onhand_rem=0,
				@inv_bal_6=0
		else
			select	@net_req_6=0,
				@onhand_rem=@onhand_rem-@net_sh_6,
				@inv_bal_6=@onhand_rem
	else
		select	@net_req_6=0,
			@inv_bal_6=@onhand_rem
	if @net_sh_7>0
		if @onhand_rem<=@net_sh_7
			select	@net_req_7=(@net_sh_7-@onhand_rem),
				@onhand_rem=0,
				@inv_bal_7=0
		else
			select	@net_req_7=0,
				@onhand_rem=@onhand_rem-@net_sh_7,
				@inv_bal_7=@onhand_rem
	else
		select	@net_req_7=0,
			@inv_bal_7=@onhand_rem
	if @net_sh_8>0
		if @onhand_rem<=@net_sh_8
			select	@net_req_8=(@net_sh_8-@onhand_rem),
				@onhand_rem=0,
				@inv_bal_8=0
		else
			select	@net_req_8=0,
				@onhand_rem=@onhand_rem-@net_sh_8,
				@inv_bal_8=@onhand_rem
	else
		select	@net_req_8=0,
			@inv_bal_8=@onhand_rem
	if @net_sh_future>0
		if @onhand_rem<=@net_sh_future
			select	@net_req_future=(@net_sh_future-@onhand_rem),
				@onhand_rem=0,
				@inv_bal_future=0
		else
			select	@net_req_future=0,
				@onhand_rem=@onhand_rem-@net_sh_future,
				@inv_bal_future=@onhand_rem
	else
		select	@net_req_future=0,
			@inv_bal_future=@onhand_rem
	/* compute the suggested release quanitites */
	if @net_req_past>0
		if @net_req_past>@min_on_order
			select @sug_rel_past=((@net_req_past/@min_on_order)+1)*@min_on_order
		else
			select @sug_rel_past=@min_on_order
	else
		select @sug_rel_past=0
	if @net_req_1>0
		if @net_req_1>@min_on_order
			select @sug_rel_1=((@net_req_1/@min_on_order)+1)*@min_on_order
		else
			select @sug_rel_1=@min_on_order
	else
		select @sug_rel_1=0
	if @net_req_2>0
		if @net_req_2>@min_on_order
			select @sug_rel_2=((@net_req_2/@min_on_order)+1)*@min_on_order
		else
			select @sug_rel_2=@min_on_order
	else
		select @sug_rel_2=0
	if @net_req_3>0
		if @net_req_3>@min_on_order
			select @sug_rel_3=((@net_req_3/@min_on_order)+1)*@min_on_order
		else
			select @sug_rel_3=@min_on_order
	else
		select @sug_rel_3=0
	if @net_req_4>0
		if @net_req_4>@min_on_order
			select @sug_rel_4=((@net_req_4/@min_on_order)+1)*@min_on_order
		else
			select @sug_rel_4=@min_on_order
	else
		select @sug_rel_4=0
	if @net_req_5>0
		if @net_req_5>@min_on_order
			select @sug_rel_5=((@net_req_5/@min_on_order)+1)*@min_on_order
		else
			select @sug_rel_5=@min_on_order
	else	
		select @sug_rel_5=0
	if @net_req_6>0
		if @net_req_6>@min_on_order
			select @sug_rel_6=((@net_req_6/@min_on_order)+1)*@min_on_order
		else
			select @sug_rel_6=@min_on_order
	else
		select @sug_rel_6=0
	if @net_req_7>0
		if @net_req_7>@min_on_order
			select @sug_rel_7=((@net_req_7/@min_on_order)+1)*@min_on_order
		else
			select @sug_rel_7=@min_on_order
	else
		select @sug_rel_7=0
	if @net_req_8>0
		if @net_req_8>@min_on_order
			select @sug_rel_8=((@net_req_8/@min_on_order)+1)*@min_on_order
		else
			select @sug_rel_8=@min_on_order
	else
		select @sug_rel_8=0
	if @net_req_future>0
		if @net_req_future>@min_on_order
			select @sug_rel_future=((@net_req_future/@min_on_order)+1)*@min_on_order
		else
			select @sug_rel_future=@min_on_order
	else
		select @sug_rel_future=0
	/* select all the result set values */
	select	part=@part,
		name=@name,
		onhand=@onhand,
		past_date='Past Due',
		date1=@start_dt,
		date2=(DateAdd(dd,1,@start_dt)),
		date3=(DateAdd(dd,2,@start_dt)),
		date4=(DateAdd(dd,3,@start_dt)),
		date5=(DateAdd(dd,4,@start_dt)),
		date6=(DateAdd(dd,7,@start_dt)),
		date7=(DateAdd(dd,14,@start_dt)),
		date8=(DateAdd(dd,21,@start_dt)),
		future_date='Future',
		demand_past=@demand_past,
		demand1=@demand1,
		demand2=@demand2,
		demand3=@demand3,
		demand4=@demand4,
		demand5=@demand5,
		demand6=@demand6,
		demand7=@demand7,
		demand8=@demand8,
		demand_future=@demand_future,
		asgnd_past=@asgnd_past,
		asgnd1=@asgnd1,
		asgnd2=@asgnd2,
		asgnd3=@asgnd3,
		asgnd4=@asgnd4,
		asgnd5=@asgnd5,
		asgnd6=@asgnd6,
		asgnd7=@asgnd7,
		asgnd8=@asgnd8,
		asgnd_future=isnull(@asgnd_future,0),
		net_sh_past=@demand_past - isnull(@asgnd_past,0),
		net_sh_1=@demand1 - @asgnd1,
		net_sh_2=@demand2 - @asgnd2,
		net_sh_3=@demand3 - @asgnd3,
		net_sh_4=@demand4 - @asgnd4,
		net_sh_5=@demand5 - @asgnd5,
		net_sh_6=@demand6 - @asgnd6,
		net_sh_7=@demand7 - @asgnd7,
		net_sh_8=@demand8 - @asgnd8,
		net_sh_future=@demand_future - @asgnd_future,
		po_past=@po_past,
		po1=@po1,
		po2=@po2,
		po3=@po3,
		po4=@po4,
		po5=@po5,
		po6=@po6,
		po7=@po7,
		po8=@po8,
		po_future=@po_future,
		net_req_past=@net_req_past,
		net_req1=@net_req_1,
		net_req2=@net_req_2,
		net_req3=@net_req_3,
		net_req4=@net_req_4,
		net_req5=@net_req_5,
		net_req6=@net_req_6,
		net_req7=@net_req_7,
		net_req8=@net_req_8,
		net_reqfuture=@net_req_future,
		inv_bal_past=@inv_bal_past,
		inv_bal1=@inv_bal_1,
		inv_bal2=@inv_bal_2,
		inv_bal3=@inv_bal_3,
		inv_bal4=@inv_bal_4,
		inv_bal5=@inv_bal_5,
		inv_bal6=@inv_bal_6,
		inv_bal7=@inv_bal_7,
		inv_bal8=@inv_bal_8,
		inv_bal_future=@inv_bal_future,
		sug_rel_past=@sug_rel_past,
		sug_rel_1=@sug_rel_1,
		sug_rel_2=@sug_rel_2,
		sug_rel_3=@sug_rel_3,
		sug_rel_4=@sug_rel_4,
		sug_rel_5=@sug_rel_5,
		sug_rel_6=@sug_rel_6,
		sug_rel_7=@sug_rel_7,
		sug_rel_8=@sug_rel_8,
		sug_rel_future=@sug_rel_future,
		proj_bal_past=@sug_rel_past-@net_req_past,
		proj_bal_1=@sug_rel_1-@net_req_1,
		proj_bal_2=@sug_rel_2-@net_req_2,
		proj_bal_3=@sug_rel_3-@net_req_3,
		proj_bal_4=@sug_rel_4-@net_req_4,
		proj_bal_5=@sug_rel_5-@net_req_5,
		proj_bal_6=@sug_rel_6-@net_req_6,
		proj_bal_7=@sug_rel_7-@net_req_7,
		proj_bal_8=@sug_rel_8-@net_req_8,
		proj_bal_future=@sug_rel_future-@net_req_future,
		standard_pack=isnull(@standard_pack,1),
		min_on_order=@min_on_order,
		lead_time=isnull(@lead_time,0),
		receiving_um=@receiving_um
end -- (1e)
GO

print'
------------------------------------
-- procedure:	msp_build_label_list
------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_build_label_list') )
        drop procedure msp_build_label_list
GO

CREATE PROCEDURE msp_build_label_list
AS
        SELECT  name,
	      null,
	      object_name
          FROM  report_library
         WHERE  report = 'label'
         ORDER BY name     
GO



print'
--------------------------------
-- procedure:	msp_explode_part
--------------------------------
'
create table #bom_info(
		parent_part                    varchar(25) null,
		part                           varchar(25),
		quantity                       numeric(20,6),
		extended_quantity              numeric(20,6),
		machine                        varchar(10),
		process_id                     varchar(25) null,
		setup_time                     numeric(20,6),
		class                          char(1),
		due_datetime		       datetime null,
		dropdead_datetime	       datetime null,
		runtime                        numeric(20,6),
		group_technology               varchar(25) null,
		week_no                        int,
		new_row_id		       int,
		bom_level			       int)
go

if exists (select * from dbo.sysobjects where id = object_id('msp_explode_part'))
	drop procedure msp_explode_part
go

create procedure msp_explode_part (@parent_part varchar(25),
				   @part varchar(25),
				   @parent_quantity numeric(20,6),
				   @component_due datetime,
				   @bom_level int) as
begin
declare		@part_number                    varchar(25),
		@quantity			numeric(20,6),
		@bom_quantity			numeric(20,6),
		@extended_quantity		numeric(20,6),
		@process_id			varchar(25),
		@dropdead_datetime		datetime,
		@machine			varchar(10),
		@setup_time			numeric(20,6),
		@runtime			numeric(20,6),
		@week_no			int,
		@no_weeks			int,
		@last_day			int,
		@week_cnt			int,
		@day_cnt 			int,
		@sunday				char(1),
		@monday				char(1),
		@tuesday			char(1),
		@wednesday			char(1),
		@thursday			char(1),
		@friday				char(1),
		@saturday			char(1),
		@work_hours_in_day		int,
		@include_set_up			char(1),
		@new_row_id			int,
		@bom_type			char(1)

	select	@sunday = sunday,				/* get user parameters */
		@monday = monday,
		@tuesday = tuesday,
		@wednesday = wednesday,
		@thursday = thursday,
		@friday = friday,
		@saturday = saturday,
		@work_hours_in_day = workhours_in_day,
		@include_set_up = include_setuptime
	  from	parameters

	create	table #components
		(component_part			varchar(25),
		 quantity			numeric(20,6))

	select @bom_level = @bom_level + 1

	select	@bom_quantity = bom.std_qty,			/* BOM Quantity */
		@bom_type     = bom.type
	  from	bill_of_material bom
	 where	@part = bom.part
	   and  @parent_part = bom.parent_part
								/* BOM Extended Quantity */
	if @bom_type = 'P' or @bom_type = 'T' 
		select  @extended_quantity = isnull(@bom_quantity,1)	
	else
		select	@extended_quantity = isnull(@bom_quantity,1) * @parent_quantity
	
	select  @machine = pm.machine				/* Machine */
	  from	part_machine pm
	 where	@part = pm.part
	   and	pm.sequence = 1 

	select	@process_id = pmfg.process_id,			/* Process Id,Setup,Runtime */
		@setup_time = isnull(pmfg.setup_time,0),	/* Drop Dead Date Time */
		@runtime = isnull(@extended_quantity,@parent_quantity)
			* (1 / pmfg.parts_per_hour),
		@dropdead_datetime = dateadd(hh,isnull(-1.0 * @extended_quantity 
			* (1.0 / pmfg.parts_per_hour * 24 / @work_hours_in_day),0.0),
			@component_due)
	  from	part_mfg pmfg
	 where	@part = pmfg.part


       select @dropdead_Datetime = isnull(@dropdead_datetime, @component_due)

	if @include_set_up = 'Y'				/* Include Setup? */
		select	@runtime = @runtime + isnull(@setup_time,0),
			@dropdead_datetime = dateadd(hh,-1.0 * 			isnull(@setup_time,0),@dropdead_datetime)

	select	@no_weeks = datediff(dy,@dropdead_datetime,@component_due) / 7 + 1,
		@last_day = datepart(dw,@dropdead_datetime)

	select @week_cnt = @no_weeks				/* adjust Drop Dead Date Time */
								/* for non-working days */
	while @week_cnt > 0
	begin
		if @week_cnt = 1
			select @day_cnt = datepart(dw,@component_due)
		else
			select @day_cnt = 7
		while @day_cnt > 0
		begin
			if @day_cnt = 1 and @sunday = 'Y'
				select @dropdead_datetime = dateadd(dy,-1,@dropdead_datetime)
			if @day_cnt = 2 and @monday = 'Y'
				select @dropdead_datetime = dateadd(dy,-1,@dropdead_datetime)
			if @day_cnt = 3 and @tuesday = 'Y'
				select @dropdead_datetime = dateadd(dy,-1,@dropdead_datetime)
			if @day_cnt = 4 and @wednesday = 'Y'
				select @dropdead_datetime = dateadd(dy,-1,@dropdead_datetime)
			if @day_cnt = 5 and @thursday = 'Y'
				select @dropdead_datetime = dateadd(dy,-1,@dropdead_datetime)
			if @day_cnt = 6 and @friday = 'Y'
				select @dropdead_datetime = dateadd(dy,-1,@dropdead_datetime)
			if @day_cnt = 7 and @saturday = 'Y'
				select @dropdead_datetime = dateadd(dy,-1,@dropdead_datetime)
			if @week_cnt = 1 and @day_cnt = @last_day
				break
			select @last_day = datepart(dw,@dropdead_datetime)
			select @day_cnt = @day_cnt - 1
		end
		select @week_cnt = @week_cnt - 1
	end
								/* cal. weeks since fiscal year */
	select	@week_no = datediff(wk,parm.fiscal_year_begin,@component_due)
	  from	parameters parm

	select	@new_row_id = count(new_row_id) + 1		/* unique row id for mps rec. */
	  from	#bom_info

	insert	#bom_info(					/* load work table w/ BOM data */
		parent_part,					/* for parent part */
		part,
		quantity,
		extended_quantity,
		machine,
		process_id,
		setup_time,
		class,
		due_datetime,
		dropdead_datetime,
		runtime,
		group_technology,
		week_no,
		new_row_id,
		bom_level)
	select	@parent_part,
		@part,
		isnull(@bom_quantity,1),
		isnull(@extended_quantity,@parent_quantity),
		isnull(@machine,'NONE'),
		isnull(@process_id,'NONE'),
		isnull(@setup_time,0),
		p.class,
		@component_due,
		isnull(@dropdead_datetime,@component_due),
		isnull(@runtime,0),
		p.group_technology,
		@week_no,
		@new_row_id,
		@bom_level
	  from	part p
	 where	@part = p.part

	insert	#components(component_part, quantity)		/* get components for part */
	select	part, quantity
	  from	bill_of_material
	 where	parent_part = @part

	set rowcount 1						/* setup poor man's cursor */

	select	@part_number = component_part,			/* get a component */
		@quantity = quantity
	  from	#components
      order by	component_part

	while @@rowcount > 0					/* loop for each component */
	begin

		set rowcount 0
								/* call myself for each component */
		execute msp_explode_part @part, @part_number, @extended_quantity, @dropdead_datetime, @bom_level

		set rowcount 1

		delete
		  from	#components
		 where  #components.component_part = @part_number

		select	@part_number = component_part,		/* get next component */
			@quantity = quantity
		  from	#components
	      order by	component_part

	end

	set rowcount 0

	drop table #components					/* clean-up */

return
end
go

drop table #bom_info
go

print'
-----------------------------
-- procedure:	msp_build_mps
-----------------------------
'
create table #order_detail(
        part_number                    varchar(25),
        std_qty                        numeric(20,6),
        due_date                       datetime,
        order_no                       numeric(8,0),
        row_id                         int,
        ship_type                      char(1) null,
        plant                          varchar(10) null)
go
create table #bom_info(
        parent_part                    varchar(25) null,
        part                           varchar(25),
        quantity                       numeric(20,6),
        extended_quantity              numeric(20,6),
        machine                        varchar(10),
        process_id                     varchar(25) null,
        setup_time                     numeric(20,6),
        class                          char(1),
        due_datetime                   datetime null,
        dropdead_datetime              datetime null,
        runtime                        numeric(20,6),
        group_technology               varchar(25) null,
        week_no                        int,
        new_row_id                     int,
        bom_level                              int)
go
if exists (select * from dbo.sysobjects where id = object_id('msp_build_mps'))
        drop procedure msp_build_mps
go
create procedure msp_build_mps (@a_order_no numeric(8,0), @a_row_id int) as

declare         @part_number                    varchar(25),
                @std_qty                        numeric(20,6),
                @due_date                       datetime,
                @due                            datetime,
                @order_no                       numeric(8,0),
                @row_id                         int,
                @origin                         numeric(8,0),
                @source                         int,
                @ship_type                      char(1),
                @plant                          varchar(10),
                @qnty                           numeric(20,6),
                @qty_left                       numeric(20,6),
                @assign_qty                     numeric(20,6),
                @assign_qty_wo                  numeric(20,6),
                @id                             numeric(12,0)

        create table #mps_temp (
                part                            varchar(25),
                plant                           varchar(10) null)

        create table #mps_assign (
                part                            varchar(25),
                due                             datetime,
                source                          int,
                origin                          numeric(8,0),
                qnty                            numeric(20,6),
                id                              numeric(12,0))

        set rowcount 1                                          /* setup poor man's cursor */

        select  @part_number = part_number,                     /* get order detail record */
                @std_qty = std_qty,
                @due_date = due_date,
                @order_no = order_no,
                @row_id = row_id,
                @ship_type = ship_type,
                @plant = plant
          from  #order_detail
      order by  part_number

        while @@rowcount > 0                                    /* loop for each order detail */
        begin

                set rowcount 0

                delete from #bom_info
                                                                /* explode the part */
                execute msp_explode_part null, @part_number, @std_qty, @due_date, 0

                begin transaction                               /* begin transaction */

                        delete  from master_prod_sched          /* delete mps for order detail */
                         where  master_prod_sched.origin = @order_no
                           and  master_prod_sched.source = @row_id

                        insert into master_prod_sched           /* create new mps record */
                          (type,   
                           part,   
                           due,   
                           qnty,   
                           source,   
                           source2,   
                           origin,   
                           rel_date,   
                           tool,   
                           workcenter,   
                           machine,   
                           run_time,   
                           run_day,  
                           dead_start,   
                           material,   
                           job,   
                           material_qnty,   
                           setup,   
                           location,   
                           field1,   
                           field2,   
                           field3,   
                           field4,   
                           field5,   
                           status,   
                           sched_method,   
                           qty_completed,   
                           process,   
                           tool_num,   
                           workorder,   
                           qty_assigned,   
                           due_time,   
                           start_time,   
                           id,   
                           parent_id,   
                           begin_date,   
                           begin_time,   
                           end_date,   
                           end_time,   
                           po_number,   
                           po_row_id,   
                           week_no,
                           plant,
                           ship_type)  
                        select
                           class,   
                           part,   
                           due_datetime,   
                           extended_quantity,   
                           @row_id,   
                           null,   
                           @order_no,   
                           null,   
                           null,   
                           null,   
                           machine,   
                           runtime,   
                           null,   
                           dropdead_datetime,   
                           null,   
                           '',   
                           null,   
                           setup_time,   
                           null,   
                           null,               /*changed from group_technology to null as column width was not same and causing problem to run cop*/  
                           null,   
                           null,   
                           null,   
                           null,   
                           'S',   
                           null,   
                           null,   
                           process_id,   
                           null,   
                           null,   
                           0,   
                           due_datetime,   
                           dropdead_datetime,   
                           new_row_id,   
                           0,   
                           null,   
                           null,   
                           null,   
                           null,   
                           null,   
                           null,   
                           week_no,
                           @plant,
                           @ship_type
                        from #bom_info
select part, bom_level from #bom_info
                        update  order_detail                    /* set order detail COP flag */
                           set  flag = 0  
                         where  order_detail.order_no = @order_no  
                           and  order_detail.row_id = @row_id

                commit transaction                              /* commit transaction */

                set rowcount 1

                delete
                  from  #order_detail
                 where  #order_detail.order_no = @order_no
                   and  #order_detail.row_id = @row_id

                select  @part_number = part_number,             /* get next order detail */
                        @std_qty = std_qty,
                        @due_date = due_date,
                        @order_no = order_no,
                        @row_id = row_id,
                        @ship_type = ship_type,
                        @plant = plant
                  from  #order_detail
              order by  part_number

        end

        set rowcount 0                                          /* assign mps quantities */

        begin transaction                                       /* begin transaction */
                if exists (select 1 where @a_order_no is null) 
                        insert  #mps_temp (part, plant)         /* get distinct mps plant,parts */
                        select  distinct part, plant
                          from  master_prod_sched
                      order by  plant, part
                else
                        insert  #mps_temp (part, plant)         /* get distinct mps plant,parts */
                        select  distinct part, @plant
                          from  #bom_info
                      order by  part

                set rowcount 1                                  /* setup poor man's cursor */

                select  @part_number = part,                    /* get distinct mps plant,part */
                        @plant = plant
                  from  #mps_temp
              order by  plant, part

                while @@rowcount > 0                            /* loop for each distinct plant,part */
                begin

                        set rowcount 0
                                                                /* get po and wo qty w/ null plant */
                                update  master_prod_sched       /* zero mps assigned quantities */
                                   set  qty_assigned = 0
                                 where  part = @part_number

                                select  @assign_qty = sum(pod.standard_qty)
                                  from  po_detail pod
                                 where  pod.part_number = @part_number
                                   and  pod.status <> 'C'

                                select  @assign_qty_wo = sum(wod.qty_required)
                                  from  workorder_detail wod
                                 where  wod.part = @part_number
                        
                                                                /* sum quantities */
                        select @assign_qty = isnull(@assign_qty,0) + isnull(@assign_qty_wo,0)

                        /* get mps plant,parts */
			/* modified insert statement to get id also which is a part of pk - mb */

                        insert  #mps_assign (part, due, source, origin, qnty, id)
                        select  part, due, source, origin, qnty, id
                          from  master_prod_sched
                         where  part = @part_number

                        set rowcount 1                          /* setup poor man's cursor */

			/* modified insert statement to get id also which is a part of pk - mb */
                        select  @due = due,                     /* get mps plant,part */
                                @source = source,
                                @origin = origin,
                                @qnty   = qnty,
                                @id     = id
                          from  #mps_assign
                         where  part = @part_number
	                      order by  due

                        select  @qty_left = @assign_qty
                                                                /* loop for each mps plant,part */
                        while (@@rowcount > 0) and (@qty_left > 0)
                        begin
                                set rowcount 0

                                if @qty_left > @qnty    /* assign qty from oldest to newest */
                                begin

					/* included id in where clause which is a part of pk - mb */
                                        update  master_prod_sched
                                           set  qty_assigned = @qnty
                                         where  part = @part_number
                                           and  source = @source
                                           and  origin = @origin
                                           and  due = @due
                                           and  id = @id

                                        select  @qty_left = @qty_left - @qnty
                                end
                                else
                                begin

					/* included id in where clause which is a part of pk - mb */
                                        update  master_prod_sched
                                           set  qty_assigned = @qty_left
                                         where  part = @part_number
                                           and  source = @source
                                           and  origin = @origin
                                           and  due = @due
                                           and  id = @id

                                        select  @qty_left = 0
                                end                             

                                set rowcount 1

                                delete  from #mps_assign
                                 where  part = @part_number
                                   and  source = @source
                                   and  origin = @origin
	              and  due = @due	
	              and id = @id

                                select  @due = due,             /* get next mps plant, part */
                                        @source = source,
                                        @origin = origin,
                                        @qnty = qnty,
                                        @id     = id
                                  from  #mps_assign
                                 where  part = @part_number
                              order by  due
                                
                        end

                        set rowcount 0

                        delete  from #mps_assign

                        select  @assign_qty = 0

                        set rowcount 1

                        delete  from #mps_temp
                         where  part = @part_number

                        select  @part_number = part,            /* get next distinct mps plant,part */
                                @plant = plant
                          from  #mps_temp
                      order by  plant, part

                end

        set rowcount 0

        commit transaction                                      /* commit transaction */


        drop table #mps_temp                                    /* clean-up */

        drop table #mps_assign 
return
go
drop table #order_detail
go
drop table #bom_info
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

print'
-----------------------------------
-- procedure:	msp_build_recv_grid
-----------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_build_recv_grid'))
        drop procedure msp_build_recv_grid
GO

CREATE PROCEDURE msp_build_recv_grid ( @po_number integer, @start_dt datetime )
AS

        SELECT  po_detail.part_number,
                Max ( po_detail.date_due ),   
                Max ( @start_dt )  date1 ,
                ( Sum( CASE     WHEN    date_due <  @start_dt THEN quantity ELSE 0 END ) - Sum( CASE    WHEN    date_due < @start_dt THEN received ELSE 0 END ) )qty_past_due,
                ( Sum( CASE  WHEN       date_due < DateAdd ( dd, 1, @start_dt)  AND date_due >= @start_dt THEN quantity ELSE 0  END ) - Sum( CASE  WHEN date_due < DateAdd ( dd, 1, @start_dt)  AND date_due >= @start_dt THEN received ELSE 0  END ) ) qty_date1,
                ( Sum( CASE  WHEN       date_due < DateAdd ( dd, 2, @start_dt)  AND date_due >= DateAdd ( dd, 1, @start_dt) THEN quantity ELSE 0 END ) - Sum( CASE  WHEN        date_due < DateAdd ( dd, 2, @start_dt)  AND date_due >=  DateAdd ( dd, 1, @start_dt) THEN received ELSE 0 END ) )qty_date2,
                ( Sum( CASE  WHEN       date_due < DateAdd ( dd, 3, @start_dt)  AND date_due >= DateAdd ( dd, 2, @start_dt) THEN quantity ELSE 0 END ) - Sum( CASE  WHEN        date_due < DateAdd ( dd, 3, @start_dt)  AND date_due >= DateAdd ( dd, 2, @start_dt) THEN received ELSE 0 END ) ) qty_date3,
                ( Sum( CASE  WHEN       date_due < DateAdd ( dd, 4, @start_dt)  AND date_due >= DateAdd ( dd, 3, @start_dt) THEN quantity ELSE 0 END ) - Sum( CASE  WHEN        date_due < DateAdd ( dd, 4, @start_dt)  AND date_due >= DateAdd ( dd, 3, @start_dt) THEN received ELSE 0 END ) ) qty_date4,
                ( Sum( CASE  WHEN       date_due < DateAdd ( dd, 5, @start_dt)  AND date_due >= DateAdd ( dd, 4, @start_dt) THEN quantity ELSE 0 END ) - Sum( CASE  WHEN        date_due < DateAdd ( dd, 5, @start_dt)  AND date_due >= DateAdd ( dd, 4, @start_dt) THEN received ELSE 0 END ) ) qty_date5,
                ( Sum( CASE  WHEN       date_due < DateAdd ( dd,  6, @start_dt)  AND date_due >= DateAdd ( dd, 5, @start_dt) THEN quantity ELSE 0 END ) - Sum( CASE  WHEN       date_due <  DateAdd ( dd, 6, @start_dt)  AND date_due >= DateAdd ( dd, 5, @start_dt) THEN received ELSE 0 END ) ) qty_date6,
                ( Sum( CASE  WHEN       date_due < DateAdd ( dd, 7, @start_dt)  AND date_due >= DateAdd ( dd, 6, @start_dt) THEN quantity ELSE 0 END ) - Sum( CASE  WHEN       date_due <  DateAdd ( dd, 7, @start_dt)  AND date_due >= DateAdd ( dd, 6, @start_dt) THEN received  ELSE 0  END ) )qty_date7,
                Sum( CASE       WHEN    date_due < @start_dt THEN received ELSE 0 END ) recv_past_due,
                Sum( CASE  WHEN date_due < DateAdd ( dd, 1, @start_dt)  AND date_due >= @start_dt THEN received ELSE 0  END ) recv_date1,
                Sum( CASE  WHEN date_due < DateAdd ( dd, 2, @start_dt)  AND date_due >=  DateAdd ( dd, 1, @start_dt) THEN received ELSE 0 END ) recv_date2,
                Sum( CASE  WHEN date_due < DateAdd ( dd, 3, @start_dt)  AND date_due >= DateAdd ( dd, 2, @start_dt) THEN received ELSE 0 END ) recv_date3,
                Sum( CASE  WHEN date_due < DateAdd ( dd, 4, @start_dt)  AND date_due >= DateAdd ( dd, 3, @start_dt) THEN received ELSE 0 END ) recv_date4,
                Sum( CASE  WHEN date_due < DateAdd ( dd, 5, @start_dt)  AND date_due >= DateAdd ( dd, 4, @start_dt) THEN received ELSE 0 END ) recv_date5,
                Sum( CASE  WHEN date_due <  DateAdd ( dd, 6, @start_dt)  AND date_due >= DateAdd ( dd, 5, @start_dt) THEN received ELSE 0 END ) recv_date6,
                Sum( CASE  WHEN date_due <  DateAdd ( dd, 7, @start_dt)  AND date_due >= DateAdd ( dd, 6, @start_dt) THEN received  ELSE 0  END ) recv_date7,
                Max ( po_detail.po_number),
                Max ( po_detail.release_type), 
                Max ( po_detail.release_no)
        FROM    po_detail
        WHERE   po_detail.po_number = @po_number and ( po_detail.deleted is null or po_detail.deleted <> 'Y' )
      GROUP BY part_number
GO


print'
---------------------------------------------------
-- PROCEDURE:	msp_calc_customer_matrix
---------------------------------------------------
'
if exists ( select 1 from dbo.sysobjects where id = object_id ( 'msp_calc_customer_matrix' ) )
	drop procedure msp_calc_customer_matrix
go
if exists ( select 1 from dbo.sysobjects where id = object_id ( 'msp_calc_customer_price_matrix' ) )
	drop procedure msp_calc_customer_price_matrix
go

create procedure msp_calc_customer_matrix ( 	@part varchar(25), 
														@customer varchar(10), 
														@qty_break decimal(20,6), 
														@currency_unit varchar(3) )
as
begin
	-- declare local variables
	declare	@customer_currency	varchar(3),
			@base_currency		varchar(3)

	-- get the base currency from parameters table
	select	@base_currency = base_currency
	from	parameters

	if isnull(@currency_unit,'') > ''
		update 	part_customer_price_matrix set
				price = ( part_customer_price_matrix.alternate_price * isnull(( 	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
												from	currency_conversion cc
												where	effective_date <= GetDate ( ) and
														currency_code = @currency_unit ) and
							currency_code = @currency_unit ),1) / isnull((
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
												from	currency_conversion cc
												where	effective_date <= GetDate ( ) and
														currency_code = @base_currency ) and
							currency_code = @base_currency ),1))
		from	part_customer_price_matrix,
				customer
		where	part_customer_price_matrix.customer = customer.customer and
				customer.default_currency_unit = @currency_unit

	else
	begin
		-- get customer's default currency
		select	@customer_currency = default_currency_unit
		from	customer
		where	customer = @customer
		
		if isnull(@part,'') > ''
			update 	part_customer_price_matrix set
					price = ( part_customer_price_matrix.alternate_price * isnull(( 	
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @customer_currency ) and
								currency_code = @customer_currency ),1) / isnull((
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @base_currency ) and
								currency_code = @base_currency ),1))
			from	part_customer_price_matrix
			where	part = @part and
					customer = @customer and
					qty_break = @qty_break 
		else
			update 	part_customer_price_matrix set
					price = ( part_customer_price_matrix.alternate_price * isnull(( 	
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @customer_currency ) and
								currency_code = @customer_currency ),1) / isnull((
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @base_currency ) and
								currency_code = @base_currency ),1))
			from	part_customer_price_matrix
			where	customer = @customer
	end	
end
go


print'
----------------------------------------------
-- PROCEDURE:	msp_calc_invoice_currency
----------------------------------------------
'
if exists ( select 1 from dbo.sysobjects where id = object_id ( 'msp_calc_invoice_currency' ) )
	drop procedure msp_calc_invoice_currency
go

create procedure msp_calc_invoice_currency (	@shipper integer, 
						@customer varchar(10), 
						@destination varchar(10), 
						@part varchar(25), 
						@currency varchar(3) )
as
begin

	-- declare local variables
	declare	@base_currency	varchar(3)

	-- get the base currency from parameters table
	select	@base_currency = base_currency
	from	parameters

	-- if invoice_no was sent update only that invoice
	if isnull(@shipper,0) > 0
	begin

		if 	isnull(@part,'') > ''

			update 	shipper_detail set
					price = ( alternate_price * isnull((	
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = shipper.currency_unit ) and
								currency_code = shipper.currency_unit ),1) / isnull((
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
			from	shipper
			where	shipper.id = @shipper and
				shipper_detail.part = @part and
				shipper_detail.shipper = @shipper
		else

			update 	shipper_detail set
					price = ( alternate_price * isnull((	
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
										from	currency_conversion cc
										where	effective_date <= GetDate ( ) and
											currency_code = shipper.currency_unit ) and
							currency_code = shipper.currency_unit ),1) / isnull((
										select	rate
										from	currency_conversion 
										where 	effective_date = (	select	max (effective_date)
										from	currency_conversion cc
										where	effective_date <= GetDate ( ) and
											currency_code = @base_currency ) and
							currency_code = @base_currency ),1) )
			from	shipper
			where	shipper.id = @shipper and
				shipper_detail.shipper = @shipper

	end	
	-- if customer is sent, update all invoices for that customer that haven't been printed 
	else if isnull(@customer,'') > ''
		update 	shipper_detail set
				price = ( alternate_price * isnull((	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
												from	currency_conversion cc
												where	effective_date <= GetDate ( ) and
														currency_code = shipper.currency_unit ) and
							currency_code = shipper.currency_unit ),1) / isnull((
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
		from	shipper
		where	shipper.customer = @customer and
				shipper_detail.shipper = shipper.id

	-- if destination is sent, update all invoices for that destination that haven't been printed
	else if isnull(@destination,'') > ''
		update 	shipper_detail set
				price = ( alternate_price * isnull((	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
												from	currency_conversion cc
												where	effective_date <= GetDate ( ) and
														currency_code = shipper.currency_unit ) and
							currency_code = shipper.currency_unit ),1) / isnull((
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
		from	shipper
		where	shipper.destination = @destination and
				shipper_detail.shipper = shipper.id

	-- if currency is sent, update all invoices with that currency
	else if isnull(@currency,'') > ''
		update 	shipper_detail set
				price = ( alternate_price * isnull((	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
												from	currency_conversion cc
												where	effective_date <= GetDate ( ) and
														currency_code = shipper.currency_unit ) and
							currency_code = shipper.currency_unit ),1) / isnull((
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
		from	shipper
		where	shipper.currency_unit = @currency and
				shipper_detail.shipper = shipper.id

	-- otherwise update all invoices 
	else
		update 	shipper_detail set
				price = ( alternate_price * isnull((	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
												from	currency_conversion cc
												where	effective_date <= GetDate ( ) and
														currency_code = shipper.currency_unit ) and
							currency_code = shipper.currency_unit ),1) / isnull((
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
		from	shipper
		where	shipper_detail.shipper = shipper.id

end
go


print'
--------------------------------------------
-- PROCEDURE:	msp_calc_order_currency
--------------------------------------------
'
if exists ( select 1 from dbo.sysobjects where id = object_id ( 'msp_calc_order_currency' ) )
	drop procedure msp_calc_order_currency
go

create procedure msp_calc_order_currency (	@order_no numeric(8,0),
						@customer varchar(10),
						@destination varchar(10),
						@sequence numeric(5,0),
						@currency varchar(3) )
as
begin

	-- declare local variables
	declare	@base_currency	varchar(3)

	-- get the base currency from parameters table
	select	@base_currency = base_currency
	from	parameters

	-- if order_no was sent update only that order
	if isnull(@order_no,0) > 0
	begin

		if isnull(@sequence,0) > 0
		begin
			update 	order_detail set
				price = ( order_detail.alternate_price * isnull(( 	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
									from	currency_conversion cc
									where	effective_date <= GetDate ( ) and
										currency_code = order_header.currency_unit ) and
						currency_code = order_header.currency_unit ),1) / isnull((
							select	rate
							from	currency_conversion 
							where 	effective_date = (	select	max (effective_date)
											from	currency_conversion cc
											where	effective_date <= GetDate ( ) and
												currency_code = @base_currency ) and
								currency_code = @base_currency ),1))
			from	order_header
			where	order_detail.order_no = @order_no and
				order_detail.sequence = @sequence and
				order_header.order_no = order_detail.order_no and
				order_header.order_type = 'N'

			update 	order_detail set
				order_detail.alternate_price = order_header.alternate_price,
				price = ( order_header.alternate_price * isnull(( 	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
									from	currency_conversion cc
									where	effective_date <= GetDate ( ) and
										currency_code = order_header.currency_unit ) and
						currency_code = order_header.currency_unit ),1) / isnull((
							select	rate
							from	currency_conversion 
							where 	effective_date = (	select	max (effective_date)
											from	currency_conversion cc
											where	effective_date <= GetDate ( ) and
												currency_code = @base_currency ) and
								currency_code = @base_currency ),1))
			from	order_header
			where	order_detail.order_no = @order_no and
				order_detail.sequence = @sequence and
				order_header.order_no = order_detail.order_no and
				order_header.order_type = 'B'
		end
		else
		begin

			update 	order_header set
				price = ( alternate_price * isnull(( 	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
									from	currency_conversion cc
									where	effective_date <= GetDate ( ) and
										currency_code = order_header.currency_unit ) and
						currency_code = order_header.currency_unit ),1) / isnull((
							select	rate
							from	currency_conversion 
							where 	effective_date = (	select	max (effective_date)
											from	currency_conversion cc
											where	effective_date <= GetDate ( ) and
												currency_code = @base_currency ) and
								currency_code = @base_currency ),1))
			where	order_no = @order_no and
				order_type = 'B'

			update 	order_detail set
				price = ( order_detail.alternate_price * isnull((	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
									from	currency_conversion cc
									where	effective_date <= GetDate ( ) and
										currency_code = order_header.currency_unit ) and
						currency_code = order_header.currency_unit ),1) / isnull((
							select	rate
							from	currency_conversion 
							where 	effective_date = (	select	max (effective_date)
											from	currency_conversion cc
											where	effective_date <= GetDate ( ) and
												currency_code = @base_currency ) and
								currency_code = @base_currency ),1))
			from	order_header
			where	order_detail.order_no = @order_no and
				order_header.order_no = order_detail.order_no and
				order_header.order_type = 'N'

		end

	end	
	-- if customer is sent, update all orders for that customer
	else if isnull(@customer,'') > ''
	begin
			update 	order_header set
				price = ( alternate_price * isnull((	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
									from	currency_conversion cc
									where	effective_date <= GetDate ( ) and
										currency_code = order_header.currency_unit ) and
						currency_code = order_header.currency_unit ),1) / isnull((
							select	rate
							from	currency_conversion 
							where 	effective_date = (	select	max (effective_date)
											from	currency_conversion cc
											where	effective_date <= GetDate ( ) and
												currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
			where	customer = @customer and
				order_type = 'B'

			update 	order_detail set
				price = ( order_detail.alternate_price * isnull((	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
									from	currency_conversion cc
									where	effective_date <= GetDate ( ) and
										currency_code = order_header.currency_unit ) and
						currency_code = order_header.currency_unit ),1) / isnull((
							select	rate
							from	currency_conversion 
							where 	effective_date = (	select	max (effective_date)
											from	currency_conversion cc
											where	effective_date <= GetDate ( ) and
												currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
			from	order_header
			where	order_header.customer = @customer and
				order_header.order_type = 'N' and
				order_header.order_no = order_detail.order_no
	end
	-- if destination is sent, update all orders for that destination
	else if isnull(@destination,'') > ''
	begin
			update 	order_header set
				price = ( alternate_price * isnull((	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
									from	currency_conversion cc
									where	effective_date <= GetDate ( ) and
										currency_code = order_header.currency_unit ) and
						currency_code = order_header.currency_unit ),1) / isnull((
							select	rate
							from	currency_conversion 
							where 	effective_date = (	select	max (effective_date)
											from	currency_conversion cc
											where	effective_date <= GetDate ( ) and
												currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
			where	destination = @destination and
				order_type = 'B'

			update 	order_detail set
				price = ( order_detail.alternate_price * isnull((	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
									from	currency_conversion cc
									where	effective_date <= GetDate ( ) and
										currency_code = order_header.currency_unit ) and
						currency_code = order_header.currency_unit ),1) / isnull((
							select	rate
							from	currency_conversion 
							where 	effective_date = (	select	max (effective_date)
											from	currency_conversion cc
											where	effective_date <= GetDate ( ) and
												currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
			from	order_header
			where	order_header.destination = @destination and
				order_header.order_type = 'N' and
				order_header.order_no = order_detail.order_no
	end
	-- if currency is sent, update all orders with that currency
	else if isnull(@currency,'') > ''
	begin
			update 	order_header set
				price = ( alternate_price * isnull((	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
									from	currency_conversion cc
									where	effective_date <= GetDate ( ) and
										currency_code = order_header.currency_unit ) and
						currency_code = order_header.currency_unit ),1) / isnull((
							select	rate
							from	currency_conversion 
							where 	effective_date = (	select	max (effective_date)
											from	currency_conversion cc
											where	effective_date <= GetDate ( ) and
												currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
			where	currency_unit = @currency and
				order_type = 'B'

			update 	order_detail set
				price = ( order_detail.alternate_price * isnull((	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
									from	currency_conversion cc
									where	effective_date <= GetDate ( ) and
										currency_code = order_header.currency_unit ) and
						currency_code = order_header.currency_unit ),1) / isnull((
							select	rate
							from	currency_conversion 
							where 	effective_date = (	select	max (effective_date)
											from	currency_conversion cc
											where	effective_date <= GetDate ( ) and
												currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
			from	order_header
			where	order_header.currency_unit = @currency and
				order_header.order_type = 'N' and
				order_header.order_no = order_detail.order_no
	end
	-- otherwise update all orders
	else
	begin
			update 	order_header set
				price = ( alternate_price * isnull((	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
									from	currency_conversion cc
									where	effective_date <= GetDate ( ) and
										currency_code = order_header.currency_unit ) and
						currency_code = order_header.currency_unit ),1) / isnull((
							select	rate
							from	currency_conversion 
							where 	effective_date = (	select	max (effective_date)
											from	currency_conversion cc
											where	effective_date <= GetDate ( ) and
												currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
			where	order_type = 'B'

			update 	order_detail set
				price = ( order_detail.alternate_price * isnull((	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
									from	currency_conversion cc
									where	effective_date <= GetDate ( ) and
										currency_code = order_header.currency_unit ) and
						currency_code = order_header.currency_unit ),1) / isnull((
							select	rate
							from	currency_conversion 
							where 	effective_date = (	select	max (effective_date)
											from	currency_conversion cc
											where	effective_date <= GetDate ( ) and
												currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
			from	order_header
			where	order_header.order_type = 'N' and
				order_header.order_no = order_detail.order_no
	end
end

go





print'
-----------------------------------------
-- PROCEDURE:	msp_calc_po_currency
-----------------------------------------
'
if exists ( select 1 from dbo.sysobjects where id = object_id ( 'msp_calc_po_currency' ) )
	drop procedure msp_calc_po_currency
go

create procedure msp_calc_po_currency (	@po_no integer, 
												@vendor varchar(10), 
												@destination varchar(10), 
												@row_id integer, 
												@part varchar(25), 
												@date_due datetime, 
												@currency varchar(3) )
as
begin

	-- declare local variables
	declare	@base_currency	varchar(3)

	-- get the base currency from parameters table
	select	@base_currency = base_currency
	from	parameters

	-- if po_no was sent update only that purchase order
	if isnull(@po_no,0) > 0
	begin

		if 	isnull(@row_id,0) > 0 and
			isnull(@part,'') > '' and
			isnull(@date_due,convert(datetime,'1990/01/01')) > convert(datetime,'1990/01/01')

			update 	po_detail set
					price = ( alternate_price * isnull((	
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = po_header.currency_unit ) and
								currency_code = po_header.currency_unit ),1) / isnull((
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
			from	po_header
			where	po_detail.po_number = @po_no and
					po_detail.row_id = @row_id and
					po_detail.date_due = @date_due and
					po_detail.part_number = @part and
					po_header.po_number = po_detail.po_number
		else

			update 	po_detail set
					price = ( alternate_price * isnull((	
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = po_header.currency_unit ) and
								currency_code = po_header.currency_unit ),1) / isnull((
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
			from	po_header
			where	po_detail.po_number = @po_no and
					po_header.po_number = po_detail.po_number


	end	
	-- if vendor is sent, update all purchase orders for that vendor 
	else if isnull(@vendor,'') > ''
		update 	po_detail set
				price = ( alternate_price * isnull((	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
												from	currency_conversion cc
												where	effective_date <= GetDate ( ) and
														currency_code = po_header.currency_unit ) and
							currency_code = po_header.currency_unit ),1) / isnull((
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
		from	po_header
		where	po_header.vendor_code = @vendor and
				po_header.po_number = po_detail.po_number

	-- if destination is sent, update all purchase orders for that destination 
	else if isnull(@destination,'') > ''
		update 	po_detail set
				price = ( alternate_price * isnull((	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
												from	currency_conversion cc
												where	effective_date <= GetDate ( ) and
														currency_code = po_header.currency_unit ) and
							currency_code = po_header.currency_unit ),1) / isnull((
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
		from	po_header
		where	po_header.ship_to_destination = @destination and
				po_header.po_number = po_detail.po_number

	-- if currency is sent, update all purchase orders with that currency
	else if isnull(@currency,'') > ''
		update 	po_detail set
				price = ( alternate_price * isnull((	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
												from	currency_conversion cc
												where	effective_date <= GetDate ( ) and
														currency_code = po_header.currency_unit ) and
							currency_code = po_header.currency_unit ),1) / isnull((
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
		from	po_header
		where	po_header.currency_unit = @currency and
				po_header.po_number = po_detail.po_number

	-- otherwise update all orders
	else
		update 	po_detail set
				price = ( alternate_price * isnull((	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
												from	currency_conversion cc
												where	effective_date <= GetDate ( ) and
														currency_code = po_header.currency_unit ) and
							currency_code = po_header.currency_unit ),1) / isnull((
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @base_currency ) and
								currency_code = @base_currency ),1) )
		from	po_header
		where	po_header.po_number = po_detail.po_number

end

go




print'
-------------------------------------------
-- procedure:	msp_calc_committed_dropship
-------------------------------------------
'
IF	Exists	(
	SELECT	*
	FROM	sysobjects
	WHERE	id = Object_id ( 'msp_calc_committed_dropship' ) )
	DROP PROCEDURE	msp_calc_committed_dropship
GO

CREATE PROCEDURE msp_calc_committed_dropship (
	@orderno	integer,
	@rowid		integer )
AS
BEGIN -- (1B)
---------------------------------------------------------------------------------------
-- 	This procedure calculates the committed quantity for a dropship order.
--	Modified:	April 26 1999, Chris Rogers
--	Paramters:	@orderno		mandatory
--			@rowid			mandatory
--	Returns:	0			success
---------------------------------------------------------------------------------------
--	Outline:
--	1.	Declarations
--	2.	Initializations
--	3.	Sum quantity from po_detail for dropship
--	4.	Get standard unit from part_inventory table
--	5.	Convert quantity from order unit to standard unit
--	6.	Update order_detail with converted quantity
--	7.	Return success
---------------------------------------------------------------------------------------

--	1.	Declarations
	declare	@quantity	numeric(20,6),
		@part		varchar(25),
		@unit		varchar(2),
		@stdunit	varchar(2)
	
--	2.	Get part number and unit from order for later use
	select	@part = part_number,
		@unit = unit
	from	order_detail
	where	order_no = @orderno and
		row_id = @rowid
		
--	3.	Sum quantity from po_detail for dropship
	select	@quantity = sum ( standard_qty )
	from	po_detail
	where	sales_order = @orderno and
		dropship_oe_row_id = @rowid
		
--	4.	Get standard unit from part_inventory table
	select	@stdunit = standard_unit
	from	part_inventory
	where	part = @part
	
--	5.	Convert quantity from order unit to standard unit
	exec msp_unit_conversion @part, @quantity, @unit, @stdunit
	
--	6.	Update order_detail with converted quantity
	update	order_detail
	set	committed_qty = @quantity
	where	order_no = @orderno and
		row_id = @rowid

--	7.	Return success
	return 0
END -- (1E)
go



print '
----------------------------------------
-- procedure:	msp_calc_shipper_weights
----------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_calc_shipper_weights'))
	drop procedure msp_calc_shipper_weights
GO

CREATE PROCEDURE msp_calc_shipper_weights @shipper int
AS
BEGIN

	DECLARE	@tare_weight	numeric(20,6),
		@net_weight		numeric(20,6),
		@gross_weight	numeric(20,6),
		@part			varchar(35),
		@part_original	varchar(25),
		@suffix			integer,
		@pallet_tare	numeric(20,6)

	select	@part = min(part)
	from	shipper_detail
	where	shipper = @shipper

	select	@part = isnull(@part,'')

	while ( @part > '' )
	begin

		select	@part_original = part_original,
			@suffix = suffix
		from	shipper_detail
		where	shipper = @shipper and
			part = @part

		if isnull(@suffix,0) > 0
		begin
			SELECT	@net_weight = sum ( isnull(object.weight,0) )
			FROM	object
			WHERE	object.shipper = @shipper AND
				object.part = @part_original AND
				object.suffix = @suffix

			SELECT	@tare_weight = sum ( isnull ( pm.weight, 0 ) )
			FROM	object as o,
				package_materials as pm
			WHERE 	o.package_type = pm.code AND
				o.shipper = @shipper AND
				o.part = @part_original AND
				o.suffix = @suffix
		end
		else
		begin
			SELECT	@net_weight = sum ( IsNull ( object.weight, 0 ) )
			FROM	object
			WHERE	object.shipper = @shipper AND
				object.part = @part

			SELECT	@tare_weight = sum ( isnull ( pm.weight, 0 ) )
			FROM	object o,
				package_materials pm
			WHERE 	o.package_type = pm.code AND
				o.shipper = @shipper AND
				o.part = @part
		end

		select 	@tare_weight = isnull(@tare_weight,0),
			@net_weight = isnull(@net_weight,0),
			@gross_weight = isnull(@tare_weight,0) + isnull(@net_weight,0)

		update 	shipper_detail set
			net_weight = @net_weight,
			tare_weight = @tare_weight,
			gross_weight = @gross_weight
		where 	shipper = @shipper and
			part = @part

		select	@part = min(part)
		from	shipper_detail
		where	shipper = @shipper and
			part > @part
	
		select	@part = isnull(@part,'')
	end

	SELECT	@pallet_tare = isnull ( sum ( o.tare_weight ), 0 )
	FROM	object as o
	WHERE 	o.shipper = @shipper and
		type = 'S'
		
	select	@tare_weight = sum (sd.tare_weight) + @pallet_tare,
		@net_weight = sum (sd.net_weight),
		@gross_weight = sum (sd.gross_weight) + @pallet_tare
	from	shipper_detail sd
	where	sd.shipper = @shipper

	select	@tare_weight = isnull(@tare_weight,0),
		@net_weight = isnull(@net_weight,0),
		@gross_weight = isnull(@gross_weight,0)

	UPDATE	shipper
	SET	shipper.tare_weight = @tare_weight,
		shipper.net_weight = @net_weight,
		shipper.gross_weight = @gross_weight
	WHERE	shipper.id = @shipper

END

GO




print'
---------------------------------------------------
-- PROCEDURE:	msp_calc_vendor_matrix
---------------------------------------------------
'
if exists ( select 1 from dbo.sysobjects where id = object_id ( 'msp_calc_vendor_matrix' ) )
	drop procedure msp_calc_vendor_matrix
go
if exists ( select 1 from dbo.sysobjects where id = object_id ( 'msp_calc_vendor_price_matrix' ) )
	drop procedure msp_calc_vendor_price_matrix
go

create procedure msp_calc_vendor_matrix ( 	@part varchar(25), 
														@vendor varchar(10), 
														@qty_break decimal(20,6), 
														@currency_unit varchar(3) )
as
begin
	-- declare local variables
	declare	@vendor_currency	varchar(3),
			@base_currency		varchar(3)

	-- get the base currency from parameters table
	select	@base_currency = base_currency
	from	parameters

	if isnull(@currency_unit,'') > ''
		update 	part_vendor_price_matrix set
				price = ( part_vendor_price_matrix.alternate_price * isnull(( 	
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
												from	currency_conversion cc
												where	effective_date <= GetDate ( ) and
														currency_code = @currency_unit ) and
							currency_code = @currency_unit ),1) / isnull((
					select	rate
					from	currency_conversion 
					where 	effective_date = (	select	max (effective_date)
												from	currency_conversion cc
												where	effective_date <= GetDate ( ) and
														currency_code = @base_currency ) and
							currency_code = @base_currency ),1))
		from	part_vendor_price_matrix,
				vendor
		where	part_vendor_price_matrix.vendor = vendor.code and
				vendor.default_currency_unit = @currency_unit
	else
	begin
		-- get vendor's default currency
		select	@vendor_currency = default_currency_unit
		from	vendor
		where	code = @vendor
		
		if isnull(@part,'') > ''
			update 	part_vendor_price_matrix set
					price = ( part_vendor_price_matrix.alternate_price * isnull(( 	
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @vendor_currency ) and
								currency_code = @vendor_currency ),1) / isnull((
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @base_currency ) and
								currency_code = @base_currency ),1))
			from	part_vendor_price_matrix
			where	part = @part and
					vendor = @vendor and
					break_qty = @qty_break 
		else
			update 	part_vendor_price_matrix set
					price = ( part_vendor_price_matrix.alternate_price * isnull(( 	
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @vendor_currency ) and
								currency_code = @vendor_currency ),1) / isnull((
						select	rate
						from	currency_conversion 
						where 	effective_date = (	select	max (effective_date)
													from	currency_conversion cc
													where	effective_date <= GetDate ( ) and
															currency_code = @base_currency ) and
								currency_code = @base_currency ),1))
			from	part_vendor_price_matrix
			where	vendor = @vendor
	end	
end
go


print'
-------------------------
-- msp_find_internal_part
-------------------------
'
if	exists	(
	select	*
	  from	sysobjects
	where	id = object_id ( 'msp_find_internal_part' ) )
	drop procedure	msp_find_internal_part
go

create procedure msp_find_internal_part (
	@customerpart varchar(35),
	@customer varchar(10),
	@internalpart varchar(25) output )
as
-------------------------------------------------------------------------------------
--	This procedure finds an internal part number from customer part and customer.
--
--	Modifications:	02 JAN 1999, Eric E. Stimpson	Original
--			24 MAY 1999, Eric E. Stimpson	Modified formatting.
--			29 JUN 1999, Eric E. Stimpson	Changed null to empty for error returns.
--
--	Paramters:	@customerpart	mandatory
--			@customer	mandatory
--			@internalpart	output
--
--	Returns:	  0	success
--			 -1	error occurred (more than one internal part found)
--			100	internal part not found
--
--	Process:
--	1. Declarations.
--	2. Initialize all variables.
--	3. Get the number of internal parts.
--	4. If part count is equal to 0, set internal part to empty and return internal part not found.
--	5. If part count is greater than 1, set internal part to empty and return error occurred.
--	6. Part count is equal to 1, set internal part to the part found and return success.
-------------------------------------------------------------------------------------

--	1. Declarations.
declare	@partcount	integer

--	2. Initialize all variables.
select	@partcount = 0

--	3. Get the number of internal parts.
select	@partcount = IsNull ( (
		select	Count ( 1 )
		  from	part_customer
		 where	customer_part = @customerpart and
		 	customer = @customer ), 0 )

--	4. If part count is equal to 0, set internal part to null and return internal part not found.
if @partcount = 0
begin -- (1aB)
	select	@internalpart = ''
	Return 100
end -- (1aB)

--	5. If part count is greater than 1, set internal part to null and return error occurred.
if @partcount > 1
begin -- (1bB)
	select @internalpart = ''
	Return -1
end -- (1bB)

--	6. Part count is equal to 1, set internal part to the part found and return success.
select	@internalpart = part
  from	part_customer
 where	customer_part = @customerpart and
 	customer = @customer
return 0
go



print'
-------------------------
-- msp_create_customer_po
-------------------------
'
if exists (
	select	*
	  from	sysobjects
	 where	id = object_id ( 'msp_create_customer_po' ) )
	drop procedure	msp_create_customer_po
go

create procedure msp_create_customer_po (
	@shipto varchar(20),
	@customerpo varchar(30),
	@orderno decimal(8) output,
	@customer varchar(10) output )
as
-------------------------------------------------------------------------------------
--	This procedure creates a normal order header from customer po and shipto id
--	data.
--
--	Modifications:	02 JAN 1999, Eric E. Stimpson	Original
--			24 MAY 1999, Eric E. Stimpson	Modified formatting.
--
--	Paramters:	@shipto		mandatory
--			@customerpo	mandatory
--			@orderno	output
--			@customer	output
--
--	Returns:	  0	success
--			 -2	ship to not World Group, do not process.
--			100	ship to not found or not billable.
--
--	Process:
--	1. Declarations.
--	2. Inititialize all variables from customer and destination tables.
--	3. Check if customer found and return ship to not found or not billable if not.
--	4. Get the next available order number from parameters.
--	5. Create order header and return success.
-------------------------------------------------------------------------------------

--	1. Declarations.
declare	@orderdate	datetime,
	@ordertype	char(1),
	@salesrep	varchar(10),
	@terms		varchar(20),
	@currency	varchar(3),
	@csstatus	varchar(20)

--	2. Inititialize all variables from customer and destination tables.
select	@customer = destination.customer,
	@orderdate = GetDate(),
	@ordertype = 'N',
	@salesrep = salesrep,
	@terms = terms,
	@currency = destination.default_currency_unit,
	@csstatus = destination.cs_status
  from	destination
  	join customer on destination.customer = customer.customer
 where	destination = @shipto

--	3. Check if customer found and return ship to not found or not billable if not.
if IsNull ( @customer, '' ) = ''
	Return 100

--	4. Get the next available order number from parameters.
select	@orderno = sales_order
  from	parameters

while (	select	order_no
	  from	order_header
	  	cross join parameters
	 where	order_no=sales_order ) > 0
begin -- (1bB)
	update	parameters
	   set	sales_order = sales_order + 1

	select	@orderno = sales_order
	  from	parameters
end -- (1bB)

update	parameters
   set	sales_order = sales_order + 1

--	6. Create order header and return success.
insert	order_header (
		order_no,
		customer,
		order_date,
		destination,
		order_type,
		customer_po,
		salesman,
		term,
		currency_unit,
		cs_status )
select	@orderno,
	@customer,
	@orderdate,
	@shipto,
	@ordertype,
	@customerpo,
	@salesrep,
	@terms,
	@currency,
	@csstatus

return 0
go

print '
------------------------------
-- msp_calculate_committed_qty
------------------------------
'
------------------------------
-- msp_calculate_committed_qty
------------------------------
if exists (
	select	1
	  from	sysobjects
	 where	id = object_id ( 'msp_calculate_committed_qty' ) )
	 drop procedure msp_calculate_committed_qty
go

create procedure msp_calculate_committed_qty (
	@orderno	numeric(8,0),
	@ordpart	varchar (25) = null,
	@suffix		integer = null )
as
---------------------------------------------------------------------------------------
-- 	This procedure calculates the committed quantity for an order.
--
--	Modifications:	22 JAN 1999, Eric E. Stimpson	Original.
--			29 MAY 1999, Eric E. Stimpson	Modified formatting.
--			09 JUN 1999, Chris Rogers	Modified to use due_date instead of sequence order.
--			06 JUL 1999, Eric E. Stimpson	Added suffix loop for normal orders.
--			08 AUG 1999, Chris Rogers	Included sequence for uniqueness in the case of duplicate due_date.
--							Changed @orderno argument to a numeric(8,0) to match db.
--			10 FEB 2000, Eric E. Stimpson	Fixed issue with finding next release with duplicate due_dates.
--			12 DEC 2001, Harish Gubbi	Changed the logic of assigining the committed qty
--			20 JAN 2003, Harish Gubbi	Changed the cursor var from releases to creleases
--
--	Paramters:	@orderno	mandatory
--			@ordpart	optional
--			@suffix		optional
--
--	Returns:	  0		success
--			100		order not found
--
--	Process:
--	1.	Declarations.
--	2.	Initializations.
--	3.	Check if part number was passed and loop through all parts if not.
--	4.	Check if suffix was passed and loop through all suffixes if not.
--	5.	Check if order exists and return 100 if not.
--	6.	Build shipper part number from part number and suffix.
--	7.	Get the total committed for this part.
--	8.	Set committed quantity to zero for this order.
--	9.	Initialize due date and sequence.	
--	10.	Loop through order detail rows, writing committed quantities.
--	11.	If sequence was found, set committed quantity appropriately, otherwise set remaining committed to zero.
--	12.	If release is less than remaining committed quantity then use whole release.
--	13.	Otherwise, use partial release.
--	14.	Find the next order detail release and its quantity.
--	15.	Completed successfully, return 0
---------------------------------------------------------------------------------------

--	1.	Declarations.
declare	@shippart		varchar (35),
	@shiptype		char (1),
	@committedleft		numeric (20,6),
	@releaseqty		numeric (20,6),
	@sequence		integer,
	@retcode		integer,
	@due_date		datetime,
	@ctrvar			integer

--	2.	Initializations.
select	@retcode = 100
select	@due_date = DateAdd ( yy, -10, GetDate ( ) )

--	3.	Check if part number was passed and loop through all parts if not.
if @ordpart is null
begin -- (1aB)
	select	@ordpart = min ( part_number )
	  from	order_detail
	 where	order_no = @orderno

	while @ordpart > ''
	begin -- (2aB)
		exec	@retcode = msp_calculate_committed_qty
				@orderno,
				@ordpart

		select	@ordpart = min ( part_number )
		  from	order_detail
		 where	order_no = @orderno and
			part_number > @ordpart
	end -- (2aB)
	return @retcode

end -- (1aB)

--	4.	Check if suffix was passed and loop through all suffixes if not.
if @suffix is null
begin -- (1aB)
	select	@suffix = min ( suffix )
	  from	order_detail
	 where	order_no = @orderno and
		part_number = @ordpart

	while @suffix > 0
	begin -- (2bB)
		exec	@retcode = msp_calculate_committed_qty
				@orderno,
				@ordpart,
				@suffix

		select	@suffix = min ( suffix )
		  from	order_detail
		 where	order_no = @orderno and
			part_number = @ordpart and
			suffix > @suffix
	end -- (2bB)

end -- (1aB)

--	5.	Check if order exists and return 100 if not.
if
(	select	count ( 1 )
	  from	order_detail
	 where	order_no = @orderno and
		part_number = @ordpart and
		( suffix = @suffix or @suffix is null ) ) = 0
	return 100

--	6.	Build shipper part number from part number and suffix.
if @suffix > 0
	select	@shippart = @ordpart + '-' + convert ( varchar ( 9 ), @suffix )
else
	select	@shippart = @ordpart

--	7.	Get the total committed for this part.
select	@committedleft = isnull ( (
	select	sum ( qty_required )
	  from	shipper_detail,
		shipper
	 where	order_no = @orderno and
		part = @shippart and
		shipper = id and
		shipper.type is null and
		( status = 'O' or status = 'A' or status = 'S') ), 0 )

--	8.	Set committed quantity to zero for this order.
update	order_detail
   set	committed_qty = 0
 where	order_no = @orderno and
	part_number = @ordpart and
	( ( suffix is null ) or suffix = @suffix )

declare	creleases cursor for
select	due_date, sequence, quantity
from	order_detail
where	order_no = @orderno and
	part_number = @ordpart and
	(	suffix is null or
		suffix = @suffix )
order by due_date, sequence	


--	9.	Initialize due date and sequence.	
select	@ctrvar = 0

--	Open cursor
open	creleases

--	fetch data from the cursor
fetch	creleases
into	@due_date, @sequence, @releaseqty

--	Check sqlstatus
if @@fetch_status <> 0 
	select @ctrvar = 1

--	loop through all the order detail rows
while @ctrvar = 0
begin

	--	10.	Loop through order detail rows, writing committed quantities.
	if @committedleft > 0 
	begin -- (1bB)

	--	11.	If sequence was found, set committed quantity appropriately, otherwise set remaining committed to zero.
		if @sequence > 0
		begin -- (2bB)
	
	--	12.	If release is less than remaining committed quantity then use whole release.
			if @committedleft > @releaseqty
			begin -- (3bB)
				update	order_detail
				   set	committed_qty = @releaseqty
				 where	order_no = @orderno and
					sequence = @sequence
	
				select	@committedleft = @committedleft - @releaseqty
			end -- (3bB)
	
	--	13.	Otherwise, use partial release.
			else
			begin -- (3cB)
				update	order_detail
				   set	committed_qty = @committedleft
				 where	order_no = @orderno and
					sequence = @sequence
	
				select	@committedleft = 0
			end -- (3cB)
	
		end -- (2bB)
		else
			select	@committedleft = 0

		--	fetch data from the cursor			
		fetch	creleases
		into	@due_date, @sequence, @releaseqty
		
		--	Check sqlstatus		
		if @@fetch_status <> 0 
			select @ctrvar = 1

	end -- (1bB)
	else
		select @ctrvar = 1
end

--	Close cursor
close	creleases
deallocate creleases
	
--	15.	Completed successfully, return 0.
return 0
go

print'
------------------------------------------
-- procedure:	msp_calculate_std_quantity
------------------------------------------
'
IF	Exists	(
	SELECT	*
	  FROM	sysobjects
	WHERE	id = Object_id ( 'msp_calculate_std_quantity' ) )
	DROP PROCEDURE	msp_calculate_std_quantity
GO

CREATE PROCEDURE msp_calculate_std_quantity
(	@part			varchar (25),
	@altquantity	numeric (20,6) OUTPUT,
	@unit			char (2) )
AS
BEGIN -- (1B)
---------------------------------------------------------------------------------------
-- 	This procedure calculates the standard quantity for a part from an alternate
--	quantity and unit of measure.
--	Modified:	02 Jan 1999, Eric E. Stimpson
--	Paramters:	@part			mandatory
--				@altquantiy		mandatory
--				@unit			optional
--	Returns:	0				success
--				-1				error, invalid unit for this part
--				100				no change, unit was standard unit
---------------------------------------------------------------------------------------

--	Declarations.
	DECLARE	@stdquantity	numeric (20,6),
			@factor			numeric (20,6)

--	Initialize all variables
	SELECT	@stdquantity = 0,
			@factor = 1

--	If unit is standard unit, return no change, unit was standard unit.
	IF @unit =
	(	SELECT	standard_unit
		  FROM	part_inventory
		 WHERE	part = @part )
		Return	100

--	Get the standard quantity conversion factor.
	SELECT	@factor = IsNull
			( (	SELECT	conversion
				  FROM	unit_conversion,
						part_inventory,
						part_unit_conversion
				 WHERE	part_inventory.part = @part AND
						part_unit_conversion.part = @part AND
						part_unit_conversion.code = unit_conversion.code AND
						unit_conversion.unit1 = @unit AND
						unit_conversion.unit2 = part_inventory.standard_unit ), -1 )

--	If factor is -1, an error occurred because part had an invalid unit of measure.  Return error.
	IF @factor = -1
		Return	-1

--	Calculate the standard quantity
	SELECT	@stdquantity = @altquantity * @factor

--	Assign the standard quantity to return variable and return success.
	SELECT	@altquantity = @stdquantity
	Return	0
END -- (1B)

go



print'
----------------------------------
-- procedure:	msp_check_downline
----------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_check_downline'))
	drop procedure msp_check_downline
GO

create procedure msp_check_downline(@@parent varchar(25),@@child varchar(25)) as
begin
  declare @cur_part varchar(25),
  @level integer,
  @current_datetime datetime
  select @current_datetime=convert(datetime,convert(varchar(12),GetDate())+' '+convert(varchar(2),datepart(hh,GetDate()))+':'+convert(varchar(2),datepart(mi,GetDate()))+':'+convert(varchar(2),datepart(ss,GetDate())))
  insert into temp_bom_stack
    select part,1, @@spid
      from bill_of_material_ec
      where parent_part=@@child
      and start_datetime<=@current_datetime
      and(end_datetime>=@current_datetime
      or end_datetime is null)
  select @level=1
  while @level>0
    begin
      select @cur_part=min(part)
        from temp_bom_stack
        where partlevel=@level and
	 	spid=@@spid
      if @cur_part is not null
        begin
          if @cur_part=@@parent
          begin
          	rollback transaction
          	return
          end
          delete from temp_bom_stack
            where part=@cur_part
            and partlevel=@level and
	    spid=@@spid
          insert into temp_bom_stack
            select part,
              @level+1,@@spid
              from bill_of_material_ec
              where parent_part=@cur_part
              and start_datetime<=@current_datetime
              and(end_datetime>=@current_datetime
              or end_datetime is null)
          if @@error=0
            select @level=@level+1
        end
      else
        select @level=@level-1
    end
end
go


print'
----------------------------------
-- procedure:	msp_component_list
----------------------------------
'
if exists ( select 1 from dbo.sysobjects where id = object_id ( 'msp_component_list' ) )
 drop procedure msp_component_list
go

create procedure msp_component_list(@top_part varchar(25))
as
begin
 create table #stack(
   part varchar(25) null,
   )
 create table #output_stack(
   part varchar(25) null,
   )
 declare @count integer,
 @part varchar(25)
 insert into #stack values(@top_part)
 select @count=1
 while @count>0
   begin
     select @part=max(part)
       from #stack
     delete from #stack where part=@part
     insert into #output_stack values(@part)
     insert into #stack
       select bom.part
         from bill_of_material as bom
         where bom.parent_part=@part
     select @count=@@rowcount
   end
 select part from #output_stack where part<>@top_part
 drop table #stack
 drop table #output_stack
end
go


print '
--------------------------------
-- procedure:	msp_create_wo_po
--------------------------------
'
if exists (select 1 from dbo.sysobjects where id = object_id('msp_create_wo_po'))
   drop procedure msp_create_wo_po
GO
create procedure msp_create_wo_po as
-------------------------------------------------------------------------------------------------
--	Procedure	msp_create_wo_po
--	Purpose		To create work orders or po releases for all the parts onhand falls
--			below the minimum level Applicable to all the kanban part
--	Arguments	None
--
--	Development	Developer	Date	Description
--			GPH		No idea	Created long time back
--			GPH		4/27/01	Included a procedure call at the end of the proc
--
------------------------------------------------------------------------------------------------
--	Declare variables
declare	@onhand           dec(20,6),      @min_onhand      dec(20,6),       @max_onhand      dec(20,6),
	@part             varchar(25),    @vendor          varchar(10),     @prev_part       varchar(25),
	@part_type        char(1),        @part_class      char(1),         @work_order      varchar(10),
	@machine_no       varchar(10),    @due_date        datetime,        @process_id      varchar(25),
	@setup_time       int,            @cycle_time      int,             @runtime         numeric(15,7),
	@cycle_unit       varchar(15),    @parts_per_hour  numeric(7,3),    @parts_per_cycle numeric(7,3),
	@new_qty_sum      numeric(20,6),  @new_qty         numeric(20,6),   @include_set_up  char(1),
	@trusted          varchar(1),     @po_number       int,             @rowid           numeric(20,0),
	@desc             varchar(40),    @uom             varchar(2),      @crp             varchar(25),
	@account_code     varchar(50),    @price           numeric(20,6),   @release_no      int,
	@ship_to_dest     varchar(25),    @terms           varchar(20),     @week_no         int,
	@plant            varchar(10),    @standard_qty    numeric(20,6),   @ship_via        varchar(15),
	@ship_type        varchar(1),     @status          varchar(1),      @leaddays        int,
	@dFiscalYearBegin datetime,       @idays           int,             @iweek           int,
	@mindaysonhand    int,            @location        varchar(10),     @prev_locn       varchar(10),
	@dmdqty           numeric(20,6),  @howmanydays     int,             @hours           int,
	@enddate          datetime,       @endtime         datetime,        @dest            varchar(10),
	@prev_dest        varchar(10),    @orderno         int,             @customer        varchar(10),
	@stdpack          numeric(20,6),  @note            varchar(255),
	@kanban           char(1),	  @requisition	   char(1)
	
create table #tmp_partloc (	location varchar(10) not null,
				days_onhand numeric(20,6) null,
				min_onhand  numeric(20,6) null,
				max_onhand  numeric(20,6) null )
				
create table #tmp_dest (	destination varchar(10) not null,
				order_no    int not null)
select @prev_part=''

begin transaction

--	Get the setup time
select	@include_set_up=include_setuptime,
	@dFiscalYearBegin=fiscal_year_begin,
	@requisition = isnull(requisition,'N') 
from	parameters

--	Get each row of information from part,part_inventory,part_online table
set rowcount 1

select	@part		= part.part,
	@part_type	= part.type,
	@part_class	= part.class,
	@desc		= part.name,
	@crp		= part.cross_ref,
	@uom		= part_inventory.standard_unit,
	@onhand		= isnull(part_online.on_hand,0),
	@min_onhand	= isnull(part_online.min_onhand,0),
	@max_onhand	= isnull(part_online.max_onhand,0),
	@vendor		= part_online.default_vendor,
	@po_number	= part_online.default_po_number
from	part,part_inventory,part_online
where	(part.part > @prev_part) and
	(part_inventory.part=part.part) and
	(part_online.part=part.part)
order by part.part   

--	while rowcount is greater than 0 
while @@rowcount>0
begin	-- 2b
	select @due_date=convert( datetime, (substring(convert(varchar(19), getdate()),1,11)))
	--	check type & class
	if @part_class='M'	-- if it's a manufactured part
	begin	-- 3b 
		if @part_type='F'  -- if it's a finished part
		begin	-- 4b 
			--	append all the destinations & order_no for that part from order_header table
			set rowcount 0
			insert	#tmp_dest (destination,order_no)
			select	destination,order_no
			from	order_header
			where	order_header.blanket_part=@part
			order by destination
			
			--	check whether the tmp table is populated or not 
			if @@rowcount>0
			begin	-- 4.1b
				select @prev_dest=''
				--	Get the 1st destination from the tmp table
				set rowcount 1
				select	@dest=destination,
					@orderno=order_no
				from	#tmp_dest
				--	process for all the locations
				while @@rowcount > 0
				begin	-- 4.2b
					set rowcount 0 
					select	@customer=isnull(customer,''),
						@stdpack =isnull(standard_pack,0),
						@orderno=order_no
					from	order_header
					where	destination=@dest and order_no=@orderno
					set rowcount 0 
					--	append all the locations for that part from part location table
					insert	#tmp_partloc (location,days_onhand,min_onhand,max_onhand)
					select	location,days_onhand,minimum,maximum
					from	part_location
					where	part_location.part=@part and
						part_location.destination=@dest
					order by location 
					--	check whether the tmp table is populated or not 
					if @@rowcount>0
					begin	-- 5b
						select @prev_locn=''
						--	Get the 1st location from the tmp table
						set rowcount 1
						select	@location=location,
							@mindaysonhand=isnull(days_onhand,0),
							@min_onhand=isnull(min_onhand,0),
							@max_onhand=isnull(max_onhand,0)
						from	#tmp_partloc
						--	Process for all the locations
						while @@rowcount > 0
						begin	-- 6b
							--	Get onhand quantity from object table
							select	@onhand=isnull(sum(quantity),0)
							from	object
							where	part=@part and location=@location
							--	Get the demand quantity from order_detail table
							if @mindaysonhand>0
							begin	-- 6.1b
								select	@dmdqty=isnull(sum(quantity),0)
								from	order_detail,order_header
								where	order_header.blanket_part=@part and order_header.destination=@dest and
									order_header.order_no = order_detail.order_no and   
									order_detail.due_date <= dateadd(dd, isnull(@mindaysonhand,0), @due_date)
							end	-- 6.1b
							else
							begin	-- 6.2b
								if @onhand<@min_onhand    
									select @dmdqty=@max_onhand
								else
									select @dmdqty=@min_onhand
							end	-- 6.2b
							--	check dmd qty vs onhand
							if @dmdqty > @onhand
							begin	-- 6.3b
								select @new_qty= @dmdqty - @onhand
								--	Check whether work order quantity is greater than 0 & then proceed
								--	Get the work order quantity
								select	@new_qty_sum= isnull(sum(isnull(qty_required,0) -  isnull(qty_completed,0)),0)
								from	workorder_detail
								where	part = @part
								--	Check whether the summed quantity is less than the max onhand             
								if @new_qty_sum < @new_qty
								begin	-- 6.4b 
									--	Compute the new quantity for the work order to be created
									select @new_qty= (@new_qty - @new_qty_sum)  
									--	Check whether work order quantity is greater than 0 & then proceed
									if @new_qty > 0
									begin 	-- 6.5b
										set rowcount 1
										--	Get part details from part_mfg
										select	@process_id=isnull(part_mfg.process_id,'none'),
											@cycle_time=isnull(part_mfg.cycle_time,1),
											@cycle_unit=part_mfg.cycle_unit,
											@parts_per_hour=isnull(part_mfg.parts_per_hour,1),
											@parts_per_cycle=isnull(part_mfg.parts_per_cycle,1),
											@setup_time = isnull(part_mfg.setup_time,0),     
											@runtime = @new_qty * isnull((1 / part_mfg.parts_per_hour),0),
											@machine_no=part_machine.machine
										from	part_mfg,part_machine
										where 	part_mfg.part=@part and part_machine.part=@part
										
										--	Get end date & time 
										select	@enddate= @due_date,
											@endtime= @due_date      
										
										--	Include setup time with runtime is if it is set to y in parameter table
										if @include_set_up = 'Y'
											select	@runtime = @runtime + isnull(@setup_time,0)
										--	If the machine no is null get it from part_inventory table 
										if @machine_no is null
											select	@machine_no=primary_location
											from	part_inventory
											where	part=@part
										--	get next work order number from parameters table
										select	@work_order=convert(varchar,next_workorder)
										from	parameters
										select	@note='Auto generated work order & standard pack qty for the part '+@part+': '+ltrim(convert(varchar(16),@stdpack))
										set rowcount 0 
										--	Insert data into work order header                  
										insert 
										into	work_order 
											(work_order,machine_no,sequence,due_date,process_id,setup_time, 
											cycle_time,start_date,start_time,end_date,end_time,runtime,cycle_unit,
											note,order_no,destination,customer)    
										values	(@work_order,@machine_no,9999,@due_date,@process_id,@setup_time,
											@cycle_time,@due_date,@due_date,@enddate,@endtime,@runtime,@cycle_unit,
											@note,@orderno,@dest,@customer) 
										--	Insert data into work order detail
										insert 
										into	workorder_detail
											(workorder,part,qty_required,qty_completed,parts_per_cycle,run_time,
											balance,parts_per_hour) 
										values	(@work_order,@part,@new_qty,0,@parts_per_cycle,@runtime,@new_qty,
											@parts_per_hour)
										--	Get next work order number
										update parameters set next_workorder=convert(numeric,@work_order) + 1
									end	-- 6.5b
								end	-- 6.4b
							end	-- 6.3b
							select	@prev_locn=@location
							--	Delete the current location from the temp table
							set rowcount 0 
							delete 
							from	#tmp_partloc
							where	location=@location
							--	Get the 1st location from the tmp table
							set rowcount 1
							select	@location=location,
								@mindaysonhand=isnull(days_onhand,0),
								@min_onhand=isnull(min_onhand,0),
								@max_onhand=isnull(max_onhand,0)
							from	#tmp_partloc
						end	-- 6b
					end	-- 5b
					select	@prev_dest=@dest
					--	Delete the current location from the temp table
					set rowcount 0 
					delete 
					from	#tmp_dest
					where	destination=@dest
					--	Get the next dest from the tmp table
					set rowcount 1
					select	@dest=destination,
						@orderno=order_no
					from	#tmp_dest
				end	-- 4.2b
			end	-- 4.1b 
			else
			begin	-- 9b
				-- 	Get onhand quantity from object table for that part
				select	@onhand=isnull(sum(quantity),0)
				from	object
				where	part=@part and status='A'
				if @onhand <= @min_onhand -- if onhand quantity is less than the minimum onhand then proceed
				begin	-- 10b
					--	Compute the new quantity for the work order/po to be created
					select	@new_qty= @max_onhand - @onhand
					-- get the work order quantity
					select	@new_qty_sum= isnull(sum(isnull(qty_required,0) -  isnull(qty_completed,0)),0)
					from	workorder_detail
					where	part = @part
					--	Check whether the summed quantity is less than the max onhand             
					if @new_qty_sum < @max_onhand
					begin	-- 11b 
						--	Compute the new quantity for the work order to be created
						select @new_qty= @new_qty - @new_qty_sum
					
						--	Check whether work order quantity is greater than 0 & then proceed
						if @new_qty > 0
						begin	-- 12b
							set rowcount 1 
							--	Get part details from part_mfg
							select	@process_id=isnull(part_mfg.process_id,'none'),
								@cycle_time=isnull(part_mfg.cycle_time,1),
								@cycle_unit=part_mfg.cycle_unit,
								@parts_per_hour=isnull(part_mfg.parts_per_hour,1),
								@parts_per_cycle=isnull(part_mfg.parts_per_cycle,1),
								@setup_time = isnull(part_mfg.setup_time,0), 
								@runtime = @new_qty * isnull((1 / part_mfg.parts_per_hour),0),
								@machine_no=part_machine.machine
							from	part_mfg,part_machine
							where	part_mfg.part=@part and part_machine.part=@part
							
							--	Get end date & time 
							select	@enddate= @due_date,
								@endtime= @due_date 
							-- include setup time with runtime is if it is set to y in parameter table
							if @include_set_up = 'Y'
								select	@runtime = @runtime + isnull(@setup_time,0)
							-- if the machine no is null get it from part_inventory table 
							if @machine_no is null
								select	@machine_no=primary_location
								from	part_inventory
								where	part=@part
							--	Get next work order number from parameters table
							select	@work_order=convert(varchar,next_workorder)
							from	parameters
							set rowcount 0
							--	Insert data into work order header 
							insert 
							into	work_order 
								(work_order,machine_no,sequence,due_date,process_id,setup_time, 
								cycle_time,start_date,start_time,end_date,end_time,runtime,cycle_unit,
								note,order_no,destination,customer)    
							values	(@work_order,@machine_no,9999,@due_date,@process_id,@setup_time,
								@cycle_time,@due_date,@due_date,@enddate,@endtime,@runtime,@cycle_unit,
								'Auto generated work order',0,'','') 
							--	Insert data into work order detail
							insert 
							into	workorder_detail
								(workorder,part,qty_required,qty_completed,parts_per_cycle,run_time,
								balance,parts_per_hour) 
							values	(@work_order,@part,@new_qty,0,@parts_per_cycle,@runtime,@new_qty,@parts_per_hour)
							--	Get next work order number
							update parameters set next_workorder=convert(numeric,@work_order)+1
						end	-- 12b
					end	-- 11b
				end	-- 10b
			end	-- 9b
		end	-- 4b 
		else	-- if it's a manufactured wip or raw part
		begin	-- 9b
			-- 	Get onhand quantity from object table for that part
			select	@onhand=isnull(sum(quantity),0)
			from	object
			where	part=@part and status='A'
			if @onhand <= @min_onhand -- if onhand quantity is less than the minimum onhand then proceed
			begin	-- 10b
				--	Compute the new quantity for the work order/po to be created
				select	@new_qty= @max_onhand - @onhand
				-- get the work order quantity
				select	@new_qty_sum= isnull(sum(isnull(qty_required,0) -  isnull(qty_completed,0)),0)
				from	workorder_detail
				where	part = @part
				--	Check whether the summed quantity is less than the max onhand             
				if @new_qty_sum < @max_onhand
				begin	-- 11b 
					--	Compute the new quantity for the work order to be created
					select @new_qty= @new_qty - @new_qty_sum
				
					--	Check whether work order quantity is greater than 0 & then proceed
					if @new_qty > 0
					begin	-- 12b
						set rowcount 1 
						--	Get part details from part_mfg
						select	@process_id=isnull(part_mfg.process_id,'none'),
							@cycle_time=isnull(part_mfg.cycle_time,1),
							@cycle_unit=part_mfg.cycle_unit,
							@parts_per_hour=isnull(part_mfg.parts_per_hour,1),
							@parts_per_cycle=isnull(part_mfg.parts_per_cycle,1),
							@setup_time = isnull(part_mfg.setup_time,0), 
							@runtime = @new_qty * isnull((1 / part_mfg.parts_per_hour),0),
							@machine_no=part_machine.machine
						from	part_mfg,part_machine
						where	part_mfg.part=@part and part_machine.part=@part
						
						--	Get end date & time 
						select	@enddate= @due_date,
							@endtime= @due_date 
						-- include setup time with runtime is if it is set to y in parameter table
						if @include_set_up = 'Y'
							select	@runtime = @runtime + isnull(@setup_time,0)
						-- if the machine no is null get it from part_inventory table 
						if @machine_no is null
							select	@machine_no=primary_location
							from	part_inventory
							where	part=@part
						--	Get next work order number from parameters table
						select	@work_order=convert(varchar,next_workorder)
						from	parameters
						set rowcount 0
						--	Insert data into work order header 
						insert 
						into	work_order 
							(work_order,machine_no,sequence,due_date,process_id,setup_time, 
							cycle_time,start_date,start_time,end_date,end_time,runtime,cycle_unit,
							note,order_no,destination,customer)    
						values	(@work_order,@machine_no,9999,@due_date,@process_id,@setup_time,
							@cycle_time,@due_date,@due_date,@enddate,@endtime,@runtime,@cycle_unit,
							'Auto generated work order',0,'','') 
						--	Insert data into work order detail
						insert 
						into	workorder_detail
							(workorder,part,qty_required,qty_completed,parts_per_cycle,run_time,
							balance,parts_per_hour) 
						values	(@work_order,@part,@new_qty,0,@parts_per_cycle,@runtime,@new_qty,@parts_per_hour)
						--	Get next work order number
						update parameters set next_workorder=convert(numeric,@work_order)+1
					end	-- 12b
				end	-- 11b
			end	-- 10b
		end	-- 9b
	end	-- 3b 
	else if (@part_class='P')    -- if it's a purchased part        
	begin	-- 13b
		--	Get onhand quantity from object table for that part
		select	@onhand=isnull(sum(quantity),0)
		from	object
		where	part=@part and status='A'
		
		if @onhand <= @min_onhand -- if onhand quantity is less than the minimum onhand then proceed
		begin	-- 14b
			--	Compute the new quantity for the work order/po to be created
			select	@new_qty= @max_onhand - @onhand
			--	Check whether the vendor has been specified for that part 
			if @vendor is not null
			begin	-- 15b
				--	Check whether the vendor is a trusted vendor or not 
				select	@kanban=kanban
				from	vendor
				where	code=@vendor
				-- if vendor is a trusted vendor then proceed with the creation of po
				if @kanban='Y'
				begin	-- 16b
					if @po_number is null
					begin	-- 16.1b
						--	Get po number from po header table for that vendor
						set rowcount 1 
						select	@po_number=po_number
						from	po_header
						where	vendor_code=@vendor and status='A'
					end	-- 16.1b
					--	If a valid po exist for that vendor
					if @po_number > 0
					begin	-- 16.2b
						set rowcount 0 
						--	Get the po quantity from existing releases
						select	@new_qty_sum= isnull(sum(isnull(balance,0)),0)
						from	po_detail
						where	po_detail.part_number = @part and po_detail.po_number=@po_number and
							isnull(po_detail.deleted,'N')<>'Y'
						--	Check whether the summed quantity is less than the max onhand             
						if @new_qty_sum < @max_onhand
						begin -- 16.3b 
							--	Compute the new quantity for the po to be created
							select	@new_qty= (@new_qty - @new_qty_sum)  
							--	Check whether work order quantity is greater than 0 & then proceed
							if @new_qty > 0
							begin	-- 16.4b
								--	Get details from po_header
								select	@release_no=release_no,
									@ship_to_dest=ship_to_destination,
									@terms = terms,
									@plant = plant,
									@ship_type=ship_type,
									@ship_via=ship_via,
									@status = status
								from	po_header
								where	po_header.po_number=@po_number
								--	Get details from part_vendor & part_vendor_price_matrix                    
								select	@standard_qty=isnull(vendor_standard_pack,0),
									@leaddays = isnull(lead_time,0), 
									@price = isnull(price,0)
								from	part_vendor,part_vendor_price_matrix
								where	part_vendor.part=@part and part_vendor.vendor=@vendor and 
									part_vendor_price_matrix.part=@part and 
									part_vendor_price_matrix.vendor=@vendor
								--	Rowid for that new row being created 
								select	@rowid=isnull(max(row_id),0) + 1
								from	po_detail 
								where	po_number=@po_number
		
								--	Get part details from part,part_purchasing table 
								select	@desc=part.name,
									@uom =part_inventory.standard_unit,
									@crp =part.cross_ref,
									@account_code=part_purchasing.gl_account_code
								from	part,part_purchasing,part_inventory
								where	part.part=@part and
									part_purchasing.part=@part and
									part_inventory.part=@part
								--	Get the no. of days from the fiscal year begin
								select	@idays = datepart(dd,@dfiscalyearbegin)
								--	calculate the week number
								select	@iweek = ((datediff(dd,@dfiscalyearbegin, dateadd(dd, isnull(@leaddays,0), 
										@due_date)) + @idays) / 7) + 1
								--	insert row into po detail 
								insert 
								into	po_detail
									(po_number,part_number,date_due,row_id,vendor_code,description,
									unit_of_measure,status,cross_reference_part,account_code,notes,
									quantity,received,balance,release_no,ship_to_destination,terms,week_no,
									plant,standard_qty,ship_type,printed,ship_via, alternate_price)        
								values	(@po_number,@part, dateadd(dd, isnull(@leaddays,0), @due_date),@rowid,
									@vendor,@desc,@uom,@status,@crp,@account_code,'auto generated release',
									@new_qty,0,@new_qty,@release_no,@ship_to_dest,@terms,@iweek,@plant,
									@new_qty,@ship_type,'N',@ship_via, @price) 
						
							end	-- 16.4b
						end	-- 16.3b
					end	-- 16.2b
				end	-- 16b
			end	-- 15b
		end	-- 14b 
	end	-- 13b
	--	Update the master_prod_sched table qty_assigned column with this quantity ???
	--	Assign the current part to the previous part variable
	select	@prev_part=@part  
	-- get the next part for processing from the part table.
	set rowcount 1
	select	@part=part.part,
		@part_type=part.type,
		@part_class=part.class,
		@desc=part.name,
		@crp=part.cross_ref,
		@uom=part_inventory.standard_unit,
		@onhand=isnull(part_online.on_hand,0),
		@min_onhand=isnull(part_online.min_onhand,0),
		@max_onhand=isnull(part_online.max_onhand,0),
		@vendor=part_online.default_vendor,
		@po_number=part_online.default_po_number  
	from	part,part_inventory,part_online
	where	part.part > @prev_part and
		part_inventory.part=part.part and
		part_online.part=part.part
	order by part.part
end	-- 2b
if @requisition ='Y'
begin
	set rowcount 0 
	execute msp_create_requisitionrel
end 	
commit transaction
--	Added this procedure call, so that, it recalc runtime for that machine 
--	and re-sequences work orders on that machine
execute msp_recalc_tasks
set rowcount 0 
go


print'
-----------------------------------------
-- procedure:	msp_customer_price_matrix
-----------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_customer_price_matrix'))
	drop procedure msp_customer_price_matrix
GO

CREATE PROCEDURE msp_customer_price_matrix ( @part varchar (25), @customer varchar (25) ) AS

SELECT 	0.000000, 
	0.000000 
FROM	parameters 
UNION ALL  
SELECT 	qty_break,   
     	price  
FROM 	part_customer_price_matrix 
WHERE 	part = @part AND
	customer = @customer

GO


print'
--------------------------------------------
-- procedure:	msp_customer_price_matrix_no
--------------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_customer_price_matrix_no'))
        drop procedure msp_customer_price_matrix_no
GO

create procedure msp_customer_price_matrix_no (  @part varchar (25), @customer varchar (25), @display_currency varchar (10) )
as
begin
select  part_customer_price_matrix.part, 
        part_customer_price_matrix.customer, 
        part_customer_price_matrix.qty_break, 
        (       part_customer_price_matrix.alternate_price * isnull(( 
                select  rate 
                from            currency_conversion  
                where   effective_date = (      select  max (effective_date) 
                                                from    currency_conversion cc 
                                                where   effective_date < GetDate ( ) and 
                                        currency_code = customer.default_currency_unit ) and 
                                        currency_code = customer.default_currency_unit ),1) / isnull(( 
                select  rate 
                from            currency_conversion  
                where   effective_date = (      select  max (effective_date) 
                                                from    currency_conversion cc 
                                                where   effective_date < GetDate ( ) and 
                                                        currency_code = @display_currency ) and 
                                                        currency_code = @display_currency ),1)) as price,
        part_inventory.standard_unit,
        customer.default_currency_unit  
        from    part_customer_price_matrix, 
                part_inventory,
                customer 
        where   part_customer_price_matrix.customer = @customer and 
                part_customer_price_matrix.part = @part and 
                part_customer_price_matrix.part = part_inventory.part and
                customer.customer = @customer
end

GO


print'
-------------------------------
-- procedure:	msp_fp_list_sub
-------------------------------
'
if exists(select * from dbo.sysobjects where name='msp_fp_list_sub' and type = 'P')
   drop procedure msp_fp_list_sub
go
create procedure msp_fp_list_sub (@childpart varchar(25)) as
begin -- (1b)
  declare @currentchildpart varchar(25),
          @parttype varchar(1),
          @partclass varchar(1)
  create table #bom_temp (parent_part varchar(25) not null)
  begin transaction -- (2b)
  set rowcount 0 
  insert into partlist (part)
  select parent_part from bill_of_material where part=@childpart

/*  insert into #bom_temp (parent_part)
  select parent_part from bill_of_material where part=@childpart
  if (@@rowcount > 0) 
  begin -- (3b)
    set rowcount 1
    select @currentchildpart=parent_part
      from #bom_temp
    while (@@rowcount > 0)    
    begin -- (4b)
      set rowcount 0 
      select @partclass=class,
             @parttype=type
        from part
       where (part=@currentchildpart)
      if (@partclass='M' and @parttype='F')
         insert into partlist values(@currentchildpart)
      set rowcount 0  
      exec msp_fp_list_sub @currentchildpart
      set rowcount 0
      delete 
        from #bom_temp  
       where parent_part=@currentchildpart
      set rowcount 1
      select @currentchildpart=parent_part
        from #bom_temp
     end -- (4e)
  end -- (3e)  
*/
  commit transaction -- (2e)
  drop table #bom_temp
end -- (1e)
go 


print'
--------------------------------
-- procedure:	msp_fp_list_main
--------------------------------
'
if exists(select * from dbo.sysobjects where name='msp_fp_list_main' and type = 'P')
   drop procedure msp_fp_list_main
go
create procedure msp_fp_list_main (@childpart varchar(25)) as
begin -- (1b)
  begin transaction -- (2b)
  delete 
    from partlist
  exec msp_fp_list_sub @childpart
  commit transaction -- (2e)
  set rowcount 0 	
  select part from partlist
end -- (1e)
go 



print'
-----------------------------------
-- PROCEDURE:	msp_generate_kanban
-----------------------------------
'
IF	Exists	(
	SELECT	*
	  FROM	sysobjects
	WHERE	id = Object_id ( 'msp_generate_kanban' ) )
	DROP PROCEDURE msp_generate_kanban
GO

CREATE PROCEDURE msp_generate_kanban
(	@orderno	decimal (8) )
AS
---------------------------------------------------------------------------------------
-- 	This procedure generates kanban table information from data stored in order header
--	Modified:	12 Mar 1999, Eric E. Stimpson
--	Paramters:	@orderno		mandatory
--	Returns:	0				success
--				-1				error, invalid begin or end kanban number for order
---------------------------------------------------------------------------------------

--	Declarations.
DECLARE	@beginkanban	varchar (6),
		@endkanban	varchar (6),
		@rootindex	integer,
		@root		varchar (5),
		@suffix1	char (6),
		@suffix2	char (6),
		@begin		integer,
		@end		integer,
		@count		integer


--	Get beginning and ending kanban numbers from order.
SELECT	@beginkanban = begin_kanban_number,
		@endkanban = end_kanban_number
  FROM	order_header
 WHERE	order_no = @orderno

--	Find the common alpha numeric root index (position) between beginning and ending kanban numbers.
SELECT	@rootindex =
		( CASE	
			WHEN	Substring ( @beginkanban, 1, 1 ) = Substring ( @endkanban, 1, 1 ) THEN
			( CASE
				WHEN	Substring ( @beginkanban, 2, 1 ) = Substring ( @endkanban, 2, 1 ) THEN
				( CASE
					WHEN	Substring ( @beginkanban, 3, 1 ) = Substring ( @endkanban, 3, 1 ) THEN
					( CASE
						WHEN	Substring ( @beginkanban, 4, 1 ) = Substring ( @endkanban, 4, 1 ) THEN
						( CASE
							WHEN	Substring ( @beginkanban, 5, 1 ) = Substring ( @endkanban, 5, 1 ) THEN 5
							ELSE	4
						END )
						ELSE	3
					END )
					ELSE	2
				END )
				ELSE	1
			END )
			ELSE	0
		END )

--	Calculate the root and suffixes from the root index.
SELECT	@root = Substring ( @beginkanban, 1, @rootindex ),
		@suffix1 = Right ( '000000' + Substring ( @beginkanban, @rootindex + 1, 6 ), 6 ),
		@suffix2 = Right ( '000000' + Substring ( @endkanban, @rootindex + 1, 6 ), 6 )

--	If suffixes are numeric, calculate the beginning and ending counters.
IF	@suffix1 LIKE '[0-9][0-9][0-9][0-9][0-9][0-9]' AND
	@suffix2 LIKE '[0-9][0-9][0-9][0-9][0-9][0-9]' AND
	@root IS NOT NULL
	SELECT	@begin = Convert ( integer, @suffix1 ),
			@end = Convert ( integer, @suffix2 ),
			@count = Convert ( integer, @suffix1 )

--	If kanban numbers are valid, generate kanban table data.
IF	@end >= @begin
	WHILE @count <= @end
	BEGIN
		BEGIN TRANSACTION
		INSERT	kanban
		SELECT	Substring ( @root + Right ( '00000' + Convert ( varchar (6), @count ), DataLength ( @beginkanban ) - DataLength ( @root ) ), 1, DataLength ( @beginkanban ) ) kanban,
				@orderno,
				line11,
				line12,
				line13,
				line14,
				line15,
				line16,
				line17,
				'A' status,
				standard_pack
		  FROM	order_header
		 WHERE	order_no = @orderno AND
				Substring ( @root + Right ( '00000' + Convert ( varchar (6), @count ), DataLength ( @beginkanban ) - DataLength ( @root ) ), 1, DataLength ( @beginkanban ) ) NOT IN
				(	SELECT	kanban_number
					  FROM	kanban
					 where	order_no = @orderno )
		SELECT	@count = @count + 1
		COMMIT TRANSACTION
	END

--	Otherwise return error code.
ELSE
	Return -1

--	Indicate success.
Return 0
GO


print '
---------------------------------------
-- PROCEDURE:	msp_get_1050_compl_data
---------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_get_1050_compl_data'))
	drop procedure msp_get_1050_compl_data
GO

CREATE PROCEDURE msp_get_1050_compl_data
	(	@a_s_machine	varchar ( 10 ),
		@a_s_part	varchar ( 25 ) = null )
AS
DECLARE	@l_s_wo_number		varchar ( 10 ),
	@l_f_std_pack		float,
	@l_f_parts_per_cycle	float,
	@l_f_cyc_tot		float,
	@l_f_qty_comp		float,
	@l_f_qty_req		float,
	@l_f_defects		float,
	@l_f_box_req		float,
	@l_f_box_per_sqr	float
CREATE TABLE #part_list
(	part		varchar ( 25 ) )
CREATE TABLE #result_out_header
(
	wo_number	varchar (10) null,
	machine_count	integer	null)
CREATE TABLE #result_out_detail
(	part		varchar ( 25 ),
	box_per_square	float,
	required	float,
	cycles		float	null,
	complete	float	null,
	defects		float	null )
/* Get the work order from work_order :: @l_s_wo_number */
SELECT	@l_s_wo_number = work_order
  FROM	work_order
 WHERE	machine_no = @a_s_machine AND
	sequence = 1
/* Get the current counter count from machine_data_1050 :: @l_f_cyc_tot */
SELECT	@l_f_cyc_tot = counter
  FROM	machine_data_1050
 WHERE	machine = @a_s_machine
/* Write header info */
INSERT	#result_out_header
	SELECT	@l_s_wo_number,
		IsNull ( @l_f_cyc_tot, 0 )
/* Build part list */
IF @a_s_part IS NULL
	INSERT	#part_list
		SELECT	part
		  FROM	workorder_detail
		 WHERE	workorder = @l_s_wo_number
ELSE
	INSERT	#part_list
		SELECT	part
		  FROM	workorder_detail
		 WHERE	workorder = @l_s_wo_number AND
			part = @a_s_part
/* Loop through part list */
SELECT	@a_s_part = NULL
SELECT	@a_s_part = Min ( part )
  FROM	#part_list
WHILE @a_s_part > ''
BEGIN
/* Get the total required qty from workorder_detail :: @l_f_qty_req */
	SELECT	@l_f_qty_req = Sum ( qty_required )
	  FROM	workorder_detail
	 WHERE	part = @a_s_part AND
		workorder = @l_s_wo_number
/* Get the total completed qty from workorder_detail :: @l_f_qty_comp */
	SELECT	@l_f_qty_comp = Sum ( qty_completed )
	  FROM	workorder_detail
	 WHERE	part = @a_s_part AND
		workorder = @l_s_wo_number
/* Get the total number of defects from defects :: @l_f_defects */
	SELECT	@l_f_defects = IsNull ( Sum ( defects.quantity ), 0 )
	  FROM	defects
	 WHERE	part = @a_s_part AND
		work_order = @l_s_wo_number
/* Get the number of parts per cycle from part_mfg :: @l_f_parts_per_cycle */
	SELECT	@l_f_parts_per_cycle = parts_per_cycle
	  FROM	part_mfg
	 WHERE	part = @a_s_part
	IF IsNull ( @l_f_parts_per_cycle, 0 ) = 0
		SELECT @l_f_parts_per_cycle = 1
/* Get the standard pack (parts per box) from part_packaging :: @l_f_std_pack */
	SELECT	@l_f_std_pack = Min ( quantity )
	  FROM	part_packaging
	 WHERE	part = @a_s_part
	IF IsNull ( @l_f_std_pack, 0 ) = 0
		SELECT @l_f_std_pack = 1
/* Calculate the number of boxes required by dividing @l_f_qty_req by @l_f_std_pack and rounding up :: @l_f_box_req */
	SELECT	@l_f_box_req = @l_f_qty_req / @l_f_std_pack
/* Calculate the boxes per square from @l_f_box_req and @l_f_defects :: @l_f_box_per_sqr */
	SELECT	@l_f_box_per_sqr = Power ( Convert ( float, 10 ), Ceiling ( LOG10 ( @l_f_box_req + ( @l_f_defects / @l_f_std_pack ) ) ) )
/*	SELECT	@l_s_wo_number wo_number,
		@l_f_std_pack std_pack,
		@l_f_parts_per_cycle ppc,
		@l_f_cyc_tot cyc_tot,
		@l_f_qty_comp qty_comp,
		@l_f_qty_req qty_req,
		@l_f_defects def,
		@l_f_box_req box_req,
		@l_f_box_per_sqr box_per_sqr*/
	INSERT #result_out_detail
	(	part,
		box_per_square,
		required,
		cycles,
		complete,
		defects )
		SELECT	@a_s_part,
			IsNull ( @l_f_box_per_sqr / 10, 0 ),
			IsNull ( @l_f_box_req / @l_f_box_per_sqr, 0 ),
			IsNull ( @l_f_cyc_tot * @l_f_parts_per_cycle / ( @l_f_std_pack * @l_f_box_per_sqr ), 0 ),
			IsNull ( @l_f_qty_comp / ( @l_f_std_pack * @l_f_box_per_sqr ), 0 ),
			IsNull ( @l_f_defects / ( @l_f_std_pack * @l_f_box_per_sqr ), 0 )
	DELETE	#part_list
	 WHERE	part = @a_s_part
	SELECT	@a_s_part = NULL
	SELECT	@a_s_part = Min ( part )
	  FROM	#part_list
END
SELECT	*
  FROM	#result_out_header,
	#result_out_detail


GO


print '
-------------------------------------
-- PROCEDURE:	msp_get_1050_iss_data
-------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_get_1050_iss_data'))
	drop procedure msp_get_1050_iss_data
GO

CREATE PROCEDURE msp_get_1050_iss_data
	(	@a_s_machine	varchar ( 10 ),
		@a_s_parent	varchar ( 25 ) = null,
		@a_s_part	varchar ( 25 ) = null )
AS
DECLARE	@l_s_wo_number		varchar ( 10 ),
	@l_f_std_pack		float,
	@l_f_parts_per_cycle	float,
	@l_f_cyc_tot		float,
	@l_f_qty_iss		float,
	@l_f_qty_req		float,
	@l_f_qty_avail		float,
	@l_f_qty_plant		float,
	@l_f_qty_unavail	float,
	@l_f_box_req		float,
	@l_f_box_per_sqr	float,
	@l_f_factor		float
CREATE TABLE #part_list
(	part		varchar ( 25 ) )
CREATE TABLE #result_out_header
(
	wo_number	varchar (10) null,
	machine_count	integer	null)
CREATE TABLE #result_out_detail
(	part		varchar ( 25 ),
	box_per_square	float,
	required	float,
	cycles		float	null,
	issue		float	null,
	available	float	null,
	avail_plant	float	null,
	unavailable	float	null )
/* Get the work order from work_order :: @l_s_wo_number */
SELECT	@l_s_wo_number = work_order
  FROM	work_order
 WHERE	machine_no = @a_s_machine AND
	sequence = 1
/* Get the current counter count from machine_data_1050 :: @l_f_cyc_tot */
SELECT	@l_f_cyc_tot = counter
  FROM	machine_data_1050
 WHERE	machine = @a_s_machine
/* Write header info */
INSERT	#result_out_header
	SELECT	@l_s_wo_number,
		IsNull ( @l_f_cyc_tot, 0 )
/* Build part list */
IF @a_s_parent IS NULL
	SELECT	@a_s_parent = Min ( part )
	  FROM	workorder_detail
	 WHERE	workorder = @l_s_wo_number
IF @a_s_part IS NULL
	INSERT	#part_list
		SELECT	part
		  FROM	bill_of_material
		 WHERE	parent_part = @a_s_parent
ELSE
	INSERT	#part_list
		SELECT	part
		  FROM	bill_of_material
		 WHERE	parent_part = @a_s_parent AND
			part = @a_s_part
/* Loop through part list */
SELECT	@a_s_part = NULL
SELECT	@a_s_part = Min ( part )
  FROM	#part_list
WHILE @a_s_part > ''
BEGIN
/* Get the bill factor from bill_of_material :: @l_f_factor */
	SELECT	@l_f_factor = IsNull ( quantity, 0 )
	  FROM	bill_of_material
	 WHERE	parent_part = @a_s_parent AND
		part = @a_s_part
/* Get the total required qty from workorder_detail :: @l_f_qty_req */
	SELECT	@l_f_qty_req = Sum ( qty_required ) * @l_f_factor
	  FROM	workorder_detail
	 WHERE	part = @a_s_parent AND
		workorder = @l_s_wo_number
/* Get the total issued qty from audit_trail :: @l_f_qty_iss */
	SELECT	@l_f_qty_iss = IsNull ( Sum ( std_quantity ), 0 )
	  FROM	audit_trail
	 WHERE	part = @a_s_part AND
		workorder = @l_s_wo_number AND
		type = 'M'
/* Get the total available quantity at current location :: @l_f_qty_avail */
	SELECT	@l_f_qty_avail = IsNull ( Sum ( std_quantity ), 0 )
	  FROM	object
	 WHERE	part = @a_s_part AND
		location = @a_s_machine AND
		status = 'A'
/* Get the total available quantity in plant :: @l_f_qty_plant */
	SELECT	@l_f_qty_plant = IsNull ( Sum ( std_quantity ), 0 )
	  FROM	object
	 WHERE	part = @a_s_part AND
		location <> @a_s_machine AND
		status = 'A'
/* Get the total unavailable quantity in plant :: @l_f_qty_unavail */
	SELECT	@l_f_qty_unavail = IsNull ( Sum ( std_quantity ), 0 )
	  FROM	object
	 WHERE	part = @a_s_part AND
		status <> 'A'
/* Get the number of parts per cycle from part_mfg :: @l_f_parts_per_cycle */
	SELECT	@l_f_parts_per_cycle = parts_per_cycle
	  FROM	part_mfg
	 WHERE	part = @a_s_parent
	IF IsNull ( @l_f_parts_per_cycle, 0 ) = 0
		SELECT @l_f_parts_per_cycle = 1
/* Get the standard pack (parts per box) from part_packaging :: @l_f_std_pack */
	SELECT	@l_f_std_pack = Min ( quantity )
	  FROM	part_packaging
	 WHERE	part = @a_s_part
	IF IsNull ( @l_f_std_pack, 0 ) = 0
		SELECT @l_f_std_pack = 1
/* Calculate the number of boxes required by dividing @l_f_qty_req by @l_f_std_pack and rounding up :: @l_f_box_req */
	SELECT	@l_f_box_req = @l_f_qty_req / @l_f_std_pack
/* Calculate the boxes per square from @l_f_box_req and @l_f_defects :: @l_f_box_per_sqr */
	SELECT	@l_f_box_per_sqr = Power ( Convert ( float, 10 ), Ceiling ( LOG10 ( @l_f_box_req ) ) )
/*	SELECT	@l_s_wo_number wo_number,
		@l_f_std_pack std_pack,
		@l_f_parts_per_cycle ppc,
		@l_f_cyc_tot cyc_tot,
		@l_f_qty_iss qty_iss,
		@l_f_qty_req qty_req,
		@l_f_qty_avail available,
		@l_f_qty_plant avail_plant,
		@l_f_qty_unavail unavailable,
		@l_f_box_req box_req,
		@l_f_box_per_sqr box_per_sqr,
		@l_f_factor factor*/
	INSERT #result_out_detail
	(	part,
		box_per_square,
		required,
		cycles,
		issue,
		available,
		avail_plant,
		unavailable )
		SELECT	@a_s_part,
			IsNull ( @l_f_box_per_sqr / 10, 0 ),
			IsNull ( @l_f_box_req / @l_f_box_per_sqr, 0 ),
			IsNull ( @l_f_cyc_tot * @l_f_parts_per_cycle / ( @l_f_std_pack * @l_f_box_per_sqr ), 0 ),
			IsNull ( @l_f_qty_iss / ( @l_f_std_pack * @l_f_box_per_sqr ), 0 ),
			IsNull ( @l_f_qty_avail / ( @l_f_std_pack * @l_f_box_per_sqr ), 0 ),
			IsNull ( @l_f_qty_plant / ( @l_f_std_pack * @l_f_box_per_sqr ), 0 ),
			IsNull ( @l_f_qty_unavail / ( @l_f_std_pack * @l_f_box_per_sqr ), 0 )
	DELETE	#part_list
	 WHERE	part = @a_s_part
	SELECT	@a_s_part = NULL
	SELECT	@a_s_part = Min ( part )
	  FROM	#part_list
END
SELECT	*
  FROM	#result_out_header,
	#result_out_detail


GO


print'
--------------------------------
-- PROCEDURE:	msp_get_next_bol
--------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'msp_get_next_bol' )
	DROP PROCEDURE msp_get_next_bol
go

CREATE PROCEDURE msp_get_next_bol
(	@bol	integer OUTPUT )
AS
BEGIN -- (1B)
---------------------------------------------------------------------------------------
-- 	This procedure gets the next available bill of lading number and returns it via 
--	the reference parameter @bol.
--	Modified:	22 Feb 1999, Chris Rogers
--	Paramters:	@bol	mandatory
--	Returns:	0	success
---------------------------------------------------------------------------------------

--  Get the next available bol number from parameters.
	SELECT	@bol = bol_number
	  FROM	parameters

	WHILE
	(	SELECT	parameters.bol_number
		  FROM	bill_of_lading
			cross join parameters
		 WHERE	bill_of_lading.bol_number = parameters.bol_number ) > 0
	BEGIN -- (2B)
		UPDATE	parameters
		   SET	bol_number = bol_number + 1

		SELECT	@bol = bol_number
		  FROM	parameters
	END -- (2B)

	UPDATE	parameters
	   SET	bol_number = bol_number + 1

	Return 0
END -- (1B)
go


print '
-----------------------------------
-- PROCEDURE:	msp_get_machinelist
-----------------------------------
'
if exists(select 1 from sysobjects where name='msp_get_machinelist' and type='P')
   drop procedure msp_get_machinelist
go
create procedure msp_get_machinelist (@as_filterstring varchar(25)) as
begin -- (1b)
  if @as_filterstring is null or @as_filterstring='' or @as_filterstring='All'
     select machine_no
       from machine
      where status = 'R'
     order by machine_no
  else
     select m.machine_no
       from machine as m
       join location as l on l.code=m.machine_no and l.group_no=@as_filterstring
      where m.status = 'R' 
     order by m.machine_no
end -- (1e)
go

print'
------------------------------
-- procedure:	msp_get_onhand
------------------------------
'
if exists (select * from dbo.sysobjects where id = 	object_id('msp_get_onhand') )
	drop procedure msp_get_onhand
GO

/* modified on 10/29/98 */

create procedure msp_get_onhand ( @l_s_part varchar ( 25) )
as
begin
if (select onhand_from_partonline from parameters) <> 'Y'	
	SELECT	SUM ( isnull(o.std_quantity,0) ) as onhand,   
		isnull(sd.order_no, 0) as origin,   
		SUM ( isnull(o.std_quantity,0) ) as available   
	FROM	 	object as o, shipper_detail  as sd   
	WHERE	o.shipper = sd.shipper AND 	  		
		o.part = sd.part_original AND  
		o.part = @l_s_part AND  
		o.status = 'A'    
	GROUP BY sd.order_no    
	UNION     
	SELECT	SUM ( isnull( std_quantity,0) ) as onhand,    
	 	0,   
		SUM ( isnull(std_quantity,0) ) as available     
	FROM	 object as o    
	WHERE	isnull(shipper,0) = 0 AND
		o.part = @l_s_part AND
		status = 'A' 
else
	SELECT	on_hand as onhand,   
		0  as origin,   
		on_hand as available   
	FROM	part_online
	WHERE	part = @l_s_part 
end
GO

print'
------------------------------------
-- PROCEDURE:	msp_get_next_shipper
------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'msp_get_next_shipper' )
	DROP PROCEDURE msp_get_next_shipper
go

CREATE PROCEDURE msp_get_next_shipper
(	@shipper	integer OUTPUT )
AS
BEGIN -- (1B)
---------------------------------------------------------------------------------------
-- 	This procedure gets the next available shipper and returns it via the reference
--	parameter @shipper.
--	Modified:	16 Feb 1999, Eric E. Stimpson
--	Paramters:	@shipper		mandatory
--	Returns:	0				success
---------------------------------------------------------------------------------------

--  Get the next available order number from parameters.
	SELECT	@shipper = shipper
	  FROM	parameters

	WHILE
	(	SELECT	shipper
		  FROM	shipper
				cross join parameters
		 WHERE	id = shipper ) > 0
	BEGIN -- (2B)
		UPDATE	parameters
		   SET	shipper = shipper + 1

		SELECT	@shipper = shipper
		  FROM	parameters
	END -- (2B)

	UPDATE	parameters
	   SET	shipper = shipper + 1

	Return 0
END -- (1B)
go


print'
-----------------------------------
-- PROCEDURE:	msp_get_next_serial
-----------------------------------
'
if exists (select 1 from dbo.sysobjects where name = 'msp_get_next_serial' )
	drop procedure msp_get_next_serial
GO

CREATE PROCEDURE msp_get_next_serial
(@serial integer OUTPUT )
AS
BEGIN -- (1B)
---------------------------------------------------------------------------------------
-- 	This procedure gets the next available shipper and returns it via the reference
--	parameter @shipper.
--	Modified:	26 Feb 1999, Mamatha bettagere
--	Paramters:	@shipper    mandatory
--	Returns:	0	    success
---------------------------------------------------------------------------------------
--  Get the next available order number from parameters.
	SELECT	@serial = next_serial
	  FROM	parameters

	WHILE
	( (	SELECT	serial
		  FROM	object
		 cross join parameters
		 WHERE	serial = next_serial ) > 0 OR
	(	SELECT	serial
		  FROM	audit_trail
		 cross join parameters
		 WHERE	serial = next_serial ) > 0 )
	BEGIN -- (2B)
		UPDATE	parameters
		   SET	next_serial = next_serial + 1

		SELECT	@serial = next_serial
		  FROM	parameters
	END -- (2B)

	UPDATE	parameters
	   SET	next_serial = next_serial + 1

	Return 0
END -- (1B)
GO


print'
-------------------------------
-- PROCEDURE:	msp_get_po_list
-------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_get_po_list') )
   drop procedure msp_get_po_list
go
create procedure msp_get_po_list (@vendor varchar(10)) as
begin
if isnull(@vendor,'') > '' 
	SELECT	po_number,vendor_code
	FROM	po_header
	WHERE	status = 'A' and vendor_code = @vendor
	GROUP BY vendor_code,po_number
else
	SELECT	po_number,vendor_code
	FROM	po_header
	WHERE	status = 'A'
	GROUP BY vendor_code,po_number
end
go



print '
----------------
-- msp_low_level
----------------'
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

	while @@fetch_status = 0
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
	deallocate childparts


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


print'
----------------------------
-- msp_reconcile_rma_shipper
----------------------------
'
IF Exists
(	SELECT	1
	FROM	sysobjects
	WHERE	id = object_id ( 'msp_reconcile_rma_shipper' ) )
        DROP PROCEDURE msp_reconcile_rma_shipper
GO

CREATE PROCEDURE msp_reconcile_rma_shipper
(	@rma integer )
AS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--      This procedure reconciles the qnty and standard quantity staged to a shipper,
--      sets boxes and pallets staged fields in shipper detail and
--      shipper header, and sets the status of the shipper to
--      (S)taged or (O)pen as appropriate
--
--      Modifications:
--	MB 07/12/99	Original
--	MB 09/26/99	Modified
--			Included code to update shipper detail table from object table depending on the origin,
--			suffix, shipper.
--	EES 28 APR 2000	Modified to use audit trail information.
--
--      Agruments:      @rma not null : shipper to be reconciled
--
--      Returns:        0       success
--                      -1      shipper not found
--                      -2      error, shipper was already closed
--                      -3      error, invalid part was staged to this shipper
--
--	Process:
--	I.	Declarations.
--	II.	Initialize all variables.
--	III.	Ensure shipper is valid.
--	IV.	Calculate received quantity, standard quantity, and boxes staged.
--	V.	Set boxes, pallets staged and status fields in shipper header.
--	VI.	Return.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--	I.	Declarations.
DECLARE	@status		char (1),
	@invalidpart	varchar (25),
	@boxstage	integer,
	@rma_type	varchar (1)

--	II.	Initialize all variables.
SELECT	@status = NULL,
	@invalidpart = NULL

--	III.	Ensure shipper is valid.
IF NOT Exists
(	SELECT	1
	FROM	shipper
	WHERE	id = @rma )
	Return -1

IF Exists
(	SELECT	1
	FROM 	shipper
	WHERE	id = @rma AND
		status in ( 'C', 'Z' ) )
	Return -2

--	IV.	Calculate received quantity, standard quantity, and boxes staged.
UPDATE	shipper_detail
SET	qty_packed = -
	(	SELECT	Sum ( box.quantity )
		FROM	audit_trail box
		WHERE	box.shipper = Convert ( varchar , shipper_detail.shipper ) AND
			box.type = 'U' AND
			box.origin = Convert ( varchar, shipper_detail.old_shipper ) AND
			IsNull ( box.suffix, 0 ) = IsNull ( shipper_detail.old_suffix, 0 ) AND
			box.part = shipper_Detail.part_original AND
                        box.shipper = convert(varchar,@rma) ),
	alternative_qty = -
	(	SELECT	Sum ( box.std_quantity )
		FROM	audit_trail box
		WHERE	box.shipper = Convert ( varchar , shipper_detail.shipper ) AND
			box.type = 'U' AND
			box.origin = Convert ( varchar, shipper_detail.old_shipper ) AND
			IsNull ( box.suffix, 0 ) = IsNull ( shipper_detail.old_suffix, 0 ) AND
			box.part = shipper_Detail.part_original AND
                        box.shipper = convert(varchar,@rma) ),
	boxes_staged =
	(	SELECT	Count ( 1 )
		FROM	audit_trail box
		WHERE	box.shipper = Convert ( varchar , shipper_detail.shipper ) AND
			box.type = 'U' AND
			box.origin = Convert ( varchar, shipper_detail.old_shipper ) AND
			IsNull ( box.suffix, 0 ) = IsNull ( shipper_detail.old_suffix, 0 ) AND
			box.part = shipper_Detail.part_original AND
                        box.shipper = convert(varchar,@rma) )
WHERE	shipper = @rma

--	V.	Set boxes, pallets staged and status fields in shipper header.
UPDATE	shipper
SET	staged_objs =
	(	SELECT	Count ( 1 )
		FROM	audit_trail box
		WHERE	box.type = 'U' AND
			box.object_type IS NULL AND
			box.shipper = Convert ( varchar, @rma ) ),
	staged_pallets =
	(	SELECT	Count ( 1 )
		FROM	audit_trail box
		WHERE	box.type = 'U' AND
			box.object_type = 'S' AND
			box.shipper = Convert ( varchar, @rma ) ),
	status = IsNull (
        (	SELECT	Max ( 'O' )
		FROM	shipper_detail sd
		WHERE	sd.shipper = @rma and
			alternative_qty  = 0 or qty_packed = 0  ) , 'S' )
WHERE	id = @rma

--	VI.	Return.
Return 0
GO




print'
------------------------
-- msp_reconcile_shipper
------------------------
'

if exists (
	select	1
	  from	sysobjects
	 where	id = object_id ( 'msp_reconcile_shipper' ) )
	drop procedure msp_reconcile_shipper
go

create procedure msp_reconcile_shipper
(	@shipper	integer )
as
---------------------------------------------------------------------------------------
-- 	This procedure reconciles the quantity and standard quantity staged to a shipper,
--	caculates the shipper container information, sets boxes and pallets staged
--	fields in shipper detail and shipper header, and sets the status of the shipper to
--	(S)taged or (O)pen as appropriate.
--	This procedure sets quantity original and quantity required on Outside Process,
--	Return to Vendor, and Quick Shippers.  Unused line items are removed.
--
--	Arguments:	@shipper	mandatory
--
--	Modifications:	09 FEB 1999, Eric E. Stimpson	Original
--			09 JUN 1999, Eric E. Stimpson	Modified format.
--							Added computation of quantity original and quantity required.
--							Added removal of unused line items.
--
--	Returns:	 0		success
--			-1		shipper not found
--			-2		error, shipper was already closed
--			-3		error, invalid part was staged to this shipper
--
--	Process:
--	1. Ensure shipper is not closed.
--	2. Ensure shipper exists.
--	3. Ensure no invalid parts are staged to this shipper.
--	4. Reconcile quantity and standard quantity staged to shipper.
--	5. Refresh shipper container information.
--	6. Set boxes and pallets staged fields in shipper detail and shipper header.
--	7. Set the status of the shipper to (S)taged or (O)pen.
--	8. Set quantity original and quantity required on Quick, RTV, or Outside shippers.
--	9. Remove shipper detail with no quantity required.
---------------------------------------------------------------------------------------

--	1. Ensure shipper is not closed.
if exists (
	select	1
	  from	shipper
	 where	id = @shipper and
		( type = 'C' or type = 'Z' ) )
		return -2

--	2. Ensure shipper exists.
if not exists (
	select	1
	  from	shipper
	 where	id = @shipper )
	return -1

--	3. Ensure no invalid parts are staged to this shipper.
if exists (
	select	1
	  from	object
	 where	shipper = @shipper and
		type is null and
		part not in (
		select	part_original
		  from	shipper_detail
		 where	shipper = @shipper ) )
		return -3

--	4. Reconcile quantity and standard quantity staged to shipper.
begin transaction

update	shipper_detail
   set	qty_packed =
		(select	sum ( box.quantity )
		  from	object box
		 where	shipper_detail.part_original = box.part and
			isnull ( shipper_detail.suffix, 0 ) = isnull ( box.suffix, 0 ) and
			box.type is null and
			box.shipper = @shipper ),
	alternative_qty =
		(select	sum ( box.std_quantity )
		  from	object box
		 where	shipper_detail.part_original = box.part and
				isnull ( shipper_detail.suffix, 0 ) = isnull ( box.suffix, 0 ) and
				box.type is null and
				box.shipper = @shipper ),	
	boxes_staged = 
		(select count ( 1 )
		 from object box 
		 where shipper_detail.part_original = box.part and
			isnull ( shipper_detail.suffix, 0 ) = isnull ( box.suffix, 0 ) and
			box.type is null and 
			box.shipper = @shipper )
 where	shipper = @shipper 

--	5. Refresh shipper container information.
delete	shipper_container
 where	shipper = @shipper


insert	shipper_container (
		shipper,
		container_type,
		quantity,
		weight,
		group_flag )
select	shipper,
	package_type,
	count ( 1 ),
	null,
	null
  from	object
 where	shipper = @shipper and
	package_type > ''
group by shipper,
	package_type

--	6. Set boxes and pallets staged fields in shipper detail and shipper header.
update	shipper
   set	staged_objs = (
   		select	count ( 1 )
		  from	object box
		 where	box.type is null and
				box.shipper = @shipper ),
	staged_pallets = (
		select	count ( 1 )
		  from	object pallet
		 where	pallet.type = 's' and
			pallet.shipper = @shipper )
 where	id = @shipper

--	7. Set the status of the shipper to (S)taged or (O)pen.
update	shipper
   set	status = isnull ( (
   		select	max ( 'O' )
		  from	shipper_detail sd
			left outer join order_detail od on sd.order_no = od.order_no and
				sd.part_original = od.part_number and
				isnull ( sd.suffix, 0 ) = isnull ( od.suffix, 0 )
			left outer join part_packaging pp on pp.part = sd.part_original
				and pp.code = od.packaging_type
		 where	sd.shipper = @shipper and
		 	(	(	isnull ( alternative_qty, 0 ) < qty_required and
					isnull ( pp.stage_using_weight, 'N' ) <> 'Y' ) or
				(	isnull ( gross_weight, 0 ) < qty_required and
					pp.stage_using_weight = 'Y' ) ) ), 'S' )
 where	id = @shipper

--	8. Set quantity original and quantity required on Quick, RTV, or Outside shippers.
update	shipper_detail
   set	qty_required = qty_packed,
   	qty_original = qty_packed
  from	shipper
 where	shipper = @shipper and
 	id = shipper and
 	( shipper.type = 'V' or shipper.type = 'Q' or shipper.type = 'O' )

--	9. Remove shipper detail with no quantity required.
delete	shipper_detail
 where	qty_required = 0
  
commit transaction
return 0
go




print'
---------------------------------------------------------------------------------------------------------
-- msp_reverse_rma_object
---------------------------------------------------------------------------------------------------------
'

if exists ( 
	select 1 
	from dbo.sysobjects 
	where id = object_id  ( 'msp_reverse_rma_object' )  )
	drop procedure msp_reverse_rma_object
go

create procedure msp_reverse_rma_object 
	( @serial integer, 
	  @rma integer )
as
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Msp_reverse_rma_object procedure deletes an object and its audit trail entry from the database and  reconciles 
--	rma shipper.
--	
--	Modifications :	MB 09/26/99	 Modified
--				Modified the stored procedure to accept two arguments and also included
--				Code to call msp_reconcile_rma_shipper to update shipper tables.
--
--	Arguments 	@serial integer : The Object serial that is being deleted 
--			@rma   integer : The RMA shipper number
--
--	Returns:		0 Success
--			-1 If the serial number does not exist
--
--	Process:		1.  Get the serial and origin from the audit trail record 	
--			2. Return  -1 if object is invalid
--			3. Delete object record	
--			4. Delete audit trail record
--			5. Call msp_reconcile_rma_shipper procedure to reconcile shipper table quantities
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

begin
	declare 	@audit_serial integer
	declare 	@origin varchar (25)
	
--	1. Get the serial and origin from the audit trail record 	
	select 	@audit_serial = serial, 
		@origin = origin
	from 	audit_trail
	where 	serial = @serial and
        		type = 'U'

--	2. Return  -1 if object is invalid
	if @audit_serial <= 0  or @audit_serial is null
		return -1
		
	begin transaction
	begin
	
--		3. Delete object record	
		delete from object
		where serial = @serial 

--		4. Delete audit trail record
		delete audit_trail
		where serial = @serial and type = 'U'

--		5. Call msp_reconcile_rma_shipper procedure to reconcile shipper table quantities
		execute msp_reconcile_rma_shipper @rma 

	end	

	commit transaction
	return 0
end
go





print '
-----------------------------------
-- PROCEDURE:	msp_router_treeview
-----------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_router_treeview'))
	drop procedure msp_router_treeview
GO

create procedure
msp_router_treeview(@top_part char(25),@mode smallint,@user_datetime datetime)
as
begin transaction
-- declarations
	declare @item_level integer,
		@line char(30),
		@parent_part varchar(25),
		@part varchar(25),
		@current_datetime datetime,
		@start_datetime datetime,
		@activity varchar(25),
		@item_type varchar(2),
		@substitute_part varchar(1),
		@type varchar(1),
		@label varchar(255),
		@rowcount integer,
		@temp varchar(255),
		@item_type_number smallint,
		@sequence smallint,
		@eng_level  varchar (10),
		@stack_item_id smallint,
		@parent_id smallint,
		@new_item_id smallint,
		@routertype varchar(40)
		

-- create temporary tables
	create table #stack (
		id			numeric(8,0) identity not null,
		parent_id		integer,
		parent_part		varchar(25) null,
		part			varchar(25) null,
		item_level		smallint null,
		start_datetime		datetime null,
		end_datetime		datetime null,
		substitute_part		varchar(1) null,
		type			varchar(1) null,
		spid			integer not null
	)

	create table #output_stack(
		parent_id 		smallint,
		item_id			numeric(8,0) identity not null,
		parent_item 		varchar(25) null,
		item 			varchar(25) null,
		item_level 		smallint null,
		item_type 		varchar(2) null,
		item_label 		varchar(255) null,
		activity 		varchar(25) null,
		machine 		varchar(15) null,
		parent_part 		varchar(25) null,
		part 			varchar(25) null,
		components 		smallint null,
		start_datetime 		datetime null,
		item_type_number 	smallint null,
		sequence 		smallint null
	)
	

-- get current date in the format mm/dd/yyyy hh:mm:ss
	select	@current_datetime = 
		convert(datetime,
			convert(varchar(12),GetDate())+' '+
				convert(varchar(2),
					datepart(hh,GetDate()))+':'+
						convert(varchar(2),
							datepart(mi,GetDate()))+':'+
								convert(varchar(2),
									datepart(ss,GetDate())))
-- initialize parent and item id
	select	@new_item_id = 0
		
	insert into #stack (
		parent_id,
		parent_part,
		part,
		item_level,
		start_datetime,
		end_datetime,
		substitute_part,
		type,
		spid) 
	values	(0,
		@top_part,
		@top_part,
		1,
		@current_datetime,
		@current_datetime,
		'N',
		'M',
		@@spid)
	
	select @item_level=1

	while @item_level>0
	begin
		select @activity=''
		select @parent_part=''
		select @part=''
		
		if exists(select 1 from #stack where item_level=@item_level and spid=@@spid)
		begin
			select 	@eng_level = ''
			
			select	@start_datetime=min(start_datetime)
			from	#stack
			where	item_level=@item_level
				and spid=@@spid
				
			select 	@stack_item_id = min(id)
			from	#stack
			where 	item_level=@item_level
				and start_datetime=@start_datetime
				and spid=@@spid

			select 	@parent_part=parent_part,
				@part=part,
				@substitute_part=substitute_part,
				@type=type,
				@parent_id = parent_id
			from	#stack
			where 	id = @stack_item_id and
				spid = @@spid

			select	@eng_level=engineering_level
			from 	effective_change_notice
			where	part=@part
				and effective_date=(	select	max(effective_date)
							from	effective_change_notice
							where 	part=@part
								and effective_date<=@current_datetime) 
			select	@activity=activity_router.code,
				@sequence=sequence,
				@routertype=activity_codes.flow_route_window
			from 	activity_router
					join activity_codes on activity_router.code = activity_codes.code
			where 	parent_part=@top_part
				and part=@part

			if isnull(@activity,'')>''
			begin
				if @routertype = 'w_create_flow_route_outside_version2'
				begin
					select @item_type='O1'
					select @label='Outside Process:'+@activity+' / Output:'+@part+' Eng.Level: ' + @eng_level
					select @item_type_number=10
				end
				else
				begin
					select @item_type='A1'
					select @label='Activity:'+@activity+' / Output:'+@part+' Eng.Level: ' + @eng_level
					select @item_type_number=9
				end
			end
			else
			begin
				select	@activity=activity_router.code,
					@sequence=sequence,
					@routertype=activity_codes.flow_route_window
				from 	activity_router
						join activity_codes on activity_router.code = activity_codes.code
				where 	parent_part=@parent_part
					and part=@part
					
				if isnull(@activity,'')>''
				begin
					if @routertype = 'w_create_flow_route_outside_version2'
					begin
						select @item_type='O2'
						select @label='Outside Process:'+@activity+' / Output:'+@part+' Eng.Level: ' + @eng_level
						select @item_type_number=10
					end
					else
					begin
						select @item_type='A2'
						select @label='Activity:'+@activity+' / Output:'+@part+' Eng.Level: ' + @eng_level
						select @item_type_number=9
					end
				end
				else
				begin
					select	@activity=activity_router.code,
						@sequence=sequence,
						@routertype=activity_codes.flow_route_window
					from 	activity_router
							join activity_codes on activity_router.code = activity_codes.code
					where 	parent_part=@part
						and part=@part

					if isnull(@activity,'')>''
					begin
						if @routertype = 'w_create_flow_route_outside_version2'
						begin
							select @item_type='O3'
							select @label='Outside Process:'+@activity+' / Output:'+@part+' Eng.Level: ' + @eng_level
							select @item_type_number=10
						end
						else
						begin
							select @item_type='A3'
							select @label='Activity:'+@activity+' / Output:'+@part+' Eng.Level: ' + @eng_level
							select @item_type_number=9
						end
					end
					else
					begin
						if isnull(@substitute_part,'N')='Y'
							if isnull(@type,'M')='M'
							begin
								select @item_type='SM'
								select @label='Substitute (Material):'+@part+' Eng.Level: ' + @eng_level
								select @item_type_number=7
							end
							else
							begin
								select @item_type='ST'
								select @label='Substitute (Tool):'+@part+' Eng.Level: ' + @eng_level
								select @item_type_number=8
							end
						else
							if isnull(@type,'M')='M'
							begin
								select @item_type='CM'
								select @label='Component (Material):'+@part+' Eng.Level: ' + @eng_level
								select @item_type_number=5
							end
							else
							begin
								select @item_type='CT'
								select @label='Component (Tool):'+@part+' Eng.Level: ' + @eng_level
								select @item_type_number=6
							end
							
						select @activity=''
					end
				end
			end
			
			insert into #output_stack (
				parent_id,
				parent_item,
				item,
				item_level,
				item_type,
				item_label,
				activity,
				machine,
				parent_part,
				part,
				components,
				start_datetime,
				item_type_number,
				sequence )
			values	(@parent_id,
				@parent_part,
				@part,
				@item_level,
				@item_type,
				@label,
				@activity,
				'',
				@parent_part,
				@part,
				0,
				@start_datetime,
				@item_type_number,
				@sequence)
				
			select 	@new_item_id = max(item_id)
			from	#output_stack
			
			if isnull(@activity,'')>''
			begin
				if @item_type = 'O1' or @item_type = 'O2' or @item_type = 'O3'
				begin
					
					insert into #output_stack (
						parent_id,
						parent_item,
						item,
						item_level,
						item_type,
						item_label,
						activity,
						machine,
						parent_part,
						part,
						components,
						start_datetime,
						item_type_number,
						sequence )
					select 	@new_item_id,
						@part,
						machine,
						@item_level+1,
						'OP',
						'Primary Vendor:'+machine,
						@activity,
						machine,
						@parent_part,
						@part,
						0,
						null,
						4,
						0
					from	part_machine
					where 	part=@part
						and activity=@activity
						and sequence=1

					insert into #output_stack (
						parent_id,
						parent_item,
						item,
						item_level,
						item_type,
						item_label,
						activity,
						machine,
						parent_part,
						part,
						components,
						start_datetime,
						item_type_number,
						sequence )
					select	@new_item_id,
						@part,
						machine,
						@item_level+1,
						'OP',
						'Secondary Vendor:'+machine,
						@activity,
						machine,
						@parent_part,
						@part,
						0,
						null,
						4,
						0
					from	part_machine
					where 	part=@part
						and activity=@activity
						and sequence>1
						
				end
				else
				begin
					
					insert into #output_stack (
						parent_id,
						parent_item,
						item,
						item_level,
						item_type,
						item_label,
						activity,
						machine,
						parent_part,
						part,
						components,
						start_datetime,
						item_type_number,
						sequence )
					select	@new_item_id,
						@part,
						machine,
						@item_level+1,
						'MP',
						'Primary Machine:'+machine,
						@activity,
						machine,
						@parent_part,
						@part,
						0,
						null,
						1,
						0
					from 	part_machine
					where 	part=@part
						and activity=@activity
						and sequence=1

					insert into #output_stack (
						parent_id,
						parent_item,
						item,
						item_level,
						item_type,
						item_label,
						activity,
						machine,
						parent_part,
						part,
						components,
						start_datetime,
						item_type_number,
						sequence )
					select	@new_item_id,
						@part,
						machine,
						@item_level+1,
						'MS',
						'Secondary Machine:'+machine,
						@activity,
						machine,
						@parent_part,
						@part,
						0,
						null,
						2,
						0
					from 	part_machine
					where 	part=@part
						and activity=@activity
						and sequence>1

					insert into #output_stack (
						parent_id,
						parent_item,
						item,
						item_level,
						item_type,
						item_label,
						activity,
						machine,
						parent_part,
						part,
						components,
						start_datetime,
						item_type_number,
						sequence )
					select	#output_stack.item_id,
						pmt.machine,
						pmt.tool,
						@item_level+2,
						'MT',
						'Machine Tool:'+pmt.tool,
						'',
						pmt.machine,
						@parent_part,
						@part,
						0,
						null,
						3,
						0
					from 	part_machine as pm
						,part_machine_tool as pmt,
						#output_stack
					where 	pm.part=pmt.part
						and pm.machine=pmt.machine
						and pm.part=@part
						and pm.activity=@activity
						and #output_stack.activity = @activity
						and #output_stack.machine = pmt.machine
						and #output_stack.parent_part = @parent_part
						and #output_stack.part = @part
				end
			end

			if @mode=1
				insert into #stack (
					parent_id,
					parent_part,
					part,
					item_level,
					start_datetime,
					end_datetime,
					substitute_part,
					type,
					spid)
				select	@new_item_id,
					@part,
					part,
					@item_level+1,
					start_datetime,
					start_datetime,
					substitute_part,
					type,
					@@spid
				from 	bill_of_material_ec
				where 	parent_part=@part
					and start_datetime>@current_datetime
				order by part
			else if @mode=2
				insert into #stack (
					parent_id,
					parent_part,
					part,
					item_level,
					start_datetime,
					end_datetime,
					substitute_part,
					type,
					spid)
				select	@new_item_id,
					@part,
					part,
					@item_level+1,
					start_datetime,
					start_datetime,
					substitute_part,
					type,
					@@spid
				from 	bill_of_material_ec
				where 	parent_part=@part
				order by part
			else if @mode=3
				insert into #stack (
					parent_id,
					parent_part,
					part,
					item_level,
					start_datetime,
					end_datetime,
					substitute_part,
					type,
					spid)
				select 	@new_item_id,
					@part,
					part,
					@item_level+1,
					start_datetime,
					null,
					substitute_part,
					type,
					@@spid
				from 	bill_of_material_ec
				where 	parent_part=@part
					and start_datetime>@user_datetime
					and isnull(end_datetime,@user_datetime)>=@user_datetime
				order by part
			else
				insert into #stack (
					parent_id,
					parent_part,
					part,
					item_level,
					start_datetime,
					end_datetime,
					substitute_part,
					type,
					spid)
				select 	@new_item_id,
					@part,
					part,
					@item_level+1,
					start_datetime,
					start_datetime,
					substitute_part,
					type,
					@@spid
				from 	bill_of_material_ec
				where 	parent_part=@part
					and start_datetime<=@current_datetime
					and(end_datetime>=@current_datetime or end_datetime is null)
				order by part

			select @rowcount=@@rowcount

			delete from #stack
			where 	item_level=@item_level
				and id = @stack_item_id

			update	#output_stack set
				components = @rowcount
			where	item_id = @new_item_id
				
			if @rowcount>0
				select @item_level=@item_level+1
		end
		else
			select @item_level=@item_level-1
	end

	select	#output_stack.parent_item,
		#output_stack.item,
		#output_stack.item_level,
		#output_stack.item_type,
		#output_stack.item_label,
		#output_stack.activity,
		#output_stack.machine,
		#output_stack.parent_part,
		#output_stack.part,
		0,
		0,
		0,
		#output_stack.components,
		#output_stack.start_datetime,
		#output_stack.item_type_number,
		#output_stack.sequence,
		#output_stack.parent_id,
		#output_stack.item_id
	from	#output_stack 
	order by item_level asc

commit transaction
go




print '
--------------------------------
-- msp_sync_shipper_invoice
--------------------------------
'

if exists (
	select	1
	from	sysobjects
	where	id = object_id ( 'msp_sync_shipper_invoice' ) )
	drop procedure msp_sync_shipper_invoice
go

create procedure msp_sync_shipper_invoice
(	@shipper	integer )
as
---------------------------------------------------------------------------------------
-- 	This procedure is executed when a normal or quick shipper is shipped out to
--	synchronize the shipper number and invoice number
--
--	Arguments:
--	
--	@shipper	integer		mandatory
--
--	Modifications:	27 SEP 1999, Chris Rogers	Original
--			23 NOV 1999, Chris Rogers	Added check for sync switch in admin table
--
--	Returns:	 0		success
--			-1		error
--
--	Process:
--	1.	Update invoice_number with the value in the id column in the shipper table
---------------------------------------------------------------------------------------

--	1.	Update invoice_number with the value in the id column in the shipper table
if exists ( select 1 from admin where db_invoice_sync = 'Y' )
begin
	update	shipper 
	set	invoice_number = id
	where	id = @shipper
	
	exec msp_sync_parm_shipper_invoice
end
go


print '
--------------------------------
-- msp_sync_parm_shipper_invoice
--------------------------------
'

if exists (
	select	1
	from	sysobjects
	where	id = object_id ( 'msp_sync_parm_shipper_invoice' ) )
	drop procedure msp_sync_parm_shipper_invoice
go

create procedure msp_sync_parm_shipper_invoice
as
---------------------------------------------------------------------------------------
-- 	This procedure is executed when a parameter record is updated to set the 
--	next_invoice number to shipper number.
--
--	Modifications:	27 SEP 1999, Chris Rogers	Original
--			23 NOV 1999, Chris Rogers	Added check for sync switch in admin table
--
--	Returns:	 0		success
--			-1		error
--
--	Process:
--	1.	Update next_invoice with the value in the shipper column in parameters table
---------------------------------------------------------------------------------------

--	1.	Update next_invoice with the value in the shipper column in parameters table
if exists ( select 1 from admin where db_invoice_sync = 'Y' )
	update	parameters
	set	next_invoice = shipper

go


	
print'
---------------------------------
-- msp_shipping_dock_objects_list
---------------------------------
'
if exists (
	select	1
	  from	sysobjects
	 where	id = object_id ( 'msp_shipping_dock_objects_list' ) )
	drop procedure msp_shipping_dock_objects_list
go

create procedure msp_shipping_dock_objects_list
(	@shipper integer )
as
------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	This procedure returns the list of objects available for all the parts on shipper.
--
--	Modifications:	22 SEP 1998, Chris Rogers	Original.
--			19 FEB 1999, Eric E. Stimpson	Rewrote for performance.
--			05 AUG 1999, Mamatha Bettareger	Included configurable column to the select statement.
--			02 OCT 1999, Eric E. Stimpson	Optimized query.
--			28 Dec 2000, Harish G P		Removed commit transaction statement at the end
--
--	Arguments:	@shipper	mandatory
--
--	1. Return result set.
------------------------------------------------------------------------------------------------------------------------------------------------------------------
begin
	create table #results
	(
		serial integer null,
		part varchar(25) null,
		status char(1) null,
		quantity decimal(20,6) null,
		unit_measure varchar(2) null,
		std_quantity decimal(20,6) null,
		parent_serial integer null,
		shipper integer null,
		location varchar(10) null,
		note varchar(255) null,
		suffix integer null,
		origin varchar(20) null,
		engineering_level varchar(10) null,
		configurable char(1) null
	)
	
	insert into #results
	select	box.serial,
		box.part,
		box.status,
		box.quantity,
		box.unit_measure,
		box.std_quantity,
		box.parent_serial,
		box.shipper,
		box.location,
		box.note,
		box.suffix,
		box.origin,
		box.engineering_level,
		configurable
	from	object box,
		shipper_detail sd,
		part_inventory pi
	where	box.status = 'a' and
		pi.part = box.part and 
		box.part = part_original and
		sd.shipper = @shipper and
		( isnull ( box.suffix, 0 ) = isnull ( sd.suffix, 0 ) or
		isnull ( pi.configurable, 'N' ) = 'N' )
	
	insert into #results
	select	pallet.serial,
		pallet.part,
		pallet.status,
		pallet.quantity,
		pallet.unit_measure,
		pallet.std_quantity,
		pallet.parent_serial,
		pallet.shipper,
		pallet.location,
		pallet.note,
		pallet.suffix,
		pallet.origin,
		pallet.engineering_level,
		'N'
	from	object pallet,
		#results box
	where	box.parent_serial = pallet.serial
	
	select	serial,
		part,
		status,
		quantity,
		unit_measure,
		std_quantity,
		parent_serial,
		shipper,
		location,
		note,
		suffix,
		origin,
		engineering_level,
		configurable
	from	#results
	order by 2, 1
	
	drop table #results
end
go

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

print '
-----------------------------------------------------------------------------------
--	msp_explode_demand_flagged 
-----------------------------------------------------------------------------------
'
if exists ( select 1 from sysobjects where name = 'msp_explode_demand_flagged')
	drop procedure msp_explode_demand_flagged
go

create procedure	msp_explode_demand_flagged
as
-----------------------------------------------------------------------------------
--	msp_explode_demand_flagged :
--
--
--
--	Process :
--	
--	1.	Delete MPS for 
--	2.	Write the current set of releases to MPS
--	3.	Loop on @current_level
--	4.	Insert children of @current_level to MPS
--	5.	call msp_assign_quantity
--
--	Development Team - 07/20/1999 
--	Development Team - 08/26/1999	Modified update order_detail statement for performance.
--	Development Team - 09/15/1999	Included paranthesis to compute dead_start correctly
--	Development Team - 01/07/1999	Changed bill_of_material view to mvw_billofmaterial to suppress substitute_parts
--	GPH		 - 04/04/2000	Included overlap time as part of the dropdead date computation & part_inventory join
--					to get the standard pack qty
-----------------------------------------------------------------------------------

--	Declarations

declare	@current_level	integer,
	@part	varchar (25)

--	Initialize
select	@current_level = 1

begin transaction -- ( 1T )

--	1.	Delete MPS
delete	master_prod_sched  
from    master_prod_sched 
	join mvw_demand mvw on mvw.first_key = master_prod_sched.origin and
				mvw.second_key = master_prod_sched.source
where	mvw.flag > 0

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
		case	when parameters.include_setuptime = 'Y'then part_machine.setup_time
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
	IsNull ( dateadd ( mi, - 60 * (( 24.00 / convert (decimal, parameters.workhours_in_day ) ) * ( mvw_demand.std_qty / part_machine.parts_per_hour + 
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
	join part_inventory on mvw_demand.part = part_inventory.part
	left outer join part_machine on mvw_demand.part = part_machine.part and
		part_machine.sequence = 1
	cross join parameters 
where	mvw_demand.flag > 0

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
	where	mvw_new.id = @current_level - 1 and
		mvw_new.flag > 0
	order	by mvw_new.id
end -- (1B)

declare parts cursor for
select  mps.part 
from	master_prod_sched mps
	join mvw_demand mvw on mps.origin = mvw.first_key and
				mps.source = mvw.second_key
where	mvw.flag > 0 
group 	by mps.part

open	parts

fetch parts into @part 

while @@fetch_status = 0 
begin

--	5. call msp_assign_quantity
	execute msp_assign_quantity @part

	fetch parts into @part 

end

close parts

deallocate parts 

commit transaction -- ( 1T )

go

--------------------------------------------------------------------------------------
--	Msp_explode_demand_order
-------------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'msp_explode_demand_order')
	drop procedure msp_explode_demand_order
go

create procedure	msp_explode_demand_order (
	@firstkey numeric (8,0),
	@secondkey integer )
as
--------------------------------------------------------------------------------------
--	Msp_explode_demand_order
--
--	Parameters :	@firstkey
--
--	Process :
--	
--	1.	Delete MPS
--	2.	Write the current set of releases to MPS
--	3.	Loop on @current_level
--	4.	Insert children of @current_level to MPS
--	5. 	Call msp_assign_quantity
--
--	Development Team - 07/20/1999 
--	Development Team - 08/26/1999	Modified update order_detail statement for performance.
--	Development Team - 09/15/1999	Included paranthesis to compute dead_start correctly
--	Development Team - 01/07/1999	Changed bill_of_material view to mvw_billofmaterial to suppress substitute_parts
--	GPH		 - 04/04/2000	Included overlap time as part of the dropdead date computation & part_inventory join
--					to get the standard pack qty
--------------------------------------------------------------------------------------
--	Declarations

declare	@current_level	integer,
	@part varchar(25)

--	Initialize
select	@current_level = 1

begin	transaction -- (1t)

--	1.	Delete MPS
delete	master_prod_sched
where	master_prod_sched.origin = @firstkey and
	master_prod_sched.source = @secondkey

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
	IsNull ( dateadd ( mi, - 60 * (( 24.00 / parameters.workhours_in_day ) * (mvw_demand.std_qty / part_machine.parts_per_hour +
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
	IsNull ( dateadd ( mi, - 60 * (( 24.00 / convert (decimal, parameters.workhours_in_day ) ) * (mvw_demand.std_qty / part_machine.parts_per_hour + 
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
where	mvw_demand.first_key = @firstkey and
	mvw_demand.second_key = @secondkey

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
	where	mvw_new.id = @current_level - 1 and
		mvw_new.origin = @firstkey and
		mvw_new.source = @secondkey
end -- (1B)

--	call msp_assign_quantity procedure

declare parts cursor for
select  mps.part 
from	master_prod_sched mps
where   mps.origin = @firstkey and
	mps.source = @secondkey
group 	by mps.part

open	parts

fetch parts into @part 

while @@fetch_status = 0 
begin

--	5. 	call msp_assign_quantity
	execute msp_assign_quantity @part

	fetch parts into @part 

end

close parts

deallocate parts 

commit transaction -- ( 1T )

go

print'
-----------------------------
-- procedure:	msp_super_cop
-----------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_super_cop'))
	drop procedure msp_super_cop
GO

create procedure	msp_super_cop (
	@regen_all	char (1),
	@order_no	numeric (8,0) = null,
	@row_id		integer = null )
as
-------------------------------------------------------------------------------------------------------------------------------
--	msp_super_cop : 	this procedure calls the explode demand procedure
--
--	parameters:		@regen_all char (1),
--				@order_no  numeric (8,0) null,
--				@row_id	   integer null
--
--	Process :
-- 	1. 	Call msp_explode_demand procedure
--	2. 	Set the flags on the releases
--
--	Development Team - 07/20/1999
--	Development Team - 08/26/1999	Modified update order_detail statement for performance.
--	
--------------------------------------------------------------------------------------------------------------------------------
-- 	1. Call msp_explode_demand procedure
if @regen_all = 'Y' 
begin
	execute msp_explode_demand

	update	order_detail 
	set 	flag = 0
	from 	order_detail 
		join master_prod_sched mps on mps.origin = order_detail.order_no and
			mps.source = order_detail.row_id
	where	order_detail.flag > 0
	
end 	
else 
	if @order_no is null
	begin 
		execute msp_explode_demand_flagged

		update	order_detail 
		set 	flag = 0
		from	order_detail
			join master_prod_sched mps on mps.origin = order_detail.order_no and
    	     			mps.source = order_detail.row_id
		where	order_detail.flag > 0
	end
	else 
	begin		
		execute msp_explode_demand_order @order_no, @row_id
		update	order_detail 
		set 	flag = 0
		where 	order_no= @order_no and 
			row_id 	= @row_id
	end 		
		
go


---------------------------------------------------------------------------------------
--	Monitor Order Validation Procedure
---------------------------------------------------------------------------------------

------------------------------
-- msp_transferinsertedrelease
------------------------------
if exists (
	select	1
	  from	sysobjects
	 where	id = object_id ( 'msp_transferinsertedrelease' ) )
	drop procedure	msp_transferinsertedrelease
go

create procedure msp_transferinsertedrelease (
	@orderno	numeric (8) )
as
-------------------------------------------------------------------------------------
--	This procedure transfers inserted releases to order detail.
--
--	Modifications:	08 JAN 1999, Eric E. Stimpson	Original
--			25 MAY 1999, Eric E. Stimpson	Modified formatting.
--			01 OCT 1999, Eric E. Stimpson	Modified to consider current accum shipped (#2).
--			05 JAN 2000, Eric E. Stimpson	Add result set on success.
--
--	Paramters:	@orderno	mandatory
--
--	Returns:	  0	success
--			100	order not found
--
--	Process:
--	1.	Delete existing releases.
--	2.	Adjust releases with current accum shipped.
--	3.	Insert new releases.
--	4.	Return success.
---------------------------------------------------------------------------------------

--	1.	Delete existing releases.
delete	order_detail
 where	order_no = @orderno

--	2.	Adjust releases with current accum shipped.
update	order_detail_inserted
set	our_cum = isnull(our_cum,0) + (
	select	Max ( isnull(order_header.our_cum,0) - isnull(odi.our_cum,0) )
	from	order_detail_inserted odi
		join order_header on order_header.order_no = @orderno
	where	odi.order_no = @orderno and
		odi.type = order_detail_inserted.type ),
	the_cum = isnull(the_cum,0) + (
	select	Max ( isnull(order_header.our_cum,0) - isnull(odi.our_cum,0) )
	from	order_detail_inserted odi
		join order_header on order_header.order_no = @orderno
	where	odi.order_no = @orderno and
		odi.type = order_detail_inserted.type )
from	order_detail_inserted
where	order_detail_inserted.order_no = @orderno

--	3.	Insert new releases.
insert	order_detail
select	*
  from	order_detail_inserted
 where	order_no = @orderno

--	4.	Return success.
select 0
return 0
go

print'
-----------------------------------
-- procedure:	msp_unit_conversion
-----------------------------------
'
IF	Exists	(
	SELECT	*
	  FROM	sysobjects
	WHERE	id = Object_id ( 'msp_unit_conversion' ) )
	DROP PROCEDURE	msp_unit_conversion
GO

CREATE PROCEDURE msp_unit_conversion
(	@part			varchar (25),
	@altquantity	numeric (20,6) OUTPUT,
	@unitfrom		char (2),
	@unitto			char (2) )
AS
BEGIN -- (1B)
---------------------------------------------------------------------------------------
-- 	This procedure calculates an alternate quantity for a part from an alternate
--	quantity and unit of measure.
--	Modified:	02 Jan 1999, Eric E. Stimpson
--	Paramters:	@part			mandatory
--				@altquantiy		mandatory
--				@unit			optional
--	Returns:	0				success
--				-1				error, invalid from unit for this part
--				-2				error, invalid to unit for this part
--				100				no change, from unit and to unit were same
---------------------------------------------------------------------------------------

--	Declarations.
	DECLARE	@stdquantity	numeric (20,6),
			@factor			numeric (20,6)

--	Initialize all variables
	SELECT	@stdquantity = 0,
			@factor = 1

--	If from unit and to unit are the same, return no change.
	IF @unitfrom = @unitto
		Return	100

--	Get the standard quantity conversion factor.
	SELECT	@factor = IsNull
			( (	SELECT	conversion
				  FROM	unit_conversion,
						part_inventory,
						part_unit_conversion
				 WHERE	part_inventory.part = @part AND
						part_unit_conversion.part = @part AND
						part_unit_conversion.code = unit_conversion.code AND
						unit_conversion.unit1 = @unitfrom AND
						unit_conversion.unit2 = part_inventory.standard_unit ), -1 )

--	If factor is -1, an error occurred because from unit of measure was invalid.  Return error.
	IF @factor = -1
		Return	-1

--	Calculate the standard quantity.
	SELECT	@stdquantity = @altquantity * @factor

--	Get the alternate quantity conversion factor.
	SELECT	@factor = IsNull
			( (	SELECT	conversion
				  FROM	unit_conversion,
						part_inventory,
						part_unit_conversion
				 WHERE	part_inventory.part = @part AND
						part_unit_conversion.part = @part AND
						part_unit_conversion.code = unit_conversion.code AND
						unit_conversion.unit1 = part_inventory.standard_unit AND
						unit_conversion.unit2 = @unitto ), -2 )

--	If factor is -2, an error occurred because to unit of measure was invalid.  Return error.
	IF @factor = -2
		Return	-2

--	Calculate the alternate quantity and return success,
	SELECT	@altquantity = @stdquantity * @factor
	Return	0

END -- (1B)
GO



print'
-----------------------------
-- procedure:	msp_unit_list
-----------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_unit_list'))
	drop procedure msp_unit_list
GO

CREATE PROCEDURE msp_unit_list ( @part varchar(25) ) AS

select unit=null,description='(None)'
union select distinct standard_unit,description
  from part_inventory,unit_measure
  where standard_unit=unit and part_inventory.part=@part
union select distinct unit_conversion.unit1,description
  from part_unit_conversion
  ,unit_conversion,unit_measure
  where unit1=unit and(part_unit_conversion.code=unit_conversion.code)
  and((part_unit_conversion.part=@part))
union select distinct unit_conversion.unit2,description
  from part_unit_conversion
  ,unit_conversion,unit_measure
  where unit2=unit and(part_unit_conversion.code=unit_conversion.code)
  and((part_unit_conversion.part=@part))

GO


print'
--------------------------------------
-- PROCEDURE:	msp_update_kanban_info
--------------------------------------
'
if exists(select 1 from dbo.sysobjects where name='msp_update_kanban_info' and type='P')
   drop procedure msp_update_kanban_info
go
create procedure msp_update_kanban_info (@shipper integer) as
begin -- (1b)
   SELECT kanban.kanban_number,   
          kanban.status,   
          object.serial,
          pi.label_format 
     FROM kanban, object
          join part_inventory as pi on pi.part = object.part
    WHERE ( kanban.kanban_number  = isnull ( object.kanban_number, '0' )) and 
          ( object.shipper = @shipper )
end -- (1e)
go



print'
------------------------------
-- msp_update_part_qty_asgnd
------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_update_part_qty_asgnd'))
	drop procedure msp_update_part_qty_asgnd
go

create procedure msp_update_part_qty_asgnd 
( @part varchar (25) ) 
as
---------------------------------------------------------------------------------------
-- 	This procedure re assigns the quantity assigned ( po qty or wo qty ) to the 
--	master prod sched table for the part number supplied. 
--
--	Arguments:	@part	mandatory
--
--	Modifications:	15 JUN 1999, Mamatha Bettagere
--
--	Returns:	1	success
--
--	Process:
--	1. Update qty_assigned = 0 for all rows for that part in mps table
--	2. Get active po qty or wo qty for that part number 
--	3. Get all mps rows for that part order by due date
--	4. Assign quantities in due date order  through all rows
---------------------------------------------------------------------------------------

declare	@part_assign			varchar(25),
	@due_date                       datetime,
	@due	                        datetime,
	@order_no                       numeric(8,0),
	@row_id                         int,
	@origin                         numeric(8,0),
	@source                         int,
	@plant                          varchar(10),
	@qnty				numeric(20,6),
	@assign_qty			numeric(20,6),
	@id				numeric(12,0)

create table #mps_assign (
	part				varchar(25),
	due				datetime,
	source				int,
	origin				numeric(8,0),
	qnty				numeric(20,6),
	id				numeric(12,0))

	begin transaction

--	1. Update qty_assigned = 0 for all rows for that part in mps table
	update	master_prod_sched 
	set	qty_assigned = 0
	where	part = @part

--	2. Get active po qty or wo qty for that part number 
	select	@assign_qty = sum ( standard_qty )
	from	po_detail
	where	part_number = @part and
		status <> 'C'

--	select	@assign_qty_wo = sum(wod.qty_required)
--	from	workorder_detail wod
--	where	wod.part = @part
	
	select	@assign_qty = isnull(@assign_qty,0) + isnull(sum(wod.qty_required - wod.qty_completed),0)
	from	workorder_detail wod
	where	wod.part = @part
	
--	3. Get all mps rows for that part order by due date
	insert	#mps_assign (part, due, source, origin, qnty, id)
	select	part, due, source, origin, qnty, id
	from	master_prod_sched
	where	part = @part
	order by due

	set rowcount 1

 	select 	@due = due, 
	       	@source = source, 
	       	@origin = origin, 
		@qnty = qnty,
		@id	= id
	from	#mps_assign

--	4. Assign quantities in due date order  through all rows

	while ( @@rowcount > 0 )  and ( @assign_qty > 0 )
	begin
		
		set rowcount 0
	
		if @assign_qty > @qnty	
		begin
			update	master_prod_sched
			set	qty_assigned = @qnty
			where	part = @part and
				source = @source and
				origin = @origin and
				due = @due and
				id = @id
		
			select	@assign_qty = @assign_qty - @qnty
		end
		else
		begin
			update	master_prod_sched
			set	qty_assigned = @assign_qty
			where	part = @part and 
				source = @source and
				origin = @origin and
				due = @due and
				id = @id
	
			select	@assign_qty = 0
		end				
	
		set rowcount 1
	
		delete  
		from	#mps_assign
		where	part = @part and
			source = @source and
			origin = @origin and
			due = @due and
			id = @id
	
		set rowcount 1
	
		select	@due = due,		
			@source = source,
			@origin = origin,
			@qnty = qnty,
			@id   = id
		from	#mps_assign
			
	end

	commit transaction					
	
--	select 1

	set rowcount 0

go


print '
-------------------------------
-- PROCEDURE:	edi_msp_shipout
-------------------------------
'
----------------------------------------------------------------------------------
--	EDI Monitor shipout procedure:
--
--	Monitor defined this procedure for EDI to override.
if exists (
	(	select	1
		from	sysobjects
		where	id = object_id ( 'edi_msp_shipout' ) ) )
	drop procedure edi_msp_shipout
go

create procedure edi_msp_shipout
(	@shipper	integer )
as
-- 	1.	Record shipout for homogeneous pallet with part id of boxes.
insert	serial_asn
select	pallet.serial,
	max ( boxes.part ),
	convert ( integer, pallet.shipper ),
	pallet.package_type
from	object pallet 
	join object boxes on pallet.serial = boxes.parent_serial
where	pallet.shipper = @shipper and
	pallet.type = 'S'
group by	pallet.serial,
	pallet.shipper,
	pallet.package_type
having	count ( distinct boxes.part ) = 1
	
--	2.	Record shipout for loose box.
insert	serial_asn
select	serial,
	part,
	convert ( integer, shipper ),
	package_type
from	object
where	shipper = @shipper and
	parent_serial is null and
	type is null

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

print'
----------------------------------------
-- PROCEDURE:	msp_update_onhand_from_s
----------------------------------------
'
if exists(select 1 from dbo.sysobjects where name='msp_update_onhand_from_s' and type='P')
   drop procedure msp_update_onhand_from_s
go

create procedure msp_update_onhand_from_s 
(@shipper integer, 
 @returnvalue integer OUTPUT) as
begin -- (1b)
  declare @part_original varchar(25),
          @totalcount integer,
          @onhand     numeric(20,6)
  create table #sd_part_temp (part_original varchar(25))
  insert into #sd_part_temp (part_original)
  SELECT part_original 
    FROM shipper_detail 
   WHERE (shipper_detail.shipper = @shipper)
  select @returnvalue = 0 -- success status
  select @totalcount = count(*)
    from #sd_part_temp
  if (@totalcount > 0) 
   begin -- (2b)
     set rowcount 1
     select @part_original=part_original
       from #sd_part_temp
     while (@@rowcount > 0) 
      begin -- (3b)
        set rowcount 0 
        -- get object onhand
        select @onhand=sum(std_quantity)
          from object
         where (part=@part_original and status='A')
        -- update part online table
        update part_online
           set on_hand=isnull(@onhand,0)
         where (part=@part_original)
        set rowcount 0 
        delete 
          from #sd_part_temp
         where (part_original = @part_original) 
        set rowcount 1
        select @part_original=part_original
          from #sd_part_temp
      end -- (3e)    
   end -- (2e)
  else
   select @returnvalue=100
  drop table #sd_part_temp
end -- (1e)
go


print'
---------------------------------------
-- PROCEDURE:	msp_update_shipper_cost
---------------------------------------
'
if exists(select 1 from dbo.sysobjects where name='msp_update_shipper_cost' and type='P')
   drop procedure msp_update_shipper_cost
go

create procedure msp_update_shipper_cost 
(@serial integer, 
 @shipper integer,
 @customer varchar(10),
 @vendor   varchar(10),
 @destination varchar(10),
 @shippertype char(1),
 @operator varchar(5),
 @returnvalue integer OUTPUT) as
begin -- (1b)
  declare @part        varchar(25),
          @suffix      integer,
          @std_qty     numeric(20,6),
          @price       numeric(20,6),
          @salesman    varchar(10),
          @note        varchar(254),
          @group_no    varchar(10),
          @order_no    integer,
          @release_no  varchar(30),
          @accountcode varchar(50),
          @cost        numeric(20,6),
          @total_cost  numeric(20,6),
          @onhand      numeric(20,6),
          @remarks     varchar(40)
  SELECT @returnvalue = 0 -- success status
  SET rowcount 0 
  -- get the details about that object
  SELECT @part=o.part,
         @suffix=o.suffix,
         @std_qty=o.std_quantity,
         @cost=o.cost,
         @onhand=p.on_hand
    FROM object as o join part_online as p on p.part = o.part
   WHERE (serial=@serial)
  if (@@rowcount > 0 )
   begin -- (2b)
     -- get price for that part
     SET rowcount 0 
     if (@suffix is not null and @suffix <> 0)
        SELECT @price =price, 
               @salesman=salesman,
               @note =note, 
               @group_no =group_no,
               @order_no=order_no, 
               @release_no =release_no, 
               @accountcode=account_code 
          FROM shipper_detail 
         WHERE (shipper = @shipper and part_original = @part and suffix = @suffix)
     else
         SELECT @price =price, 
                @salesman=salesman,
                @note =note, 
                @group_no =group_no,
                @order_no=order_no, 
                @release_no =release_no, 
                @accountcode=account_code 
           FROM shipper_detail 
          WHERE (shipper = @shipper and part_original = @part)
     if @@rowcount > 0 
      begin -- (3b)
        --  compute the total cost
        SELECT @total_cost = isnull(@std_qty,1.0) * isnull(@cost,1.0)
        set rowcount 0         
        -- update shipper detail 
        if (@suffix is not null and @suffix <> 0)
          UPDATE shipper_detail 
             SET total_cost = @total_cost 
           WHERE (shipper = @shipper and part_original = @part and suffix = @suffix)
        else
          UPDATE shipper_detail 
             SET total_cost = @total_cost 
           WHERE (shipper = @shipper and part_original = @part)
        if @@rowcount > 0 
         begin -- (4b)
           if (@shippertype='S' or @shippertype='Q')
              SELECT @remarks = 'Shipping'
           else if (@shippertype = 'O')
             SELECT @remarks = 'Out Proc' 
           else if (@shippertype = 'V')
             SELECT @remarks = 'Ret Vendor'
           else 
             SELECT @remarks = ''
           set rowcount 0   
           -- create audit_trail info
           INSERT INTO audit_trail  
                 ( serial, date_stamp, type, part, quantity, remarks, price, salesman, customer,   
                   vendor, po_number,  operator, from_loc, to_loc, on_hand, lot, weight, status,   
                   shipper, flag, activity, unit, workorder, std_quantity, cost, control_number,   
                   custom1, custom2, custom3, custom4, custom5, plant, invoice_number,    notes,   
                   gl_account, package_type, suffix, due_date, group_no, sales_order,release_no,   
                   dropship_shipper, std_cost, user_defined_status, engineering_level,   posted,   
                   parent_serial, origin, destination, sequence, object_type, part_name, start_date,
                   field1, field2, show_on_shipper, tare_weight, kanban_number, dimension_qty_string,
                   dim_qty_string_other, varying_dimension_code)  
           SELECT  serial, getdate(), @shippertype, part, quantity, @remarks, @price, @salesman, @customer,
                   @vendor, po_number, @operator, location, @destination, @onhand, lot, weight, status, 
                   convert(varchar,@shipper), null, null, unit_measure, workorder, std_quantity, cost, null,
                   custom1, custom2, custom3, custom4, custom4, plant, null, @note, 
                   @accountcode, package_type, suffix, date_due, @group_no, convert(varchar,@order_no), @release_no, 
                   null, std_cost, user_defined_status, engineering_level, null, 
                   parent_serial, null, @destination, sequence, null, name, start_date,
                   field1, field2, show_on_shipper, tare_weight, kanban_number, dimension_qty_string,
                   dim_qty_string_other, varying_dimension_code
              FROM object
             WHERE (serial=@serial)   
           if (@@rowcount = 0) 
             SELECT @returnvalue= -1
           -- check shipper type
           if (@shippertype = 'O') 
             -- update object info
             UPDATE object SET location=@destination, destination=@destination, status='P'
              WHERE (serial=@serial)
           else
             -- delete row from object table
             DELETE FROM object WHERE (serial=@serial)
         end -- (4e) 
        else
         SELECT @returnvalue= -1 
      end -- (3e)
     else
      SELECT @returnvalue= -1     
   end  -- (2e)
  else
   SELECT @returnvalue= -1 
end -- (1e)
go 


print'
---------------------------------
-- PROCEDURE:	msp_update_orders
---------------------------------
'
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

--**********************************************************************************
--Procedure   : msp_checkshipper(shipper long) returns long 
--Description : procedure to check the following
--              whether the customer status is approved or not
--              whether the shipper is staged or not
--              whether the packing list has been printed or not
--              whether the shipper is closed by any other user or not
--              whether the bol is applicable & has been printed or not
--Argument    : Receives shipper number (Long)
--Return value:   0 - is success
--              100 - is not found
--               -1 - customer status is not 'A'
--               -2 - shipper is closed 
--               -3 - shipper status is not 'S'
--               -4 - packlist not printed
--               -5 - bill of lading not printed
--Log changes : gph on 3/23/99 11:08 am original
--**********************************************************************************
if exists(select 1 from sysobjects where name='msp_checkshipper' and type ='P')
   drop procedure msp_checkshipper
go
create procedure msp_checkshipper (@shipper integer, @returnvalue integer OUTPUT) as
begin -- (1b)
  declare @bol_number  integer,
          @customerstatus char(1),
          @shipperstatus  char(1),
          @packlistprinted char(1),
          @bolprinted char(1)
  SELECT @returnvalue=0 -- successful status
  -- check for customer status, shipper status, packlist printed
  SELECT @customerstatus=status_type, 
         @shipperstatus=status, 
         @packlistprinted=printed, 
         @bol_number=bill_of_lading_number
    FROM customer_service_status as a, shipper as b
   WHERE (a.status_name = b.cs_status and b.id = @shipper)
  if (@@rowcount > 0)
   if (@customerstatus='A')  -- Check customer status type
    begin -- (3b)
      if (@shipperstatus='S') -- check shipper status 
       begin -- (3.1b) 
         if (@packlistprinted='Y') -- check pack list printed
          begin -- (3.2b) 
            if (@bol_number > 0) -- check the bol number
             begin -- (3.3b)
               SELECT @bolprinted=bill_of_lading.printed  
                 FROM bill_of_lading  
                WHERE (bill_of_lading.bol_number = @bol_number)
               if (@bolprinted<>'Y')   -- check bol printed 
                  SELECT @returnvalue=-5 -- bol not printed
             end -- (3.3e) 
          end -- (3.2e)
         else
           SELECT @returnvalue=-4  -- pack list not printed
       end -- (3.1e) 
      else
       begin -- (3.1.1b)
         if (@shipperstatus in ('C','Z')) -- check whether the shipper is closed
            SELECT @returnvalue=-2 -- shipper is closed by another user
         else 
            SELECT @returnvalue=-3 -- shipper not staged
       end -- (3.1.1e)       
    end -- (3e)
   else
     SELECT @returnvalue = -1 -- customer status is not approved	
  else
    SELECT @returnvalue = 100 -- shipper not found
  select @returnvalue -- return value 
end -- (1e)
go

print'
-------------------
-- msp_stage_object
-------------------
'

if exists (
	select	1
	  from	sysobjects
	 where	id = object_id ( 'msp_stage_object' ) )
	drop procedure msp_stage_object
go

create procedure msp_stage_object (
 	@shipper integer, 
	@serial integer, 
	@parent_serial integer = null, 
	@create_sd char (1) = null, 
	@pkg_override char (1) = null,
	@result integer out )
as
---------------------------------------------------------------------------------------
-- 	This procedure stages an object to shipper.
--	parameter @shipper, @serial, @parent_serial, @create_sd, @pkg_override
--
--	Arguments:	@shipper    	mandatory
--			@serial     	mandatory
--			@parent_serial	optional
--			@create_sd	optional
--			@pkg_override	optional
--
--	Modifications:	02 MAR 1999, Mamatha Bettagere	Original.
--			04 MAY 1999, Mamatha Bettagere
--			09 JUN 1999, Eric E. Stimpson	Modified format.
--							Removed Package Type checking.
--							Moved part_original and part_required calculations to msp_reconcile_shipper.
--	
--	Returns:	 0	success
--			-1	shipper not found
--			-2	error, shipper was already closed
--			-3	error, invalid object
--			-4	error, object already staged to a shipper			
--			-5	package types don't match
--			-6	shipper type is 'v' and po number is null on object
--			-7	shipper type is 'o' and part/vendor relation doesn't exist
--
--	Process:
--	1. Ensure shipper is not closed.
--	2. Ensure shipper exists.
-- 	3. Check for valid, approved and not previously staged box.
--	4. Check for shipper type ( return to vendor type ) and po number.
--	5. Check for shipper type ( outside process ) and part vendor relationship
-- 	6. Check packing requirements.
-- 	7. If @create_sd then create shipper detail row
--	8. Stage a super object.
--	9. Stage a box.
-- 	10. Call reconcile shipper procedure to udpate shipper and shipper container tables
---------------------------------------------------------------------------------------

--	1. Ensure shipper is not closed.
if exists (
	select	1
	  from	shipper
	 where	id = @shipper and
		( status = 'C' or status = 'z' ) )	
	return -2

--	2. Ensure shipper exists.
if not exists (
	select	1
	  from	shipper
	 where	id = @shipper )	
	return -1

-- 	3. Check for valid, approved and not previously staged box.
if exists (
	select	1
	  from 	object
	 where	serial = @serial and
		( status <> 'A' and type <> 'S' ) )
	return -3
if exists (
	select	1
	  from 	object
	 where	serial = @serial and
		shipper > 0 )
	return -4

begin transaction

--	4. Check for shipper type ( return to vendor type ) and po number.
if exists (
	select	1
	  from	shipper
	  	cross join object
	 where	shipper = @shipper and
		serial = @serial and
		shipper.type = 'V' and
		object.type is null and
		IsNull ( po_number, '' ) = ''
	union
	select	1
	  from	shipper
	  	cross join object
	 where	shipper = @shipper and
		parent_serial = @serial and
		shipper.type = 'V' and
		IsNull ( po_number, '' ) = '' )
	return -6  


--	5. Check for shipper type ( outside process ) and part vendor relationship
if exists (
	select	1
	  from	shipper
		cross join object
	 where	shipper = @shipper and
		serial = @serial and
		shipper.type = 'O' and
		object.type is null and
		part not in (
		select	part
		  from	part_vendor )
	union
	select	1
	  from	shipper
		cross join object
	 where	shipper = @shipper and
		parent_serial = @serial and
		shipper.type = 'O' and
		part not in (
		select	part
		  from	part_vendor ) )
	return -7

-- 	6. Check packing requirements.

-- 	7. If @create_sd then create shipper detail row
if @create_sd = 'Y'
	execute msp_create_shipper_detail @shipper, @serial 

--	8. Stage a super object.
update	object
   set	shipper = @shipper,
	show_on_shipper = 'N'
 where	parent_serial = @serial

update	object
   set	shipper = @shipper,
	show_on_shipper = 'Y'
 where	serial = @serial and
	type = 'S'

--	9. Stage a box (to a pallet).
update	object
   set	shipper = @shipper,
	parent_serial = @parent_serial,
	show_on_shipper = (
		case
			when @parent_serial is null then 'Y'
			else 'N'
		end )
 where	serial = @serial and
	type is null

-- 	10. Call reconcile shipper procedure to udpate shipper and shipper container tables
execute @result = msp_reconcile_shipper @shipper 

commit transaction
return @result 
go



print'
---------------------
-- msp_unstage_object
---------------------
'

if exists (
	select	1
	  from	sysobjects
	 where	id = object_id ( 'msp_unstage_object' ) )
	drop procedure msp_unstage_object
go

create procedure msp_unstage_object (
	@shipper integer,
	@serial integer,
	@result integer out )
as
---------------------------------------------------------------------------------------
-- 	This procedure unstages an object from shipper.
--
--	Arguments:	@shipper	mandatory
--			@serial		mandatory
--
--	Modifications:	30 APR 1999, Mamatha Bettagere	Original.
--			09 JUN 1999, Eric E. Stimpson	Modified format.
--							Moved shipper_detail removal to msp_reconcile_shipper.
--
--	Returns:	0	    success
--
--	Process:
--	1. Unstage a super object.
--	2. Unstage an box (from a pallet).
-- 	3. Call reconcile shipper procedure to udpate shipper and shipper container tables
---------------------------------------------------------------------------------------

begin transaction

--	1. Unstage a super object.
update	object
   set	shipper = null,
	show_on_shipper = null
 where	serial = @serial and
	type = 'S'

update	object
   set	shipper = null,
	show_on_shipper = null
 where	parent_serial = @serial

--	2. Unstage an box (from a pallet).
update	object
   set	shipper = null,
	show_on_shipper = null,
	parent_serial = null
 where	serial = @serial and
 	type is null
 
-- 	3. Call reconcile shipper procedure to udpate shipper and shipper container tables
execute @result = msp_reconcile_shipper @shipper 

commit transaction
return @result 
go




print'
-----------------------------------------
-- PROCEDURE:	msp_create_shipper_detail
-----------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_create_shipper_detail') )
	drop procedure msp_create_shipper_detail
go

create procedure msp_create_shipper_detail ( @shipper integer, @serial integer )
as
begin -- (1A)
-------------------------------------------------------------------------------------------
--	stored procedure to create shipper detail.
--      arguments : 	@shipper integer
--			@serial  integer	
--
--
--	Original :MB 03/03/99 
--	Modified :MB 04/30/99  
-------------------------------------------------------------------------------------------
--	declare local variables
	declare @salesman varchar (25), 
		@qty_packed numeric (20,6 ), 
		@std_qty_converted numeric (20,6), 
		@std_qty_packed numeric (20,6),
		@std_price numeric (20,6),
		@part varchar (25),
		@quantity numeric (20,6),
		@customer varchar (10),
		@unit  varchar (10),
		@type  varchar (1)

--	create temp table to hold all values for objects on pallet
	create table #boxes_on_pallet 
	( serial integer,
	  part	 varchar(25),
	  quantity decimal (20,6),
	  unit_measure varchar (10),
	  salesman varchar (25) null,
	  customer varchar (10) null,
	  std_qty_converted decimal (20,6),
	  std_price decimal (20,6) null,
	  shipper integer )

-- 	begin insert transaction
	begin transaction

--	get values from object table to temp table
	insert into #boxes_on_pallet 
	select 	serial,
		part,	
		quantity, 
		unit_measure, 
		'',
		'', 
		0, 
		null,
		@shipper 
	 from object 
	 where serial = @serial and object.type is null or parent_serial = @serial 

--	get salesman for that customer
	update #boxes_on_pallet 
	set salesman = (select customer.salesrep
			  FROM customer, shipper  
			 WHERE shipper.customer = customer.customer AND
			       #boxes_on_pallet.shipper = shipper.id  AND
			       shipper.id = @shipper ),
	    customer = (select shipper.customer
			  FROM customer, shipper  
			 WHERE shipper.customer = customer.customer AND
			       #boxes_on_pallet.shipper = shipper.id  AND
			       shipper.id = @shipper )
	where #boxes_on_pallet.shipper = @shipper 

--	get the std pack qty for that part and unit
	update #boxes_on_pallet 
	set std_qty_converted = isnull ( ( SELECT unit_conversion.conversion
				    FROM part_unit_conversion,   
			        	 unit_conversion  
				   WHERE ( part_unit_conversion.code = unit_conversion.code ) and  
			        	 ( part_unit_conversion.part = #boxes_on_pallet.part ) AND  
				         ( unit_conversion.unit1 = #boxes_on_pallet.unit_measure ) AND  
			        	 ( unit_conversion.unit2 = (select standard_unit 
								    from part_inventory 	
								    where part = #boxes_on_pallet.part )) ), 0 )

--	get price for that part

	set rowcount 1 

	select  @part = part,
		@customer = customer,
		@quantity = quantity
	from   #boxes_on_pallet 
	where  std_price is null 

	while @part > ''
	begin
		exec @std_price =  msp_calc_part_cust_price @part, @customer, @quantity 
		
		update #boxes_on_pallet
		set std_price = @std_price
		where part = @part
		and   customer = @customer 
		and   quantity = @quantity

		select @part = null

		set rowcount 1 

		select  @part = part,
			@customer = customer,
			@quantity = quantity
		from   #boxes_on_pallet 
		where  std_price is null 

	end
	
--	insert row into shipper_detail table 
	insert into shipper_detail 
	(  shipper,   
           part,   
           qty_required,   
           qty_packed,   
           qty_original,   
           accum_shipped,   
           order_no,   
           customer_po,   
           release_no,   
           release_date,   
           type,   
           price,   
           account_code,   
           salesman,   
           tare_weight,   
           gross_weight,   
           net_weight,   
           date_shipped,   
           assigned,   
           packaging_job,   
           note,   
           operator,   
           boxes_staged,   
           pack_line_qty,   
           alternative_qty,   
           alternative_unit,   
           week_no,   
           taxable,   
           price_type,   
           cross_reference,   
           customer_part,   
           dropship_po,   
           dropship_po_row_id,   
           dropship_oe_row_id,
	   part_name,
	   part_original,
	   alternate_price)  
	select @shipper,
	       #boxes_on_pallet.part,
	       #boxes_on_pallet.quantity,
		 ( isnull( #boxes_on_pallet. std_qty_converted, 1 ) * #boxes_on_pallet.quantity) ,
		 #boxes_on_pallet.quantity,
	         null,   
        	 0,   
	         null,   
        	 null,   
	         null,   
        	 null,   
		 #boxes_on_pallet.std_price, 
		 ( case when part.class = 'M' then ( select part_mfg.gl_account_code
						     from part_mfg
						     where part_mfg.part = #boxes_on_pallet.part ) else 
						(select part_purchasing.gl_account_code  
						 from part_purchasing 
						where part_purchasing.part = #boxes_on_pallet.part ) end ),
		 #boxes_on_pallet.salesman,
		 0,
		 0,
		 0,
	         null,   
        	 null,   
	         null,   
		 null,
	         null,   
        	 1,   
	         null,   
        	 #boxes_on_pallet.quantity,
	         #boxes_on_pallet.unit_measure,
	         null,   
        	 null,   
	         null,   
        	 null,   
	         part.cross_ref,   
        	 null,   
	         null,   
        	 null,
		 part.name,
		 #boxes_on_pallet.part,
		 #boxes_on_pallet.std_price 
	  from #boxes_on_pallet, part 
	  where serial  = #boxes_on_pallet.serial 
	  and #boxes_on_pallet.part = part.part 

	commit transaction	

	drop table #boxes_on_pallet	 

end 

go


print'
----------------------------------------
-- PROCEDURE:	msp_calc_part_cust_price
----------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('dbo.msp_calc_part_cust_price') )
	drop procedure dbo.msp_calc_part_cust_price
GO

create procedure msp_calc_part_cust_price ( @part varchar (25), @customer varchar (10), @quantity numeric (20,6 ) )
as
begin -- (1A)
-----------------------------------------------------------------------------------------
--	
--
--
--
--
--	mb 03/03/99 
-----------------------------------------------------------------------------------------
	declare @dec_std_price numeric (20,6),
		@premium varchar (1),
		@category varchar (25),
		@currency varchar (3),
		@price_type varchar (1),
		@dec_price numeric (20,6),
		@dec_markup numeric (20,6),
		@dec_premium numeric (20,6),
		@dec_qty_break numeric (20,6),
		@multiplier varchar (1)	

	SELECT	@dec_std_price = ps.price, 
		@premium = ps.premium,
		@category = c.category,
		@currency = c.default_currency_unit,
		@price_type = pc.type
	FROM 	part_standard ps, customer c, part_customer  pc
	WHERE 	ps.part = @part   AND 
		c.customer = @customer AND
		ps.part = pc.part AND 
		pc.customer = c.customer

	if ( isnull ( @price_type , '' ) = '' and isnull ( @category, '' ) = '' )
		return @dec_std_price

	if  @price_type = 'D' 
		SELECT 	@dec_price = price
		FROM 	part_customer_price_matrix as a, part_customer as b
		WHERE 	( a.part = b.part ) AND
			( a.customer = b.customer ) AND
			( a.part = @part ) AND  
			( a.customer = @customer ) 
	else if @price_type = 'C' 
	begin
		SELECT	@dec_markup = markup,
			@multiplier = multiplier,
			@dec_premium = premium
		FROM	category
		WHERE	code = @category 
	
		if @@rowcount <= 0 
			return @dec_std_price
		
		if @premium  <> 'Y' 
			select @dec_premium = 0
	
		if @multiplier = '+'
			select @dec_price = @dec_std_price + @dec_markup + @dec_premium
		else if @multiplier = '-' 
			select @dec_price = @dec_std_price - @dec_markup + @dec_premium
		else if @multiplier = '%' 
			select @dec_price = @dec_std_price + ( @dec_std_price * @dec_markup ) + @dec_premium
		else if @multiplier = 'x'
			select @dec_price = @dec_std_price * @dec_markup + @dec_premium 
	end
	else if @price_type = 'B' 
	begin
		SELECT @dec_qty_break = max(qty_break)
		  FROM part_customer_price_matrix  
		 WHERE ( part = @part ) AND  
		       ( customer = @customer ) AND  
		       ( qty_break <= @quantity ) 
			 
		if @dec_qty_break > 0
			SELECT 	@dec_price = price
			FROM 	part_customer_price_matrix  
			WHERE 	part = @part AND 
				customer = @customer AND  
				qty_break = @dec_qty_break   
		else
			return @dec_std_price
	end
	if isnull ( @dec_price, 0 ) = 0 
		select @dec_price = @dec_std_price
	
	return @dec_price
end -- (1A)
go


print'
---------------------------------------
-- PROCEDURE:	msp_get_demand_quantity
---------------------------------------
'
if exists (select 1 from dbo.sysobjects where name='msp_get_demand_quantity' and type='P')
   drop procedure msp_get_demand_quantity
go
create procedure msp_get_demand_quantity (@part varchar(25)) as
begin -- (1b)
  declare @demand numeric(20,6),
          @woqty  numeric(20,6),
          @onhand numeric(20,6),
          @parttype char(1)
  begin transaction
  select @demand = sum(mps.qnty) - sum(mps.qty_assigned),
         @parttype = max(mps.type)
    from master_prod_sched as mps
   where mps.part = @part
  select @woqty = sum(wod.qty_required)
    from workorder_detail as wod
   where wod.part = @part
  select @onhand = pol.on_hand
    from part_online as pol
   where pol.part = @part
  select isnull(@demand,0), isnull(@woqty,0), isnull(@onhand,0), isnull(@parttype,'')
  commit transaction
end -- (1e)
go


if exists (select 1 from sysobjects where name='msp_get_part_info' and type='P')
	drop procedure msp_get_part_info
go
create procedure msp_get_part_info (
@part varchar(25), 
@qty numeric(20,6)) 
as
begin -- (1b)
------------------------------------------------------------------------------------------------
--	Modifications	08/08/02, HGP	Included seq as part of the where clause to get the 
--					primary machine of the part
------------------------------------------------------------------------------------------------
begin transaction
declare	@machine_no	varchar(10), 
	@due_date	datetime,     
	@process_id	varchar(25),
	@setup_time	numeric(15,7),
	@cycle_time	int,          
	@runtime	numeric(15,7),
	@cycle_unit	varchar(15), 
	@parts_per_hour numeric(20,6), 
	@parts_per_cycle numeric(20,6),
	@include_set_up char(1), 
	@parts_rate	int

select	@process_id = ISNULL(part_mfg.process_id,'NONE'),
	@cycle_time = part_mfg.cycle_time,
	@cycle_unit = part_mfg.cycle_unit,
	@parts_per_hour = ISNULL(part_mfg.parts_per_hour,1),
	@parts_per_cycle = part_mfg.parts_per_cycle,
	@setup_time = isnull(part_mfg.setup_time,0),     
	@runtime = isnull(@qty,0) * isnull((1 / isnull(part_mfg.parts_per_hour,1)),0),
	@machine_no = part_machine.machine,
	@due_date = getdate()
from	part_mfg,
	part_machine
where	(part_mfg.part=@part and part_machine.part=@part and part_machine.sequence=1)

IF @process_id IS NULL 
	select @process_id = 'NONE'

select	@include_set_up = isnull(include_setuptime,'N')
from	parameters

-- include setup time with runtime is if it is set to Y in parameter table
IF (@include_set_up = 'Y')
	select @runtime = isnull(@runtime,0) + isnull(@setup_time,0)

-- if the machine no is null get it from part_inventory table 
IF (@machine_no IS NULL)
	select	@machine_no=primary_location
	from	part_inventory
	where	(part=@part)

if (@cycle_time=0 or @cycle_time is null)
	select	@parts_rate=1
else 
	select	@parts_rate=0
	
if @due_date IS NULL
	select	@due_date = getdate()

select	@process_id, @cycle_time, @cycle_unit, @parts_per_hour, @parts_per_cycle, @setup_time,
	@runtime, @machine_no, @due_date, @due_date, @due_date, @due_date, @parts_rate, 
	isnull(@include_set_up,'N')
	
commit transaction

end -- (1e)
go

if exists(select 1 from sysobjects where name='msp_wo_creation' and type='P')
   drop procedure msp_wo_creation
go
create procedure msp_wo_creation 
(@part       varchar(25),
@qty        numeric(20,6),
@due_date   datetime,
@process_id varchar(25),
@machine_no varchar(10),
@setup_time numeric(15,7),
@runtime    numeric(15,7),
@cycle_time int,          
@cycle_unit varchar(15), 
@parts_per_hour numeric(20,6), 
@parts_per_cycle numeric(20,6),
@startdate  datetime,
@enddate    datetime,
@returnvalue integer OUTPUT,
@eworkorder varchar(10),
@rworkorder varchar(10) OUTPUT) as
-------------------------------------------------------------------------------------------------
--	Procedure	msp_wo_creation
--	Purpose		To create manual work orders 
--	Arguments	Couple of them, see the above for list
--
--	Development	Developer	Date	Description
--			GPH		No idea	Created long time back
--			GPH		4/27/01	Included a procedure call at the end of the proc
--			GPH		8/8/02	Included work order as input and output argument
------------------------------------------------------------------------------------------------

begin -- (1b)
	declare	@work_order varchar(10),
		@woorder integer,
		@note varchar(255),
		@qty_tobeassigned numeric(20,6),
		@mps_qnty  numeric(20,6),
		@qty_remain numeric(20,6),
		@part_type char(1),
		@qnty numeric(20,6),
		@due datetime,
		@source integer, 
		@origin integer,
		@id integer,
		@updqty numeric(20,6),
		@totcount integer,
		@tool	varchar(10),
		@wonumber varchar(10),
		@seq integer
	create table #mps_temp 
		(qnty       numeric(20,6) null,
		part       varchar(25) not null,
		due        datetime not null,
		source     integer not null,
		origin     integer null,
		id         integer null )
	begin transaction 
	-- get next work order number from parameters table
	SELECT	@woorder=next_workorder
	FROM	parameters
	SELECT	@work_order=CONVERT(varchar,@woorder)    
	-- get the tool from part_machine_tool    
	SELECt	@tool = tool
	from	part_machine_tool
	where	part = @part

	SELECT	@note='Manual work order',
		@returnvalue = 0 

	SET rowcount 0 
	-- insert data into work order header                  
	INSERT 
	INTO	work_order 
		(work_order,machine_no,sequence,due_date,process_id,setup_time, 
		cycle_time,start_date,start_time,end_date,end_time,runtime,cycle_unit,
		note,order_no,destination,customer,tool)    
	VALUES	(@work_order,@machine_no,@woorder,@due_date,@process_id,@setup_time,
		@cycle_time,@startdate,@startdate,@enddate,@enddate,@runtime,@cycle_unit,
		@note,0,'','', @tool) 
	if (@@rowcount <= 0)
		select @returnvalue = -1  
	else  
	begin  
	-- insert data into work order detail
	INSERT 
	INTO	workorder_detail
		(workorder,part,qty_required,qty_completed,parts_per_cycle,run_time,
		balance,parts_per_hour) 
	VALUES (@work_order,@part,@qty,0,@parts_per_cycle,@runtime,@qty,
		@parts_per_hour)
	if (@@rowcount <= 0)
		select @returnvalue = -2  
	-- get next work order number
	UPDATE parameters SET next_workorder=@woorder+1
	if (@@rowcount <= 0)
		select @returnvalue = -3  
	end 

	if (@returnvalue = 0)
		execute msp_update_mps_assignedqty @part, @returnvalue 

	if (@returnvalue <> 0)
		rollback transaction
	else
	begin
		commit transaction
		select @rworkorder = @work_order
		--	Added this procedure call, so that, it recalc runtime for that machine 
		--	and re-sequences work orders on that machine
		execute msp_recalc_tasks @machine_no
	end	
		
	set rowcount 0    
end -- (1e)
go

print '
------------------------------------------
-- PROCEDURE:	msp_update_mps_assignedqty
------------------------------------------
'
if exists(select 1 from dbo.sysobjects where name='msp_update_mps_assignedqty' and type='P')
   drop procedure msp_update_mps_assignedqty
go

create procedure msp_update_mps_assignedqty (@part varchar(25), @rtnval int OUTPUT) as
begin -- (1b)
  declare @qty_tobeassigned numeric(20,6),
          @qty_remain numeric(20,6),
          @part_type char(1),
          @qnty numeric(20,6),
          @due datetime,
          @source integer, 
          @origin integer,
          @id integer,
          @updqty numeric(20,6),
          @totcount integer
  create table #mps_temp 
         (qnty       numeric(20,6) null,
          part       varchar(25) not null,
          due        datetime not null,
          source     integer not null,
          origin     integer null,
          id         integer null )
  begin transaction     
  select @rtnval = 0  
  -- set qty_assigned to 0 in mps table for that part,
  -- get sum of qty_required from workorder_detail table
  -- process row by row for that part in mps table to set the assigned quantity until the qty 
  -- becomes zero
  -- update mps qty assigned column with 0 for that part
  set rowcount 0 
  UPDATE master_prod_sched
      SET qty_assigned = 0 
    WHERE part = @part   
  if @@rowcount > 0 
   begin -- (2b)
     -- get part type
     SELECT @part_type=class
       FROM part
      WHERE part=@part
     -- get the qty to be assigned from either of the table 
     if @part_type = 'M'
        SELECT @qty_tobeassigned=isnull(sum(qty_required),0)
          FROM workorder_detail
         WHERE (part=@part)
     else if @part_type = 'P'
        SELECT @qty_tobeassigned=isnull(sum(standard_qty),0)
          FROM po_detail  
         WHERE (po_detail.status <> 'C') AND (po_detail.part_number = @part )
     -- insert rows into temp table
     insert into #mps_temp (qnty, part, due, source, origin, id)
     select qnty, part, due, source, origin, id
       from master_prod_sched
      where (part=@part)
      order by start_time
     -- get total count
     SELECT @totcount = count(*)
       FROM #mps_temp
     if @totcount > 0 
      begin -- (3b) 
        set rowcount 1 
        select @qnty = qnty,
               @due  = due,
               @source = source,
               @origin = origin,
               @id = id
          from #mps_temp             
        while (@qty_tobeassigned > 0 and @@rowcount > 0) 
         begin -- (4b)
           If @Qty_tobeassigned > @qnty 
              select @updqty = @qnty, @qty_tobeassigned = @qty_tobeassigned - @qnty
           else 
            begin 
              select @updqty = @qty_tobeassigned
              select @qty_tobeassigned = 0
            end
           if @updqty > 0  
            begin
              set rowcount 0 
              update master_prod_sched
                 set qty_assigned = @updqty
               where (part=@part and due=@due and source=@source and id=@id)
	         set rowcount 0 
                 delete
                   from #mps_temp 
                  where (part=@part and due=@due and source=@source and id=@id)
                 set rowcount 1 
                 select @qnty = qnty,
                        @due  = due,
                        @source = source,
                        @origin = origin,
                        @id = id
                   from #mps_temp              
            end 
         end --(4e)
        select @rtnval = 0  
      end -- (3e)
   end -- (2e) 
  if @rtnval <> 0 
     rollback transaction
  else 
     commit transaction 
  set rowcount 0    
end -- (1e)
go



print '
---------------------------------------
-- PROCEDURE:	msp_productionpotential
---------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_productionpotential') )
	drop procedure msp_productionpotential
GO

create procedure msp_productionpotential
(	@part	varchar (25) )
as

--	1.	Declare local variables.
declare @current_level int
declare @count int
declare	@childpart varchar (25)
declare	@onhand	numeric(20,6)
declare @bqty	numeric(20,6)
declare @cpart	varchar ( 25 )
declare	@pptime numeric(20,6)

--	2.	Create temporary table for exploding components.
create table #stack 
(
	part	varchar (25),
	stack_level	int,
	quantity numeric (20, 6)
) 


create table #bomparts (part varchar(25),
			levl integer,
			qty numeric(20,6) )		

create table #bparts (	part varchar(25),
			qty numeric ( 20, 6 ),
			onhand numeric(20,6) null)
			
--	3,	Declare trigger for looping through parts at current low level.
declare	childparts cursor for
select	part
from	#stack
where	stack_level = @current_level

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

--	5.	If rows found, loop through current level, adding children.
if @@rowcount > 0 
	select @count = 1
else
	select @count = 0

while @count > 0
begin

--	6.	Add components for each part at current level using cursor.
	select @count = 0

	open childparts

	fetch	childparts
	into	@childpart

	while @@fetch_status = 0
	begin

--	7.	Store level and total usage at this level for components.
		insert	#stack
		select	bom.part,
			@current_level + 1,
			bom.quantity * (
			select	sum ( #stack.quantity )
			from	#stack
			where	#stack.part = @childpart and
				#stack.stack_level = @current_level )
		from	bill_of_material as bom
		where	bom.parent_part = @childpart

		select	@count = 1

		fetch	childparts
		into	@childpart
	end

	close childparts
	
--	8.	Continue incrementing level as long as new components are added.
	if @count = 1
		select @current_level = @current_level + 1
end

--	9.	Deallocate components cursor.
deallocate childparts

--	10.	Insert the parts into another temp table
insert into #bomparts
select part, max ( stack_level ), sum ( quantity )
from #stack
group by part
order by max ( stack_level )

--	11.	Insert the parts & onhand into another temp table
insert into #bparts
select	bmp.part,
	bmp.qty,
	isnull(pol.on_hand,0)
from	#bomparts bmp
	join part_online pol on pol.part = bmp.part

--	12.	Get Min on hand from the temp table
select	@onhand = isnull(min(onhand),0) from #bparts

--	13.	Get the part & bom qty for that onhand
select	@cpart = part,
	@bqty  = qty
from	#bparts
where	onhand = @onhand

--	14.	Get the parts per hour from part machine 
select	@pptime = parts_per_hour
from	part_mfg
where	part = @cpart

--	12.	Return result set.	
select @cpart part, @onhand onhand, (isnull((@onhand * @bqty),0)/isnull(@pptime,1)) pptime
GO

----------------------------------------
--	procedure:	msp_recalc_tasks
----------------------------------------
if exists (
	(	select	*
		from	sysobjects
		where	id = object_id ( 'msp_recalc_tasks' ) ) )
	drop procedure msp_recalc_tasks
go

create procedure msp_recalc_tasks
(	@machine_no	varchar (10) = null )
---------------------------------------------------------------
--	Purpose:
--
--	This procedure recalculates the runtimes and begin and
--	end times for the tasks on a single machine (pass
--	argument) or all machines (no argument).
--
--	Arguments:
--
--	MachineNO	Optional.
--
--	History:
--
--	19 Nov 1999	Eric Stimpson	Created.
--	07 Jan 2000	Harish Gubbi	Moved the Initialization of start date inside the loop & changed the statement too
--	05 May 2000	Harish Gubbi	Moved the wocursor declaration & deallocation with in the loop, from sql7 POV
--	07 Apr 2002	Harish Gubbi	Included a isnull function on the runtime calculation, as that was causing not to show up in pb
--
--	Process:
--
--	I.	Declarations.
--		A.	Declare variables.
--		B.	Declare cursor.
--		C.	Create temporary storage for machine schedule.
--	II.	Recalculate machines.
--		A.	Open list of machines.
--		B.	Get first machine [only machine if machine was passed].
--		C.	Loop while more machines.
--			1.	Initialize start date, 
--			2.	Prepare work orders.
--				a.	Recalculate balance.
--				b.	Negate sequence.
--			3.	Initialize variables.
--				a.	Initialize the sequence, accumulative runtime, wo start and wo start offset.
--				b.	Initialize temporary machine schedule.
--				c.	Initialize temporary w(tx).  [accumulative work at time x]
--			4.	Recalculate work orders.
--				 .	Declare cursor.
--				a.	Open list of work orders.
--				b.	Get first work order.
--				c.	Loop while more work orders.
--					1)	Set sequence, start date and time, and runtime for this work order.
--					2)	Calculate end_dt for this work order, wo start.
--					3)	Increment sequence.
--					4)	Get next work order.
--				d.	Close work order list.
--				 .	Deallocate cursor
--			5.	Get next machine
--		D.	Close machine list.
---------------------------------------------------------------
as

begin transaction
--	I.	Declarations.
--		A.	Declare variables.
declare	@resource_name	varchar (10),
	@sequence	integer,
	@start		datetime,
	@workorder	varchar (10),
	@wostart	datetime,
	@wostartoffset	real,
	@runtime	real,
	@accumruntime	real

--		B.	Declare cursor.
declare	resourcecursor cursor for
select distinct work_order.machine_no
from	work_order
	join machine on work_order.machine_no = machine.machine_no
where	work_order.machine_no = IsNull ( @machine_no, work_order.machine_no )

/*
declare wocursor cursor for
select	work_order
from	work_order
where	machine_no = @resource_name
order by sequence desc, work_order
*/

--		C.	Create temporary storage for machine schedule.
create table #schedule
(	begin_dt	datetime,
	runtime		real )

create table #workattimex
(	timex		real,
	accumwork	real )

--	II.	Recalculate machines.
--		A.	Open list of machines.
open resourcecursor

--		B.	Get first machine [only machine if machine was passed].
fetch	resourcecursor
into	@resource_name

--		C.	Loop while more machines.
while ( @@fetch_status = 0 )
begin -- (1B)
--			1.	Initialize start date.
	select	@start = isnull ((select	Getdate()
				from	shop_floor_calendar
				where	machine = @resource_name and
					Getdate() between begin_datetime and end_datetime),
				(select	isnull( min ( begin_datetime ), GetDate() ) 
				from	shop_floor_calendar
				where	machine = @resource_name and
				begin_datetime >= Getdate()) )

--			2.	Prepare work orders.
--				a.	Recalculate balance.
	update	workorder_detail
	set	balance = qty_required - qty_completed
	where	balance <> qty_required - qty_completed and
		workorder in
		(	select	work_order
			from	work_order
			where	machine_no = @resource_name )
	
--				b.	Negate sequence.
	update	work_order
	set	sequence = -sequence
	where	sequence < 0 and
		machine_no = @resource_name
	
	update	work_order
	set	sequence = -sequence
	where	machine_no = @resource_name
	
--			3.	Initialize variables.
--				a.	Initialize the sequence, accumulative runtime, wo start and wo start offset.
	select	@sequence = 1,
		@wostartoffset = 0,
		@accumruntime = 0,
		@wostart = @start
	
--				b.	Initialize temporary machine schedule.
	delete	#schedule
	
	insert	#schedule
	select	begin_datetime,
		Convert ( real, DateDiff ( minute, begin_datetime, end_datetime ) ) / 60
	from	shop_floor_calendar
	where	machine = @resource_name and
		begin_datetime >= @start
	
	insert	#schedule
	select	@start,
		Convert ( real, DateDiff ( minute, @start, end_datetime ) / 60 )
	from	shop_floor_calendar
	where	machine = @resource_name and
		@start between begin_datetime and end_datetime
	
	insert	#schedule
	select	@start,
		0
--				c.	Initialize temporary w(tx).  [accumulative work at time x]
	delete	#workattimex
	
	insert	#workattimex
	select	Convert ( real, DateDiff ( minute,
			(	select	min ( trs1.begin_dt )
				from	#schedule trs1 ), begin_dt ) ) / 60,
		IsNull (
			(	select	sum ( runtime )
				from	#schedule trs1
				where	trs1.begin_dt < trs.begin_dt ), 0 )
	from	#schedule trs

--	declare the cursor 		
	declare wocursor cursor for
	select	work_order
	from	work_order
	where	machine_no = @resource_name
	order by sequence desc, work_order
	
--			4.	Recalculate work orders.
--				a.	Open list of work orders.
	open wocursor
	
--				b.	Get first work order.
	fetch	wocursor
	into	@workorder
	
--				c.	Loop while more work orders.
	while ( @@fetch_status = 0 )
	begin -- (2B)
	
--					1)	Set sequence, start date and time, and runtime for this work order.
		update	work_order
		set	sequence = @sequence,
			start_date = @wostart,
			start_time = @wostart,
			runtime =
			(	select	Max ( isnull(balance / IsNull ( pm.parts_per_hour, pmp.parts_per_hour ),0) +
					(	case	when IsNull ( include_setuptime, 'N' ) = 'Y' then IsNull ( IsNull ( pm.setup_time, pmp.setup_time ), 0 )
							else 0
						end ) )
				from	workorder_detail wod
					left outer join part_machine pm on wod.part = pm.part and
						pm.machine = @resource_name
					left outer join part_machine pmp on wod.part = pmp.part and
						pmp.sequence = 1
					cross join parameters
				where	workorder = @workorder )
		from	work_order
		where	work_order = @workorder
		
--					2)	Calculate end_dt for this work order, wo start.
		select	@runtime = Convert ( real, runtime )
		from	work_order
		where	work_order = @workorder
		
		select	@accumruntime = @accumruntime + @runtime
		
		delete	#workattimex
		where	accumwork <
			(	select	max ( accumwork )
				from	#workattimex
				where	accumwork < @accumruntime )
		
		select	@wostartoffset = timex + @accumruntime - accumwork
		from	#workattimex
		where	accumwork =
			(	select	max ( accumwork )
				from	#workattimex
				where	accumwork < @accumruntime )
		
		select	@wostart = DateAdd ( minute, @wostartoffset * 60, @start )
		
		update	work_order
		set	end_date = @wostart,
			end_time = @wostart 
		where	work_order = @workorder
		
--					3)	Increment sequence.
		select	@sequence = @sequence + 1
	
--					4)	Get next work order.
		fetch	wocursor
		into	@workorder
	end -- (2B)
	
--				d.	Close work order list.
	close	wocursor
	deallocate wocursor	
--			5.	Get next machine
	fetch	resourcecursor
	into	@resource_name
end -- (1B)

--		D.	Close machine list.
close	resourcecursor

deallocate resourcecursor
commit transaction
go

print'
--------------------------------
-- PROCEDURE:	msp_jobstatusall
--------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'msp_jobstatusall' and type='P')
	drop procedure msp_jobstatusall
go
create procedure msp_jobstatusall ( @workorder varchar(10) ) as
--	Declare variables
declare	@jcqty	numeric(20,6),
	@miqty	numeric(20,6),
	@objectsproduced numeric(20,6),
	@avgtimeperobject numeric(20,6),
	@objectsused	numeric(20,6),
	@avgtimebetissues numeric(20,6),
	@defectsperobject numeric(20,6),
	@avgtimebetdefects numeric(20,6),	
	@downtimeevents numeric(20,6),
	@avgtimebetdowntime numeric(20,6),	
	@operatorslogged numeric(20,6),
	@avgtimeoflog	numeric(20,6),		
	@part	varchar(25),
	@defectsqty	numeric(20,6),
	@packagetype	varchar(10),
	@packageqty	numeric(20,6),
	@startdate	datetime,
	@enddate	datetime,
	@woqty		numeric(20,6),
	@woobjects	integer,
	@stdate		datetime,
	@eddate		datetime,
	@hrs		numeric(6,2),
	@defectshrs	numeric(6,2),
	@defectsevents	numeric(20,6),
	@downtimehrs	numeric(6,2),
	@laborhrs	numeric(6,2),
	@std_runtime	numeric (20,6),
	@pre_runtime	numeric (20,6), 
	@act_runtime	numeric (20,6),
	@jobcomplete	numeric (20,6),
	@materialissues	numeric (20,6)

--	Get startdatetime & enddatetime of the job	
select	@hrs = datediff(hh, start_date, end_date) + datediff(hh,start_time, end_time)
from	work_order 
where	work_order = @workorder

--	Get workorder quantity
select	@std_runtime 	= isnull(max(qty_required),0) / isnull(parts_per_hour,1), 
	@pre_runtime 	= isnull(max(balance),0) / isnull(parts_per_hour,1), 
	@act_runtime	= max(run_time),
	@jobcomplete	= ((sum(qty_completed) * 100) / isnull(sum(qty_required),1 ) ),
	@woqty		= isnull(sum(qty_required),0)
from	workorder_detail 
where	workorder = @workorder
group by qty_required, balance, parts_per_hour

--	Get job complete quantity from audit_trail for the passed workorder
select	@jcqty = isnull ( sum(quantity), 0 ),
	@objectsproduced = isnull ( count ( 1 ), 0) 
from	audit_trail
where	workorder = @workorder and type = 'J'

--	Get material issue quantity from audit_trail for the passed workorder
select	@miqty = isnull ( sum ( quantity ), 0) ,
	@objectsused = isnull ( count ( 1 ), 0 )  
from	audit_trail
where	workorder = @workorder and type = 'M'

--	Get defects quantity 
select 	@defectsqty = isnull ( sum ( quantity ) , 0) ,
	@defectsevents = isnull(count(1),0)
from	defects
where	work_order = @workorder

if @defectsevents = 0 
	select @defectsevents = 1.0

select	@stdate = min ( defect_date ), 
	@eddate = max ( defect_date )
from	defects
where	work_order = @workorder

select	@defectshrs = isnull( datediff(hh, @stdate, @eddate), 0 )

--	Get downtime quantity
select	@downtimeevents = isnull ( count(1), 0 ),
	@downtimehrs = isnull ( sum ( down_time ), 0 )
from	downtime
where	job = @workorder

--	Get labor recordings
select	@operatorslogged = isnull ( count(1), 0 ) 
from	shop_floor_time_log
where	work_order = @workorder

select	@laborhrs = isnull ( sum( labor_hours ), 0)
from	shop_floor_time_log
where	work_order = @workorder

select	@packageqty = isnull(@packageqty,1.0),
	@objectsproduced = isnull(@objectsproduced,1.0),
	@woobjects = isnull(@woobjects,1.0),
	@defectsperobject = @defectsqty / isnull(@defectsevents,1.0),
	@downtimeevents = isnull(@downtimeevents,1.0),
	@operatorslogged = isnull(@operatorslogged,1.0)	

if @woobjects > 0 	
	select	@avgtimeperobject= isnull((@objectsproduced) * (isnull(@hrs,0) / isnull(@woobjects,1)),0),
		@avgtimebetissues= isnull((@objectsused) * (isnull(@hrs,0) / isnull(@woobjects,1)),0)
else
	select	@avgtimeperobject=0,
		@avgtimebetissues=0
		
if @defectsperobject > 0 
	select	@avgtimebetdefects= isnull(@defectshrs,0) / isnull ( @defectsevents,1)
else
	select	@avgtimebetdefects= 0

if @downtimeevents > 0 
	select	@avgtimebetdowntime= isnull(@downtimehrs,0) / isnull ( @downtimeevents,1)
else
	select	@avgtimebetdowntime= 0
		
if @operatorslogged > 0 
	select	@avgtimeoflog = isnull(@laborhrs,0) / isnull ( @operatorslogged,1)
else
	select	@avgtimeoflog = 0			

if @woqty > 0 
	select	@materialissues = isnull(((isnull(@miqty,0) / isnull (@woqty,1)) * 100),0)
else
	select	@materialissues = 0	
	
--	Display results
select	@objectsproduced, 
	@avgtimeperobject, 
	@objectsused, 
	@avgtimebetissues, 
	@defectsperobject, 
	@avgtimebetdefects, 
	@downtimeevents, 
	@avgtimebetdowntime, 
	@operatorslogged,
	@avgtimeoflog,
	@std_runtime, 
	@pre_runtime, 
	@act_runtime, 
	@jobcomplete, 
	@materialissues,
	@downtimehrs, 
	@defectsqty, 
	@laborhrs,
	@jcqty,
	@miqty	
go


print '
-----------------------
-- PROCEDURE:	msp_jcs
-----------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'msp_jcs' and type = 'P')
	drop procedure msp_jcs
go

create procedure msp_jcs (@workorder varchar (10) ) as
--	Declare
declare	@aqty	numeric(20,6),
	@acost	numeric(20,6),
	@part	varchar(25),
	@scost	numeric(20,6),
	@woqty	numeric(20,6),
	@wopart	varchar(25),
	@scrapqty	numeric(20,6),
	@downtimeqty	numeric(20,6),
	@laborqty	numeric(20,6),
	@downtimerate	numeric(20,6),
	@laborrate	numeric(20,6),
	@machine	varchar(10)

--	Get the machine on the workorder
select	@machine = machine_no
from	work_order
where	work_order = @workorder

--	Get the workorder part
select	@wopart = min(part)
from	workorder_detail
where	workorder = @workorder

--	Get the workorder qty for the part & workorder
select	@woqty = isnull ( sum ( qty_required ), 0)
from	workorder_detail
where	workorder = @workorder and
	part = @wopart

--	Get all the material issues done against the current workorder
select	@aqty	=	sum( quantity ),
	@acost	=	max( cost ),
	@part	=	min( part ) 
from	audit_trail 
where 	workorder = @workorder and 
	type = 'M'

if @acost is null
begin -- 1b
	select	@acost = isnull ( cost_cum, 1 ) 
	from	part_standard
	where	part = @part
end -- 1b

--	Get scrap quantity
select	@scrapqty = isnull ( sum ( quantity ), 0)
from	defects
where	work_order = @workorder

--	Get the downtime & rate
select	@downtimeqty = isnull ( sum ( down_time ), 0)
from	downtime
where	job = @workorder

--	Get downtime rate 
select	@downtimerate = isnull ( standard_rate, 0 )
from	machine
where	machine_no = (select distinct machine from downtime where job = @workorder ) 

--	Get the labor hours & rate
select	@laborqty = sum ( labor_hours )
from	shop_floor_time_log
where	work_order = @workorder

--	Get the labor rate
select	@laborrate = isnull ( standard_rate, 0 )
from	labor
where	id = (select min(labor_code) from part_machine where part = @wopart ) 

--	Get the standard cost for the part
select	@scost = isnull ( cost_cum, 1 ) 
from	part_standard
where	part = @wopart

--	Display results
select	isnull((@aqty * @acost),0), isnull((@scost * @woqty),0), isnull((@scrapqty * @scost),0), isnull((@downtimeqty * @downtimerate),0), isnull((@laborqty * @laborrate),0)
go



print '
----------------------------------
-- PROCEDURE:	msp_calculateyield
----------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_calculateyield'))
	drop procedure msp_calculateyield
GO

create procedure msp_calculateyield (
@part	varchar(25),
@requiredqty numeric(20,6), 
@workorder varchar(10) ) as
-------------------------------------------------------------------------------------------------
--	Name : msp_calculateyield
--
--	Purpose:	To calculate the yield for graph purposes
--
--	Arguments:	@part varchar			Part for which yield has to be computed
--			@requiredqty numeric(20,6)	Required or demand quantity
--			@workorder varchar(10)		Work order no to get the Material issues from Audit trail
--	
--	Development	GPH	12/12/99	Original
--			GPH	04/25/00	Modified the where clause (eliminated part in the where clause
--						from audit trail select
-------------------------------------------------------------------------------------------------
--	1.	Declare local variables.
declare @completedqty numeric(20,6)

--	2.	Create temporary table for exploding components.
create table #bomparts (part	varchar(25),
			bomqty	numeric(20,6) )
			
create table #bpartsqty (part	varchar(25),
			qty	numeric(20,6))

--	3.	Get components parts
insert	into #bomparts
select	part, quantity
from	bill_of_material
where	parent_part = @part

--	4.	Get the materials issued for the above part from audit_trail
select	@completedqty = isnull(sum(quantity),0)
from	audit_trail
where	workorder = @workorder and type = 'M'

--	5.	Insert data into the temp table
insert	into #bpartsqty
select	part, isnull( bomqty, 0) * isnull(@requiredqty ,0)
from	#bomparts
union	all
select	part, isnull( bomqty, 0) * isnull(@completedqty ,0)
from	#bomparts

--	6.	Display results
select	part, qty from #bpartsqty
GO



print '
---------------------------------------
-- PROCEDURE:	msp_packlineobjectslist
---------------------------------------
'
if exists ( select 1 from sysobjects where name = 'msp_packlineobjectslist' and type = 'P')
	drop procedure msp_packlineobjectslist
go
create procedure msp_packlineobjectslist (@aishipper integer, @asorigin varchar ( 10)=null) as
if len ( @asorigin )  > 1
	select	serial,   
		part,   
		quantity,   
		unit_measure,   
		std_quantity,   
		weight,   
		type,
		parent_serial  
	from	object  
	where	shipper = @aishipper
	union
	select	serial,   
		part,   
		quantity,   
		unit_measure,   
		std_quantity,   
		weight,   
		type,
		parent_serial  
	from	object  
	where	origin = isnull(@asorigin,'')
	order by 1 asc
else
	select	serial,   
		part,   
		quantity,   
		unit_measure,   
		std_quantity,   
		weight,   
		type,
		parent_serial  
	from	object  
	where	shipper = @aishipper
	order by 1 asc
go

print '
-------------------------------------
-- PROCEDURE:	msp_ole_documentslist
-------------------------------------
'
if exists (select 1 from dbo.sysobjects where id = object_id('msp_ole_documentslist'))
	drop procedure msp_ole_documentslist
GO
create procedure 	msp_ole_documentslist (@machineno varchar(10), @part varchar(25), @workorder varchar(10)) as
select	distinct wod.part,
	ole.id
from	work_order wo
	left outer join	workorder_detail wod on wod.workorder = wo.work_order
	left outer join	issues iss on iss.product_code = wod.part or product_component = wod.part and iss.status = 'Assigned'
	join	ole_objects ole on ole.parent_id = convert(varchar, iss.issue_number)
where 	wo.machine_no = @machineno and
	wod.part = @part and 
	wo.work_order = @workorder
go

print '
-----------------------------------
-- PROCEDURE:	msp_labelsfromorder
-----------------------------------
'
if exists ( select 1 from sysobjects where name = 'msp_labelsfromorder' )
	drop procedure msp_labelsfromorder
go

create procedure msp_labelsfromorder ( @order integer, @part varchar(25) )
as
	select	box_label,
		pallet_label
	from	order_detail
	where	order_no = @order and
		part_number = @part and
		due_date = (	select	min(due_date)
				from	order_detail
				where	order_no = @order and
					part_number = @part )

go

print '
----------------------------
-- PROCEDURE:	msp_getnotes
----------------------------
'
if exists ( select 1 from sysobjects where name = 'msp_getnotes' and type = 'P')
	drop procedure msp_getnotes
go

create procedure msp_getnotes 
(@part varchar(25) = null, 
 @orderno numeric ( 8,0) = null ) as
----------------------------------------------------------------------------------------------
--
--	Procedure to append notes from different tables required to store in work orders
--
--	Parameters	@part		- part
--			@orderno	- order no
--
--	Developed	Harish Gubbi 	11/23/99
--
--	Declarations
--	Initilization
--	Get activity router notes
--	Get notes for shipper & bill of lading
--	Append values to notes
--	Get notes from order_header
--	Append values to notes
--	Get notes from order_header
--	Append values to notes
----------------------------------------------------------------------------------------------

--	Declarations
declare @notes		varchar(255),
	@destination	varchar(10),
	@notestemp1	varchar(255),
	@notestemp2	varchar(255)

--	Initilization
select	@notes=''

--	Get activity router notes
select	@notes = isnull(notes,'')
from	activity_router
where	parent_part = @part and
	sequence = 1
	
--	Get notes for shipper & bill of lading
select	@notestemp1 = isnull(note_for_shipper,''),
	@notestemp2 = isnull(note_for_bol,'')
from	destination_shipping
	join order_header od on od.destination = destination_shipping.destination
where	od.order_no = @orderno 			

--	Append values to notes
select	@notes = isnull(rtrim(@notes),'') + isnull(@notestemp1,'') + isnull(@notestemp2,'')

--	Get notes from order_header
select	@notestemp1 = notes
from	order_header
where	order_no = @orderno

--	Append values to notes
select	@notes = isnull(rtrim(@notes),'') + isnull(@notestemp1,'')

--	Get notes from order_header
select	@notestemp1 = notes
from	order_detail
where	order_no = @orderno and
	part_number = @part

--	Append values to notes
select	@notes = isnull(rtrim(@notes),'') + isnull(@notestemp1,'')

select	@notes

go


print '
-------------------------------
-- PROCEDURE:	msp_getmpsparts
-------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'msp_getmpsparts' and type = 'P')
	drop procedure msp_getmpsparts
go
create procedure msp_getmpsparts (@machine varchar (10) ) as
select	distinct part
from	master_prod_sched
where	machine = @machine
go




print '
-------------------------------------
-- PROCEDURE:	msp_retrieve_bomparts
-------------------------------------
'
if exists (select 1 from dbo.sysobjects where name = 'msp_retrieve_bomparts' )
	drop procedure msp_retrieve_bomparts
go 

create procedure msp_retrieve_bomparts ( @part varchar ( 25 ) ) as
declare @bomlevel integer,
	@sequence integer,
	@childpart varchar(25),
	@bomqty	decimal(20,6),
	@bomq	varchar(20),
	@lseq	integer,
	@count  integer,
	@parentseq integer
	

create table #bomparts (
	parentpart	varchar ( 25) null,
	part 		varchar ( 25) not null,
	bomqty		decimal (20,6) not null,
	bomlevel	integer	not null,
	sequence	integer	not null,
	parentseq	integer not null) 

select  @bomlevel = 1, @sequence = 1, @lseq = 1, @parentseq = 1

insert into #bomparts values ( null, @part , 1 , @bomlevel, @sequence, @parentseq )

select 	@part = min(part),
	@count= count ( * ),
	@bomlevel = min(bomlevel),
	@parentseq= (select sequence from #bomparts where sequence = @lseq)
from 	#bomparts where sequence = @lseq

while @count > 0 
begin

	declare bomparts cursor for 
	select 	part, 
		convert(varchar(20),quantity)
	from 	bill_of_material 
	where	parent_part = @part
	
	open 	bomparts
	fetch 	bomparts into @childpart, @bomq
			
	while @@fetch_status = 0 
	begin
	
		select @sequence = @sequence + 1		
		insert into #bomparts 
		values ( @part , @childpart, convert(numeric ( 20,6), @bomq) , @bomlevel + 1, @sequence, @parentseq )
	
		fetch 	bomparts into @childpart, @bomq
	end 
	
	close bomparts
	
	deallocate bomparts
	
	select @lseq = @lseq + 1

	select 	@part = min(part),
		@count= count ( * ),
		@bomlevel = min(bomlevel),
		@parentseq= (select sequence from #bomparts where sequence = @lseq)
	from 	#bomparts where sequence = @lseq
	
end 	
select * from #bomparts
go


print '
--------------------------------------
-- PROCEDURE:	msp_customer_scorecard
--------------------------------------
'
if exists (	select	1
		from	dbo.sysobjects
		where	name = 'msp_customer_scorecard' )
	drop procedure msp_customer_scorecard
go

create procedure msp_customer_scorecard (	@customer varchar(25) )
as
begin
--	GPH 12/26/00 Modified the select statement on open orders as it was summing up wrongly.
--	GPH 03/10/01 Include a select statement to get the time portion of the datetime column
--			on both start and end datetime columns
--	GPH 12/21/01 Included table prefix on status column on couple of select statement


	declare	@start_date		datetime,
		@end_date		datetime,
		@quote_count		integer,
		@quote_amount		decimal(20,6),
		@order_count		integer,
		@order_amount		decimal(20,6),
		@shipsched_count	integer,
		@shipsched_amount	decimal(20,6),
		@shiphist_count		integer,
		@shiphist_amount	decimal(20,6),
		@issues_count		integer,
		@pastdue_count		integer,
		@pastdue_amount		decimal(20,6),
		@return_count		integer,
		@return_amount		decimal(20,6),
		@closure_rate		decimal(20,6),
		@closure_right		decimal(20,6),
		@closure_left		decimal(20,6),
		@ontime_rate		decimal(20,6),
		@ontime_right		decimal(20,6),
		@ontime_left		decimal(20,6),
		@return_rate		decimal(20,6),
		@return_right		decimal(20,6),
		@return_left		decimal(20,6),
		@order_blanket_amount	decimal(20,6),
		@order_normal_amount	decimal(20,6)
		
	if ( select count(customer) from customer_additional where customer = @customer ) < 1
		insert into customer_additional ( customer, type ) values ( @customer, ' ' )
		
	select	@start_date = isnull(start_date,dateadd ( yy, -5, GetDate ( ) ) ),
		@end_date = isnull(end_date,dateadd ( yy, 5, GetDate ( ) ) )
	from	customer_additional
	where	customer = @customer
	
	select	@start_date = convert(datetime, (convert(varchar,datepart(yy,@start_date))+'/'+convert(varchar,datepart(mm,@start_date))+'/'+convert(varchar,datepart(dd,@start_date))+' 00:00:01')),
 		@end_date = convert(datetime, (convert(varchar,datepart(yy,@end_date))+'/'+convert(varchar,datepart(mm,@end_date))+'/'+convert(varchar,datepart(dd,@end_date))+' 23:59:59'))
	
	-- Get the # and $ of quotes for this customer
	select	@quote_count = count(q.quote_number)
	from	quote q
	where 	q.status <> 'C' and 
		q.customer = @customer and 
		q.quote_date >= @start_date and 
		q.quote_date <= @end_date
				
	if @quote_count > 0
		select	@quote_amount = sum(qd.quantity * qd.price)
		from	quote q,
			quote_detail qd
		where 	q.quote_number = qd.quote_number and
			q.status <> 'C' and 
			q.customer = @customer and 
			q.quote_date >= @start_date and 
			q.quote_date <= @end_date
	else
		select @quote_amount = 0
				
	-- Get the # and $ of orders for this customer
	select	@order_count = count(order_no) 
	from 	order_header 
	where 	isnull(order_header.status,'') <> 'C' and 
		customer = @customer and 
		order_date >= @start_date and 
		order_date <= @end_date
	
	if @order_count > 0
		select	@order_amount = sum(IsNull(od.alternate_price,0) * isnull(od.quantity,0))
		from	order_header oh,
			order_detail od
		where 	oh.order_no = od.order_no and
			isnull(oh.status,'') <> 'C' and 
			oh.customer = @customer and 
			oh.order_date >= @start_date and 
			oh.order_date <= @end_date
	else
		select @order_amount = 0
				
	
	-- Get the # and $ of ship schedules for this customer
	select	@shipsched_count = count(s.id)
	from	shipper s
	where	( s.status = 'O' or s.status = 'S' ) and 
		( s.type='O' or s.type='Q' or s.type='V' or s.type is null ) and 
		s.customer = @customer and 
		s.date_stamp >= @start_date and 
		s.date_stamp <= @end_date
	
	if @shipsched_count > 0
		select	@shipsched_amount = isnull(sum(IsNull ( sd.price, 0 ) * IsNull(sd.qty_packed,0)),0)
		from	shipper s,
			shipper_detail sd
		where	s.id = sd.shipper and
			( s.status = 'O' or s.status = 'S' ) and 
			( s.type='O' or s.type='Q' or s.type='V' or s.type is null ) and 
			s.customer = @customer and 
			s.date_stamp >= @start_date and 
			s.date_stamp <= @end_date
	else
		select @shipsched_amount = 0
	
	-- Get the # of ship histories for this customer
	select	@shiphist_count = count(s.id)
	from	shipper s
	where 	( s.status = 'C' or s.status = 'Z' ) and 
		( s.type='O' or s.type='Q' or s.type='V' or s.type is null ) and 
		s.customer = @customer  and 
		s.date_shipped >= @start_date and 
		s.date_shipped <= @end_date
				
	if @shiphist_count > 0
		select	@shiphist_amount = isnull(sum(IsNull(sd.price,0)*IsNull(sd.qty_packed,0)),0)
		from	shipper s,
			shipper_detail sd
		where 	s.id = sd.shipper and
			( s.status = 'C' or s.status = 'Z' ) and 
			( s.type='O' or s.type='Q' or s.type='V' or s.type is null ) and 
			s.customer = @customer  and 
			s.date_shipped >= @start_date and 
			s.date_shipped <= @end_date
	else
		select @shiphist_amount = 0
	
	-- Issues will go here
	select	@issues_count = count(issue_number)
	from	cs_issues_vw
	where	origin = @customer and
		type = 'O' and
		start_date >= @start_date and start_date <= @end_date
	
	
	-- Get the # of past due orders
	select	@pastdue_count = count(order_no) 
	from 	order_header 
	where 	datediff(day,(select min(due_date) from order_detail where order_detail.order_no = order_header.order_no),GetDate()) > 0 and 
		isnull(order_header.status,'') <> 'C' and 
		customer = @customer and 
		order_date >= @start_date and 
		order_date <= @end_date
	
	if @pastdue_count > 0
		select	@pastdue_amount = sum(IsNull ( od.alternate_price, 0 ) * isnull(od.quantity,0))
		from	order_header oh,
			order_detail od
		where 	oh.order_no = od.order_no and
			datediff(day,(select min(due_date) from order_detail where order_detail.order_no = oh.order_no),GetDate()) > 0 and 
			isnull(oh.status,'') <> 'C' and 
			customer = @customer and 
			order_date >= @start_date and 
			order_date <= @end_date
	else
		select @pastdue_amount = 0
	
	
	-- Get the # and $ of returns for this customer
	select	@return_count = count(customer)
	from	cs_returns_vw
	where 	cs_returns_vw.status <> 'C' and 
		customer = @customer and 
		date_stamp >= @start_date and 
		date_stamp <= @end_date
	
	if @return_count > 0
		select	@return_count = count(customer),
			@return_amount = isnull(sum(IsNull(qty_packed,0) * IsNull(price,0)),0)
		from	cs_rma_detail_vw
				join cs_returns_vw on id = shipper
		where	cs_returns_vw.status <> 'C' and 
			rmacustomer=@customer and
			customer = @customer and 
			date_stamp >= @start_date and 
			date_stamp <= @end_date
	else
		select @return_count = 0
			
	-- Get the closure rate for the date range given
	select	@closure_left = count(quote_number) 
	from	quote 
	where 	quote.status <> 'C' and 
		customer = @customer and 
		quote_date >= @start_date and 
		quote_date <= @end_date
	
	select	@closure_right = count(quote_number) 
	from	quote 
	where 	customer = @customer and 
		quote_date >= @start_date and 
		quote_date <= @end_date
	
	if @closure_right = 0
		select @closure_right = 1
		
	select @closure_rate = isnull(@closure_left,0) / isnull(@closure_right,1)
	
	
	-- Get the on-time delivery rating for the date range given
	select	@ontime_left = count(id) 
	from	shipper 
	where 	date_shipped is null and 
		customer = @customer and 
		date_stamp >= @start_date and 
		date_stamp <= @end_date
	
	select 	@ontime_right = count(id) 
	from	shipper 
	where 	customer = @customer and 
		date_stamp >= @start_date and 
		date_stamp <= @end_date
				
	if @ontime_right = 0
		select @ontime_right = 1
		
	select @ontime_rate = isnull(@ontime_left,0) / isnull(@ontime_right,1)
	
	
	-- Get the return rating for the date range given
	select	@return_left = sum(IsNull(qty_packed,0))
	from	cs_rma_detail_vw
			join cs_returns_vw on id = shipper
	where 	cs_returns_vw.status <> 'C' and 
		customer = @customer and 
		rmacustomer = @customer and 
		date_stamp >= @start_date and 
		date_stamp <= @end_date
	
	select	@return_right = sum(IsNull(sd.qty_packed,0)) 
	from	shipper s, 
		shipper_detail sd 
	where 	s.id = sd.shipper and 
		s.customer = @customer and 
		s.date_shipped >= @start_date and 
		s.date_shipped <= @end_date
				
	if @return_right = 0
		select @return_right = 1
		
	select @return_rate = isnull(@return_left,0) / isnull(@return_right,1)
	
	
	select	@quote_count,
		@quote_amount,
		@order_count,
		@order_amount,
		@shipsched_count,
		@shipsched_amount,
		@shiphist_count,
		@shiphist_amount,
		@issues_count,
		@pastdue_count,
		@pastdue_amount,
		@return_count,
		@return_amount,
		@closure_rate,
		@ontime_rate,
		@return_rate,
		@start_date,
		@end_date,
		@customer
		
end
go

print '
----------------------------
--	msp_scdatavalidation
----------------------------
'
if exists ( select 1 from sysobjects where name = 'msp_scdatavalidation' and type='P')
	drop procedure msp_scdatavalidation
go

create procedure	msp_scdatavalidation (@part varchar(25) = null)
as
----------------------------------------------------------------------------------------------------------------------
--	msp_scdatavalidation : To identify the invalid data elements before running super cop
--
--	parameters:	None 
--
--	process:
--	1.	Declarations
--	2.	Declare temp tables
--	3.	Insert part or parts from either passed value or from order_detail as these are all top level parts
--	4.	Initilize
--	5.	Get the temp table count
--	6.	Process all the level one parts
--	7.	Initilize the required variables with initial values
--	8.	Delete temp tables
--	9.	Insert row into vbom temp table	
--		10.	Delete temp table
--		11.	Get components for this current part
--		12.	Check whether the parent part exists in the components list
--		13.	On count being > 0 write to err temp table
--			14.	Check whether the part already exists in the err list temp table
--			15.	On count being > 0 write to err temp table
--			16.	Check whether the part exists in the vbom temp table
--				17.	Get bomlevel & tree from the temp table
--			18.	Process all the component parts	
--			19.	Get the 1st part for processing		
--				20.	Check whether the part is found in vbom temp table
--					21.	Check whether the part already exists in the err list temp table
--					22.	On count being = 0 write to err temp table
--					23.	write data to other temp tables				
--				24.	Get the 1st part for processing		
--		25.	update the temp table set processed with 0
--		26.	Get the next unprocessed part		
--	27.	Get the temp table count
--	28.	Display results
--
--	Purpose:
--	Check for all null std_qty in bill_of_material_ec 
--	Check for all null parts_per_hour in part_machine 
--	Check for all null row_id & std_qty in order_detail
--	Check for dead start date based on setup time, due date & other parameters. ??

--	Process :
--	1.	Declarations
--	1.1	Check for infinite bom (ie call msp_findinfinitebom procedure ) 
--	2.	Initialize
--	3.	Demand with std_qty having null values
--	4.	Demand with row_id having null values 
--	5.	Check any demand is there, if so proceed further
--	6.	Bom parts with std qty being null for the current level parts
--	7.	Parts with parts per hour being null for the current level parts
--	8.	Check for qnty over parts per hour division & what it evaluates to (computation)
--	9.	Calculate the math to arrive at the start date
--	10.	Get components for all the level 1 parts
--			11.	Bom parts with std qty being null for the current level parts			
--			12.	Parts with parts per hour being null for the current level parts			
--			13.	Check for qnty over parts per hour division & what it evaluates to (computation)
--			14.	Calculate the math to arrive at the start date
--	15.	Verify count in the temp table
--	16.	Display results
--		
--	Development:	Harish Gubbi	2/9/00	Created	
--			Harish Gubbi	9/29/01	Modified. Increased the size of @airow variable
--							  Included '%' in the patindex string
------------------------------------------------------------------------------------------------------------------

--	1.	Declarations
declare	@current_level	integer

declare	@count integer,
	@currentpart	varchar(25),
	@parentpart	varchar(25),
	@ppart		varchar(25),
	@bomlevel	integer,
	@processed	smallint,
	@incrementor	integer,
	@foundcount	integer,
	@counter	integer,
	@found		integer,
	@tree		varchar(255),
	@airow		varchar(5),
	@pos		integer,
	@checkcount	integer,
	@rwcount	integer

--	2.	Declare temp tables
create	table #partsmain ( part varchar(25) null)

create	table #parts ( part varchar(25) null )

create	table #partext ( parentpart varchar(25) null,
			 part	varchar(25) null,
			 processed smallint null)

create	table #vbom (	part varchar(25) null,
			bomlevel integer null,
			airow	varchar(2) null,
			tree	varchar(255) null)

create	table #errlist (parentpart varchar(25) null,
			componentpart varchar(25) null)

create table #sctemp ( part varchar(25) not null,
			due datetime not null,
			qnty numeric(20,6) null,
			source integer null,
			origin numeric(8,0) null,
			id integer,
			rowno integer null )

create table #scoutput ( reason varchar(255))

--	3.	Insert part or parts from either passed value or from order_detail as these are all top level parts
if isnull(@part,'') = ''
begin
	insert	into #partsmain 
	select	distinct part_number
	from	order_detail od
		join order_header oh on oh.order_no = od.order_no 
	where	isnull(oh.status,'O') <> 'C'
	order by part_number
end
else
	insert	into #partsmain values ( @part ) 

--	4.	Initilize
select	@count = 0,
	@parentpart = '',
	@bomlevel = 1

--	5.	Get the temp table count
select	@parentpart = min ( part ),
	@count = count ( 1 ) 
from	#partsmain
where	part > @parentpart

--	6.	Process all the level one parts
while	@count > 0 
begin	-- 1b

--	7.	Initilize the required variables with initial values
	select	@incrementor = 1,
		@bomlevel = 1,
		@checkcount = 1,
		@ppart = @parentpart
	
--	8.	Delete temp tables
	delete	#vbom
	delete	#partext

--	9.	Insert row into vbom temp table	
	insert	into #vbom values ( @ppart, @bomlevel, '1', '-1-' )
	
	while @checkcount > 0 
	begin	-- 2b

--		10.	Delete temp table
		delete	#parts

--		11.	Get components for this current part
		insert	into #parts 
		select	part
		from	bill_of_material
		where	parent_part = @ppart
		order by part
		
--		12.	Check whether the parent part exists in the components list
		select	@foundcount = count ( 1 )
		from	#parts
		where	part = @ppart

--		13.	On count being > 0 write to err temp table
		if @foundcount > 0 
		begin	-- 3b
	
--			14.	Check whether the part already exists in the err list temp table
			select	@found = count ( 1 )
			from	#errlist
			where	parentpart = @ppart
	
--			15.	On count being > 0 write to err temp table
			if @found > 0 
				insert	into #errlist values ( @ppart, @ppart ) 
		end	-- 3b
		else
		begin	-- 4b
	
--			16.	Check whether the part exists in the vbom temp table
			select	@found = count ( 1 ) 
			from	#vbom
			where	part = @ppart
				
			if @found > 0 
			begin	-- 5b
	
--				17.	Get bomlevel & tree from the temp table
				select	@bomlevel = isnull(max(bomlevel),0) + 1,
					@tree = max(tree)
				from	#vbom
				where	part = @ppart
				
			end	-- 5b
	
--			18.	Process all the component parts	
			select	@currentpart = ''
	
--			19.	Get the 1st part for processing		
			select	@currentpart = min ( part ),
				@counter = count ( 1 )
			from	#parts
			where	part > @currentpart
				
			while @counter > 0 
			begin	-- 6b
	
--				20.	Check whether the part is found in vbom temp table
				select	@found = count ( 1 ) 
				from	#vbom
				where	part = @currentpart	
				
				if @found > 0 
				begin	-- 7b
					select	@airow = '%-' + airow + '-%'
					from	#vbom
					where	part = @currentpart	
					
					select	@pos = isnull(patindex ( @airow, @tree ),0) 
				end	-- 7b
				if @pos > 0 
				begin	-- 8b
				
--					21.	Check whether the part already exists in the err list temp table
					select	@found = count ( 1 )
					from	#errlist
					where	parentpart = @ppart and
						componentpart = @currentpart
					
--					22.	On count being = 0 write to err temp table
					if @found = 0 
					begin	-- 9b
						insert	into #errlist values ( @ppart, @currentpart ) 
						select	@counter = 0, @airow = '', @pos = 0 
					end	-- 9b	
				end	-- 8b
				else
				begin	-- 10b

--					23.	write data to other temp tables				
					insert	into #partext values ( @ppart, @currentpart, -1 )
					select	@incrementor = @incrementor + 1
					select	@tree = @tree + convert ( varchar, @incrementor ) + '-'
					insert	into #vbom values ( @currentpart, @bomlevel, convert ( varchar, @incrementor ), @tree ) 
				end	-- 10b
				
--				24.	Get the 1st part for processing		
				select	@currentpart = min ( part ),
					@counter = count ( 1 )
				from	#parts
				where	part > @currentpart
				
			end	-- 6b
		end	-- 4b

--		25.	update the temp table set processed with 0
		update	#partext set processed = 0 where part = @ppart

--		26.	Get the next unprocessed part		
		select	@ppart = min ( part ),
			@checkcount = count ( 1 )
		from	#partext
		where	processed < 0 

	end	-- 2b

--	27.	Get the temp table count
	select	@parentpart = min ( part ),
		@count = count ( 1 ) 
	from	#partsmain
	where	part > @parentpart
end	-- 1b

--	28.	Display results
--	select * from #vbom
--	1.1	Check for infinite boms
insert	into #scoutput (reason ) 
select  'Parent part ' + parentpart + ' with the component part ' + componentpart + ' is in a infinite bill of material' from #errlist

select	@count = count ( 1 ) 
from	#sctemp

if @count = 0 
begin	-- 0b

	--	Bom parts with std qty being null for the current level parts
	insert	into #scoutput (reason ) 
	select	'Parent part ' +bom.parent_part + ' with component part ' + bom.part + ' has null standard quantity '
	from	bill_of_material bom
	where	(bom.std_qty is null or bom.std_qty = 0 )
	
	--	Inserting parts with parts per hour with null or 0 value
	insert	into #scoutput (reason ) 
	select	'Part '+ part + ' with parts per hour having a 0 or a null value'
	from	part_machine
	where	parts_per_hour = 0 or parts_per_hour is null
	
	--	Inserting parts with duplicate row ids in order detail
	insert	into #scoutput (reason ) 
	select	distinct 'Sales Order no '+ convert ( varchar, od.order_no ) + ' has duplicate row ids '
	from	 order_detail od
	where	(select count(1) from order_detail od1 where od1.order_no = od.order_no and od1.row_id = od.row_id) > 1
	group by order_no, row_id

	--	Inserting parts with null std_qty in order detail
	insert	into #scoutput (reason ) 
	select	distinct 'Sales Order no '+ convert ( varchar, od.order_no ) +', sequence '+convert(varchar,sequence)+ ' & part ' + part_number + ' has null standard quantity '
	from	order_detail od
	where	(od.std_qty is null or od.std_qty = 0 ) 

	--	Inserting parts with null row_id in order detail
	insert	into #scoutput (reason ) 
	select	distinct 'Sales Order no '+ convert ( varchar, od.order_no ) +', sequence '+convert(varchar,sequence)+ ' & part ' + part_number + ' has null row id '
	from	order_detail od
	where	(od.row_id is null or od.row_id = 0 ) 
	
	--	15.	Verify count in the temp table
	select	@count = isnull(count ( 1 ),0)
	from	#scoutput
	
	if @count = 0 
		insert	into #scoutput (reason ) 
		values	('No problems reported in the data')
	else
		insert into #scoutput ( reason )
		values ( 'The above data problems have been identified, Fix the data problem before running super cop')
end	-- 0b
--	16.	Display results
select	reason from #scoutput
go

print '
-------------------------------------------------------
--  stored procedure to get hierarchy 
-------------------------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_get_hierarchy'))
	drop procedure msp_get_hierarchy
go
create procedure msp_get_hierarchy  (@operator_code varchar (8)) 
as

declare @operator varchar (8),
	@backup_approver varchar(8),
	@backup_end_date datetime, 
	@count integer

	create table #mps_hierarchy (
		operator_code varchar (8) )			/*temp table to hold all codes*/

	create table #mps_operator (
		operator		varchar(8),
		backup_approver		varchar(8) null,
		backup_end_date		datetime null)		/*temp table to process all rows*/

		begin transaction				/* begin transaction */

		/* insert all op codes whose approver is @operator_code */
		insert into #mps_hierarchy
		select operator_code
		from requisition_security 
		where approver = @operator_code or operator_code = @operator_code

		/* insert all op codes whose backup approver is @operator_code */
		insert into #mps_operator
		select operator_code,  backup_approver, backup_approver_end_date
		from requisition_security 
		where ( backup_approver = @operator_code AND getdate() <= backup_approver_end_date  )
		AND ( operator_code <> @operator_code )

		set rowcount 1 

		/* get the first row values from #mps_operator table */
 	        select @operator = operator, 
		       @backup_end_date = backup_end_date,
		       @backup_approver = backup_approver
		from  #mps_operator

		while @@rowcount > 0 
		begin

			set rowcount 0

			/* check for the validity of backup approver end date */
			if getdate() <= @backup_end_date 
			begin
				set rowcount 0
				
				select @count = count(*)
				from #mps_hierarchy 
				where operator_code = @operator

				if isnull (@count, 0) = 0 
				begin
					/* insert row to hierarchy table */
					insert into #mps_hierarchy values ( @operator )
					select @count  = 0 
				end

				set rowcount 0
					
				/* get all the operators list for the operator and */
				/*insert rows to process from #mps_operator*/
				insert into #mps_operator
				select operator_code, backup_approver, backup_approver_end_date
				from requisition_security 
				where approver = @operator and
				operator_code <> @operator  

			end
			else if isnull(@backup_approver,'') = ''
			begin
				set rowcount 0
				
				select @count = count(*)
				from #mps_hierarchy 
				where operator_code = @operator

				if isnull (@count, 0) = 0 
				begin
					/* insert row to hierarchy table if backup approver is null */
					insert into #mps_hierarchy values ( @operator )
					select @count  = 0 
				end
			end		

			set rowcount 0

			/* delete the processed row */
			delete from #mps_operator where operator = @operator 

			set rowcount 1 

			/* get the next row to process */
			select @operator = operator, 
			       @backup_end_date = backup_end_date,
 		               @backup_approver = backup_approver
			from  #mps_operator

		end 

		commit transaction			/*commit transaction */	

		set rowcount 0

		/* select output */
		select operator_code 
		from #mps_hierarchy 
		
		drop table #mps_operator
		drop table #mps_hierarchy 

return
go

print '
-------------------------------------------------------
--  msp_update_po_qty_assigned stored procedure to update mps
-------------------------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_update_po_qty_assigned'))
	drop procedure msp_update_po_qty_assigned
go

create procedure msp_update_po_qty_assigned (@po_number integer) as

declare		@part_number                    varchar(25),
		@part_mps			varchar(25),
		@part_assign			varchar(25),
		@std_qty                        numeric(20,6),
		@due_date                       datetime,
		@due	                        datetime,
		@order_no                       numeric(8,0),
		@row_id                         int,
		@origin                         numeric(8,0),
		@source                         int,
		@plant                          varchar(10),
		@qnty				numeric(20,6),
		@qty_left			numeric(20,6),
		@assign_qty			numeric(20,6),
		@id				numeric(12,0)

	create table #mps_po_part ( 
		part				varchar(25),
		plant				varchar(10) null,
		quantity			numeric(20,6) null)

	create table #mps_temp (
		part				varchar(25),
		plant				varchar(10) null)

	create table #mps_assign (
		part				varchar(25),
		due				datetime,
		source				int,
		origin				numeric(8,0),
		qnty				numeric(20,6),
		id				numeric(12,0) )

	begin transaction

	insert into #mps_po_part
	select	max (part_number),
		max (plant),			/* get po detail record */
		sum(standard_qty)
	  from	po_detail
	where   po_number = @po_number
	group by part_number, plant

	set rowcount 1				/* setup poor man's cursor */

	select	@part_number = part,		/* get po detail record */ 		
		@plant = plant,
		@std_qty = quantity
	  from	#mps_po_part

	while @@rowcount > 0 
	begin 

		set rowcount 0

		insert	#mps_temp  	        /* get distinct mps plant,parts */
		select	part, plant
		  from	master_prod_sched
		where   part = @part_number
		group by part, plant
		order by part

		set rowcount 1

		select @part_mps = part
		from #mps_temp

		while @@rowcount > 0 
		begin

			set rowcount 0

			update master_prod_sched 
			set qty_assigned = 0
			where part = @part_mps

			select @assign_qty = sum ( standard_qty )
			from po_detail
			where part_number = @part_mps
			and  status <> 'C'

						/* get po and wo qty w/ null plant */
			insert	#mps_assign (part, due, source, origin, qnty, id)
			select	part, due, source, origin, qnty, id
			  from	master_prod_sched
			 where	part = @part_mps
			order by due

			set rowcount 1

		 	select 	@due = due, 
			       	@source = source, 
			       	@origin = origin, 
				@qnty = qnty,
				@id = id
			  from	master_prod_sched
			where   part =@part_mps
			  order by due		

			select @qty_left = @assign_qty

			while ( @@rowcount > 0 )  and ( @qty_left > 0 )
			begin

				set rowcount 0

				if @qty_left > @qnty	/* assign qty from oldest to newest */
				begin
					update	master_prod_sched
					   set	qty_assigned = @qnty
					 where	part = @part_mps
					   and	source = @source
				   	   and	origin = @origin
				   	   and	due = @due
					   and  id = @id
	
					select	@qty_left = @qty_left - @qnty
				end
				else
				begin
					update	master_prod_sched
					   set	qty_assigned = @qty_left
					 where	part = @part_mps
					   and	source = @source
				   	   and	origin = @origin
				   	   and	due = @due
					   and  id = @id

					select	@qty_left = 0
				end				

				set rowcount 1

				delete  from #mps_assign
				 where	part = @part_mps
				   and	source = @source
				   and	origin = @origin
				   and	due = @due
				   and  id = @id

				select	@due = due,		/* get next mps plant, part */
					@source = source,
					@origin = origin,
					@qnty = qnty,
					@id   = id
				  from	#mps_assign
				 where	part = @part_mps
			      order by	due
				
			end

			set rowcount 0

			delete  from #mps_assign
	
			select	@assign_qty = 0

			set rowcount 0

			delete  from #mps_temp

			set rowcount 1

			select @part_mps = part
			from #mps_temp

		end 
		
		set rowcount 0	  

		delete from #mps_po_part
		where part = @part_number

		set rowcount 1					/* setup poor man's cursor */
	
		select	@part_number = part,			/* get po detail record */
			@plant = plant,
			@std_qty = quantity
		  from	#mps_po_part

	end 

	commit transaction					/* commit transaction */

	drop table #mps_temp					/* clean-up */
	drop table #mps_assign 
	drop table #mps_po_part

go

print '
-------------------------------------------------------
--  new procedure to recalc po detail and update mps
-------------------------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'msp_recalc_po_detail' and type = 'P' )
	drop procedure msp_recalc_po_detail
go

create procedure msp_recalc_po_detail ( @po_number integer )
as
begin
	declare @qty_overreceived numeric (20,6),
		@received  	  numeric (20,6),
		@quantity	  numeric (20,6),
		@vendor_code      varchar (10),
		@part_number      varchar (25),
		@row_id           integer,
		@date_due	  datetime,
		@part		  varchar (25),	
		@qty_received     numeric (20,6),	  
		@balance	  numeric (20,6),
		@unit             varchar (2),
		@conversion_qty   numeric (20,6)
	
	/* create temp table to get all po detail rows to be processed */

	create table #mps_po_detail
	( part_number varchar (25),
          vendor_code varchar (10),
	  quantity    numeric (20,6) ,
	  received    numeric (20,6) null,
	  row_id      integer,
	  date_due    datetime,
	  unit		varchar (2) )

	/* create temp table to get all the part in detail */
	
	create table #mps_po_part
	( part_number varchar (25),
	  received    numeric (20,6) )

	/* get the parts to be processed */
	insert into #mps_po_part
	select part_number, sum (received)	
	from po_detail 
	where po_number = @po_number
	group by part_number

	begin transaction

	set rowcount 1

	/* get the first part */
	select @part = part_number,
	       @received = received
	from #mps_po_part
	
	/* loop through while rowcount is greater than zero */
	while @@rowcount > 0 
	begin 	
		set rowcount 0 

		/* get all the rows for the po and part number */
		insert into #mps_po_detail
		select part_number, 
			 vendor_code, 	
			 quantity, 
			 received, 
			 row_id, 
			 date_due, 
			 Unit_of_measure
		from po_detail
		where po_number = @po_number
		and   part_number = @part
		order by date_due 

		set rowcount 1

		select  @part_number = part_number,
			@vendor_code = vendor_code,
		        @quantity    = quantity,
			@row_id     = row_id,
			@date_due   = date_due,
			@unit       = unit
		from #mps_po_detail

		/* get the qty conversion */	
		select @conversion_qty = unit_conversion.conversion  
		from part_unit_conversion, unit_conversion  
		where ( part_unit_conversion.code = unit_conversion.code ) and  
		      ( part_unit_conversion.part = @part_number ) and  
		      ( unit_conversion.unit1 = @unit ) and  
		      ( unit_conversion.unit2 = ( select  standard_unit
						    from  part_inventory  
						   where  part = @Part_number ) ) 

		select @conversion_qty = isnull ( @conversion_qty, 1 ) 

		/* gt over received quantity from part vendor table */
		select @qty_overreceived = qty_over_received
		from part_vendor
		where part = @part
		and   vendor = @vendor_code 

		select @qty_received = isnull ( @received, 0 ) + isnull ( @qty_overreceived, 0 )

		/* loop through all rows for that part in po detail */
		while @@rowcount > 0 and @qty_received > 0
		begin

			set rowcount 0 

			if @quantity > 0 
			begin
				/* assign the received quantities */
				if @qty_received > @quantity    	
				begin
					update	po_detail
					   set	quantity = @quantity,
						received = @quantity,
						balance  = 0,
						standard_qty = 0
					where po_number = @po_number 
					and   part_number = @part_number
					and   row_id      = @row_id
					and   date_due    = @date_due
		
					select	@qty_received = @qty_received - @quantity
					select  @qty_overreceived = @qty_received

				end
				else
				begin
					select @balance = ( @quantity - @qty_received )

					update	po_detail
					   set	quantity = @quantity,
						received = @qty_received,
						balance  = @balance,
						standard_qty = ( @balance * @conversion_qty )
					where po_number = @po_number 
					and   part_number = @part_number
					and   row_id      = @row_id
					and   date_due    = @date_due
	
					select	@qty_received = 0
					select  @qty_overreceived = 0
				end				

			  end

			  set rowcount 0
		
			  delete from #mps_po_detail
				where part_number = @part_number
				and   row_id      = @row_id
				and   date_due    = @date_due
				
			set rowcount 1

			select  @part_number = part_number,
				@vendor_code = vendor_code,
			        @quantity    = quantity,
			        @row_id     = row_id,
			        @date_due   = date_due,
				@unit       = unit
			 from  #mps_po_detail

		end 

		set rowcount 0

		/* update part vendor with remaining quantities */
		update part_vendor
		set qty_over_received = @qty_overreceived
		where part = @part
		and   vendor = @vendor_code 

		/* delete from temp table the part that was already processed */
		delete from #mps_po_part
		where part_number = @part
		
		set rowcount 1

		select 	@part = part_number,
	       		@received = received
		from #mps_po_part

	end 

	/* delete rows which are marked for deletion and and balance is zero */
	delete from po_detail
	where  deleted = 'Y' OR balance <= 0 

	commit transaction

	exec msp_update_po_qty_assigned @po_number	

	/* return value 1 */
	select 1 

	drop table #mps_po_detail	

end 
go

print '
-------------------------------------
-- procedure:	msp_build_requisition
-------------------------------------
'
if exists (select * from sysobjects where id = object_id('msp_build_requisition') )
	drop procedure msp_build_requisition
go

create procedure msp_build_requisition ( @operator_code varchar (8) = null, @mode varchar (1) = null, @showclosed char(1) = 'N' ) 
as
begin
----------------------------------------------------------------------------------------
--	Stored procedure to get the hierarchy levels, dollar limits for a given operator
--	Arguments: @operator_code varchar (8) : to pass the operator code for which
--						sp is retrieved
--
--		   @mode	varchar (1)   : 'A' or 'S' from requisition_inquiry screen
--
--	Original : 05/10/99	MB
--	Modified : 05/19/99	MB
--		 : 12/20/99	Eric.E.Stimpson	Add minimum and maximum po number to result set.
--		 : 01/31/02	GPH Modified the select statements, included a left outer join 	
----------------------------------------------------------------------------------------
	declare @operator varchar (8),
		@count 		integer,
		@level 		integer,
		@app_operator	varchar (8),
		@operator_level	integer,
		@dollar_prev	numeric (20,6),
		@dollar		numeric (20,6)

	begin transaction
	
--	temp table to process all rows
	create table #mps_operator (
		operator_code		varchar(8),
		approver		varchar(8) null,
		approver_dollar		numeric (20,6) null,
		self_dollar		numeric (20,6) null,
		hierarchy_level		integer )		

		select @level = 0 
		select @count = 0 

--		get operator level for this operator
		select @operator_level = security_level
		from requisition_security
		where operator_code = @operator_code

--		insert row for current operator into the temp table
		insert into #mps_operator
		select operator_code, 
			approver, 
			0,
			self_dollar_limit,
			@level
		from requisition_security 
		where approver =  @operator_code 

--		get number of rows from the temp table
		select @count = count(1)
		from #mps_operator

--		loop while there are more than a row inserted
		while @count > 0 
		begin
		
			select @level = @level - 1 

--			insert previous hierarchy levels operator codes		
			insert into #mps_operator
			select operator_code, 
				approver, 
				0, 
				self_dollar_limit,
				@level
			from requisition_security 
			where approver in ( select operator_code 
					    from #mps_operator 
					    where hierarchy_level = @level + 1) 
			and approver <> @operator_code

			select @count = count(1)
			from requisition_security 
			where approver in ( select operator_code 
						from #mps_operator 
						where hierarchy_level = @level )
			and approver <> @operator_code

			if @count > 0 						
				select @count = 1 
			else if @count is null or @count <= 0 
				select @count = 0 

		end

		select @level = 0 
		select @count = 0 
		select @operator = @operator_code

--		insert rows for operator in next and higher hierarchy levels
		while @operator > '' and @count = 0 
		begin

			select @level = @level + 1 

			insert into #mps_operator
			select operator_code, 
				approver, 
				0,
				self_dollar_limit,
				@level
			from requisition_security 
			where operator_code =  @operator and
			      operator_code not in (select operator_code from #mps_operator 
						    where hierarchy_level <= @level ) 

			select @app_operator = @operator
	
			select @operator = null

			select @operator = approver
			from #mps_operator
			where operator_code = @app_operator  

			if @operator  > '' 
				select @count = count ( 1 )
				from #mps_operator 
				where operator_code = @operator 
			else
				select @count = 1 
			
			if @count > 0 						
				select @count = 1 
			else
				select @count = 0 
		end

-- 	get dollar limits for the operator 
	update #mps_operator
	set approver_dollar = (select dollar 
		      from requisition_security 
		      where #mps_operator.approver = requisition_security.operator_code )

--		insert backup approver for this operator
		if ( select backup_approver 
			from requisition_security 
			where operator_code = @operator_code ) > '' 
		begin
			insert into #mps_operator
			select operator_code, 
			       backup_approver, 
			       dollar, 
			       self_dollar_limit,
			       0
			from  requisition_security 
			where operator_code = @operator_code 
		end

--		insert approver as backup approver 
		if ( select min(operator_code)
			from requisition_security 
			where backup_approver = @operator_code ) > '' 
		begin
			insert into #mps_operator
			select operator_code, 
			       @operator_code, 
			       dollar, 
			       self_dollar_limit,
			       0
			from requisition_security
			where backup_approver = @operator_code
		end

	commit transaction			/*commit transaction */	

	set rowcount 0

--	select output 	
--	select * from #mps_operator order by hierarchy_level 

	if @operator_level = 1 
	begin
		select requisition_header.requisition_number,   
        	 	requisition_header.vendor_code,
	        	 requisition_header.creation_date,   
	        	 requisition_header.status,   
		         requisition_header.requested_date,   
        		 requisition_header.requisitioner,   
		         requisition_header.ship_to_destination,   
        		 requisition_header.terms,   
	        	 requisition_header.fob,   
	        	 requisition_header.ship_via,   
		         requisition_header.notes,   
        		 requisition_header.approved,   
		         requisition_header.approver,   
        		 requisition_header.approval_date,   
	        	 requisition_header.freight_type,
			total_cost = (SELECT isnull ( sum (extended_cost) , 0 )
					 FROM requisition_detail  
					WHERE requisition_detail.requisition_number =  
						requisition_header.requisition_number ),
			min_po = (SELECT min ( po_number )
					 FROM requisition_detail  
					WHERE requisition_detail.requisition_number =  
						requisition_header.requisition_number ),
			max_po = (SELECT max ( po_number )
					 FROM requisition_detail  
					WHERE requisition_detail.requisition_number =  
						requisition_header.requisition_number ),
        	 	name
			from requisition_header
				left outer join vendor on vendor.code = requisition_header.vendor_code   
			where requisition_header.requisitioner = @operator_code and
				requisition_header.status <> ( case @showclosed when 'N' then '7' else '-1' end )
	end
	else if @operator_level = 7  
	begin
		if @mode = 'A'
			select requisition_header.requisition_number,   
        	 	requisition_header.vendor_code,
	        	 requisition_header.creation_date,   
	        	 requisition_header.status,   
		         requisition_header.requested_date,   
        		 requisition_header.requisitioner,   
	        	 requisition_header.ship_to_destination,   
	        	 requisition_header.terms,   
		         requisition_header.fob,   
	        	 requisition_header.ship_via,   
		         requisition_header.notes,   
        		 requisition_header.approved,   
	        	 requisition_header.approver,   
	        	 requisition_header.approval_date,   
		         requisition_header.freight_type,
			 total_cost = (SELECT isnull ( sum (extended_cost) , 0 )
					 FROM requisition_detail  
					WHERE requisition_detail.requisition_number =  
						requisition_header.requisition_number ),
			min_po = (SELECT min ( po_number )
					 FROM requisition_detail  
					WHERE requisition_detail.requisition_number =  
						requisition_header.requisition_number ),
			max_po = (SELECT max ( po_number )
					 FROM requisition_detail  
					WHERE requisition_detail.requisition_number =  
						requisition_header.requisition_number ),   
        	 	name
			from requisition_header   
				left outer join vendor on vendor.code = requisition_header.vendor_code   
			where ( requisition_header.requisitioner in ( select operator_code 
						 from #mps_operator 
					 	where hierarchy_level <= 1 )  
			or ( requisition_header.status in ( '3', '8' ) ) and  
				requisition_header.status <> ( case @showclosed when 'N' then '7' else '-1' end ) )
		else
		begin

			select @dollar_prev =  (select max ( approver_dollar )
					       from #mps_operator 
						where hierarchy_level = -1 ),
				 @dollar = ( select dollar 
						from requisition_security 
						where operator_code = @operator_code )

			select @dollar_prev = isnull ( @dollar_prev, 0 ),
			       @dollar	    = isnull ( @dollar, 0 )

			select requisition_header.requisition_number,   
		         	requisition_header.vendor_code,   
			         requisition_header.creation_date,   
        			 requisition_header.status,   
		        	 requisition_header.requested_date,   
	        		 requisition_header.requisitioner,   
		        	 requisition_header.ship_to_destination,   
	        		 requisition_header.terms,   
		        	 requisition_header.fob,   
	        		 requisition_header.ship_via,   
			         requisition_header.notes,   
        			 requisition_header.approved,   
	        		 requisition_header.approver,   
		        	 requisition_header.approval_date,   
			         requisition_header.freight_type,
				 total_cost = (SELECT isnull ( sum (extended_cost) , 0 )
						 FROM requisition_detail  
						WHERE requisition_detail.requisition_number =  
							requisition_header.requisition_number ),
			min_po = (SELECT min ( po_number )
					 FROM requisition_detail  
					WHERE requisition_detail.requisition_number =  
						requisition_header.requisition_number ),
			max_po = (SELECT max ( po_number )
					 FROM requisition_detail  
					WHERE requisition_detail.requisition_number =  
						requisition_header.requisition_number ),   
        	 		name
				from requisition_header   
					left outer join vendor on vendor.code = requisition_header.vendor_code   
				where ( ( ( requisition_header.requisitioner in ( select operator_code 
							 from #mps_operator 
							 where hierarchy_level <= 1 ) ) 
				and ( (SELECT  sum (extended_cost) 
					FROM requisition_detail  
					WHERE requisition_detail.requisition_number =  
						requisition_header.requisition_number ) > @dollar_prev 
					and 
					(SELECT   sum (extended_cost) 
				 	FROM requisition_detail  
					WHERE requisition_detail.requisition_number =  
						requisition_header.requisition_number ) <= @dollar ) ) or 
			( requisitioner = @operator_code ) 
			or requisition_header.status = '3' or requisition_header.status = '8' ) and
				requisition_header.status <> ( case @showclosed when 'N' then '7' else '-1' end )

		end
	end
	else 		
	begin
		if @mode = 'A'
			select requisition_header.requisition_number,   
        	 	requisition_header.vendor_code,   
	        	 requisition_header.creation_date,   
	        	 requisition_header.status,   
		         requisition_header.requested_date,   
        		 requisition_header.requisitioner,   
		         requisition_header.ship_to_destination,   
        		 requisition_header.terms,   
	        	 requisition_header.fob,   
	        	 requisition_header.ship_via,   
		         requisition_header.notes,   
        		 requisition_header.approved,   
		         requisition_header.approver,   
        		 requisition_header.approval_date,   
	        	 requisition_header.freight_type,
			 total_cost = (SELECT isnull ( sum (extended_cost) , 0 )
					 FROM requisition_detail  
					WHERE requisition_detail.requisition_number =  
						requisition_header.requisition_number ),
			min_po = (SELECT min ( po_number )
					 FROM requisition_detail  
					WHERE requisition_detail.requisition_number =  
						requisition_header.requisition_number ),
			max_po = (SELECT max ( po_number )
					 FROM requisition_detail  
					WHERE requisition_detail.requisition_number =  
						requisition_header.requisition_number ),   
        	 	name
			from requisition_header   
				left outer join vendor on vendor.code = requisition_header.vendor_code   
			where ( requisition_header.requisitioner in ( select operator_code 
						 from #mps_operator 
						 where hierarchy_level <= 1 ) )  and
				requisition_header.status <> ( case @showclosed when 'N' then '7' else '-1' end )

		else
		begin
			select @dollar_prev =  ( select max ( approver_dollar )
						from #mps_operator 
						where  hierarchy_level = -1),	       
					 @dollar = ( select dollar 
					from requisition_security  
					where operator_code = @operator_code  )

			select @dollar_prev = isnull ( @dollar_prev, 0 ),
			       @dollar	    = isnull ( @dollar, 0 )
	
			select requisition_header.requisition_number,   
         			requisition_header.vendor_code,   
			         requisition_header.creation_date,   
        			 requisition_header.status,   
			         requisition_header.requested_date,   
        			 requisition_header.requisitioner,   
			         requisition_header.ship_to_destination,   
        			 requisition_header.terms,   
			         requisition_header.fob,   
        			 requisition_header.ship_via,   
			         requisition_header.notes,   
        			 requisition_header.approved,   
			         requisition_header.approver,   
        			 requisition_header.approval_date,   
			         requisition_header.freight_type,
				 total_cost = (SELECT isnull ( sum (extended_cost) , 0 )
						 FROM requisition_detail  
						WHERE requisition_detail.requisition_number =  
							requisition_header.requisition_number ),
			min_po = (SELECT min ( po_number )
					 FROM requisition_detail  
					WHERE requisition_detail.requisition_number =  
						requisition_header.requisition_number ),
			max_po = (SELECT max ( po_number )
					 FROM requisition_detail  
					WHERE requisition_detail.requisition_number =  
						requisition_header.requisition_number ),   
        	 	name
			from requisition_header   
				left outer join vendor on vendor.code = requisition_header.vendor_code   
			where ( ( ( requisition_header.requisitioner in ( select operator_code 
						 from #mps_operator 
						 where hierarchy_level <= 1 ) )  
				and ( (SELECT sum (extended_cost)
				FROM requisition_detail  
				WHERE requisition_detail.requisition_number =  
					requisition_header.requisition_number ) > @dollar_prev 
				and 
				(SELECT sum (extended_cost)
				 FROM requisition_detail  
				WHERE requisition_detail.requisition_number =  
					requisition_header.requisition_number ) <= @dollar ) ) 
				or ( requisitioner = @operator_code ) ) and
				requisition_header.status <> ( case @showclosed when 'N' then '7' else '-1' end )

		end
	end

	drop table #mps_operator

end
go


print '
-----------------------------------------
-- procedure:	msp_create_requisitionrel
-----------------------------------------
'

if exists (select * from dbo.sysobjects where id = object_id('msp_create_requisitionrel'))
	drop procedure msp_create_requisitionrel
GO

create procedure msp_create_requisitionrel AS
---------------------------------------------------------------------------------------
--	This procedure creates requisition based part kanban info ( min & max)
--
--	Modifications:	5 AUG 1999, Harish P. Gubbi	Original.
--
--	Parameters:	As of now nothing
--
--	Returns:	None
--
--	Process:
--	1.	Declare all the required local variables.
--	2.	Declare cursor for purchased finished, wip & raw parts
--	3.	Loop through each part
--	4.	Get summed qty from object & po releases for the current part
--	5.	Check part type for the currently fetched part
--	6	Arrive at the new work order quantity
-- 	6.5	Get Part Price from part_vendor_price_matrix			
--	7.	Create reqsuition header & detail records
-- 	8.	Get the next part
--	9.	Return
---------------------------------------------------------------------------------------

--	1.	Declare all the required local variables.
declare @part           varchar(25),
        @parttype      	char(1),
        @stdunit       	varchar(2),
	@onhand       	numeric(20,6),
        @minonhand	decimal(20,6),
        @maxonhand     	decimal(20,6),
        @requisitionqty	numeric(20,6),
        @poquantity	numeric(20,6),        
        @requisitionno  integer,
        @newqty    	numeric(20,6),
	@duedate       	datetime,
	@kanban         char(1),
	@vendor		varchar(10),
	@shiptodest	varchar(25),
	@shiptype	char(1),
	@shipvia	varchar(15),
	@terms		varchar(20),
	@rowid		integer,
	@desc		varchar(50),
	@account_code	varchar(50),
	@fob		varchar(10),
	@freighttype	varchar(15),
	@price		decimal(20,6)
	
select  @duedate=convert( datetime, (substring(convert(varchar(19), getdate()),1,11)))

--	2.	Declare cursor for Purchased finished, wip & raw parts
declare parts cursor for
	select  p.part,
		p.type,
		substring(p.name,1,50),
        	pi.standard_unit,
        	isnull(pol.min_onhand,0),
	       	isnull(pol.max_onhand,0),
        	pol.default_vendor,
         	pol.default_po_number,
         	v.kanban,
         	v.ship_via,
         	v.fob,
         	v.frieght_type,
         	v.terms,
		(select convert(numeric(20,6),isnull(sum(quantity),0))
			from object where object.part = p.part and object.status='A'),
		(select convert(numeric(20,6),isnull(sum(balance),0))
			from po_detail where po_detail.part_number = p.part)	
   	from 	part as p
   		join part_inventory as pi on pi.part = p.part
   		join part_online as pol on pol.part = p.part 
   		join vendor as v on v.code = pol.default_vendor
  	where 	p.class = 'P' and
  		pol.default_vendor is not null and 
  		(v.kanban = 'Y' or pol.kanban_required = 'Y') and pol.kanban_po_requisition = 'R'
	order by 1
	
--	3.	Loop through each part
open parts

fetch	parts
into	@part,
	@parttype,
	@desc,	
	@stdunit,
	@minonhand,
	@maxonhand,
	@vendor,
	@requisitionno,
	@kanban,
	@shipvia,
	@fob,
	@freighttype,
	@terms,
	@onhand,
	@poquantity
	
while ( @@fetch_status = 0 )
begin -- (1a)

--	get requisition qty for the part        
	select	@requisitionqty = isnull(sum(quantity),0)
	from	requisition_detail
		join requisition_header on requisition_header.requisition_number = requisition_detail.requisition_number
	where	requisition_detail.part_number = @part and 
		requisition_header.status <> '4' and 
		requisition_header.status <> '6'

--	6.	Arrive at the new requisition quantity
	if @onhand <= @minonhand
		if @poquantity < (@maxonhand - @onhand)
		begin 
	        	select @newqty= (@maxonhand - @onhand) - @poquantity
		        if @requisitionqty < @newqty
		        	select @newqty= @newqty - @requisitionqty
			else
	        		select @newqty= 0
	        end 	
		else
        		select @newqty= 0
	else
        	select @newqty= 0
-- 	6.5	Get Part Price from part_vendor_price_matrix			
	
	execute rsp_get_vendor_part_price  @part , @vendor , @newqty , @price 


--	7.	Create requisition detail records
	if @newqty > 0 		
	begin -- (2a)
	
		-- get next requisition no. from parametes or max(requisition no + 1) from req_header
		select	@requisitionno=isnull(max(requisition_number),0) + 1
		from 	requisition_header
	
		-- rowid for that new row being created 
		select	@rowid=isnull(max(row_id),0) + 1
		from	requisition_detail 
		where	requisition_number=@requisitionno

--		Insert into  requisition header records
		-- insert row into requisition header
		insert 
		into	requisition_header (
			requisition_number, vendor_code, ship_to_destination, terms, 
			fob, requested_date, requisitioner, ship_via, notes, approved,
			approver, creation_date, status, approval_date, freight_type)
		values 	(@requisitionno, @vendor, @shiptodest, @terms, 
			@fob, getdate(), 'kanba', @shipvia, 'Auto Generated Requisition through Kanban procedur', null,
			null, getdate(), '1', null, @freighttype)
		
		-- insert row into requisition detail 
		insert 	
		into	requisition_detail (
			requisition_number, part_number, description, quantity, date_required, row_id, 
			vendor_code, unit_of_measure , unit_cost)
		values	(@requisitionno, @part, @desc, @newqty, @duedate, @rowid,
			@vendor, @stdunit , @price) 
	end -- (2a)
	
--	8.	Get the next part

	fetch	parts
	into	@part,
		@parttype,
		@desc,		
		@stdunit,
		@minonhand,
		@maxonhand,
		@vendor,
		@requisitionno,
		@kanban,
		@shipvia,
		@fob,
		@freighttype,
		@terms,
		@onhand,
		@poquantity
	
end -- (1a)
close parts

deallocate parts

--	9.	Return
Return
GO

print '
------------------------------
-- msp_vendor_price procedure
------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'msp_vendor_price' )
	drop procedure msp_vendor_price
go

create procedure msp_vendor_price ( @as_part varchar(25), @as_vendor varchar(10), @adec_qty decimal(20,6) )
as
begin transaction
	declare @price numeric (20,6)
	
	SELECT	@price = part_vendor_price_matrix.price  
	FROM	part_vendor_price_matrix
	WHERE	part = @as_part and
		vendor = @as_vendor and
		break_qty = (	select	max ( break_qty )
				from	part_vendor_price_matrix
				where	part = @as_part and
					vendor = @as_vendor and
					break_qty <= @adec_qty ) 
	
	if isnull ( @price, -1 ) = -1
		select	@price = price
		from	part_standard
		where	part = @as_part
	
	select isnull(@price,0)
commit transaction
go



print'
---------------------------------
-- Trigger Changes
---------------------------------
'



print'
---------------------------------
-- TRIGGER:	mtr_audit_trail_i
---------------------------------
'
if exists(select * from dbo.sysobjects where name='mtr_gl_account')
	drop trigger mtr_gl_account
go

if exists(select * from dbo.sysobjects where name='mtr_audit_trail_i')
	drop trigger mtr_audit_trail_i
go
create trigger mtr_audit_trail_i
on audit_trail
for insert
as
-----------------------------------------------------------------------------------------------
--	This trigger concatenates gl segments from various tables & writes to audit_trail
--
--	Modifications:	05 AUG 1999, Harish P. Gubbi	Original.
--
--	Parameters:	None
--
--	Returns:	None
--
--	Process:
--	1. 	Declare variables	
--	2.	Declare cursor for inserted
--	3. 	Loop through each row
--	4.	Get gl tran type code	
--	5.	Get Natural segment from part_gl_account table
--	6.	Get Plant segment from from destination table
--	7.	Get Product line segment from from product line table
-- 	8.	Update audit_trail table with gl_account_no
-- 	9.	Record shipout for homogeneous pallet with part id of boxes.
--	10.	Record shipout for loose box.
-- 	11.	Return 

-----------------------------------------------------------------------------------------------

--	1.	Declare variables
declare @part          varchar(25),
	@plant         varchar(10),
	@productline   varchar(25),
	@type          varchar(1),
	@ttype          varchar(1),
	@parttype     varchar(1),
	@partsubtype  varchar(1),
	@gl_account_no varchar(50),
	@gltrantypest  varchar(25),
	@serial        int

--	2.	Declare cursor for the inserted rows	
declare new_recs cursor for
select	inserted.part,
	inserted.type,
	inserted.plant,
	inserted.serial,
	part.product_line,
	part.class,
	part.type
from	inserted 
	join part on part.part = inserted.part
open	new_recs
fetch	new_recs into  @part, @type, @plant, @serial, @productline, @parttype, @partsubtype

--	3.	Loop through each row
while @@fetch_status = 0
begin -- (1a)

--	4.	Get gl tran type code		
	if @productline is not null
	begin -- (2a)
		select	@gltrantypest =
			(case 
				when @type='A' and @partsubtype='F' then 'Manual Add - Finished Goo' 
				when @type='A' and @partsubtype='W' then 'Manual Add - Wip'
				when @type='A' and @partsubtype='R' then 'Manual Add - Raw'
				when @type='X' 		 	    then 'Change/Correct Object'
				when @type='R' and @partsubtype='F' then 'Receive Finished'
				when @type='R' and @partsubtype='R' then 'Receive Raw'
				when @type='R' and @partsubtype='W' then 'Receive Wip'
				when @type='V' and @partsubtype in ('R','W','F') then 'Return Raw to Vendor'
				when @type='M' and @partsubtype='F' then 'Issue Finished'
				when @type='M' and @partsubtype='R' then 'Issue Raw to Wip'
				when @type='M' and @partsubtype='W' then 'Issue Wip'
				when @type='J' and @partsubtype='F' then 'Complete Finished Goods'
				when @type='J' and @partsubtype='W' then 'Complete Wip'
				when @type='J' and @partsubtype='R' then 'Ship Finished Goods' 
				else ''
			end)
      		-- get the tran type code from gl_tran_type table 		
		select	@ttype=code
		from	gl_tran_type
		where	name = @gltrantypest

--	5.	Get Natural segment from part_gl_account table	
  		select	@gl_account_no= 
  			(case 
  				when @parttype='M' then isnull(part_gl_account.gl_account_no_cr,'')
  				when @parttype='P' then isnull(part_gl_account.gl_account_no_db,'')
  			end)
    		from	part_gl_account
		where	part_gl_account.part=@productline and 
			part_gl_account.tran_type=@ttype

--	6.	Get Plant segment from from destination table
		select	@gl_account_no = 
			(case
				when isnull(@gl_account_no,'') <> '' then
					isnull(@gl_account_no,'') + isnull(destination.gl_segment,'')  
				else
					isnull(destination.gl_segment,'')
			end)
		from	destination
		where   destination.plant=@plant
		
--	7.	Get Product line segment from from product line table
		select	@gl_account_no = 
			(case
				when isnull(@gl_account_no,'') <> '' then
					isnull(@gl_account_no,'') + isnull(product_line.gl_segment,'')	
				else
					isnull(product_line.gl_segment,'')
			end)
  		from 	product_line
 		where   product_line.id=@productline
			
-- 	8.	Update audit_trail table with gl_account_no
      		if (@gl_account_no is not null and @gl_account_no<>'')
         		update	audit_trail
            		set	gl_account=@gl_account_no
          		where	audit_trail.serial = @serial and 
          			type=@type
			
    	end -- (2a)

-- 	9.	Record shipout for homogeneous pallet with part id of boxes.
	if (select count ( distinct boxes.part ) 
		from audit_trail pallet 
			join audit_trail boxes on pallet.serial = boxes.parent_serial
		where	pallet.serial = @serial and
			pallet.object_type = 'S' and
			pallet.type = 'S'
		group by	pallet.serial,
				pallet.shipper,
				pallet.package_type) = 1

		insert	serial_asn
		select	pallet.serial,
			max ( boxes.part ),
			convert ( integer, pallet.shipper ),
			pallet.package_type
		from	audit_trail pallet 
			join audit_trail boxes on pallet.serial = boxes.parent_serial
		where	pallet.serial = @serial and
			pallet.object_type = 'S' and
			pallet.type = 'S'
		group by	pallet.serial,
				pallet.shipper,
				pallet.package_type
		
--	10.	Record shipout for loose box.
	insert	serial_asn
	select	serial,
		part,
		convert ( integer, shipper ),
		package_type
	from	audit_trail
	where	serial = @serial and
	parent_serial is null and
		object_type is null and
		type = 'S'
		
	fetch	new_recs into	@part, @type, @plant, @serial, @productline, @parttype, 
				@partsubtype
end -- (1a)
close new_recs
deallocate new_recs

--	11.	Return
Return

go



print'
-------------------------------------------------
-- trigger:	mtr_bill_of_lading_u (SQL Server)
-------------------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_bill_of_lading_u' )
	drop trigger mtr_bill_of_lading_u
go

create trigger mtr_bill_of_lading_u on bill_of_lading for update
as
begin
	declare updated_rows cursor for
		select	bol_number,
			scac_transfer,
			scac_pickup,
			trans_mode,
			destination
		from	inserted

	declare	@bol_number integer,
		@scac_transfer varchar(10),
		@scac_pickup varchar(10),
		@trans_mode varchar(10),
		@destination varchar(20)
		
	open updated_rows
	fetch updated_rows into @bol_number,@scac_transfer,@scac_pickup,@trans_mode,@destination
	while ( @@fetch_status = 0 )
	begin
		if update ( scac_transfer ) or update ( scac_pickup ) or update ( trans_mode ) or update ( destination )
		begin
			update	shipper
			set	ship_via = @scac_transfer,
				bol_carrier = @scac_pickup,
				trans_mode = @trans_mode,
				bol_ship_to = @destination
			where	bill_of_lading_number = @bol_number
		end
		fetch updated_rows into @bol_number,@scac_transfer,@scac_pickup,@trans_mode,@destination
	end
	close updated_rows
	deallocate updated_rows
end
go


print'
-------------------------------------
-- trigger:	mtr_bill_of_material_ec_i
-------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('mt_bill_of_material_ec_i'))
	drop trigger mt_bill_of_material_ec_i
GO
if exists (select * from dbo.sysobjects where id = object_id('mtr_bill_of_material_ec_i'))
	drop trigger mtr_bill_of_material_ec_i
GO

create trigger
mtr_bill_of_material_ec_i
on bill_of_material_ec for insert
as
begin
  declare @current_datetime datetime,
  @most_recient_start_datetime datetime,
  @new_end_datetime datetime,
  @parent_part varchar(25),
  @part varchar(25),
  @start_datetime datetime,
  @end_datetime datetime,
  @type varchar(1),
  @quantity decimal(20,6),
  @unit_measure varchar(2),
  @reference_no varchar(50),
  @std_qty decimal(20,6),
  @scrap_factor decimal(20,6),
  @engineering_level varchar(10),
  @operator varchar(5),
  @substitute_part varchar(25),
  @note varchar(255),
  @std_unit varchar(2),
  @unit_conversion decimal(20,14)
  if @@rowcount>1
    rollback transaction
  else
    begin
      select @current_datetime=convert(datetime,convert(varchar(12),GetDate())+' '+convert(varchar(2),datepart(hh,GetDate()))+':'+convert(varchar(2),datepart(mi,GetDate()))+':'+convert(varchar(2),datepart(ss,GetDate())))
      select @parent_part=parent_part,
        @part=part,
        @start_datetime=start_datetime,
        @end_datetime=end_datetime,
        @type=type,
        @quantity=quantity,
        @unit_measure=unit_measure,
        @reference_no=reference_no,
        @std_qty=std_qty,
        @scrap_factor=scrap_factor,
        @engineering_level=engineering_level,
        @operator=operator,
        @substitute_part=substitute_part,
        @note=note
        from inserted
      if @parent_part=@part
        begin
          rollback transaction
        end
      else
        begin
          select @std_unit = standard_unit
          from part_inventory
          where part = @part
          if isnull(@std_unit,'') > ''
          begin
            if @std_unit <> @unit_measure
            begin
            	select @unit_conversion = conversion
            	from unit_conversion uc,
            		 part_unit_conversion puc
            	where puc.part = @part and
            		  puc.code = uc.code and
            		  unit1 = @unit_measure and
            		  unit2 = @std_unit
            	if isnull(@unit_conversion,0) <> 0
          			update bill_of_material_ec set
          				std_qty = @unit_conversion * @quantity
          			where parent_part = @parent_part and
					part = @part and
          				start_datetime = @start_datetime
          		else
	          		update bill_of_material_ec set
	          			std_qty = @quantity
          			where parent_part = @parent_part and
					part = @part and
          				start_datetime = @start_datetime
          	end
          	else
          		update bill_of_material_ec set
          			std_qty = @quantity
     			where parent_part = @parent_part and
				part = @part and
     				start_datetime = @start_datetime
          end
          if @start_datetime=convert(datetime,'1980/01/01')
            select @start_datetime=@current_datetime
          execute msp_check_downline @@parent=@parent_part,@@child=@part
          if @start_datetime>@current_datetime
            begin
              select @most_recient_start_datetime=max(start_datetime)
                from bill_of_material_ec
                where parent_part=@parent_part
                and part=@part
                and start_datetime<@start_datetime
                and(end_datetime>@start_datetime
                or end_datetime is null)
              if @most_recient_start_datetime is not null
                begin
                  update bill_of_material_ec set
                    end_datetime=dateadd(ss,-1,@start_datetime),
                    date_changed=@current_datetime
                    where parent_part=@parent_part
                    and part=@part
                    and start_datetime=@most_recient_start_datetime
                end
              select @new_end_datetime=min(start_datetime)
                from bill_of_material_ec
                where parent_part=@parent_part
                and part=@part
                and start_datetime>@start_datetime
              if @new_end_datetime is not null
                begin
                  update bill_of_material_ec set
                    end_datetime=dateadd(ss,-1,@new_end_datetime),
                    date_changed=@current_datetime
                    where parent_part=@parent_part
                    and part=@part
                    and start_datetime=@start_datetime
                end
            end
          else
            begin
              select @most_recient_start_datetime=max(start_datetime)
                from bill_of_material_ec
                where parent_part=@parent_part
                and part=@part
                and start_datetime<@start_datetime
                and(end_datetime>@start_datetime
                or end_datetime is null)
              if @most_recient_start_datetime is not null
                begin
                  update bill_of_material_ec set
                    end_datetime=dateadd(ss,-1,@start_datetime),
                    date_changed=@current_datetime
                    where parent_part=@parent_part
                    and part=@part
                    and start_datetime=@most_recient_start_datetime
                end
              select @new_end_datetime=min(start_datetime)
                from bill_of_material_ec
                where parent_part=@parent_part
                and part=@part
                and start_datetime>@start_datetime
              if @new_end_datetime is not null
                begin
                  update bill_of_material_ec set
                    end_datetime=dateadd(ss,-1,@new_end_datetime),
                    date_changed=@current_datetime
                    where parent_part=@parent_part
                    and part=@part
                    and start_datetime=@start_datetime
                end
            end
        end
    end
end
go



print'
-------------------------------------
-- trigger:	mtr_bill_of_material_ec_d
-------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('mt_bill_of_material_ec_d'))
	drop trigger mt_bill_of_material_ec_d
GO
if exists (select * from dbo.sysobjects where id = object_id('mtr_bill_of_material_ec_d'))
	drop trigger mtr_bill_of_material_ec_d
GO

create trigger mtr_bill_of_material_ec_d
on bill_of_material_ec for delete
as
begin
  declare @current_datetime datetime,
  @parent_part varchar(25),
  @part varchar(25),
  @start_datetime datetime,
  @end_datetime datetime,
  @type varchar(1),
  @quantity decimal(20,6),
  @unit_measure varchar(2),
  @reference_no varchar(50),
  @std_qty decimal(20,6),
  @scrap_factor decimal(20,6),
  @engineering_level varchar(10),
  @operator varchar(5),
  @substitute_part varchar(25),
  @note varchar(255)
  if @@rowcount>1
    rollback transaction
  else
    begin
      select @current_datetime=convert(datetime,convert(varchar(12),GetDate())+' '+convert(varchar(2),datepart(hh,GetDate()))+':'+convert(varchar(2),datepart(mi,GetDate()))+':'+convert(varchar(2),datepart(ss,dateadd(ss,-1,GetDate()))))
      select @parent_part=parent_part,
        @part=part,
        @start_datetime=start_datetime,
        @end_datetime=end_datetime,
        @type=type,
        @quantity=quantity,
        @unit_measure=unit_measure,
        @reference_no=reference_no,
        @std_qty=std_qty,
        @scrap_factor=scrap_factor,
        @engineering_level=engineering_level,
        @operator=operator,
        @substitute_part=substitute_part,
        @note=note
        from deleted
      if @start_datetime<=@current_datetime
        and @end_datetime<@current_datetime
        begin
          rollback transaction
        end
      else
        begin
          insert into bill_of_material_ec(parent_part,
            part,
            start_datetime,
            end_datetime,
            type,
            quantity,
            unit_measure,
            reference_no,
            std_qty,
            scrap_factor,
            engineering_level,
            operator,
            substitute_part,
            date_changed,
            note) values(
            @parent_part,
            @part,
            @start_datetime,
            @current_datetime,
            @type,
            @quantity,
            @unit_measure,
            @reference_no,
            @std_qty,
            @scrap_factor,
            @engineering_level,
            @operator,
            @substitute_part,
            @current_datetime,
            @note)
        end
    end
end
go


print'
-------------------------------------
-- trigger:	mtr_bill_of_material_ec_u
-------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('mt_bill_of_material_ec_u'))
	drop trigger mt_bill_of_material_ec_u
GO
if exists (select * from dbo.sysobjects where id = object_id('mtr_bill_of_material_ec_u'))
	drop trigger mtr_bill_of_material_ec_u
GO

create trigger
mtr_bill_of_material_ec_u
on bill_of_material_ec for update
as
begin
  declare @current_datetime datetime,
  @closest_start_datetime datetime,
  @return_code integer,
  @inserted_parent_part varchar(25),
  @inserted_part varchar(25),
  @inserted_start_datetime datetime,
  @inserted_end_datetime datetime,
  @inserted_type varchar(1),
  @inserted_quantity decimal(20,6),
  @inserted_unit_measure varchar(2),
  @inserted_reference_no varchar(50),
  @inserted_std_qty decimal(20,6),
  @inserted_scrap_factor decimal(20,6),
  @inserted_engineering_level varchar(10),
  @inserted_operator varchar(5),
  @inserted_substitute_part varchar(25),
  @inserted_note varchar(255),
  @deleted_parent_part varchar(25),
  @deleted_part varchar(25),
  @deleted_start_datetime datetime,
  @deleted_end_datetime datetime,
  @deleted_type varchar(1),
  @deleted_quantity decimal(20,6),
  @deleted_unit_measure varchar(2),
  @deleted_reference_no varchar(50),
  @deleted_std_qty decimal(20,6),
  @deleted_scrap_factor decimal(20,6),
  @deleted_engineering_level varchar(10),
  @deleted_operator varchar(5),
  @deleted_substitute_part varchar(25),
  @deleted_note varchar(255),
  @std_unit varchar(2),
  @unit_conversion decimal(20,14),
  @adjusted_std_qty decimal(20,6)
  if @@rowcount>1
    rollback transaction
  else
    begin
      select @current_datetime=convert(datetime,convert(varchar(12),GetDate())+' '+convert(varchar(2),datepart(hh,GetDate()))+':'+convert(varchar(2),datepart(mi,GetDate()))+':'+convert(varchar(2),datepart(ss,GetDate())))
      select @inserted_parent_part=parent_part,
        @inserted_part=part,
        @inserted_start_datetime=start_datetime,
        @inserted_end_datetime=end_datetime,
        @inserted_type=type,
        @inserted_quantity=quantity,
        @inserted_unit_measure=unit_measure,
        @inserted_reference_no=reference_no,
        @inserted_std_qty=std_qty,
        @inserted_scrap_factor=scrap_factor,
        @inserted_engineering_level=engineering_level,
        @inserted_operator=operator,
        @inserted_substitute_part=substitute_part,
        @inserted_note=note
        from inserted
      select @deleted_parent_part=parent_part,
        @deleted_part=part,
        @deleted_start_datetime=start_datetime,
        @deleted_end_datetime=end_datetime,
        @deleted_type=type,
        @deleted_quantity=quantity,
        @deleted_unit_measure=unit_measure,
        @deleted_reference_no=reference_no,
        @deleted_std_qty=std_qty,
        @deleted_scrap_factor=scrap_factor,
        @deleted_engineering_level=engineering_level,
        @deleted_operator=operator,
        @deleted_substitute_part=substitute_part,
        @deleted_note=note
        from deleted
      if not update ( std_qty )
      begin
      if @inserted_start_datetime<@current_datetime
        and @inserted_end_datetime<@current_datetime
        begin
          rollback transaction
        end
      else
        begin
          if update(quantity) or update(unit_measure)
            begin
	          select @std_unit = standard_unit
	          from part_inventory
	          where part = @inserted_part
	          if isnull(@std_unit,'') > ''
	          begin
	            if @std_unit <> @inserted_unit_measure
	            begin
	            	select @unit_conversion = conversion
	            	from unit_conversion uc,
	            		 part_unit_conversion puc
	            	where puc.part = @inserted_part and
	            		  puc.code = uc.code and
	            		  unit1 = @inserted_unit_measure and
	            		  unit2 = @std_unit
	            	if isnull(@unit_conversion,0) <> 0
	          			select @adjusted_std_qty = @unit_conversion * @inserted_quantity
	          		else
		          		select @adjusted_std_qty = @inserted_quantity
	          	end
	          	else
	          		select @adjusted_std_qty = @inserted_quantity
	          end
            end
			else
				select @adjusted_std_qty = @inserted_std_qty

          if update(end_datetime)
            begin
              select @closest_start_datetime=min(start_datetime)
                from bill_of_material_ec
                where parent_part=@inserted_parent_part
                and part=@inserted_parent_part
                and start_datetime>@inserted_start_datetime
              if @closest_start_datetime is not null
                begin
                  update bill_of_material_ec set
                    start_datetime=dateadd(ss,1,@inserted_end_datetime),
                    date_changed=@current_datetime
                    where parent_part=@inserted_parent_part
                    and part=@inserted_part
                    and start_datetime=@closest_start_datetime
                end
            end
          if @inserted_start_datetime<=@current_datetime
            and(@inserted_end_datetime>=@current_datetime or @inserted_end_datetime is null)
            begin
              update bill_of_material_ec set
                end_datetime=dateadd(ss,-1,@current_datetime),
                date_changed=@current_datetime,
                type=@deleted_type,
                quantity=@deleted_quantity,
                unit_measure=@deleted_unit_measure,
                reference_no=@deleted_reference_no,
                std_qty=@deleted_std_qty,
                scrap_factor=@deleted_scrap_factor,
                engineering_level=@deleted_engineering_level,
                operator=@deleted_operator,
                substitute_part=@deleted_substitute_part,
                note=@deleted_note
                where parent_part=@inserted_parent_part
                and part=@inserted_part
                and start_datetime=@inserted_start_datetime
              insert into bill_of_material_ec(parent_part,
                part,
                start_datetime,
                end_datetime,
                type,
                quantity,
                unit_measure,
                reference_no,
                std_qty,
                scrap_factor,
                engineering_level,
                operator,
                substitute_part,
                date_changed,
                note) values(
                @inserted_parent_part,
                @inserted_part,
                @current_datetime,
                @inserted_end_datetime,
                @inserted_type,
                @inserted_quantity,
                @inserted_unit_measure,
                @inserted_reference_no,
                @adjusted_std_qty,
                @inserted_scrap_factor,
                @inserted_engineering_level,
                @inserted_operator,
                @inserted_substitute_part,
                @current_datetime,
                @inserted_note)
            end
        end
      end
    end
end
go


print'
--------------------------------------------------
-- TRIGGER:	mtr_currency_conversion_i (mssql)
--------------------------------------------------
'
if exists ( select * from dbo.sysobjects where id = object_id ( 'mtr_currency_conversion_i' ) )
	drop trigger mtr_currency_conversion_i
go

create trigger mtr_currency_conversion_i on currency_conversion for insert
as
begin
	-- declarations
	declare	@currency_code	varchar(10),
		@effective_date	datetime,
		@current_date	datetime

	-- declare cursor
	declare updated_rows cursor for
		select	currency_code,
			effective_date
		from	inserted

	-- open and fetch first row of cursor
	open updated_rows
	
	fetch updated_rows into @currency_code, @effective_date
	
	-- loop through records
	while ( @@fetch_status = 0 )
	begin
		select	@current_date = max ( effective_date )
		from	currency_conversion
		where	currency_code = @currency_code and
			effective_date <= GetDate ()
			
		if @effective_date = @current_date
		begin
			if update ( rate ) or update ( effective_date )
			begin
				exec msp_calc_order_currency null, null, null, null, @currency_code
				exec msp_calc_po_currency null, null, null, null, null, null, @currency_code
				exec msp_calc_invoice_currency null, null, null, null, @currency_code
				exec msp_calc_customer_matrix null, null, null, @currency_code
				exec msp_calc_vendor_matrix null, null, null, @currency_code
			end
		end
				
		fetch updated_rows into @currency_code, @effective_date
	end
	
	-- close cursor
	close updated_rows
	deallocate updated_rows
end
go



print'
--------------------------------------------------
-- TRIGGER:	mtr_currency_conversion_u (mssql)
--------------------------------------------------
'
if exists ( select * from dbo.sysobjects where id = object_id ( 'mtr_currency_conversion_u' ) )
	drop trigger mtr_currency_conversion_u
go

create trigger mtr_currency_conversion_u on currency_conversion for update
as
begin
	-- declarations
	declare	@currency_code	varchar(10),
		@effective_date	datetime,
		@current_date	datetime

	-- declare cursor
	declare updated_rows cursor for
		select	currency_code,
			effective_date
		from	inserted

	-- open and fetch first row of cursor
	open updated_rows
	
	fetch updated_rows into @currency_code, @effective_date
	
	-- loop through records
	while ( @@fetch_status = 0 )
	begin
		select	@current_date = max ( effective_date )
		from	currency_conversion
		where	currency_code = @currency_code and
			effective_date <= GetDate ()
			
		if @effective_date = @current_date
		begin
			if update ( rate ) or update ( effective_date )
			begin
				exec msp_calc_order_currency null, null, null, null, @currency_code
				exec msp_calc_po_currency null, null, null, null, null, null, @currency_code
				exec msp_calc_invoice_currency null, null, null, null, @currency_code
				exec msp_calc_customer_matrix null, null, null, @currency_code
				exec msp_calc_vendor_matrix null, null, null, @currency_code
			end
		end
				
		fetch updated_rows into @currency_code, @effective_date
	end
	
	-- close cursor
	close updated_rows
	deallocate updated_rows
end
go



print '
-------------------------------
-- TRIGGER:	mtr_order_detail_d
-------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_order_detail_d' )
	drop trigger mtr_order_detail_d
go

create trigger mtr_order_detail_d on order_detail for delete
as
begin
	-- declarations
	declare	@order_no			numeric(8,0),
		@sequence			numeric(5,0),
		@rowid				integer,
		@part				varchar(25),
		@shiptype			varchar(1),
		@suffix				integer

	-- get first updated/inserted row
	select	@order_no = min(order_no)
	from	deleted

	-- loop through all updated records
	while ( isnull(@order_no,-1) <> -1 )
	begin

		select	@sequence = min(sequence)
		from	deleted
		where	order_no = @order_no

		while ( isnull(@sequence,-1) <> -1 )
		begin

			select	@part = part_number,
				@rowid = row_id,
				@suffix = suffix,
				@shiptype = ship_type
			from	deleted
			where	order_no = @order_no and
				sequence = @sequence

			if isnull(@shiptype,'N') = 'N'
				exec msp_calculate_committed_qty @order_no, @part, @suffix
						
			select	@sequence = min(sequence)
			from	deleted
			where	order_no = @order_no and
				sequence > @sequence

		end

		select	@order_no = min(order_no)
		from	deleted
		where	order_no > @order_no

	end

end
go


print '
-------------------------------
-- TRIGGER:	mtr_order_detail_i
-------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_order_detail_iu' )
	drop trigger mtr_order_detail_iu
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_order_detail_i' )
	drop trigger mtr_order_detail_i
go

create trigger mtr_order_detail_i on order_detail for insert
as
begin
	-- declarations
	declare	@order_no	numeric(8,0),
		@sequence	numeric(5,0),
		@part		varchar(25),
		@configurable	varchar(1),
		@count		smallint,
		@suffix		integer,
		@type		varchar(1),
		@shiptype	varchar(1),
		@box_label	varchar(25),
		@pallet_label	varchar(25),
		@customer	varchar(10),
		@price_type	char(1)
		
	-- get first updated/inserted row
	select	@order_no = min(order_no)
	from	inserted

	-- loop through all updated records
	while ( isnull(@order_no,-1) <> -1 )
	begin

		select	@sequence = min(sequence)
		from	inserted
		where	order_no = @order_no

		while ( isnull(@sequence,-1) <> -1 )
		begin

			exec msp_calc_order_currency @order_no, null, null, @sequence, null

			-- check if a suffix is needed only for normal orders
			select	@type = order_type,
				@part = blanket_part,
				@box_label = box_label,
				@pallet_label = pallet_label,
				@customer = customer
			from	order_header
			where	order_no = @order_no
			
			select	@shiptype = ship_type
			from	inserted
			where	order_no = @order_no and
				sequence = @sequence
				
			if @type = 'N'
			begin
				-- create suffix if part is configurable
				select	@part = part_number
				from	inserted
				where	order_no = @order_no and
					sequence = @sequence
					
				select	@configurable = configurable
				from	part_inventory
				where	part = @part
	
				if IsNull ( @configurable, 'N' ) = 'Y'
				begin
					select @count = 1
					
					while ( @count > 0 )
					begin
					
						select	@suffix = next_suffix
						from	part_inventory
						where	part = @part
						
						select	@suffix = IsNull ( @suffix, 1 )
						
						update	part_inventory set
							next_suffix = @suffix + 1
						where	part = @part
						
						select	@count = count(suffix)
						from	order_detail
						where	part_number = @part and
							suffix = @suffix
						
						if @count <= 0
							select	@count = count(suffix)
							from	shipper_detail
							where	part = @part and
								suffix = @suffix
								
						if @count <= 0
							select	@count = count(suffix)
							from	object
							where	part = @part and
								suffix = @suffix
								
						if @count <= 0
							update 	order_detail 
							set	suffix = @suffix
							where	order_no = @order_no and
								sequence = @sequence
					end
				end
				else				
					-- create part_customer record if customer_additional.auto_profile is set to 'Y'
					-- and part is not configurable
					if isnull ( ( select isnull ( auto_profile, 'N' ) from customer where customer = @customer ), 'N' ) = 'Y' and
					   not exists ( select 1 from part_customer where customer = @customer and part = @part )
					begin
						if ( select isnull(category,'') from customer where customer = @customer ) > ''
							select @price_type = 'C'
						else
							select @price_type = 'B'
							
						insert into part_customer ( part, customer, customer_part, customer_standard_pack, taxable, customer_unit, type, upc_code, blanket_price )
						select @part, @customer, isnull(customer_part,''), std_qty, null, unit, @price_type, null, null from inserted where order_no = @order_no and sequence = @sequence
					end
			end
			else
				update	order_detail
				set	box_label = @box_label,
					pallet_label = @pallet_label
				where	order_no = @order_no and
					sequence = @sequence
						
			if isnull(@shiptype,'N') = 'N'
				exec msp_calculate_committed_qty @order_no, @part, @suffix
				
			select	@sequence = min(sequence)
			from	inserted
			where	order_no = @order_no and
				sequence > @sequence

		end

		select	@order_no = min(order_no)
		from	inserted
		where	order_no > @order_no

	end

end
go


print '
----------------------------------
-- TRIGGER:	mtr_order_detail_u
----------------------------------
'
if exists (	select	1
		from	sysobjects
		where	name = 'mtr_order_detail_u' )
	drop trigger mtr_order_detail_u
go

create trigger mtr_order_detail_u
on order_detail
for update
as
---------------------------------------------------------------------------------------
--	This trigger propagates price changes and calls for recalculation of committed
--	quantities for quantity or due date changes.
--
--	Modifications:	?? ??? ????	???			Original
--			26 AUG 1999	Eric E. Stimpson	Modified to loop through modified records.
--			17 NOV 1999	Chris B. Rogers		Changed statement below #7 to use order_no instead of sequence to fix lock up.
--
--	1,	Declarations
--	2.	Loop through all updated records for price changes.
--	3.	Get first order that has a price change.
--	4.	Get first sequence for current order that has a price change.
--	5,	Calculate standard price.
--	6.	Get the next sequence for current order that has a price change.
--	7.	Get the next order that has a price change.
--	8.	Loop through all normal updated records for quantity or due date changes.
--	9.	Get first order that has a quantity or due date change.
--	10.	Get first sequence for current order that has a quantity or due date change.
--	11,	Calculate committed quantity.
--	12.	Get the next sequence for current order that has a quantity or due date change.
--	13.	Get the next order that has a quantity or due date change.
--	14.	Loop through all dropship updated records for quantity or due date changes.
--	15.	Get first order that has a quantity or due date change.
--	16.	Get first sequence for current order that has a quantity or due date change.
--	17,	Calculate committed dropship quantity.
--	18.	Get the next sequence for current order that has a quantity or due date change.
--	19.	Get the next order that has a quantity or due date change.
---------------------------------------------------------------------------------------

--	1,	Declarations
declare	@order_no			numeric(8,0),
	@sequence			numeric(5,0),
	@rowid				integer,
	@part				varchar(25),
	@suffix				integer

--	2.	Loop through all updated records for price changes.
--	3.	Get first order that has a price change.
select	@order_no = min ( deleted.order_no )
from	deleted
	join order_detail on order_detail.order_no = deleted.order_no and
		order_detail.sequence = deleted.sequence
where	IsNull ( order_detail.alternate_price, -1 ) <> IsNull ( deleted.alternate_price, -1 )

while isnull ( @order_no, -1 ) <> -1
begin

--	4.	Get first sequence for current order that has a price change.
	select	@sequence = min ( deleted.sequence )
	from	deleted
		join order_detail on order_detail.order_no = @order_no and
			order_detail.sequence = deleted.sequence
	where	IsNull ( order_detail.alternate_price, -1 ) <> IsNull ( deleted.alternate_price, -1 ) and
		deleted.order_no = @order_no

	while isnull ( @sequence, -1 ) <> -1
	begin

--	5,	Calculate standard price.
		exec msp_calc_order_currency @order_no, null, null, @sequence, null
		
--	6.	Get the next sequence for current order that has a price change.
		select	@sequence = min ( deleted.sequence )
		from	deleted
			join order_detail on order_detail.order_no = @order_no and
				order_detail.sequence = deleted.sequence
		where	IsNull ( order_detail.alternate_price, -1 ) <> IsNull ( deleted.alternate_price, -1 ) and
			deleted.order_no = @order_no and
			deleted.sequence > @sequence
	end

--	7.	Get the next order that has a price change.
	select	@order_no = min ( deleted.order_no )
	from	deleted
		join order_detail on order_detail.order_no = @order_no and
			order_detail.sequence = deleted.sequence
	where	IsNull ( order_detail.alternate_price, -1 ) <> IsNull ( deleted.alternate_price, -1 ) and
		deleted.order_no > @order_no
end

--	8.	Loop through all normal updated records for quantity or due date changes.
--	9.	Get first order that has a quantity or due date change.
select	@order_no = min ( deleted.order_no )
from	deleted
	join order_detail on order_detail.order_no = deleted.order_no and
		order_detail.sequence = deleted.sequence
where	(	order_detail.quantity <> deleted.quantity or
		order_detail.due_date <> deleted.due_date ) and
	deleted.ship_type = 'N'
		
while isnull ( @order_no, -1 ) <> -1
begin

--	10.	Get first sequence for current order that has a quantity or due date change.
	select	@sequence = min ( deleted.sequence )
	from	deleted
		join order_detail on order_detail.order_no = deleted.order_no and
			order_detail.sequence = deleted.sequence
	where	(	order_detail.quantity <> deleted.quantity or
			order_detail.due_date <> deleted.due_date ) and
		deleted.ship_type = 'N' and
		deleted.order_no = @order_no

	while isnull ( @sequence, -1 ) <> -1
	begin

--	11,	Calculate committed quantity.
		select	@part = part_number,
			@suffix = suffix
		from	order_detail
		where	order_no = @order_no and
			sequence = @sequence

		exec msp_calculate_committed_qty @order_no, @part, @suffix
		
--	12.	Get the next sequence for current order that has a quantity or due date change.
		select	@sequence = min ( deleted.sequence )
		from	deleted
			join order_detail on order_detail.order_no = deleted.order_no and
				order_detail.sequence = deleted.sequence
		where	(	order_detail.quantity <> deleted.quantity or
				order_detail.due_date <> deleted.due_date ) and
			deleted.ship_type = 'N' and
			deleted.order_no = @order_no and
			deleted.sequence > @sequence
	end

--	13.	Get the next order that has a quantity or due date change.
	select	@order_no = min ( deleted.order_no )
	from	deleted
		join order_detail on order_detail.order_no = deleted.order_no and
			order_detail.sequence = deleted.sequence
	where	(	order_detail.quantity <> deleted.quantity or
			order_detail.due_date <> deleted.due_date ) and
		deleted.ship_type = 'N' and
		deleted.order_no > @order_no
end


--	14.	Loop through all dropship updated records for quantity or due date changes.
--	15.	Get first order that has a quantity or due date change.
select	@order_no = min ( deleted.order_no )
from	deleted
	join order_detail on order_detail.order_no = deleted.order_no and
		order_detail.sequence = deleted.sequence
where	(	order_detail.quantity <> deleted.quantity or
		order_detail.due_date <> deleted.due_date ) and
	deleted.ship_type = 'D'
		
while isnull ( @order_no, -1 ) <> -1
begin

--	16.	Get first sequence for current order that has a quantity or due date change.
	select	@sequence = min ( deleted.sequence )
	from	deleted
		join order_detail on order_detail.order_no = deleted.order_no and
			order_detail.sequence = deleted.sequence
	where	(	order_detail.quantity <> deleted.quantity or
			order_detail.due_date <> deleted.due_date ) and
		deleted.ship_type = 'D' and
		deleted.order_no = @order_no

	while isnull ( @sequence, -1 ) <> -1
	begin

--	17,	Calculate committed dropship quantity.
		select	@rowid = row_id
		from	order_detail
		where	order_no = @order_no and
			sequence = @sequence

		exec msp_calc_committed_dropship @order_no, @rowid
		
--	18.	Get the next sequence for current order that has a quantity or due date change.
		select	@sequence = min ( deleted.sequence )
		from	deleted
			join order_detail on order_detail.order_no = deleted.order_no and
				order_detail.sequence = deleted.sequence
		where	(	order_detail.quantity <> deleted.quantity or
				order_detail.due_date <> deleted.due_date ) and
			deleted.ship_type = 'D' and
			deleted.order_no = @order_no and
			deleted.sequence > @sequence
	end

--	19.	Get the next order that has a quantity or due date change.
	select	@order_no = min ( deleted.order_no )
	from	deleted
		join order_detail on order_detail.order_no = deleted.order_no and
			order_detail.sequence = deleted.sequence
	where	(	order_detail.quantity <> deleted.quantity or
			order_detail.due_date <> deleted.due_date ) and
		deleted.ship_type = 'D' and
		deleted.order_no > @order_no
end
go


update order_detail set quantity = quantity + 1
go



print'
-------------------------------
-- TRIGGER:	mtr_order_header_i
-------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_order_header_iu' )
	drop trigger mtr_order_header_iu
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_order_header_i' )
	drop trigger mtr_order_header_i
go

create trigger mtr_order_header_i on order_header for insert
as
begin
	-- declarations
	declare	@order_no	numeric(8,0),
			@inserted_status varchar(20)

	-- get first updated/inserted row
	select	@order_no = min(order_no)
	from	inserted

	-- loop through all updated records and call procedure to calculate the currency price
	while ( isnull(@order_no,-1) <> -1 )
	begin

		exec msp_calc_order_currency @order_no, null, null, null, null

		select	@inserted_status = isnull(cs_status,'')
		from	inserted
		where	order_no = @order_no

		update 	shipper 
		set		cs_status = @inserted_status
		from 	shipper_detail
		where 	shipper.id = shipper_detail.shipper and
				shipper_detail.order_no = @order_no

		select	@order_no = min(order_no)
		from	inserted
		where	order_no > @order_no

	end

end
go


-------------------------------
-- TRIGGER:	mtr_order_header_u
-------------------------------
if exists ( select 1 from sysobjects where name = 'mtr_order_header_u' )
	drop trigger mtr_order_header_u
GO

create trigger mtr_order_header_u
on order_header
for update
as
-- declarations
declare	@order_no	numeric(8,0),
	@deleted_cu	varchar(3),
	@deleted_ap	numeric(20,6),
	@deleted_status varchar(20),
	@deleted_box_label varchar(25),
	@deleted_pallet_label varchar(25),
	@inserted_cu varchar(3),
	@inserted_ap numeric(20,6),
	@inserted_status varchar(20),
	@inserted_box_label varchar(25),
	@inserted_pallet_label varchar(25),
	@type varchar(1)

-- get first updated/inserted row
select	@order_no = min(order_no)
from	inserted

-- loop through all updated records and call procedure to generate kanban and calculate the currency price.
while ( isnull(@order_no,-1) <> -1 )
begin
	EXECUTE	msp_generate_kanban @order_no

	select	@inserted_cu = currency_unit,
		@inserted_ap = alternate_price,
		@inserted_status = cs_status,
		@inserted_box_label = box_label,
		@inserted_pallet_label = pallet_label,
		@type = order_type
	from	inserted
	where	order_no = @order_no

	select	@deleted_cu = currency_unit,
		@deleted_ap = alternate_price,
		@deleted_status = cs_status,
		@deleted_box_label = box_label,
		@deleted_pallet_label = pallet_label
	from	deleted
	where	order_no = @order_no

	select @inserted_cu = isnull(@inserted_cu,'')
	select @inserted_ap = isnull(@inserted_ap,0)
	select @inserted_status = isnull(@inserted_status,'')
	select @inserted_box_label = isnull ( @inserted_box_label, '' )
	select @inserted_pallet_label = isnull ( @inserted_pallet_label, '' )
	select @deleted_cu = isnull(@deleted_cu,'')
	select @deleted_ap = isnull(@deleted_ap,0)
	select @deleted_status = isnull(@deleted_status,'')
	select @deleted_box_label = isnull ( @deleted_box_label, '' )
	select @deleted_pallet_label = isnull ( @deleted_pallet_label, '' )

	if 	@inserted_cu <> @deleted_cu or
		@inserted_ap <> @deleted_ap
		exec msp_calc_order_currency @order_no, null, null, null, null
/*	else if @inserted_status <> @deleted_status
		update 	shipper 
		set	cs_status = @inserted_status
		from 	shipper_detail
		where 	shipper.id = shipper_detail.shipper and
			shipper_detail.order_no = @order_no
*/
	if	@type = 'B' and
		( @inserted_box_label <> @deleted_box_label or
		@inserted_pallet_label <> @deleted_pallet_label )
		update	order_detail
		set	box_label = @inserted_box_label,
			pallet_label = @inserted_pallet_label
		where	order_no = @order_no
		
	select	@order_no = min(order_no)
	from	inserted
	where	order_no > @order_no

end
GO

print '
--------------------------------
-- TRIGGER:	mtr_parameters_u
--------------------------------
'
if exists (
	select	1
	from	sysobjects
	where	id = object_id ( 'mtr_parameters_u' ) )
	drop trigger mtr_parameters_u
go

create trigger mtr_parameters_u
on parameters
for update
as

declare	@shipper	integer,
	@invoice	integer
	
if update ( shipper ) or update ( next_invoice )
begin
	select	@shipper = shipper,
		@invoice = next_invoice
	from	inserted
	
	if isnull ( @shipper, 0 ) <> isnull ( @invoice, 0 )
		exec msp_sync_parm_shipper_invoice
end

go


print '
----------------------------------
-- TRIGGER:	mtr_part_machine_i
----------------------------------
'
if exists ( select * from dbo.sysobjects where id = object_id('mt_part_machine_i'))
	drop trigger mt_part_machine_i
go
if exists ( select * from dbo.sysobjects where id = object_id('mtr_part_machine_i'))
	drop trigger mtr_part_machine_i
go

create trigger mtr_part_machine_i
on part_machine for insert
as
begin
	declare @machine varchar(15),
		@activity varchar(25),
		@part varchar(25),
		@sequence integer
  
	declare new_recs cursor for
	  	select 	machine,
	    		activity,
	    		part,
	    		sequence
		from 	inserted

	open new_recs
	fetch new_recs into @machine,@activity,@part,@sequence
	while ( @@fetch_status = 0 )
	begin
		if @sequence=1
			update	activity_router 
			set	group_location=@machine
			where 	part=@part and 
				code=@activity

		fetch new_recs into @machine,@activity,@part,@sequence
	end
	close new_recs
	deallocate new_recs
end
go


print '
----------------------------------
-- TRIGGER:	mtr_part_machine_u
----------------------------------
'
if exists ( select * from dbo.sysobjects where id = object_id('mt_part_machine_u'))
	drop trigger mt_part_machine_u
go
if exists ( select * from dbo.sysobjects where id = object_id('mtr_part_machine_u'))
	drop trigger mtr_part_machine_u
go

create trigger mtr_part_machine_u
on part_machine for update
as
begin
	declare @machine varchar(15),
		@part varchar(25),
		@activity varchar(25),
		@sequence integer

	declare updated_recs cursor for
		select 	machine,
			part,
			activity,
			sequence
		from 	inserted

	open updated_recs
	fetch updated_recs into @machine,@part,@activity,@sequence
	while ( @@fetch_status = 0 )
	begin
		if @sequence=1
			update activity_router set
			group_location=@machine
			where part=@part
			and code=@activity

		fetch updated_recs into @machine,@part,@activity,@sequence
	end
	close updated_recs
	deallocate updated_recs
end
go



print '
----------------------------------
-- TRIGGER:	mtr_part_machine_d
----------------------------------
'
if exists ( select * from dbo.sysobjects where id = object_id('mt_part_machine_d'))
	drop trigger mt_part_machine_d
go
if exists ( select * from dbo.sysobjects where id = object_id('mtr_part_machine_d'))
	drop trigger mtr_part_machine_d
go

create trigger mtr_part_machine_d
on part_machine for delete
as
begin
	declare @sequence integer,
		@part varchar(25),
		@machine varchar(15),
		@activity varchar(25)

	declare deleted_recs cursor for
		select	machine,
			part,
			activity,
			sequence
		from deleted

	open deleted_recs
	fetch deleted_recs into @machine, @part, @activity, @sequence
	while ( @@fetch_status = 0 )
	begin
		if @sequence=1
		begin
			select 	@sequence=min(sequence)
			from 	part_machine
			where 	part=@part and 
				machine=@machine and 
				activity=@activity

			if isnull(@sequence,0)>0
				update 	activity_router 
				set	group_location=@machine
			  	where 	part=@part and 
			  		code=@activity
			else
				update 	activity_router 
				set	group_location=''
			  	where 	part=@part and
			  		code=@activity
		end
		fetch deleted_recs into @machine, @part, @activity, @sequence
	end
	close deleted_recs
	deallocate deleted_recs
end
go



print'
----------------------
-- trigger:	mtr_part_i
----------------------
'
IF EXISTS ( select * from dbo.sysobjects where name = 'mtr_part_i')
   drop trigger mtr_part_i
go

CREATE TRIGGER mtr_part_i ON part
FOR INSERT
AS
BEGIN
   INSERT INTO part_standard (part) (SELECT part FROM inserted)
END
GO

print'
----------------------
-- trigger:	mtr_part_u
----------------------
'
IF EXISTS ( select * from dbo.sysobjects where name = 'mtr_part_u')
   drop trigger mtr_part_u
go
CREATE TRIGGER mtr_part_u ON part
FOR UPDATE
AS
BEGIN
   Declare @dpart varchar(25),
           @ipart varchar(25)
   SELECT @dpart=part 
     FROM deleted  
   SELECT @ipart=part 
     FROM inserted
   IF (@dpart <> @ipart) 
   BEGIN
     DELETE part_standard WHERE part IN (SELECT part FROM deleted)
     INSERT INTO part_standard (part) (SELECT part FROM inserted)
   END 
END
GO


print'
----------------------
-- trigger:	mtr_part_d
----------------------
'
IF EXISTS ( select * from dbo.sysobjects where name = 'mtr_part_d')
   drop trigger mtr_part_d
go

CREATE TRIGGER mtr_part_d ON part
FOR DELETE
AS
BEGIN
   DELETE part_standard WHERE part IN (SELECT part FROM deleted)
END
GO


print'
---------------------------------------------
-- TRIGGER:	mtr_pc_price_matrix_i
---------------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_pc_price_matrix_iu'  )
	drop trigger mtr_pc_price_matrix_iu
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_pc_price_matrix_i'  )
	drop trigger mtr_pc_price_matrix_i
go

create trigger mtr_pc_price_matrix_i on part_customer_price_matrix for insert
as
begin
	-- declare local variables
	declare	@part				varchar(25),
			@customer			varchar(10),
			@qty_break			numeric(20,6)

	-- get first updated/inserted row
	select	@part = min(part)
	from	inserted

	-- loop through all updated records
	while ( isnull(@part,'') <> '' )
	begin

		select 	@customer = min(customer)
		from	inserted
		where	part = @part

		while ( isnull(@customer,'') <> '' )
		begin

			select	@qty_break = min(qty_break)
			from	inserted
			where	part = @part and
					customer = @customer

			while ( isnull(@qty_break,-1) <> -1 )
			begin

				exec msp_calc_customer_matrix @part, @customer, @qty_break, null
			
				select	@qty_break = min(qty_break)
				from	inserted
				where	part = @part and
						customer = @customer and
						qty_break > @qty_break

			end

			select 	@customer = min(customer)
			from	inserted
			where	part = @part and
					customer > @customer

		end

		select	@part = min(part)
		from	inserted
		where	part > @part

	end

end
go




print'
---------------------------------------------
-- TRIGGER:	mtr_pc_price_matrix_u
---------------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_pc_price_matrix_u'  )
	drop trigger mtr_pc_price_matrix_u
go

create trigger mtr_pc_price_matrix_u on part_customer_price_matrix for update
as
begin
	-- declare local variables
	declare	@part				varchar(25),
			@customer			varchar(10),
			@qty_break			numeric(20,6),
			@inserted_ap		numeric(20,6),
			@deleted_ap			numeric(20,6)

	-- get first updated/inserted row
	select	@part = min(part)
	from	inserted

	-- loop through all updated records
	while ( isnull(@part,'') <> '' )
	begin

		select 	@customer = min(customer)
		from	inserted
		where	part = @part

		while ( isnull(@customer,'') <> '' )
		begin

			select	@qty_break = min(qty_break)
			from	inserted
			where	part = @part and
					customer = @customer

			while ( isnull(@qty_break,-1) <> -1 )
			begin

				select	@deleted_ap = alternate_price
				from	deleted
				where	part = @part and
						customer = @customer and
						qty_break = @qty_break

				select	@inserted_ap = alternate_price
				from	inserted
				where	part = @part and
						customer = @customer and
						qty_break = @qty_break

				select @deleted_ap = isnull(@deleted_ap,0)
				select @inserted_ap = isnull(@inserted_ap,0)

				if @deleted_ap <> @inserted_ap
					exec msp_calc_customer_matrix @part, @customer, @qty_break, null
			
				select	@qty_break = min(qty_break)
				from	inserted
				where	part = @part and
						customer = @customer and
						qty_break > @qty_break

			end

			select 	@customer = min(customer)
			from	inserted
			where	part = @part and
					customer > @customer

		end

		select	@part = min(part)
		from	inserted
		where	part > @part

	end

end
go


print'
----------------------------
-- TRIGGER:	mtr_po_detail_i
----------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_po_detail_iu' )
	drop trigger mtr_po_detail_iu
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_po_detail_i' )
	drop trigger mtr_po_detail_i
go

create trigger mtr_po_detail_i on po_detail for insert
as
begin
	-- declarations
	declare	@po_number		integer,
		@row_id			numeric(20),
		@part			varchar(25),
		@date_due		datetime,
		@today			datetime

	select	@today = GetDate()

	-- get first updated row
	select	@po_number = min(po_number)
	from 	inserted

	-- loop through all updated records
	while ( isnull(@po_number,-1) <> -1 )
	begin

		select	@row_id = min(row_id)
		from	inserted
		where	po_number = @po_number

		while ( isnull(@row_id,-1) <> -1 )
		begin
		
			select	@part = min(part_number)
			from	inserted
			where	po_number = @po_number and
				row_id = @row_id

			while ( isnull(@part,'') > '' )
			begin

				select	@date_due = min(date_due)
				from	inserted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number = @part

				while ( isnull(@date_due,@today) <> @today )
				begin

					exec msp_calc_po_currency @po_number, null, null, @row_id, @part, @date_due, null

					select	@date_due = min(date_due)
					from	inserted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due > @date_due

				end

				select	@part = min(part_number)
				from	inserted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number > @part

			end

			select	@row_id = min(row_id)
			from	inserted
			where	po_number = @po_number and
				row_id > @row_id

		end

		select	@po_number = min(po_number)
		from 	inserted
		where	po_number > @po_number

	end

end
go
 
-------------------------------
-- TRIGGER:	mtr_po_detail_u
-------------------------------
if exists ( select 1 from sysobjects where name = 'mtr_po_detail_u' )
	drop trigger mtr_po_detail_u
go

create trigger mtr_po_detail_u on po_detail for update
as
begin
	-- declarations
	declare	@po_number	integer,
		@row_id		integer,
		@part		varchar(25),
		@date_due	datetime,
		@inserted_ap	numeric(20,6),
		@deleted_ap	numeric(20,6),
		@today		datetime, 
		@release_no	integer,
		@uom		char(2),
		@type		char(1)

	declare	@requisition_id	integer,
		@quantity_old	numeric (20,6),
		@received	numeric (20,6),
		@total_rows	integer,
		@count		integer,
		@received_new	numeric (20,6),
		@part_old	varchar (25),
		@name		varchar (50),
		@quantity_new	numeric (20,6),
		@deleted	varchar (1),
		@vendor_old	varchar (10),
		@vendor_new	varchar (10),
		@price_new	numeric (20,6),
		@price_old	numeric (20,6)

	select	@today = GetDate()

	-- get first updated row
	select	@po_number = min(po_number)
	from 	inserted

	-- loop through all updated records
	while ( isnull(@po_number,-1) <> -1 )
	begin

		select	@row_id = min(row_id)
		from	inserted
		where	po_number = @po_number

		while ( isnull(@row_id,-1) <> -1 )
		begin
		
			select	@part = min(part_number)
			from	inserted
			where	po_number = @po_number and
				row_id = @row_id

			while ( isnull(@part,'') > '' )
			begin

				select	@date_due = min(date_due)
				from	inserted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number = @part

-- from here 11/13/02					
				select	@quantity_new = quantity,
				  	@received_new = received,
					@price_new = price,
					@vendor_new = vendor_code,
					@release_no = release_no,
					@uom = unit_of_measure,
					@type = type
				from	inserted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number = @part and
					date_due = @date_due

				select  @received	= received,
				   	@quantity_old   = quantity
				from	deleted 
				where	po_number = @po_number and
					row_id = @row_id and
					part_number = @part and
					date_due = @date_due

				if (update(received) or update(quantity)) and (@received_new-@received) <> 0 and @quantity_new > 0 
				begin
					insert into cdipohistory 
						(po_number, vendor, part, uom, date_due, type, last_recvd_date, 
						last_recvd_amount, quantity, received, balance,	price, row_id, 
						release_no)
					values	(@po_number, @vendor_new, @part, @uom, @date_due, @type, 
						GetDate(), (@received_new-@received),@quantity_new, @received_new, 
						(@quantity_new - @received_new),@price_new, @row_id, @release_no)
				end
-- till here 11/13/02
					

				while ( isnull(@date_due,@today) <> @today )
				begin

					select	@deleted_ap = alternate_price
					from	deleted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due = @date_due

					select	@inserted_ap = alternate_price,
						@name	     = description,
						@quantity_new = quantity,
					  	@received_new = received,
						@deleted  = deleted,
						@price_new = price
					from	inserted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due = @date_due

					select @deleted_ap = isnull(@deleted_ap,0)
					select @inserted_ap = isnull(@inserted_ap,0)

					if @inserted_ap <> @deleted_ap
						exec msp_calc_po_currency @po_number, null, null, @row_id, @part, @date_due, null

					select  @part_old = part_number,
						@requisition_id = requisition_id,
						@received	= received,
					   	@quantity_old   = quantity,
						@price_old	= price
					from	deleted 
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due = @date_due

					if @requisition_id > 0 
					begin
						if @part_old <> @part
						begin
							update requisition_detail
							set part_number = @part,
							    description = @name,
							    status = 'Modified',	
							    status_notes = 'Modified part number from ' + @part_old  + ' to new part number: ' + @part + ' on ' + convert ( varchar (20), getdate( ) )
							where requisition_number = @requisition_id
							and   po_rowid = @row_id 	
							and   po_number = @po_number 

							update requisition_header
							set status = '8',
							    status_notes = 'Modified part number on detail item on :' + convert ( varchar (20), getdate( ) )
							where requisition_number = @requisition_id
						end
						else if @part_old = @part
						begin

							-- check if received quantity was changed or not 
							if @received_new > 0 and @received_new >= @quantity_new
							begin
								update requisition_detail
								set status = 'Completed',
							        status_notes = 'Completed on ' + convert ( varchar (20), getdate( ) )
								where requisition_number = @requisition_id
								and   po_rowid = @row_id 
								and   po_number = @po_number 

								select @total_rows = count(*)
								from  requisition_detail
								where requisition_number = @requisition_id 

								select @count = count(*)
								from  requisition_detail
								where requisition_number = @requisition_id
								and status = 'Completed'
			
								if @total_rows = @count 
								begin
									update requisition_header
									set status = '7',
									    status_notes = 'Completed on ' + + convert ( varchar (20), getdate( ) )
									where requisition_number = @requisition_id
						    		end	
							end

							-- check if quantity was changed or not 
							else if @quantity_old <> @quantity_new
								update requisition_detail
								set quantity = @quantity_new,
								    status = 'Modified',	
								    status_notes = 'Modified quantity from ' + convert ( varchar (20), @quantity_old)  + ' to quantity: ' + convert ( varchar (20), @quantity_new ) + ' on ' + convert ( varchar (20), getdate( ) )
								where requisition_number = @requisition_id
								and   po_rowid = @row_id 
								and   po_number = @po_number 

							-- check if item marked for deletion 
							else if @deleted = 'Y' 	
							begin
								update requisition_detail
								set po_number = null,
								    status = 'Modified',
								    status_notes = 'Deleted from PO: ' + convert ( varchar(15), po_number ) + ' on ' + convert ( varchar (20), getdate( ) )
							        where requisition_number = @requisition_id
								and   po_rowid = @row_id 
								and   po_number = @po_number 

								update requisition_header
								set status = '8',
							        status_notes = 'Modified part number on detail item on :' + convert ( varchar (20), getdate( ) )
								where requisition_number = @requisition_id
							end
						end
						else if @price_old <> @price_new
							update requisition_detail
							set unit_cost = @price_new
						        where requisition_number = @requisition_id
							and   po_rowid = @row_id 
							and   po_number = @po_number 
					end
					
					select	@date_due = min(date_due)
					from	inserted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due > @date_due

				end

				select	@part = min(part_number)
				from	inserted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number > @part

			end

			select	@row_id = min(row_id)
			from	inserted
			where	po_number = @po_number and
				row_id > @row_id

		end

		select	@po_number = min(po_number)
		from 	inserted
		where	po_number > @po_number

	end

end
go

print '
-------------------------------------------------------
--  add delete trigger on po detail 
-------------------------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_po_detail_d' )
    drop trigger mtr_po_detail_d
go

create trigger mtr_po_detail_d on po_detail for delete
as
begin
	declare @requisition_id integer,
		@quantity   	numeric (20,6),
		@received   	numeric (20,6),
		@total_rows 	integer,
		@count      	integer,
		@row_id     	integer,
		@po_number  	integer,
		@part		varchar(25),
		@date_due	datetime,
		@today		datetime
	
	select	@today = GetDate()

	-- get first updated row
	select	@po_number = min(po_number)
	from 	deleted

	-- loop through all updated records
	while ( isnull(@po_number,-1) <> -1 )
	begin

		select	@row_id = min(row_id)
		from	deleted
		where	po_number = @po_number

		while ( isnull(@row_id,-1) <> -1 )
		begin
		
			select	@part = min(part_number)
			from	deleted
			where	po_number = @po_number and
				row_id = @row_id

			while ( isnull(@part,'') > '' )
			begin

				select	@date_due = min(date_due)
				from	deleted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number = @part

				while ( isnull(@date_due,@today) <> @today )
				begin

					select	@requisition_id = requisition_id,
						@quantity = quantity,
						@received = received
					from	deleted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due = @date_due
						
					if @requisition_id > 0 
					begin
					
						if @received <= 0 
						begin
							update 	requisition_detail
							set 	po_number = null,
								status = 'Modified',
							    	status_notes = 'Deleted from PO: ' + convert ( varchar(15), po_number ) + ' on ' + convert ( varchar (20), getdate( ) )
							where	requisition_number = @requisition_id and
								po_rowid = @row_id and
								po_number = @po_number 
						
							update	requisition_header
							set	status = '8'
							where 	requisition_number = @requisition_id
						end
						else if @received >= @quantity
						begin
							update	requisition_detail
							set	status = 'Completed',
								status_notes = 'Completed on ' + + convert ( varchar (20), getdate( ) )
							where	requisition_number = @requisition_id and
								po_rowid = @row_id and
								po_number = @po_number 
						
							select	@total_rows = count(*)
							from	requisition_detail
							where	requisition_number = @requisition_id
						
							select	@count = count(*)
							from	requisition_detail
							where	requisition_number = @requisition_id and
								status = 'Completed'
								
							if @total_rows = @count 
							begin
								update	requisition_header
								set	status = '7',
									status_notes = 'Completed on ' + + convert ( varchar (20), getdate( ) )
								where	requisition_number = @requisition_id
							end
						
						end
					end
					
					select	@date_due = min(date_due)
					from	deleted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due > @date_due

				end

				select	@part = min(part_number)
				from	deleted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number > @part

			end

			select	@row_id = min(row_id)
			from	deleted
			where	po_number = @po_number and
				row_id > @row_id

		end

		select	@po_number = min(po_number)
		from 	deleted
		where	po_number > @po_number

	end

end
go



print '
---------------------------
-- TRIGGER:	mtr_po_header_u
---------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('dbo.mtr_po_header_u') and sysstat & 0xf = 8)
	drop trigger dbo.mtr_po_header_u
GO

create trigger mtr_po_header_u on po_header for update
as
begin
	-- declarations
	declare	@po_number		integer,
		@deleted_cu		varchar(3),
		@inserted_cu		varchar(3),
		@vendor_old		varchar(10),
		@vendor_new		varchar(10)

	-- get first updated row
	select	@po_number = min(po_number)
	from 	inserted


	-- loop through all updated records
	while ( isnull(@po_number,-1) <> -1 )
	begin

		select	@deleted_cu = currency_unit,
			@vendor_old = vendor_code
		from	deleted
		where	po_number = @po_number

		select	@inserted_cu = currency_unit,
			@vendor_new = vendor_code
		from	inserted
		where	po_number = @po_number

		select @deleted_cu = isnull(@deleted_cu,'')
		select @inserted_cu = isnull(@inserted_cu,'')

		if @deleted_cu <> @inserted_cu
			exec msp_calc_po_currency @po_number, null, null, null, null, null, null

		-- included this block to check if user changed vendor code and update necessary tables 
		if @vendor_old <> @vendor_new
		begin
			update po_detail
			set vendor_code = @vendor_new
			where po_number = @po_number

			update requisition_detail
			set vendor_code = @vendor_new,
		        status = 'Modified',	
		        status_notes = 'Modified Vendor Code from ' + @vendor_old  + ' to different Vendor: ' + @vendor_new + ' on ' + convert ( varchar (20), getdate( ) )
			where po_number = @po_number 

			update requisition_header
			set status = '8',
		 	status_notes = 'Modified Vendor Code on detail item on : '  + convert ( varchar (20), getdate( ) )
			where requisition_number in (	select distinct (requisition_id)
							from po_detail
							where po_detail.po_number = @po_number )	
		end

		select	@po_number = min(po_number)
		from 	inserted
		where	po_number > @po_number

	end

end

GO


print'
---------------------------------------------
-- TRIGGER:	mtr_pv_price_matrix_i
---------------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_pv_price_matrix_iu' )
	drop trigger mtr_pv_price_matrix_iu
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_pv_price_matrix_i' )
	drop trigger mtr_pv_price_matrix_i
go

create trigger mtr_pv_price_matrix_i on part_vendor_price_matrix for insert
as
begin
	-- declare local variables
	declare	@part				varchar(25),
			@vendor				varchar(10),
			@qty_break			numeric(20,6)

	-- get first updated/inserted row
	select	@part = min(part)
	from	inserted

	-- loop through all updated records
	while ( isnull(@part,'') <> '' )
	begin

		select	@vendor = min(vendor)
		from	inserted
		where	part = @part

		while ( isnull(@vendor,'') <> '' )
		begin

			select	@qty_break = min(break_qty)
			from	inserted
			where	part = @part and
					vendor = @vendor

			while ( isnull(@qty_break,-1) <> -1 )
			begin

				exec msp_calc_vendor_matrix @part, @vendor, @qty_break, null

				select	@qty_break = min(break_qty)
				from	inserted
				where	part = @part and
						vendor = @vendor and
						break_qty > @qty_break

			end

			select	@vendor = min(vendor)
			from	inserted
			where	part = @part and
					vendor > @vendor

		end

		select	@part = min(part)
		from	inserted
		where	part > @part

	end

end
go


print'
---------------------------------------------
-- TRIGGER:	mtr_pv_price_matrix_u
---------------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_pv_price_matrix_u' )
	drop trigger mtr_pv_price_matrix_u
go

create trigger mtr_pv_price_matrix_u on part_vendor_price_matrix for update
as
begin
	-- declare local variables
	declare	@part				varchar(25),
			@vendor				varchar(10),
			@qty_break			numeric(20,6),
			@inserted_ap		numeric(20,6),
			@deleted_ap			numeric(20,6)

	-- get first updated/inserted row
	select	@part = min(part)
	from	inserted

	-- loop through all updated records
	while ( isnull(@part,'') <> '' )
	begin

		select	@vendor = min(vendor)
		from	inserted
		where	part = @part

		while ( isnull(@vendor,'') <> '' )
		begin

			select	@qty_break = min(break_qty)
			from	inserted
			where	part = @part and
					vendor = @vendor

			while ( isnull(@qty_break,-1) <> -1 )
			begin

				select	@deleted_ap = alternate_price
				from	deleted
				where	part = @part and
						vendor = @vendor and
						break_qty = @qty_break

				select	@inserted_ap = alternate_price
				from	inserted
				where	part = @part and
						vendor = @vendor and
						break_qty = @qty_break

				select @deleted_ap = isnull(@deleted_ap,0)
				select @inserted_ap = isnull(@inserted_ap,0)

				if @deleted_ap <> @inserted_ap
					exec msp_calc_vendor_matrix @part, @vendor, @qty_break, null

				select	@qty_break = min(break_qty)
				from	inserted
				where	part = @part and
						vendor = @vendor and
						break_qty > @qty_break

			end

			select	@vendor = min(vendor)
			from	inserted
			where	part = @part and
					vendor > @vendor

		end

		select	@part = min(part)
		from	inserted
		where	part > @part

	end

end
go


print'
------------------------------------
-- TRIGGER:	mtr_shipper_detail_d
------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_shipper_detail_d' )
	drop trigger mtr_shipper_detail_d
go

create trigger mtr_shipper_detail_d on shipper_detail for delete
as
begin
	-- declarations
	declare	@shipper		integer,
		@part			varchar(35),
		@suffix			integer,
		@order_number		numeric(8,0),
		@linecount		integer,
		@part_original		varchar(25)

	-- get first updated/deleted row
	select	@shipper = min(shipper)
	from 	deleted
	
	-- loop through all updated records
	while ( isnull(@shipper,-1) <> -1 )
	begin

		-- Get the number line items on shipper.
		select	@linecount = count ( 1 )
		  from	shipper_detail
		 where	shipper = @shipper
		 
		-- If shipper is now empty, mark it as empty.
		if @linecount = 0
			update	shipper
			   set	status = 'E'
			 where	id = @shipper
	
		select	@part = min(part)
		from 	deleted
		where	shipper = @shipper

		while ( isnull(@part,'') <> '' )
		begin

			select	@suffix = suffix,
				@order_number = order_no,
				@part_original = part_original
			from	deleted
			where	shipper = @shipper and
				part = @part
				
			if isnull ( @order_number, 0 ) > 0
				exec msp_calculate_committed_qty @order_number, @part_original, @suffix
					
			select	@part = min(part)
			from 	deleted
			where	shipper = @shipper and
				part > @part

		end

		select	@shipper = min(shipper)
		from 	deleted
		where	shipper > @shipper

	end

end
go




print'
---------------------------------
-- TRIGGER:	mtr_shipper_detail_i
---------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mt_shipper_detail_i' )
	drop trigger mt_shipper_detail_i
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_shipper_detail_i' )
	drop trigger mtr_shipper_detail_i
go

if exists ( select 1 from dbo.sysobjects where name = 'mtr_shipper_detail_iu' )
	drop trigger mtr_shipper_detail_iu
go

create trigger mtr_shipper_detail_i on shipper_detail for insert
as
begin
	-- declarations
	declare	@shipper		integer,
		@part			varchar(35),
		@suffix			integer,
		@order_number		numeric(8,0),
		@part_original		varchar(25)

	-- get first updated/inserted row
	select	@shipper = min(shipper)
	from 	inserted

	-- loop through all updated records
	while ( isnull(@shipper,-1) <> -1 )
	begin

		select	@part = min(part)
		from 	inserted
		where	shipper = @shipper

		while ( isnull(@part,'') <> '' )
		begin

			exec msp_calc_invoice_currency @shipper, null, null, @part, null
	
			select	@part_original = part_original,
				@suffix = suffix,
				@order_number = order_no
			from	inserted
			where	shipper = @shipper and
				part = @part
				
			if isnull ( @order_number, 0 ) > 0
				exec msp_calculate_committed_qty @order_number, @part_original, @suffix
					
			select	@part = min(part)
			from 	inserted
			where	shipper = @shipper and
				part > @part

		end

		select	@shipper = min(shipper)
		from 	inserted
		where	shipper > @shipper

	end

end
go


print'
---------------------------------
-- TRIGGER:	mtr_shipper_detail_u
---------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_shipper_detail_u' )
	drop trigger mtr_shipper_detail_u
go

create trigger mtr_shipper_detail_u on shipper_detail for update
as
begin
	-- declarations
	declare	@shipper		integer,
		@part			varchar(35),
		@inserted_ap		numeric(20,6),
		@inserted_qty_required	numeric(20,6),
		@deleted_ap		numeric(20,6),
		@deleted_qty_required	numeric(20,6),
		@order_number		numeric(8,0),
		@suffix			integer,
		@shipper_status		varchar(1),
		@part_original		varchar(25)

	-- get first updated/inserted row
	select	@shipper = min(shipper)
	from 	inserted

	-- loop through all updated records
	while ( isnull(@shipper,-1) <> -1 )
	begin

		select	@part = min(part)
		from 	inserted
		where	shipper = @shipper

		while ( isnull(@part,'') <> '' )
		begin

			select	@deleted_ap = alternate_price,
				@deleted_qty_required = qty_required
			from	deleted
			where	shipper = @shipper and
				part = @part

			select @deleted_ap = isnull(@deleted_ap,-1)

			select	@inserted_ap = alternate_price,
				@inserted_qty_required = qty_required,
				@order_number = order_no,
				@suffix = suffix,
				@part_original = part_original
			from	inserted
			where	shipper = @shipper and
				part = @part

			select @inserted_ap = isnull(@inserted_ap,-1)

			if @deleted_ap <> @inserted_ap
				exec msp_calc_invoice_currency @shipper, null, null, @part, null
	
			select	@shipper_status = status
			from	shipper
			where	id = @shipper
			
			if isnull ( @order_number, 0 ) > 0
				if isnull ( @deleted_qty_required, 0 ) <> isnull ( @inserted_qty_required, 0 )
					exec msp_calculate_committed_qty @order_number, @part_original, @suffix
				
			select	@part = min(part)
			from 	inserted
			where	shipper = @shipper and
				part > @part

		end

		select	@shipper = min(shipper)
		from 	inserted
		where	shipper > @shipper

	end

end
go

-------------------------
-- TRIGGER:	mtr_shipper_i
-------------------------
if exists ( select 1 from sysobjects where name = 'mtr_shipper_i' )
	drop trigger mtr_shipper_i
go

create trigger mtr_shipper_i on shipper for insert
as
begin
-----------------------------------------------------------------------------------------------
--	Harish G.P	11/17/01	Included the code to sync shipper and invoice on manual
--					invoices.
--			09/06/02	Commented the shipper update st. to overcome the 
--					recurrisive trigger problem.
-----------------------------------------------------------------------------------------------
	-- declarations
	declare	@shipper	integer
	declare @type		char(1)

	-- get first updated row
	select	@shipper = min(id)
	from 	inserted

	-- loop through all updated records
	while ( isnull(@shipper,-1) <> -1 )
	begin

		if (	select	isnull(currency_unit,'')
			from	inserted
			where	id = @shipper ) > ''
		begin
			exec msp_calc_invoice_currency @shipper, null, null, null, null
/*
			update 	shipper set
				cs_status = destination.cs_status
			from	destination
			where	shipper.id = @shipper and
				destination.destination = shipper.destination
*/				
		end
/*		else
			update 	shipper set
				cs_status = destination.cs_status,
				currency_unit = isnull ( destination.default_currency_unit, (	select	default_currency_unit
												from	customer
												where	customer.customer = destination.customer  ) )
			from	destination
			where	shipper.id = @shipper and
				destination.destination = shipper.destination
*/		
		-- Get the type from the inserted view
		select	@type = isnull(type,'')
		from	inserted
		where	id = @shipper

		-- check if type is 'M', (ie manual invoice) then, sync shipper & invoice no.
		-- if need be add other types too here
		if @type ='M'
			execute msp_sync_shipper_invoice @shipper

		select	@shipper = min(id)
		from 	inserted
		where	id > @shipper

	end

end
go

----------------
-- mtr_shipper_u
----------------
if exists (
	select	1
	  from	sysobjects
	 where	id = object_id ( 'mtr_shipper_u' ) )
	drop trigger mtr_shipper_u
go

create trigger mtr_shipper_u
on shipper
for update
as
-----------------------------------------------------------------------------------------------
--	Modifications	08/08/02, HGP	Commented the date updation statement on the shipper as
--					that's being handled in the msp_shipout routine
--			09/06/02, HGP	Commented the shipper update st. to overcome the 
--					recurrsive trigger problem.
-----------------------------------------------------------------------------------------------
-- declarations
declare	@shipper		integer,
	@inserted_cu		varchar (3),
	@inserted_status	varchar (20),
	@deleted_cu		varchar (3),
	@deleted_status 	varchar (20),
	@type			varchar (7),
	@order_no		numeric(8,0),
	@inserted_invoice	integer,
	@deleted_invoice	integer

-- set shipper_detail.date_shipped and order_header last_shipped on ship out
if exists (
	select	inserted.status
	from	inserted
		join deleted on inserted.id = deleted.id
	where	inserted.status = 'C' and
		deleted.status <> 'C' )
begin
	update	order_header
	   set	shipper = inserted.id
	  from	inserted
	  	join shipper_detail on inserted.id = shipper_detail.shipper
	 where	shipper_detail.order_no = order_header.order_no
end

-- get first updated row
select	@shipper = min ( id )
  from 	inserted

-- loop through all updated records
while ( isnull ( @shipper, -1 ) <> -1 )
begin
	select	@deleted_cu = currency_unit,
		@deleted_status = status,
		@deleted_invoice = invoice_number
	  from	deleted
	 where	id = @shipper

	select	@inserted_cu = currency_unit,
		@inserted_status = status,
		@inserted_invoice = invoice_number,
		@type = isnull ( type, 'Q' )
	  from	inserted
	 where	id = @shipper

	select	@deleted_cu = isnull ( @deleted_cu, '' )
	select	@deleted_status = isnull ( @deleted_status, '' )
	select	@inserted_cu = isnull ( @inserted_cu, '' )
	select	@inserted_status = isnull ( @inserted_status, '' )

	if @deleted_cu <> @inserted_cu
		exec msp_calc_invoice_currency @shipper, null, null, null, null

	else if @inserted_status <> @deleted_status and @inserted_status = 'C'
	begin
/*	
		update	shipper
		set	date_shipped = GetDate ( )
		where	id = @shipper
*/

		update	shipper_detail
		set	total_cost = isnull (
			(	select	sum ( std_quantity * cost )
				from	audit_trail
				where	audit_trail.shipper = convert(varchar,@shipper) and
					part=shipper_detail.part_original and
					isnull ( audit_trail.suffix, 0 ) = isnull ( shipper_detail.suffix, 0 ) and
					audit_trail.type = 'S' ), total_cost )
		from	shipper_detail
		where	shipper_detail.shipper = @shipper

		select	@order_no = min(order_no)
		from	shipper_detail
		where	shipper = @shipper
		
		while ( isnull(@order_no,0) > 0 )
		begin
		
			exec msp_calculate_committed_qty @order_no, null, null
			
			select @order_no = isnull ( (
				select	min(order_no)
				from	shipper_detail
				where	shipper = @shipper and
					order_no > @order_no ), 0 )
		end
	end

/*
	update 	shipper
	set	cs_status = destination.cs_status
	from	destination
	where	shipper.id = @shipper and
		destination.destination = shipper.destination
*/		

--	Commented the below if statement as it has to call that proc for all types of shippers
	if isnull ( @inserted_invoice, 0 ) <> isnull ( @deleted_invoice, 0 ) -- and @type = 'Q'
		exec msp_sync_shipper_invoice @shipper
		
	select	@shipper = min(id)
	  from 	inserted
	 where	id > @shipper
end
go

print'
------------------------------------
-- TRIGGER:	mtr_activity_code_d
------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_activity_code_d' )
	drop trigger mtr_activity_code_d
go

create trigger mtr_activity_code_d on activity_codes
for delete
as
begin

	declare  @activity varchar (15), 
		 @count integer

	select @activity = code
	from  deleted

	select @count = count(1) 
	from activity_router
	where code = @activity

	if isnull ( @count, -1 ) <= 0 
	begin
		select @count = count(1)
		from part_machine
		where activity = @activity 

		if isnull ( @count, 0) > 0 
			RAISERROR 99999 'You cannot delete this activity as it is used elsewhere in the system! '

	end
	else
		RAISERROR 99999 'You cannot delete this activity as it is used elsewhere in the system! ' 
	
end
go



print'
---------------------------------
-- trigger:	mtr_activity_router_d
---------------------------------
'
if exists ( select * from dbo.sysobjects where id = object_id('mt_activity_router_d'))
	drop trigger mt_activity_router_d
go
if exists ( select * from dbo.sysobjects where id = object_id('mtr_activity_router_d'))
	drop trigger mtr_activity_router_d
go

create trigger
mtr_activity_router_d
on activity_router for delete
as
begin
	declare deleted_items cursor for select parent_part,sequence from deleted order by
		parent_part asc,sequence asc
	declare @parent_part varchar(25),
		@sequence numeric(5,0),
		@counter integer
	select @counter=0
	open deleted_items
	fetch deleted_items into @parent_part,@sequence
	while @@fetch_status=0
	begin
		update 	activity_router set
			sequence=sequence-1
		where 	parent_part=@parent_part
			and sequence>=@sequence

		fetch deleted_items into @parent_part,@sequence 
	end
	close deleted_items
	deallocate deleted_items
end

GO



print'
------------------------------
-- trigger:	mtr_issue_detail_i
------------------------------
'
if exists ( select 1 from dbo.sysobjects where id = object_id ( 'mtr_issue_detail_i' ) )
	drop trigger mtr_issue_detail_i
go

create trigger mtr_issue_detail_i on issue_detail for insert
as
begin
	declare	@date_stamp datetime,
			@status_type varchar(1),
			@status varchar(25),
			@issue_number integer,
			@today datetime,
			@notes_from varbinary(16),
			@notes_to varbinary(16)

	select	@today = GetDate()

	select 	@issue_number = min(issue_number)
	from 	inserted

	while(isnull(@issue_number,-1)<>-1)
	begin

		select	@date_stamp = min(date_stamp)
		from	inserted
		where	issue_number = @issue_number

		while(isnull(@date_stamp,@today)<>@today)
		begin

			select	@status = status_new
			from	inserted
			where	issue_number = @issue_number and
					date_stamp = @date_stamp

			select	@status_type = type
			from 	issues_status
			where 	status = @status

			if @status_type='C'
			begin

				select	@notes_from = TEXTPTR(notes) 
				from	issue_detail
				where	issue_number = @issue_number and
						date_stamp = @date_stamp
	
				READTEXT issue_detail.notes @notes_from 0 0
	
				update 	issues
				set		solution = ' '
				where	issue_number = @issue_number and
						solution is null

				select	@notes_to = TEXTPTR(solution)
				from	issues
				where	issue_number = @issue_number
	
				UPDATETEXT issues.solution @notes_to 0 NULL issue_detail.notes @notes_from

			end

			select	@date_stamp = min(date_stamp)
			from	inserted
			where	issue_number = @issue_number and
					date_stamp > @date_stamp

		end

		select 	@issue_number = min(issue_number)
		from 	inserted
		where	issue_number > @issue_number

	end

end
go


print '
----------------------------
-- TRIGGER:	mtr_object_i
----------------------------
'
if exists ( select * from dbo.sysobjects where id = object_id('mt_object_weight_i'))
	drop trigger mt_object_weight_i
go
if exists ( select * from dbo.sysobjects where id = object_id('mtr_object_weight_i'))
	drop trigger mtr_object_weight_i
go
if exists ( select * from dbo.sysobjects where id = object_id('mtr_object_i'))
	drop trigger mtr_object_i
go

CREATE TRIGGER mtr_object_i ON object
FOR INSERT
AS
BEGIN

	DECLARE	@update_shipper		int,
		@net_weight		numeric(20,6),
		@tare_weight		numeric(20,6),
		@type		varchar(1),
		@part		varchar(25),
		@package_type	varchar(25),
		@std_qty		numeric(20,6),
		@serial		int,
		@shipper		int,
		@weight		numeric(20,6),
		@count			int,
		@unit_weight		numeric(20,6),
		@calc_weight	numeric(20,6),
		@current_datetime	datetime,
		@eng_level		varchar(10),
		@dummy_date		datetime

/*	This trigger is only valid for single row inserts to object table	*/
/*	Get key values for the new object...	*/
	set rowcount 1
	SELECT	@current_datetime = GetDate ( ),
		@type = type,
		@part = part,
		@package_type = package_type,
		@std_qty = std_quantity,
		@serial = serial,
		@shipper = shipper, 
		@weight  = weight,
		@eng_level   = engineering_level
	FROM	inserted
	set rowcount 0

/*	Set the engineering revision level for the object based on 'Right Now'	*/
      IF Isnull(@eng_level, '') = ''
      BEGIN  
    	  SELECT	@eng_level = max(engineering_level)
	  FROM	effective_change_notice
	  WHERE	effective_date = (
			select Max ( a.effective_date )
			  from effective_change_notice a
			 where a.effective_date < @current_datetime AND
				 a.part = @part ) AND
		effective_change_notice.part = @part
	  UPDATE	object
	  SET		engineering_level = @eng_level
	  WHERE	serial = @serial
      END

/*	Set tare weight to zero, then adjust it to package weight if package type is valid	*/
	UPDATE	object
	   SET	tare_weight = 0
	 WHERE	serial = @serial

	UPDATE	object
	   SET	tare_weight = isnull(package_materials.weight,0)
	  FROM	package_materials
	 WHERE	serial = @serial AND
			code = @package_type

/*	If not a weighed item or a super object, calculate the object's net weight	*/
	IF IsNull ( @type, '' ) = '' -- is whether a pallet or normal object
	BEGIN
            -- next is whether weight is from scale or not
		IF IsNull ( (	SELECT	part_packaging.serial_type
				FROM	part_packaging
				WHERE	part = @part AND
							code = @package_type ), '(None)' ) = '(None)'
		BEGIN
			SELECT @unit_weight = IsNull ( unit_weight, 0 )
			FROM   part_inventory
			WHERE  part_inventory.part = @part
			select @calc_weight = @unit_weight * @std_qty
                  -- calculate weight only when weight column is null while inserting a new row 
			IF (@weight IS NULL)
				UPDATE 	object
				SET	 	object.weight = isnull(@calc_weight,0)
				WHERE  object.serial = @serial


		END

	END

	IF @shipper > 0
	begin
		execute msp_calc_shipper_weights @shipper

		update	object
		set	object.destination = shipper.destination
		from	shipper
		where	object.serial = @serial and
			shipper.id = object.shipper
	end

END
GO

------------------------------------
-- TRIGGER:	mtr_object_u (mssql)
------------------------------------
if exists ( select * from sysobjects where id = object_id('mtr_object_u'))
	drop trigger mtr_object_u
go
if exists ( select * from sysobjects where id = object_id('mt_object_weight_u'))
	drop trigger mt_object_weight_u
go
if exists ( select * from sysobjects where id = object_id('mtr_object_weight_u'))
	drop trigger mtr_object_weight_u
go

CREATE TRIGGER mtr_object_u ON object
FOR UPDATE
AS
BEGIN
-----------------------------------------------------------------------------------------------
--	Modifications	09/06/02, HGP	Commented out the object update st. to over come 
--					recurrsive trigger problem.
-----------------------------------------------------------------------------------------------

	DECLARE	@update_shipper		int,
		@net_weight		numeric(20,6),
		@tare_weight		numeric(20,6),
		@old_shipper		int,
		@type			varchar(1),
		@part			varchar(25),
		@package_type		varchar(25),
		@std_qty		numeric(20,6),
		@serial			int,
		@shipper		int,
		@weight			numeric(20,6),
		@calc_weight		numeric(20,6),
		@unit_weight		numeric(20,6)

	DECLARE	recs CURSOR FOR
		SELECT	type,
			part,
			package_type,
			std_quantity,
			serial,
			shipper,
			weight
		FROM	inserted

	OPEN recs

	FETCH recs INTO @type,
			@part,
			@package_type,
			@std_qty,
			@serial,
			@shipper,
                	@weight
	
	WHILE @@fetch_status = 0
	BEGIN

		SELECT	@old_shipper		= shipper
		FROM	deleted
		WHERE	serial = @serial
/*
		if Update ( shipper )
		begin
			if @shipper > 0
			begin
				update	object
				set	object.destination = shipper.destination
				from	shipper
				where	serial = @serial and
					object.shipper = shipper.id
			end
			else
				update	object
				set	destination = ''
				where	serial = @serial
		end
*/		
		IF @type IS NULL -- normal object or pallet 
		BEGIN
                  -- weight is from scale or not    
			IF IsNull ( (	SELECT	part_packaging.serial_type
					FROM	part_packaging
					WHERE	part = @part AND
						code = @package_type ), '(None)' ) = '(None)'
			BEGIN
                        -- calculate the weight only when the qty or std qty differs & deleted 
                        -- weight is same as the inserted wt. or when the inserted wt. is null 
				IF ( Update ( std_quantity ) or Update ( part ) ) and ( NOT Update ( weight ) or @weight IS NULL)
				BEGIN
					SELECT	@unit_weight = IsNull ( unit_weight, 0 )
					FROM	part_inventory
					WHERE	part_inventory.part = @part

					SELECT	@calc_weight = @unit_weight * @std_qty
/*
					UPDATE	object
					SET	object.weight = isnull(@calc_weight,0)
					WHERE	object.serial = @serial
*/					
				END

				SELECT @update_shipper = 1

			END

			ELSE

				SELECT @update_shipper = 1

			IF @shipper > 0 AND @update_shipper = 1

				IF @old_shipper > 0 AND Update ( shipper )
				BEGIN

					execute msp_calc_shipper_weights @shipper

					execute msp_calc_shipper_weights @old_shipper

				END
				ELSE

					execute msp_calc_shipper_weights @shipper

			ELSE IF @old_shipper > 0 AND @update_shipper = 1

				execute msp_calc_shipper_weights @old_shipper

		END
		ELSE

			IF Update ( package_type ) AND @shipper > 0
				execute msp_calc_shipper_weights @shipper

		FETCH recs INTO @type,
				@part,
				@package_type,
				@std_qty,
				@serial,
				@shipper,
				@weight

	END

	CLOSE recs

	DEALLOCATE recs

END
GO

print'
--------------------------
-- trigger:	mtr_customer_u
--------------------------
'
if exists (select 1 from sysobjects where name = 'mtr_customer_u' )
	drop trigger mtr_customer_u
GO

create trigger mtr_customer_u on customer for update
as
begin
	-- declarations
	declare @customer varchar(10),
			@cs_status varchar(20),
			@deleted_status varchar(20)

	-- get first updated row
	select	@customer = min(customer)
	from 	inserted

	-- loop through all updated records and if cs_status has been modified, update 
	-- destination with new status
	while(isnull(@customer,'-1')<>'-1')
	begin

		select	@cs_status = cs_status
		from	inserted
		where	customer = @customer

		select	@deleted_status = cs_status
		from	deleted
		where	customer = @customer

		select @cs_status = isnull(@cs_status,'')
		select @deleted_status = isnull(@deleted_status,'')

		if @cs_status <> @deleted_status
		begin
			update 	destination
			set	cs_status = @cs_status
			where 	customer = @customer

			update 	shipper
			set	cs_status = @cs_status
			where 	customer = @customer
		end 
		select	@customer = min(customer)
		from 	inserted
		where	customer > @customer

	end

end
GO

print'
-----------------------------
-- trigger:	mtr_destination_u
-----------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_destination_u' )
	drop trigger mtr_destination_u
GO

create trigger mtr_destination_u on destination for update
as
begin
	-- declarations
	declare @destination varchar(20),
			@cs_status varchar(20),
			@deleted_status varchar(20)

	-- get first updated row
	select	@destination = min(destination)
	from 	inserted

	-- loop through all updated records and if cs_status has been modified, update 
	-- orders with new status
	while(isnull(@destination,'-1') <> '-1')
	begin

		select	@cs_status = cs_status
		from	inserted
		where	destination = @destination

		select	@deleted_status = cs_status
		from	deleted
		where	destination = @destination

		select @cs_status = isnull(@cs_status,'')
		select @deleted_status = isnull(@deleted_status,'')

		if @cs_status <> @deleted_status
			update 	order_header
			set		cs_status = @cs_status
			where 	destination = @destination

		select	@destination = min(destination)
		from 	inserted
		where	destination > @destination

	end
end

GO

print'
---------------------------------
-- trigger:	mtr_ole_objects_i
---------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_ole_objects_i' )
	drop trigger mtr_ole_objects_i
go

create trigger mtr_ole_objects_i on ole_objects for insert
as
begin
	-- declare local variables
	declare @serial integer
	
	-- if trying to update more than 1 row exit
	if @@rowcount > 1
		raiserror 99999 'Multi-row insert on table ole_objects not allowed!'
		
	-- get inserted serial
	select	@serial = serial 
	from 	inserted
	
	if @serial = 0
	begin
		update 	ole_objects
		set	serial = isnull ( (	select	max(serial)
						from	ole_objects ), 0 ) + 1
		where	serial = 0
	end
end
go


print'
-----------------------------
-- TRIGGER:	mtr_contact_d
-----------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_contact_d' )
	drop trigger mtr_contact_d
go

create trigger mtr_contact_d on contact for delete
as
begin
	declare	@contact varchar(35)
	declare deleted_contacts cursor for
		select	name
		from	deleted
		
	open deleted_contacts
	fetch deleted_contacts into @contact
	while ( @@fetch_status = 0 )
	begin
		delete from contact_call_log where contact = @contact
		fetch deleted_contacts into @contact
	end
	close deleted_contacts
	deallocate deleted_contacts
end
go


print'
-----------------------------
-- TRIGGER:	mtr_contact_u
-----------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_contact_u' )
	drop trigger mtr_contact_u
go

create trigger mtr_contact_u on contact for update
as
begin
	declare	@inserted_contact varchar(35),
		@deleted_contact varchar(35)
		
	declare inserted_contacts cursor for
		select	name
		from	inserted
	declare deleted_contacts cursor for
		select	name
		from	deleted
		
	open inserted_contacts
	open deleted_contacts
	fetch inserted_contacts into @inserted_contact
	fetch deleted_contacts into @deleted_contact
	while ( @@fetch_status = 0 )
	begin
		if @inserted_contact <> @deleted_contact
			update 	contact_call_log
			set	contact = @inserted_contact
			where	contact = @deleted_contact
			
		fetch inserted_contacts into @inserted_contact
		fetch deleted_contacts into @deleted_contact
	end
	close inserted_contacts
	deallocate inserted_contacts
	close deleted_contacts
	deallocate deleted_contacts
end
go

print '
-------------------------------------------------------
--  trigger on employee table on insert
-------------------------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('mtr_employee_i') )
	drop trigger mtr_employee_i
go

create trigger mtr_employee_i on  employee 
for insert
as
begin
	declare @operator_code varchar (8),
		@password      varchar (8)

	if exists ( select 1 from parameters where requisition = 'Y' )
	begin
		select	@operator_code = operator_code,
			@password      = password
		from	inserted
	
		if @@rowcount = 1 
			insert into requisition_security (
			operator_code,
			password,
			security_level,
			dollar,
			approver,
			approver_password,
			backup_approver,
			backup_approver_password,
			backup_approver_end_date,
			dollar_week_limit,
	        	account_group_code,
			project_group_code,
			self_dollar_limit,
			name )
			select 	operator_code, 
				password,
				null,
				0,
				null,
				null,
				null,
				null,
				null,
				0,
				null,
				null,
				0,
				name
			from inserted
	end
end
go

print '
-------------------------------------------------------
--  trigger on employee table on update 
-------------------------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('mtr_employee_u') )
	drop trigger mtr_employee_u
go

create trigger mtr_employee_u on  employee 
for update
as
begin
	declare @operator_old varchar (8),
		@password_old varchar (8),
		@operator_new varchar (8),
		@password_new varchar (8)

	select	@operator_old = operator_code,
		@password_old = password
	from	deleted

	select	@operator_new = operator_code,
		@password_new = password
	from	inserted

	if @operator_old <> @operator_new
		update requisition_security
		set    operator_code = @operator_new
		where  operator_code = @operator_old 
		and    password = @password_old
        else if @password_old <> @operator_new
		update requisition_security
		set    password = @password_new
		where  operator_code = @operator_old 
		and    password = @password_old

end
go

print '
-------------------------------------------------------
--  trigger on employee table for delete
-------------------------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('mtr_employee_d') )
	drop trigger mtr_employee_d
go

create trigger mtr_employee_d on  employee 
for delete
as
begin
	declare @operator_code varchar (8),
		@password      varchar (8)

	select	@operator_code = operator_code,
		@password      = password
	from	deleted

	if @@rowcount = 1 
		delete from requisition_security 
		where  operator_code = @operator_code
		and    password = @password 
	
end
go

execute msp_super_cop 'Y',null,null
go

print '
-------------------------------------------------------
--  Procedure required for one of the standard forms
-------------------------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_form_release'))
        drop procedure msp_form_release
go

CREATE PROCEDURE msp_form_release(@po_number varchar(15))
as
BEGIN
SELECT
        vendor.contact,
        po_header.po_number ,
        po_header.release_no,
        vendor.buyer,
        po_detail.part_number ,
        po_detail.description ,
        po_detail.balance ,
        po_detail.date_due ,
        destination.name,
        destination.destination ,
        destination.address_1 ,
        destination.address_2 ,
        destination.address_3 ,
        destination.address_4,
        destination.address_5,  
        parameters.company_name ,
        parameters.address_1 ,
        parameters.address_2 ,
        parameters.address_3 ,
        po_header.vendor_code ,
        vendor.name ,
        po_header.ship_to_destination ,
        vendor.contact ,
        po_detail.unit_of_measure ,
        vendor.address_1 ,
        vendor.address_2 ,
        vendor.address_3 ,
        vendor.address_4,
        vendor.address_5,  
        po_detail.notes ,
        po_header.notes     

FROM 
        po_detail ,
        po_header ,
        destination ,
        parameters ,
        vendor 
        
WHERE ( po_header.po_number = po_detail.po_number ) and
        ( vendor.code = po_header.vendor_code ) and
        ( po_header.ship_to_destination *= destination.destination ) and
        ( ( convert(varchar (15),po_header.po_number) = @po_number ) )   

END
go


print '
--------------------------------------------------------
--	Procedure required for one of the standard forms
--------------------------------------------------------
'
if exists (select * from dbo.sysobjects where id = object_id('msp_form_ecl'))
        drop procedure msp_form_ecl
go

CREATE PROCEDURE msp_form_ecl(@part varchar(50),@date datetime)
as
BEGIN

SELECT  max(Convert(varchar(30),effective_date,102) +'  '+ '/' +'   ' + engineering_level)      
FROM
        effective_change_notice
WHERE
        (part = @part) and
        (@date >= effective_date)

END
go

print '
------------------------------
--	Procedure msp_copypart
------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'msp_copypart' and type='P')
	drop procedure msp_copypart
go
create procedure msp_copypart (
@oldpart varchar(25), 
@newpart varchar(25), 
@returnvalue integer OUTPUT)
as
---------------------------------------------------------------------------------------------
--	Procedure	msp_copypart

--	Purpose		to copy an existing part to a new part

--	Arguments	Old part and new part

--	Returns		0 -	Success
--			-1 -	Invalid arguments
--			-2 - 	Duplicate part

--	Process		Check arguments for validity
--			Check whether the new part already exists
--			Insert row into part table
--				Part table insert trigger inserts row into part_standard
--			Insert row into part_inventory table
--			Insert row into part_online table
--			Insert row into part_purchasing table
--			Insert row(s) into part_packaging table

--	Development	Developer	Date	Details
--			GPH		4/14/01	Created the procedure
---------------------------------------------------------------------------------------------
--	Check the arguments, if null return unsuccessful state
if isnull(@oldpart,'') = '' or isnull(@newpart,'')=''
	select	-1	-- return invalid
else if (select isnull(count(1),0) from part where part = @newpart) > 0 
--	Check whether the part already exists, if so return unsuccessful
	select	-2	-- return duplicate
else
begin
--	Insert a row in part table
	insert	into part (
		part,
		name,
		cross_ref,
		class,
		type,
		commodity,
		group_technology,
		quality_alert,
		description_short,
		description_long,
		serial_type,
		product_line,
		configuration,
		standard_cost,
		user_defined_1,
		user_defined_2,
		flag,
		engineering_level,
		drawing_number,
		gl_account_code,
		eng_effective_date,
		low_level_code )
	select	@newpart,
		name,
		cross_ref,
		class,
		type,
		commodity,
		group_technology,
		quality_alert,
		description_short,
		description_long,
		serial_type,
		product_line,
		configuration,
		standard_cost,
		user_defined_1,
		user_defined_2,
		flag,
		engineering_level,
		drawing_number,
		gl_account_code,
		eng_effective_date,
		low_level_code
	from	part
	where	part = @oldpart

--	Part_standard gets inserted through the insert trigger on part table

--	Insert into part_inventory
	insert	into part_inventory (
		part,
		standard_pack,
		unit_weight,
		standard_unit,
		cycle,
		abc,
		saftey_stock_qty,
		primary_location,
		location_group,
		ipa,
		label_format,
		shelf_life_days,
		material_issue_type,
		safety_part,
		upc_code,
		dim_code,
		configurable,
		next_suffix,
		drop_ship_part)
	select	@newpart,
		standard_pack,
		unit_weight,
		standard_unit,
		cycle,
		abc,
		saftey_stock_qty,
		primary_location,
		location_group,
		ipa,
		label_format,
		shelf_life_days,
		material_issue_type,
		safety_part,
		upc_code,
		dim_code,
		configurable,
		next_suffix,
		drop_ship_part		
	from	part_inventory
	where	part = @oldpart

--	insert into part_online
	insert	into part_online (
		part,
		on_hand,
		on_demand,
		on_schedule,
		bom_net_out,
		min_onhand,
		max_onhand,
		default_vendor,
		default_po_number,
		kanban_po_requisition,
		kanban_required)
	select	@newpart,
		0,
		0,
		0,
		0,
		min_onhand,
		max_onhand,
		default_vendor,
		default_po_number,
		kanban_po_requisition,
		kanban_required			
	from	part_online
	where	part = @oldpart

--	insert into part_purchasing
	insert	into part_purchasing (
		part,
		buyer,
		min_order_qty,
		reorder_trigger_qty,
		min_on_hand_qty,
		primary_vendor,
		gl_account_code)
	select	@newpart,
		buyer,
		min_order_qty,
		reorder_trigger_qty,
		min_on_hand_qty,
		primary_vendor,
		gl_account_code
	from	part_purchasing
	where	part = @oldpart
		
--	insert into part_packaging
	insert	into part_packaging (
		part,
		code,
		quantity,
		manual_tare,
		label_format,
		round_to_whole_number,
		package_is_object,
		inactivity_time,
		threshold_upper,
		threshold_lower,
		unit,
		stage_using_weight,
		inactivity_amount,
		threshold_upper_type,
		threshold_lower_type,
		serial_type )
	select	@newpart,
		code,
		quantity,
		manual_tare,
		label_format,
		round_to_whole_number,
		package_is_object,
		inactivity_time,
		threshold_upper,
		threshold_lower,
		unit,
		stage_using_weight,
		inactivity_amount,
		threshold_upper_type,
		threshold_lower_type,
		serial_type
	from	part_packaging
	where	part = @oldpart

	select	0 -- return successful
end 	
go

print '
----------------------------
--	Parameters changes
---------------------------- 
'
if exists (select * from sysobjects where id = object_id('dbo.mtr_parameters_u') )
	drop trigger dbo.mtr_parameters_u
GO

if exists (select * from sysobjects where id = object_id('dbo.parameters') )
begin
	alter table parameters drop constraint PK__parameters__5E9FE363
	execute sp_rename parameters, parameters_temp
end
GO

CREATE TABLE dbo.parameters (
	company_name varchar (50) NOT NULL ,
	next_serial int NOT NULL ,
	default_rows int NULL ,
	next_issue int NULL ,
	sales_order int NULL ,
	shipper int NULL ,
	company_logo varchar (30) NULL ,
	show_program_name char (1) NULL ,
	purchase_order numeric(10, 0) NULL ,
	address_1 varchar (30) NULL ,
	address_2 varchar (30) NULL ,
	address_3 varchar (30) NULL ,
	admin_password varchar (5) NULL ,
	time_interval int NULL ,
	next_invoice int NULL ,
	next_requisition int NULL ,
	delete_scrapped_objects char (1) NULL ,
	ipa char (1) NULL ,
	ipa_beginning_sequence int NULL ,
	audit_trail_delete char (1) NULL ,
	invoice_add char (1) NULL ,
	plant_required char (1) NULL ,
	edit_po_number char (1) NULL ,
	over_receive char (1) NULL ,
	phone_number varchar (15) NULL ,
	shipping_label varchar (30) NULL ,
	bol_number int NULL ,
	verify_packaging char (1) NULL ,
	fiscal_year_begin datetime NULL ,
	sales_tax_account varchar (50) NULL ,
	freight_account varchar (50) NULL ,
	populate_parts char (1) NULL ,
	populate_locations char (1) NULL ,
	populate_machines char (1) NULL ,
	mandatory_lot_inventory char (1) NULL ,
	edi_process_days int NULL ,
	set_asn_uop char (1) NULL ,
	shop_floor_check_u1 char (1) NULL ,
	shop_floor_check_u2 char (1) NULL ,
	shop_floor_check_u3 char (1) NULL ,
	shop_floor_check_u4 char (1) NULL ,
	shop_floor_check_u5 char (1) NULL ,
	shop_floor_check_lot char (1) NULL ,
	lot_control_message varchar (255) NULL ,
	mandatory_qc_notes char (1) NULL ,
	asn_directory varchar (25) NULL ,
	next_db_change int NULL ,
	fix_number int NULL ,
	auto_stage_for_packline char (1) NULL ,
	ask_for_minicop char (1) NULL ,
	issue_file_location varchar (250) NULL ,
	accounting_interface_db varchar (25) NULL ,
	accounting_interface_type varchar (25) NULL ,
	accounting_interface_login varchar (10) NULL ,
	accounting_interface_pwd varchar (10) NULL ,
	accounting_pbl_name varchar (50) NULL ,
	accounting_cust_sync_dp varchar (50) NULL ,
	accounting_vend_sync_db varchar (50) NULL ,
	accounting_ap_dp_header varchar (50) NULL ,
	accounting_ar_dp varchar (50) NULL ,
	accounting_ap_dp_detail varchar (50) NULL ,
	inv_reg_col varchar (25) NULL ,
	scale_part_choice char (1) NULL ,
	accounting_profile varchar (50) NULL ,
	accounting_type varchar (25) NULL ,
	next_voucher int NULL ,
	days_to_process int NULL ,
	include_setuptime char (1) NULL ,
	sunday char (1) NULL ,
	monday char (1) NULL ,
	tuesday char (1) NULL ,
	wednesday char (1) NULL ,
	thursday char (1) NULL ,
	friday char (1) NULL ,
	saturday char (1) NULL ,
	workhours_in_day int NULL ,
	order_type char (1) NULL ,
	pallet_package_type char (1) NULL ,
	clear_after_trans_jc char (1) NULL ,
	dda_required char (1) NULL ,
	dda_formula_type char (1) NULL ,
	shipper_required varchar (1) NULL ,
	calc_mtl_cost varchar (1) NULL ,
	issues_environment_message varchar (255) NULL ,
	base_currency varchar (3) NULL ,
	currency_display_symbol varchar (10) NULL ,
	euro_enabled smallint NULL ,
	requisition char (1) NULL ,
	onhand_from_partonline char (1) NULL ,
	consolidate_mps char (1) NULL ,
	daily_horizon int NULL ,
	weekly_horizon int NULL ,
	fortnightly_horizon int NULL ,
	monthly_horizon int NULL ,
	next_workorder int NULL ,
	audit_deletion char(1) NULL,
	CONSTRAINT PK__parameters__5E9FE363 PRIMARY KEY  CLUSTERED 
	(
		company_name
	)
)
GO

create trigger mtr_parameters_u
on parameters
for update
as

declare	@shipper	integer,
	@invoice	integer
	
if update ( shipper ) or update ( next_invoice )
begin
	select	@shipper = shipper,
		@invoice = next_invoice
	from	inserted
	
	if isnull ( @shipper, 0 ) <> isnull ( @invoice, 0 )
		exec msp_sync_parm_shipper_invoice
end
GO

insert into parameters (
	company_name, next_serial, default_rows, next_issue, sales_order, shipper,
	company_logo, show_program_name, purchase_order, address_1, address_2, address_3,
	admin_password,	time_interval, next_invoice, next_requisition, delete_scrapped_objects,
	ipa, ipa_beginning_sequence, audit_trail_delete, invoice_add, plant_required,
	edit_po_number, over_receive, phone_number, shipping_label, bol_number, verify_packaging,
	fiscal_year_begin, sales_tax_account, freight_account, populate_parts,populate_locations,
	populate_machines, mandatory_lot_inventory, edi_process_days, set_asn_uop,
	shop_floor_check_u1, shop_floor_check_u2, shop_floor_check_u3, shop_floor_check_u4,
	shop_floor_check_u5, shop_floor_check_lot, lot_control_message,	mandatory_qc_notes,
	asn_directory, next_db_change, fix_number, auto_stage_for_packline, ask_for_minicop,
	issue_file_location, accounting_interface_db, accounting_interface_type,
	accounting_interface_login, accounting_interface_pwd, accounting_pbl_name,
	accounting_cust_sync_dp, accounting_vend_sync_db, accounting_ap_dp_header,
	accounting_ar_dp, accounting_ap_dp_detail, inv_reg_col,	scale_part_choice,
	accounting_profile, accounting_type, next_voucher, days_to_process, include_setuptime,
	sunday, monday,	tuesday, wednesday, thursday, friday, saturday, workhours_in_day,
	order_type, pallet_package_type, clear_after_trans_jc,dda_required, dda_formula_type,
	shipper_required, calc_mtl_cost, issues_environment_message, base_currency,currency_display_symbol,
	euro_enabled, requisition, onhand_from_partonline, consolidate_mps, daily_horizon,
	weekly_horizon, fortnightly_horizon, monthly_horizon, next_workorder )
select 	company_name, next_serial, default_rows, next_issue, sales_order, shipper,
	company_logo, show_program_name, purchase_order, address_1, address_2, address_3,
	admin_password,	time_interval, next_invoice, next_requisition, delete_scrapped_objects,
	ipa, ipa_beginning_sequence, audit_trail_delete, invoice_add, plant_required,
	edit_po_number, over_receive, phone_number, shipping_label, bol_number, verify_packaging,
	fiscal_year_begin, sales_tax_account, freight_account, populate_parts,populate_locations,
	populate_machines, mandatory_lot_inventory, edi_process_days, set_asn_uop,
	shop_floor_check_u1, shop_floor_check_u2, shop_floor_check_u3, shop_floor_check_u4,
	shop_floor_check_u5, shop_floor_check_lot, lot_control_message,	mandatory_qc_notes,
	asn_directory, next_db_change, fix_number, auto_stage_for_packline, ask_for_minicop,
	issue_file_location, accounting_interface_db, accounting_interface_type,
	accounting_interface_login, accounting_interface_pwd, accounting_pbl_name,
	accounting_cust_sync_dp, accounting_vend_sync_db, accounting_ap_dp_header,
	accounting_ar_dp, accounting_ap_dp_detail, inv_reg_col,	scale_part_choice,
	accounting_profile, accounting_type, next_voucher, days_to_process, include_setuptime,
	sunday, monday,	tuesday, wednesday, thursday, friday, saturday, workhours_in_day,
	order_type, pallet_package_type, clear_after_trans_jc,dda_required, dda_formula_type,
	shipper_required, calc_mtl_cost, issues_environment_message, base_currency,currency_display_symbol,
	euro_enabled, requisition, onhand_from_partonline, consolidate_mps, daily_horizon,
	weekly_horizon, fortnightly_horizon, monthly_horizon, next_workorder
from	parameters_temp
go

update parameters set audit_deletion = 'N'
go

if exists (select * from sysobjects where id = object_id('dbo.parameters_temp') )
	drop table parameters_temp
go

print'
-----------------------------
-- update version in database
-----------------------------
'
execute sp_rename admin, admin_temp
go

if not exists ( select 1 from dbo.sysobjects where name = 'admin' )
begin
	create table admin
	(
		version	varchar(50) not null,
		db_invoice_sync char(1) null
	)

	insert into admin ( version, db_invoice_sync )
	select version, db_invoice_sync from admin_temp
	
	drop table admin_temp
end
else if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'admin' and sc.id = so.id and sc.name = 'db_invoice_sync' )
begin
	alter table admin add db_invoice_sync char(1) null
	update admin set db_invoice_sync = 'N'
end
go

print'
--------------------------------------------------
--	mtr_vendor_u trigger
--------------------------------------------------
'
if exists ( select 1 from dbo.sysobjects where name = 'mtr_vendor_u') 
	drop trigger mtr_vendor_u
go

create trigger mtr_vendor_u on vendor for update
as
begin
	--	declarations
	declare	@vendor varchar(10),
		@vs_status varchar(20),
		@deleted_status varchar(20)
	--	get first updated row

	select	@vendor=min(code)
	from	inserted

	--	loop through all updated records and if vs_status has been modified, 
	--	update destination with new status
	
	while	(isnull(@vendor,'-1')<>'-1')
	begin
		select	@vs_status=status
		from	inserted
		where	code=@vendor
		select	@deleted_status=status
		from	deleted
		where	code=@vendor
		select	@vs_status=isnull(@vs_status,'')
		select	@deleted_status=isnull(@deleted_status,'')
		if @vs_status<>@deleted_status
			update	destination 
			set	cs_status=@vs_status
			where	vendor=@vendor
		select @vendor=min(code)
		from	inserted
		where	code>@vendor
	end
end
go

print '
---------------------------------
--	destination table changes
---------------------------------
'
if not exists ( select	1 
		from	dbo.sysobjects 
			join dbo.syscolumns on dbo.syscolumns.id =  dbo.sysobjects.id
		where	dbo.sysobjects.name = 'destination' and 
			dbo.syscolumns.name = 'custom1')
	alter table destination add 
		custom1 varchar(10) null,
	 	custom2 varchar(10) null,
	 	custom3 varchar(10) null,
	 	custom4 varchar(10) null,
	 	custom5 varchar(10) null,
	 	custom6 varchar(10) null,
	 	custom7 varchar(10) null,
	 	custom8 varchar(10) null,
	 	custom9 varchar(10) null,
	 	custom10 varchar(10) null
go

print '
------------------------------------------
-- VIEW:	cs_ship_history_summary_vw
------------------------------------------
'
if exists 
( 
	select	1 
	from 	sysobjects 
	where 	id = object_id('cs_ship_history_summary_vw') 
)
	drop view cs_ship_history_summary_vw
go
    
create view cs_ship_history_summary_vw 
as 
select	shipper.id,   
	shipper.destination,   
	shipper.date_stamp,   
	shipper.ship_via,   
	shipper.bill_of_lading_number,   
	shipper.staged_objs,   
	shipper.plant,   
	shipper.printed,   
	shipper.customer,   
	shipper.gross_weight,   
	shipper.pro_number,   
	shipper.status,   
	shipper.notes,   
	shipper.type,   
	destination.name,   
	shipper.net_weight,   
	shipper.picklist_printed,   
	shipper.invoice_number,   
	shipper.scheduled_ship_time,   
	shipper.cs_status,   
	shipper.staged_pallets,
	isnull(customer.name,vendor.name) vname,
	isnull(bill_of_lading.printed,'N') bol_printed
from	shipper
	left outer join bill_of_lading on bill_of_lading.bol_number = shipper.bill_of_lading_number,   
	destination
	join customer on customer.customer = destination.customer
	left outer join vendor on vendor.code = destination.vendor,   
	customer_service_status
where	( shipper.destination = destination.destination ) and  
	( shipper.cs_status = customer_service_status.status_name ) and  
	( shipper.status = 'C' OR shipper.status = 'Z' ) and 
	customer_service_status.status_type <> 'C' and
	( shipper.type = 'V' or shipper.type = 'O' or shipper.type = 'Q'  or shipper.type is null ) 
go

print '
------------------------------------------
-- VIEW:	cs_ship_history_detail_vw
------------------------------------------
'
if exists 
( 
	select	1 
	from 	sysobjects 
	where 	id = object_id('cs_ship_history_detail_vw') 
)
	drop view cs_ship_history_detail_vw
go
    
create view cs_ship_history_detail_vw 
as 
select	shipper.id,   
	shipper.destination,   
	shipper.date_stamp,   
	shipper.ship_via,   
	shipper.bill_of_lading_number,   
	shipper.staged_objs,   
	shipper.plant,   
	shipper.printed,   
	shipper.customer,   
	shipper.gross_weight,   
	shipper.pro_number,   
	shipper.status,   
	shipper.notes,   
	shipper.type,   
	destination.name,   
	shipper.net_weight,   
	shipper.picklist_printed,   
	shipper.invoice_number,   
	shipper.scheduled_ship_time,   
	shipper.cs_status,   
	shipper_detail.part_original,   
	shipper_detail.customer_part,   
	shipper_detail.customer_po,   
	shipper.staged_pallets,   
	shipper_detail.boxes_staged,   
	shipper_detail.order_no,
	isnull(bill_of_lading.printed,'N') bol_printed
from	shipper
	left outer join bill_of_lading on shipper.bill_of_lading_number = bill_of_lading.bol_number,   
	destination,
	customer,   
	customer_service_status,   
	shipper_detail  
where	( shipper.destination = destination.destination ) and  
	( shipper.customer = customer.customer ) and  
	( shipper.cs_status = customer_service_status.status_name ) and  
	( shipper_detail.shipper = shipper.id ) and  
	( shipper.status = 'C' OR shipper.status = 'Z'  ) AND  
	customer_service_status.status_type <> 'C'and
	( shipper.type = 'V' or shipper.type = 'O' or shipper.type = 'Q'  or shipper.type is null ) 
go

print '
------------------------------
--	Input custom menu data
------------------------------
'
if not exists ( select 1 from custom_pbl_link where Menu_text = 'ReportListing' and module = 'monitor.main1')
	insert into custom_pbl_link values ( 'Report&Listing','ReportListing','monitor.main1','Standard Reports and Listings',null,'C','reports_listings.exe',null,null)
go


-----------------------------------
-- VIEW:	cs_ship_schedule_vw
-----------------------------------
if exists 
( 
	select	1 
	from 	sysobjects 
	where 	id = object_id('cs_ship_schedule_vw') 
)
	drop view cs_ship_schedule_vw
go
    
create view cs_ship_schedule_vw 
as 
SELECT 	shipper.id,   
	shipper.destination,   
	shipper.date_stamp,   
	shipper.ship_via,   
	shipper.bill_of_lading_number,   
	shipper.staged_objs,   
	shipper.plant,   
	shipper.printed,   
	shipper.customer,   
	shipper.gross_weight,   
	shipper.pro_number,   
	shipper.status,   
	shipper.notes,   
	shipper.type,   
	shipper.net_weight,   
	shipper.picklist_printed,   
	shipper.invoice_number,   
	shipper.scheduled_ship_time,   
	shipper.cs_status,   
	shipper_detail.part_original,   
	shipper_detail.customer_part,   
	shipper_detail.customer_po,   
	shipper.staged_pallets,   
	shipper_detail.boxes_staged,   
	shipper_detail.order_no,
	shipper.truck_number,
	destination.name,
	customer.name cname
FROM 	shipper,   
	destination
	join customer on customer.customer = destination.customer,   
	customer_service_status,   
	shipper_detail  
WHERE 	shipper.destination = destination.destination and  
	shipper.cs_status = customer_service_status.status_name and  
	shipper_detail.shipper = shipper.id and  
	( shipper.status = 'O' OR  
	shipper.status = 'S' ) AND  
	isnull(shipper.type,'') <> 'R' and
	customer_service_status.status_type <> 'C'
go

-----------------------
-- Table:	filters
-----------------------
if exists ( select 1 from sysobjects where name = 'filters')
	drop table filters
go	
create table filters (
	filtername	varchar(10) not null,
	sequence	integer not null,
	module		varchar(30) not null,
	filterdate	datetime not null,
	leftparenthesis	varchar(10) null,
	column_name	varchar(255) not null,
	roperator	varchar(15) not null,
	value		varchar(255) not null,
	loperator	varchar(10) null,
	operator	varchar(5) null,
	rightparenthesis varchar(10) null,
	constraint PK_filters primary key (filtername, sequence))
go

if exists ( select 1 from sysobjects where name = 'cdisp_po_comparision')
	drop procedure cdisp_po_comparision
go

create procedure cdisp_po_comparision (@mode char(1)=null, @start_dt datetime=null ) as
begin
	declare	@part varchar(25)
	create table #mps ( part varchar(25) )
	create table #pparts ( cpart varchar(25), ppart varchar(25), bomqty numeric(20,6)) 
	create table #ponhand ( cpart varchar(25), ppart varchar(25), onhand numeric(20,6)) 		
	create table #mpsdmd (	part varchar(25),
				demandpast numeric(20,6),
				demand1 numeric(20,6),
				demand2 numeric(20,6),
				demand3 numeric(20,6),
				demand4 numeric(20,6),
				demand5 numeric(20,6),
				demand6 numeric(20,6),
				demand7 numeric(20,6),
				demand8 numeric(20,6),
				demand9 numeric(20,6),
				demand10 numeric(20,6),
				demand11 numeric(20,6),
				demand12 numeric(20,6),
				demandfuture numeric(20,6))
	create table #mpsasgn (	part varchar(25),
				asgnpast numeric(20,6),
				asgn1 numeric(20,6),
				asgn2 numeric(20,6),
				asgn3 numeric(20,6),
				asgn4 numeric(20,6),
				asgn5 numeric(20,6),
				asgn6 numeric(20,6),
				asgn7 numeric(20,6),
				asgn8 numeric(20,6),
				asgn9 numeric(20,6),
				asgn10 numeric(20,6),
				asgn11 numeric(20,6),
				asgn12 numeric(20,6),
				asgnfuture numeric(20,6))
	
	--	1.	Declare local variables.
	declare @current_level int
	declare @count int
	declare	@childpart varchar (25)
	declare @bomqty numeric(20,6)
	declare	@cbomqty numeric(20,6)
	
	--	2.	Create temporary table for exploding components.
	create table #stack 
	(
		part	varchar (25),
		stack_level	int,
		bomqty	numeric (20,6)		
	) 
	
	--	3,	Declare trigger for looping through parts at current low level.
	declare	childparts cursor for
	select	part, bomqty
	from	#stack
	where	stack_level = @current_level
	
	insert	into #mps
	select	distinct part 
	from	master_prod_sched
	where	type = 'P'
	order by part
	
	declare purparts cursor for 
	select	a.part
	from	#mps a
	order by 1
	
	open	purparts
	fetch	purparts into @part
	while ( @@fetch_status = 0 )
	begin
			--	4.	Initialize stack with part or list of top parts.
		select @current_level = 1
		insert into #stack
		values ( @part, @current_level, 1)
		
		--	5.	If rows found, loop through current level, adding children.
		if @@rowcount > 0 
			select @count = 1
		else
			select @count = 0
		
		while @count > 0
		begin
		
		--	6.	Add components for each part at current level using cursor.
			select @count = 0
		
			open childparts
		
			fetch	childparts
			into	@childpart, @cbomqty
		
			while @@fetch_status = 0
			begin
		
		--	7.	Store level and total usage at this level for components.
				insert	#stack
				select	bom.parent_part,
					@current_level + 1,
					bom.quantity * @cbomqty
				from	bill_of_material as bom
				where	bom.part = @childpart
		
				select	@count = 1
		
				fetch	childparts
				into	@childpart, @cbomqty
			end
		
			close	childparts
		
		--	8.	Continue incrementing level as long as new components are added.
			if @count = 1
				select @current_level = @current_level + 1
		end
		
		--	9.	Deallocate components cursor.
		--deallocate childparts
	
		insert into #pparts 
		select @part, part, bomqty from #stack group by part, bomqty
	
		delete #stack
		fetch	purparts into @part
	end
	close purparts
	deallocate purparts
	deallocate childparts	
	
	insert into #ponhand	
	select	p.cpart,
		p.ppart,
		isnull(sum(o.quantity * p.bomqty),0)		
	from	#pparts p
		join object o on o.part = p.ppart
	group by p.cpart, p.ppart
	order by 1,2
	
	if @mode is null 
		select @mode = 'W'
	if @start_dt is null
		select @start_dt = getdate()

	if @mode = 'M'
	begin
		insert	into #mpsdmd
		select	#mps.part,
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due < @start_dt and 
				mps.part = #mps.part) demandpast,
				
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= @start_dt and mps.due < dateadd ( month, 1, @start_dt ) and
				mps.part = #mps.part) demand1,
	
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( month, 1, @start_dt ) and 
				mps.due < dateadd ( month, 2, @start_dt ) and
				mps.part = #mps.part) demand2,
	
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( month, 2, @start_dt ) and 
				mps.due < dateadd ( month, 3, @start_dt ) and
				mps.part = #mps.part) demand3,
	
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( month, 3, @start_dt ) and 
				mps.due < dateadd ( month, 4, @start_dt ) and
				mps.part = #mps.part) demand4,
	
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( month, 4, @start_dt ) and 
				mps.due < dateadd ( month, 5, @start_dt ) and
				mps.part = #mps.part) demand5,
	
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( month, 5, @start_dt ) and 
				mps.due < dateadd ( month, 6, @start_dt ) and
				mps.part = #mps.part) demand6,
				
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( month, 6, @start_dt ) and 
				mps.due < dateadd ( month, 7, @start_dt ) and
				mps.part = #mps.part) demand7,
				
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( month, 7, @start_dt ) and 
				mps.due < dateadd ( month, 8, @start_dt ) and
				mps.part = #mps.part) demand8,
				
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( month, 8, @start_dt ) and 
				mps.due < dateadd ( month, 9, @start_dt ) and
				mps.part = #mps.part) demand9,
	
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( month, 9, @start_dt ) and 
				mps.due < dateadd ( month, 10, @start_dt ) and
				mps.part = #mps.part) demand10,
	
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( month, 10, @start_dt ) and 
				mps.due < dateadd ( month, 11, @start_dt ) and
				mps.part = #mps.part) demand11,
	
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( month, 11, @start_dt ) and 
				mps.due < dateadd ( month, 12, @start_dt ) and
				mps.part = #mps.part) demand12,
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( month, 12, @start_dt ) and
				mps.part = #mps.part) demandfuture
		from	#mps
		order	by #mps.part			

		insert into #mpsasgn
		select	#mps.part,
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due < @start_dt and 
				pod.part_number = #mps.part) asgndpast,
				
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= @start_dt and pod.date_due < dateadd ( month, 1, @start_dt ) and
				pod.part_number = #mps.part) asgnd1,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( month, 1, @start_dt ) and 
				pod.date_due < dateadd ( month, 2, @start_dt ) and
				pod.part_number = #mps.part) asgnd2,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( month, 2, @start_dt ) and 
				pod.date_due < dateadd ( month, 3, @start_dt ) and
				pod.part_number = #mps.part) asgnd3,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( month, 3, @start_dt ) and 
				pod.date_due < dateadd ( month, 4, @start_dt ) and
				pod.part_number = #mps.part) asgnd4,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( month, 4, @start_dt ) and 
				pod.date_due < dateadd ( month, 5, @start_dt ) and
				pod.part_number = #mps.part) asgnd5,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( month, 5, @start_dt ) and 
				pod.date_due < dateadd ( month, 6, @start_dt ) and
				pod.part_number = #mps.part) asgnd6,
				
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( month, 6, @start_dt ) and 
				pod.date_due < dateadd ( month, 7, @start_dt ) and
				pod.part_number = #mps.part) asgnd7,
				
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( month, 7, @start_dt ) and 
				pod.date_due < dateadd ( month, 8, @start_dt ) and
				pod.part_number = #mps.part) asgnd8,
				
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( month, 8, @start_dt ) and 
				pod.date_due < dateadd ( month, 9, @start_dt ) and
				pod.part_number = #mps.part) asgnd9,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( month, 9, @start_dt ) and 
				pod.date_due < dateadd ( month, 10, @start_dt ) and
				pod.part_number = #mps.part) asgnd10,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( month, 10, @start_dt ) and 
				pod.date_due < dateadd ( month, 11, @start_dt ) and
				pod.part_number = #mps.part) asgnd11,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( month, 11, @start_dt ) and 
				pod.date_due < dateadd ( month, 12, @start_dt ) and
				pod.part_number = #mps.part) asgnd12,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( month, 12, @start_dt ) and
				pod.part_number = #mps.part) asgndfuture
		from	#mps
		order	by #mps.part			
	end
	else
	begin
		insert	into #mpsdmd
		select	#mps.part,
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due < @start_dt and 
				mps.part = #mps.part) demandpast,
				
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= @start_dt and mps.due < dateadd ( week, 1, @start_dt ) and
				mps.part = #mps.part) demand1,
	
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( week, 1, @start_dt ) and 
				mps.due < dateadd ( week, 2, @start_dt ) and
				mps.part = #mps.part) demand2,
	
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( week, 2, @start_dt ) and 
				mps.due < dateadd ( week, 3, @start_dt ) and
				mps.part = #mps.part) demand3,
	
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( week, 3, @start_dt ) and 
				mps.due < dateadd ( week, 4, @start_dt ) and
				mps.part = #mps.part) demand4,
	
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( week, 4, @start_dt ) and 
				mps.due < dateadd ( week, 5, @start_dt ) and
				mps.part = #mps.part) demand5,
	
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( week, 5, @start_dt ) and 
				mps.due < dateadd ( week, 6, @start_dt ) and
				mps.part = #mps.part) demand6,
				
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( week, 6, @start_dt ) and 
				mps.due < dateadd ( week, 7, @start_dt ) and
				mps.part = #mps.part) demand7,
				
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( week, 7, @start_dt ) and 
				mps.due < dateadd ( week, 8, @start_dt ) and
				mps.part = #mps.part) demand8,
				
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( week, 8, @start_dt ) and 
				mps.due < dateadd ( week, 9, @start_dt ) and
				mps.part = #mps.part) demand9,
	
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( week, 9, @start_dt ) and 
				mps.due < dateadd ( week, 10, @start_dt ) and
				mps.part = #mps.part) demand10,
	
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( week, 10, @start_dt ) and 
				mps.due < dateadd ( week, 11, @start_dt ) and
				mps.part = #mps.part) demand11,
	
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( week, 11, @start_dt ) and 
				mps.due < dateadd ( week, 12, @start_dt ) and
				mps.part = #mps.part) demand12,
			(select	isnull(sum(mps.qnty),0)
			from	master_prod_sched mps
			where	mps.due >= dateadd ( week, 12, @start_dt ) and
				mps.part = #mps.part) demandfuture
		from	#mps
		order	by #mps.part			

		insert into #mpsasgn
		select	#mps.part,
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due < @start_dt and 
				pod.part_number = #mps.part) asgndpast,
				
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= @start_dt and pod.date_due < dateadd ( week, 1, @start_dt ) and
				pod.part_number = #mps.part) asgnd1,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( week, 1, @start_dt ) and 
				pod.date_due < dateadd ( week, 2, @start_dt ) and
				pod.part_number = #mps.part) asgnd2,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( week, 2, @start_dt ) and 
				pod.date_due < dateadd ( week, 3, @start_dt ) and
				pod.part_number = #mps.part) asgnd3,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( week, 3, @start_dt ) and 
				pod.date_due < dateadd ( week, 4, @start_dt ) and
				pod.part_number = #mps.part) asgnd4,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( week, 4, @start_dt ) and 
				pod.date_due < dateadd ( week, 5, @start_dt ) and
				pod.part_number = #mps.part) asgnd5,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( week, 5, @start_dt ) and 
				pod.date_due < dateadd ( week, 6, @start_dt ) and
				pod.part_number = #mps.part) asgnd6,
				
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( week, 6, @start_dt ) and 
				pod.date_due < dateadd ( week, 7, @start_dt ) and
				pod.part_number = #mps.part) asgnd7,
				
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( week, 7, @start_dt ) and 
				pod.date_due < dateadd ( week, 8, @start_dt ) and
				pod.part_number = #mps.part) asgnd8,
				
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( week, 8, @start_dt ) and 
				pod.date_due < dateadd ( week, 9, @start_dt ) and
				pod.part_number = #mps.part) asgnd9,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( week, 9, @start_dt ) and 
				pod.date_due < dateadd ( week, 10, @start_dt ) and
				pod.part_number = #mps.part) asgnd10,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( week, 10, @start_dt ) and 
				pod.date_due < dateadd ( week, 11, @start_dt ) and
				pod.part_number = #mps.part) asgnd11,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( week, 11, @start_dt ) and 
				pod.date_due < dateadd ( week, 12, @start_dt ) and
				pod.part_number = #mps.part) asgnd12,
	
			(select	isnull(sum(pod.balance),0)
			from	po_detail pod
			where	pod.date_due >= dateadd ( week, 12, @start_dt ) and
				pod.part_number = #mps.part) asgndfuture
		from	#mps
		order	by #mps.part			
	end

	if @mode = 'M'
		select	#mps.part,
			p.name,
			p.description_long,
			parto.default_vendor,
			pv.min_on_order,
			v.name,
			@start_dt date1,
			dateadd ( month, 1, @start_dt ) date2,
			dateadd ( month, 2, @start_dt ) date3,
			dateadd ( month, 3, @start_dt ) date4,
			dateadd ( month, 4, @start_dt ) date5,
			dateadd ( month, 5, @start_dt ) date6,
			dateadd ( month, 6, @start_dt ) date7,
			dateadd ( month, 7, @start_dt ) date8,
			dateadd ( month, 8, @start_dt ) date9,
			dateadd ( month, 9, @start_dt ) date10,
			dateadd ( month, 10, @start_dt ) date11,
	 		dateadd ( month, 11, @start_dt ) date12,
			dateadd ( month, 12, @start_dt ) datefuture,
			demandpast,
			demand1,
			demand2,
			demand3,
			demand4,
			demand5,
			demand6,
			demand7,
			demand8,
			demand9,
			demand10,
			demand11,
			demand12,
			demandfuture,
			asgnpast,
			asgn1,
			asgn2,
			asgn3,
			asgn4,
			asgn5,
			asgn6,
			asgn7,
			asgn8,
			asgn9,
			asgn10,
			asgn11,
			asgn12,
			asgnfuture,
			(select isnull(sum(onhand),0) from #ponhand where cpart = #mps.part) onhand,
			pmt.company_name company_name,
			pmt.company_logo company_logo
		from	#mps
			join part p on p.part = #mps.part
			join part_online parto on parto.part = p.part
			LEFT outer join #mpsdmd on #mpsdmd.part = #mps.part
			LEFT outer join #mpsasgn on #mpsasgn.part = #mps.part
			LEFT OUTER join part_vendor pv on pv.part = p.part and pv.vendor = parto.default_vendor
			LEFT OUTER join vendor v on v.code = parto.default_vendor
			CROSS JOIN parameters pmt
			order	by #mps.part
	else
			select	#mps.part,
			p.name,
			p.description_long,
			parto.default_vendor,
			pv.min_on_order,
			v.name,
			@start_dt date1,
			dateadd ( week, 1, @start_dt ) date2,
			dateadd ( week, 2, @start_dt ) date3,
			dateadd ( week, 3, @start_dt ) date4,
			dateadd ( week, 4, @start_dt ) date5,
			dateadd ( week, 5, @start_dt ) date6,
			dateadd ( week, 6, @start_dt ) date7,
			dateadd ( week, 7, @start_dt ) date8,
			dateadd ( week, 8, @start_dt ) date9,
			dateadd ( week, 9, @start_dt ) date10,
			dateadd ( week, 10, @start_dt ) date11,
	 		dateadd ( week, 11, @start_dt ) date12,
			dateadd ( week, 12, @start_dt ) datefuture,
			demandpast,
			demand1,
			demand2,
			demand3,
			demand4,
			demand5,
			demand6,
			demand7,
			demand8,
			demand9,
			demand10,
			demand11,
			demand12,
			demandfuture,
			asgnpast,
			asgn1,
			asgn2,
			asgn3,
			asgn4,
			asgn5,
			asgn6,
			asgn7,
			asgn8,
			asgn9,
			asgn10,
			asgn11,
			asgn12,
			asgnfuture,
			(select isnull(sum(onhand),0) from #ponhand where cpart = #mps.part) onhand,
			pmt.company_name company_name,
			pmt.company_logo company_logo
		from	#mps
			join part p on p.part = #mps.part
			join part_online parto on parto.part = p.part
			LEFT outer join #mpsdmd on #mpsdmd.part = #mps.part
			LEFT outer join #mpsasgn on #mpsasgn.part = #mps.part
			left OUTER join part_vendor pv on pv.part = p.part and pv.vendor = parto.default_vendor
			LEFT OUTER join vendor v on v.code = parto.default_vendor
			CROSS join parameters pmt
		order	by #mps.part
end 		
go

----------------------------------
-- View:	cdivw_scrapqtylist
----------------------------------
if exists(select 1 from sysobjects where name = 'cdivw_scrapqtylist')
	drop view cdivw_scrapqtylist
go	
create view cdivw_scrapqtylist
	(part,
	 scrapcode,
	scrapqty,
	scrapdate)
as	
select	df.part, 
	df.reason,
	df.quantity scrapqty,
	df.defect_date
from	defects df
union 
select	at.part,
	at.user_defined_status,
	at.quantity scrapqty,
	at.date_stamp
from	audit_trail at
where	at.status = 'S'
go

if not exists (select 1 from dbo.syscolumns, dbo.sysobjects where dbo.sysobjects.id = dbo.syscolumns.id and dbo.sysobjects.name = 'employee' and dbo.syscolumns.name = 'epassword')
	alter table employee add epassword text null
go
if not exists (select 1 from dbo.syscolumns, dbo.sysobjects where dbo.sysobjects.id = dbo.syscolumns.id and dbo.sysobjects.name = 'employee' and dbo.syscolumns.name = 'operatorlevel')
	alter table employee add operatorlevel integer null
go
if not exists (select 1 from dbo.syscolumns, dbo.sysobjects where dbo.sysobjects.id = dbo.syscolumns.id and dbo.sysobjects.name = 'machine_policy' and dbo.syscolumns.name = 'supervisorclose')
	alter table machine_policy add supervisorclose char(1) null
go
	
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
if not exists (select 1 from dbo.sysindexes, dbo.sysobjects where dbo.sysobjects.id = dbo.sysindexes.id and dbo.sysobjects.name = 'po_detail' and dbo.sysindexes.name = 'podpart')
	create index podpart on po_detail (part_number)
go

Print	'workorder detail part index'
if not exists (select 1 from dbo.sysindexes, dbo.sysobjects where dbo.sysobjects.id = dbo.sysindexes.id and dbo.sysobjects.name = 'workorder_detail' and dbo.sysindexes.name = 'wodpart')
	create index wodpart on workorder_detail (part)
go
	
-- at the end
print '
----------------------------
--	Updating the version
---------------------------- 
'
update	admin set version = '4.6.20041231'
go
