SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  procedure [dbo].[cdisp_hbpo_desadv_det] (@shipper integer) as
begin
------------------------------------------------------------------------------------
-- cdisp_hbpo_desadv_det
-- Gather data for HBPO DESADV detail lines
-- 11/2006 by Bruce Harold
------------------------------------------------------------------------------------

-- Define variables
declare	@palletserial		integer,
	@custpart		varchar(25),
	@cartonpkg		varchar(17),
	@cartonsize		decimal(19,6),
	@serial			integer,
	@serial1		integer,
	@serial2		integer,
	@serial3		integer,
	@serial4		integer,
	@serial5		integer,
	@serial6		integer,
	@serial7		integer,
	@serial8		integer,
	@serial9		integer,
	@serial10		integer,
	@i			integer,
	@lineno			integer,
	@cursorstat		integer

-- Work Tables

create table #part_pkg (
	pallet_serial	integer NULL,
	cust_part	varchar (25) NULL,
	carton_pkg	varchar (17) NULL,
	carton_size	decimal (19,6) NULL,
	line_no		integer NULL,
	pallet_package	varchar (17) NULL,
	ecl		varchar (17) NULL,
	part		varchar (35) NULL,
	ship_qty	decimal (19,6) NULL,
	carton_cnt	integer NULL,
	cust_po		varchar (35) NULL,
	warehouse	varchar (25) NULL
)

create table #serials (
	pallet_serial	integer NULL,
	cust_part	varchar (25) NULL,
	carton_pkg	varchar (17) NULL,
	carton_size	decimal (19,6) NULL,
	part		varchar (35) NULL,
	serial		integer NULL
)

create table #serials_grouped (
	pallet_serial	integer NULL,
	cust_part	varchar (25) NULL,
	carton_pkg	varchar (17) NULL,
	carton_size	decimal (19,6) NULL,
	serial1		integer NULL,
	serial2		integer NULL,
	serial3		integer NULL,
	serial4		integer NULL,
	serial5		integer NULL,
	serial6		integer NULL,
	serial7		integer NULL,
	serial8		integer NULL,
	serial9		integer NULL,
	serial10	integer NULL
)

-- Gather Data

-- all cartons
insert into #serials
	(pallet_serial,
	cust_part,
	carton_pkg,
	carton_size,
	part,
	serial)
select	audit_trail.parent_serial,
	audit_trail.part,
	audit_trail.package_type,
	audit_trail.quantity,
	audit_trail.part,
	audit_trail.serial
From	audit_trail
Where	audit_trail.type = 'S' and
	audit_trail.part <> 'PALLET'  and
	audit_trail.shipper = CONVERT(varchar(25), @shipper)

-- group by pallet, part, pkg, size
insert into #part_pkg
	(pallet_serial,
	cust_part,
	carton_pkg,
	carton_size,
	pallet_package,
	ecl,
	part,
	ship_qty,
	carton_cnt,
	cust_po,
	warehouse)
select	#serials.pallet_serial,
	#serials.cust_part,
	#serials.carton_pkg,
	#serials.carton_size,
	max(atp.package_type),
	max(oh.revision),
	max(#serials.part),
	sum(#serials.carton_size),
	count(1),
	max(sd.customer_po),
	max(oh.zone_code)
from	#serials
	left outer join audit_trail atp on atp.serial = #serials.pallet_serial and
		atp.type = 'S' and
		atp.shipper = convert(varchar(25), @shipper)
	join shipper_detail sd on sd.shipper = @shipper and
		sd.part = #serials.part
	join order_header oh on oh.order_no = sd.order_no
group by #serials.pallet_serial, #serials.cust_part, #serials.carton_pkg, #serials.carton_size


-- Update Fields (Use if needed)

-- Group Serial Numbers

-- Initialize
select	@lineno = 0

declare	cur_pkg cursor for
select	pallet_serial,
	cust_part,
	carton_pkg,
	carton_size
from	#part_pkg
order by pallet_serial, cust_part, carton_pkg, carton_size desc

open	cur_pkg

fetch	cur_pkg
into	@palletserial,
	@custpart,
	@cartonpkg,
	@cartonsize

while @@fetch_status = 0 
begin  -- cur_pkg

	-- assign line number to this record
	select	@lineno = @lineno + 1
	
	update	#part_pkg
	set	line_no = @lineno
	where	pallet_serial = @palletserial 
		and cust_part = @custpart	
		and carton_pkg = @cartonpkg
		and carton_size = @cartonsize
		
--	where	current of cur_pkg
		
	declare cur_serial cursor for
	select	serial
	from	#serials
	where	isnull(#serials.pallet_serial,0) = isnull(@palletserial,0) and
		#serials.cust_part = @custpart and
		#serials.carton_pkg = @cartonpkg and
		#serials.carton_size = @cartonsize
	order by serial
	
	open	cur_serial
		
	fetch	cur_serial
	into	@serial

	select @cursorstat = @@fetch_status
	
	-- Special looping logic to handle sets of 10
	-- This adds one more fetch than usual
	while ( @cursorstat = 0 )
	begin -- cur_serial
			
		-- Initialize variables
	
		select	@i = 0,
			@serial1 = NULL,
			@serial2 = NULL,
			@serial3 = NULL,
			@serial4 = NULL,
			@serial5 = NULL,
			@serial6 = NULL,
			@serial7 = NULL,
			@serial8 = NULL,
			@serial9 = NULL,
			@serial10 = NULL
		
		-- loop 1 to 10 as long as there are records
		while ( @i < 10 and @cursorstat = 0 )
		begin -- 10 loop & cur_serial
			select	@i = @i + 1	
			
			-- Put serial in correct spot
			if @i = 1
				select @serial1 = @serial
			else if @i = 2
				select @serial2 = @serial
			else if @i = 3
				select @serial3 = @serial
			else if @i = 4
				select @serial4 = @serial
			else if @i = 5
				select @serial5 = @serial
			else if @i = 6
				select @serial6 = @serial
			else if @i = 7
				select @serial7 = @serial
			else if @i = 8
				select @serial8 = @serial
			else if @i = 9
				select @serial9 = @serial
			else if @i = 10
				select @serial10 = @serial
	
			-- Next serial		
			fetch	cur_serial
			into	@serial

			select @cursorstat = @@fetch_status
			
		end  -- 10 loop & cur_serial
		
		-- If we have 10 or have run out of serials, it is time to write
		
		insert into #serials_grouped
			(pallet_serial,
			cust_part,
			carton_pkg,
			carton_size,
			serial1,
			serial2,
			serial3,
			serial4,
			serial5,
			serial6,
			serial7,
			serial8,
			serial9,
			serial10)
		values	(@palletserial,
			@custpart,
			@cartonpkg,
			@cartonsize,
			@serial1,
			@serial2,
			@serial3,
			@serial4,
			@serial5,
			@serial6,
			@serial7,
			@serial8,
			@serial9,
			@serial10)
		
	end -- cur_serial

	-- Close serial cursor	
	close cur_serial
--	deallocate cur_serial
	
	-- Next Part/package
	fetch	cur_pkg
	into	@palletserial,
		@custpart,
		@cartonpkg,
		@cartonsize
		
end -- cur_pkg

close cur_pkg
deallocate cur_pkg
deallocate cur_serial

-- Final Select

select	ppk.pallet_serial,
	ppk.cust_part,
	ppk.carton_pkg,
	ppk.carton_size,
	ppk.line_no,
	ppk.pallet_package,
	ppk.ecl,
	ppk.part,
	ppk.ship_qty,
	ppk.carton_cnt,
	ppk.cust_po,
	ppk.warehouse,
	serial1,
	serial2,
	serial3,
	serial4,
	serial5,
	serial6,
	serial7,
	serial8,
	serial9,
	serial10
from	#part_pkg ppk
	join #serials_grouped sg on
		isnull(sg.pallet_serial, 0) = isnull(ppk.pallet_serial, 0) and
		sg.cust_part = ppk.cust_part and
		sg.carton_pkg = ppk.carton_pkg and
		sg.carton_size = ppk.carton_size
order by ppk.pallet_serial, ppk.cust_part, ppk.carton_pkg, ppk.carton_size, serial1

end


GO
