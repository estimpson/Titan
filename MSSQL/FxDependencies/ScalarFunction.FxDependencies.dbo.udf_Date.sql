
/*
Create ScalarFunction.FxDependencies.dbo.udf_Date.sql
*/

use FxDependencies
go

if	objectproperty(object_id('dbo.udf_Date'), 'IsScalarFunction') = 1 begin
	drop function dbo.udf_Date
end
go

create function dbo.udf_Date
(	@datetime datetime
)
returns date
as
begin
--- <Body>

--- </Body>

---	<Return>
	return
		convert(date, @datetime)
end
go

