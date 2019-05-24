SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[cdisp_massdelauditrec] ( @startchar char(1) ) as
begin
	--	Declare variables
	declare	@noofdays smallint
	
	--	Initialize the number of days based on the starting character passed
	if @startchar = 'D' 
		select @noofdays = 30
	else if @startchar = 'F'
		select @noofdays = 60
	else if @startchar = 'M'
		select @noofdays = 90
	
	--	if the starting char is F the below section will be executed
	if @startchar = 'F'
	begin	
		--	insert into audit trail all the parts starting with 'F' and ending with 'BP' and which are over 60 days
		insert	into audit_trail (
			serial,  part,  from_loc,  date_stamp,  type, remarks, to_loc, unit, operator, status,  destination, origin, cost, weight, parent_serial,  notes, quantity, customer, 
			sequence, shipper, lot,  po_number, part_name, plant,  std_quantity, package_type, field1, field2, custom1,  custom2,  custom3,  custom4,  custom5, show_on_shipper, due_date,
			tare_weight, suffix, std_cost, user_defined_status, workorder, engineering_level, kanban_number, dimension_qty_string, dim_qty_string_other, varying_dimension_code, posted,
			on_hand)
		SELECT	serial,  object.part,  location,  getdate(), 'D', 'Delete',  'Trash', unit_measure,  operator,  status,  destination,   origin,  cost,  weight,  parent_seriaL,  note,  quantity,   customer,
			sequence,  shipper,  lot,   po_number,  name,  plant,   std_quantity,  package_type,  field1,  field2,  custom1,  custom2,  custom3,  custom4,  custom5,  show_on_shipper, date_due,
			tare_weight,  suffix,  std_cost,  user_defined_status, workorder, 	engineering_level, 	kanban_number, dimension_qty_string,  dim_qty_string_other,  varying_dimension_code,  posted,
			pol.on_hand
		from	object
			join part_online pol on pol.part = object.part
		where	left(object.part,1) = @startchar  and right(object.part,2) = 'BP' and
			datediff(dd, last_date, getdate()) > @noofdays 
			
		--	delete inventory from object
		delete	object
		where	left(object.part,1) = @startchar  and right(object.part,2) = 'BP' and
			datediff(dd, last_date, getdate()) > @noofdays 
	end
	else
	begin
		--	insert into audit trail all the parts starting with 'D' or 'M' which are over 30 or 90 days	
		insert	into audit_trail (
			serial,  part,  from_loc,  date_stamp,  type, remarks, to_loc, unit, operator, status,  destination,  origin, cost, weight, parent_serial,  notes, quantity, customer, 
			sequence, shipper, lot,  po_number, part_name, plant,  std_quantity, package_type, field1, field2, custom1,  custom2,  custom3,  custom4,  custom5, show_on_shipper, due_date,
			tare_weight, suffix, std_cost, user_defined_status, workorder, engineering_level, kanban_number, dimension_qty_string, dim_qty_string_other, varying_dimension_code, posted,
			on_hand)
		SELECT	serial,  object.part,  location,  getdate(), 'D', 'Delete',  'Trash', unit_measure,  operator,  status,  destination,   origin,  cost,  weight,  parent_seriaL,  note,  quantity,   customer,
			sequence,  shipper,  lot,   po_number,  name,  plant,   std_quantity,  package_type,  field1,  field2,  custom1,  custom2,  custom3,  custom4,  custom5,  show_on_shipper, date_due,
			tare_weight,  suffix,  std_cost,  user_defined_status, workorder, 	engineering_level, 	kanban_number, dimension_qty_string,  dim_qty_string_other,  varying_dimension_code,  posted,
			pol.on_hand
		from	object
			join part_online pol on pol.part = object.part
		where	left(object.part,1) = @startchar  and
			datediff(dd, last_date, getdate()) > @noofdays 
			
		--	delete inventory from object			
		delete	object
		where	left(object.part,1) = @startchar  and
			datediff(dd, last_date, getdate()) > @noofdays 
	end
end
GO
