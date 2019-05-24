SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[Test](customer_part,salesman,salesrep, name ,commission_rate) as select order_header.customer_part,order_header.salesman,salesrep.salesrep,salesrep. name ,salesrep.commission_rate from order_header,.salesrep where(order_header.salesman=salesrep.salesrep)
GO
