SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[usp_StampingSetup_PO_Import]
as
begin
	set nocount on

	declare 
		@ProcName nvarchar(100) = N'dbo.usp_StampingSetup_PO_Import'
	,	@CustomError as nvarchar(1000)


	begin try
	begin transaction

		insert into dbo.StampingSetup_PO_Import
		(
			RawPart
		,	PoDate
		,	Quantity
		,	ImportDateTime
		)
		select
			tpi.RawPart
		,	convert(datetime2, tpi.PoDate)
		,	convert(int, tpi.Quantity)
		,	convert(datetime2, tpi.ImportDateTime)
		from
			dbo.TempPoImport tpi
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
