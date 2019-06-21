
--begin transaction
--go

declare
	@ShipperID int = 90576
,	@XMLShipNotice_FunctionName sysname = null
,	@XMLData xml = convert(xml, N'
<TRN-856>
	<TRN-INFO name="SHIP NOTICE/MANIFEST" trading_partner="BENTELER" standard="X" agency="X" version="004010" type="856" doc_number="90576" control_number="0960" />
	<SEG-BSN>
		<SEG-INFO code="BSN" name="BEGINNING SEGMENT FOR SHIP NOTICE" />
		<DE code="0353" name="TRANSACTION SET PURPOSE CODE" type="ID" desc="Original">00</DE>
		<DE code="0396" name="SHIPMENT IDENTIFICATION" type="AN">90576</DE>
		<DE code="0373" name="DATE" type="DT">20190620</DE>
		<DE code="0337" name="TIME" type="TM">0930</DE>
	</SEG-BSN>
	<SEG-DTM>
		<SEG-INFO code="DTM" name="DATE/TIME REFERENCE" />
		<DE code="0374" name="DATE/TIME QUALIFIER" type="ID" desc="Shipped">011</DE>
		<DE code="0373" name="DATE" type="DT">20190620</DE>
		<DE code="0337" name="TIME" type="TM">0930</DE>
	</SEG-DTM>
	<LOOP-HL>
		<LOOP-INFO name="HL Loop" />
		<SEG-HL>
			<SEG-INFO code="HL" name="HIERARCHICAL LEVEL" />
			<DE code="0628" name="HIERARCHICAL ID NUMBER" type="AN">1</DE>
			<DE code="0734" name="HIERARCHICAL PARENT ID NUMBER" type="AN" />
			<DE code="0735" name="HIERARCHICAL LEVEL CODE" type="ID" desc="Shipment">S</DE>
		</SEG-HL>
		<SEG-TD1>
			<SEG-INFO code="TD1" name="CARRIER DETAILS (QUANTITY AND WEIGHT)" />
			<DE code="0103" name="PACKAGING CODE" type="AN" />
			<DE code="0080" name="LADING QUANTITY" type="N">38</DE>
		</SEG-TD1>
		<SEG-TD5>
			<SEG-INFO code="TD5" name="CARRIER DETAILS (ROUTING SEQUENCE/TRANS" />
			<DE code="0133" name="ROUTING SEQUENCE CODE" type="ID" desc="Origin/Delivery Carrier (Any Mode)">B</DE>
			<DE code="0066" name="IDENTIFICATION CODE QUALIFIER" type="ID" desc="Standard Carrier Alpha Code (SCAC)">2</DE>
			<DE code="0067" name="IDENTIFICATION CODE" type="AN">XPCA                                                                        4</DE>
			<DE code="0091" name="TRANSPORTATION METHOD/TYPE CODE" type="ID" desc="Motor (Common Carrier)">M</DE>
		</SEG-TD5>
		<LOOP-TD3>
			<LOOP-INFO name="TD3 Loop" />
			<SEG-TD3>
				<SEG-INFO code="TD3" name="CARRIER DETAILS (EQUIPMENT)" />
				<DE code="0040" name="EQUIPMENT DESCRIPTION CODE" type="ID" desc="Trailer (not otherwise specified)">TL</DE>
				<DE code="0206" name="EQUIPMENT INITIAL" type="AN" />
				<DE code="0207" name="EQUIPMENT NUMBER" type="AN">53309</DE>
			</SEG-TD3>
		</LOOP-TD3>
		<LOOP-N1>
			<LOOP-INFO name="N1 Loop" />
			<SEG-N1>
				<SEG-INFO code="N1" name="PARTY IDENTIFICATION" />
				<DE code="0098" name="ENTITY IDENTIFIER CODE" type="ID" desc="Ship To">ST</DE>
				<DE code="0093" name="NAME" type="AN">BENTELER AUTOMOTIVE</DE>
				<DE code="0066" name="IDENTIFICATION CODE QUALIFIER" type="ID" desc="Purchasing Office">98</DE>
				<DE code="0067" name="IDENTIFICATION CODE" type="AN">0445</DE>
			</SEG-N1>
		</LOOP-N1>
		<LOOP-N1>
			<LOOP-INFO name="N1 Loop" />
			<SEG-N1>
				<SEG-INFO code="N1" name="PARTY IDENTIFICATION" />
				<DE code="0098" name="ENTITY IDENTIFIER CODE" type="ID" desc="Supplier/Manufacturer">SU</DE>
				<DE code="0093" name="NAME" type="AN" />
				<DE code="0066" name="IDENTIFICATION CODE QUALIFIER" type="ID" desc="ZIP Code">16</DE>
				<DE code="0067" name="IDENTIFICATION CODE" type="AN">2112779  </DE>
			</SEG-N1>
		</LOOP-N1>
	</LOOP-HL>
	<LOOP-HL>
		<LOOP-INFO name="HL Loop" />
		<SEG-HL>
			<SEG-INFO code="HL" name="HIERARCHICAL LEVEL" />
			<DE code="0628" name="HIERARCHICAL ID NUMBER" type="AN">2</DE>
			<DE code="0734" name="HIERARCHICAL PARENT ID NUMBER" type="AN">1</DE>
			<DE code="0735" name="HIERARCHICAL LEVEL CODE" type="ID" desc="Item">I</DE>
		</SEG-HL>
		<SEG-LIN>
			<SEG-INFO code="LIN" name="ITEM IDENTIFICATION" />
			<DE code="0350" name="ASSIGNED IDENTIFICATION" type="AN" />
			<DE code="0235" name="PRODUCT/SERVICE ID QUALIFIER" type="ID" desc="Buyer&apos;s Part Number">BP</DE>
			<DE code="0234" name="PRODUCT/SERVICE ID" type="AN">13007607</DE>
			<DE code="0235" name="PRODUCT/SERVICE ID QUALIFIER" type="ID" desc="Engineering Change Level">EC</DE>
			<DE code="0234" name="PRODUCT/SERVICE ID" type="AN">07</DE>
			<DE code="0235" name="PRODUCT/SERVICE ID QUALIFIER" type="ID" desc="Purchaser&apos;s Order Line Number">PL</DE>
			<DE code="0234" name="PRODUCT/SERVICE ID" type="AN">00020</DE>
			<DE code="0235" name="PRODUCT/SERVICE ID QUALIFIER" type="ID" desc="Purchase Order Number">PO</DE>
			<DE code="0234" name="PRODUCT/SERVICE ID" type="AN">50001656</DE>
			<DE code="0235" name="PRODUCT/SERVICE ID QUALIFIER" type="ID" desc="Release Number">RN</DE>
			<DE code="0234" name="PRODUCT/SERVICE ID" type="AN">225</DE>
		</SEG-LIN>
		<SEG-SN1>
			<SEG-INFO code="SN1" name="ITEM DETAIL (SHIPMENT)" />
			<DE code="0350" name="ASSIGNED IDENTIFICATION" type="AN" />
			<DE code="0382" name="NUMBER OF UNITS SHIPPED" type="N">3800</DE>
			<DE code="0355" name="UNIT OR BASIS FOR MEASUREMENT CODE" type="ID" desc="Piece">PC</DE>
		</SEG-SN1>
	</LOOP-HL>
	<LOOP-HL>
		<LOOP-INFO name="HL Loop" />
		<SEG-HL>
			<SEG-INFO code="HL" name="HIERARCHICAL LEVEL" />
			<DE code="0628" name="HIERARCHICAL ID NUMBER" type="AN">3</DE>
			<DE code="0734" name="HIERARCHICAL PARENT ID NUMBER" type="AN">1</DE>
			<DE code="0735" name="HIERARCHICAL LEVEL CODE" type="ID" desc="Item">I</DE>
		</SEG-HL>
		<SEG-LIN>
			<SEG-INFO code="LIN" name="ITEM IDENTIFICATION" />
			<DE code="0350" name="ASSIGNED IDENTIFICATION" type="AN" />
			<DE code="0235" name="PRODUCT/SERVICE ID QUALIFIER" type="ID" desc="Buyer&apos;s Part Number">BP</DE>
			<DE code="0234" name="PRODUCT/SERVICE ID" type="AN">13007608</DE>
			<DE code="0235" name="PRODUCT/SERVICE ID QUALIFIER" type="ID" desc="Engineering Change Level">EC</DE>
			<DE code="0234" name="PRODUCT/SERVICE ID" type="AN">08</DE>
			<DE code="0235" name="PRODUCT/SERVICE ID QUALIFIER" type="ID" desc="Purchaser&apos;s Order Line Number">PL</DE>
			<DE code="0234" name="PRODUCT/SERVICE ID" type="AN">00030</DE>
			<DE code="0235" name="PRODUCT/SERVICE ID QUALIFIER" type="ID" desc="Purchase Order Number">PO</DE>
			<DE code="0234" name="PRODUCT/SERVICE ID" type="AN">50001656</DE>
			<DE code="0235" name="PRODUCT/SERVICE ID QUALIFIER" type="ID" desc="Release Number">RN</DE>
			<DE code="0234" name="PRODUCT/SERVICE ID" type="AN">226</DE>
		</SEG-LIN>
		<SEG-SN1>
			<SEG-INFO code="SN1" name="ITEM DETAIL (SHIPMENT)" />
			<DE code="0350" name="ASSIGNED IDENTIFICATION" type="AN" />
			<DE code="0382" name="NUMBER OF UNITS SHIPPED" type="N">3800</DE>
			<DE code="0355" name="UNIT OR BASIS FOR MEASUREMENT CODE" type="ID" desc="Piece">PC</DE>
		</SEG-SN1>
	</LOOP-HL>
	<SEG-CTT>
		<SEG-INFO code="CTT" name="TRANSACTION TOTALS" />
		<DE code="0354" name="NUMBER OF LINE ITEMS" type="N">2</DE>
	</SEG-CTT>
</TRN-856>')

select
	@XMLData

declare
	@CallProcName sysname
,	@TableName sysname
,	@ProcName sysname
,	@ProcReturn integer
,	@ProcResult integer
,	@Error integer
,	@RowCount integer
,	@TranDT datetime = getdate()

declare
	@outboundFolder sysname = '\RawEDIData\CustomerEDI\Outbound\Staging'
,	@fileContents varbinary(max) = convert(varbinary(max), @XMLData)
,	@newStreamID uniqueidentifier
,	@newFileName sysname

execute @ProcReturn = FxEDI.RAWEDIDATA_FS.usp_NewFile
		@Folder = @outboundFolder
	,	@FileStream = @fileContents
	,	@FileName = @newFileName out
	,	@FileStreamID = @newStreamID out
	,	@TranDT = @TranDT out
	,	@Result = @ProcResult out
	,	@Debug = 0
	,	@DebugMsg = ''

select
	red.stream_id
,	convert(xml, red.file_stream)
,	red.name
,	red.path_locator
,	red.parent_path_locator
,	red.file_type
,	red.cached_file_size
,	red.creation_time
,	red.last_write_time
,	red.last_access_time
,	red.is_directory
,	red.is_offline
,	red.is_hidden
,	red.is_readonly
,	red.is_archive
,	red.is_system
,	red.is_temporary
from
	FxEDI.dbo.RawEDIData red
where
	red.stream_id = @newStreamID
go
use FxEDI
go
declare
	@SendFileFromFolderRoot sysname = '\RawEDIData\CustomerEDI\OutBound'
,	@SendFileNamePattern sysname = '%[0-9][0-9][0-9][0-9][0-9].xml'

declare
	@stagingFolder sysname = @SendFileFromFolderRoot + '\Staging'
,	@inProcessFolder sysname = @SendFileFromFolderRoot + '\InProcess'
,	@sentFolder sysname = @SendFileFromFolderRoot + '\Sent'
,	@errorFolder sysname = @SendFileFromFolderRoot + '\Error'
,	@moveFilePrefix sysname = Replace(convert(varchar(50), getdate(), 126), ':', '') + '.'

declare
	@fhlRow int

insert
	FTP.LogHeaders with (tablockx)
(	Type
,	Description
)
select
	Type = 2
,	Description = 'Send Customer EDI.'

set	@fhlRow = scope_identity()

declare
	@CallProcName sysname
,	@TableName sysname
,	@ProcName sysname
,	@ProcReturn integer
,	@ProcResult integer
,	@Error integer
,	@RowCount integer
,	@TranDT datetime = getdate()


execute
	@ProcReturn = RAWEDIDATA_FS.usp_FileMove
	    @FromFolder = @stagingFolder
	,   @ToFolder = @inProcessFolder
	,   @FileNamePattern = @SendFileNamePattern
	,   @FileAppendPrefix = @moveFilePrefix
	,   @TranDT = @TranDT out
	,	@Result = @ProcResult out

declare
	@outboundFileList varchar(max) = ''

select
	@outboundFileList += redOutboundFiles.name + ','
from
	dbo.RawEDIData redOutboundFolder
	left join dbo.RawEDIData redOutboundFiles
		on redOutboundFiles.parent_path_locator = redOutboundFolder.path_locator
		and redOutboundFiles.is_directory = 0
where
	redOutboundFolder.is_directory = 1
	and redOutboundFolder.file_stream.GetFileNamespacePath() = @inProcessFolder

insert
	FTP.LogDetails
(	FLHRowID
,	Line
,	Command
,	CommandOutput
)
select
	FLHRowID = @fhlRow
,	Line = 1
,	Command = 'Output Customer EDI Queue'
,	CommandOutput = @outboundFileList

execute as login = 'sa'

declare
	@CommandOutput varchar(max)

exec
--	loopback.FxEDI.EDI.usp_CommandShell_Execute
	FxEDI.EDI.usp_CommandShell_Execute
	@Command = '\\tterp\MSSQLSERVER\FxEDI\RawEDIData\CustomerEDI\FTPCommands\SendOutbound_v2.cmd'
,	@CommandOutput = @CommandOutput out

revert

insert
	FTP.LogDetails
(	FLHRowID
,	Line
,	Command
,	CommandOutput
)
select
	FLHRowID = @fhlRow
,	Line = 2
,	Command = '\\tterp\MSSQLSERVER\FxEDI\RawEDIData\CustomerEDI\FTPCommands\SendOutbound_v2.cmd'
,	CommandOutput = @CommandOutput

select
	*
from
	FTP.LogHeaders lh
where
	lh.RowID = @fhlRow

select
	*
from
	FTP.LogDetails ld
where
	ld.FLHRowID = @fhlRow
go

--rollback
--go
