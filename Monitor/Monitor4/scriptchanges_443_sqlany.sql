--**********************************************************************************
--Procedure   : msp_checkshipper(shipper long) returns long 
--Description : procedure to check the following
--              whether the customer status is approved or not
--              whether the shipper is staged or not
--              whether the packing list has been printed or not
--              whether the shipper is closed by any other user or not
--              whether the bol is applicable & has been printed or not
--Argument    : Receives shipper number (Long)
--Return value:   0 - is success
--              100 - is not found
--               -1 - customer status is not 'A'
--               -2 - shipper is closed 
--               -3 - shipper status is not 'S'
--               -4 - packlist not printed
--               -5 - bill of lading not printed
--Log changes : gph on 3/23/99 11:08 am original
--**********************************************************************************
if exists(select 1 from sysobjects where name='msp_checkshipper' and type ='P')
   drop procedure msp_checkshipper
go
create procedure msp_checkshipper (@shipper integer, @returnvalue integer OUTPUT) as
begin -- (1b)
  declare @bol_number  integer,
          @customerstatus char(1),
          @shipperstatus  char(1),
          @packlistprinted char(1),
          @bolprinted char(1)
  SELECT @returnvalue=0 -- successful status
  -- check for customer status, shipper status, packlist printed
  SELECT @customerstatus=status_type, 
         @shipperstatus=status, 
         @packlistprinted=printed, 
         @bol_number=bill_of_lading_number
    FROM customer_service_status as a, shipper as b
   WHERE (a.status_name = b.cs_status and b.id = @shipper)
  if (@@rowcount > 0)
   if (@customerstatus='A')  -- Check customer status type
    begin -- (3b)
      if (@shipperstatus='S') -- check shipper status 
       begin -- (3.1b) 
         if (@packlistprinted='Y') -- check pack list printed
          begin -- (3.2b) 
            if (@bol_number > 0) -- check the bol number
             begin -- (3.3b)
               SELECT @bolprinted=bill_of_lading.printed  
                 FROM bill_of_lading  
                WHERE (bill_of_lading.bol_number = @bol_number)
               if (@bolprinted<>'Y')   -- check bol printed 
                  SELECT @returnvalue=-5 -- bol not printed
             end -- (3.3e) 
          end -- (3.2e)
         else
           SELECT @returnvalue=-4  -- pack list not printed
       end -- (3.1e) 
      else
       begin -- (3.1.1b)
         if (@shipperstatus in ('C','Z')) -- check whether the shipper is closed
            SELECT @returnvalue=-2 -- shipper is closed by another user
         else 
            SELECT @returnvalue=-3 -- shipper not staged
       end -- (3.1.1e)       
    end -- (3e)
   else
     SELECT @returnvalue = -1 -- customer status is not approved	
  else
    SELECT @returnvalue = 100 -- shipper not found
  select @returnvalue -- return value 
end -- (1e)
go

if exists(select 1 from sysobjects where name = 'cdivw_inv_inquiry')
	drop view cdivw_inv_inquiry
go

create view cdivw_inv_inquiry (	
	invoice_number,   
	id,   
	date_shipped,   
	destination,   
	customer,   
	ship_via,   
	invoice_printed,   
	notes,   
	type,   
	shipping_dock,   
	status,   
	aetc_number,   
	freight_type,   
	printed,   
	bill_of_lading_number,   
	model_year_desc,   
	model_year,   
	location,   
	staged_objs,   
	plant,   
	invoiced,   
	freight,   
	tax_percentage,   
	total_amount,   
	gross_weight,   
	net_weight,   
	tare_weight,   
	responsibility_code,   
	trans_mode,   
	pro_number,   
	time_shipped,   
	truck_number,   
	seal_number,   
	terms,   
	tax_rate,   
	staged_pallets,   
	container_message,   
	picklist_printed,   
	dropship_reconciled,   
	date_stamp,   
	platinum_trx_ctrl_num,   
	posted,   
	scheduled_ship_time, 
	part) as  
select	shipper.invoice_number,   
	shipper.id,   
	shipper.date_shipped,   
	shipper.destination,   
	shipper.customer,   
	shipper.ship_via,   
	shipper.invoice_printed,   
	shipper.notes,   
	shipper.type,   
	shipper.shipping_dock,   
	shipper.status,   
	shipper.aetc_number,   
	shipper.freight_type,   
	shipper.printed,   
	shipper.bill_of_lading_number,   
	shipper.model_year_desc,   
	shipper.model_year,   
	shipper.location,   
	shipper.staged_objs,   
	shipper.plant,   
	shipper.invoiced,   
	shipper.freight,   
	shipper.tax_percentage,   
	shipper.total_amount,   
	shipper.gross_weight,   
	shipper.net_weight,   
	shipper.tare_weight,   
	shipper.responsibility_code,   
	shipper.trans_mode,   
	shipper.pro_number,   
	shipper.time_shipped,   
	shipper.truck_number,   
	shipper.seal_number,   
	shipper.terms,   
	shipper.tax_rate,   
	shipper.staged_pallets,   
	shipper.container_message,   
	shipper.picklist_printed,   
	shipper.dropship_reconciled,   
	shipper.date_stamp,   
	shipper.platinum_trx_ctrl_num,   
	shipper.posted,   
	shipper.scheduled_ship_time,  
	shipper_detail.part_original
from	shipper 
	left outer join shipper_detail on shipper_detail.shipper = shipper.id  
go

if exists(select 1 from sysobjects where name = 'cdisp_gssreport_enhanced')
	drop procedure cdisp_gssreport_enhanced
go
create procedure cdisp_gssreport_enhanced (@destination varchar(10), @mode char(1)=null) as
begin 	
	declare	@part	varchar(25),
		@due	datetime,
		@qty	decimal(20,6),
		@committedqty	decimal(20,6),
		@orderno	numeric(8,0),
		@onhand	decimal(20,6),
		@cpart	varchar(30),
		@customerpo	varchar(30),
		@modelyear	varchar(10),
		@stdate		datetime,
		@rpdue	numeric(20,6),
		@rday1		numeric(20,6),
		@rday2		numeric(20,6),
		@rday3		numeric(20,6),
		@rday4		numeric(20,6),
		@rday5		numeric(20,6),
		@rday6		numeric(20,6),
		@cpdue	numeric(20,6),
		@cday1		numeric(20,6),
		@cday2		numeric(20,6),
		@cday3		numeric(20,6),
		@cday4		numeric(20,6),
		@cday5		numeric(20,6),
		@cday6		numeric(20,6),
		@cnt		integer,
		@sdtstamp	varchar(10),
		@qtyreq		numeric(20,6),
		@multiplier	smallint
		
	create table #ordtemp (
		destination	varchar(10),
		part		varchar(25),
		cpart		varchar(30),
		customerpo	varchar(30),
		modelyear	varchar(10),
		onhand		numeric(20,6),
		rpdue	numeric(20,6),
		rday1		numeric(20,6),
		rday2		numeric(20,6),
		rday3		numeric(20,6),
		rday4		numeric(20,6),
		rday5		numeric(20,6),
		rday6		numeric(20,6),
		cpdue	numeric(20,6),
		cday1		numeric(20,6),
		cday2		numeric(20,6),
		cday3		numeric(20,6),
		cday4		numeric(20,6),
		cday5		numeric(20,6),
		cday6		numeric(20,6))

	select	@stdate = getdate()
	
	If @mode is null
		select	@mode = 'D'
		
	select	@multiplier = 1
	
	if @mode = 'W' or @mode = 'w'
		select	@multiplier = 7
		
	declare	ord_cursor cursor for 
	select	oh.destination,
		od.order_no,
		od.part_number,
		od.due_date, 
		od.customer_part,
		isnull(oh.customer_po,''),
		isnull(oh.model_year,''),
		isnull(sum(od.quantity),0) quantity
	from	order_detail od
		join order_header oh on oh.order_no = od.order_no 
	where	oh.destination = @destination and 
		isnull(oh.status,'O') = 'O' and
		od.due_date < dateadd(dd,(6 * @multiplier),@stdate)
	group by oh.destination, od.order_no, od.part_number, od.due_date, od.customer_part, 
		oh.customer_po, oh.model_year
	order by 1,2,3

	open	ord_cursor
	fetch	ord_cursor into @destination, @orderno, @part, @due, @cpart, @customerpo, @modelyear, @qty
	
	while	(@@sqlstatus=0) 
	begin
	
		select	@rpdue=0, @rday1=0, @rday2=0, @rday3=0, @rday4=0, @rday5=0, @rday6=0,
			@cpdue=0, @cday1=0, @cday2=0, @cday3=0, @cday4=0, @cday5=0, @cday6=0,
			@onhand=0, @cnt=0

		select	@onhand = isnull(sum(quantity),0)
		from	object
		where	part = @part and status = 'A'
		
		if @mode = 'D'
			select	@rpdue	= (case when convert(varchar(10), @due, 111) < convert(varchar(10), @stdate,111) then isnull(@qty,0) else 0 end),
				@rday1	= (case	when convert(varchar(10), @due, 111) = convert(varchar(10), @stdate,111) then isnull(@qty,0)else 0 end),
				@rday2	= (case	when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,(1 * @multiplier),@stdate),111) then isnull(@qty,0) else 0 end),
				@rday3	= (case	when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,(2 * @multiplier),@stdate),111) then isnull(@qty,0) else 0 end),
				@rday4	= (case when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,(3 * @multiplier),@stdate),111) then isnull(@qty,0) else 0 end),
				@rday5	= (case when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,(4 * @multiplier),@stdate),111) then isnull(@qty,0) else 0 end),
				@rday6	= (case when convert(varchar(10), @due, 111) = convert(varchar(10), dateadd(dd,(5 * @multiplier),@stdate),111) then isnull(@qty,0) else 0 end)
		else
			if datepart(wk,@due) < datepart(wk, @stdate) 
				select	@rpdue = isnull(@qty,0)
			else if datepart(wk,@due) = datepart(wk, @stdate) 
				select	@rday1 = isnull(@qty,0)
			else if datepart(wk,@due) = datepart(wk, dateadd(dd,(1 * @multiplier),@stdate))
				select	@rday2 = isnull(@qty,0)
			else if datepart(wk,@due) = datepart(wk, dateadd(dd,(2 * @multiplier),@stdate))
				select	@rday3 = isnull(@qty,0)
			else if datepart(wk,@due) = datepart(wk, dateadd(dd,(3 * @multiplier),@stdate))
				select	@rday4 = isnull(@qty,0)
			else if datepart(wk,@due) = datepart(wk, dateadd(dd,(4 * @multiplier),@stdate))
				select	@rday5 = isnull(@qty,0)
			else if datepart(wk,@due) = datepart(wk, dateadd(dd,(5 * @multiplier),@stdate))
				select	@rday6 = isnull(@qty,0)

		declare sd_cursor cursor for
		select	convert(varchar(10),date_stamp,111), 
			qty_required
		from	shipper_detail
			join shipper on shipper.id = shipper_detail.shipper
		where	order_no=@orderno and
			part=@part and
			shipper.type is null and
			(status='O' or status='A' or status='S')
		
		open	sd_cursor
		fetch	sd_cursor into @sdtstamp, @qtyreq
		
		while	(@@sqlstatus=0)
		begin
			if @mode = 'D'
				select	@cpdue = @cpdue + (case when @sdtstamp < convert(varchar(10), @stdate,111) then @qtyreq else 0 end),
					@cday1 = @cday1 + (case when @sdtstamp = convert(varchar(10), @stdate,111) then @qtyreq else 0 end),
					@cday2 = @cday2 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,(1 * @multiplier),@stdate),111) then @qtyreq else 0 end),
					@cday3 = @cday3 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,(2 * @multiplier),@stdate),111) then @qtyreq else 0 end),
					@cday4 = @cday4 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,(3 * @multiplier),@stdate),111) then @qtyreq else 0 end),
					@cday5 = @cday5 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,(4 * @multiplier),@stdate),111) then @qtyreq else 0 end),
					@cday6 = @cday6 + (case when @sdtstamp = convert(varchar(10), dateadd(dd,(5 * @multiplier),@stdate),111) then @qtyreq else 0 end)
			else
				if datepart(wk,@sdtstamp) < datepart(wk, @stdate) 
					select	@cpdue = isnull(@qtyreq,0)
				else if datepart(wk,@sdtstamp) = datepart(wk, @stdate) 
					select	@cday1 = isnull(@qtyreq,0)
				else if datepart(wk,@sdtstamp) = datepart(wk, dateadd(dd,(1 * @multiplier),@stdate)) 	
					select	@cday2 = isnull(@qtyreq,0)
				else if datepart(wk,@sdtstamp) = datepart(wk, dateadd(dd,(2 * @multiplier),@stdate)) 	
					select	@cday3 = isnull(@qtyreq,0)
				else if datepart(wk,@sdtstamp) = datepart(wk, dateadd(dd,(3 * @multiplier),@stdate)) 	
					select	@cday4 = isnull(@qtyreq,0)
				else if datepart(wk,@sdtstamp) = datepart(wk, dateadd(dd,(4 * @multiplier),@stdate)) 	
					select	@cday5 = isnull(@qtyreq,0)
				else if datepart(wk,@sdtstamp) = datepart(wk, dateadd(dd,(5 * @multiplier),@stdate)) 	
					select	@cday6 = isnull(@qtyreq,0)
		
			fetch	sd_cursor into @sdtstamp, @qtyreq		
		end
		close	sd_cursor
		
		select	@cnt = isnull(count(1),0)
		from	#ordtemp
		where	destination = @destination and
			part	= @part and
			customerpo = @customerpo and
			modelyear = @modelyear
	
		if isnull(@cnt,0)=0 
		begin
			insert	into #ordtemp 
			values	(@destination, @part, @cpart, @customerpo, @modelyear, @onhand,
				@rpdue, @rday1, @rday2, @rday3, @rday4, @rday5, @rday6,
				@cpdue, @cday1, @cday2, @cday3, @cday4, @cday5, @cday6)
		end
		else
		begin
			update	#ordtemp
			set	rpdue	= rpdue + @rpdue,
				rday1	= rday1 + @rday1,
				rday2	= rday2 + @rday2,
				rday3	= rday3 + @rday3,
				rday4	= rday4 + @rday4,
				rday5	= rday5 + @rday5,
				rday6	= rday6 + @rday6,
				cpdue 	= @cpdue,
				cday1	= @cday1,
				cday2	= @cday2,
				cday3	= @cday3,
				cday4	= @cday4,
				cday5	= @cday5,
				cday6	= @cday6
			where	destination = @destination and
				part	= @part and
				customerpo = @customerpo and
				modelyear = @modelyear
		end
		
		fetch	ord_cursor into @destination, @orderno, @part, @due, @cpart, @customerpo, @modelyear, @qty			
	end 
	close	ord_cursor
	
	select	destination, part, cpart, customerpo, modelyear, onhand,
		rpdue, rday1, rday2, rday3, rday4, rday5, rday6,
		cpdue, cday1, cday2, cday3, cday4, cday5, cday6,
		(rpdue - cpdue) dpdue, (rday1 - cday1) dday1, 
		(rday2 - cday2) dday2, (rday3 - cday3) dday3, (rday4 - cday4) dday4, 
		(rday5 - cday5) dday5, (rday6 - cday6) dday6,
		company_name, company_logo		
	from	#ordtemp
		cross join parameters
	order	by 1, 2, 4
end
go

-- at the end
print '
----------------------------
--	Updating the version
---------------------------- 
'
update admin set version = '4.4.3'
go

commit
go
