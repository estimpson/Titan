SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[cdisp_edi_830_cums] as
begin
	/*-------------------------------------------------------------------------------------*/
	/*  This procedure creates/deletes 830 releases from m_in_release_plan based on authorized cum quantities.*/
	/*  Modified:   3/14/02	Andre S. Boulanger and Harish Gubbi */
	/*  Returns:    0               success*/
	/*              100             ship schedule not found */
	/*-------------------------------------------------------------------------------------*/
	/*  Declare all the required local variables.*/
	declare @totcount integer,
		@min_order_date datetime,
		@last_order_date datetime,
		@max_order_date datetime,
		@due_date datetime,
		@destination varchar(25),
		@customerpart varchar(35),
		@customercum decimal(20,6),
		@ourcum decimal(20,6),
		@new_quantity decimal(20,6),
		@orderquantity decimal(20,6),
		@customerpo	varchar(25),
		@rcustomerpart varchar(25),
		@rcustomerpo	varchar(25),
		@rreleasedt	datetime,
		@rquantity	decimal(20,6),
		@diffquantity	decimal(20,6),
		@rshiptoid	varchar(20)
  
	/*  Purge log table.*/
	begin transaction
	delete from log
	where spid=@@spid
	
	/*  Log purged, indicate in log.*/
	insert into log
	select @@spid,
	(select IsNull(Max(id),0)+1
	from log
	where spid=@@spid),'Log purged successfully.'
	
	/*  Get the totcount from the edi_830_cums TABLE*/
	select @totcount=Count(1)
	from edi_830_cums
	/*  If there is data to process, proceed...*/
	if(@totcount>0)
	begin /* (2B)*/
		/*  Data found, start processing, indicate in log.*/
		insert into log
		select @@spid,
		(select IsNull(Max(id),0)+1
		from log
		where spid=@@spid),'Start processing '+convert(varchar(20),GetDate())+'.'
		
		/*  Declare the cusror for processing inbound ship schedule data.*/
		declare cumcursor CURSOR for 
		select 	customer_part,
			destination,
			customer_po,
			IsNull(customer_cum,0),
			IsNull(our_cum,0)
		from	edi_830_cums
		where	customer_cum<>our_cum 
		order by 1 asc,2 asc, 3 asc
		
		/*  Open the cursor.*/
		open cumcursor
		
		/*  Fetch a row of data from the cursor.*/
		fetch	cumcursor into 
			@customerpart,
			@destination,
			@customerpo,
			@customercum,
			@ourcum
		
		/*  Continue processing as long as more inbound ship schedule data exists.*/
		while(@@fetch_status = 0)
		begin /* (3B)*/
		Print @customerpart
			if @customercum>@ourcum
			begin /* (4aB)*/
				select @min_order_date=null
				
				select	@min_order_date=Min(m_in_release_plan.release_dt)
				from	m_in_release_plan
				where	m_in_release_plan.shipto_id=@destination
					and m_in_release_plan.customer_part=@customerpart
					and m_in_release_plan.customer_po=@customerpo  
                          
				update	m_in_release_plan 
				set	quantity=quantity+(@customercum-@ourcum)
				from	m_in_release_plan
				where	m_in_release_plan.shipto_id=@destination
					and m_in_release_plan.customer_part=@customerpart
					and m_in_release_plan.release_dt=@min_order_date
					and m_in_release_plan.customer_po=@customerpo
            		end /* (4aB)*/
          		else 
			begin /* (4bB)*/
            
				select	@diffquantity = @ourcum - @customercum
				
				declare releasecursor CURSOR for 
				select	customer_part,
					shipto_id,
					customer_po,
					release_dt,
					quantity
				from	m_in_release_plan
				where	customer_part = @customerpart and
					shipto_id = @destination and
					customer_po = @customerpo 
				order by 1 asc,2 asc, 3 asc, 4 asc
		
				/*  Open the cursor.*/
				open releasecursor
				
				/*  Fetch a row of data from the cursor.*/
				fetch	releasecursor into 
					@rcustomerpart,
					@rshiptoid,
					@rcustomerpo,
					@rreleasedt,
					@rquantity
		
				/*  Continue processing as long as more inbound ship schedule data exists.*/
				while(@@fetch_status = 0) and @diffquantity > 0
				begin
				print convert(varchar,@diffquantity)+ ' ' + convert(varchar,@rquantity) 
					if @rquantity <= @diffquantity 
					begin
						delete	m_in_release_plan
						where	m_in_release_plan.customer_part=@rcustomerpart and
							m_in_release_plan.shipto_id=@rshiptoid and
							m_in_release_plan.customer_po=@rcustomerpo and
							m_in_release_plan.release_dt=@rreleasedt
						select	@diffquantity = @diffquantity - @rquantity
					end		
					else
					begin
						update	m_in_release_plan
						set	quantity = quantity - @diffquantity
						where	m_in_release_plan.customer_part=@rcustomerpart and
							m_in_release_plan.shipto_id=@rshiptoid and
							m_in_release_plan.customer_po=@rcustomerpo and
							m_in_release_plan.release_dt=@rreleasedt
						select	@diffquantity = @diffquantity - @rquantity
					end		

					/*  Fetch a row of data from the cursor.*/
					fetch	releasecursor into 
						@rcustomerpart,
						@rshiptoid,
						@rcustomerpo,
						@rreleasedt,
						@rquantity
				end       		     
				close	releasecursor
				deallocate releasecursor
			end /* (4bB) */				
			fetch	cumcursor into 
				@customerpart,
				@destination,
				@customerpo,
				@customercum,
				@ourcum

		end /* ( 3B )*/
      		close cumcursor
      		deallocate cumcursor
	end /* (2B)*/
	insert into log
	select @@spid,
	(select IsNull(Max(id),0)+1
	from log
	where spid=@@spid),'Finished.'
	delete from edi_830_cums
	commit transaction
end -- (1B)


GO
