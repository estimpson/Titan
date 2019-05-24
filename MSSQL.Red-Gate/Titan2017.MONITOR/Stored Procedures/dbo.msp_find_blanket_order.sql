SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[msp_find_blanket_order] (
	@customerpart	varchar (35),
	@shipto		varchar (20),
	@customerpo	varchar (30) = null,
	@modelyear	varchar (4) = null,
	@orderno	numeric (8) output )
as
---------------------------------------------------------------------------------------
--	This procedure finds a blanket order from customer information.
--
--	Modifications:	10 MAR 1999, Eric E. Stimpson	Original.
--			25 MAY 1999, Eric E. Stimpson	Modified formatting.
--							Changed decimal to numeric.
--
--	Parameters:	@customerpart	mandatory
--			@shipto		mandatory
--			@customerpo	optional
--			@modelyear	optional
--			@orderno	mandatory
--
--	Returns:	  0	success
--			 -1	error occurred (more than one order found)
--			100	order not found
---------------------------------------------------------------------------------------

--	1. Declare all the required local variables.
declare	@ordercount	integer

--	2. Initialize all variables.
select	@ordercount = 0

--	3. Get the number of orders.
select	@ordercount = isnull ( (
		select	count ( 1 )
		  from	order_header oh
			left outer join edi_setups edi on edi.destination = @shipto
		 where	customer_part = @customerpart and
			oh.destination = @shipto and
			( customer_po = @customerpo or
				isnull ( check_po, 'N' ) <> 'Y' ) and
			( model_year = @modelyear or
				isnull ( check_model_year, 'N' ) <> 'Y' ) ), 0 )

--	4. If order count is equal to 0, set orderno to null and return 100 for 
--         "order not found."
if @ordercount = 0
begin -- (1aB)
	select	@orderno = null
	return	100
end -- (1aB)

--	5. If order count is greater than 1, set orderno to null and return -1 
--         for "error occurred."
--	6. Data integrity in order header should prevent this condition.
if @ordercount > 1
begin -- (1bB)
	select	@orderno = null
	return	-1
end -- (1bB)

--	7. order count is equal to 1, set orderno to the order found and return 0 
--         for "success."
select	@orderno = order_no
  from	order_header oh
	join edi_setups edi on edi.destination = @shipto
where	customer_part = @customerpart and
	oh.destination = @shipto and
	( customer_po = @customerpo or
		isnull ( check_po, 'N' ) <> 'Y' ) and
	( model_year = @modelyear or
		isnull ( check_model_year, 'N' ) <> 'Y' )
return	0
GO
