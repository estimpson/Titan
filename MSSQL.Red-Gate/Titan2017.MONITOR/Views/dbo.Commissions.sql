SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[Commissions](customer_part,salesrep, name ,commission_rate) as select order_header.customer_part,salesrep.salesrep,salesrep. name ,salesrep.commission_rate from order_header,.salesrep where(order_header.salesman=salesrep.salesrep)
GO
