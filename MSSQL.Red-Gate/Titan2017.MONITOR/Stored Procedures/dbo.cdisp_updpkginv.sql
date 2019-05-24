SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[cdisp_updpkginv] (@shipper integer, @operator varchar(5)) as
begin -- 1b
	--	Declarations
	declare	@pkgcodepart	varchar(25)
	declare	@shipqty	numeric(20,6)
	declare	@shipstdqty	numeric(20,6)
	declare	@serial		integer
	declare	@serialnumber	integer	
	declare	@oqty		numeric(20,6)
	declare	@ostdqty	numeric(20,6)
	declare	@um		varchar(2)
	declare @onhand		numeric(20,6)
	declare	@pkgqty		decimal(20,6)
	declare @noofshpctr	decimal(20,6)
	declare	@part		varchar(25)

	begin transaction
	--	Declare the required temp table
	create	table #atrecords (
		part		varchar(25),
		pkgcodepart	varchar(25),
		quantity	numeric(20,6),
		std_quantity	numeric(20,6) )
	
	if @operator is null
		select @operator = 'Mon'
		
	--	Insert records into the temp table
	insert	into #atrecords	
	select	part, package_type, isnull(quantity,0), isnull(std_quantity,0)
	from	audit_trail
	where	shipper = convert(varchar(20),@shipper) and
		type = 'S' and package_type > '' 

	--	Declare the required cursor 
	declare pkglist cursor for 
	select 	part, pkgcodepart, isnull(sum(quantity),0), isnull(sum(std_quantity),0)
	from 	#atrecords
	group by part, pkgcodepart
			
	--	Open cursor
	open	pkglist
	
	--	Fetch the data row by row
	fetch	pkglist into @part, @pkgcodepart, @shipqty, @shipstdqty 

	--	Check for sqlstatus, as long as it's valid process the rows
	while ( @@fetch_status = 0 )
	begin -- 2b

		select	@pkgqty = quantity
		from	part_packaging
		where	code = @pkgcodepart and part = @part
		
		--	Declare the required cursor 
		declare objectslist cursor for 
		select 	serial, isnull(quantity,0), isnull(std_quantity,0), unit_measure
		from 	object
		where	part = @pkgcodepart

		--	Get the onhand for that package code part
		select	@onhand = isnull(sum(isnull(quantity,0)),0)
		from	object
		where	part = @pkgcodepart

		--	Open cursor
		open	objectslist
		
		--	Fetch the data row by row
		fetch	objectslist into @serial, @oqty, @ostdqty, @um

		--	Check for sqlstatus, as long as it's valid process the rows
		while ( @@fetch_status = 0 and @shipqty > 0 )
		begin -- 3b
		
			-- Compute the no. of containers
			select	@noofshpctr = (@shipqty/isnull(@pkgqty,1))
			
			--	Check shipped quantity with quantity on each serial 
			if isnull(@oqty,0) >=  @noofshpctr -- if serial qty is less or equal than shipped
			begin -- 4b

				--	Reduce onhand
				select	@onhand = @onhand - @noofshpctr
				
				--	update object with the new quantity for that serial
				update	object
				set	quantity = quantity - @noofshpctr,
					std_quantity = std_quantity - @noofshpctr
				where	serial = @serial 
				
				--	Update part_online table
				update	part_online
				set	on_hand = @onhand
				where	part = @pkgcodepart
				
				--	Write a 'X' type record to audit trail as serial is corrected
				insert	into audit_trail (serial, date_stamp, type, part, quantity, remarks, price, salesman,   
							customer, vendor, po_number, operator, from_loc, to_loc, on_hand, lot,   
							weight, status, shipper, flag, activity, unit, workorder,std_quantity,   
							cost, control_number, custom1, custom2,	custom3, custom4, custom5,   
							plant, invoice_number, notes, gl_account, package_type,	suffix,   
							due_date, group_no, sales_order, release_no, dropship_shipper,   
							std_cost, user_defined_status, engineering_level, posted, parent_serial,
							origin, destination, sequence, object_type, part_name, start_date,
							field1, field2, show_on_shipper, tare_weight, kanban_number, 
							dimension_qty_string, dim_qty_string_other, varying_dimension_code)
				select	object.serial, getdate(), 'X', object.part, object.quantity, 'PkgIUpdate', object.cost,
					null, object.customer, null, object.po_number, @operator, object.location, 
					object.location, @onhand, object.lot, object.weight, object.status, object.shipper, 
					null, null, object.unit_measure, object.workorder, object.std_quantity, object.cost, 
				  	null, object.custom1, object.custom2, object.custom3, object.custom4, object.custom5, 
				  	object.plant, null, object.note, null,	object.package_type, object.suffix, object.date_due, 
				  	null, null, null, null, object.std_cost, object.user_defined_status, object.engineering_level, 
				  	object.posted, object.parent_serial, object.origin, object.destination, object.sequence, 
				  	null, object.name, object.start_date, object.field1, object.field2, object.show_on_shipper, 
				  	object.tare_weight, object.kanban_number, object.dimension_qty_string, object.dim_qty_string_other, 
				  	object.varying_dimension_code
				from	object 
				where	object.serial = @serial						

				--	Adjust shipqty				
				select	@shipqty = @shipqty - (@pkgqty * @noofshpctr)
				
			end -- 4e
			else	-- if object quantity is greater than the ship qty 
			begin -- 5b
				--	Reduce onhand
				select	@onhand = @onhand - @noofshpctr

				--	Update part_online table
				update	part_online
				set	on_hand = @onhand
				where	part = @pkgcodepart

				--	Write a 'D' type record to audit trail for the serial
				insert	into audit_trail (serial, date_stamp, type, part, quantity, remarks, price, salesman,   
							customer, vendor, po_number, operator, from_loc, to_loc, on_hand, lot,   
							weight, status, shipper, flag, activity, unit, workorder,std_quantity,   
							cost, control_number, custom1, custom2,	custom3, custom4, custom5,   
							plant, invoice_number, notes, gl_account, package_type,	suffix,   
							due_date, group_no, sales_order, release_no, dropship_shipper,   
							std_cost, user_defined_status, engineering_level, posted, parent_serial,
							origin, destination, sequence, object_type, part_name, start_date,
							field1, field2, show_on_shipper, tare_weight, kanban_number, 
							dimension_qty_string, dim_qty_string_other, varying_dimension_code)
				select	object.serial, getdate(), 'D', object.part, object.quantity, 'PkgIDelete', object.cost,
					null, object.customer, null, object.po_number, @operator, object.location, 
					object.location, @onhand, object.lot, object.weight, object.status, object.shipper, 
					null, null, object.unit_measure, object.workorder, object.std_quantity, object.cost, 
				  	null, object.custom1, object.custom2, object.custom3, object.custom4, object.custom5, 
				  	object.plant, null, object.note, null,	object.package_type, object.suffix, object.date_due, 
				  	null, null, null, null, object.std_cost, object.user_defined_status, object.engineering_level, 
				  	object.posted, object.parent_serial, object.origin, object.destination, object.sequence, 
				  	null, object.name, object.start_date, object.field1, object.field2, object.show_on_shipper, 
				  	object.tare_weight, object.kanban_number, object.dimension_qty_string, object.dim_qty_string_other, 
				  	object.varying_dimension_code
				from	object 
				where	object.serial = @serial						

				--	Delete object from object table
				delete	object
				where	serial = @serial

				--	Adjust shipqty				
				select	@shipqty = @shipqty - (@pkgqty * @oqty ) 

			end -- 5e
	
			-- 	Fetch next set of rows
			fetch	objectslist into @serial, @oqty, @ostdqty, @um
		end -- 3e
			
		--	Close cursor
		close objectslist
		deallocate objectslist
	
		-- 	Fetch next set of rows
		fetch	pkglist into @part, @pkgcodepart, @shipqty, @shipstdqty
		
	end -- 2e
		
	--	Close cursor
	close pkglist
	deallocate pkglist
	
	commit transaction

end -- 1e
GO
