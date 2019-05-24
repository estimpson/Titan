CREATE TABLE [dbo].[po_detail]
(
[po_number] [int] NOT NULL,
[vendor_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[part_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit_of_measure] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_due] [datetime] NOT NULL,
[requisition_number] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_recvd_date] [datetime] NULL,
[last_recvd_amount] [numeric] (20, 6) NULL,
[cross_reference_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [numeric] (20, 6) NULL,
[received] [numeric] (20, 6) NULL,
[balance] [numeric] (20, 6) NULL,
[active_release_cum] [numeric] (20, 6) NULL,
[received_cum] [numeric] (20, 6) NULL,
[price] [numeric] (20, 6) NULL,
[row_id] [numeric] (20, 0) NOT NULL,
[invoice_status] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_date] [datetime] NULL,
[invoice_qty] [numeric] (20, 6) NULL,
[invoice_unit_price] [numeric] (20, 6) NULL,
[RELEASE_NO] [int] NULL,
[ship_to_destination] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[terms] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[week_no] [int] NULL,
[plant] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_number] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[standard_qty] [numeric] (20, 6) NULL,
[sales_order] [int] NULL,
[dropship_oe_row_id] [int] NULL,
[ship_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dropship_shipper] [int] NULL,
[price_unit] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[printed] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[selected_for_print] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deleted] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_via] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[release_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dimension_qty_string] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[taxable] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled_time] [datetime] NULL,
[truck_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[confirm_asn] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job_cost_no] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alternate_price] [numeric] (20, 6) NULL,
[requisition_id] [int] NULL,
[promise_date] [datetime] NULL,
[other_charge] [numeric] (20, 6) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtr_po_detail_d] on [dbo].[po_detail] for delete
as
begin
	declare @requisition_id integer,
		@quantity   	numeric (20,6),
		@received   	numeric (20,6),
		@total_rows 	integer,
		@count      	integer,
		@row_id     	integer,
		@po_number  	integer,
		@part		varchar(25),
		@date_due	datetime,
		@today		datetime
	
	select	@today = GetDate()

	-- get first updated row
	select	@po_number = min(po_number)
	from 	deleted

	-- loop through all updated records
	while ( isnull(@po_number,-1) <> -1 )
	begin

		select	@row_id = min(row_id)
		from	deleted
		where	po_number = @po_number

		while ( isnull(@row_id,-1) <> -1 )
		begin
		
			select	@part = min(part_number)
			from	deleted
			where	po_number = @po_number and
				row_id = @row_id

			while ( isnull(@part,'') > '' )
			begin

				select	@date_due = min(date_due)
				from	deleted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number = @part

				while ( isnull(@date_due,@today) <> @today )
				begin

					select	@requisition_id = requisition_id,
						@quantity = quantity,
						@received = received
					from	deleted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due = @date_due
						
					if @requisition_id > 0 
					begin
					
						if @received <= 0 
						begin
							update 	requisition_detail
							set 	po_number = null,
								status = 'Modified',
							    	status_notes = 'Deleted from PO: ' + convert ( varchar(15), po_number ) + ' on ' + convert ( varchar (20), getdate( ) )
							where	requisition_number = @requisition_id and
								po_rowid = @row_id and
								po_number = @po_number 
						
							update	requisition_header
							set	status = '8'
							where 	requisition_number = @requisition_id
						end
						else if @received >= @quantity
						begin
							update	requisition_detail
							set	status = 'Completed',
								status_notes = 'Completed on ' + + convert ( varchar (20), getdate( ) )
							where	requisition_number = @requisition_id and
								po_rowid = @row_id and
								po_number = @po_number 
						
							select	@total_rows = count(*)
							from	requisition_detail
							where	requisition_number = @requisition_id
						
							select	@count = count(*)
							from	requisition_detail
							where	requisition_number = @requisition_id and
								status = 'Completed'
								
							if @total_rows = @count 
							begin
								update	requisition_header
								set	status = '7',
									status_notes = 'Completed on ' + + convert ( varchar (20), getdate( ) )
								where	requisition_number = @requisition_id
							end
						
						end
					end
					
					select	@date_due = min(date_due)
					from	deleted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due > @date_due

				end

				select	@part = min(part_number)
				from	deleted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number > @part

			end

			select	@row_id = min(row_id)
			from	deleted
			where	po_number = @po_number and
				row_id > @row_id

		end

		select	@po_number = min(po_number)
		from 	deleted
		where	po_number > @po_number

	end

end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtr_po_detail_i] on [dbo].[po_detail] for insert
as
begin
	-- declarations
	declare	@po_number		integer,
		@row_id			numeric(20),
		@part			varchar(25),
		@date_due		datetime,
		@today			datetime

	select	@today = GetDate()

	-- get first updated row
	select	@po_number = min(po_number)
	from 	inserted

	-- loop through all updated records
	while ( isnull(@po_number,-1) <> -1 )
	begin

		select	@row_id = min(row_id)
		from	inserted
		where	po_number = @po_number

		while ( isnull(@row_id,-1) <> -1 )
		begin
		
			select	@part = min(part_number)
			from	inserted
			where	po_number = @po_number and
				row_id = @row_id

			while ( isnull(@part,'') > '' )
			begin

				select	@date_due = min(date_due)
				from	inserted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number = @part

				while ( isnull(@date_due,@today) <> @today )
				begin

					exec msp_calc_po_currency @po_number, null, null, @row_id, @part, @date_due, null

					select	@date_due = min(date_due)
					from	inserted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due > @date_due

				end

				select	@part = min(part_number)
				from	inserted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number > @part

			end

			select	@row_id = min(row_id)
			from	inserted
			where	po_number = @po_number and
				row_id > @row_id

		end

		select	@po_number = min(po_number)
		from 	inserted
		where	po_number > @po_number

	end

end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtr_po_detail_u] on [dbo].[po_detail] for update
as
begin
	-- declarations
	declare	@po_number	integer,
		@row_id		integer,
		@part		varchar(25),
		@date_due	datetime,
		@inserted_ap	numeric(20,6),
		@deleted_ap	numeric(20,6),
		@today		datetime, 
		@release_no	integer,
		@uom		char(2),
		@type		char(1)

	declare	@requisition_id	integer,
		@quantity_old	numeric (20,6),
		@received	numeric (20,6),
		@total_rows	integer,
		@count		integer,
		@received_new	numeric (20,6),
		@part_old	varchar (25),
		@name		varchar (50),
		@quantity_new	numeric (20,6),
		@deleted	varchar (1),
		@vendor_old	varchar (10),
		@vendor_new	varchar (10),
		@price_new	numeric (20,6),
		@price_old	numeric (20,6)

	select	@today = GetDate()

	-- get first updated row
	select	@po_number = min(po_number)
	from 	inserted

	-- loop through all updated records
	while ( isnull(@po_number,-1) <> -1 )
	begin

		select	@row_id = min(row_id)
		from	inserted
		where	po_number = @po_number

		while ( isnull(@row_id,-1) <> -1 )
		begin
		
			select	@part = min(part_number)
			from	inserted
			where	po_number = @po_number and
				row_id = @row_id

			while ( isnull(@part,'') > '' )
			begin

				select	@date_due = min(date_due)
				from	inserted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number = @part

-- from here 11/13/02					
				select	@quantity_new = quantity,
				  	@received_new = received,
					@price_new = price,
					@vendor_new = vendor_code,
					@release_no = release_no,
					@uom = unit_of_measure,
					@type = type
				from	inserted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number = @part and
					date_due = @date_due

				select  @received	= received,
				   	@quantity_old   = quantity
				from	deleted 
				where	po_number = @po_number and
					row_id = @row_id and
					part_number = @part and
					date_due = @date_due

				if (update(received) or update(quantity)) and (@received_new-@received) <> 0 and @quantity_new > 0 
				begin
					insert into cdipohistory 
						(po_number, vendor, part, uom, date_due, type, last_recvd_date, 
						last_recvd_amount, quantity, received, balance,	price, row_id, 
						release_no)
					values	(@po_number, @vendor_new, @part, @uom, @date_due, @type, 
						GetDate(), (@received_new-@received),@quantity_new, @received_new, 
						(@quantity_new - @received_new),@price_new, @row_id, @release_no)
				end
-- till here 11/13/02
					

				while ( isnull(@date_due,@today) <> @today )
				begin

					select	@deleted_ap = alternate_price
					from	deleted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due = @date_due

					select	@inserted_ap = alternate_price,
						@name	     = description,
						@quantity_new = quantity,
					  	@received_new = received,
						@deleted  = deleted,
						@price_new = price
					from	inserted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due = @date_due

					select @deleted_ap = isnull(@deleted_ap,0)
					select @inserted_ap = isnull(@inserted_ap,0)

					if @inserted_ap <> @deleted_ap
						exec msp_calc_po_currency @po_number, null, null, @row_id, @part, @date_due, null

					select  @part_old = part_number,
						@requisition_id = requisition_id,
						@received	= received,
					   	@quantity_old   = quantity,
						@price_old	= price
					from	deleted 
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due = @date_due

					if @requisition_id > 0 
					begin
						if @part_old <> @part
						begin
							update requisition_detail
							set part_number = @part,
							    description = @name,
							    status = 'Modified',	
							    status_notes = 'Modified part number from ' + @part_old  + ' to new part number: ' + @part + ' on ' + convert ( varchar (20), getdate( ) )
							where requisition_number = @requisition_id
							and   po_rowid = @row_id 	
							and   po_number = @po_number 

							update requisition_header
							set status = '8',
							    status_notes = 'Modified part number on detail item on :' + convert ( varchar (20), getdate( ) )
							where requisition_number = @requisition_id
						end
						else if @part_old = @part
						begin

							-- check if received quantity was changed or not 
							if @received_new > 0 and @received_new >= @quantity_new
							begin
								update requisition_detail
								set status = 'Completed',
							        status_notes = 'Completed on ' + convert ( varchar (20), getdate( ) )
								where requisition_number = @requisition_id
								and   po_rowid = @row_id 
								and   po_number = @po_number 

								select @total_rows = count(*)
								from  requisition_detail
								where requisition_number = @requisition_id 

								select @count = count(*)
								from  requisition_detail
								where requisition_number = @requisition_id
								and status = 'Completed'
			
								if @total_rows = @count 
								begin
									update requisition_header
									set status = '7',
									    status_notes = 'Completed on ' + + convert ( varchar (20), getdate( ) )
									where requisition_number = @requisition_id
						    		end	
							end

							-- check if quantity was changed or not 
							else if @quantity_old <> @quantity_new
								update requisition_detail
								set quantity = @quantity_new,
								    status = 'Modified',	
								    status_notes = 'Modified quantity from ' + convert ( varchar (20), @quantity_old)  + ' to quantity: ' + convert ( varchar (20), @quantity_new ) + ' on ' + convert ( varchar (20), getdate( ) )
								where requisition_number = @requisition_id
								and   po_rowid = @row_id 
								and   po_number = @po_number 

							-- check if item marked for deletion 
							else if @deleted = 'Y' 	
							begin
								update requisition_detail
								set po_number = null,
								    status = 'Modified',
								    status_notes = 'Deleted from PO: ' + convert ( varchar(15), po_number ) + ' on ' + convert ( varchar (20), getdate( ) )
							        where requisition_number = @requisition_id
								and   po_rowid = @row_id 
								and   po_number = @po_number 

								update requisition_header
								set status = '8',
							        status_notes = 'Modified part number on detail item on :' + convert ( varchar (20), getdate( ) )
								where requisition_number = @requisition_id
							end
						end
						else if @price_old <> @price_new
							update requisition_detail
							set unit_cost = @price_new
						        where requisition_number = @requisition_id
							and   po_rowid = @row_id 
							and   po_number = @po_number 
					end
					
					select	@date_due = min(date_due)
					from	inserted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due > @date_due

				end

				select	@part = min(part_number)
				from	inserted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number > @part

			end

			select	@row_id = min(row_id)
			from	inserted
			where	po_number = @po_number and
				row_id > @row_id

		end

		select	@po_number = min(po_number)
		from 	inserted
		where	po_number > @po_number

	end

end
GO
ALTER TABLE [dbo].[po_detail] ADD CONSTRAINT [PK_po_detail] PRIMARY KEY CLUSTERED  ([po_number], [part_number], [date_due], [row_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [podpart] ON [dbo].[po_detail] ([part_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[po_detail] ADD CONSTRAINT [fk_po_detail1] FOREIGN KEY ([po_number]) REFERENCES [dbo].[po_header] ([po_number])
GO
