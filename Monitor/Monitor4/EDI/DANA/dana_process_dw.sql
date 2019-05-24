BEGIN
BEGIN TRANSACTION
DELETE Log
COMMIT TRANSACTION

BEGIN TRANSACTION
Delete m_in_release_plan
COMMIT TRANSACTION

BEGIN TRANSACTION
insert m_in_release_plan
	select 	rtrim(customer_part),
		edi_setups.destination,
		rtrim(customer_po),
		rtrim(model_year),
		rtrim(release_no),
		'N',
		convert(numeric(20,6),FST01),
		'S',
		convert(datetime,(CASE WHEN convert(tinyint,left(FST04,2))<97  THEN '20' + FST04
                         			 ELSE '19' + FST04 
				END ))
	from	edi_830_releases, edi_setups
	where	rtrim(edi_830_releases.ship_to) = edi_setups.parent_destination and
		rtrim(edi_830_releases.supplier) = edi_setups.supplier_code
	                      
COMMIT TRANSACTION

BEGIN TRANSACTION
execute msp_process_in_release_plan_formet
COMMIT TRANSACTION


BEGIN TRANSACTION
Update 	order_header
   Set 	dock_code = rtrim(dock_REF_DK),
   	line_feed_code = rtrim(line_feed_REF_LF),
   	zone_code = rtrim(res_line_feed_REF_RL)
From 	order_header, edi_830_oh_data, edi_setups
Where 	order_header.customer_part = rtrim(edi_830_oh_data.customer_part) and
        edi_setups.parent_destination = rtrim(edi_830_oh_data.ship_to) and
        edi_setups.destination = order_header.destination and
        edi_setups.supplier_code = rtrim(edi_830_oh_data.supplier)
COMMIT TRANSACTION

BEGIN TRANSACTION
Update 	order_header
   Set 	fab_cum = rtrim(auth_qty1),
   	fab_date = convert(datetime,(CASE WHEN convert(tinyint,left(auth_date1,2))<97  THEN '20' + auth_date1
                         			 ELSE '19' + auth_date1 
						END ))
   	
From 	order_header, edi_830_auth2, edi_setups
Where 	order_header.customer_part = rtrim(edi_830_auth2.customer_part) and
        edi_setups.parent_destination = rtrim(edi_830_auth2.ship_to) and
        edi_setups.destination = order_header.destination and
        edi_setups.supplier_code = rtrim(edi_830_auth2.supplier) and
        rtrim( edi_830_auth2.auth_type) = 'MI'

COMMIT TRANSACTION

BEGIN TRANSACTION
Update 	order_header
   Set 	raw_cum = rtrim(auth_qty1),
   	raw_date = convert(datetime,(CASE WHEN convert(tinyint,left(auth_date1,2))<97  THEN '20' + auth_date1
                         			 ELSE '19' + auth_date1 
						END ))
From 	order_header, edi_830_auth2, edi_setups
Where 	order_header.customer_part = rtrim(edi_830_auth2.customer_part) and
        edi_setups.parent_destination = rtrim(edi_830_auth2.ship_to) and
        edi_setups.destination = order_header.destination and
        edi_setups.supplier_code = rtrim(edi_830_auth2.supplier) and
        rtrim( edi_830_auth2.auth_type) = 'MT'

COMMIT TRANSACTION

BEGIN TRANSACTION
DELETE	edi_830_oh_data
COMMIT TRANSACTION

BEGIN TRANSACTION
Insert 	edi_830_auth_history2
Select 	*
  From	edi_830_auth2
COMMIT TRANSACTION

BEGIN TRANSACTION
DELETE edi_830_auth2
COMMIT TRANSACTION

BEGIN TRANSACTION
Update	order_detail
set	type = 'F'
From	order_detail, edi_830_releases, edi_setups
where	order_detail.customer_part = rtrim(edi_830_releases.customer_part) and
	edi_setups.parent_destination = rtrim(edi_830_releases.ship_to) and
	edi_setups.destination = order_detail.destination and
	edi_setups.supplier_code = rtrim(edi_830_releases.supplier) and
	convert(datetime,order_detail.due_date) = convert(datetime,(CASE WHEN convert(tinyint,left(FST04,2))<97  THEN '20' + FST04
                         			 ELSE '19' + FST04 
						END )) and
	rtrim(edi_830_releases.FST02) = 'C'
COMMIT TRANSACTION

BEGIN TRANSACTION
Delete edi_830_releases
COMMIT TRANSACTION


SELECT DISTINCT "message" from log
   WHERE "message" like 'Blanket order does%'
END






