
/*
Create ScalarFunction.FxEDI.RAWEDIDATA_FS.udf_GetNewFilePathLocator.sql
*/

use FxEDI
go

if	objectproperty(object_id('RAWEDIDATA_FS.udf_GetNewFilePathLocator'), 'IsScalarFunction') = 1 begin
	drop function RAWEDIDATA_FS.udf_GetNewFilePathLocator
end
go

create function RAWEDIDATA_FS.udf_GetNewFilePathLocator
(	@folder nvarchar(max)
)
returns hierarchyid
as
begin
--- <Body>
	declare
		@outputPath hierarchyid

	select
		@outputPath = FxSYS.dbo.udf_GetNewChildHierarchyID(path_locator)
	from
		dbo.RawEDIData red
	where
		red.file_stream.GetFileNamespacePath() = @folder
		and red.is_directory = 1
--- </Body>

---	<Return>
	return
		@outputPath
end
go

select
	RAWEDIDATA_FS.udf_GetNewFilePathLocator('\RawEDIData\CustomerEDI\Outbound\Staging')
