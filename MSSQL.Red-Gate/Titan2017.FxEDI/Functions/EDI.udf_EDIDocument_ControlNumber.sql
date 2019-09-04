SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI].[udf_EDIDocument_ControlNumber]
(	@XMLData xml
)
returns varchar(max)
as
begin
--- <Body>
	declare
		@ReturnValue varchar(max)
		
	set @ReturnValue = @XMLData.value('/TRN-INFO[1]/@control_number', 'varchar(max)')
--- </Body>

---	<Return>
	return
		@ReturnValue
end
GO
