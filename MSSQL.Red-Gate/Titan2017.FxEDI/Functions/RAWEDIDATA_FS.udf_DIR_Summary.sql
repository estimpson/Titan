SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [RAWEDIDATA_FS].[udf_DIR_Summary]
(	@Path nvarchar(max)
)
returns @DIR table
(	Name nvarchar(255)
,	PathLocator hierarchyid
,	RootFileCount int
,	RootSubFolderCount int
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

	insert
		@DIR
	(	Name
	,	PathLocator
	,	RootFileCount
	,	RootSubFolderCount
	)
	select
		Name = min(red.name)
	,	PathLocator = min(red.parent_path_locator)
	,	RootFileCount = count(case when red.is_directory = 0 then 1 end)
	,	RootSubFolderCount = count(case when red.is_directory = 1 then 1 end)
	from
		dbo.RawEDIData red
	where
		red.parent_path_locator = @PathLocator
	group by
		red.parent_path_locator

	if	@@ROWCOUNT = 0 begin
		insert
			@DIR
		(	Name
		,	PathLocator
		,	RootFileCount
		,	RootSubFolderCount
		)
		select
			Name = min(red.name)
		,	PathLocator = min(red.path_locator)
		,	RootFileCount = 0
		,	RootSubFolderCount = 0
		from
			dbo.RawEDIData red
		where
			red.path_locator = @PathLocator
		group by
			red.path_locator
	end
--- </Body>

---	<Return>
	return
end
GO
