SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[cdisp_process_karmax_830]
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
		convert(datetime,'20' + FST04)
	 FROM  karmax_830_releases  LEFT OUTER JOIN edi_setups  ON isNULL(rtrim(karmax_830_releases.ship_to_id_2), 'No ship to')+ '*' + isNULL(rtrim(karmax_830_releases.supplier_id), 'No supplier id') = edi_setups.parent_destination  
	 
	                      
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
   	fab_date = convert(datetime,'20'+ isNULL(rtrim(fab_auth_end_date),'000101')),
   	raw_cum = convert(numeric (20,6),isNULL(rtrim(raw_auth), '0')),
   	raw_date = convert(datetime,'20'+ isNULL(rtrim(raw_auth_end_date),'000101')),
   	the_cum = convert(numeric(20,6),isNULL(rtrim(prior_cum),'0')),
   	po_expiry_date = convert(datetime,'20'+ isNULL(rtrim(prior_cum_end_date),'000101')) 
   	
From 	order_header, karmax_830_auth_cums, edi_setups
Where 	order_header.customer_part = rtrim(karmax_830_auth_cums.customer_part) and
        edi_setups.parent_destination = rtrim(karmax_830_auth_cums.ship_to_id_2)+'*'+rtrim(karmax_830_auth_cums.supplier_id) and
        edi_setups.destination = order_header.destination and
        order_header.customer_po = rtrim(karmax_830_auth_cums.customer_po_lin)

COMMIT TRANSACTION

BEGIN TRANSACTION
Update 	order_header
   Set 	shipped = convert(numeric (20,6),isNULL(rtrim(cytd), '0')),
   	due_date = convert(datetime,'20'+ isNULL(rtrim(cytd_end_date),'000101'))
   	   	
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



GO
