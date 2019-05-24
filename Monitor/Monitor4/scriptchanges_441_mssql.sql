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
select	distinct shipper.invoice_number,   
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
go

------------------------------
-- trigger:	mtr_customer_u
------------------------------
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
	@odqty		numeric(20,6)

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
			when	due < @start_dt then qnty - qty_assigned
			else 0
		end ) demandpast,
		( case
			when	due < dateadd ( day, 1, @start_dt ) and due >= @start_dt then qnty - qty_assigned 
			else 0
		end ) demand1,
		( case
			when	due < dateadd ( day, 2, @start_dt ) and due >= dateadd ( day, 1, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand2,
		( case
			when	due < dateadd ( day, 3, @start_dt ) and due >= dateadd ( day, 2, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand3,
		( case
			when	due < dateadd ( day, 4, @start_dt ) and due >= dateadd ( day, 3, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand4,
		( case
			when	due < dateadd ( day, 5, @start_dt ) and due >= dateadd ( day, 4, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand5,
		( case
			when	due < dateadd ( day, 6, @start_dt ) and due >= dateadd ( day, 5, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand6,
		( case
			when	due < dateadd ( day, 7, @start_dt ) and due >= dateadd ( day, 6, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand7,
		( case
			when	due < dateadd ( day, 8, @start_dt ) and due >= dateadd ( day, 7, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand8,
		( case
			when	due < dateadd ( day, 9, @start_dt ) and due >= dateadd ( day, 8, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand9,
		( case
			when	due < dateadd ( day, 10, @start_dt ) and due >= dateadd ( day, 9, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand10,
		( case
			when	due < dateadd ( day, 11, @start_dt ) and due >= dateadd ( day, 10, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand11,
		( case
			when	due < dateadd ( day, 12, @start_dt ) and due >= dateadd ( day, 11, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand12,
		( case
			when	due < dateadd ( day, 13, @start_dt ) and due >= dateadd ( day, 12, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand13,
		( case
			when	due < dateadd ( day, 14, @start_dt ) and due >= dateadd ( day, 13, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand14,
		( case
			when	due >= dateadd ( day, 14, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demandfuture,
		part.type,
		0,
		part.engineering_level,
		part.group_technology,
		mps.source
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
			when	due < @start_dt then qnty - qty_assigned
			else 0
		end ) demandpast,
		( case
			when	due < dateadd ( week, 1, @start_dt ) and due >= @start_dt then qnty - qty_assigned
			else 0
		end ) demand1,
		( case
			when	due < dateadd ( week, 2, @start_dt ) and due >= dateadd ( week, 1, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand2,
		( case
			when	due < dateadd ( week, 3, @start_dt ) and due >= dateadd ( week, 2, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand3,
		( case
			when	due < dateadd ( week, 4, @start_dt ) and due >= dateadd ( week, 3, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand4,
		( case
			when	due < dateadd ( week, 5, @start_dt ) and due >= dateadd ( week, 4, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand5,
		( case
			when	due < dateadd ( week, 6, @start_dt ) and due >= dateadd ( week, 5, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand6,
		( case
			when	due < dateadd ( week, 7, @start_dt ) and due >= dateadd ( week, 6, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand7,
		( case
			when	due < dateadd ( week, 8, @start_dt ) and due >= dateadd ( week, 7, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand8,
		( case
			when	due < dateadd ( week, 9, @start_dt ) and due >= dateadd ( week, 8, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand9,
		( case
			when	due < dateadd ( week, 10, @start_dt ) and due >= dateadd ( week, 9, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand10,
		( case
			when	due < dateadd ( week, 11, @start_dt ) and due >= dateadd ( week, 10, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand11,
		( case
			when	due < dateadd ( week, 12, @start_dt ) and due >= dateadd ( week, 11, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand12,
		( case
			when	due < dateadd ( week, 13, @start_dt ) and due >= dateadd ( week, 12, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand13,
		( case
			when	due < dateadd ( week, 14, @start_dt ) and due >= dateadd ( week, 13, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demand14,
		( case
			when	due >= dateadd ( week, 14, @start_dt ) then qnty - qty_assigned
			else 0
		end ) demandfuture,
		part.type,
		0,
		part.engineering_level,
		part.group_technology,
		mps.source
	from	#mps
		join master_prod_sched mps on #mps.ai_row = mps.ai_row
		join part on mps.part = part.part
		left outer join part_machine on mps.part = part_machine.part and
			part_machine.sequence = 1
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
where	isnull(oh.status,'O') = 'O' and
	od.committed_qty < od.quantity and 
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
	(isnull(status,'O') <> 'C' or isnull(status,'S') <> 'C')

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

update admin set version = '4.4.1'
go
