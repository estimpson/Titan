SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[cdisp_process_karmax_862]
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
		convert(datetime,'20' + FST04)
	 FROM  karmax_862_releases  LEFT OUTER JOIN edi_setups  ON isNULL(rtrim(karmax_862_releases.ship_to), 'No ship to')+ '*' + isNULL(rtrim(karmax_862_releases.supplier_id), 'No supplier id') = edi_setups.parent_destination  
	 
	                      
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
   	due_date = convert(datetime,'20'+ isNULL(rtrim(cytd_end_date),'000101'))
   	   	
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












GO
