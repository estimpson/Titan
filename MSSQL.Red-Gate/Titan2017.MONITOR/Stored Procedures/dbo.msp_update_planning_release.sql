SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[msp_update_planning_release]
as
begin /*(1B)*/
  /* Declare variable(s)*/
  declare @ordernumber decimal(8),
  @ourcum decimal(20,6),
  @thecum decimal(20,6),
  @quantity decimal(20,6),
  @stdquantity decimal(20,6),
  @part varchar(25),
  @unit varchar(2)
  /* Initialize variable(s)       */
  select @ordernumber=0,
    @ourcum=0,
    @thecum=0,
    @quantity=0,
    @stdquantity=0
  begin transaction
  /* Declare Cursor*/
  declare plancursor CURSOR DYNAMIC for select distinct order_detail.order_no
      from order_detail,order_header
      where order_header.order_type='B'
      and order_header.order_no=order_detail.order_no
  /*  Open the cursor.*/
  open plancursor
  /*  Fetch a row of data from the cursor.*/
  FETCH plancursor into @ordernumber
    /*  Continue processing as long as more order_detail data exists.*/
  while(@@fetch_status=0)
    begin /* (2B)*/
      if((select  count (distinct  type ) from order_detail where order_no=@ordernumber)>1)
        and((select artificial_cum from order_header where order_no=@ordernumber)='A')
        begin
          select @ourcum=isnull( max (the_cum),0) from order_detail
            where order_no=@ordernumber
            and  type ='F'
          select @thecum=isnull(min(the_cum),0) from order_detail
            where order_detail.order_no=@ordernumber
            and order_detail. type ='P'
          select @quantity=@thecum-@ourcum
          select @stdquantity=@quantity
          select @part=blanket_part,
            @unit=unit
            from order_header
            where(order_header.order_no=@ordernumber)
          execute msp_calculate_std_quantity @part,@stdquantity,@unit
          update order_detail set
            quantity=@quantity,
            our_cum=@ourcum,
            std_qty=@stdquantity
            where order_detail.order_no=@ordernumber
            and order_detail. type ='P'
            and order_detail.due_date=(select min(due_date) from order_detail
              where order_detail.order_no=@ordernumber
              and order_detail. type ='P')
          delete from order_detail
            where order_detail.order_no=@ordernumber
            and order_detail. type ='P'
            and order_detail.quantity<=0
        end
      FETCH plancursor into @ordernumber
    end
  close plancursor
  deallocate plancursor
  commit transaction /* (2B)*/
end -- (1B)

GO
