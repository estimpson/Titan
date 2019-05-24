SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure
[dbo].[msp_llform_nest_release_ecl](@part varchar(50),@date datetime)
as
begin
  select  max (convert(varchar(30),effective_date,102)+'  '+'/'+'   '+engineering_level)
    from effective_change_notice
    where(part=@part)
    and(@date>=effective_date)
end
GO
