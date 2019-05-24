SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



                                                                                                                             
                                                                                                                                       
                                                                                                                                              
--use FX                                                                                                                                      
--go                                                                                                                                          
                                                                                                                                              
--if	objectproperty(object_id('dbo.usp_Shipping_ShipoutReleiveOrders'), 'IsProcedure') = 1 begin                                             
--	drop procedure dbo.usp_Shipping_ShipoutReleiveOrders                                                                                      
--end                                                                                                                                         
--go                                                                                                                                          
                                                                                                                                              
--create procedure dbo.usp_Shipping_ShipoutReleiveOrders                                                                                      
CREATE procedure [dbo].[usp_Shipping_ShipoutCaptureDiscretePOs]                                                                                     
	@ShipperID integer                                                                                                                          
,	@TranDT datetime = null out                                                                                                                 
,	@Result integer = null out                                                                                                                  
,	@Debug integer = 1                                                                                                                          
as                                                                                                                                            
set nocount on                                                                                                                                
set ansi_warnings off                                                                                                                         
set	@Result = 999999                                                                                                                          
                                                                                                                                              
--- <Error Handling>                                                                                                                          
declare                                                                                                                                       
	@CallProcName sysname,                                                                                                                      
	@TableName sysname,                                                                                                                         
	@ProcName sysname,                                                                                                                          
	@ProcReturn integer,                                                                                                                        
	@ProcResult integer,                                                                                                                        
	@Error integer,                                                                                                                             
	@RowCount integer                                                                                                                           
                                                                                                                                              
set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. dbo.usp_Test                            
--- </Error Handling>                                                                                                                         
                                                                                                                                              
--- <Tran Required=Yes AutoCreate=Yes TranDTParm=Yes>                                                                                         
declare                                                                                                                                       
	@TranCount smallint                                                                                                                         
                                                                                                                                              
set	@TranCount = @@TranCount                                                                                                                  
if	@TranCount = 0 begin                                                                                                                      
	begin tran @ProcName                                                                                                                        
end                                                                                                                                           
else begin                                                                                                                                    
	save tran @ProcName                                                                                                                         
end                                                                                                                                           
set	@TranDT = coalesce(@TranDT, GetDate())                                                                                                    
--- </Tran>                                                                                                                                   
                                                                                                                                              
                                                                                 
create table                                                                                                                                  
	#shipmentSummary                                                                                                                            
(	ShipTo varchar(25)                                                                                                                          
,	CustomerPart varchar(30)                                                                                                                    
,	QtyPacked numeric(20,6)                                                                                                                     
,	ActiveOrderNo numeric(8,0)                                                                                                                  
,	primary key                                                                                                                                 
	(	ShipTo                                                                                                                                    
	,	CustomerPart                                                                                                                              
	)                                                                                                                                           
)                                                                                                                                             
                                                                                                                                              
insert                                                                                                                                        
	#shipmentSummary                                                                                                                            
(	ShipTo                                                                                                                                      
,	CustomerPart                                                                                                                                
,	QtyPacked                                                                                                                                   
,	ActiveOrderNo                                                                                                                               
)                                                                                                                                             
select                                                                                                                                        
	ShipTo = s.destination                                                                                                                      
,	CustomerPart = sd.customer_part                                                                                                             
,	QtyPacked = sum(sd.qty_packed)                                                                                                            
,	ActiveOrderNo = max(coalesce(sd.order_no,0))                                                                               
from                                                                                                                                          
	dbo.shipper_detail sd                                                                                                                       
		join dbo.shipper s                                                                                                                        
			on s.id = sd.shipper                                                                                                                    
		join dbo.order_header ohGSS                                                                                                               
			on sd.order_no = ohGSS.order_no                                                                                                                                                        
		and ohGSS.order_type = 'B'                                                                                                                
where                                                                                                                                         
	sd.shipper = @ShipperID                                                                                                                     
group by                                                                                                                                      
	s.destination                                                                                                                               
,	sd.customer_part                                                                                                                            
                                                                                                                                              
if	@Debug = 1 begin                                                                                                                          
	select                                                                                                                                      
		*                                                                                                                                         
	from                                                                                                                                        
		#shipmentSummary                                                                                                                          
end                                                                                                                                           
                                                                                                                                              
/*	Caculate requirements summarized by Active Order, Release Date, Release No.                                                               
	                                                                                                                                            
	Get all requirements for alternate orders unless this was an order for prototypes,                                                          
	orders that don't have an "Active" order, or normal orders.                                                                                 
*/                                                                                                                                            
create table                                                                                                                                  
	#requirements                                                                                                                               
(	RowID int not null IDENTITY(1, 1) primary key                                                                                               
,	ActiveOrderNo numeric(8,0)                                                                                                                  
,	ShipTo varchar(25)                                                                                                                          
,	CustomerPart varchar(30)                                                                                                                    
,	ReleaseDate datetime                                                                                                                        
,	ReleaseNo varchar(50)                                                                                                                       
,	QtyRequired numeric(20,6)                                                                                                                   
,	PriorAccum numeric(20,6)                                                                                                                    
,	PostAccum numeric(20,6)                                                                                                                     
,	unique                                                                                                                                      
	(	ShipTo                                                                                                                                    
	,	CustomerPart                                                                                                                              
	,	ReleaseDate                                                                                                                               
	,	ReleaseNo                                                                                                                                 
	)                                                                                                                                           
,	unique                                                                                                                                      
	(	ActiveOrderNo                                                                                                                             
	,	ReleaseDate                                                                                                                               
	,	ReleaseNo                                                                                                                                 
	)                                                                                                                                           
)                                                                                                                                             
                                                                                                                                              
insert                                                                                                                                        
	#requirements                                                                                                                               
(	ActiveOrderNo                                                                                                                               
,	ShipTo                                                                                                                                      
,	CustomerPart                                                                                                                                
,	ReleaseDate                                                                                                                                 
,	ReleaseNo                                                                                                                                   
,	QtyRequired                                                                                                                                 
)                                                                                                                                             
select                                                                                                                                        
	ActiveOrderNo = ss.ActiveOrderNo                                                                                                            
,	ShipTo = od.destination                                                                                                                     
,	CustomerPart = od.customer_part                                                                                                             
,	ReleaseDate = od.due_date                                                                                                                   
,	ReleaseNo = coalesce(od.release_no, '')                                                                                                     
,	QtyRequired = sum(od.std_qty)                                                                                                               
from                                                                                                                                          
	dbo.order_detail od                                                                                                                         
	join #shipmentSummary ss                                                                                                                                      
		on od.order_no = coalesce(ss.ActiveOrderNo,0)                                                                         
group by                                                                                                                                      
	ss.ActiveOrderNo                                                                                                                            
,	od.destination                                                                                                                              
,	od.customer_part                                                                                                                            
,	od.due_date                                                                                                                                 
,	od.release_no                                                                                                                               
order by                                                                                                                                      
	od.destination                                                                                                                              
,	od.customer_part                                                                                                                            
,	od.due_date                                                                                                                                 
,	od.release_no                                                                                                                               
                                                                                                                                              
update                                                                                                                                        
	r                                                                                                                                           
set	PostAccum =                                                                                                                               
		(	select                                                                                                                                  
				sum(r1.QtyRequired)                                                                                                                   
			from                                                                                                                                    
				#requirements r1                                                                                                                      
			where                                                                                                                                   
				r1.ActiveOrderNo = r.ActiveOrderNo                                                                                                    
				and r1.RowID <= r.RowID                                                                                                               
		)                                                                                                                                         
from                                                                                                                                          
	#requirements r                                                                                                                             
                                                                                                                                              
update                                                                                                                                        
	r                                                                                                                                           
set	PriorAccum = r.PostAccum - r.QtyRequired                                                                                                  
from                                                                                                                                          
	#requirements r                                                                                                                             
                                                                                                                                              
if	@Debug = 1 begin                                                                                                                          
	select                                                                                                                                      
		*                                                                                                                                         
	from                                                                                                                                        
		#requirements r                                                                                                                           
end                                                                                                                                           
                                                                                                                                              
/*	Calculate the releases shipped summarized by Active Order, Release Date, and ReleaseNo. */                                                
create table                                                                                                                                  
	#releasesShipped                                                                                                                            
(	RowID int not null IDENTITY(1, 1) primary key                                                                                               
,	ActiveOrderNo numeric(8,0)                                                                                                                  
,	ShipTo varchar(25)                                                                                                                          
,	CustomerPart varchar(30)                                                                                                                    
,	ReleaseDate datetime                                                                                                                        
,	ReleaseNo varchar(50)                                                                                                                       
,	ReleaseQty numeric(20,6)                                                                                                                    
,	PriorAccum numeric(20,6)                                                                                                                    
,	PostAccum numeric(20,6)                                                                                                                     
,	unique                                                                                                                                      
	(	ActiveOrderNo                                                                                                                             
	,	ReleaseDate                                                                                                                               
	,	ReleaseNo                                                                                                                                 
	)                                                                                                                                           
,	unique                                                                                                                                      
	(	ShipTo                                                                                                                                    
	,	CustomerPart                                                                                                                              
	,	ReleaseDate                                                                                                                               
	,	ReleaseNo                                                                                                                                 
	)                                                                                                                                           
)                                                                                                                                             
                                                                                                                                              
insert                                                                                                                                        
	#releasesShipped                                                                                                                            
(	ActiveOrderNo                                                                                                                               
,	ShipTo                                                                                                                                      
,	CustomerPart                                                                                                                                
,	ReleaseDate                                                                                                                                 
,	ReleaseNo                                                                                                                                   
,	ReleaseQty                                                                                                                                  
,	PriorAccum                                                                                                                                  
,	PostAccum                                                                                                                                   
)                                                                                                                                             
select                                                                                                                                        
	ActiveOrderNo = r.ActiveOrderNo                                                                                                             
,	ShipTo = r.ShipTo                                                                                                                           
,	CustomerPart = r.CustomerPart                                                                                                               
,	ReleaseDate = r.ReleaseDate                                                                                                                 
,	ReleaseNo = r.ReleaseNo                                                                                                                     
,	ReleaseQty =                                                                                                                                
		case                                                                                                                                      
			when ss.QtyPacked >= r.PostAccum then r.QtyRequired                                                                                     
			else ss.QtyPacked - r.PriorAccum                                                                                                        
		end                                                                                                                                       
,	PriorAccum = r.PriorAccum                                                                                                                   
,	PostAccum =                                                                                                                                 
		case                                                                                                                                      
			when ss.QtyPacked >= r.PostAccum then r.PostAccum                                                                                       
			else ss.QtyPacked                                                                                                                       
		end                                                                                                                                       
from                                                                                                                                          
	#requirements r                                                                                                                             
	join #shipmentSummary ss                                                                                                                    
		on ss.ActiveOrderNo = r.ActiveOrderNo                                                                                                     
where                                                                                                                                         
	r.PriorAccum < ss.QtyPacked                                                                                                                 
                                                                                                                                              
if	@Debug = 1 begin                                                                                                                          
	select                                                                                                                                      
		*                                                                                                                                         
	from                                                                                                                                        
		#releasesShipped                                                                                                                          
end                                                                                                                                           
                                                                                                                                              
/*	Calculate the releases to be relieved...*/                                                                                                
/*	...	get the open releases for this order in the order they are to be releived. */                                                         
create table                                                                                                                                  
	#releases                                                                                                                                   
(	RowID int not null IDENTITY(1, 1) primary key                                                                                               
,	OrderNo numeric(8,0)                                                                                                                        
,	ActiveOrderNo numeric(8,0)                                                                                                                  
,	ShipTo varchar(25)                                                                                                                          
,	CustomerPart varchar(30)                                                                                                                    
,	ReleaseDate datetime                                                                                                                        
,	ReleaseNo varchar(50)                                                                                                                       
,	PartCode varchar(25)                                                                                                                        
,	QtyRequired numeric(20,6)                                                                                                                   
,	PriorAccum numeric(20,6)                                                                                                                    
,	PostAccum numeric(20,6)                                                                                                                     
,	ReleaseID int                                                                                                                               
,	ReleiveQty numeric(20,6)                                                                                                                    
,	DeleteRelease bit default(0)                                                                                                                
,	unique                                                                                                                                      
	(	OrderNo                                                                                                                                   
	,	RowID                                                                                                                                     
	)                                                                                                                                           
,	unique                                                                                                                                      
	(	ShipTo                                                                                                                                    
	,	CustomerPart                                                                                                                              
	,	RowID                                                                                                                                     
	)                                                                                                                                           
)                                                                                                                                             
                                                                                                                                              
insert                                                                                                                                        
	#releases                                                                                                                                   
(	OrderNo                                                                                                                                     
,	ActiveOrderNo                                                                                                                               
,	ShipTo                                                                                                                                      
,	CustomerPart                                                                                                                                
,	ReleaseDate                                                                                                                                 
,	ReleaseNo                                                                                                                                   
,	PartCode                                                                                                                                    
,	QtyRequired                                                                                                                                 
,	ReleaseID                                                                                                                                   
)                                                                                                                                             
select                                                                                                                                        
	OrderNo = od.order_no                                                                                                                       
,	ActiveOrderNo = ss.ActiveOrderNo                                                                                                            
,	ShipTo = od.destination                                                                                                                     
,	CustomerPart = od.customer_part                                                                                                             
,	ReleaseDate = od.due_date                                                                                                                   
,	ReleaseNo = coalesce(od.release_no, '')                                                                                                     
,	PartCode = od.part_number                                                                                                                   
,	QtyRequired = od.std_qty                                                                                                                    
,	ReleaseID = od.id                                                                                                                           
from                                                                                                                                          
	dbo.order_detail od                                                                                                                         
	join #shipmentSummary ss                                                                                                                   
		on od.order_no = coalesce(ss.ActiveOrderNo,0)                                                                         
order by                                                                                                                                      
	od.destination                                                                                                                              
,	od.customer_part                                                                                                                            
,	od.due_date                                                                                                                                 
,	od.release_no                                                                                                                               
,	od.part_number -- Use ordering for release distribution.  Perhaps not critical because redistribution should handle correctly.              
                                                                                                                                              
update                                                                                                                                        
	r                                                                                                                                           
set	PostAccum =                                                                                                                               
		(	select                                                                                                                                  
				sum(r1.QtyRequired)                                                                                                                   
			from                                                                                                                                    
				#releases r1                                                                                                                          
			where                                                                                                                                   
				r1.ActiveOrderNo = r.ActiveOrderNo                                                                                                    
				and r1.RowID <= r.RowID                                                                                                               
		)                                                                                                                                         
from                                                                                                                                          
	#releases r                                                                                                                                 
                                                                                                                                              
update                                                                                                                                        
	r                                                                                                                                           
set	PriorAccum = r.PostAccum - r.QtyRequired                                                                                                  
from                                                                                                                                          
	#releases r                                                                                                                                 
                                                                                                                                              
/*	...	calculate the quantity to be relieved. */                                                                                             
update                                                                                                                                        
	r                                                                                                                                           
set	ReleiveQty =                                                                                                                              
		case                                                                                                                                      
			when ss.QtyPacked >= r.PostAccum then r.QtyRequired                                                                                     
			else ss.QtyPacked - r.PriorAccum                                                                                                        
		end                                                                                                                                       
,	DeleteRelease =                                                                                                                             
		case                                                                                                                                      
			when ss.QtyPacked >= r.PostAccum then 1                                                                                                 
			else 0                                                                                                                                  
		end                                                                                                                                       
from                                                                                                                                          
	#releases r                                                                                                                                 
	join #shipmentSummary ss                                                                                                                    
		on ss.ActiveOrderNo = r.ActiveOrderNo                                                                                                     
where                                                                                                                                         
	r.PriorAccum < ss.QtyPacked                                                                                                                 
                                                                                                                                              
                                                                       
                                                                                                                                            
/*	Write Discrete PO shipment history (Blanket POs that have SPOT in order_header.customer_po). */                                           
--                                                                                                                                            
if	exists                                                                                                                                    
	(	select                                                                                                                                    
			*                                                                                                                                       
		from                                                                                                                                      
			#releases r                                                                                                                             
		where                                                                                                                                     
			r.OrderNo in ( Select order_no from order_header where customer = 'BENT')                      
	) begin                                                                                                                                     
	                                                                                                                                            
	--- <Insert rows="*">                                                                                                                       
	set	@TableName = 'DiscretePONumbersShipped'                                                                                                 
                                                                                                                                              
	insert                                                                                                                                      
		DiscretePONumbersShipped                                                                                                                  
	(	OrderNo                                                                                                                                   
	,	ShipDate                                                                                                                                  
	,	Qty                                                                                                                                       
	,	DiscretePONumber                                                                                                                          
	,	Shipper                                                                                                                                   
	)                                                                                                                                           
	select                                                                                                                                      
		OrderNo = r.OrderNo                                                                                                                       
	,	ShipDate = s.date_shipped                                                                                        
	,	Qty =                                                                                                                                     
			case                                                                                                                                    
				when r.PostAccum < rs.PriorAccum then 0                                                                                               
				when r.PriorAccum > rs.PostAccum then 0                                                                                               
				when r.PostAccum >= rs.PostAccum and r.PriorAccum <= rs.PriorAccum then rs.PostAccum - rs.PriorAccum                                  
				when r.PostAccum < rs.PostAccum and r.PriorAccum > rs.PriorAccum then r.PostAccum - r.PriorAccum                                      
				when r.PostAccum >= rs.PostAccum and r.PriorAccum > rs.PriorAccum then rs.PostAccum - r.PriorAccum                                    
				when r.PostAccum < rs.PostAccum and r.PriorAccum <= rs.PriorAccum then r.PostAccum - rs.PriorAccum                                    
			end                                                                                                                                     
	,	DiscretePONumber = rs.ReleaseNo                                                                                                           
	,	Shipper = s.id                                                                                                                            
	from                                                                                                                                        
		#releases r                                                                                                                               
		join #releasesShipped rs                                                                                                                  
			on rs.ActiveOrderNo = r.ActiveOrderNo                                                                                                   
			and rs.ReleaseDate = r.ReleaseDate                                                                                                      
		join dbo.shipper s                                                                                                                        
			on s.id = @ShipperID                                                                                                                    
	where                                                                                                                                       
		r.PostAccum > rs.PriorAccum                                                                                                               
		and r.PriorAccum < rs.PostAccum                                                                                                           
                                                                                                                                              
	select                                                                                                                                      
		@Error = @@Error,                                                                                                                         
		@RowCount = @@Rowcount                                                                                                                    
                                                                                                                                              
	if	@Error != 0 begin                                                                                                                       
		set	@Result = 999999                                                                                                                      
		RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)                             
		rollback tran @ProcName                                                                                                                   
		return                                                                                                                                    
	end                                                                                                                                         
	--- </Insert>                                                                                                                               
end                                                                                                                                           
                                                                                                                                              
                                                                                                                                              
                                                                                                       
                                                                                                                                         
                                                                              
--- </Troubleshooting>                                                                                                                        
                                                                                                                                             
IF	@TranCount = 0 BEGIN                                                                                                                      
	COMMIT TRAN @ProcName                                                                                                                       
END                                                                                                                                           
                                                                                                                                              
---	<Return>                                                                                                                                  
SET	@Result = 0                                                                                                                               
RETURN                                                                                                                                        
	@Result                                                                                                                                     
--- </Return>                                                                                                                                 
                                                                                                                                              
/*                                                                                                                                            
Example:                                                                                                                                      
Initial queries                                                                                                                               
{                                                                                                                                             
                                                                                                                                              
}                                                                                                                                             
                                                                                                                                              
Test syntax                                                                                                                                   
{                                                                                                                                             
                                                                                                                                              
set statistics io on                                                                                                                          
set statistics time on                                                                                                                        
go                                                                                                                                            
                                                                                                                                              
declare                                                                                                                                       
	@shipperID int                                                                                                                              
                                                                                                                                              
set	@shipperID = 82470                                                                                                                        
                                                                                                                                              
begin transaction Test                                                                                                                        
                                                                                                                                              
declare                                                                                                                                       
	@ProcReturn integer                                                                                                                         
,	@TranDT datetime                                                                                                                            
,	@ProcResult integer                                                                                                                         
,	@Error integer                                                                                                                              
                                                                                                                                              
execute                                                                                                                                       
	@ProcReturn = dbo.usp_Shipping_ShipoutCaptureDiscretePOs                                                                                        
	@ShipperID = @shipperID                                                                                                                     
,	@TranDT = @TranDT out                                                                                                                       
,	@Result = @ProcResult out                                                                                                                   
,	@Debug = 1                                                                                                                                  
                                                                                                                                              
set	@Error = @@error                                                                                                                          
                                                                                                                                              
select                                                                                                                                        
	@Error, @ProcReturn, @TranDT, @ProcResult                                                                                                   
go                                                                                                                                            
                                                                                                                                              
if	@@trancount > 0 begin                                                                                                                     
	rollback                                                                                                                                    
end                                                                                                                                           
go                                                                                                                                            
                                                                                                                                              
set statistics io off                                                                                                                         
set statistics time off                                                                                                                       
go                                                                                                                                            
                                                                                                                                              
}                                                                                                                                             
                                                                                                                                              
Results {                                                                                                                                     
}                                                                                                                                             
*/                                                                                                                                            
                                                                                                                                              
                                                                                                                                              
                                                                                                                                              
                                                                                                                                              



GO
