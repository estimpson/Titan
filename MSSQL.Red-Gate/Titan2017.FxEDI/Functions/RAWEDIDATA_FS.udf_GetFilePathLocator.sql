SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [RAWEDIDATA_FS].[udf_GetFilePathLocator]
(	@folderPath nvarchar(max)
)
returns hierarchyid
as
begin
--- <Body>
	declare
		@outputPath hierarchyid

	select
		@outputPath = FS.udf_GetNewChildHierarchyID(red.path_locator)
	from
		dbo.RawEDIData red
	where
		red.is_directory = 1
		and red.file_stream.GetFileNamespacePath() = @folderPath
--- </Body>

---	<Return>
	return
		@outputPath
end
GO
