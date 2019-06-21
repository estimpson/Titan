
/*
Create ScalarFunction.FxEDI.RAWEDIDATA_FS.udf_GetNextFileName.sql
*/

use FxEDI
go

if	objectproperty(object_id('RAWEDIDATA_FS.udf_GetNextFileName'), 'IsScalarFunction') = 1 begin
	drop function RAWEDIDATA_FS.udf_GetNextFileName
end
go

create function RAWEDIDATA_FS.udf_GetNextFileName
(	@OutboundPath sysname
)
returns nvarchar(max)
as
begin
--- <Body>
	declare
		@newOutboundFileName nvarchar(max)
	,	@outboundFileNumber int

	select
		@outboundFileNumber = max(coalesce
		(	convert(int, substring(redOutboundFiles.name, 9, 5)) + 1
		,	1
		))
	from
		dbo.RawEDIData redOutboundFolder
		left join dbo.RawEDIData redOutboundFiles
			on redOutboundFiles.parent_path_locator = redOutboundFolder.path_locator
			and redOutboundFiles.is_directory = 0
			and redOutboundFiles.name like 'outbound[0-9][0-9][0-9][0-9][0-9].xml'
	where
		redOutboundFolder.file_stream.GetFileNamespacePath() = @outboundPath
		and redOutboundFolder.is_directory = 1

	select
		@newOutboundFileName = N'outbound' + right(N'0000' + convert(varchar, @outboundFileNumber), 5) + N'.xml'
--- </Body>

---	<Return>
	return
		@newOutboundFileName
end
go

select
	RAWEDIDATA_FS.udf_GetNextFileName('\RawEDIData\CustomerEDI\Outbound\Staging')