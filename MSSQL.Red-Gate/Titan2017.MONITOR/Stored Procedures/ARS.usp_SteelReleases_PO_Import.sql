SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [ARS].[usp_SteelReleases_PO_Import]
as
begin
	set nocount on

	declare 
		@ProcName nvarchar(100) = N'ARS.usp_SteelReleases_PO_Import'
	,	@CustomError as nvarchar(1000)


	begin try
	begin transaction

		insert into ARS.SteelReleases_PO_Import
		(
			RawPart
		,	PODate
		,	Quantity
		,	Note
		,	ImportDT
		)
		select
			tpi.RawPart
		,	convert(datetime, tpi.PoDate)
		,	convert(decimal(20,6), tpi.Quantity)
		,	tpi.Note
		,	null
		from
			ARS.TempPoImport tpi
		where
			coalesce(tpi.RawPart, '') <> ''

		if (@@rowcount < 1) begin
			select @CustomError = formatmessage('Zero rows were imported.  Expected one or more rows.  Proc %s.', @ProcName);
			throw 50000, @CustomError, 0;
		end
		
	commit transaction
	end try
	begin catch
		
		if @@trancount > 0 rollback transaction;
		throw;

	end catch
end
GO
