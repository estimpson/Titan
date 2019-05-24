SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[cdisp_getcshippers] (@stdate datetime, @eddate datetime=null, @operator varchar(5)=null) as
begin -- 1b
	declare	@sstdate varchar(20),
		@seddate varchar(20),
		@shipper integer
		
	if @eddate is null 
		select	@eddate = getdate()
	if @operator is null
		select	@operator = 'Mon'
	
	select	@sstdate = convert(varchar(10),@stdate,111)+ ' 00:00:00', 
		@seddate = convert(varchar(10),@eddate,111)+ ' 23:23:59'
		
	select	@stdate = convert(datetime, @sstdate),
		@eddate = convert(datetime, @seddate)	

	--	Declare the required cursor 
	declare shipperlist cursor for 
	select 	id
	from 	shipper
	where	date_shipped >= @stdate and date_shipped <= @eddate and 
		(status = 'C' or status = 'Z') and
		invoice_number > 0 and isnull(responsibility_code,'N') = 'N'

	--	Open cursor
	open	shipperlist
	
	--	Fetch the data row by row
	fetch	shipperlist into @shipper

	--	Check for sqlstatus, as long as it's valid process the rows
	while ( @@fetch_status = 0 )
	begin -- 2b

		execute cdisp_updpkginv @shipper, @operator
		
		-- 	Fetch next set of rows
		fetch	shipperlist into @shipper

		begin tran		
		update	shipper
		set	responsibility_code = 'Y'
		where	id = @shipper
		commit tran
		
	end -- 2e
		
	--	Close cursor
	close shipperlist
	deallocate shipperlist

end -- 1e
GO
