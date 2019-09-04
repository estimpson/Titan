SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [RAWEDIDATA_FS].[udf_GetNewFilePathLocator]
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
GO
