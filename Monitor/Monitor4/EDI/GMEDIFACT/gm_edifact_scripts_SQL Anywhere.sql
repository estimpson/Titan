if exists (select * from sysobjects where id =object_id('deljit_releases'))
        drop table deljit_releases
GO

CREATE TABLE deljit_releases  (
  process_date		datetime NULL DEFAULT getdate(), 
  release_number		varchar(35) NULL,
  ship_to_id                    	varchar(35) NULL,
  buyer_part                    	varchar(35) NULL,
  type1         		varchar(35)  NULL,
  customer_po   		varchar(35) NULL,	
  model_year                    	varchar(35) NULL,
  quantity                      	varchar(35) NULL,
  date_time                     	varchar(35) NULL)

GO

if exists (select * from sysobjects where id=object_id('deljit_kanban'))
        drop table deljit_kanban

go
 
CREATE TABLE deljit_kanban  (
  release_number                varchar(35) NULL,
  ship_to_id                    varchar(35) NULL,
  buyer_part                    varchar(35) NULL,
  model_year                    varchar(35) NULL,
  kanban_line                   varchar(35) NULL,
  line_id                       varchar(35) NULL,
  begin_kanban  varchar(35)  NULL,
  end_kanban    varchar(35)  NULL  )
go 
  if exists (select * from sysobjects where id=object_id('deljit_oh'))
        drop table deljit_oh
go
CREATE TABLE deljit_oh  (
  release_date         varchar(35) NULL,        
  release_number                varchar(35) NULL,
  ship_to_id                    varchar(35) NULL,
  buyer_part                    varchar(35) NULL,
  model_year                    varchar(35) NULL,
  dock_code                     varchar(35) NULL,
  line_feed_code                varchar(35) NULL  )
go 
  if exists (select * from sysobjects where id=object_id('deljit_cytd'))
        drop table deljit_cytd
go
CREATE TABLE deljit_cytd  (
  release_number                varchar(35) NULL,
  ship_to_id                    varchar(35) NULL,
  buyer_part                    varchar(35) NULL,
  model_year                    varchar(35) NULL,
  cytd_start_date               varchar(35) NULL,
  cytd_ship_qty                 varchar(35) NULL  )
  
go 
  if exists (select * from sysobjects where id=object_id('delfor_releases'))
        drop table delfor_releases
go

CREATE TABLE delfor_releases  (
  process_date		datetime NULL DEFAULT getdate(),
  release_number                varchar(35) NULL,
  ship_to_id                    	varchar(35) NULL,
  buyer_part                    	varchar(35) NULL,
  type1         		varchar(35)  NULL,
   customer_po   		varchar(35) NULL,
  model_year                    	varchar(35) NULL,
  forecast_type                 	varchar(35) NULL,
  quantity                     	varchar(35) NULL,
  start_date                    	varchar(35) NULL,
  date_mgo		varchar(35) NULL
   )
go 
  if exists (select * from sysobjects where id=object_id('delfor_cums'))
        drop table delfor_cums
go
CREATE TABLE delfor_cums  (
  release_number                varchar(35) NULL,
  ship_to_id                    	varchar(35) NULL,
  buyer_part                    	varchar(35) NULL,
  model_year                    	varchar(35) NULL,
  fab_auth_qty                  	varchar(35) NULL,
  fab_auth_start_dte         varchar(35) NULL,
  raw_auth_qty                  varchar(35) NULL,
  raw_auth_start_dte        varchar(35) NULL  )
go 
  
  
  if exists (select * from sysobjects where id=object_id('gm_pilot_releases'))
        drop table gm_pilot_releases
go 


CREATE TABLE gm_pilot_releases (
  customer_part                 varchar(35)  NULL,
  ship_to_id                    varchar(20)  NULL,
  customer_po                   varchar(20)  NULL,
  model_year                    varchar(4)  NULL,
  release_no                    varchar(30)  NULL,
  quantity                      numeric(20,6)  NULL,
  release_date                  datetime  NULL,
  forecast_type                 varchar(2)  NULL  )
go


  if exists (select * from sysobjects where id = object_id('delfor_oh')) 
        drop table delfor_oh
go      
CREATE TABLE delfor_oh  (
  release_date                    varchar (12) NULL,
  release_number                varchar(35) NULL,
  ship_to_id                    varchar(35) NULL,
  buyer_part                    varchar(35) NULL,
  model_year                    varchar(35) NULL,
  dock_code                     varchar(35) NULL,
  line_feed_code                varchar(35) NULL  )
go  
  if exists (select * from sysobjects where id = object_id('delfor_cytd')) 
        drop table delfor_cytd
go
CREATE TABLE delfor_cytd  (
  release_number                varchar(35) NULL,
  ship_to_id                    varchar(35) NULL,
  buyer_part                    varchar(35) NULL,
  model_year                    varchar(35) NULL,
  cytd_start_date                varchar(35) NULL,
  cytd_qty_shipped              varchar(35) NULL  )
  
  IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'msp_firm_plan_overlap_delete' and type = 'P')
        DROP PROCEDURE msp_firm_plan_overlap_delete
        
GO      
CREATE PROCEDURE msp_firm_plan_overlap_delete as

BEGIN --(1B)

  -- Declare variable(s)
  DECLARE  @ordernumber                 integer,
            @maxduedate                 date
            
            
  -- Initialize variable(s)       
  SELECT    	@ordernumber = 0,
                @maxduedate  = NULL
                           

  BEGIN TRANSACTION

    -- Declare Cursor

    DECLARE overlapcursor CURSOR FOR
                SELECT  DISTINCT order_detail.order_no, max(order_detail.due_date)
                  FROM  order_detail, order_header
                WHERE  order_header.order_type = 'B' and
                       order_header.order_no = order_detail.order_no and
                       order_detail.type = 'F'
                 GROUP BY order_detail.order_no          

    --  Open the cursor.
    OPEN  overlapcursor

    --  Fetch a row of data from the cursor.
    FETCH  overlapcursor
                  INTO  @ordernumber,
                            @maxduedate 
    --  Continue processing as long as more order_detail data exists.
    WHILE   ( @@SQLSTATUS = 0 )
     BEGIN -- (2B)
       IF (SELECT count(distinct type) from order_detail where order_no = @ordernumber)>1
        BEGIN
           BEGIN TRANSACTION
              DELETE order_detail 
                  WHERE type = 'P' and
                                order_detail.due_date <= @maxduedate and
                                order_no  = @ordernumber
            COMMIT TRANSACTION                          
              
                
      
        END
       FETCH overlapcursor
                  INTO  @ordernumber,
                            @maxduedate         
     END  
     CLOSE overlapcursor     
     
   COMMIT TRANSACTION -- (2B)
END -- (1B)             


 


