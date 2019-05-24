SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[vw_CAMI_OrderDetail]
as

Select    substring(order_detail.release_no, 1, patindex('%*%', order_detail.release_no)-1) as ReleaseNumber,
        substring(order_detail.release_no, patindex('%*%', order_detail.release_no)+1, 30) as SID,
        order_detail.part_number,
        order_detail.customer_part,
        order_detail.quantity,
        order_detail.due_date
from        order_detail
JOIN        order_header on order_detail.order_no = order_header.order_no
where    release_no like '%*%'  and
        order_header.destination like '%CAMI%'
GO
