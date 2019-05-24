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

update admin set version = '4.5.1'
go
commit
go
