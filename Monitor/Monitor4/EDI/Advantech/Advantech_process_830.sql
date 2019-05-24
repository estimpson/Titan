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
		rtrim(release_no)+ '-' + rtrim(po_line),
		'N',
		convert(numeric(20,6),FST01),
		'S',
		convert(timestamp,(CASE WHEN convert(tinyint,left(FST04,2))<97  THEN '20' + FST04
                         			 ELSE '19' + FST04 
				END ))
	from	adv_edi_830_releases_f, edi_setups
	where	rtrim(adv_edi_830_releases_f.ship_to) = edi_setups.parent_destination
	                      
COMMIT TRANSACTION

BEGIN TRANSACTION
insert m_in_release_plan
	select 	rtrim(customer_part),
		edi_setups.destination,
		rtrim(customer_po),
		rtrim(model_year),
		rtrim(release_no)+ '-' + rtrim(po_line),
		'N',
		convert(numeric(20,6),FST01),
		'S',
		convert(timestamp,(CASE WHEN convert(tinyint,left(FST04,2))<97  THEN '20' + FST04
                         			 ELSE '19' + FST04 
				END ))
	from	adv_edi_830_releases_p, edi_setups
	where	rtrim(adv_edi_830_releases_p.ship_to) = edi_setups.parent_destination
	                      
COMMIT TRANSACTION

BEGIN TRANSACTION
execute msp_process_in_release_plan_adv
COMMIT TRANSACTION



BEGIN TRANSACTION
Update 	order_header
   Set 	fab_cum = rtrim(fab_auth),
   	raw_cum = rtrim(raw_auth),
   	fab_date = convert(date,(CASE WHEN convert(tinyint,left(fab_start_date,2))<97  THEN '20' + fab_start_date
                         			 ELSE '19' + fab_start_date 
						END )),
   	raw_date = convert(date,(CASE WHEN convert(tinyint,left(raw_start_date,2))<97  THEN '20' + raw_start_date
                         			 ELSE '19' + raw_start_date 
						END ))
From 	order_header, adv_edi_830_auth, edi_setups
Where 	order_header.customer_part = rtrim(adv_edi_830_auth.customer_part) and
        edi_setups.parent_destination = rtrim(adv_edi_830_auth.ship_to) and
        edi_setups.destination = order_header.destination

COMMIT TRANSACTION

BEGIN TRANSACTION
DELETE	adv_edi_830_oh_data
COMMIT TRANSACTION

BEGIN TRANSACTION
Insert 	adv_edi_830_auth_history
Select 	*
  From	adv_edi_830_auth
COMMIT TRANSACTION

BEGIN TRANSACTION
DELETE adv_edi_830_auth
COMMIT TRANSACTION

BEGIN TRANSACTION
Update	order_detail
set	type = 'F'
From	order_detail, adv_edi_830_releases_f, edi_setups
where	order_detail.customer_part = rtrim(adv_edi_830_releases_f.customer_part) and
	edi_setups.parent_destination = rtrim(adv_edi_830_releases_f.ship_to) and
	edi_setups.destination = order_detail.destination and
	convert(date,order_detail.due_date) = convert(date,(CASE WHEN convert(tinyint,left(FST04,2))<97  THEN '20' + FST04
                         			 ELSE '19' + FST04 
						END )) 
COMMIT TRANSACTION

BEGIN TRANSACTION
Delete adv_edi_830_releases_f
Delete adv_edi_830_releases_p
COMMIT TRANSACTION


SELECT DISTINCT "message" from log
   WHERE "message" like 'Blanket order does%'
END




