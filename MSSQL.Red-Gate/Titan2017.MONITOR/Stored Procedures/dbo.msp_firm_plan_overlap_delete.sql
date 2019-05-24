SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[msp_firm_plan_overlap_delete]
as
begin /*(1B)*/
  /* Declare variable(s)*/
  declare @ordernumber integer,
  @maxduedate datetime
  /* Initialize variable(s)       */
  select @ordernumber=0,
    @maxduedate=null
  begin transaction
  /* Declare Cursor*/
  declare overlapcursor CURSOR DYNAMIC for select distinct order_detail.order_no, max (order_detail.due_date)
      from order_detail,order_header
      where order_header.order_type='B'
      and order_header.order_no=order_detail.order_no
      and order_detail. type ='F'
      group by order_detail.order_no
  /*  Open the cursor.*/
  open overlapcursor
  /*  Fetch a row of data from the cursor.*/
  FETCH overlapcursor into @ordernumber,
    /*  Continue processing as long as more order_detail data exists.*/
    @maxduedate
  while(@@fetch_status=0)
    begin /* (2B)*/
      if(select  count (distinct  type ) from order_detail where order_no=@ordernumber)>1
        begin
          begin transaction
          delete from order_detail
            where  type ='P'
            and order_detail.due_date<=@maxduedate
            and order_no=@ordernumber
          commit transaction
        end
      FETCH overlapcursor into @ordernumber,
        @maxduedate end
  close overlapcursor
  deallocate overlapcursor
  commit transaction /* (2B)*/
end -- (1B)

GO
