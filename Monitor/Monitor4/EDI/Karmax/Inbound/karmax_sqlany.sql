
if exists (select * from sysobjects where id = object_id('karmax_830_releases'))
        drop table karmax_830_releases
        
GO

CREATE TABLE karmax_830_releases (
        release_no		varchar (30) NULL,
        release_type		varchar (2)  NULL,
        po_number_bfr		varchar (22) NULL,
        supplier_id		varchar (17) NULL,		
        ship_to 		varchar (30) NULL,
        customer_part 		varchar (30) NULL,
        ecl	 		varchar (19) NULL,
        customer_po_lin		varchar (22) NULL,
        ship_to_id_2		varchar	(30) NULL,
        SDP01			varchar (2)  NULL,
        SDP02			varchar (1)  NULL, 
       	FST01	 		varchar (17) NULL,
       	FST02	 		varchar (1)  NULL,
       	FST03	 		varchar (1)  NULL,
       	FST04	 		varchar (6)  NULL
)
GO


if exists (select * from sysobjects where id = object_id('karmax_830_oh_data'))
        drop table karmax_830_oh_data
        
GO

CREATE TABLE karmax_830_oh_data (
        release_no		varchar	(30) NULL,
        po_number_bfr		varchar (22) NULL,
        supplier_id		varchar (17) NULL,
        ship_to 		varchar (30) NULL,
        customer_part 		varchar (30) NULL,
        ecl 			varchar (30) NULL,
        customer_po_lin		varchar (22) NULL,
        ref02_dock 		varchar (30) NULL,
        ref02_harm_code		varchar (30) NULL,
        ref02_line_feed		varchar (30) NULL,
        ref02_reserve_lf	varchar	(30) NULL,
        ship_to_id_2		varchar	(30) NULL 
)
GO


if exists (select * from sysobjects where id = object_id('karmax_830_auth_cums'))
        drop table karmax_830_auth_cums
        
GO

CREATE TABLE karmax_830_auth_cums (
        release_no		varchar	(30) NULL,
        po_number_bfr		varchar (22) NULL,
        supplier_id		varchar (17) NULL,
        ship_to 		varchar (30) NULL,
        customer_part 		varchar (30) NULL,
        ecl 			varchar (30) NULL,
        customer_po_lin		varchar (22) NULL,
        raw_auth		varchar (17) NULL,
        raw_auth_start_dt	varchar (6)  NULL,
        raw_auth_end_date	varchar (6)  NULL,
        fab_auth		varchar (17) NULL,
        fab_auth_start_dt	varchar (6)  NULL,
        fab_auth_end_date	varchar (6)  NULL,
        prior_cum		varchar (17) NULL,
        prior_cum_start_dt	varchar (6)  NULL,
        prior_cum_end_date	varchar (6)  NULL,
        ship_to_id_2		varchar	(30) NULL
        
                
)
GO

if exists (select * from sysobjects where id = object_id('karmax_830_auth_cums_history'))
        drop table karmax_830_auth_cums_history
        
GO

CREATE TABLE karmax_830_auth_cums_history (
        release_no		varchar	(30) NULL,
        po_number_bfr		varchar (22) NULL,
        supplier_id		varchar (17) NULL,
        ship_to 		varchar (30) NULL,
        customer_part 		varchar (30) NULL,
        ecl 			varchar (30) NULL,
        customer_po_lin		varchar (22) NULL,
        raw_auth		varchar (17) NULL,
        raw_auth_start_dt	varchar (6)  NULL,
        raw_auth_end_date	varchar (6)  NULL,
        fab_auth		varchar (17) NULL,
        fab_auth_start_dt	varchar (6)  NULL,
        fab_auth_end_date	varchar (6)  NULL,
        prior_cum		varchar (17) NULL,
        prior_cum_start_dt	varchar (6)  NULL,
        prior_cum_end_date	varchar (6)  NULL,
        ship_to_id_2		varchar	(30) NULL
        
                
)
GO

if exists (select * from sysobjects where id = object_id('karmax_830_shipments'))
        drop table karmax_830_shipments
        
GO

CREATE TABLE karmax_830_shipments (
        release_no		varchar	(30) NULL,
        po_number_bfr		varchar (22) NULL,
        supplier_id		varchar (17) NULL,
        ship_to 		varchar (30) NULL,
        customer_part 		varchar (30) NULL,
        ecl 			varchar (30) NULL,
        customer_po_lin		varchar (22) NULL,
        ship_to_id_2		varchar	(30) NULL,
        last_qty_shipped	varchar (17) NULL,
        shipped_date		varchar (6)  NULL,
        shipper_id_ship		varchar (30) NULL,
        received_date		varchar (6)  NULL,
        last_qty_received	varchar (17) NULL,
        shipper_id_rec		varchar (30) NULL,
        cytd			varchar (17) NULL,
        cytd_start_dt		varchar (6)  NULL,
        cytd_end_date		varchar (6)  NULL
        
                
)
GO

if exists (select * from sysobjects where id = object_id('edi_830_cums'))
        drop table edi_830_cums
        
GO

CREATE TABLE edi_830_cums (
        customer_part		varchar (30),
        destination		varchar (20),
        customer_po		varchar (30),
        customer_cum		numeric (20,6),
        our_cum			numeric (20,6)
        
                
)
GO

if exists (select * from sysobjects where id = object_id('karmax_862_releases'))
        drop table karmax_862_releases
        
GO

CREATE TABLE karmax_862_releases (
        release_no		varchar (30) NULL,
        release_type		varchar (2)  NULL,
        po_number_bfr		varchar (22) NULL,
        supplier_id		varchar (17) NULL,		
        ship_to 		varchar (30) NULL,
        customer_part 		varchar (30) NULL,
        ecl	 		varchar (19) NULL,
        customer_po_lin		varchar (22) NULL,
        ship_to_id_2		varchar	(30) NULL,
        SDP01			varchar (2)  NULL,
        SDP02			varchar (1)  NULL, 
       	FST01	 		varchar (17) NULL,
       	FST02	 		varchar (1)  NULL,
       	FST03	 		varchar (1)  NULL,
       	FST04	 		varchar (6)  NULL
)
GO


if exists (select * from sysobjects where id = object_id('karmax_862_oh_data'))
        drop table karmax_862_oh_data
        
GO

CREATE TABLE karmax_862_oh_data (
        release_no		varchar	(30) NULL,
        po_number_bfr		varchar (22) NULL,
        supplier_id		varchar (17) NULL,
        ship_to 		varchar (30) NULL,
        customer_part 		varchar (30) NULL,
        ecl 			varchar (30) NULL,
        customer_po_lin		varchar (22) NULL,
        ref02_dock 		varchar (30) NULL,
        ref02_harm_code		varchar (30) NULL,
        ref02_line_feed		varchar (30) NULL,
        ref02_reserve_lf	varchar	(30) NULL,
        ship_to_id_2		varchar	(30) NULL 
)
GO


if exists (select * from sysobjects where id = object_id('karmax_862_auth_cums'))
        drop table karmax_862_auth_cums
        
GO

CREATE TABLE karmax_862_auth_cums (
        release_no		varchar	(30) NULL,
        po_number_bfr		varchar (22) NULL,
        supplier_id		varchar (17) NULL,
        ship_to 		varchar (30) NULL,
        customer_part 		varchar (30) NULL,
        ecl 			varchar (30) NULL,
        customer_po_lin		varchar (22) NULL,
        raw_auth		varchar (17) NULL,
        raw_auth_start_dt	varchar (6)  NULL,
        raw_auth_end_date	varchar (6)  NULL,
        fab_auth		varchar (17) NULL,
        fab_auth_start_dt	varchar (6)  NULL,
        fab_auth_end_date	varchar (6)  NULL,
        prior_cum		varchar (17) NULL,
        prior_cum_start_dt	varchar (6)  NULL,
        prior_cum_end_date	varchar (6)  NULL,
        ship_to_id_2		varchar	(30) NULL
        
                
)
GO

if exists (select * from sysobjects where id = object_id('karmax_862_auth_cums_history'))
        drop table karmax_862_auth_cums_history
        
GO

CREATE TABLE karmax_862_auth_cums_history (
        release_no		varchar	(30) NULL,
        po_number_bfr		varchar (22) NULL,
        supplier_id		varchar (17) NULL,
        ship_to 		varchar (30) NULL,
        customer_part 		varchar (30) NULL,
        ecl 			varchar (30) NULL,
        customer_po_lin		varchar (22) NULL,
        raw_auth		varchar (17) NULL,
        raw_auth_start_dt	varchar (6)  NULL,
        raw_auth_end_date	varchar (6)  NULL,
        fab_auth		varchar (17) NULL,
        fab_auth_start_dt	varchar (6)  NULL,
        fab_auth_end_date	varchar (6)  NULL,
        prior_cum		varchar (17) NULL,
        prior_cum_start_dt	varchar (6)  NULL,
        prior_cum_end_date	varchar (6)  NULL,
        ship_to_id_2		varchar	(30) NULL
        
                
)
GO

if exists (select * from sysobjects where id = object_id('karmax_862_shipments'))
        drop table karmax_862_shipments
        
GO

CREATE TABLE karmax_862_shipments (
        release_no		varchar	(30) NULL,
        po_number_bfr		varchar (22) NULL,
        supplier_id		varchar (17) NULL,
        ship_to 		varchar (30) NULL,
        customer_part 		varchar (30) NULL,
        ecl 			varchar (30) NULL,
        customer_po_lin		varchar (22) NULL,
        ship_to_id_2		varchar	(30) NULL,
        last_qty_shipped	varchar (17) NULL,
        shipped_date		varchar (6)  NULL,
        shipper_id_ship		varchar (30) NULL,
        received_date		varchar (6)  NULL,
        last_qty_received	varchar (17) NULL,
        shipper_id_rec		varchar (30) NULL,
        cytd			varchar (17) NULL,
        cytd_start_dt		varchar (6)  NULL,
        cytd_end_date		varchar (6)  NULL
        
                
)
GO

if exists (select * from sysobjects where id = object_id('edi_862_cums'))
        drop table edi_862_cums
        
GO

CREATE TABLE edi_862_cums (
        customer_part		varchar (30),
        destination		varchar (20),
        customer_po		varchar (30),
        customer_cum		numeric (20,6),
        our_cum			numeric (20,6)
        
                
)
GO

if exists (
	select	*
	  from	sysobjects
	 where	id = object_id ( 'msp_adjust_planning_830' ) )
	drop procedure	msp_adjust_planning_830
go


create procedure msp_adjust_planning_830
as
begin transaction

delete	order_detail
from	order_detail
	join order_header on order_detail.order_no = order_header.order_no
	join m_in_release_plan on 
	order_header.customer_part = m_in_release_plan.customer_part and
	order_header.destination = m_in_release_plan.shipto_id

where	type = 'P' and
	order_detail.the_cum <=
	(	select	max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no )

update	order_detail
set	our_cum =
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ),
	quantity = order_detail.the_cum -
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ),
	std_qty = order_detail.the_cum -
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no )
	
from	order_detail
	join order_header on order_detail.order_no = order_header.order_no
	join m_in_release_plan on 
	order_header.customer_part = m_in_release_plan.customer_part and
	order_header.destination = m_in_release_plan.shipto_id

where	type = 'P' and
	order_detail.due_date <=
	(	select max ( od2.due_date )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ) and
	order_detail.due_date =
	(	select min ( od2.due_date )
		from	order_detail od2
		where	od2.type = 'P' and
			order_detail.order_no = od2.order_no )

update	order_detail
set	due_date =
	(	select max ( od2.due_date )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ) + 1

from	order_detail
	join order_header on order_detail.order_no = order_header.order_no
	join m_in_release_plan on 
	order_header.customer_part = m_in_release_plan.customer_part and
	order_header.destination = m_in_release_plan.shipto_id

where	type = 'P' and
	order_detail.due_date <=
	(	select max ( od2.due_date )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no )

update	order_detail
set	our_cum =
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ),
	quantity = order_detail.the_cum -
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ),
	std_qty = order_detail.the_cum -
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no )
	
from	order_detail
	join order_header on order_detail.order_no = order_header.order_no
	join m_in_release_plan on 
	order_header.customer_part = m_in_release_plan.customer_part and
	order_header.destination = m_in_release_plan.shipto_id

where	type = 'P' and
	order_detail.our_cum =
	(	select min ( od2.our_cum )
		from	order_detail od2
		where	od2.type = 'P' and
			order_detail.order_no = od2.order_no ) and
	order_detail.our_cum <>
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no )

commit transaction

go

if exists (
	select	*
	  from	sysobjects
	 where	id = object_id ( 'msp_adjust_planning_862' ) )
	drop procedure	msp_adjust_planning_862
go


create procedure msp_adjust_planning_862
as
begin transaction

delete	order_detail
from	order_detail
	join order_header on order_detail.order_no = order_header.order_no
	join m_in_ship_schedule on 
	order_header.customer_part = m_in_ship_schedule.customer_part and
	order_header.destination = m_in_ship_schedule.shipto_id

where	type = 'P' and
	order_detail.the_cum <=
	(	select	max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no )

update	order_detail
set	our_cum =
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ),
	quantity = order_detail.the_cum -
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ),
	std_qty = order_detail.the_cum -
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no )
	
from	order_detail
	join order_header on order_detail.order_no = order_header.order_no
	join m_in_ship_schedule on 
	order_header.customer_part = m_in_ship_schedule.customer_part and
	order_header.destination = m_in_ship_schedule.shipto_id

where	type = 'P' and
	order_detail.due_date <=
	(	select max ( od2.due_date )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ) and
	order_detail.due_date =
	(	select min ( od2.due_date )
		from	order_detail od2
		where	od2.type = 'P' and
			order_detail.order_no = od2.order_no )

update	order_detail
set	due_date =
	(	select max ( od2.due_date )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ) + 1

from	order_detail
	join order_header on order_detail.order_no = order_header.order_no
	join m_in_ship_schedule on 
	order_header.customer_part = m_in_ship_schedule.customer_part and
	order_header.destination = m_in_ship_schedule.shipto_id

where	type = 'P' and
	order_detail.due_date <=
	(	select max ( od2.due_date )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no )

update	order_detail
set	our_cum =
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ),
	quantity = order_detail.the_cum -
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ),
	std_qty = order_detail.the_cum -
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no )
	
from	order_detail
	join order_header on order_detail.order_no = order_header.order_no
	join m_in_ship_schedule on 
	order_header.customer_part = m_in_ship_schedule.customer_part and
	order_header.destination = m_in_ship_schedule.shipto_id

where	type = 'P' and
	order_detail.our_cum =
	(	select min ( od2.our_cum )
		from	order_detail od2
		where	od2.type = 'P' and
			order_detail.order_no = od2.order_no ) and
	order_detail.our_cum <>
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no )


commit transaction

go

---------------------------------------------------------------------------------------
--	Monitor Orders API Procedure [SQL Anywhere version]
---------------------------------------------------------------------------------------

------------------------------
-- msp_process_in_release_plan
------------------------------
if exists (
	select	*
	  from	sysobjects
	 where	id = object_id ( 'msp_process_in_release_plan' ) )
	drop procedure	msp_process_in_release_plan
go

create procedure msp_process_in_release_plan
as
-------------------------------------------------------------------------------------
--	This procedure creates releases from inbound release plan data.
--
--	Modifications:	29 APR 1999, Eric E. Stimpson	Original
--			24 MAY 1999, Eric E. Stimpson	Modified formatting.
--							Changed decimal to numeric.
--							Added exception storage.
--			06 NOV 2000, Andre S. Boulanger Added label format and packaging to insert order_detail statement.
--
--	Returns:	  0	success
--			100	release plan not found
--
--	Process:
--	1. Declare all the required local variables.
--	2. Inititialize all variables.
--	3. Purge log table.
--	4. Log purged, indicate in log.
--	5. Get the totcount from the m_in_release_plan table
--	6. If there is data to process, proceed...
--	7. Data found, start processing, indicate in log.
--	8. Get the fiscal year begin date.
--	9. Declare the cusror for processing inbound release plan data.
--	10. Open the cursor.
--	11. Fetch a row of data from the cursor.
--	12. Continue processing as long as more inbound release plan data exists.
--	13. Processing release, indicate in log.
--	14. Find blanket order.
--	15. If order find was successful.
--	16. Get blanket order info:  blanket part, plant, accumulative shipped, packaging_type, box_label, pallet_label.
--	17. If this is a new order, delete old release plan and forecast schedule.
--	18. Deleting release plan.
--	19. Release plan deleted, indicate in log.
--	20. If previous order was valid, calculate committed quantity for the previous order.
--	21. Indicate calculation successful in log.
--	22. Calculation was successful, indicate in log.
--	23. Calculation was unsuccessful, indicate in log
--	24. Assign the prev order no with the current order no, and cumordered with the cumshipped
--	25. Calculate the appropriate releasequantity, cumordered, and newcumordered based on quantityqualifier...
--	26. The quantity value is an accumulative requirement.
--	27. calculate the releasequantity and set the newcumordered.
--	28. The quantity value is a net requirement.
--	29. Calculate the newcumordered and set the releasequantity.
--	30. Calculate standard quantity for release quantity.
--	31. Indicated unsuccessful calculation in log.
--	32. Calculation was unsuccessful, indicate in log
--	33. Determine the validity of the release (releasequantity greater than zero)...
--	34. Release is valid, get the next sequence and rowid for the new release.
--	35. Calculate the week number (from fiscalyearbegin).
--	36. Create release.
--	37. Release was created, indicate in log.
--	38. Set the cumordered to the newcumordered.
--	39. Release was already shipped, indicate in log.
--	40. Determine if exception was multiple orders found.
--	41. Multiple orders found, indicate in log.
--	42. No orders found, indicate in log.
--	43. Record exception data in customer po exceptions.
--	44. Reinitialize order no.
--	45. Fetch a row of data from the cursor 
--	46. If previous order was valid, calculate committed quantity for the previous order.
--	47. Indicate calculation successful in log.
--	48. Calculation was successful, indicate in log.
--	49. Calculation was unsuccessful, indicate in log
--	50. Close the cursor.
--	51. No inbound release plan to process, indicate in log and return rows not found.
--	52. Done processing, indicate in log.
--	53. Remove processed inbound data.
-------------------------------------------------------------------------------------

--	1. Declare all the required local variables.
declare	@returncode		integer,
	@totcount		integer,
	@fiscalyearbegin	datetime,
	@orderno		numeric (8),
	@customerpart		varchar (35),
	@shipto			varchar (20),
	@customerpo		varchar (30),
	@modelyear		varchar (4),
	@releaseno		varchar (30),
	@quantityqualifier	char (1),
	@quantity		numeric (20,6),
	@releasedt		datetime,
	@releasedtqualifier	char (1),
	@blanketpart		varchar (25),
	@plant			varchar (10),
	@prevorderno		numeric (8),
	@cumshipped		numeric (20,6),
	@cumordered		numeric (20,6),
	@newcumordered		numeric (20,6),
	@releasequantity	numeric (20,6),
	@orderunit		char (2),
	@standardquantity	numeric (20,6),
	@sequence		integer,
	@rowid			integer,
	@weekno			integer,
	@packagingtype		varchar (20),
	@boxlabel		varchar (25),
	@palletlabel		varchar (25)

--	2. Inititialize all variables.
select	@totcount = 0,
	@fiscalyearbegin = null,
	@orderno = 0,
	@customerpart = null,
	@shipto = null,
	@customerpo = null,
	@modelyear = null,
	@releaseno = null,
	@quantityqualifier = null,
	@quantity = 0,
	@releasedt = null,
	@releasedtqualifier = null,
	@blanketpart = null,
	@plant = null,
	@prevorderno = 0,
	@cumshipped = 0,
	@cumordered = 0,
	@newcumordered = 0,
	@releasequantity = 0,
	@standardquantity = 0,
	@sequence = 0,
	@rowid = 0,
	@weekno = 0,
	@packagingtype=null,
	@boxlabel=null,
	@palletlabel=null

--	3. Purge log table.
delete	log
 where	spid = @@spid

--	4. Log purged, indicate in log.
insert	log (
		spid,
		id,
		"message" )
select	@@spid,
	(	select	isnull ( max ( id ), 0 ) + 1
		  from	log
		 where	spid = @@spid ),
	'Log purged successfully.'

--	5. Get the totcount from the m_in_release_plan table
select	@totcount = count ( 1 )
  from	m_in_release_plan

--	6. If there is data to process, proceed...
if ( @totcount > 0 )
begin -- (1aB)

--	7. Data found, start processing, indicate in log.
	insert	log (
			spid,
			id,
			"message" )
	select	@@spid,
		(	select	isnull ( max ( id ), 0 ) + 1
			  from	log
			 where	spid = @@spid ),
		'Start processing ' + convert ( varchar ( 20 ), getdate ( ) ) + '.'

--	8. Get the fiscal year begin date.
	select	@fiscalyearbegin = fiscal_year_begin
	  from	parameters

--	9. Declare the cusror for processing inbound release plan data.
	declare	ibcursor cursor for
	select	customer_part,
		shipto_id,
		customer_po,
		model_year,
		release_no,
		quantity_qualifier,
		quantity,
		release_dt,
		release_dt_qualifier
	  from	m_in_release_plan
	order by	1, 2, 3, 4, 8

--	10. Open the cursor.
	  open	ibcursor

--	11. Fetch a row of data from the cursor.
	 fetch	ibcursor
	  into	@customerpart,
		@shipto,
		@customerpo,
		@modelyear,
		@releaseno,
		@quantityqualifier,
		@quantity,
		@releasedt,
		@releasedtqualifier

--	12. Continue processing as long as more inbound release plan data exists.
	while ( @@sqlstatus = 0 )
	begin -- (2B)

--	13. Processing release, indicate in log.
		insert	log (
				spid,
				id,
				"message" )
		select	@@spid,
			(	select	isnull ( max ( id ), 0 ) + 1
				  from	log
				 where	spid = @@spid ),
			'Searching for blanket order for customer part :  (' + @customerpart + ', destination :' + @shipto + ', customer po :' + @customerpo + ' & model year :'+ @modelyear+'.  Processing release #  (' + @releaseno+') due ' + convert ( varchar(20), @releasedt, 113) + '.'

--	14. Find blanket order.
		exec	@returncode = msp_find_blanket_order
				@customerpart,
				@shipto,
				@customerpo,
				@modelyear,
				@orderno output

--	15. If order find was successful.
		if @returncode = 0
		begin -- (3aB)

--	16. Get blanket order info:  blanket part, plant, accumulative shipped.
			select	@blanketpart = blanket_part,
			        	@plant = plant,
			        	@cumshipped = isnull ( our_cum, 0 ),
				@orderunit = shipping_unit,
				@packagingtype=package_type,
				@boxlabel=box_label,
				@palletlabel=pallet_label
			  from	order_header
			 where	order_no = @orderno

--	17. If this is a new order, delete old release plan and forecast schedule.
			if ( @orderno <> isnull ( @prevorderno, 0 ) )
			begin -- (4aB)

--	18. Deleting release plan.
				delete	order_detail
				 where	order_no = @orderno and
			 		type = 'P'

--	19. Release plan deleted, indicate in log.
				insert	log (
						spid,
						id,
						"message" )
				select	@@spid,
					(	select	isnull ( max ( id ), 0 ) + 1
						  from	log
						 where	spid = @@spid ),
					'Deleted old release plan from order detail.'

--	20. If previous order was valid, calculate committed quantity for the previous order.
				if @prevorderno > 0
				begin -- (5B)
					exec	@returncode = msp_calculate_committed_qty
								@prevorderno,
								null,
								null

--	21. Indicate calculation successful in log.
					if @returncode = 0

--	22. Calculation was successful, indicate in log.
						insert	log (
								spid,
								id,
								"message" )
						select	@@spid,
							(	select	isnull ( max ( id ), 0 ) + 1
								  from	log
								 where	spid = @@spid ),
							'Calculated committed quantity for order:  ' + convert ( char ( 8 ), @prevorderno ) + '.'
					else

--	23. Calculation was unsuccessful, indicate in log
						insert	log (
								spid,
								id,
								"message" )
						select	@@spid,
							(	select	isnull ( max ( id ), 0 ) + 1
								  from	log
								 where	spid = @@spid ),
							'Failed to calculated committed quantity for order:  ' + convert ( char ( 8 ), @prevorderno ) + '.  Order not found.'
				end -- (5B)
					
--	24. Assign the prev order no with the current order no, and cumordered with the cumshipped
				select	@prevorderno = @orderno,
					@cumordered = @cumshipped
			end -- (4aB)

--	25. Calculate the appropriate releasequantity, cumordered, and newcumordered based on quantityqualifier...
			if ( @quantityqualifier = 'A' )

--	26. The quantity value is an accumulative requirement.
--	27. calculate the releasequantity and set the newcumordered.
				select	@releasequantity = @quantity - @cumordered,
					@newcumordered = @quantity
			else

--	28. The quantity value is a net requirement.
--	29. Calculate the newcumordered and set the releasequantity.
				select	@newcumordered = @quantity + @cumordered,
					@releasequantity = @quantity

--	30. Calculate standard quantity for release quantity.
				select	@standardquantity = @releasequantity
				exec	@returncode = msp_calculate_std_quantity
						@blanketpart,
						@releasequantity,
						@orderunit

--	31. Indicated unsuccessful calculation in log.
					if @returncode = -1

--	32. Calculation was unsuccessful, indicate in log
						insert	log (
								spid,
								id,
								"message" )
						select	@@spid,
							(	select	isnull ( max ( id ), 0 ) + 1
								  from	log
								 where	spid = @@spid ),
							'Failed to calculated standard quantity for part:  ' + @blanketpart + ' and unit:  ' + @orderunit + '.  Invalid unit for part.'

--	33. Determine the validity of the release (releasequantity greater than zero)...
			if @releasequantity > 0
			begin -- (4bB)

--	34. Release is valid, get the next sequence and rowid for the new release.
				select	@sequence = isnull ( (
						select	max ( sequence )
						  from	order_detail as od
						 where	od.order_no = @orderno 
					 			), 0 ) + 1,
					@rowid = isnull ( (
						select	max ( row_id )
						  from	order_detail as od
						 where	od.order_no = @orderno 
					 			), 0 ) + 1

--	35. Calculate the week number (from fiscalyearbegin).
				select	@weekno = datediff ( dd, @fiscalyearbegin, @releasedt ) / 7 + 1

--	36. Create release.
				insert	order_detail (
						order_no,
						sequence,
						part_number,
						type,
						quantity,
						status,
						notes,
						unit,
						due_date,
						release_no,
						destination,
						customer_part,
						row_id,
						flag,
						ship_type,
						packline_qty,
						plant,
						week_no,
						std_qty,
						our_cum,
						the_cum,
						packaging_type,
						box_label,
						pallet_label
						 )
				values (	@orderno,
						@sequence,
						@blanketpart,
						'P',
						@releasequantity,
						@releasedtqualifier,
						'830-Release created thru stored procedure',
						@orderunit,
						@releasedt,
						@releaseno,
						@shipto,
						@customerpart,
						@rowid,
						1,
						'N',
						0,
						@plant,
						@weekno,
						@standardquantity,
						@cumordered,
						@newcumordered,
						@packagingtype,
						@boxlabel,
						@palletlabel )

--	37. Release was created, indicate in log.
				insert	log (
						spid,
						id,
						"message" )
				select	@@spid,
					(	select	isnull ( max ( id ), 0 ) + 1
						  from	log
						 where	spid = @@spid ),
					'Inserted release for customer part :' + @customerpart+', destination :' + @shipto + ', release date :' + convert( varchar(16), @releasedt ) + ', quantity :' + convert( varchar(20), @releasequantity )

--	38. Set the cumordered to the newcumordered.
				select	@cumordered = @newcumordered
			end -- (4bB)
			else

--	39. Release was already shipped, indicate in log.
				insert	log (
						spid,
						id,
						"message" )
				select	@@spid,
					(	select	isnull ( max ( id ), 0 ) + 1
						  from	log
						 where	spid = @@spid ),
					'Release not saved because quantity ordered has already been shipped.'
		end -- (3aB)
		else
		begin -- (3bB)

--	40. Determine if exception was multiple orders found.
			if @returncode = -1

--	41. Multiple orders found, indicate in log.
				insert	log (
						spid,
						id,
						"message" )
				select	@@spid,
					(	select	isnull ( max ( id ), 0 ) + 1
						  from	log
						 where	spid = @@spid ),
					'Blanket order is not unique for the customer part: ' + @customerpart + ', destination: ' + @shipto + ', customer po: ' + @customerpo + ' & model year: ' + @modelyear + '. create one & then re-process.'

			else

--	42. No orders found, indicate in log.
				insert	log (
						spid,
						id,
						"message" )
				select	@@spid,
					(	select	isnull ( max ( id ), 0 ) + 1
						  from	log
						 where	spid = @@spid ),
					'Blanket order does not exist for the customer part: ' + @customerpart + ', destination: ' + @shipto + ', customer po: ' + @customerpo + ' & model year: ' + @modelyear + '. create one & then re-process.'

--	43. Record exception data in customer po exceptions.
			insert	m_in_release_plan_exceptions (
					logid,
					customer_part,
					shipto_id,
					customer_po,
					model_year,
					release_no,
					quantity_qualifier,
					quantity,
					release_dt_qualifier,
					release_dt )
			select	(	select	isnull ( max ( id ), 0 )
					  from	log
					 where	spid = @@spid ),
				@customerpart,
				@shipto,
				@customerpo,
				@modelyear,
				@releaseno,
				@quantityqualifier,
				@quantity,
				@releasedtqualifier,
				@releasedt
		end -- (3bB)

--	44. Reinitialize order no.
        select	@orderno = 0

--	45. Fetch a row of data from the cursor 
		 fetch	ibcursor
		  into	@customerpart,
			@shipto,
			@customerpo,
			@modelyear,
			@releaseno,
			@quantityqualifier,
			@quantity,
			@releasedt,
			@releasedtqualifier

	end -- (2B)

--	46. If previous order was valid, calculate committed quantity for the previous order.
	if @prevorderno > 0
	begin -- (2bB)
		exec	@returncode = msp_calculate_committed_qty
				@prevorderno,
				null,
				null

--	47. Indicate calculation successful in log.
	if @returncode = 0

--	48. Calculation was successful, indicate in log.
		insert	log (
				spid,
				id,
				"message" )
		select	@@spid,
			(	select	isnull ( max ( id ), 0 ) + 1
				  from	log
				 where	spid = @@spid ),
			'Calculated committed quantity for order:  ' + convert ( char ( 8 ), @prevorderno ) + '.'
	else

--	49. Calculation was unsuccessful, indicate in log
		insert	log (
				spid,
				id,
				"message" )
		select	@@spid,
			(	select	isnull ( max ( id ), 0 ) + 1
				  from	log
				 where	spid = @@spid ),
			'Failed to calculated committed quantity for order:  ' + convert ( char ( 8 ), @prevorderno ) + '.  Order not found.'
	end -- (2bB)

--	50. Close the cursor.
	close	ibcursor

end -- (1aB)
else

--	51. No inbound release plan to process, indicate in log and return rows not found.
begin -- (1bB)
	insert	log (
			spid,
			id,
			"message" )
	select	@@spid,
		(	select	isnull ( max ( id ), 0 ) + 1
			  from	log
			 where	spid = @@spid ),
		'Inbound release plan does not exist.  Check configuration and reprocess.'

	return	100
end -- (1bB)

--	52. Done processing, indicate in log.
insert	log (
		spid,
		id,
		"message" )
select	@@spid,
	(	select	isnull ( max ( id ), 0 ) + 1
		  from	log
		 where	spid = @@spid ),
	'Processing complete.' + convert ( varchar(20), getdate ( ) )

--	53. Remove processed inbound data.
EXECUTE msp_adjust_planning_830
delete	m_in_release_plan
return 0
go

if exists (
	select	*
	  from	sysobjects
	 where	id = object_id ( 'cdisp_process_karmax_830' ) )
	drop procedure	cdisp_process_karmax_830
go


create procedure cdisp_process_karmax_830
as
Begin


BEGIN TRANSACTION
Delete m_in_release_plan
Delete log
COMMIT TRANSACTION


BEGIN TRANSACTION
insert m_in_release_plan
	select 	rtrim(customer_part),
		isNULL(edi_setups.destination, 'No ship to'),
		rtrim(customer_po_lin),
		'',
		rtrim(release_no),
		'N',
		convert(numeric(20,6),isNULL(FST01,'0')),
		'S',
		convert(timestamp,'20' + FST04)
	 FROM  "karmax_830_releases"  LEFT OUTER JOIN "edi_setups"  ON isNULL(rtrim(karmax_830_releases.ship_to_id_2), 'No ship to')+ '*' + isNULL(rtrim(karmax_830_releases.supplier_id), 'No supplier id') = "edi_setups"."parent_destination"  
	 
	                      
COMMIT TRANSACTION

BEGIN TRANSACTION
DELETE m_in_release_plan_exceptions
COMMIT TRANSACTION

begin
execute cdisp_edi_830_cums
end

Begin
execute msp_process_in_release_plan
End



BEGIN TRANSACTION
Insert karmax_830_auth_cums_history
Select * from karmax_830_auth_cums
COMMIT TRANSACTION


BEGIN TRANSACTION
Delete karmax_830_oh_data
COMMIT TRANSACTION

BEGIN TRANSACTION
Update 	order_header
   Set 	fab_cum = convert(numeric (20,6),isNULL(rtrim(fab_auth), '0')),
   	fab_date = convert(date,'20'+ isNULL(rtrim(fab_auth_end_date),'000101')),
   	raw_cum = convert(numeric (20,6),isNULL(rtrim(raw_auth), '0')),
   	raw_date = convert(date,'20'+ isNULL(rtrim(raw_auth_end_date),'000101')),
   	the_cum = convert(numeric(20,6),isNULL(rtrim(prior_cum),'0')),
   	po_expiry_date = convert(date,'20'+ isNULL(rtrim(prior_cum_end_date),'000101')) 
   	
From 	order_header, karmax_830_auth_cums, edi_setups
Where 	order_header.customer_part = rtrim(karmax_830_auth_cums.customer_part) and
        edi_setups.parent_destination = rtrim(karmax_830_auth_cums.ship_to_id_2)+'*'+rtrim(karmax_830_auth_cums.supplier_id) and
        edi_setups.destination = order_header.destination and
        order_header.customer_po = rtrim(karmax_830_auth_cums.customer_po_lin)

COMMIT TRANSACTION

BEGIN TRANSACTION
Update 	order_header
   Set 	shipped = convert(numeric (20,6),isNULL(rtrim(cytd), '0')),
   	due_date = convert(date,'20'+ isNULL(rtrim(cytd_end_date),'000101'))
   	   	
From 	order_header, karmax_830_shipments, edi_setups
Where 	order_header.customer_part = rtrim(karmax_830_shipments.customer_part) and
        edi_setups.parent_destination = rtrim(karmax_830_shipments.ship_to_id_2)+'*'+rtrim(karmax_830_shipments.supplier_id) and
        edi_setups.destination = order_header.destination and
        order_header.customer_po = rtrim(karmax_830_shipments.customer_po_lin)

COMMIT TRANSACTION


BEGIN TRANSACTION

Insert	edi_830_cums
Select	order_header.customer_part,
	order_header.destination,
	order_header.customer_po,
	the_cum - (shipped-our_cum),
	our_cum
From	order_header, karmax_830_auth_cums, edi_setups
Where 	order_header.customer_part = rtrim(karmax_830_auth_cums.customer_part) and
        edi_setups.parent_destination = rtrim(karmax_830_auth_cums.ship_to_id_2)+'*'+rtrim(karmax_830_auth_cums.supplier_id) and
        edi_setups.destination = order_header.destination and
        order_header.customer_po = rtrim(karmax_830_auth_cums.customer_po_lin)

COMMIT TRANSACTION

begin
execute cdisp_edi_830_cums
end


/*BEGIN TRANSACTION
Delete karmax_830_auth_cums
COMMIT TRANSACTION*/

BEGIN TRANSACTION
Delete karmax_830_releases
COMMIT TRANSACTION

BEGIN TRANSACTION
Delete karmax_830_shipments
COMMIT TRANSACTION

END


go

if exists (select * from sysobjects where id = object_id('cdisp_edi_830_cums'))
        drop procedure cdisp_edi_830_cums 
go

create procedure cdisp_edi_830_cums as
begin
	/*-------------------------------------------------------------------------------------*/
	/*  This procedure creates/deletes 830 releases from m_in_release_plan based on authorized cum quantities.*/
	/*  Modified:   3/14/02	Andre S. Boulanger and Harish Gubbi */
	/*  Returns:    0               success*/
	/*              100             ship schedule not found */
	/*-------------------------------------------------------------------------------------*/
	/*  Declare all the required local variables.*/
	declare @totcount integer,
		@min_order_date timestamp,
		@last_order_date timestamp,
		@max_order_date timestamp,
		@due_date timestamp,
		@destination varchar(25),
		@customerpart varchar(35),
		@customercum decimal(20,6),
		@ourcum decimal(20,6),
		@new_quantity decimal(20,6),
		@orderquantity decimal(20,6),
		@customerpo	varchar(25),
		@rcustomerpart varchar(25),
		@rcustomerpo	varchar(25),
		@rreleasedt	datetime,
		@rquantity	decimal(20,6),
		@diffquantity	decimal(20,6),
		@rshiptoid	varchar(20)
  
	/*  Purge log table.*/
	begin transaction
	delete from log
	where spid=@@spid
	
	/*  Log purged, indicate in log.*/
	insert into log
	select @@spid,
	(select IsNull(Max(id),0)+1
	from log
	where spid=@@spid),'Log purged successfully.'
	
	/*  Get the totcount from the edi_830_cums TABLE*/
	select @totcount=Count(1)
	from edi_830_cums
	/*  If there is data to process, proceed...*/
	if(@totcount>0)
	begin /* (2B)*/
		/*  Data found, start processing, indicate in log.*/
		insert into log
		select @@spid,
		(select IsNull(Max(id),0)+1
		from log
		where spid=@@spid),'Start processing '+convert(varchar(20),GetDate())+'.'
		
		/*  Declare the cusror for processing inbound ship schedule data.*/
		declare cumcursor CURSOR for 
		select 	customer_part,
			destination,
			customer_po,
			IsNull(customer_cum,0),
			IsNull(our_cum,0)
		from	edi_830_cums
		where	customer_cum<>our_cum 
		order by 1 asc,2 asc, 3 asc
		
		/*  Open the cursor.*/
		open cumcursor
		
		/*  Fetch a row of data from the cursor.*/
		fetch	cumcursor into 
			@customerpart,
			@destination,
			@customerpo,
			@customercum,
			@ourcum
		
		/*  Continue processing as long as more inbound ship schedule data exists.*/
		while(@@SQLSTATUS = 0)
		begin /* (3B)*/
		Print @customerpart
			if @customercum>@ourcum
			begin /* (4aB)*/
				select @min_order_date=null
				
				select	@min_order_date=Min(m_in_release_plan.release_dt)
				from	m_in_release_plan
				where	m_in_release_plan.shipto_id=@destination
					and m_in_release_plan.customer_part=@customerpart
					and m_in_release_plan.customer_po=@customerpo  
                          
				update	m_in_release_plan 
				set	quantity=quantity+(@customercum-@ourcum)
				from	m_in_release_plan
				where	m_in_release_plan.shipto_id=@destination
					and m_in_release_plan.customer_part=@customerpart
					and m_in_release_plan.release_dt=@min_order_date
					and m_in_release_plan.customer_po=@customerpo
            		end /* (4aB)*/
          		else 
			begin /* (4bB)*/
            
				select	@diffquantity = @ourcum - @customercum
				
				declare releasecursor CURSOR for 
				select	customer_part,
					shipto_id,
					customer_po,
					release_dt,
					quantity
				from	m_in_release_plan
				where	customer_part = @customerpart and
					shipto_id = @destination and
					customer_po = @customerpo 
				order by 1 asc,2 asc, 3 asc, 4 asc
		
				/*  Open the cursor.*/
				open releasecursor
				
				/*  Fetch a row of data from the cursor.*/
				fetch	releasecursor into 
					@rcustomerpart,
					@rshiptoid,
					@rcustomerpo,
					@rreleasedt,
					@rquantity
		
				/*  Continue processing as long as more inbound ship schedule data exists.*/
				while(@@SQLSTATUS = 0) and @diffquantity > 0
				begin
				print convert(varchar,@diffquantity)+ ' ' + convert(varchar,@rquantity) 
					if @rquantity <= @diffquantity 
					begin
						delete	m_in_release_plan
						where	m_in_release_plan.customer_part=@rcustomerpart and
							m_in_release_plan.shipto_id=@rshiptoid and
							m_in_release_plan.customer_po=@rcustomerpo and
							m_in_release_plan.release_dt=@rreleasedt
						select	@diffquantity = @diffquantity - @rquantity
					end		
					else
					begin
						update	m_in_release_plan
						set	quantity = quantity - @diffquantity
						where	m_in_release_plan.customer_part=@rcustomerpart and
							m_in_release_plan.shipto_id=@rshiptoid and
							m_in_release_plan.customer_po=@rcustomerpo and
							m_in_release_plan.release_dt=@rreleasedt
						select	@diffquantity = @diffquantity - @rquantity
					end		

					/*  Fetch a row of data from the cursor.*/
					fetch	releasecursor into 
						@rcustomerpart,
						@rshiptoid,
						@rcustomerpo,
						@rreleasedt,
						@rquantity
				end       		     
				close	releasecursor
			end /* (4bB) */				
			fetch	cumcursor into 
				@customerpart,
				@destination,
				@customerpo,
				@customercum,
				@ourcum

		end /* ( 3B )*/
      		close cumcursor
	end /* (2B)*/
	insert into log
	select @@spid,
	(select IsNull(Max(id),0)+1
	from log
	where spid=@@spid),'Finished.'
	delete from edi_830_cums
	commit transaction
end -- (1B)

go

if exists (select * from sysobjects where id = object_id('cdisp_edi_862_cums'))
        drop procedure cdisp_edi_862_cums 
go

create procedure cdisp_edi_862_cums as
begin
	/*-------------------------------------------------------------------------------------*/
	/*  This procedure creates/deletes 862 releases from m_in_release_plan based on authorized cum quantities.*/
	/*  Modified:   3/14/02	Andre S. Boulanger and Harish Gubbi */
	/*  Returns:    0               success*/
	/*              100             ship schedule not found */
	/*-------------------------------------------------------------------------------------*/
	/*  Declare all the required local variables.*/
	declare @totcount integer,
		@min_order_date timestamp,
		@last_order_date timestamp,
		@max_order_date timestamp,
		@due_date timestamp,
		@destination varchar(25),
		@customerpart varchar(35),
		@customercum decimal(20,6),
		@ourcum decimal(20,6),
		@new_quantity decimal(20,6),
		@orderquantity decimal(20,6),
		@customerpo	varchar(25),
		@rcustomerpart varchar(25),
		@rcustomerpo	varchar(25),
		@rreleasedt	datetime,
		@rquantity	decimal(20,6),
		@diffquantity	decimal(20,6),
		@rshiptoid	varchar(20)
  
	/*  Purge log table.*/
	begin transaction
	delete from log
	where spid=@@spid
	
	/*  Log purged, indicate in log.*/
	insert into log
	select @@spid,
	(select IsNull(Max(id),0)+1
	from log
	where spid=@@spid),'Log purged successfully.'
	
	/*  Get the totcount from the edi_862_cums TABLE*/
	select @totcount=Count(1)
	from edi_862_cums
	/*  If there is data to process, proceed...*/
	if(@totcount>0)
	begin /* (2B)*/
		/*  Data found, start processing, indicate in log.*/
		insert into log
		select @@spid,
		(select IsNull(Max(id),0)+1
		from log
		where spid=@@spid),'Start processing '+convert(varchar(20),GetDate())+'.'
		
		/*  Declare the cusror for processing inbound ship schedule data.*/
		declare cumcursor CURSOR for 
		select 	customer_part,
			destination,
			customer_po,
			IsNull(customer_cum,0),
			IsNull(our_cum,0)
		from	edi_862_cums
		where	customer_cum<>our_cum 
		order by 1 asc,2 asc, 3 asc
		
		/*  Open the cursor.*/
		open cumcursor
		
		/*  Fetch a row of data from the cursor.*/
		fetch	cumcursor into 
			@customerpart,
			@destination,
			@customerpo,
			@customercum,
			@ourcum
		
		/*  Continue processing as long as more inbound ship schedule data exists.*/
		while(@@SQLSTATUS = 0)
		begin /* (3B)*/
		Print @customerpart
			if @customercum>@ourcum
			begin /* (4aB)*/
				select @min_order_date=null
				
				select	@min_order_date=Min(m_in_ship_schedule.release_dt)
				from	m_in_ship_schedule
				where	m_in_ship_schedule.shipto_id=@destination
					and m_in_ship_schedule.customer_part=@customerpart
					and m_in_ship_schedule.customer_po=@customerpo  
                          
				update	m_in_ship_schedule 
				set	quantity=quantity+(@customercum-@ourcum)
				from	m_in_ship_schedule
				where	m_in_ship_schedule.shipto_id=@destination
					and m_in_ship_schedule.customer_part=@customerpart
					and m_in_ship_schedule.release_dt=@min_order_date
					and m_in_ship_schedule.customer_po=@customerpo
            		end /* (4aB)*/
          		else 
			begin /* (4bB)*/
            
				select	@diffquantity = @ourcum - @customercum
				
				declare releasecursor CURSOR for 
				select	customer_part,
					shipto_id,
					customer_po,
					release_dt,
					quantity
				from	m_in_ship_schedule
				where	customer_part = @customerpart and
					shipto_id = @destination and
					customer_po = @customerpo 
				order by 1 asc,2 asc, 3 asc, 4 asc
		
				/*  Open the cursor.*/
				open releasecursor
				
				/*  Fetch a row of data from the cursor.*/
				fetch	releasecursor into 
					@rcustomerpart,
					@rshiptoid,
					@rcustomerpo,
					@rreleasedt,
					@rquantity
		
				/*  Continue processing as long as more inbound ship schedule data exists.*/
				while(@@SQLSTATUS = 0) and @diffquantity > 0
				begin
				print convert(varchar,@diffquantity)+ ' ' + convert(varchar,@rquantity) 
					if @rquantity <= @diffquantity 
					begin
						delete	m_in_ship_schedule
						where	m_in_ship_schedule.customer_part=@rcustomerpart and
							m_in_ship_schedule.shipto_id=@rshiptoid and
							m_in_ship_schedule.customer_po=@rcustomerpo and
							m_in_ship_schedule.release_dt=@rreleasedt
						select	@diffquantity = @diffquantity - @rquantity
					end		
					else
					begin
						update	m_in_ship_schedule
						set	quantity = quantity - @diffquantity
						where	m_in_ship_schedule.customer_part=@rcustomerpart and
							m_in_ship_schedule.shipto_id=@rshiptoid and
							m_in_ship_schedule.customer_po=@rcustomerpo and
							m_in_ship_schedule.release_dt=@rreleasedt
						select	@diffquantity = @diffquantity - @rquantity
					end		

					/*  Fetch a row of data from the cursor.*/
					fetch	releasecursor into 
						@rcustomerpart,
						@rshiptoid,
						@rcustomerpo,
						@rreleasedt,
						@rquantity
				end       		     
				close	releasecursor
			end /* (4bB) */				
			fetch	cumcursor into 
				@customerpart,
				@destination,
				@customerpo,
				@customercum,
				@ourcum

		end /* ( 3B )*/
      		close cumcursor
	end /* (2B)*/
	insert into log
	select @@spid,
	(select IsNull(Max(id),0)+1
	from log
	where spid=@@spid),'Finished.'
	delete from edi_862_cums
	commit transaction
end -- (1B)

go
if exists (
	select	*
	  from	sysobjects
	 where	id = object_id ( 'cdisp_process_karmax_862' ) )
	drop procedure	cdisp_process_karmax_862
go


create procedure cdisp_process_karmax_862
as
Begin


BEGIN TRANSACTION
Delete m_in_ship_schedule
Delete log
COMMIT TRANSACTION


BEGIN TRANSACTION
insert m_in_ship_schedule
	select 	rtrim(customer_part),
		isNULL(edi_setups.destination, 'No ship to'),
		rtrim(customer_po_lin),
		'',
		rtrim(release_no),
		'N',
		convert(numeric(20,6),isNULL(FST01,'0')),
		'S',
		convert(timestamp,'20' + FST04)
	 FROM  "karmax_862_releases"  LEFT OUTER JOIN "edi_setups"  ON isNULL(rtrim(karmax_862_releases.ship_to), 'No ship to')+ '*' + isNULL(rtrim(karmax_862_releases.supplier_id), 'No supplier id') = "edi_setups"."parent_destination"  
	 
	                      
COMMIT TRANSACTION

BEGIN TRANSACTION
DELETE m_in_ship_schedule_exceptions
COMMIT TRANSACTION

begin
execute cdisp_edi_862_cums
end

Begin
execute msp_process_in_ship_sched
End

BEGIN TRANSACTION
Delete karmax_862_oh_data
COMMIT TRANSACTION


BEGIN TRANSACTION
Update 	order_header
   Set 	shipped = convert(numeric (20,6),isNULL(rtrim(cytd), '0')),
   	due_date = convert(date,'20'+ isNULL(rtrim(cytd_end_date),'000101'))
   	   	
From 	order_header, karmax_862_shipments, edi_setups
Where 	order_header.customer_part = rtrim(karmax_862_shipments.customer_part) and
        edi_setups.parent_destination = rtrim(karmax_862_shipments.ship_to)+'*'+rtrim(karmax_862_shipments.supplier_id) and
        edi_setups.destination = order_header.destination and
        order_header.customer_po = rtrim(karmax_862_shipments.customer_po_lin)

COMMIT TRANSACTION


BEGIN TRANSACTION

Insert	edi_862_cums
Select	order_header.customer_part,
	order_header.destination,
	order_header.customer_po,
	the_cum - (shipped-our_cum),
	our_cum
From	order_header, karmax_862_auth_cums, edi_setups
Where 	order_header.customer_part = rtrim(karmax_862_auth_cums.customer_part) and
        edi_setups.parent_destination = rtrim(karmax_862_auth_cums.ship_to)+'*'+rtrim(karmax_862_auth_cums.supplier_id) and
        edi_setups.destination = order_header.destination and
        order_header.customer_po = rtrim(karmax_862_auth_cums.customer_po_lin)

COMMIT TRANSACTION

begin
execute cdisp_edi_862_cums
end


/*BEGIN TRANSACTION
Delete karmax_862_auth_cums
COMMIT TRANSACTION*/

BEGIN TRANSACTION
Delete karmax_862_releases
COMMIT TRANSACTION

BEGIN TRANSACTION
Delete karmax_862_shipments
COMMIT TRANSACTION

END











