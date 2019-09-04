SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [EDIFACT97A].[usp_StageShipSchedules]
	@TranDT datetime = null out
,	@Result integer = null out
,	@Debug int = 0
,	@DebugMsg varchar(max) = null out
as
begin

	--set xact_abort on
	set nocount on

	--- <TIC>
	declare
		@cDebug int = @Debug + 2 -- Proc level

	if	@Debug & 0x01 = 0x01 begin
		declare
			@TicDT datetime = getdate()
		,	@TocDT datetime
		,	@TimeDiff varchar(max)
		,	@TocMsg varchar(max)
		,	@cDebugMsg varchar(max)

		set @DebugMsg = replicate(' -', (@Debug & 0x3E) / 2) + 'Start ' + user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)
	end
	--- </TIC>

	--- <SP Begin Logging>
	declare
		@LogID int

	insert
		FXSYS.USP_Calls
	(	USP_Name
	,	BeginDT
	,	InArguments
	)
	select
		USP_Name = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)
	,	BeginDT = getdate()
	,	InArguments = convert
			(	varchar(max)
			,	(	select
						[@TranDT] = @TranDT
					,	[@Result] = @Result
					,	[@Debug] = @Debug
					,	[@DebugMsg] = @DebugMsg
					for xml raw			
				)
			)

	set	@LogID = scope_identity()
	--- </SP Begin Logging>

	set	@Result = 999999

	--- <Error Handling>
	declare
		@CallProcName sysname
	,	@TableName sysname
	,	@ProcName sysname
	,	@ProcReturn integer
	,	@ProcResult integer
	,	@Error integer
	,	@RowCount integer

	set	@ProcName = schema_name(objectproperty(@@procid, 'SchemaID')) + '.' + object_name(@@procid)  -- e.g. EDIFACT96A.usp_Test
	--- </Error Handling>

	/*	Record initial transaction count. */
	declare
		@TranCount smallint

	set	@TranCount = @@TranCount

	begin try

		---	<ArgumentValidation>

		---	</ArgumentValidation>

		--- <Tran Required=Yes AutoCreate=Yes TranDTParm=Yes>
		if	@TranCount = 0 begin
			begin tran @ProcName
		end
		else begin
			save tran @ProcName
		end
		set	@TranDT = coalesce(@TranDT, GetDate())
		--- </Tran>

		--- <Body>
		declare
			@StagingProcedureSchema sysname = schema_name(objectproperty(@@procid, 'SchemaID'))
		,	@StagingProcedureName sysname = object_name(@@procid)

		/*	Ensure queue is empty (queue error). */
		set @TocMsg = 'Ensure queue is empty (queue error)'
		if	exists
			(	select
					*
				from
					EDI.EDIDocuments ed
					join FxDependencies.EDI.XML_TradingPartners_StagingDefinition xtpsd
						on xtpsd.DocumentTradingPartner = ed.TradingPartner
						and xtpsd.DocumentType = ed.Type
				where
					ed.Status = 100
					and xtpsd.StagingProcedureSchema = @StagingProcedureSchema
					and xtpsd.StagingProcedureName = @StagingProcedureName
			)
		begin
			/*	Queue error raised below. */

			--- <TOC>
			if	@Debug & 0x01 = 0x01 begin
				set @TocDT = getdate()
				set @TimeDiff =
					case
						when datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01')) > 1
							then convert(varchar, datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01'))) + ' day(s) ' + convert(char(12), @TocDT - @TicDT, 114)
						else
							convert(varchar(12), @TocDT - @TicDT, 114)
					end
				set @DebugMsg = @DebugMsg + char(13) + char(10) + replicate(' -', (@Debug & 0x3E) / 2) + @TocMsg + ': ' + @TimeDiff
				set @TicDT = @TocDT
			end
			set @DebugMsg += coalesce(char(13) + char(10) + @cDebugMsg, N'')
			set @cDebugMsg = null
			--- </TOC>

			/*	Raise queue error. */
			raiserror ('There are already documents in process.  Use %s.usp_ClearQueue to clear the queue if necessary.', 16, 1, @StagingProcedureSchema)
		end

		/*	Move new/reprocessed documents to in process otherwise done. */
		set @TocMsg = 'Move new/reprocessed documents to in process otherwise done'
		if	exists
				(	select
						*
					from
						EDI.EDIDocuments ed
						join FxDependencies.EDI.XML_TradingPartners_StagingDefinition xtpsd
							on xtpsd.DocumentTradingPartner = ed.TradingPartner
							and xtpsd.DocumentType = ed.Type
					where
						ed.Status in (0,2)
						and xtpsd.StagingProcedureSchema = @StagingProcedureSchema
						and xtpsd.StagingProcedureName = @StagingProcedureName
				)
		begin
			--- <Update rows="1+">
			set	@TableName = 'EDI.EDIDocuments'

			update
				ed
			set
				Status = 100
			from
				EDI.EDIDocuments ed
				join FxDependencies.EDI.XML_TradingPartners_StagingDefinition xtpsd
					on xtpsd.DocumentTradingPartner = ed.TradingPartner
					and xtpsd.DocumentType = ed.Type
			where
				ed.Status in (0, 2)
				and xtpsd.StagingProcedureSchema = @StagingProcedureSchema
				and xtpsd.StagingProcedureName = @StagingProcedureName
				and not exists
					(	select
							*
						from
							EDI.EDIDocuments ed
							join FxDependencies.EDI.XML_TradingPartners_StagingDefinition xtpsd
								on xtpsd.DocumentTradingPartner = ed.TradingPartner
								and xtpsd.DocumentType = ed.Type
						where
							ed.Status = 100
							and xtpsd.StagingProcedureSchema = @StagingProcedureSchema
							and xtpsd.StagingProcedureName = @StagingProcedureName
					)

			select
				@Error = @@Error,
				@RowCount = @@Rowcount

			if	@Error != 0 begin
				set	@Result = 999999
				RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
			end
			if	@RowCount <= 0 begin
				set	@Result = 999999
				RAISERROR ('Error updating into %s in procedure %s.  Rows Updated: %d.  Expected rows: 1 or more.', 16, 1, @TableName, @ProcName, @RowCount)
			end
			--- </Update>


			--- <TOC>
			if	@Debug & 0x01 = 0x01 begin
				set @TocDT = getdate()
				set @TimeDiff =
					case
						when datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01')) > 1
							then convert(varchar, datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01'))) + ' day(s) ' + convert(char(12), @TocDT - @TicDT, 114)
						else
							convert(varchar(12), @TocDT - @TicDT, 114)
					end
				set @DebugMsg = @DebugMsg + char(13) + char(10) + replicate(' -', (@Debug & 0x3E) / 2) + @TocMsg + ': ' + @TimeDiff
				set @TicDT = @TocDT
			end
			set @DebugMsg += coalesce(char(13) + char(10) + @cDebugMsg, N'')
			set @cDebugMsg = null
			--- </TOC>
		end
		else begin
			goto done
		end

		/*	Prepare ship schedules. */
		set @TocMsg = 'Prepare ship schedules'
		begin
			--declare
			--	#ShipScheduleHeaders table
			create table
				#ShipScheduleHeaders
			(	RawDocumentGUID uniqueidentifier
			,	Data xml
			,	DocumentImportDT datetime
			,	TradingPartner varchar(50)
			,	DocType varchar(6)
			,	Version varchar(20)
			,	ReleaseNo varchar(30)
			,	DocNumber varchar(50)
			,	ControlNumber varchar(10)
			,	DocumentDT datetime
			,	RowID int not null IDENTITY(1, 1) primary key
			)

			create primary xml index ix1 on #ShipScheduleHeaders(Data)

			insert
				#ShipScheduleHeaders
			(	RawDocumentGUID
			,	Data
			,	DocumentImportDT
			,	TradingPartner
			,	DocType
			,	Version
			--,	ReleaseNo
			,	DocNumber
			,	ControlNumber
			--,	DocumentDT
			)
			select
				RawDocumentGUID = ed.GUID
			,	Data = ed.Data
			,	DocumentImportDT = ed.RowCreateDT
			,	TradingPartner
			,	DocType = ed.Type
			,	Version
			--,	ReleaseNo = coalesce
			--		(	ed.Data.value('(/TRN-DELJIT/SEG-BFR/DE[@code="0328"])[1]', 'varchar(30)')
			--		,	ed.Data.value('(/TRN-DELJIT/SEG-BFR/DE[@code="0127"])[1]', 'varchar(30)')
			--		)
			,	DocNumber
			,	ControlNumber
			--,	DocumentDT = coalesce
			--		(	ed.Data.value('(/TRN-DELJIT/SEG-BFR/DE[@code="0373"])[2]', 'datetime')
			--		,	ed.Data.value('(/TRN-DELJIT/SEG-BFR/DE[@code="0373"])[1]', 'datetime')
			--		)
			from
				EDI.EDIDocuments ed
				join FxDependencies.EDI.XML_TradingPartners_StagingDefinition xtpsd
					on xtpsd.DocumentTradingPartner = ed.TradingPartner
					and xtpsd.DocumentType = ed.Type
			where
				ed.Status = 100
				and xtpsd.StagingProcedureSchema = @StagingProcedureSchema
				and xtpsd.StagingProcedureName = @StagingProcedureName

			update
				ssh
			set	ReleaseNo = Data.value('(/TRN-DELJIT/SEG-BGM/CE/DE[@code="1004"])[1]', 'varchar(30)')
			,	DocumentDT =
					case Data.value('(/TRN-DELJIT/SEG-DTM/CE/DE[.="137"][@code="2005"]/../DE[@code="2379"])[1]', 'varchar(15)')
						when '102' Then FXSYS.udf_GetDT('CCYYMMDD', Data.value('(/TRN-DELJIT/SEG-DTM/CE/DE[.="137"][@code="2005"]/../DE[@code="2380"])[1]', 'varchar(15)'))
						when '103' Then FXSYS.udf_GetDT('CCYYWW', Data.value('(/TRN-DELJIT/SEG-DTM/CE/DE[.="137"][@code="2005"]/../DE[@code="2380"])[1]', 'varchar(15)'))
						when '203' Then FXSYS.udf_GetDT('CCYYMMDDHHMM', Data.value('(/TRN-DELJIT/SEG-DTM/CE/DE[.="137"][@code="2005"]/../DE[@code="2380"])[1]', 'varchar(15)'))
						else Data.value('(/TRN-DELJIT/SEG-DTM/CE/DE[.="137"][@code="2005"]/../DE[@code="2380"])[1]', 'varchar(15)')
					end
			from
				#ShipScheduleHeaders ssh

			if	@Debug & 0x01 = 0x01 begin
				select '#ShipScheduleHeaders', * from #ShipScheduleHeaders ssh
			end

			declare
				@ShipSchedules table
			--create table
			--	@ShipSchedules
			(	RawDocumentGUID uniqueidentifier
			,	ReleaseNo varchar(50)
			,	ShipToCode varchar(50)
			,	ConsigneeCode varchar(50)
			,	ShipFromCode varchar(50)
			,	SupplierCode varchar(50)
			,	CustomerPart varchar(50)
			,	CustomerPO varchar(50)
			,	CustomerPOLine varchar(50)
			,	CustomerModelYear varchar(50)
			,	CustomerECL varchar(50)
			,	Data xml
			,	ParentData xml
			,	RowID int not null IDENTITY(1, 1) primary key
			)

			--create primary xml index ix1 on @ShipSchedules(Data)
			--create xml index ix2 on @ShipSchedules(Data) using xml index ix1 for value

			insert
				@ShipSchedules
			(	RawDocumentGUID
			,	ReleaseNo
			,	ShipToCode
			,	ConsigneeCode
			,	ShipFromCode
			,	SupplierCode
			,	Data
			,	ParentData
			)
			select
				RawDocumentGUID
			,	ReleaseNo = ssh.ReleaseNo
			,	ShipToCode = coalesce(LOOP_LIN.Data.value('(../../LOOP-NAD/SEG-NAD [DE[.="ST"][@code="3035"]]/CE/DE[@code="3039"])[1]', 'varchar(50)'), ssh.Data.value('(/TRN-DELJIT/LOOP-NAD/SEG-NAD [DE[.="SA"][@code="3035"]]/CE/DE[@code="3039"])[1]', 'varchar(50)'))
			,	ConsigneeCode = ssh.Data.value('(/TRN-DELJIT/LOOP-NAD/SEG-NAD [DE[.="IC"][@code="3035"]]/CE/DE[@code="3039"])[1]', 'varchar(50)')
			,	ShipFromCode = ssh.Data.value('(/TRN-DELJIT/LOOP-NAD/SEG-NAD [DE[.="SF"][@code="3035"]]/CE/DE[@code="3039"])[1]', 'varchar(50)')
			,	SupplierCode = ssh.Data.value('(/TRN-DELJIT/LOOP-NAD/SEG-NAD [DE[.="SU"][@code="3035"]]/CE/DE[@code="3039"])[1]', 'varchar(50)')
			,	Data = LOOP_LIN.Data.query('.')
			,	ParentData = LOOP_LIN.Data.query('..')
			from
				#ShipScheduleHeaders ssh
				cross apply ssh.Data.nodes('/TRN-DELJIT/LOOP-SEQ/LOOP-LIN') as LOOP_LIN(Data)

			update
				rp
			set	rp.CustomerPart = coalesce(nullif(Data.value('(for $a in LOOP-LIN/SEG-LIN/CE/DE[@code="7143"] where $a="BP" return $a/../DE[. << $a][@code="7140"][1])[1]', 'varchar(50)'), ''), Data.value('(for $a in LOOP-LIN/SEG-LIN/CE/DE[@code="7143"] where $a="IN" return $a/../DE[. << $a][@code="7140"][1])[1]', 'varchar(50)'))
			,	rp.CustomerPO = coalesce(nullif(Data.value('(for $a in LOOP-LIN/SEG-PIA/CE/DE[@code="7143"] where $a="PO" return $a/../DE[. << $a][@code="7140"][1])[1]', 'varchar(50)'), ''), Data.value('(for $a in LOOP-LIN/LOOP-RFF/SEG-RFF/CE/DE[@code="1153"] where $a="ON" return $a/../DE[. >> $a][@code="1154"][1])[1]', 'varchar(50)'))
			,	rp.CustomerPOLine = Data.value('(for $a in LOOP-LIN/SEG-PIA/CE/DE[@code="7143"] where $a="PL" return $a/../DE[. << $a][@code="7140"][1])[1]', 'varchar(50)')
			,	rp.CustomerModelYear = Data.value('(for $a in LOOP-LIN/SEG-PIA/CE/DE[@code="7143"] where $a="RY" return $a/../DE[. << $a][@code="7140"][1])[1]', 'varchar(50)')
			,	rp.CustomerECL = Data.value('(for $a in LOOP-LIN/SEG-PIA/CE/DE[@code="7143"] where $a="EC" return $a/../DE[. << $a][@code="7140"][1])[1]', 'varchar(50)')
			from
				@ShipSchedules rp

			if	@Debug & 0x01 = 0x01 begin
				select '@ShipSchedules', * from @ShipSchedules rp
			end

			--- <TOC>
			if	@Debug & 0x01 = 0x01 begin
				set @TocDT = getdate()
				set @TimeDiff =
					case
						when datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01')) > 1
							then convert(varchar, datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01'))) + ' day(s) ' + convert(char(12), @TocDT - @TicDT, 114)
						else
							convert(varchar(12), @TocDT - @TicDT, 114)
					end
				set @DebugMsg = @DebugMsg + char(13) + char(10) + replicate(' -', (@Debug & 0x3E) / 2) + @TocMsg + ': ' + @TimeDiff
				set @TicDT = @TocDT
			end
			set @DebugMsg += coalesce(char(13) + char(10) + @cDebugMsg, N'')
			set @cDebugMsg = null
			--- </TOC>
		end

		--return

		/*	Read supplementals. */
		set @TocMsg = 'Read supplementals'
		begin
			declare
				@ShipScheduleSupplementalTemp1 table
			(	RawDocumentGUID uniqueidentifier
			,	ReleaseNo varchar(50)
			,	ShipToCode varchar(50)
			,	ConsigneeCode varchar(50)
			,	ShipFromCode varchar(50)
			,	SupplierCode varchar(50)
			,	CustomerPart varchar(50)
			,	CustomerPO varchar(50)
			,	CustomerPOLine varchar(50)
			,	CustomerModelYear varchar(50)
			,	CustomerECL varchar(50)
			,	ValueQualifier varchar(50)
			,	Value varchar(50)
			)

			insert
				@ShipScheduleSupplementalTemp1
			(	RawDocumentGUID
			,	ReleaseNo
			,	ShipToCode
			,	ConsigneeCode
			,	ShipFromCode
			,	SupplierCode
			,	CustomerPart
			,	CustomerPO
			,	CustomerPOLine
			,	CustomerModelYear
			,	CustomerECL
			,	ValueQualifier
			,	Value
			)
			select
				rp.RawDocumentGUID
			,	rp.ReleaseNo
			,	rp.ShipToCode
			,	rp.ConsigneeCode
			,	rp.ShipFromCode
			,	rp.SupplierCode
			,	rp.CustomerPart
			,	rp.CustomerPO
			,	rp.CustomerPOLine
			,	rp.CustomerModelYear
			,	rp.CustomerECL
			,	ValueQualifier = SEG_PCI.Data.value('(CE/DE[@code="7511"])[1]', 'varchar(50)')
			,	Value = SEG_PCI.Data.value('(CE/DE[@code="7102"])[1]', 'varchar(50)')
			--,	rp.Data
			--,	rp.ParentData
			from
				@ShipSchedules rp
				outer apply rp.ParentData.nodes('/LOOP-SEQ/LOOP-PAC/LOOP-PCI/SEG-PCI') as SEG_PCI(Data)

			insert
				@ShipScheduleSupplementalTemp1
			(	RawDocumentGUID
			,	ReleaseNo
			,	ShipToCode
			,	ConsigneeCode
			,	ShipFromCode
			,	SupplierCode
			,	CustomerPart
			,	CustomerPO
			,	CustomerPOLine
			,	CustomerModelYear
			,	CustomerECL
			,	ValueQualifier
			,	Value
			)
			select
				rp.RawDocumentGUID
			,	rp.ReleaseNo
			,	rp.ShipToCode
			,	rp.ConsigneeCode
			,	rp.ShipFromCode
			,	rp.SupplierCode
			,	rp.CustomerPart
			,	rp.CustomerPO
			,	rp.CustomerPOLine
			,	rp.CustomerModelYear
			,	rp.CustomerECL
			,	ValueQualifier = SEG_LOC.Data.value('(DE[@code="3227"])[1]', 'varchar(50)')
			,	Value = SEG_LOC.Data.value('(CE/DE[@code="3225"])[1]', 'varchar(50)')
			--,	rp.Data
			--,	rp.ParentData
			--,	SEG_LOC.Data.query('.')
			from
				@ShipSchedules rp
				outer apply rp.Data.nodes('/LOOP-LIN/LOOP-LOC/SEG-LOC') as SEG_LOC(Data)

			if	@Debug & 0x01 = 0x01 begin
				select '@ShipScheduleSupplementalTemp1', * from @ShipScheduleSupplementalTemp1 rpst
			end

			declare @ShipScheduleSupplemental table
			(	RawDocumentGUID uniqueidentifier
			,	ReleaseNo varchar(50)
			,	ShipToCode varchar(50)
			,	ConsigneeCode varchar(50)
			,	ShipFromCode varchar(50)
			,	SupplierCode varchar(50)
			,	CustomerPart varchar(50)
			,	CustomerPO varchar(50)
			,	CustomerPOLine varchar(50)
			,	CustomerModelYear varchar(50)
			,	CustomerECL varchar(50)
			,	UserDefined1 varchar(50)  --Dock Code
			,	UserDefined2 varchar(50)  --Line Feed Code
			,	UserDefined3 varchar(50)  --Reserve Line Feed Code
			,	UserDefined4 varchar(50)  --Zone code
			,	UserDefined5 varchar(50)
			,	UserDefined6 varchar(50)
			,	UserDefined7 varchar(50)
			,	UserDefined8 varchar(50)
			,	UserDefined9 varchar(50)
			,	UserDefined10 varchar(50)
			,	UserDefined11 varchar(50) --11Z
			,	UserDefined12 varchar(50) --12Z
			,	UserDefined13 varchar(50) --13Z
			,	UserDefined14 varchar(50) --14Z
			,	UserDefined15 varchar(50) --15Z
			,	UserDefined16 varchar(50) --16Z
			,	UserDefined17 varchar(50) --17Z
			,	UserDefined18 varchar(50)
			,	UserDefined19 varchar(50)
			,	UserDefined20 varchar(50)
			)

			insert
				@ShipScheduleSupplemental
			(	RawDocumentGUID
			,	ReleaseNo
			,	ShipToCode
			,	ConsigneeCode
			,	ShipFromCode
			,	SupplierCode
			,	CustomerPart
			,	CustomerPO
			,	CustomerPOLine
			,	CustomerModelYear
			,	CustomerECL
			,	UserDefined1
			,	UserDefined2
			,	UserDefined3
			,	UserDefined4
			,	UserDefined5
			,	UserDefined6
			,	UserDefined7
			,	UserDefined8
			,	UserDefined9
			,	UserDefined10
			,	UserDefined11
			,	UserDefined12
			,	UserDefined13
			,	UserDefined14
			,	UserDefined15
			,	UserDefined16
			,	UserDefined17
			,	UserDefined18
			,	UserDefined19
			,	UserDefined20
			)
			select
				rpst.RawDocumentGUID
			,	rpst.ReleaseNo
			,	rpst.ShipToCode
			,	rpst.ConsigneeCode
			,	rpst.ShipFromCode
			,	rpst.SupplierCode
			,	rpst.CustomerPart
			,	rpst.CustomerPO
			,	rpst.CustomerPOLine
			,	rpst.CustomerModelYear
			,	rpst.CustomerECL
			,	UserDefined1 = max(case when rpst.ValueQualifier in ('DK', '11') then Value end)
			,	UserDefined2 = max(case when rpst.ValueQualifier in ('LF', '159') then Value end)
			,	UserDefined3 = max(case when rpst.ValueQualifier = 'RL' then Value end)
			,	UserDefined4 = max(case when rpst.ValueQualifier = '??' then Value end)
			,	UserDefined5 = max(case when rpst.ValueQualifier = '??' then Value end)
			,	UserDefined6 = max(case when rpst.ValueQualifier = '??' then Value end)
			,	UserDefined7 = max(case when rpst.ValueQualifier = '??' then Value end)
			,	UserDefined8 = max(case when rpst.ValueQualifier = '??' then Value end)
			,	UserDefined9 = max(case when rpst.ValueQualifier = '??' then Value end)
			,	UserDefined10 = max(case when rpst.ValueQualifier = '??' then Value end)
			,	UserDefined11 = max(case when rpst.ValueQualifier = '11Z' then Value end)
			,	UserDefined12 = max(case when rpst.ValueQualifier = '12Z' then Value end)
			,	UserDefined13 = max(case when rpst.ValueQualifier = '13Z' then Value end)
			,	UserDefined14 = max(case when rpst.ValueQualifier = '14Z' then Value end)
			,	UserDefined15 = max(case when rpst.ValueQualifier = '15Z' then Value end)
			,	UserDefined16 = max(case when rpst.ValueQualifier = '16Z' then Value end)
			,	UserDefined17 = max(case when rpst.ValueQualifier = '17Z' then Value end)
			,	UserDefined18 = max(case when rpst.ValueQualifier = '??' then Value end)
			,	UserDefined19 = max(case when rpst.ValueQualifier = '??' then Value end)
			,	UserDefined20 = max(case when rpst.ValueQualifier = '??' then Value end)
			from
				@ShipScheduleSupplementalTemp1 rpst
			group by
				rpst.RawDocumentGUID
			,	rpst.ReleaseNo
			,	rpst.ShipToCode
			,	rpst.ConsigneeCode
			,	rpst.ShipFromCode
			,	rpst.SupplierCode
			,	rpst.CustomerPart
			,	rpst.CustomerPO
			,	rpst.CustomerPOLine
			,	rpst.CustomerModelYear
			,	rpst.CustomerECL

			if	@Debug & 0x01 = 0x01 begin
				select '@ShipScheduleSupplemental', * from @ShipScheduleSupplemental sss
			end

			--- <TOC>
			if	@Debug & 0x01 = 0x01 begin
				set @TocDT = getdate()
				set @TimeDiff =
					case
						when datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01')) > 1
							then convert(varchar, datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01'))) + ' day(s) ' + convert(char(12), @TocDT - @TicDT, 114)
						else
							convert(varchar(12), @TocDT - @TicDT, 114)
					end
				set @DebugMsg = @DebugMsg + char(13) + char(10) + replicate(' -', (@Debug & 0x3E) / 2) + @TocMsg + ': ' + @TimeDiff
				set @TicDT = @TocDT
			end
			set @DebugMsg += coalesce(char(13) + char(10) + @cDebugMsg, N'')
			set @cDebugMsg = null
			--- </TOC>
		end

		--return

		/*	Read ship accums. */
		set @TocMsg = 'Read ship accums'
		begin
			declare
				@ShipScheduleAccumsTemp1 table
			(	RawDocumentGUID uniqueidentifier
			,	ReleaseNo varchar(50)
			,	ShipToCode varchar(50)
			,	ConsigneeCode varchar(50)
			,	ShipFromCode varchar(50)
			,	SupplierCode varchar(50)
			,	CustomerPart varchar(50)
			,	CustomerPO varchar(50)
			,	CustomerPOLine varchar(50)
			,	CustomerModelYear varchar(50)
			,	CustomerECL varchar(50)
			,	UserDefined1 varchar(50)
			,	UserDefined2 varchar(50)
			,	UserDefined3 varchar(50)
			,	UserDefined4 varchar(50)
			,	UserDefined5 varchar(50)
			,	ReceivedAccum varchar(50)
			,	ReceivedAccumBeginDT varchar(50)
			,	ReceivedAccumEndDT varchar(50)
			,	ReceivedAccumEndDTQualifier varchar(50)
			,	ReceivedQty varchar(50)
			,	ReceivedQtyDT varchar(50)
			,	ReceivedQtyDTQualifier varchar(50)
			,	ReceivedShipper varchar(50)
			)

			insert
				@ShipScheduleAccumsTemp1
			(	RawDocumentGUID
			,	ReleaseNo
			,	ShipToCode
			,	ConsigneeCode
			,	ShipFromCode
			,	SupplierCode
			,	CustomerPart
			,	CustomerPO
			,	CustomerPOLine
			,	CustomerModelYear
			,	CustomerECL
			,	UserDefined1
			,	UserDefined2
			,	UserDefined3
			,	UserDefined4
			,	UserDefined5
			,	ReceivedAccum
			,	ReceivedAccumBeginDT
			,	ReceivedAccumEndDT
			,	ReceivedAccumEndDTQualifier
			,	ReceivedQty
			,	ReceivedQtyDT
			,	ReceivedQtyDTQualifier
			,	ReceivedShipper
			)
			select
				rp.RawDocumentGUID
			,	rp.ReleaseNo
			,	rp.ShipToCode
			,	rp.ConsigneeCode
			,	rp.ShipFromCode
			,	rp.SupplierCode
			,	rp.CustomerPart
			,	rp.CustomerPO
			,	rp.CustomerPOLine
			,	rp.CustomerModelYear
			,	rp.CustomerECL
			,	UserDefined1 = null
			,	UserDefined2 = null
			,	UserDefined3 = null
			,	UserDefined4 = null
			,	UserDefined5 = null
			,	ReceivedAccum = LOOP_QTY_LASTQTY.Data.value('(SEG-QTY/CE/DE[@code="6060"])[1]', 'varchar(50)')
			,	ReceivedAccumBeginDT = LOOP_QTY_LASTQTY.Data.value('(SEG-DTM/CE/DE[.="51"][@code="2005"]/../DE[@code="2380"])[1]', 'varchar(50)')
			,	ReceivedAccumEndDT = LOOP_QTY_LASTQTY.Data.value('(SEG-DTM/CE/DE[.="11"][@code="2005"]/../DE[@code="2380"])[1]', 'varchar(50)')
			,	ReceivedAccumEndDTQualifier = LOOP_QTY_LASTQTY.Data.value('(SEG-DTM/CE/DE[.="11"][@code="2005"]/../DE[@code="2379"])[1]', 'varchar(50)')
			,	ReceivedQty = null
			,	ReceivedQtyDT = null
			,	ReceivedQtyDTQualifier = null
			,	ReceivedShipper = null
			--,	LOOP_RFF.Data.query('.')
			--,	LOOP_QTY_LASTQTY.Data.query('.')
			from
				@ShipSchedules rp
				outer apply rp.Data.nodes('/LOOP-LIN/LOOP-QTY/LOOP-RFF[CE/DE[.="AAK"][@code=1153]]') as LOOP_RFF(Data)
				outer apply rp.Data.nodes('/LOOP-LIN/LOOP-QTY[SEG-QTY/CE/DE[.="3"][@code="6063"]]') as LOOP_QTY_LASTQTY(Data)

			if	@Debug & 0x01 = 0x01 begin
				select '@ShipScheduleAccumsTemp1', * from @ShipScheduleAccumsTemp1 rpat
			end

			declare
				@ShipScheduleAccums table
			(	RawDocumentGUID uniqueidentifier
			,	ReleaseNo varchar(50)
			,	ShipToCode varchar(50)
			,	ConsigneeCode varchar(50)
			,	ShipFromCode varchar(50)
			,	SupplierCode varchar(50)
			,	CustomerPart varchar(50)
			,	CustomerPO varchar(50)
			,	CustomerPOLine varchar(50)
			,	CustomerModelYear varchar(50)
			,	CustomerECL varchar(50)
			,	UserDefined1 varchar(50)
			,	UserDefined2 varchar(50)
			,	UserDefined3 varchar(50)
			,	UserDefined4 varchar(50)
			,	UserDefined5 varchar(50)
			,	ReceivedAccum varchar(50)
			,	ReceivedAccumBeginDT varchar(50)
			,	ReceivedAccumEndDT varchar(50)
			,	ReceivedAccumEndDTQualifier varchar(50)
			,	ReceivedQty varchar(50)
			,	ReceivedQtyDT varchar(50)
			,	ReceivedQtyDTQualifier varchar(50)
			,	ReceivedShipper varchar(50)
			)

			insert
				@ShipScheduleAccums
			(	RawDocumentGUID
			,	ReleaseNo
			,	ShipToCode
			,	ConsigneeCode
			,	ShipFromCode
			,	SupplierCode
			,	CustomerPart
			,	CustomerPO
			,	CustomerPOLine
			,	CustomerModelYear
			,	CustomerECL
			,	UserDefined1
			,	UserDefined2
			,	UserDefined3
			,	UserDefined4
			,	UserDefined5
			,	ReceivedAccum
			,	ReceivedAccumBeginDT
			,	ReceivedAccumEndDT
			,	ReceivedAccumEndDTQualifier
			,	ReceivedQty
			,	ReceivedQtyDT
			,	ReceivedQtyDTQualifier
			,	ReceivedShipper
			)
			select
				RawDocumentGUID
			,	ReleaseNo
			,	ShipToCode
			,	ConsigneeCode
			,	ShipFromCode
			,	SupplierCode
			,	CustomerPart
			,	CustomerPO
			,	CustomerPOLine
			,	CustomerModelYear
			,	CustomerECL
			,	UserDefined1 = null
			,	UserDefined2 = null
			,	UserDefined3 = null
			,	UserDefined4 = null
			,	UserDefined5 = null
			,	ReceivedAccum = max(ReceivedAccum)
			,	ReceivedAccumBeginDT = max(ReceivedAccumBeginDT)
			,	ReceivedAccumEndDT = max(ReceivedAccumEndDT)
			,	ReceivedAccumEndDTQualifier = max(ReceivedAccumEndDTQualifier)
			,	ReceivedQty = max(ReceivedQty)
			,	ReceivedQtyDT = max(ReceivedQtyDT)
			,	ReceivedQtyDTQualifier = max(ReceivedQtyDTQualifier)
			,	ReceivedShipper = max(ReceivedShipper)
			from
				@ShipScheduleAccumsTemp1
			group by
				RawDocumentGUID
			,	ReleaseNo
			,	ShipToCode
			,	ConsigneeCode
			,	ShipFromCode
			,	SupplierCode
			,	CustomerPart
			,	CustomerPO
			,	CustomerPOLine
			,	CustomerModelYear
			,	CustomerECL
			,	UserDefined1
			,	UserDefined2
			,	UserDefined3
			,	UserDefined4
			,	UserDefined5

			if	@Debug & 0x01 = 0x01 begin
				select '@ShipScheduleAccums', * from @ShipScheduleAccums ssa
			end

			--- <TOC>
			if	@Debug & 0x01 = 0x01 begin
				set @TocDT = getdate()
				set @TimeDiff =
					case
						when datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01')) > 1
							then convert(varchar, datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01'))) + ' day(s) ' + convert(char(12), @TocDT - @TicDT, 114)
						else
							convert(varchar(12), @TocDT - @TicDT, 114)
					end
				set @DebugMsg = @DebugMsg + char(13) + char(10) + replicate(' -', (@Debug & 0x3E) / 2) + @TocMsg + ': ' + @TimeDiff
				set @TicDT = @TocDT
			end
			set @DebugMsg += coalesce(char(13) + char(10) + @cDebugMsg, N'')
			set @cDebugMsg = null
			--- </TOC>
		end

		--return

		/*	Read auth accums. */
		set @TocMsg = 'Read auth accums'
		begin
			declare
				@ShipScheduleAuthAccumsTemp1 table
			(	RawDocumentGUID uniqueidentifier
			,	ReleaseNo varchar(50)
			,	ShipToCode varchar(50)
			,	ConsigneeCode varchar(50)
			,	ShipFromCode varchar(50)
			,	SupplierCode varchar(50)
			,	CustomerPart varchar(50)
			,	CustomerPO varchar(50)
			,	CustomerPOLine varchar(50)
			,	CustomerModelYear varchar(50)
			,	CustomerECL varchar(50)
			,	UserDefined1 varchar(50)
			,	UserDefined2 varchar(50)
			,	UserDefined3 varchar(50)
			,	UserDefined4 varchar(50)
			,	UserDefined5 varchar(50)
			,	AuthAccum varchar(50)
			,	AuthAccumBeginDT varchar(50)
			,	AuthAccumEndDT varchar(50)
			,	AuthAccumEndDTQualifier varchar(50)
			,	FabAccum varchar(50)
			,	FabAccumBeginDT varchar(50)
			,	FabAccumEndDT varchar(50)
			,	RawAccum varchar(50)
			,	RawAccumBeginDT varchar(50)
			,	RawAccumEndDT varchar(50)
			)

			insert
				@ShipScheduleAuthAccumsTemp1
			(	RawDocumentGUID
			,	ReleaseNo
			,	ShipToCode
			,	ConsigneeCode
			,	ShipFromCode
			,	SupplierCode
			,	CustomerPart
			,	CustomerPO
			,	CustomerPOLine
			,	CustomerModelYear
			,	CustomerECL
			,	UserDefined1
			,	UserDefined2
			,	UserDefined3
			,	UserDefined4
			,	UserDefined5
			,	AuthAccum
			,	AuthAccumBeginDT
			,	AuthAccumEndDT
			,	AuthAccumEndDTQualifier
			,	FabAccum
			,	FabAccumBeginDT
			,	FabAccumEndDT
			,	RawAccum
			,	RawAccumBeginDT
			,	RawAccumEndDT
			)
			select
				rp.RawDocumentGUID
			,	rp.ReleaseNo
			,	rp.ShipToCode
			,	rp.ConsigneeCode
			,	rp.ShipFromCode
			,	rp.SupplierCode
			,	rp.CustomerPart
			,	rp.CustomerPO
			,	rp.CustomerPOLine
			,	rp.CustomerModelYear
			,	rp.CustomerECL
			,	UserDefined1 = null
			,	UserDefined2 = null
			,	UserDefined3 = null
			,	UserDefined4 = null
			,	UserDefined5 = null
			,	AuthAccum = LOOP_QTY_CUM.Data.value('(SEG-QTY/CE/DE[@code="6060"])[1]', 'varchar(50)')
			,	AuthAccumBeginDT = LOOP_QTY_CUM.Data.value('(SEG-DTM/CE/DE[.="51"][@code="2005"]/../DE[@code="2380"])[1]', 'varchar(50)')
			,	AuthAccumEndDT = LOOP_QTY_CUM.Data.value('(SEG-DTM/CE/DE[.="52"][@code="2005"]/../DE[@code="2380"])[1]', 'varchar(50)')
			,	AuthAccumEndDTQualifier = LOOP_QTY_CUM.Data.value('(SEG-DTM/CE/DE[.="52"][@code="2005"]/../DE[@code="2379"])[1]', 'varchar(50)')
			,	FabAccum = null
			,	FabAccumBeginDT = null
			,	FabAccumEndDT = null
			,	RawAccum = null
			,	RawAccumBeginDT = null
			,	RawAccumEndDT = null
			--,	LOOP_QTY_CUM.Data.query('.')
			from
				@ShipSchedules rp
				outer apply rp.Data.nodes('/LOOP-LIN/LOOP-QTY[SEG-QTY/CE/DE[.="79"][@code="6063"]]') as LOOP_QTY_CUM(Data)

			if	@Debug & 0x01 = 0x01 begin
				select '@ShipScheduleAuthAccumsTemp1', * from @ShipScheduleAuthAccumsTemp1 rpaat
			end

			declare
				@ShipScheduleAuthAccums table
			(	RawDocumentGUID uniqueidentifier
			,	ReleaseNo varchar(50)
			,	ShipToCode varchar(50)
			,	ConsigneeCode varchar(50)
			,	ShipFromCode varchar(50)
			,	SupplierCode varchar(50)
			,	CustomerPart varchar(50)
			,	CustomerPO varchar(50)
			,	CustomerPOLine varchar(50)
			,	CustomerModelYear varchar(50)
			,	CustomerECL varchar(50)
			,	UserDefined1 varchar(50)
			,	UserDefined2 varchar(50)
			,	UserDefined3 varchar(50)
			,	UserDefined4 varchar(50)
			,	UserDefined5 varchar(50)
			,	AuthAccum varchar(50)
			,	AuthAccumBeginDT varchar(50)
			,	AuthAccumEndDT varchar(50)
			,	AuthAccumEndDTQualifier varchar(50)
			,	FabAccum varchar(50)
			,	FabAccumBeginDT varchar(50)
			,	FabAccumEndDT varchar(50)
			,	RawAccum varchar(50)
			,	RawAccumBeginDT varchar(50)
			,	RawAccumEndDT varchar(50)
			)

			insert
				@ShipScheduleAuthAccums
			(	RawDocumentGUID
			,	ReleaseNo
			,	ShipToCode
			,	ConsigneeCode
			,	ShipFromCode
			,	SupplierCode
			,	CustomerPart
			,	CustomerPO
			,	CustomerPOLine
			,	CustomerModelYear
			,	CustomerECL
			,	UserDefined1
			,	UserDefined2
			,	UserDefined3
			,	UserDefined4
			,	UserDefined5
			,	AuthAccum
			,	AuthAccumBeginDT
			,	AuthAccumEndDT
			,	AuthAccumEndDTQualifier
			,	FabAccum
			,	FabAccumBeginDT
			,	FabAccumEndDT
			,	RawAccum
			,	RawAccumBeginDT
			,	RawAccumEndDT
			)
			select
				RawDocumentGUID
			,	ReleaseNo
			,	ShipToCode
			,	ConsigneeCode
			,	ShipFromCode
			,	SupplierCode
			,	CustomerPart
			,	CustomerPO
			,	CustomerPOLine
			,	CustomerModelYear
			,	CustomerECL
			,	UserDefined1 = null
			,	UserDefined2 = null
			,	UserDefined3 = null
			,	UserDefined4 = null
			,	UserDefined5 = null
			,	AuthAccum = max(AuthAccum)
			,	AuthAccumBeginDT = max(AuthAccumBeginDT)
			,	AuthAccumEndDT = max(AuthAccumEndDT)
			,	AuthAccumEndDTQualifier = max(AuthAccumEndDTQualifier)
			,	FabAccum = max(FabAccum)
			,	FabAccumBeginDT = max(FabAccumBeginDT)
			,	FabAccumEndDT = max(FabAccumEndDT)
			,	RawAccum = max(RawAccum)
			,	RawAccumBeginDT = max(RawAccumBeginDT)
			,	RawAccumEndDT = max(RawAccumEndDT)
			from
				@ShipScheduleAuthAccumsTemp1
			group by
				RawDocumentGUID
			,	ReleaseNo
			,	ShipToCode
			,	ConsigneeCode
			,	ShipFromCode
			,	SupplierCode
			,	CustomerPart
			,	CustomerPO
			,	CustomerPOLine
			,	CustomerModelYear
			,	CustomerECL
			,	UserDefined1
			,	UserDefined2
			,	UserDefined3
			,	UserDefined4
			,	UserDefined5

			if	@Debug & 0x01 = 0x01 begin
				select '@ShipScheduleAuthAccums', * from @ShipScheduleAuthAccums ssaa
			end

			--- <TOC>
			if	@Debug & 0x01 = 0x01 begin
				set @TocDT = getdate()
				set @TimeDiff =
					case
						when datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01')) > 1
							then convert(varchar, datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01'))) + ' day(s) ' + convert(char(12), @TocDT - @TicDT, 114)
						else
							convert(varchar(12), @TocDT - @TicDT, 114)
					end
				set @DebugMsg = @DebugMsg + char(13) + char(10) + replicate(' -', (@Debug & 0x3E) / 2) + @TocMsg + ': ' + @TimeDiff
				set @TicDT = @TocDT
			end
			set @DebugMsg += coalesce(char(13) + char(10) + @cDebugMsg, N'')
			set @cDebugMsg = null
			--- </TOC>
		end

		--return

		/*	Read shipping releases. */
		set @TocMsg = 'Read shipping releases'
		begin
			declare
				@ShipScheduleReleases table
			(	RawDocumentGUID uniqueidentifier
			,	ReleaseNo varchar(50)
			,	ShipToCode varchar(50)
			,	ConsigneeCode varchar(50)
			,	ShipFromCode varchar(50)
			,	SupplierCode varchar(50)
			,	CustomerPart varchar(50)
			,	CustomerPO varchar(50)
			,	CustomerPOLine varchar(50)
			,	CustomerModelYear varchar(50)
			,	CustomerECL varchar(50)
			,	UserDefined1 varchar(50)
			,	UserDefined2 varchar(50)
			,	UserDefined3 varchar(50)
			,	UserDefined4 varchar(50)
			,	UserDefined5 varchar(50)
			,	ScheduleType varchar(50)
			,	DateDue varchar(50)
			,	DateDueQualifier varchar(50)
			,	QuantityDue varchar(50)
			,	QuantityType varchar(50)
			)

			insert
				@ShipScheduleReleases
			(	RawDocumentGUID
			,	ReleaseNo
			,	ShipToCode
			,	ConsigneeCode
			,	ShipFromCode
			,	SupplierCode
			,	CustomerPart
			,	CustomerPO
			,	CustomerPOLine
			,	CustomerModelYear
			,	CustomerECL
			,	UserDefined1
			,	UserDefined2
			,	UserDefined3
			,	UserDefined4
			,	UserDefined5
			,	ScheduleType
			,	DateDue
			,	DateDueQualifier
			,	QuantityDue
			,	QuantityType
			)
			select
				rp.RawDocumentGUID
			,	rp.ReleaseNo
			,	rp.ShipToCode
			,	rp.ConsigneeCode
			,	rp.ShipFromCode
			,	rp.SupplierCode
			,	rp.CustomerPart
			,	rp.CustomerPO
			,	rp.CustomerPOLine
			,	rp.CustomerModelYear
			,	rp.CustomerECL
			,	UserDefined1 = null
			,	UserDefined2 = null
			,	UserDefined3 = null
			,	UserDefined4 = null
			,	UserDefined5 = null
			,	ScheduleType  = LOOP_QTY.Data.value('(../SEG-SCC/DE[@code="4017"])[1]', 'varchar(50)')
			,	DateDue = LOOP_QTY.Data.value('(SEG-DTM/CE/DE[@code="2380"])[1]', 'varchar(50)')
			,	DateDueQualifier = LOOP_QTY.Data.value('(SEG-DTM/CE/DE[@code="2379"])[1]', 'varchar(50)')
			,	QuantityDue = LOOP_QTY.Data.value('(SEG-QTY/CE/DE[@code="6060"])[1]', 'varchar(50)')
			,	QuantityType = LOOP_QTY.Data.value('(SEG-DTM/CE/DE[@code="2005"])[1]', 'varchar(50)')
			from
				@ShipSchedules rp
				cross apply rp.Data.nodes('/LOOP-LIN/LOOP-QTY[SEG-QTY/CE/DE[.="1"][@code="6063"]]') as LOOP_QTY(Data)

			if	@Debug & 0x01 = 0x01 begin
				select '@ShipScheduleReleases', * from @ShipScheduleReleases ssr
			end

			--- <TOC>
			if	@Debug & 0x01 = 0x01 begin
				set @TocDT = getdate()
				set @TimeDiff =
					case
						when datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01')) > 1
							then convert(varchar, datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01'))) + ' day(s) ' + convert(char(12), @TocDT - @TicDT, 114)
						else
							convert(varchar(12), @TocDT - @TicDT, 114)
					end
				set @DebugMsg = @DebugMsg + char(13) + char(10) + replicate(' -', (@Debug & 0x3E) / 2) + @TocMsg + ': ' + @TimeDiff
				set @TicDT = @TocDT
			end
			set @DebugMsg += coalesce(char(13) + char(10) + @cDebugMsg, N'')
			set @cDebugMsg = null
			--- </TOC>
		end

		--return

		/*	Write to ship schedule tables. */
		set @TocMsg = 'Write to ship schedule tables. '
		begin
			insert
				EDIFACT97A.ShipScheduleHeaders
			(	RawDocumentGUID
			,	DocumentImportDT
			,	TradingPartner
			,	DocType
			,	Version
			,	Release
			,	DocNumber
			,	ControlNumber
			,	DocumentDT
			)
			select
				ssh.RawDocumentGUID
			,	ssh.DocumentImportDT
			,	ssh.TradingPartner
			,	ssh.DocType
			,	ssh.Version
			,	ssh.ReleaseNo
			,	ssh.DocNumber
			,	ssh.ControlNumber
			,	ssh.DocumentDT
			from
				#ShipScheduleHeaders ssh

			if	@Debug & 0x01 = 0x01 begin
				select 'EDIFACT97A.ShipScheduleHeaders', * from EDIFACT97A.ShipScheduleHeaders ssh
			end

			insert
				EDIFACT97A.ShipScheduleSupplemental
			(	RawDocumentGUID
			,	ReleaseNo
			,	ShipToCode
			,	ConsigneeCode
			,	ShipFromCode
			,	SupplierCode
			,	CustomerPart
			,	CustomerPO
			,	CustomerPOLine
			,	CustomerModelYear
			,	CustomerECL
			,	UserDefined1
			,	UserDefined2
			,	UserDefined3
			,	UserDefined4
			,	UserDefined5
			,	UserDefined6
			,	UserDefined7
			,	UserDefined8
			,	UserDefined9
			,	UserDefined10
			,	UserDefined11
			,	UserDefined12
			,	UserDefined13
			,	UserDefined14
			,	UserDefined15
			,	UserDefined16
			,	UserDefined17
			,	UserDefined18
			,	UserDefined19
			,	UserDefined20
			)
			select
				sss.RawDocumentGUID
			,	sss.ReleaseNo
			,	sss.ShipToCode
			,	sss.ConsigneeCode
			,	sss.ShipFromCode
			,	sss.SupplierCode
			,	sss.CustomerPart
			,	sss.CustomerPO
			,	sss.CustomerPOLine
			,	sss.CustomerModelYear
			,	sss.CustomerECL
			,	sss.UserDefined1
			,	sss.UserDefined2
			,	sss.UserDefined3
			,	sss.UserDefined4
			,	sss.UserDefined5
			,	sss.UserDefined6
			,	sss.UserDefined7
			,	sss.UserDefined8
			,	sss.UserDefined9
			,	sss.UserDefined10
			,	sss.UserDefined11
			,	sss.UserDefined12
			,	sss.UserDefined13
			,	sss.UserDefined14
			,	sss.UserDefined15
			,	sss.UserDefined16
			,	sss.UserDefined17
			,	sss.UserDefined18
			,	sss.UserDefined19
			,	sss.UserDefined20
			from
				@ShipScheduleSupplemental sss

			if	@Debug & 0x01 = 0x01 begin
				select 'EDIFACT97A.ShipScheduleSupplemental', * from EDIFACT97A.ShipScheduleSupplemental rps
			end

			insert
				EDIFACT97A.ShipScheduleAccums
			(	RawDocumentGUID
			,	ReleaseNo
			,	ShipToCode
			,	ConsigneeCode
			,	ShipFromCode
			,	SupplierCode
			,	CustomerPart
			,	CustomerPO
			,	CustomerPOLine
			,	CustomerModelYear
			,	CustomerECL
			,	UserDefined1
			,	UserDefined2
			,	UserDefined3
			,	UserDefined4
			,	UserDefined5
			,	LastQtyReceived
			,	LastQtyDT
			,	LastShipper
			,	LastAccumQty
			,	LastAccumDT
			)
			select
				ssa.RawDocumentGUID
			,	ssa.ReleaseNo
			,	ssa.ShipToCode
			,	ssa.ConsigneeCode
			,	ssa.ShipFromCode
			,	ssa.SupplierCode
			,	ssa.CustomerPart
			,	ssa.CustomerPO
			,	ssa.CustomerPOLine
			,	ssa.CustomerModelYear
			,	ssa.CustomerECL
			,	ssa.UserDefined1
			,	ssa.UserDefined2
			,	ssa.UserDefined3
			,	ssa.UserDefined4
			,	ssa.UserDefined5
			,	LastQtyReceived = nullif(ssa.ReceivedQty, '')
			,	LastQtyDT =
					case
						when datalength(ssa.ReceivedQtyDT) = 6
							then FXSYS.udf_GetDT('YYMMDD', ssa.ReceivedQtyDT)
						when datalength(ssa.ReceivedQtyDT) = 8
							then FXSYS.udf_GetDT('CCYYMMDD', ssa.ReceivedQtyDT)
						else convert(datetime, ssa.ReceivedQtyDT)
					end
			,	LastShipper = ssa.ReceivedShipper
			,	LastAccumQty = nullif(ssa.ReceivedAccum, '')
			,	LastAccumDT =
					case
						when datalength(ssa.ReceivedAccumEndDT) = 6
							then FXSYS.udf_GetDT('YYMMDD', ssa.ReceivedAccumEndDT)
						when datalength(ssa.ReceivedAccumEndDT) = 8
							then FXSYS.udf_GetDT('CCYYMMDD', ssa.ReceivedAccumEndDT)
						else convert(datetime, ssa.ReceivedAccumEndDT)
					end
			from
				@ShipScheduleAccums ssa

			if	@Debug & 0x01 = 0x01 begin
				select 'EDIFACT97A.ShipScheduleAccums', * from EDIFACT97A.ShipScheduleAccums rpa
			end

			insert
				EDIFACT97A.ShipScheduleAuthAccums
			(	RawDocumentGUID
			,	ReleaseNo
			,	ShipToCode
			,	ConsigneeCode
			,	ShipFromCode
			,	SupplierCode
			,	CustomerPart
			,	CustomerPO
			,	CustomerPOLine
			,	CustomerModelYear
			,	CustomerECL
			,	PriorCUMStartDT
			,	PriorCUMEndDT
			,	PriorCUM
			,	FABCUMStartDT
			,	FABCUMEndDT
			,	FABCUM
			,	RAWCUMStartDT
			,	RAWCUMEndDT
			,	RAWCUM
			)
			select
				ssaa.RawDocumentGUID
			,	ssaa.ReleaseNo
			,	ssaa.ShipToCode
			,	ssaa.ConsigneeCode
			,	ssaa.ShipFromCode
			,	ssaa.SupplierCode
			,	ssaa.CustomerPart
			,	ssaa.CustomerPO
			,	ssaa.CustomerPOLine
			,	ssaa.CustomerModelYear
			,	ssaa.CustomerECL
			,	PriorCUMStartDT =
					case
						when datalength(ssaa.AuthAccumBeginDT) = 6
							then FXSYS.udf_GetDT('YYMMDD', ssaa.AuthAccumBeginDT)
						when datalength(ssaa.AuthAccumBeginDT) = 8
							then FXSYS.udf_GetDT('CCYYMMDD', ssaa.AuthAccumBeginDT)
						else convert(datetime, ssaa.AuthAccumBeginDT)
					end
			,	PriorCUMEndDT =
					case
						when datalength(ssaa.AuthAccumEndDT) = 6
							then FXSYS.udf_GetDT('YYMMDD', ssaa.AuthAccumEndDT)
						when datalength(ssaa.AuthAccumEndDT) = 8
							then FXSYS.udf_GetDT('CCYYMMDD', ssaa.AuthAccumEndDT)
						else convert(datetime, ssaa.AuthAccumEndDT)
					end
			,	PriorCUM = nullif(ssaa.AuthAccum, '')
			,	FABCUMStartDT =
					case
						when datalength(ssaa.FabAccumBeginDT) = 6
							then FXSYS.udf_GetDT('YYMMDD', ssaa.FabAccumBeginDT)
						when datalength(ssaa.FabAccumBeginDT) = 8
							then FXSYS.udf_GetDT('CCYYMMDD', ssaa.FabAccumBeginDT)
						else convert(datetime, ssaa.FabAccumBeginDT)
					end
			,	FABCUMEndDT =
					case
						when datalength(ssaa.FabAccumEndDT) = 6
							then FXSYS.udf_GetDT('YYMMDD', ssaa.FabAccumEndDT)
						when datalength(ssaa.AuthAccumEndDT) = 8
							then FXSYS.udf_GetDT('CCYYMMDD', ssaa.FabAccumEndDT)
						else convert(datetime, ssaa.FabAccumEndDT)
					end
			,	FABCUM = nullif(ssaa.FabAccum, '')
			,	RAWCUMStartDT =
					case
						when datalength(ssaa.RawAccumBeginDT) = 6
							then FXSYS.udf_GetDT('YYMMDD', ssaa.RawAccumBeginDT)
						when datalength(ssaa.RawAccumBeginDT) = 8
							then FXSYS.udf_GetDT('CCYYMMDD', ssaa.RawAccumBeginDT)
						else convert(datetime, ssaa.RawAccumBeginDT)
					end
			,	RAWCUMEndDT =
					case
						when datalength(ssaa.RawAccumEndDT) = 6
							then FXSYS.udf_GetDT('YYMMDD', ssaa.RawAccumEndDT)
						when datalength(ssaa.RawAccumEndDT) = 8
							then FXSYS.udf_GetDT('CCYYMMDD', ssaa.RawAccumEndDT)
						else convert(datetime, ssaa.RawAccumEndDT)
					end
			,	RAWCUM = nullif(ssaa.RawAccum, '')
			from
				@ShipScheduleAuthAccums ssaa

			if	@Debug & 0x01 = 0x01 begin
				select 'EDIFACT97A.ShipScheduleAuthAccums', * from EDIFACT97A.ShipScheduleAuthAccums rpaa
			end

			insert
				EDIFACT97A.ShipScheduleReleases
			(	RawDocumentGUID
			,	ReleaseNo
			,	ShipToCode
			,	ConsigneeCode
			,	ShipFromCode
			,	SupplierCode
			,	CustomerPart
			,	CustomerPO
			,	CustomerPOLine
			,	CustomerModelYear
			,	CustomerECL
			,	UserDefined1
			,	UserDefined2
			,	UserDefined3
			,	UserDefined4
			,	UserDefined5
			,	ScheduleType
			,	ReleaseQty
			,	ReleaseDT
			)
			select
				ssr.RawDocumentGUID
			,	ssr.ReleaseNo
			,	ssr.ShipToCode
			,	ssr.ConsigneeCode
			,	ssr.ShipFromCode
			,	ssr.SupplierCode
			,	ssr.CustomerPart
			,	ssr.CustomerPO
			,	ssr.CustomerPOLine
			,	ssr.CustomerModelYear
			,	ssr.CustomerECL
			,	ssr.UserDefined1
			,	ssr.UserDefined2
			,	ssr.UserDefined3
			,	ssr.UserDefined4
			,	ssr.UserDefined5
			,	ScheduleType = ssr.ScheduleType
			,	ReleaseQty = nullif(ssr.QuantityDue, '')
			,	ReleaseDT =
					case ssr.DateDueQualifier
						when '102'
							then FXSYS.udf_GetDT('CCYYMMDD', ssr.DateDue)
						when '103'
							then FXSYS.udf_GetDT('YYMMDD', ssr.DateDue)
						when '203'
							then FXSYS.udf_GetDT('CCYYMMDDHHMM', ssr.DateDue)
						else convert(datetime, ssr.DateDue)
					end
			from
				@ShipScheduleReleases ssr

			if	@Debug & 0x01 = 0x01 begin
				select 'EDIFACT97A.ShipScheduleReleases', * from EDIFACT97A.ShipScheduleReleases ssr
			end

			--- <TOC>
			if	@Debug & 0x01 = 0x01 begin
				set @TocDT = getdate()
				set @TimeDiff =
					case
						when datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01')) > 1
							then convert(varchar, datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01'))) + ' day(s) ' + convert(char(12), @TocDT - @TicDT, 114)
						else
							convert(varchar(12), @TocDT - @TicDT, 114)
					end
				set @DebugMsg = @DebugMsg + char(13) + char(10) + replicate(' -', (@Debug & 0x3E) / 2) + @TocMsg + ': ' + @TimeDiff
				set @TicDT = @TocDT
			end
			set @DebugMsg += coalesce(char(13) + char(10) + @cDebugMsg, N'')
			set @cDebugMsg = null
			--- </TOC>
		end

		/*	Set in process documents to processed. */
		set @TocMsg = 'Set in process documents to processed'
		begin
			--- <Update rows="1+">
			set	@TableName = 'EDI.EDIDocuments'

			update
				ed
			set
				Status = 1
			from
				EDI.EDIDocuments ed
				join FxDependencies.EDI.XML_TradingPartners_StagingDefinition xtpsd
					on xtpsd.DocumentTradingPartner = ed.TradingPartner
					and xtpsd.DocumentType = ed.Type
			where
				ed.Status = 100
				and xtpsd.StagingProcedureSchema = @StagingProcedureSchema
				and xtpsd.StagingProcedureName = @StagingProcedureName

			select
				@Error = @@Error,
				@RowCount = @@Rowcount

			if	@Error != 0 begin
				set	@Result = 999999
				RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
			end
			if	@RowCount <= 0 begin
				set	@Result = 999999
				RAISERROR ('Error updating into %s in procedure %s.  Rows Updated: %d.  Expected rows: 1 or more.', 16, 1, @TableName, @ProcName, @RowCount)
			end
			--- </Update>

			--- <TOC>
			if	@Debug & 0x01 = 0x01 begin
				set @TocDT = getdate()
				set @TimeDiff =
					case
						when datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01')) > 1
							then convert(varchar, datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01'))) + ' day(s) ' + convert(char(12), @TocDT - @TicDT, 114)
						else
							convert(varchar(12), @TocDT - @TicDT, 114)
					end
				set @DebugMsg = @DebugMsg + char(13) + char(10) + replicate(' -', (@Debug & 0x3E) / 2) + @TocMsg + ': ' + @TimeDiff
				set @TicDT = @TocDT
			end
			set @DebugMsg += coalesce(char(13) + char(10) + @cDebugMsg, N'')
			set @cDebugMsg = null
			--- </TOC>
		end
		--- </Body>

		done:
		---	<CloseTran AutoCommit=Yes>
		if	@TranCount = 0 begin
			commit tran @ProcName
		end
		---	</CloseTran AutoCommit=Yes>

		--- <SP End Logging>
		update
			uc
		set	EndDT = getdate()
		,	OutArguments = convert
				(	varchar(max)
				,	(	select
							[@TranDT] = @TranDT
						,	[@Result] = @Result
						,	[@DebugMsg] = @DebugMsg
						for xml raw			
					)
				)
		from
			FXSYS.USP_Calls uc
		where
			uc.RowID = @LogID
		--- </SP End Logging>

		--- <TIC/TOC END>
		if	@Debug & 0x3F = 0x01 begin
			set @DebugMsg = @DebugMsg + char(13) + char(10)
			print @DebugMsg
		end
		--- </TIC/TOC END>

		---	<Return>
		set	@Result = 0
		return
			@Result
		--- </Return>
	end try
	begin catch
		declare
			@errorSeverity int
		,	@errorState int
		,	@errorMessage nvarchar(2048)
		,	@xact_state int
	
		select
			@errorSeverity = error_severity()
		,	@errorState = error_state ()
		,	@errorMessage = error_message()
		,	@xact_state = xact_state()

		execute FXSYS.usp_PrintError

		if	@xact_state = -1 begin 
			rollback
			execute FXSYS.usp_LogError
		end
		if	@xact_state = 1 and @TranCount = 0 begin
			rollback
			execute FXSYS.usp_LogError
		end
		if	@xact_state = 1 and @TranCount > 0 begin
			rollback transaction @ProcName
			execute FXSYS.usp_LogError
		end

		raiserror(@errorMessage, @errorSeverity, @errorState)
	end catch
end

/*
Example:
Initial queries
{

}

Test syntax
{

set statistics io on
set statistics time on
go

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = EDIFACT97A.usp_StageShipSchedules
	@TranDT = @TranDT out
,	@Result = @ProcResult out
,	@Debug = 1

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult
go

if	@@trancount > 0 begin
	rollback
end
go

set statistics io off
set statistics time off
go

}

Results {
}
*/
GO
