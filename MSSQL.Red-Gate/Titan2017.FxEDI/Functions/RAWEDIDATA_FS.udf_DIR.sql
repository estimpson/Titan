SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [RAWEDIDATA_FS].[udf_DIR]
(	@Path nvarchar(max)
,	@IncludeSub bit = 0
)
returns @DIR table
(	CreateDT datetime
,	WriteDT datetime
,	AccessDT datetime
,	IsDir bit
,	Name nvarchar(255)
,	Path nvarchar(max)
,	PathLocator hierarchyid
,	ParentPathLocator hierarchyid
,	FileSize bigint
)
as
begin
--- <Body>
	declare
		@RootPath nvarchar(max) = FileTableRootPath('dbo.RawEDIData')
	,	@PathLocator hierarchyid
	,	@ParentPathLocator hierarchyid

	select
		@PathLocator = GetPathLocator(@RootPath + @Path)

	select
		@ParentPathLocator = @PathLocator.GetAncestor(1)

	if	@IncludeSub = 0 begin
		insert
			@DIR
		(	CreateDT
		,	WriteDT
		,	AccessDT
		,	IsDir
		,	Name
		,	Path
		,	PathLocator
		,	ParentPathLocator
		,	FileSize
		)
		select
			CreateDT = red.creation_time
		,	WriteDT = red.last_write_time
		,	AccessDT = red.last_access_time
		,	IsDir = red.is_directory
		,	Name = red.name
		,	Path = red.file_stream.GetFileNamespacePath()
		,	PathLocator = red.path_locator
		,	ParentPathLocator = red.parent_path_locator
		,	FileSize = len(red.file_stream)
		from
			dbo.RawEDIData red
		where
			red.parent_path_locator = @PathLocator
		union all
		select
			CreateDT = red.creation_time
		,	WriteDT = red.last_write_time
		,	AccessDT = red.last_access_time
		,	IsDir = red.is_directory
		,	Name = '.'
		,	Path = red.file_stream.GetFileNamespacePath()
		,	PathLocator = red.path_locator
		,	ParentPathLocator = red.parent_path_locator
		,	FileSize = len(red.file_stream)
		from
			dbo.RawEDIData red
		where
			red.path_locator = @PathLocator
		union all
		select
			CreateDT = red.creation_time
		,	WriteDT = red.last_write_time
		,	AccessDT = red.last_access_time
		,	IsDir = red.is_directory
		,	Name = '..'
		,	Path = red.file_stream.GetFileNamespacePath()
		,	PathLocator = red.path_locator
		,	ParentPathLocator = red.parent_path_locator
		,	FileSize = len(red.file_stream)
		from
			dbo.RawEDIData red
		where
			red.path_locator = @ParentPathLocator
		order by
			ParentPathLocator
		,	Name
	end
	else begin
		insert
			@DIR
		(	CreateDT
		,	WriteDT
		,	AccessDT
		,	IsDir
		,	Name
		,	Path
		,	PathLocator
		,	ParentPathLocator
		,	FileSize
		)
		select
			CreateDT = red.creation_time
		,	WriteDT = red.last_write_time
		,	AccessDT = red.last_access_time
		,	IsDir = red.is_directory
		,	Name = red.name
		,	Path = red.file_stream.GetFileNamespacePath()
		,	PathLocator = red.path_locator
		,	ParentPathLocator = red.parent_path_locator
		,	FileSize = len(red.file_stream)
		from
			dbo.RawEDIData red
		where
			red.parent_path_locator.IsDescendantOf(@PathLocator) = 1
		union all
		select
			CreateDT = red.creation_time
		,	WriteDT = red.last_write_time
		,	AccessDT = red.last_access_time
		,	IsDir = red.is_directory
		,	Name = '.'
		,	Path = red.file_stream.GetFileNamespacePath()
		,	PathLocator = red.path_locator
		,	ParentPathLocator = red.parent_path_locator
		,	FileSize = len(red.file_stream)
		from
			dbo.RawEDIData red
		where
			red.path_locator = @PathLocator
		union all
		select
			CreateDT = red.creation_time
		,	WriteDT = red.last_write_time
		,	AccessDT = red.last_access_time
		,	IsDir = red.is_directory
		,	Name = '..'
		,	Path = red.file_stream.GetFileNamespacePath()
		,	PathLocator = red.path_locator
		,	ParentPathLocator = red.parent_path_locator
		,	FileSize = len(red.file_stream)
		from
			dbo.RawEDIData red
		where
			red.path_locator = @ParentPathLocator
		order by
			ParentPathLocator
		,	Name
	end

--- </Body>

---	<Return>
	return
end
GO
