IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'msp_update_planning_release' and type = 'P')
	DROP PROCEDURE msp_update_planning_release
	
GO	
CREATE PROCEDURE msp_update_planning_release as

BEGIN --(1B)

  -- Declare variable(s)
  DECLARE  @ordernumber   decimal(8),
	   @ourcum        decimal (20,6),
	   @thecum        decimal (20,6),
	   @quantity      decimal (20,6),
	   @stdquantity   decimal (20,6),
	   @part          varchar(25),
	   @unit          varchar(2)

  -- Initialize variable(s)       
  SELECT   @ordernumber = 0,
           @ourcum      = 0, 
	   @thecum      = 0,
	   @quantity    = 0,
	   @stdquantity = 0      

  BEGIN TRANSACTION

    -- Declare Cursor

    DECLARE plancursor CURSOR FOR
                SELECT  DISTINCT order_detail.order_no
                  FROM  order_detail, order_header
                WHERE  order_header.order_type = 'B' and
                       order_header.order_no = order_detail.order_no    

    --  Open the cursor.
    OPEN  plancursor

    --  Fetch a row of data from the cursor.
    FETCH  plancursor
                  INTO  @ordernumber
    --  Continue processing as long as more order_detail data exists.
    WHILE   ( @@SQLSTATUS = 0 )
     BEGIN -- (2B)
       IF (SELECT count(distinct type) from order_detail where order_no = @ordernumber)>1
        BEGIN
           SELECT @ourcum = isnull(max(the_cum),0) from order_detail
              where order_no = @ordernumber and
                                  type = 'F' 
           SELECT @thecum = isnull(min(the_cum),0) from order_detail                                        
              WHERE order_detail.order_no = @ordernumber and
                              order_detail.type = 'P' 
           SELECT @quantity = @thecum - @ourcum
           SELECT @stdquantity = @quantity
           SELECT @part = blanket_part,
                  @unit = unit
             FROM order_header
            WHERE (order_header.order_no=@ordernumber)
           EXECUTE msp_calculate_std_quantity @part, @stdquantity OUTPUT, @unit
           UPDATE order_detail 
              SET quantity = @quantity,
                  our_cum  = @ourcum,
                  std_qty = @stdquantity
            WHERE order_detail.order_no = @ordernumber and
            order_detail.type = 'P' and
            order_detail.due_date = (select min(due_date) from order_detail
                                        where order_detail.order_no = @ordernumber and
                                        order_detail.type = 'P')
        END
       FETCH plancursor
                  INTO  @ordernumber
     END  
     CLOSE plancursor     
     
   COMMIT TRANSACTION -- (2B)
END -- (1B)		
