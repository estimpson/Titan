BEGIN
BEGIN TRANSACTION
DELETE Log
COMMIT TRANSACTION

BEGIN TRANSACTION
Delete m_in_ship_schedule
COMMIT TRANSACTION

BEGIN TRANSACTION
insert m_in_release_plan
	select 	rtrim(customer_part),
		isNULL(edi_setups.destination, rtrim(isNULL(textron_830_releases.ship_to, 'No Ship To'))),
		rtrim(customer_po),
		rtrim(model_year),
		rtrim(release_no)+'/'+rtrim(forecast_date),
		'N',
		convert(numeric(20,6),isNULL(QTY0102,'1')),
		'S',
		convert(timestamp,DTM0102)
	 FROM  "textron_830_releases"  LEFT OUTER JOIN "edi_setups"  ON rtrim("textron_830_releases"."ship_to") = "edi_setups"."parent_destination"
	 WHERE trim( textron_830_releases.SCC01) in ('1','4','5') and
	 	trim(DTM0101) = '194'
	                      
COMMIT TRANSACTION

BEGIN TRANSACTION
DELETE m_in_release_plan_exceptions
COMMIT TRANSACTION

BEGIN TRANSACTION
execute msp_process_in_firm_planning
COMMIT TRANSACTION

BEGIN TRANSACTION
Update	order_detail
set	type = 'F'
From	order_detail, textron_830_releases, edi_setups
where	order_detail.customer_part = rtrim(textron_830_releases.customer_part) and
	edi_setups.parent_destination = rtrim(textron_830_releases.ship_to) and
	edi_setups.destination = order_detail.destination and
	convert(date,order_detail.due_date) = convert(date,DTM0102 ) and
	trim(textron_830_releases.SCC01) in('1','5') 
COMMIT TRANSACTION

BEGIN TRANSACTION
Insert textron_830_releases_copy
Select * from textron_830_releases
COMMIT TRANSACTION

BEGIN TRANSACTION
Delete textron_830_releases
COMMIT TRANSACTION

BEGIN TRANSACTION
Update 	order_header
   Set 	dock_code = rtrim(dock_REF_DK),
   	custom03 = rtrim(ecl)   	
From 	order_header, textron_830_oh_data, edi_setups
Where 	order_header.customer_part = rtrim(textron_830_oh_data.customer_part) and
        	edi_setups.parent_destination = rtrim(textron_830_oh_data.ship_to) and
        	edi_setups.destination = order_header.destination 
COMMIT TRANSACTION

BEGIN TRANSACTION
Delete textron_830_oh_data
COMMIT TRANSACTION

BEGIN TRANSACTION
Update 	order_header
   Set 	fab_cum = convert(numeric,rtrim(QTY0102)),
   	fab_date = convert(date,DTM0102)
   	
From 	order_header, textron_830_releases_copy, edi_setups
Where 	order_header.customer_part = rtrim(textron_830_releases_copy.customer_part) and
        	edi_setups.parent_destination = rtrim(textron_830_releases_copy.ship_to) and
        	edi_setups.destination = order_header.destination and
        	trim(textron_830_releases_copy.QTY0101)='3' and
        	trim(textron_830_releases_copy.SCC01)='2'        	

COMMIT TRANSACTION

BEGIN TRANSACTION
Update 	order_header
   Set 	raw_cum = convert(numeric,rtrim(QTY0102)),
   	raw_date = convert(date,DTM0102)
   	
From 	order_header, textron_830_releases_copy, edi_setups
Where 	order_header.customer_part = rtrim(textron_830_releases_copy.customer_part) and
        	edi_setups.parent_destination = rtrim(textron_830_releases_copy.ship_to) and
        	edi_setups.destination = order_header.destination and
        	trim(textron_830_releases_copy.QTY0101)='3' and
        	trim(textron_830_releases_copy.SCC01)='3'        	

COMMIT TRANSACTION


BEGIN TRANSACTION
Insert 	textron_830_cum
Select 	rtrim(ship_to),
	trim(customer_part),
	rtrim(customer_po),
	convert(numeric, QTY0102)
  From	textron_830_releases_copy
  Where   trim(textron_830_releases_copy.QTY0101)='70' and
        	trim(textron_830_releases_copy.DTM0101)='52'
COMMIT TRANSACTION

SELECT DISTINCT "message" from log
   WHERE "message" like 'Blanket order does%'
END




