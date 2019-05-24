SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure
[dbo].[msp_sequence_adjustment]
as
begin
  declare @due_date datetime,
  @order_no decimal(8),
  @sequence integer,
  @newsequence integer
  update order_detail set
    sequence=sequence+1000
  select @order_no=min(order_no)
    from order_header
    where order_type='B'
  while(@order_no is not null)
    begin
      print 'order_no:'+convert(varchar,@order_no)
      select @due_date=min(due_date)
        from order_detail
        where order_no=@order_no
        and sequence>1000
      select @newsequence=1
      while(@due_date is not null)
        begin
          print 'due_date:'+convert(varchar,@due_date)
          select @sequence=min(sequence)
            from order_detail
            where order_no=@order_no
            and due_date=@due_date
            and sequence>1000
          print 'sequence:'+convert(varchar,@sequence)
          update order_detail set
            sequence=@newsequence
            where sequence=@sequence
            and order_no=@order_no
          select @newsequence=@newsequence+1
          select @due_date=min(due_date)
            from order_detail
            where order_no=@order_no
            and due_date>=@due_date
            and sequence>1000
        end
      select @order_no=min(order_no)
        from order_header
        where order_no>@order_no
        and order_type='B'
    end
end
GO
