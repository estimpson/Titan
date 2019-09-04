SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDIFACT96A].[CurrentShipSchedules]
(
--	@Param1 [scalar_data_type] ( = [default_value] ) ...
)
returns @CurrentShipSchedules table
(	RawDocumentGUID uniqueidentifier not null
,	ReleaseNo varchar(50) null
,	ShipToCode varchar(15) null
,	ShipFromCode varchar(15) null
,	ConsigneeCode varchar(15) null
,	CustomerPart varchar(50) null
,	CustomerPO varchar(50) null
,	CustomerModelYear varchar(50) null
,	NewDocument bit
,	SalesOrderNumber int
,	DuplicateBlanketOrders bit
,	MissingBlanketOrder bit
)
as
begin
--- <Body>
	insert
		@CurrentShipSchedules
		(	RawDocumentGUID
		,	ReleaseNo
		,	ShipToCode
		,	ShipFromCode
		,	ConsigneeCode
		,	CustomerPart
		,	CustomerPO
		,	CustomerModelYear
		,	NewDocument
		,	SalesOrderNumber
		,	DuplicateBlanketOrders
		,	MissingBlanketOrder
		)
		select
			ssr.RawDocumentGUID
		,	ssr.ReleaseNo
		,	ssr.ShipToCode
		,	ssr.ShipFromCode
		,	ssr.ConsigneeCode
		,	ssr.CustomerPart
		,	ssr.CustomerPO
		,	ssr.CustomerModelYear
		,	NewDocument = case when ssr.Status = 0 then 1 else 0 end
		,	SalesOrderNumber = max(bo.BlanketOrderNo)
		,	DuplicateBlanketOrders =
				case
					when count(distinct	bo.BlanketOrderNo) > 1 then 1
					else 0
				end
		,	MissingBlanketOrder =
				case
					when max(bo.BlanketOrderNo) is null then 1
					else 0
				end
		from
			(	select
					ssr.RawDocumentGUID
				,	ssr.ReleaseNo
				,	ssr.ShipToCode
				,	ssr.ShipFromCode
				,	ssr.ConsigneeCode
				,	ssr.CustomerPart
				,	ssr.CustomerPO
				,	ssr.CustomerModelYear
				,	ssh.Status
				,	Precedence = row_number() over
						(	partition by
								ssr.ShipToCode
							,	ssr.ShipFromCode
							,	ssr.ConsigneeCode
							,	ssr.CustomerPart
							,	ssr.CustomerPO
							,	ssr.CustomerModelYear
							order by
								ssh.DocumentImportDT desc
							,	ssh.DocumentDT desc
							,	ssh.RowID desc
						)
				from
					EDIFACT96A.ShipScheduleHeaders ssh
					join EDIFACT96A.ShipScheduleReleases ssr
						on ssr.RawDocumentGUID = ssh.RawDocumentGUID
				where
					ssh.Status in (0, 1)
			) ssr
			left join EDIFACT96A.BlanketOrders bo
				on bo.EDIShipToCode = ssr.ShipToCode
				and bo.CustomerPart = ssr.CustomerPart
				and
				(	bo.CheckCustomerPOShipSchedule = 0
					or bo.CustomerPO = ssr.CustomerPO
				)
				and
				(	bo.CheckModelYearShipSchedule = 0
					or bo.ModelYear862 = ssr.CustomerModelYear
				)
		where
			ssr.Precedence = 1
			and coalesce(bo.ProcessShipSchedule, 1) = 1
		group by
			ssr.RawDocumentGUID
		,	ssr.ReleaseNo
		,	ssr.ShipToCode
		,	ssr.ShipFromCode
		,	ssr.ConsigneeCode
		,	ssr.CustomerPart
		,	ssr.CustomerPO
		,	ssr.CustomerModelYear
		,	ssr.Status
--- </Body>

---	<Return>
	return
end
GO
