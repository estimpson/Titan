use Monitor
go

alter table dbo.PMILMDSCL alter column DTTP varchar(254) collate database_default NULL
go
alter table dbo.PMILMDSCL alter column DVAL varchar(254) collate database_default NULL
go
alter table dbo.defect_codes alter column code varchar(10) collate database_default NOT NULL
go
alter table dbo.defect_codes alter column name varchar(30) collate database_default NOT NULL
go
alter table dbo.defect_codes alter column code_group varchar(25) collate database_default NULL
go
alter table dbo.time_log alter column employee varchar(35) collate database_default NULL
go
alter table dbo.time_log alter column notes varchar(255) collate database_default NULL
go
alter table dbo.time_log alter column type char(1) collate database_default NULL
go
alter table dbo.time_log alter column workorder varchar(10) collate database_default NULL
go
alter table dbo.PMLIBR alter column NAME varchar(254) collate database_default NOT NULL
go
alter table dbo.PMLIBR alter column CODE varchar(254) collate database_default NOT NULL
go
alter table dbo.PMLIBR alter column GOID char(40) collate database_default NOT NULL
go
alter table dbo.PMLIBR alter column VRSN varchar(254) collate database_default NULL
go
alter table dbo.PMLIBR alter column PRFX varchar(254) collate database_default NULL
go
alter table dbo.ShipScheduleHeaders alter column TradingPartner varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleHeaders alter column DocType varchar(6) collate database_default NULL
go
alter table dbo.ShipScheduleHeaders alter column Version varchar(20) collate database_default NULL
go
alter table dbo.ShipScheduleHeaders alter column Release varchar(30) collate database_default NULL
go
alter table dbo.ShipScheduleHeaders alter column DocNumber varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleHeaders alter column ControlNumber varchar(10) collate database_default NULL
go
alter table dbo.ShipScheduleHeaders alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.ShipScheduleHeaders alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.destination_package alter column destination varchar(20) collate database_default NOT NULL
go
alter table dbo.destination_package alter column package varchar(20) collate database_default NOT NULL
go
alter table dbo.destination_package alter column customer_box_code varchar(20) collate database_default NULL
go
alter table dbo.PMILMDTBS alter column DTSC varchar(254) collate database_default NULL
go
alter table dbo.PMILMDTBS alter column LOGN varchar(254) collate database_default NULL
go
alter table dbo.PMILMDTBS alter column PSWD varchar(254) collate database_default NULL
go
alter table dbo.PMILMDTBS alter column PTYP varchar(254) collate database_default NULL
go
alter table dbo.location alter column code varchar(10) collate database_default NOT NULL
go
alter table dbo.location alter column name varchar(30) collate database_default NOT NULL
go
alter table dbo.location alter column type varchar(5) collate database_default NOT NULL
go
alter table dbo.location alter column group_no varchar(25) collate database_default NULL
go
alter table dbo.location alter column plant varchar(10) collate database_default NULL
go
alter table dbo.location alter column status char(1) collate database_default NULL
go
alter table dbo.location alter column secured_location char(1) collate database_default NULL
go
alter table dbo.location alter column label_on_transfer char(1) collate database_default NULL
go
alter table dbo.unit_sub alter column unit_group varchar(2) collate database_default NOT NULL
go
alter table dbo.unit_sub alter column sub_unit varchar(10) collate database_default NULL
go
alter table dbo.unit_sub alter column name_1 varchar(10) collate database_default NULL
go
alter table dbo.unit_sub alter column name_2 varchar(10) collate database_default NULL
go
alter table dbo.unit_sub alter column short_name varchar(2) collate database_default NULL
go
alter table dbo.unit_sub alter column symbol varchar(1) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_CYTD alter column BGM02 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_CYTD alter column BGM03 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_CYTD alter column NAD01Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_CYTD alter column NAD01 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_CYTD alter column NAD02Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_CYTD alter column NAD02 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_CYTD alter column NAD03Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_CYTD alter column NAD03 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_CYTD alter column DTM0102 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_CYTD alter column QTY0102 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_CYTD alter column DTM0102START varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_CYTD alter column DT0102END varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_CYTD alter column LIN0301 varchar(50) collate database_default NULL
go
alter table dbo.PMLOCK alter column WKSN varchar(254) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_LOC alter column BGM02 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_LOC alter column BGM03 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_LOC alter column NAD01Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_LOC alter column NAD01 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_LOC alter column NAD02Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_LOC alter column NAD02 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_LOC alter column NAD03Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_LOC alter column NAD03 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_LOC alter column DTM0102 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_LOC alter column LOC0201_1 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_LOC alter column LOC0201_2 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_LOC alter column LOC0201_3 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_LOC alter column LIN0301 varchar(50) collate database_default NULL
go
alter table dbo.user_defined_status alter column display_name varchar(30) collate database_default NOT NULL
go
alter table dbo.user_defined_status alter column type char(1) collate database_default NULL
go
alter table dbo.user_defined_status alter column base char(1) collate database_default NULL
go
alter table dbo.machine alter column machine_no varchar(10) collate database_default NOT NULL
go
alter table dbo.machine alter column mach_descp varchar(35) collate database_default NULL
go
alter table dbo.machine alter column status char(1) collate database_default NULL
go
alter table dbo.machine alter column cell varchar(10) collate database_default NULL
go
alter table dbo.machine alter column redraw_graph char(1) collate database_default NULL
go
alter table dbo.machine alter column burden_type varchar(1) collate database_default NULL
go
alter table dbo.machine alter column gl_segment varchar(50) collate database_default NULL
go
alter table dbo.PMOBJT alter column VRSN varchar(254) collate database_default NULL
go
alter table dbo.PMOBJT alter column GOID char(40) collate database_default NULL
go
alter table dbo.PMOBJT alter column NAME varchar(254) collate database_default NULL
go
alter table dbo.PMOBJT alter column CODE varchar(254) collate database_default NULL
go
alter table dbo.PMOBJT alter column STRN varchar(254) collate database_default NULL
go
alter table dbo.PMOBJT alter column CUSR varchar(80) collate database_default NULL
go
alter table dbo.PMOBJT alter column MUSR varchar(80) collate database_default NULL
go
alter table dbo.PMOBJT alter column CTTP varchar(254) collate database_default NULL
go
alter table dbo.vendor_custom alter column code varchar(10) collate database_default NOT NULL
go
alter table dbo.vendor_custom alter column custom1 varchar(25) collate database_default NULL
go
alter table dbo.vendor_custom alter column custom2 varchar(25) collate database_default NULL
go
alter table dbo.vendor_custom alter column custom3 varchar(25) collate database_default NULL
go
alter table dbo.vendor_custom alter column custom4 varchar(25) collate database_default NULL
go
alter table dbo.vendor_custom alter column custom5 varchar(25) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_NAD alter column BGM02 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_NAD alter column BGM03 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_NAD alter column NAD01Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_NAD alter column NAD01 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_NAD alter column NAD02Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_NAD alter column NAD02 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_NAD alter column NAD03Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_NAD alter column NAD03 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_NAD alter column DTM0102 varchar(50) collate database_default NULL
go
alter table dbo.term alter column description varchar(20) collate database_default NOT NULL
go
alter table dbo.term alter column type varchar(25) collate database_default NOT NULL
go
alter table dbo.PMILMDTLU alter column FMOD varchar(1) collate database_default NULL
go
alter table dbo.PMOLOG alter column OTYP varchar(10) collate database_default NOT NULL
go
alter table dbo.PMOLOG alter column NAME varchar(254) collate database_default NULL
go
alter table dbo.PMOLOG alter column CODE varchar(254) collate database_default NULL
go
alter table dbo.PMOLOG alter column VRSN varchar(254) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PARTLIST alter column BGM02 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PARTLIST alter column BGM03 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PARTLIST alter column NAD01Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PARTLIST alter column NAD01 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PARTLIST alter column NAD02Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PARTLIST alter column NAD02 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PARTLIST alter column NAD03Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PARTLIST alter column NAD03 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PARTLIST alter column DTM0102 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PARTLIST alter column LIN0301 varchar(50) collate database_default NULL
go
alter table dbo.price_promotion alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.price_promotion alter column customer varchar(10) collate database_default NOT NULL
go
alter table dbo.price_promotion alter column category varchar(25) collate database_default NOT NULL
go
alter table dbo.price_promotion alter column note varchar(255) collate database_default NULL
go
alter table dbo.unit_conversion alter column code varchar(10) collate database_default NOT NULL
go
alter table dbo.unit_conversion alter column unit1 varchar(2) collate database_default NOT NULL
go
alter table dbo.unit_conversion alter column unit2 varchar(2) collate database_default NOT NULL
go
alter table dbo.PMOPTS alter column NAME varchar(80) collate database_default NOT NULL
go
alter table dbo.PMOPTS alter column VALE varchar(254) collate database_default NULL
go
alter table dbo.kanban alter column kanban_number varchar(6) collate database_default NOT NULL
go
alter table dbo.kanban alter column line11 varchar(21) collate database_default NULL
go
alter table dbo.kanban alter column line12 varchar(21) collate database_default NULL
go
alter table dbo.kanban alter column line13 varchar(21) collate database_default NULL
go
alter table dbo.kanban alter column line14 varchar(21) collate database_default NULL
go
alter table dbo.kanban alter column line15 varchar(21) collate database_default NULL
go
alter table dbo.kanban alter column line16 varchar(21) collate database_default NULL
go
alter table dbo.kanban alter column line17 varchar(21) collate database_default NULL
go
alter table dbo.kanban alter column status char(1) collate database_default NOT NULL
go
alter table dbo.GM_BFT_DELJIT_PCI_GIN alter column BGM02 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PCI_GIN alter column BGM03 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PCI_GIN alter column NAD01Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PCI_GIN alter column NAD01 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PCI_GIN alter column NAD02Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PCI_GIN alter column NAD02 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PCI_GIN alter column NAD03Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PCI_GIN alter column NAD03 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PCI_GIN alter column DTM0102 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PCI_GIN alter column PCI0201 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PCI_GIN alter column PCI0401 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PCI_GIN alter column LIN0301 varchar(50) collate database_default NULL
go
alter table dbo.PMILMEVSC alter column EVNT varchar(254) collate database_default NULL
go
alter table dbo.PMILMEVSC alter column VERS varchar(254) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PIA alter column BGM02 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PIA alter column BGM03 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PIA alter column NAD01Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PIA alter column NAD01 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PIA alter column NAD02Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PIA alter column NAD02 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PIA alter column NAD03Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PIA alter column NAD03 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PIA alter column DTM0102 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PIA alter column PIA0201 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PIA alter column PIA0202 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_PIA alter column LIN0301 varchar(50) collate database_default NULL
go
alter table dbo.category alter column code varchar(10) collate database_default NOT NULL
go
alter table dbo.category alter column name varchar(25) collate database_default NULL
go
alter table dbo.category alter column multiplier char(1) collate database_default NULL
go
alter table dbo.PMILMFFIL alter column FMOD varchar(1) collate database_default NULL
go
alter table dbo.PMILMFFIL alter column FPAT varchar(254) collate database_default NULL
go
alter table dbo.PMILMFFIL alter column FSEP varchar(16) collate database_default NULL
go
alter table dbo.PMILMFFIL alter column PTYP varchar(254) collate database_default NULL
go
alter table dbo.PMILMFFIL alter column RAWD varchar(16) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_RFF alter column BGM02 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_RFF alter column BGM03 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_RFF alter column NAD01Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_RFF alter column NAD01 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_RFF alter column NAD02Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_RFF alter column NAD02 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_RFF alter column NAD03Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_RFF alter column NAD03 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_RFF alter column DTM0102 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_RFF alter column RFF0101 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_RFF alter column RFF0102 varchar(50) collate database_default NULL
go
alter table dbo.PMRLTN alter column NAME varchar(254) collate database_default NOT NULL
go
alter table dbo.PMRLTN alter column CODE varchar(254) collate database_default NOT NULL
go
alter table dbo.ShipSchedules alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.ShipSchedules alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.ShipSchedules alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.ShipSchedules alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.ShipSchedules alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.ShipSchedules alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.ShipSchedules alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.ShipSchedules alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.ShipSchedules alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.ShipSchedules alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.ShipSchedules alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.ShipSchedules alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.ShipSchedules alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.ShipSchedules alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.ShipSchedules alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.ShipSchedules alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.ShipSchedules alter column ScheduleType varchar(50) collate database_default NULL
go
alter table dbo.ShipSchedules alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.ShipSchedules alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.machine_serial_comm alter column machine varchar(10) collate database_default NOT NULL
go
alter table dbo.machine_serial_comm alter column serial_prompt char(1) collate database_default NOT NULL
go
alter table dbo.machine_serial_comm alter column serial_interface varchar(10) collate database_default NULL
go
alter table dbo.machine_serial_comm alter column winwedge_location varchar(255) collate database_default NULL
go
alter table dbo.machine_serial_comm alter column wwconfig_location varchar(255) collate database_default NULL
go
alter table dbo.machine_serial_comm alter column steady_char varchar(1) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_SHIP_SCHED alter column BGM02 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_SHIP_SCHED alter column BGM03 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_SHIP_SCHED alter column NAD01Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_SHIP_SCHED alter column NAD01 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_SHIP_SCHED alter column NAD02Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_SHIP_SCHED alter column NAD02 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_SHIP_SCHED alter column NAD03Q varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_SHIP_SCHED alter column NAD03 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_SHIP_SCHED alter column DTM0102 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_SHIP_SCHED alter column QTY0102 varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_SHIP_SCHED alter column DTM0102SHIP varchar(50) collate database_default NULL
go
alter table dbo.GM_BFT_DELJIT_SHIP_SCHED alter column LIN0301 varchar(50) collate database_default NULL
go
alter table dbo.limit_parts alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.user_definable_module_labels alter column module varchar(10) collate database_default NOT NULL
go
alter table dbo.user_definable_module_labels alter column label varchar(15) collate database_default NOT NULL
go
alter table dbo.user_definable_module_labels alter column calculated_field char(1) collate database_default NULL
go
alter table dbo.quote alter column customer varchar(10) collate database_default NULL
go
alter table dbo.quote alter column contact varchar(25) collate database_default NULL
go
alter table dbo.quote alter column status char(1) collate database_default NULL
go
alter table dbo.quote alter column destination varchar(25) collate database_default NULL
go
alter table dbo.quote alter column salesman varchar(35) collate database_default NULL
go
alter table dbo.quote alter column notes varchar(255) collate database_default NULL
go
alter table dbo.PMRLTX alter column NAME varchar(254) collate database_default NOT NULL
go
alter table dbo.PMRLTX alter column CODE varchar(254) collate database_default NOT NULL
go
alter table dbo.PMTEXT alter column TDAT varchar(254) collate database_default NOT NULL
go
alter table dbo.interface_utilities alter column transaction_type varchar(10) collate database_default NOT NULL
go
alter table dbo.interface_utilities alter column name varchar(50) collate database_default NOT NULL
go
alter table dbo.interface_utilities alter column type char(1) collate database_default NOT NULL
go
alter table dbo.interface_utilities alter column parameters varchar(255) collate database_default NULL
go
alter table dbo.m_titan_po_notes alter column note text collate database_default NULL
go
alter table dbo.PMILMPRMT alter column DTTP varchar(254) collate database_default NULL
go
alter table dbo.quote_detail alter column type char(1) collate database_default NULL
go
alter table dbo.quote_detail alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.quote_detail alter column part varchar(25) collate database_default NULL
go
alter table dbo.quote_detail alter column product_name varchar(50) collate database_default NULL
go
alter table dbo.quote_detail alter column mode char(1) collate database_default NULL
go
alter table dbo.quote_detail alter column notes varchar(255) collate database_default NULL
go
alter table dbo.quote_detail alter column unit varchar(2) collate database_default NULL
go
alter table dbo.quote_detail alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.PMTEMP alter column STR1 varchar(254) collate database_default NULL
go
alter table dbo.PMTEMP alter column STR2 varchar(254) collate database_default NULL
go
alter table dbo.part_class_type_cross_ref alter column class char(1) collate database_default NOT NULL
go
alter table dbo.part_class_type_cross_ref alter column type char(1) collate database_default NOT NULL
go
alter table dbo.karmax_830_releases alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_releases alter column release_type varchar(2) collate database_default NULL
go
alter table dbo.karmax_830_releases alter column po_number_bfr varchar(22) collate database_default NULL
go
alter table dbo.karmax_830_releases alter column supplier_id varchar(17) collate database_default NULL
go
alter table dbo.karmax_830_releases alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_releases alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_releases alter column ecl varchar(19) collate database_default NULL
go
alter table dbo.karmax_830_releases alter column customer_po_lin varchar(22) collate database_default NULL
go
alter table dbo.karmax_830_releases alter column ship_to_id_2 varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_releases alter column SDP01 varchar(2) collate database_default NULL
go
alter table dbo.karmax_830_releases alter column SDP02 varchar(1) collate database_default NULL
go
alter table dbo.karmax_830_releases alter column FST01 varchar(17) collate database_default NULL
go
alter table dbo.karmax_830_releases alter column FST02 varchar(1) collate database_default NULL
go
alter table dbo.karmax_830_releases alter column FST03 varchar(1) collate database_default NULL
go
alter table dbo.karmax_830_releases alter column FST04 varchar(6) collate database_default NULL
go
alter table dbo.PMILMPROC alter column RPRC varchar(254) collate database_default NULL
go
alter table dbo.PMSEQN alter column NAME varchar(80) collate database_default NOT NULL
go
alter table dbo.karmax_830_oh_data alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_oh_data alter column po_number_bfr varchar(22) collate database_default NULL
go
alter table dbo.karmax_830_oh_data alter column supplier_id varchar(17) collate database_default NULL
go
alter table dbo.karmax_830_oh_data alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_oh_data alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_oh_data alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_oh_data alter column customer_po_lin varchar(22) collate database_default NULL
go
alter table dbo.karmax_830_oh_data alter column ref02_dock varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_oh_data alter column ref02_harm_code varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_oh_data alter column ref02_line_feed varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_oh_data alter column ref02_reserve_lf varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_oh_data alter column ship_to_id_2 varchar(30) collate database_default NULL
go
alter table dbo.shipper alter column destination varchar(20) collate database_default NOT NULL
go
alter table dbo.shipper alter column shipping_dock varchar(15) collate database_default NULL
go
alter table dbo.shipper alter column ship_via varchar(20) collate database_default NULL
go
alter table dbo.shipper alter column status varchar(1) collate database_default NULL
go
alter table dbo.shipper alter column aetc_number varchar(20) collate database_default NULL
go
alter table dbo.shipper alter column freight_type varchar(30) collate database_default NULL
go
alter table dbo.shipper alter column printed varchar(1) collate database_default NULL
go
alter table dbo.shipper alter column model_year_desc varchar(15) collate database_default NULL
go
alter table dbo.shipper alter column model_year varchar(4) collate database_default NULL
go
alter table dbo.shipper alter column customer varchar(25) collate database_default NULL
go
alter table dbo.shipper alter column location varchar(20) collate database_default NULL
go
alter table dbo.shipper alter column plant varchar(10) collate database_default NULL
go
alter table dbo.shipper alter column type varchar(1) collate database_default NULL
go
alter table dbo.shipper alter column invoiced varchar(1) collate database_default NULL
go
alter table dbo.shipper alter column responsibility_code varchar(1) collate database_default NULL
go
alter table dbo.shipper alter column trans_mode varchar(10) collate database_default NULL
go
alter table dbo.shipper alter column pro_number varchar(35) collate database_default NULL
go
alter table dbo.shipper alter column notes varchar(254) collate database_default NULL
go
alter table dbo.shipper alter column truck_number varchar(30) collate database_default NULL
go
alter table dbo.shipper alter column invoice_printed varchar(1) collate database_default NULL
go
alter table dbo.shipper alter column seal_number varchar(25) collate database_default NULL
go
alter table dbo.shipper alter column terms varchar(25) collate database_default NULL
go
alter table dbo.shipper alter column container_message varchar(100) collate database_default NULL
go
alter table dbo.shipper alter column picklist_printed varchar(1) collate database_default NULL
go
alter table dbo.shipper alter column dropship_reconciled varchar(1) collate database_default NULL
go
alter table dbo.shipper alter column platinum_trx_ctrl_num varchar(16) collate database_default NULL
go
alter table dbo.shipper alter column posted varchar(1) collate database_default NULL
go
alter table dbo.shipper alter column currency_unit varchar(3) collate database_default NULL
go
alter table dbo.shipper alter column cs_status varchar(20) collate database_default NULL
go
alter table dbo.shipper alter column bol_ship_to varchar(20) collate database_default NULL
go
alter table dbo.shipper alter column bol_carrier varchar(35) collate database_default NULL
go
alter table dbo.shipper alter column operator varchar(5) collate database_default NULL
go
alter table dbo.PMILMPUBL alter column PTYP varchar(254) collate database_default NULL
go
alter table dbo.PMUSER alter column NAME varchar(254) collate database_default NULL
go
alter table dbo.PMUSER alter column CODE varchar(254) collate database_default NOT NULL
go
alter table dbo.PMUSER alter column EMAD varchar(254) collate database_default NULL
go
alter table dbo.PMUSER alter column PSWD varchar(254) collate database_default NULL
go
alter table dbo.PMUSER alter column RNAM varchar(254) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums alter column po_number_bfr varchar(22) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums alter column supplier_id varchar(17) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums alter column customer_po_lin varchar(22) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums alter column raw_auth varchar(17) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums alter column raw_auth_start_dt varchar(6) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums alter column raw_auth_end_date varchar(6) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums alter column fab_auth varchar(17) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums alter column fab_auth_start_dt varchar(6) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums alter column fab_auth_end_date varchar(6) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums alter column prior_cum varchar(17) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums alter column prior_cum_start_dt varchar(6) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums alter column prior_cum_end_date varchar(6) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums alter column ship_to_id_2 varchar(30) collate database_default NULL
go
alter table dbo.alternative_parts alter column main_part varchar(25) collate database_default NOT NULL
go
alter table dbo.alternative_parts alter column alt_part varchar(25) collate database_default NOT NULL
go
alter table dbo.shipper_detail alter column part varchar(35) collate database_default NOT NULL
go
alter table dbo.shipper_detail alter column customer_po varchar(25) collate database_default NULL
go
alter table dbo.shipper_detail alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.shipper_detail alter column type varchar(1) collate database_default NULL
go
alter table dbo.shipper_detail alter column account_code varchar(75) collate database_default NULL
go
alter table dbo.shipper_detail alter column salesman varchar(10) collate database_default NULL
go
alter table dbo.shipper_detail alter column assigned varchar(35) collate database_default NULL
go
alter table dbo.shipper_detail alter column packaging_job varchar(15) collate database_default NULL
go
alter table dbo.shipper_detail alter column note varchar(254) collate database_default NULL
go
alter table dbo.shipper_detail alter column operator varchar(5) collate database_default NULL
go
alter table dbo.shipper_detail alter column alternative_unit varchar(15) collate database_default NULL
go
alter table dbo.shipper_detail alter column taxable varchar(1) collate database_default NULL
go
alter table dbo.shipper_detail alter column price_type varchar(1) collate database_default NULL
go
alter table dbo.shipper_detail alter column cross_reference varchar(25) collate database_default NULL
go
alter table dbo.shipper_detail alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.shipper_detail alter column part_name varchar(100) collate database_default NULL
go
alter table dbo.shipper_detail alter column part_original varchar(25) collate database_default NULL
go
alter table dbo.shipper_detail alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.shipper_detail alter column stage_using_weight varchar(1) collate database_default NULL
go
alter table dbo.PMILMRPRC alter column DTSC varchar(254) collate database_default NULL
go
alter table dbo.PMILMRPRC alter column LOGN varchar(254) collate database_default NULL
go
alter table dbo.PMILMRPRC alter column PSWD varchar(254) collate database_default NULL
go
alter table dbo.PMILMRPRC alter column PTYP varchar(254) collate database_default NULL
go
alter table dbo.PMXFIL alter column XNAM varchar(254) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums_history alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums_history alter column po_number_bfr varchar(22) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums_history alter column supplier_id varchar(17) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums_history alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums_history alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums_history alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums_history alter column customer_po_lin varchar(22) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums_history alter column raw_auth varchar(17) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums_history alter column raw_auth_start_dt varchar(6) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums_history alter column raw_auth_end_date varchar(6) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums_history alter column fab_auth varchar(17) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums_history alter column fab_auth_start_dt varchar(6) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums_history alter column fab_auth_end_date varchar(6) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums_history alter column prior_cum varchar(17) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums_history alter column prior_cum_start_dt varchar(6) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums_history alter column prior_cum_end_date varchar(6) collate database_default NULL
go
alter table dbo.karmax_830_auth_cums_history alter column ship_to_id_2 varchar(30) collate database_default NULL
go
alter table dbo.order_header alter column customer varchar(10) collate database_default NULL
go
alter table dbo.order_header alter column contact varchar(35) collate database_default NULL
go
alter table dbo.order_header alter column destination varchar(20) collate database_default NULL
go
alter table dbo.order_header alter column blanket_part varchar(25) collate database_default NULL
go
alter table dbo.order_header alter column model_year varchar(4) collate database_default NULL
go
alter table dbo.order_header alter column customer_part varchar(35) collate database_default NULL
go
alter table dbo.order_header alter column box_label varchar(25) collate database_default NULL
go
alter table dbo.order_header alter column pallet_label varchar(25) collate database_default NULL
go
alter table dbo.order_header alter column order_type varchar(1) collate database_default NULL
go
alter table dbo.order_header alter column artificial_cum varchar(1) collate database_default NULL
go
alter table dbo.order_header alter column status varchar(1) collate database_default NULL
go
alter table dbo.order_header alter column location varchar(10) collate database_default NULL
go
alter table dbo.order_header alter column ship_type varchar(1) collate database_default NULL
go
alter table dbo.order_header alter column unit varchar(2) collate database_default NULL
go
alter table dbo.order_header alter column revision varchar(10) collate database_default NULL
go
alter table dbo.order_header alter column customer_po varchar(20) collate database_default NULL
go
alter table dbo.order_header alter column price_unit varchar(1) collate database_default NULL
go
alter table dbo.order_header alter column salesman varchar(25) collate database_default NULL
go
alter table dbo.order_header alter column zone_code varchar(30) collate database_default NULL
go
alter table dbo.order_header alter column term varchar(20) collate database_default NULL
go
alter table dbo.order_header alter column dock_code varchar(10) collate database_default NULL
go
alter table dbo.order_header alter column package_type varchar(20) collate database_default NULL
go
alter table dbo.order_header alter column plant varchar(10) collate database_default NULL
go
alter table dbo.order_header alter column notes varchar(255) collate database_default NULL
go
alter table dbo.order_header alter column shipping_unit varchar(15) collate database_default NULL
go
alter table dbo.order_header alter column line_feed_code varchar(30) collate database_default NULL
go
alter table dbo.order_header alter column begin_kanban_number varchar(6) collate database_default NULL
go
alter table dbo.order_header alter column end_kanban_number varchar(6) collate database_default NULL
go
alter table dbo.order_header alter column line11 varchar(35) collate database_default NULL
go
alter table dbo.order_header alter column line12 varchar(35) collate database_default NULL
go
alter table dbo.order_header alter column line13 varchar(35) collate database_default NULL
go
alter table dbo.order_header alter column line14 varchar(35) collate database_default NULL
go
alter table dbo.order_header alter column line15 varchar(35) collate database_default NULL
go
alter table dbo.order_header alter column line16 varchar(35) collate database_default NULL
go
alter table dbo.order_header alter column line17 varchar(35) collate database_default NULL
go
alter table dbo.order_header alter column custom01 varchar(30) collate database_default NULL
go
alter table dbo.order_header alter column custom02 varchar(30) collate database_default NULL
go
alter table dbo.order_header alter column custom03 varchar(30) collate database_default NULL
go
alter table dbo.order_header alter column engineering_level varchar(25) collate database_default NULL
go
alter table dbo.order_header alter column currency_unit varchar(3) collate database_default NULL
go
alter table dbo.order_header alter column cs_status varchar(20) collate database_default NULL
go
alter table dbo.order_header alter column order_status char(1) collate database_default NULL
go
alter table dbo.part_revision alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_revision alter column revision varchar(10) collate database_default NOT NULL
go
alter table dbo.part_revision alter column engineering_level varchar(10) collate database_default NOT NULL
go
alter table dbo.part_revision alter column notes varchar(255) collate database_default NULL
go
alter table dbo.karmax_830_shipments alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_shipments alter column po_number_bfr varchar(22) collate database_default NULL
go
alter table dbo.karmax_830_shipments alter column supplier_id varchar(17) collate database_default NULL
go
alter table dbo.karmax_830_shipments alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_shipments alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_shipments alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_shipments alter column customer_po_lin varchar(22) collate database_default NULL
go
alter table dbo.karmax_830_shipments alter column ship_to_id_2 varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_shipments alter column last_qty_shipped varchar(17) collate database_default NULL
go
alter table dbo.karmax_830_shipments alter column shipped_date varchar(6) collate database_default NULL
go
alter table dbo.karmax_830_shipments alter column shipper_id_ship varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_shipments alter column received_date varchar(6) collate database_default NULL
go
alter table dbo.karmax_830_shipments alter column last_qty_received varchar(17) collate database_default NULL
go
alter table dbo.karmax_830_shipments alter column shipper_id_rec varchar(30) collate database_default NULL
go
alter table dbo.karmax_830_shipments alter column cytd varchar(17) collate database_default NULL
go
alter table dbo.karmax_830_shipments alter column cytd_start_dt varchar(6) collate database_default NULL
go
alter table dbo.karmax_830_shipments alter column cytd_end_date varchar(6) collate database_default NULL
go
alter table dbo.gt_bom_info alter column parent_part varchar(25) collate database_default NULL
go
alter table dbo.gt_bom_info alter column part varchar(25) collate database_default NULL
go
alter table dbo.gt_bom_info alter column machine varchar(10) collate database_default NULL
go
alter table dbo.gt_bom_info alter column process_id varchar(25) collate database_default NULL
go
alter table dbo.gt_bom_info alter column class char(1) collate database_default NULL
go
alter table dbo.gt_bom_info alter column group_technology varchar(25) collate database_default NULL
go
alter table dbo.PMILMSCOL alter column ORDR varchar(1) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined6 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined7 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined8 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined9 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined10 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined11 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined12 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined13 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined14 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined15 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined16 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined17 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined18 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined19 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column UserDefined20 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleSupplemental alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.ShipScheduleSupplemental alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.edi_830_cums alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.edi_830_cums alter column destination varchar(20) collate database_default NULL
go
alter table dbo.edi_830_cums alter column customer_po varchar(30) collate database_default NULL
go
alter table dbo.po_header alter column vendor_code varchar(10) collate database_default NOT NULL
go
alter table dbo.po_header alter column terms varchar(20) collate database_default NULL
go
alter table dbo.po_header alter column fob varchar(20) collate database_default NULL
go
alter table dbo.po_header alter column ship_via varchar(15) collate database_default NULL
go
alter table dbo.po_header alter column ship_to_destination varchar(25) collate database_default NULL
go
alter table dbo.po_header alter column status varchar(1) collate database_default NULL
go
alter table dbo.po_header alter column type varchar(1) collate database_default NULL
go
alter table dbo.po_header alter column description varchar(100) collate database_default NULL
go
alter table dbo.po_header alter column plant varchar(10) collate database_default NULL
go
alter table dbo.po_header alter column freight_type varchar(20) collate database_default NULL
go
alter table dbo.po_header alter column buyer varchar(30) collate database_default NULL
go
alter table dbo.po_header alter column printed varchar(1) collate database_default NULL
go
alter table dbo.po_header alter column notes varchar(255) collate database_default NULL
go
alter table dbo.po_header alter column blanket_frequency varchar(15) collate database_default NULL
go
alter table dbo.po_header alter column blanket_part varchar(25) collate database_default NULL
go
alter table dbo.po_header alter column blanket_vendor_part varchar(30) collate database_default NULL
go
alter table dbo.po_header alter column std_unit varchar(2) collate database_default NULL
go
alter table dbo.po_header alter column ship_type varchar(10) collate database_default NULL
go
alter table dbo.po_header alter column release_control varchar(1) collate database_default NULL
go
alter table dbo.po_header alter column trusted varchar(1) collate database_default NULL
go
alter table dbo.po_header alter column currency_unit varchar(3) collate database_default NULL
go
alter table dbo.karmax_862_releases alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_releases alter column release_type varchar(2) collate database_default NULL
go
alter table dbo.karmax_862_releases alter column po_number_bfr varchar(22) collate database_default NULL
go
alter table dbo.karmax_862_releases alter column supplier_id varchar(17) collate database_default NULL
go
alter table dbo.karmax_862_releases alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_releases alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_releases alter column ecl varchar(19) collate database_default NULL
go
alter table dbo.karmax_862_releases alter column customer_po_lin varchar(22) collate database_default NULL
go
alter table dbo.karmax_862_releases alter column ship_to_id_2 varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_releases alter column SDP01 varchar(2) collate database_default NULL
go
alter table dbo.karmax_862_releases alter column SDP02 varchar(1) collate database_default NULL
go
alter table dbo.karmax_862_releases alter column FST01 varchar(17) collate database_default NULL
go
alter table dbo.karmax_862_releases alter column FST02 varchar(1) collate database_default NULL
go
alter table dbo.karmax_862_releases alter column FST03 varchar(1) collate database_default NULL
go
alter table dbo.karmax_862_releases alter column FST04 varchar(6) collate database_default NULL
go
alter table dbo.po_detail alter column vendor_code varchar(10) collate database_default NOT NULL
go
alter table dbo.po_detail alter column part_number varchar(25) collate database_default NOT NULL
go
alter table dbo.po_detail alter column description varchar(100) collate database_default NULL
go
alter table dbo.po_detail alter column unit_of_measure varchar(2) collate database_default NULL
go
alter table dbo.po_detail alter column requisition_number varchar(10) collate database_default NULL
go
alter table dbo.po_detail alter column status varchar(1) collate database_default NULL
go
alter table dbo.po_detail alter column type varchar(1) collate database_default NULL
go
alter table dbo.po_detail alter column cross_reference_part varchar(25) collate database_default NULL
go
alter table dbo.po_detail alter column account_code varchar(50) collate database_default NULL
go
alter table dbo.po_detail alter column notes varchar(255) collate database_default NULL
go
alter table dbo.po_detail alter column invoice_status varchar(1) collate database_default NULL
go
alter table dbo.po_detail alter column ship_to_destination varchar(25) collate database_default NULL
go
alter table dbo.po_detail alter column terms varchar(20) collate database_default NULL
go
alter table dbo.po_detail alter column plant varchar(10) collate database_default NULL
go
alter table dbo.po_detail alter column invoice_number varchar(10) collate database_default NULL
go
alter table dbo.po_detail alter column ship_type varchar(1) collate database_default NULL
go
alter table dbo.po_detail alter column price_unit varchar(1) collate database_default NULL
go
alter table dbo.po_detail alter column printed varchar(1) collate database_default NULL
go
alter table dbo.po_detail alter column selected_for_print varchar(1) collate database_default NULL
go
alter table dbo.po_detail alter column deleted varchar(1) collate database_default NULL
go
alter table dbo.po_detail alter column ship_via varchar(15) collate database_default NULL
go
alter table dbo.po_detail alter column release_type varchar(1) collate database_default NULL
go
alter table dbo.po_detail alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.po_detail alter column taxable varchar(1) collate database_default NULL
go
alter table dbo.po_detail alter column truck_number varchar(30) collate database_default NULL
go
alter table dbo.po_detail alter column confirm_asn varchar(1) collate database_default NULL
go
alter table dbo.po_detail alter column job_cost_no varchar(25) collate database_default NULL
go
alter table dbo.PMILMTPRC alter column DTSC varchar(254) collate database_default NULL
go
alter table dbo.PMILMTPRC alter column LOGN varchar(254) collate database_default NULL
go
alter table dbo.PMILMTPRC alter column PSWD varchar(254) collate database_default NULL
go
alter table dbo.PMILMTPRC alter column PTYP varchar(254) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column LastShipper varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAccums alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.StagingPlanningAccums alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.part_vendor_price_matrix alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_vendor_price_matrix alter column vendor varchar(10) collate database_default NOT NULL
go
alter table dbo.part_vendor_price_matrix alter column code varchar(10) collate database_default NULL
go
alter table dbo.karmax_862_oh_data alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_oh_data alter column po_number_bfr varchar(22) collate database_default NULL
go
alter table dbo.karmax_862_oh_data alter column supplier_id varchar(17) collate database_default NULL
go
alter table dbo.karmax_862_oh_data alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_oh_data alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_oh_data alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_oh_data alter column customer_po_lin varchar(22) collate database_default NULL
go
alter table dbo.karmax_862_oh_data alter column ref02_dock varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_oh_data alter column ref02_harm_code varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_oh_data alter column ref02_line_feed varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_oh_data alter column ref02_reserve_lf varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_oh_data alter column ship_to_id_2 varchar(30) collate database_default NULL
go
alter table dbo.po_detail_history alter column vendor_code varchar(10) collate database_default NOT NULL
go
alter table dbo.po_detail_history alter column part_number varchar(25) collate database_default NOT NULL
go
alter table dbo.po_detail_history alter column description varchar(100) collate database_default NULL
go
alter table dbo.po_detail_history alter column unit_of_measure varchar(2) collate database_default NULL
go
alter table dbo.po_detail_history alter column requisition_number varchar(10) collate database_default NULL
go
alter table dbo.po_detail_history alter column status varchar(1) collate database_default NULL
go
alter table dbo.po_detail_history alter column type varchar(1) collate database_default NULL
go
alter table dbo.po_detail_history alter column cross_reference_part varchar(25) collate database_default NULL
go
alter table dbo.po_detail_history alter column account_code varchar(50) collate database_default NULL
go
alter table dbo.po_detail_history alter column notes varchar(255) collate database_default NULL
go
alter table dbo.po_detail_history alter column invoice_status varchar(1) collate database_default NULL
go
alter table dbo.po_detail_history alter column ship_to_destination varchar(25) collate database_default NULL
go
alter table dbo.po_detail_history alter column terms varchar(20) collate database_default NULL
go
alter table dbo.po_detail_history alter column plant varchar(10) collate database_default NULL
go
alter table dbo.po_detail_history alter column invoice_number varchar(10) collate database_default NULL
go
alter table dbo.po_detail_history alter column ship_type varchar(1) collate database_default NULL
go
alter table dbo.po_detail_history alter column price_unit varchar(1) collate database_default NULL
go
alter table dbo.po_detail_history alter column printed varchar(1) collate database_default NULL
go
alter table dbo.po_detail_history alter column selected_for_print varchar(1) collate database_default NULL
go
alter table dbo.po_detail_history alter column deleted varchar(1) collate database_default NULL
go
alter table dbo.po_detail_history alter column ship_via varchar(15) collate database_default NULL
go
alter table dbo.po_detail_history alter column release_type varchar(1) collate database_default NULL
go
alter table dbo.po_detail_history alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.po_detail_history alter column taxable varchar(1) collate database_default NULL
go
alter table dbo.po_detail_history alter column job_cost_no varchar(25) collate database_default NULL
go
alter table dbo.po_detail_history alter column posted varchar(1) collate database_default NULL
go
alter table dbo.PMILMTPRM alter column DTTP varchar(254) collate database_default NULL
go
alter table dbo.PMILMTPRM alter column DVAL varchar(254) collate database_default NULL
go
alter table dbo.PMILMTPRM alter column PTYP varchar(1) collate database_default NULL
go
alter table dbo.mold alter column mold_number varchar(10) collate database_default NOT NULL
go
alter table dbo.mold alter column name varchar(50) collate database_default NULL
go
alter table dbo.PMBPMDCSN alter column EXPA varchar(254) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums alter column po_number_bfr varchar(22) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums alter column supplier_id varchar(17) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums alter column customer_po_lin varchar(22) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums alter column raw_auth varchar(17) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums alter column raw_auth_start_dt varchar(6) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums alter column raw_auth_end_date varchar(6) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums alter column fab_auth varchar(17) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums alter column fab_auth_start_dt varchar(6) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums alter column fab_auth_end_date varchar(6) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums alter column prior_cum varchar(17) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums alter column prior_cum_start_dt varchar(6) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums alter column prior_cum_end_date varchar(6) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums alter column ship_to_id_2 varchar(30) collate database_default NULL
go
alter table dbo.part_customer_tbp alter column customer varchar(10) collate database_default NOT NULL
go
alter table dbo.part_customer_tbp alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.object alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.object alter column location varchar(10) collate database_default NOT NULL
go
alter table dbo.object alter column unit_measure varchar(2) collate database_default NULL
go
alter table dbo.object alter column operator varchar(10) collate database_default NOT NULL
go
alter table dbo.object alter column status varchar(1) collate database_default NOT NULL
go
alter table dbo.object alter column destination varchar(20) collate database_default NULL
go
alter table dbo.object alter column station varchar(10) collate database_default NULL
go
alter table dbo.object alter column origin varchar(20) collate database_default NULL
go
alter table dbo.object alter column note varchar(254) collate database_default NULL
go
alter table dbo.object alter column customer varchar(15) collate database_default NULL
go
alter table dbo.object alter column lot varchar(20) collate database_default NULL
go
alter table dbo.object alter column type varchar(1) collate database_default NULL
go
alter table dbo.object alter column po_number varchar(30) collate database_default NULL
go
alter table dbo.object alter column name varchar(254) collate database_default NULL
go
alter table dbo.object alter column plant varchar(10) collate database_default NULL
go
alter table dbo.object alter column package_type varchar(20) collate database_default NULL
go
alter table dbo.object alter column field1 varchar(10) collate database_default NULL
go
alter table dbo.object alter column field2 varchar(10) collate database_default NULL
go
alter table dbo.object alter column custom1 varchar(50) collate database_default NULL
go
alter table dbo.object alter column custom2 varchar(50) collate database_default NULL
go
alter table dbo.object alter column custom3 varchar(50) collate database_default NULL
go
alter table dbo.object alter column custom4 varchar(50) collate database_default NULL
go
alter table dbo.object alter column custom5 varchar(50) collate database_default NULL
go
alter table dbo.object alter column show_on_shipper varchar(1) collate database_default NULL
go
alter table dbo.object alter column user_defined_status varchar(30) collate database_default NULL
go
alter table dbo.object alter column workorder varchar(10) collate database_default NULL
go
alter table dbo.object alter column engineering_level varchar(10) collate database_default NULL
go
alter table dbo.object alter column kanban_number varchar(6) collate database_default NULL
go
alter table dbo.object alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.object alter column dim_qty_string_other varchar(50) collate database_default NULL
go
alter table dbo.object alter column posted varchar(1) collate database_default NULL
go
alter table dbo.PMILMTREN alter column ETYP varchar(1) collate database_default NULL
go
alter table dbo.StagingPlanningAuthAccums alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAuthAccums alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAuthAccums alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAuthAccums alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAuthAccums alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAuthAccums alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAuthAccums alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAuthAccums alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAuthAccums alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAuthAccums alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAuthAccums alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAuthAccums alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAuthAccums alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAuthAccums alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAuthAccums alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAuthAccums alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningAuthAccums alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.StagingPlanningAuthAccums alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.karmax_862_auth_cums_history alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums_history alter column po_number_bfr varchar(22) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums_history alter column supplier_id varchar(17) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums_history alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums_history alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums_history alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums_history alter column customer_po_lin varchar(22) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums_history alter column raw_auth varchar(17) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums_history alter column raw_auth_start_dt varchar(6) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums_history alter column raw_auth_end_date varchar(6) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums_history alter column fab_auth varchar(17) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums_history alter column fab_auth_start_dt varchar(6) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums_history alter column fab_auth_end_date varchar(6) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums_history alter column prior_cum varchar(17) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums_history alter column prior_cum_start_dt varchar(6) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums_history alter column prior_cum_end_date varchar(6) collate database_default NULL
go
alter table dbo.karmax_862_auth_cums_history alter column ship_to_id_2 varchar(30) collate database_default NULL
go
alter table dbo.Results alter column type varchar(1) collate database_default NOT NULL
go
alter table dbo.Results alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.Results alter column remarks varchar(10) collate database_default NOT NULL
go
alter table dbo.Results alter column salesman varchar(10) collate database_default NULL
go
alter table dbo.Results alter column customer varchar(10) collate database_default NULL
go
alter table dbo.Results alter column vendor varchar(10) collate database_default NULL
go
alter table dbo.Results alter column po_number varchar(30) collate database_default NULL
go
alter table dbo.Results alter column operator varchar(5) collate database_default NOT NULL
go
alter table dbo.Results alter column from_loc varchar(10) collate database_default NULL
go
alter table dbo.Results alter column to_loc varchar(10) collate database_default NULL
go
alter table dbo.Results alter column lot varchar(20) collate database_default NULL
go
alter table dbo.Results alter column status varchar(1) collate database_default NOT NULL
go
alter table dbo.Results alter column shipper varchar(20) collate database_default NULL
go
alter table dbo.Results alter column flag varchar(1) collate database_default NULL
go
alter table dbo.Results alter column activity varchar(25) collate database_default NULL
go
alter table dbo.Results alter column unit varchar(2) collate database_default NULL
go
alter table dbo.Results alter column workorder varchar(10) collate database_default NULL
go
alter table dbo.Results alter column control_number varchar(254) collate database_default NULL
go
alter table dbo.Results alter column custom1 varchar(50) collate database_default NULL
go
alter table dbo.Results alter column custom2 varchar(50) collate database_default NULL
go
alter table dbo.Results alter column custom3 varchar(50) collate database_default NULL
go
alter table dbo.Results alter column custom4 varchar(50) collate database_default NULL
go
alter table dbo.Results alter column custom5 varchar(50) collate database_default NULL
go
alter table dbo.Results alter column plant varchar(10) collate database_default NULL
go
alter table dbo.Results alter column invoice_number varchar(15) collate database_default NULL
go
alter table dbo.Results alter column notes varchar(254) collate database_default NULL
go
alter table dbo.Results alter column gl_account varchar(15) collate database_default NULL
go
alter table dbo.Results alter column package_type varchar(20) collate database_default NULL
go
alter table dbo.Results alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.Results alter column sales_order varchar(15) collate database_default NULL
go
alter table dbo.Results alter column release_no varchar(15) collate database_default NULL
go
alter table dbo.Results alter column user_defined_status varchar(30) collate database_default NULL
go
alter table dbo.Results alter column engineering_level varchar(10) collate database_default NULL
go
alter table dbo.Results alter column posted varchar(1) collate database_default NULL
go
alter table dbo.Results alter column origin varchar(20) collate database_default NULL
go
alter table dbo.Results alter column destination varchar(20) collate database_default NULL
go
alter table dbo.Results alter column object_type varchar(1) collate database_default NULL
go
alter table dbo.Results alter column part_name varchar(254) collate database_default NULL
go
alter table dbo.Results alter column field1 varchar(10) collate database_default NULL
go
alter table dbo.Results alter column field2 varchar(10) collate database_default NULL
go
alter table dbo.Results alter column show_on_shipper varchar(1) collate database_default NULL
go
alter table dbo.Results alter column kanban_number varchar(6) collate database_default NULL
go
alter table dbo.Results alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.Results alter column dim_qty_string_other varchar(50) collate database_default NULL
go
alter table dbo.PMILMXDOC alter column PTYP varchar(254) collate database_default NULL
go
alter table dbo.PMILMXDOC alter column XMLF varchar(254) collate database_default NULL
go
alter table dbo.PMILMXDOC alter column XSDF varchar(254) collate database_default NULL
go
alter table dbo.PMBPMENDS alter column ETYP varchar(254) collate database_default NULL
go
alter table dbo.report_library alter column name varchar(25) collate database_default NOT NULL
go
alter table dbo.report_library alter column report varchar(25) collate database_default NOT NULL
go
alter table dbo.report_library alter column type varchar(1) collate database_default NOT NULL
go
alter table dbo.report_library alter column object_name varchar(255) collate database_default NOT NULL
go
alter table dbo.report_library alter column library_name varchar(255) collate database_default NOT NULL
go
alter table dbo.report_library alter column preview varchar(1) collate database_default NULL
go
alter table dbo.report_library alter column print_setup varchar(1) collate database_default NULL
go
alter table dbo.report_library alter column printer varchar(255) collate database_default NULL
go
alter table dbo.karmax_862_shipments alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_shipments alter column po_number_bfr varchar(22) collate database_default NULL
go
alter table dbo.karmax_862_shipments alter column supplier_id varchar(17) collate database_default NULL
go
alter table dbo.karmax_862_shipments alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_shipments alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_shipments alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_shipments alter column customer_po_lin varchar(22) collate database_default NULL
go
alter table dbo.karmax_862_shipments alter column ship_to_id_2 varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_shipments alter column last_qty_shipped varchar(17) collate database_default NULL
go
alter table dbo.karmax_862_shipments alter column shipped_date varchar(6) collate database_default NULL
go
alter table dbo.karmax_862_shipments alter column shipper_id_ship varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_shipments alter column received_date varchar(6) collate database_default NULL
go
alter table dbo.karmax_862_shipments alter column last_qty_received varchar(17) collate database_default NULL
go
alter table dbo.karmax_862_shipments alter column shipper_id_rec varchar(30) collate database_default NULL
go
alter table dbo.karmax_862_shipments alter column cytd varchar(17) collate database_default NULL
go
alter table dbo.karmax_862_shipments alter column cytd_start_dt varchar(6) collate database_default NULL
go
alter table dbo.karmax_862_shipments alter column cytd_end_date varchar(6) collate database_default NULL
go
alter table dbo.PMBPMEVNT alter column TXPR varchar(254) collate database_default NULL
go
alter table dbo.StagingPlanningHeaders alter column TradingPartner varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningHeaders alter column DocType varchar(6) collate database_default NULL
go
alter table dbo.StagingPlanningHeaders alter column Version varchar(20) collate database_default NULL
go
alter table dbo.StagingPlanningHeaders alter column Release varchar(30) collate database_default NULL
go
alter table dbo.StagingPlanningHeaders alter column DocNumber varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningHeaders alter column ControlNumber varchar(10) collate database_default NULL
go
alter table dbo.StagingPlanningHeaders alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.StagingPlanningHeaders alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.edi_862_cums alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.edi_862_cums alter column destination varchar(20) collate database_default NULL
go
alter table dbo.edi_862_cums alter column customer_po varchar(30) collate database_default NULL
go
alter table dbo.PMIMDL alter column SOID char(40) collate database_default NULL
go
alter table dbo.PMIMDL alter column STYP char(40) collate database_default NULL
go
alter table dbo.PMBPMFLOW alter column CNDA varchar(254) collate database_default NULL
go
alter table dbo.PMBPMFLOW alter column FTYP varchar(254) collate database_default NULL
go
alter table dbo.PMBPMFLOW alter column TSPT varchar(254) collate database_default NULL
go
alter table dbo.PMBPMFRMT alter column FMTT varchar(254) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column ScheduleType varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column SEQQualifier varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column QuantityQualifier varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column QuantityType varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column DateType varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column DateDTFormat varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningReleases alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.StagingPlanningReleases alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.work_order alter column work_order varchar(10) collate database_default NOT NULL
go
alter table dbo.work_order alter column tool varchar(10) collate database_default NULL
go
alter table dbo.work_order alter column machine_no varchar(10) collate database_default NOT NULL
go
alter table dbo.work_order alter column process_id varchar(25) collate database_default NULL
go
alter table dbo.work_order alter column customer_part varchar(25) collate database_default NULL
go
alter table dbo.work_order alter column employee varchar(35) collate database_default NULL
go
alter table dbo.work_order alter column type char(1) collate database_default NULL
go
alter table dbo.work_order alter column cycle_unit varchar(15) collate database_default NULL
go
alter table dbo.work_order alter column material_shortage char(1) collate database_default NULL
go
alter table dbo.work_order alter column lot_control_activated char(1) collate database_default NULL
go
alter table dbo.work_order alter column plant varchar(20) collate database_default NULL
go
alter table dbo.work_order alter column destination varchar(20) collate database_default NULL
go
alter table dbo.work_order alter column customer varchar(20) collate database_default NULL
go
alter table dbo.work_order alter column note varchar(255) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column type varchar(1) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2014 alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2014 alter column remarks varchar(10) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2014 alter column salesman varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column customer varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column vendor varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column po_number varchar(30) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column operator varchar(5) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2014 alter column from_loc varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column to_loc varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column lot varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column status varchar(1) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2014 alter column shipper varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column flag varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column activity varchar(25) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column unit varchar(2) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column workorder varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column control_number varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column custom1 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column custom2 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column custom3 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column custom4 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column custom5 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column plant varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column invoice_number varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column notes varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column gl_account varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column package_type varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column sales_order varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column release_no varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column user_defined_status varchar(30) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column engineering_level varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column posted varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column origin varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column destination varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column object_type varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column part_name varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column field1 varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column field2 varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column show_on_shipper varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column kanban_number varchar(6) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2014 alter column dim_qty_string_other varchar(50) collate database_default NULL
go
alter table dbo.PMBPMMSPT alter column DTTP varchar(254) collate database_default NULL
go
alter table dbo.edi_Formet830_Releases alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_Releases alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_Releases alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_Releases alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_Releases alter column Quantity varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_Releases alter column ShipDate varchar(80) collate database_default NULL
go
alter table dbo.audit_trail alter column type varchar(1) collate database_default NOT NULL
go
alter table dbo.audit_trail alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.audit_trail alter column remarks varchar(10) collate database_default NOT NULL
go
alter table dbo.audit_trail alter column salesman varchar(10) collate database_default NULL
go
alter table dbo.audit_trail alter column customer varchar(10) collate database_default NULL
go
alter table dbo.audit_trail alter column vendor varchar(10) collate database_default NULL
go
alter table dbo.audit_trail alter column po_number varchar(30) collate database_default NULL
go
alter table dbo.audit_trail alter column operator varchar(5) collate database_default NOT NULL
go
alter table dbo.audit_trail alter column from_loc varchar(10) collate database_default NULL
go
alter table dbo.audit_trail alter column to_loc varchar(10) collate database_default NULL
go
alter table dbo.audit_trail alter column lot varchar(20) collate database_default NULL
go
alter table dbo.audit_trail alter column status varchar(1) collate database_default NOT NULL
go
alter table dbo.audit_trail alter column shipper varchar(20) collate database_default NULL
go
alter table dbo.audit_trail alter column flag varchar(1) collate database_default NULL
go
alter table dbo.audit_trail alter column activity varchar(25) collate database_default NULL
go
alter table dbo.audit_trail alter column unit varchar(2) collate database_default NULL
go
alter table dbo.audit_trail alter column workorder varchar(10) collate database_default NULL
go
alter table dbo.audit_trail alter column control_number varchar(254) collate database_default NULL
go
alter table dbo.audit_trail alter column custom1 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail alter column custom2 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail alter column custom3 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail alter column custom4 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail alter column custom5 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail alter column plant varchar(10) collate database_default NULL
go
alter table dbo.audit_trail alter column invoice_number varchar(15) collate database_default NULL
go
alter table dbo.audit_trail alter column notes varchar(254) collate database_default NULL
go
alter table dbo.audit_trail alter column gl_account varchar(15) collate database_default NULL
go
alter table dbo.audit_trail alter column package_type varchar(20) collate database_default NULL
go
alter table dbo.audit_trail alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.audit_trail alter column sales_order varchar(15) collate database_default NULL
go
alter table dbo.audit_trail alter column release_no varchar(15) collate database_default NULL
go
alter table dbo.audit_trail alter column user_defined_status varchar(30) collate database_default NULL
go
alter table dbo.audit_trail alter column engineering_level varchar(10) collate database_default NULL
go
alter table dbo.audit_trail alter column posted varchar(1) collate database_default NULL
go
alter table dbo.audit_trail alter column origin varchar(20) collate database_default NULL
go
alter table dbo.audit_trail alter column destination varchar(20) collate database_default NULL
go
alter table dbo.audit_trail alter column object_type varchar(1) collate database_default NULL
go
alter table dbo.audit_trail alter column part_name varchar(254) collate database_default NULL
go
alter table dbo.audit_trail alter column field1 varchar(10) collate database_default NULL
go
alter table dbo.audit_trail alter column field2 varchar(10) collate database_default NULL
go
alter table dbo.audit_trail alter column show_on_shipper varchar(1) collate database_default NULL
go
alter table dbo.audit_trail alter column kanban_number varchar(6) collate database_default NULL
go
alter table dbo.audit_trail alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.audit_trail alter column dim_qty_string_other varchar(50) collate database_default NULL
go
alter table dbo.PMLDMRLSH alter column CRDA varchar(254) collate database_default NULL
go
alter table dbo.PMLDMRLSH alter column CRDB varchar(254) collate database_default NULL
go
alter table dbo.PMLDMRLSH alter column DMNT varchar(1) collate database_default NULL
go
alter table dbo.PMLDMRLSH alter column NAMA varchar(254) collate database_default NULL
go
alter table dbo.PMLDMRLSH alter column NAMB varchar(254) collate database_default NULL
go
alter table dbo.PMLDMRLSH alter column RELT varchar(1) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined6 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined7 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined8 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined9 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined10 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined11 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined12 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined13 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined14 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined15 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined16 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined17 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined18 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined19 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column UserDefined20 varchar(50) collate database_default NULL
go
alter table dbo.StagingPlanningSupplemental alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.StagingPlanningSupplemental alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.edi_Formet830_AccumSHP alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_AccumSHP alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_AccumSHP alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_AccumSHP alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_AccumSHP alter column AccumQuantity varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_AccumSHP alter column LastDate varchar(80) collate database_default NULL
go
alter table dbo.pbcatvld alter column pbv_name varchar(30) collate database_default NOT NULL
go
alter table dbo.pbcatvld alter column pbv_vald varchar(254) collate database_default NULL
go
alter table dbo.pbcatvld alter column pbv_msg varchar(254) collate database_default NULL
go
alter table dbo.PMBPMPROC alter column ACTP varchar(254) collate database_default NULL
go
alter table dbo.PMBPMPROC alter column DRTN varchar(254) collate database_default NULL
go
alter table dbo.PMBPMPROC alter column TMOT varchar(254) collate database_default NULL
go
alter table dbo.workorder_header_history alter column work_order varchar(10) collate database_default NOT NULL
go
alter table dbo.workorder_header_history alter column tool varchar(10) collate database_default NULL
go
alter table dbo.workorder_header_history alter column machine_no varchar(10) collate database_default NOT NULL
go
alter table dbo.workorder_header_history alter column process_id varchar(25) collate database_default NULL
go
alter table dbo.workorder_header_history alter column customer_part varchar(25) collate database_default NULL
go
alter table dbo.workorder_header_history alter column employee varchar(35) collate database_default NULL
go
alter table dbo.workorder_header_history alter column type char(1) collate database_default NULL
go
alter table dbo.workorder_header_history alter column cycle_unit varchar(15) collate database_default NULL
go
alter table dbo.workorder_header_history alter column material_shortage char(1) collate database_default NULL
go
alter table dbo.workorder_header_history alter column lot_control_activated char(1) collate database_default NULL
go
alter table dbo.workorder_header_history alter column plant varchar(20) collate database_default NULL
go
alter table dbo.workorder_header_history alter column destination varchar(20) collate database_default NULL
go
alter table dbo.workorder_header_history alter column customer varchar(20) collate database_default NULL
go
alter table dbo.workorder_header_history alter column note varchar(255) collate database_default NULL
go
alter table dbo.edi_Formet830_AccumATH alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_AccumATH alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_AccumATH alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_AccumATH alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_AccumATH alter column AccumQuantity varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_AccumATH alter column LastDate varchar(80) collate database_default NULL
go
alter table dbo.PMLSRP alter column LCLS char(40) collate database_default NULL
go
alter table dbo.pbcatedt alter column pbe_name varchar(30) collate database_default NOT NULL
go
alter table dbo.pbcatedt alter column pbe_edit varchar(254) collate database_default NULL
go
alter table dbo.pbcatedt alter column pbe_work char(32) collate database_default NULL
go
alter table dbo.PMBPMPRVD alter column EURL varchar(254) collate database_default NULL
go
alter table dbo.PMBPMPRVD alter column FLNM varchar(254) collate database_default NULL
go
alter table dbo.PMBPMPRVD alter column SMLG varchar(254) collate database_default NULL
go
alter table dbo.PMBPMPRVD alter column TNPF varchar(254) collate database_default NULL
go
alter table dbo.PMBPMPRVD alter column TNSP varchar(254) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column LastShipper varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAccums alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.StagingShipScheduleAccums alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.edi_Formet830_Header alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_Header alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_Header alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_Header alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_Header alter column DockCode varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet830_Header alter column LineFeedCode varchar(80) collate database_default NULL
go
alter table dbo.unit_measure alter column unit varchar(2) collate database_default NOT NULL
go
alter table dbo.unit_measure alter column description varchar(30) collate database_default NOT NULL
go
alter table dbo.PMBPMRFLW alter column CNDA varchar(254) collate database_default NULL
go
alter table dbo.PMBPMRFLW alter column FTYP varchar(254) collate database_default NULL
go
alter table dbo.NewBTlabelFormat alter column destination varchar(20) collate database_default NULL
go
alter table dbo.NewBTlabelFormat alter column blanket_part varchar(25) collate database_default NULL
go
alter table dbo.NewBTlabelFormat alter column ORDERlabel varchar(25) collate database_default NULL
go
alter table dbo.NewBTlabelFormat alter column orderpalletlabel varchar(25) collate database_default NULL
go
alter table dbo.NewBTlabelFormat alter column partlabelFormat varchar(30) collate database_default NULL
go
alter table dbo.NewBTlabelFormat alter column NewBoxlabelFormat varchar(21) collate database_default NULL
go
alter table dbo.NewBTlabelFormat alter column NewPalletlabelFormat varchar(18) collate database_default NULL
go
alter table dbo.edi_Formet862_AccumATH alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_AccumATH alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_AccumATH alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_AccumATH alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_AccumATH alter column AccumQuantity varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_AccumATH alter column LastDate varchar(80) collate database_default NULL
go
alter table dbo.multireleases alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.multireleases alter column rel_no varchar(30) collate database_default NOT NULL
go
alter table dbo.PMPDMPRCT alter column PCTP varchar(254) collate database_default NULL
go
alter table dbo.PMPDMPRCT alter column PNAM varchar(64) collate database_default NULL
go
alter table dbo.NewLabelFormats alter column part varchar(25) collate database_default NULL
go
alter table dbo.NewLabelFormats alter column OldlabelFormat varchar(30) collate database_default NULL
go
alter table dbo.NewLabelFormats alter column newLabelFormat varchar(21) collate database_default NULL
go
alter table dbo.NewLabelFormats alter column destination varchar(20) collate database_default NULL
go
alter table dbo.NewLabelFormats alter column blanket_part varchar(25) collate database_default NULL
go
alter table dbo.NewLabelFormats alter column ORDERlabel varchar(25) collate database_default NULL
go
alter table dbo.NewLabelFormats alter column orderpalletlabel varchar(25) collate database_default NULL
go
alter table dbo.NewLabelFormats alter column partlabelFormat varchar(30) collate database_default NULL
go
alter table dbo.NewLabelFormats alter column NewBoxlabelFormat varchar(21) collate database_default NULL
go
alter table dbo.NewLabelFormats alter column NewPalletlabelFormat varchar(18) collate database_default NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.StagingShipScheduleAuthAccums alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan alter column customer_part varchar(35) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan alter column shipto_id varchar(20) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan alter column customer_po varchar(20) collate database_default NULL
go
alter table dbo.m_in_release_plan alter column model_year varchar(4) collate database_default NULL
go
alter table dbo.m_in_release_plan alter column release_no varchar(30) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan alter column quantity_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan alter column release_dt_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.edi_Formet862_AccumSHP alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_AccumSHP alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_AccumSHP alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_AccumSHP alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_AccumSHP alter column AccumQuantity varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_AccumSHP alter column LastDate varchar(80) collate database_default NULL
go
alter table dbo.activity_codes alter column code varchar(25) collate database_default NOT NULL
go
alter table dbo.activity_codes alter column value_add_status char(1) collate database_default NOT NULL
go
alter table dbo.activity_codes alter column notes varchar(255) collate database_default NOT NULL
go
alter table dbo.activity_codes alter column industry varchar(25) collate database_default NULL
go
alter table dbo.activity_codes alter column flow_route_window varchar(55) collate database_default NULL
go
alter table dbo.activity_codes alter column generate_mps_records char(1) collate database_default NULL
go
alter table dbo.PMBPMSYNC alter column TMOT varchar(254) collate database_default NULL
go
alter table dbo.m_in_release_plan_exceptions alter column customer_part varchar(35) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan_exceptions alter column shipto_id varchar(20) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan_exceptions alter column customer_po varchar(20) collate database_default NULL
go
alter table dbo.m_in_release_plan_exceptions alter column model_year varchar(4) collate database_default NULL
go
alter table dbo.m_in_release_plan_exceptions alter column release_no varchar(30) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan_exceptions alter column quantity_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan_exceptions alter column release_dt_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.edi_Formet862_Header alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_Header alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_Header alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_Header alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_Header alter column DockCode varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_Header alter column LineFeedCode varchar(80) collate database_default NULL
go
alter table dbo.PMPDMVREF alter column CROL varchar(254) collate database_default NULL
go
alter table dbo.PMPDMVREF alter column PROL varchar(254) collate database_default NULL
go
alter table dbo.PMBPMVARB alter column PTYP varchar(254) collate database_default NULL
go
alter table dbo.m_in_release_plan_formet alter column customer_part varchar(35) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan_formet alter column shipto_id varchar(20) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan_formet alter column customer_po varchar(20) collate database_default NULL
go
alter table dbo.m_in_release_plan_formet alter column model_year varchar(4) collate database_default NULL
go
alter table dbo.m_in_release_plan_formet alter column release_no varchar(30) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan_formet alter column quantity_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan_formet alter column release_dt_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.StagingShipScheduleHeaders alter column TradingPartner varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleHeaders alter column DocType varchar(6) collate database_default NULL
go
alter table dbo.StagingShipScheduleHeaders alter column Version varchar(20) collate database_default NULL
go
alter table dbo.StagingShipScheduleHeaders alter column Release varchar(30) collate database_default NULL
go
alter table dbo.StagingShipScheduleHeaders alter column DocNumber varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleHeaders alter column ControlNumber varchar(10) collate database_default NULL
go
alter table dbo.StagingShipScheduleHeaders alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.StagingShipScheduleHeaders alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.m_in_customer_po alter column plant varchar(10) collate database_default NULL
go
alter table dbo.m_in_customer_po alter column shipto_id varchar(20) collate database_default NOT NULL
go
alter table dbo.m_in_customer_po alter column customer_po varchar(20) collate database_default NULL
go
alter table dbo.m_in_customer_po alter column customer_part varchar(35) collate database_default NOT NULL
go
alter table dbo.m_in_customer_po alter column release_no varchar(30) collate database_default NOT NULL
go
alter table dbo.m_in_customer_po alter column order_unit char(2) collate database_default NULL
go
alter table dbo.m_in_customer_po alter column release_dt_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.m_in_customer_po alter column release_type_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.edi_Formet862_Releases alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_Releases alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_Releases alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_Releases alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_Releases alter column Quantity varchar(80) collate database_default NULL
go
alter table dbo.edi_Formet862_Releases alter column ShipDate varchar(80) collate database_default NULL
go
alter table dbo.activity_costs alter column parent_part varchar(25) collate database_default NOT NULL
go
alter table dbo.activity_costs alter column activity varchar(10) collate database_default NOT NULL
go
alter table dbo.activity_costs alter column location varchar(10) collate database_default NOT NULL
go
alter table dbo.activity_costs alter column notes varchar(255) collate database_default NULL
go
alter table dbo.m_in_ship_schedule_formet alter column customer_part varchar(35) collate database_default NOT NULL
go
alter table dbo.m_in_ship_schedule_formet alter column shipto_id varchar(20) collate database_default NOT NULL
go
alter table dbo.m_in_ship_schedule_formet alter column customer_po varchar(20) collate database_default NULL
go
alter table dbo.m_in_ship_schedule_formet alter column model_year varchar(4) collate database_default NULL
go
alter table dbo.m_in_ship_schedule_formet alter column release_no varchar(30) collate database_default NOT NULL
go
alter table dbo.m_in_ship_schedule_formet alter column quantity_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.m_in_ship_schedule_formet alter column release_dt_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.m_in_customer_po_exceptions alter column plant varchar(10) collate database_default NULL
go
alter table dbo.m_in_customer_po_exceptions alter column shipto_id varchar(20) collate database_default NOT NULL
go
alter table dbo.m_in_customer_po_exceptions alter column customer_po varchar(20) collate database_default NULL
go
alter table dbo.m_in_customer_po_exceptions alter column customer_part varchar(35) collate database_default NOT NULL
go
alter table dbo.m_in_customer_po_exceptions alter column release_no varchar(30) collate database_default NOT NULL
go
alter table dbo.m_in_customer_po_exceptions alter column order_unit char(2) collate database_default NULL
go
alter table dbo.m_in_customer_po_exceptions alter column release_dt_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.m_in_customer_po_exceptions alter column release_type_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.PMPDMWSOP alter column CNUS varchar(254) collate database_default NULL
go
alter table dbo.tdata alter column mcode varchar(20) collate database_default NOT NULL
go
alter table dbo.tdata alter column ucode varchar(5) collate database_default NOT NULL
go
alter table dbo.tdata alter column gcode varchar(20) collate database_default NULL
go
alter table dbo.tdata alter column scode varchar(250) collate database_default NULL
go
alter table dbo.tdata alter column escode text collate database_default NULL
go
alter table dbo.tdata alter column type char(1) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column ScheduleType varchar(50) collate database_default NULL
go
alter table dbo.StagingShipSchedules alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.StagingShipSchedules alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.m_in_ship_schedule alter column customer_part varchar(35) collate database_default NOT NULL
go
alter table dbo.m_in_ship_schedule alter column shipto_id varchar(20) collate database_default NOT NULL
go
alter table dbo.m_in_ship_schedule alter column customer_po varchar(20) collate database_default NULL
go
alter table dbo.m_in_ship_schedule alter column model_year varchar(4) collate database_default NULL
go
alter table dbo.m_in_ship_schedule alter column release_no varchar(30) collate database_default NOT NULL
go
alter table dbo.m_in_ship_schedule alter column quantity_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.m_in_ship_schedule alter column release_dt_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.PMPDMWSRV alter column CNUS varchar(254) collate database_default NULL
go
alter table dbo.PMPDMWSRV alter column LPAT varchar(254) collate database_default NULL
go
alter table dbo.m_in_ship_schedule_exceptions alter column customer_part varchar(35) collate database_default NOT NULL
go
alter table dbo.m_in_ship_schedule_exceptions alter column shipto_id varchar(20) collate database_default NOT NULL
go
alter table dbo.m_in_ship_schedule_exceptions alter column customer_po varchar(20) collate database_default NULL
go
alter table dbo.m_in_ship_schedule_exceptions alter column model_year varchar(4) collate database_default NULL
go
alter table dbo.m_in_ship_schedule_exceptions alter column release_no varchar(30) collate database_default NOT NULL
go
alter table dbo.m_in_ship_schedule_exceptions alter column quantity_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.m_in_ship_schedule_exceptions alter column release_dt_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.PMPRJACTN alter column AMKD char(40) collate database_default NULL
go
alter table dbo.PMPRJACTN alter column ATYP varchar(254) collate database_default NULL
go
alter table dbo.PMPRJACTN alter column DFNM varchar(254) collate database_default NULL
go
alter table dbo.PMPRJACTN alter column DKND char(40) collate database_default NULL
go
alter table dbo.PMPRJACTN alter column FTYP varchar(254) collate database_default NULL
go
alter table dbo.PMPRJACTN alter column LOST varchar(254) collate database_default NULL
go
alter table dbo.PMPRJACTN alter column OKND char(40) collate database_default NULL
go
alter table dbo.PMPRJACTN alter column OMKD char(40) collate database_default NULL
go
alter table dbo.PMPRJACTN alter column TLGE varchar(254) collate database_default NULL
go
alter table dbo.PMCDMLINK alter column CARD varchar(254) collate database_default NULL
go
alter table dbo.PMCDMLINK alter column RNAM varchar(254) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined6 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined7 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined8 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined9 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined10 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined11 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined12 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined13 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined14 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined15 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined16 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined17 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined18 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined19 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column UserDefined20 varchar(50) collate database_default NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.StagingShipScheduleSupplemental alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.serial_asn alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.serial_asn alter column package_type varchar(25) collate database_default NULL
go
alter table dbo.company_info alter column name varchar(30) collate database_default NOT NULL
go
alter table dbo.company_info alter column address varchar(255) collate database_default NOT NULL
go
alter table dbo.company_info alter column phone varchar(15) collate database_default NULL
go
alter table dbo.company_info alter column contact varchar(30) collate database_default NULL
go
alter table dbo.requisition_security alter column operator_code varchar(8) collate database_default NOT NULL
go
alter table dbo.requisition_security alter column password varchar(8) collate database_default NOT NULL
go
alter table dbo.requisition_security alter column approver varchar(8) collate database_default NULL
go
alter table dbo.requisition_security alter column approver_password varchar(8) collate database_default NULL
go
alter table dbo.requisition_security alter column backup_approver varchar(8) collate database_default NULL
go
alter table dbo.requisition_security alter column backup_approver_password varchar(8) collate database_default NULL
go
alter table dbo.requisition_security alter column account_group_code varchar(25) collate database_default NULL
go
alter table dbo.requisition_security alter column project_group_code varchar(25) collate database_default NULL
go
alter table dbo.requisition_security alter column name varchar(40) collate database_default NULL
go
alter table dbo.PMCDMRLSH alter column CRDA varchar(254) collate database_default NULL
go
alter table dbo.PMCDMRLSH alter column CRDB varchar(254) collate database_default NULL
go
alter table dbo.PMCDMRLSH alter column DMNT varchar(1) collate database_default NULL
go
alter table dbo.PMCDMRLSH alter column NAMA varchar(254) collate database_default NULL
go
alter table dbo.PMCDMRLSH alter column NAMB varchar(254) collate database_default NULL
go
alter table dbo.PMCDMRLSH alter column RELT varchar(1) collate database_default NULL
go
alter table dbo.PMPRJFDOC alter column DOCV varchar(254) collate database_default NULL
go
alter table dbo.PMPRJFDOC alter column FEXT varchar(20) collate database_default NULL
go
alter table dbo.PMCHCK alter column ARSZ varchar(254) collate database_default NULL
go
alter table dbo.PMCHCK alter column CKCN varchar(254) collate database_default NULL
go
alter table dbo.PMCHCK alter column DTTP varchar(254) collate database_default NULL
go
alter table dbo.PMCHCK alter column DVAL varchar(254) collate database_default NULL
go
alter table dbo.PMCHCK alter column FRMT varchar(254) collate database_default NULL
go
alter table dbo.PMCHCK alter column FRZN varchar(1) collate database_default NULL
go
alter table dbo.PMCHCK alter column HVAL varchar(254) collate database_default NULL
go
alter table dbo.PMCHCK alter column LVAL varchar(254) collate database_default NULL
go
alter table dbo.PMCHCK alter column MULT varchar(254) collate database_default NULL
go
alter table dbo.PMCHCK alter column PCGN varchar(1) collate database_default NULL
go
alter table dbo.PMCHCK alter column PCOD varchar(254) collate database_default NULL
go
alter table dbo.PMCHCK alter column PDTP varchar(254) collate database_default NULL
go
alter table dbo.PMCHCK alter column UNIT varchar(254) collate database_default NULL
go
alter table dbo.PMCHCK alter column VISI varchar(1) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column part_number varchar(25) collate database_default NOT NULL
go
alter table dbo.order_detail_formet_copy alter column type varchar(1) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column product_name varchar(100) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column notes varchar(255) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column assigned varchar(35) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column status varchar(1) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column destination varchar(25) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column unit varchar(2) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column plant varchar(10) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column ship_type varchar(1) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column packaging_type varchar(20) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column custom01 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column custom02 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column custom03 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column engineering_level varchar(25) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column box_label varchar(25) collate database_default NULL
go
alter table dbo.order_detail_formet_copy alter column pallet_label varchar(25) collate database_default NULL
go
alter table dbo.requisition_header alter column vendor_code varchar(10) collate database_default NULL
go
alter table dbo.requisition_header alter column ship_to_destination varchar(25) collate database_default NULL
go
alter table dbo.requisition_header alter column terms varchar(20) collate database_default NULL
go
alter table dbo.requisition_header alter column fob varchar(20) collate database_default NULL
go
alter table dbo.requisition_header alter column requisitioner varchar(8) collate database_default NOT NULL
go
alter table dbo.requisition_header alter column ship_via varchar(15) collate database_default NULL
go
alter table dbo.requisition_header alter column notes text collate database_default NULL
go
alter table dbo.requisition_header alter column approved varchar(1) collate database_default NULL
go
alter table dbo.requisition_header alter column approver varchar(8) collate database_default NULL
go
alter table dbo.requisition_header alter column status varchar(10) collate database_default NOT NULL
go
alter table dbo.requisition_header alter column freight_type varchar(15) collate database_default NULL
go
alter table dbo.requisition_header alter column status_notes text collate database_default NULL
go
alter table dbo.part alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part alter column name varchar(100) collate database_default NOT NULL
go
alter table dbo.part alter column cross_ref varchar(50) collate database_default NULL
go
alter table dbo.part alter column class char(1) collate database_default NOT NULL
go
alter table dbo.part alter column type char(1) collate database_default NULL
go
alter table dbo.part alter column commodity varchar(30) collate database_default NULL
go
alter table dbo.part alter column group_technology varchar(25) collate database_default NULL
go
alter table dbo.part alter column quality_alert char(1) collate database_default NULL
go
alter table dbo.part alter column description_short varchar(50) collate database_default NULL
go
alter table dbo.part alter column description_long varchar(255) collate database_default NULL
go
alter table dbo.part alter column serial_type char(1) collate database_default NULL
go
alter table dbo.part alter column product_line varchar(25) collate database_default NULL
go
alter table dbo.part alter column configuration char(1) collate database_default NULL
go
alter table dbo.part alter column user_defined_1 varchar(30) collate database_default NULL
go
alter table dbo.part alter column user_defined_2 varchar(30) collate database_default NULL
go
alter table dbo.part alter column engineering_level varchar(10) collate database_default NULL
go
alter table dbo.part alter column drawing_number varchar(25) collate database_default NULL
go
alter table dbo.part alter column gl_account_code varchar(50) collate database_default NULL
go
alter table dbo.PMPRJLSTD alter column LOST varchar(254) collate database_default NULL
go
alter table dbo.PMPRJLSTD alter column OKND char(40) collate database_default NULL
go
alter table dbo.requisition_detail alter column part_number varchar(25) collate database_default NOT NULL
go
alter table dbo.requisition_detail alter column description varchar(50) collate database_default NULL
go
alter table dbo.requisition_detail alter column account_no varchar(50) collate database_default NULL
go
alter table dbo.requisition_detail alter column deliver_to_operator varchar(10) collate database_default NULL
go
alter table dbo.requisition_detail alter column notes text collate database_default NULL
go
alter table dbo.requisition_detail alter column vendor_code varchar(10) collate database_default NULL
go
alter table dbo.requisition_detail alter column service_flag varchar(1) collate database_default NULL
go
alter table dbo.requisition_detail alter column unit_of_measure varchar(2) collate database_default NULL
go
alter table dbo.requisition_detail alter column status varchar(10) collate database_default NULL
go
alter table dbo.requisition_detail alter column status_notes text collate database_default NULL
go
alter table dbo.requisition_detail alter column project_number varchar(50) collate database_default NULL
go
alter table dbo.PMPRJMDOC alter column DOCV varchar(254) collate database_default NULL
go
alter table dbo.PMPRJMDOC alter column ECLS char(40) collate database_default NULL
go
alter table dbo.PMPRJMDOC alter column EMID char(40) collate database_default NULL
go
alter table dbo.PMPRJMDOC alter column FEXT varchar(20) collate database_default NULL
go
alter table dbo.requisition_notes alter column code varchar(25) collate database_default NOT NULL
go
alter table dbo.requisition_notes alter column notes text collate database_default NULL
go
alter table dbo.part_unit_conversion alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_unit_conversion alter column code varchar(10) collate database_default NOT NULL
go
alter table dbo.PMDFLT alter column VALE varchar(254) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column part_number varchar(25) collate database_default NOT NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column type varchar(1) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column product_name varchar(100) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column notes varchar(255) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column assigned varchar(35) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column status varchar(1) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column destination varchar(25) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column unit varchar(2) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column plant varchar(10) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column ship_type varchar(1) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column packaging_type varchar(20) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column custom01 varchar(30) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column custom02 varchar(30) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column custom03 varchar(30) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column engineering_level varchar(25) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column box_label varchar(25) collate database_default NULL
go
alter table dbo.ordr_detail_copy_formet11292018539PM alter column pallet_label varchar(25) collate database_default NULL
go
alter table dbo.PMPRJPDGM alter column ECLS char(40) collate database_default NULL
go
alter table dbo.PMPRJPDGM alter column EOID char(40) collate database_default NULL
go
alter table dbo.PMDIAG alter column PGMG varchar(64) collate database_default NULL
go
alter table dbo.PMDIAG alter column PPSZ varchar(32) collate database_default NULL
go
alter table dbo.edi_benteler830_AccumATH alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_AccumATH alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_AccumATH alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_AccumATH alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_AccumATH alter column AccumQuantity varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_AccumATH alter column LastDate varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_header alter column Relno varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_header alter column RelFunction varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_header alter column RelDate varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_header alter column DocName varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_header alter column DocPurpose varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_header alter column Mapped char(1) collate database_default NULL
go
alter table dbo.requisition_account_project alter column account_number varchar(50) collate database_default NOT NULL
go
alter table dbo.requisition_account_project alter column project_number varchar(50) collate database_default NOT NULL
go
alter table dbo.PMPSLM alter column FNAM varchar(254) collate database_default NULL
go
alter table dbo.PMPSLM alter column PSFI char(40) collate database_default NULL
go
alter table dbo.PMDTSC alter column DTSR varchar(254) collate database_default NULL
go
alter table dbo.PMDTSC alter column LGIN varchar(254) collate database_default NULL
go
alter table dbo.PMDTSC alter column PSWD varchar(254) collate database_default NULL
go
alter table dbo.PMDTSC alter column ACTP varchar(2) collate database_default NULL
go
alter table dbo.PMDTSC alter column MTYP char(40) collate database_default NULL
go
alter table dbo.edi_benteler830_AccumSHP alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_AccumSHP alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_AccumSHP alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_AccumSHP alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_AccumSHP alter column AccumQuantity varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_AccumSHP alter column LastDate varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Address alter column Relno varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Address alter column MaterialIssuerID varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Address alter column SupplierID varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Address alter column ShipFromID varchar(80) collate database_default NULL
go
alter table dbo.cdipohistory alter column vendor varchar(10) collate database_default NULL
go
alter table dbo.cdipohistory alter column part varchar(25) collate database_default NULL
go
alter table dbo.cdipohistory alter column uom varchar(2) collate database_default NULL
go
alter table dbo.cdipohistory alter column type varchar(1) collate database_default NULL
go
alter table dbo.cdipohistory alter column raccuracy char(1) collate database_default NULL
go
alter table dbo.cdipohistory alter column premium_freight char(1) collate database_default NULL
go
alter table dbo.edi_benteler830_Header alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_Header alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_Header alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_Header alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_Header alter column DockCode varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_Header alter column LineFeedCode varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_PIA alter column Relno varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_PIA alter column AddItem1 varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_PIA alter column AddItem1Type varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_PIA alter column AddItem2 varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_PIA alter column AddItem2Type varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_PIA alter column AddItem3 varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_PIA alter column AddItem3Type varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_PIA alter column CAMIPart varchar(80) collate database_default NULL
go
alter table dbo.requisition_project_number alter column project_number varchar(50) collate database_default NOT NULL
go
alter table dbo.requisition_project_number alter column description varchar(255) collate database_default NULL
go
alter table dbo.PMRQMGRPE alter column EMAD varchar(254) collate database_default NULL
go
alter table dbo.PMEMDL alter column ECLS char(40) collate database_default NULL
go
alter table dbo.PMEMDL alter column EMID char(40) collate database_default NULL
go
alter table dbo.edi_benteler830_Releases alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_Releases alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_Releases alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_Releases alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_Releases alter column Quantity varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler830_Releases alter column ShipDate varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Dock alter column Relno varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Dock alter column Dock varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Dock alter column LineFeed varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Dock alter column ReserveLineFeed varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Dock alter column CAMIPart varchar(80) collate database_default NULL
go
alter table dbo.PMRQMRQMT alter column RTYP varchar(254) collate database_default NULL
go
alter table dbo.PMRQMRQMT alter column VRFM varchar(254) collate database_default NULL
go
alter table dbo.PMEOBJ alter column ECLS char(40) collate database_default NULL
go
alter table dbo.PMEOBJ alter column EOID char(40) collate database_default NULL
go
alter table dbo.edi_benteler862_AccumATH alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_AccumATH alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_AccumATH alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_AccumATH alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_AccumATH alter column AccumQuantity varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_AccumATH alter column LastDate varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Detail alter column Relno varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Detail alter column ProcessingIndicator varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Detail alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Detail alter column DockCode varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Detail alter column CAMIPart varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Detail alter column CAMIOrderNo varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Detail alter column PlanStatusInd varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Detail alter column SchedFreq varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Detail alter column SchedPattern varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Detail alter column Qty varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Detail alter column DelDate varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELFOR_Detail alter column ModelYear varchar(4) collate database_default NULL
go
alter table dbo.account_code alter column account_no varchar(50) collate database_default NOT NULL
go
alter table dbo.account_code alter column description varchar(255) collate database_default NULL
go
alter table dbo.PMRQMTLNK alter column LKTP varchar(254) collate database_default NULL
go
alter table dbo.part_characteristics alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_characteristics alter column color varchar(15) collate database_default NULL
go
alter table dbo.part_characteristics alter column hazardous char(1) collate database_default NULL
go
alter table dbo.part_characteristics alter column part_size varchar(50) collate database_default NULL
go
alter table dbo.part_characteristics alter column user_defined_1 varchar(50) collate database_default NULL
go
alter table dbo.part_characteristics alter column package_type char(1) collate database_default NULL
go
alter table dbo.part_characteristics alter column returnable char(1) collate database_default NULL
go
alter table dbo.PMEXAS alter column XLIB char(40) collate database_default NULL
go
alter table dbo.edi_benteler862_AccumSHP alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_AccumSHP alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_AccumSHP alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_AccumSHP alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_AccumSHP alter column AccumQuantity varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_AccumSHP alter column LastDate varchar(80) collate database_default NULL
go
alter table dbo.PMRQMUSER alter column EMAD varchar(254) collate database_default NULL
go
alter table dbo.PMFILO alter column FEXT varchar(20) collate database_default NULL
go
alter table dbo.edi_benteler862_Header alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_Header alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_Header alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_Header alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_Header alter column DockCode varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_Header alter column LineFeedCode varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_header alter column Relno varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_header alter column RelFunction varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_header alter column RelDate varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_header alter column DocName varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_header alter column DocPurpose varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_header alter column Mapped char(1) collate database_default NULL
go
alter table dbo.requisition_group alter column group_code varchar(25) collate database_default NOT NULL
go
alter table dbo.requisition_group alter column description varchar(255) collate database_default NULL
go
alter table dbo.part_copy alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_copy alter column name varchar(100) collate database_default NOT NULL
go
alter table dbo.part_copy alter column cross_ref varchar(50) collate database_default NULL
go
alter table dbo.part_copy alter column class char(1) collate database_default NOT NULL
go
alter table dbo.part_copy alter column type char(1) collate database_default NULL
go
alter table dbo.part_copy alter column commodity varchar(30) collate database_default NULL
go
alter table dbo.part_copy alter column group_technology varchar(25) collate database_default NULL
go
alter table dbo.part_copy alter column quality_alert char(1) collate database_default NULL
go
alter table dbo.part_copy alter column description_short varchar(50) collate database_default NULL
go
alter table dbo.part_copy alter column description_long varchar(255) collate database_default NULL
go
alter table dbo.part_copy alter column serial_type char(1) collate database_default NULL
go
alter table dbo.part_copy alter column product_line varchar(25) collate database_default NULL
go
alter table dbo.part_copy alter column configuration char(1) collate database_default NULL
go
alter table dbo.part_copy alter column user_defined_1 varchar(30) collate database_default NULL
go
alter table dbo.part_copy alter column user_defined_2 varchar(30) collate database_default NULL
go
alter table dbo.part_copy alter column engineering_level varchar(10) collate database_default NULL
go
alter table dbo.part_copy alter column drawing_number varchar(25) collate database_default NULL
go
alter table dbo.part_copy alter column gl_account_code varchar(50) collate database_default NULL
go
alter table dbo.effective_change_notice alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.effective_change_notice alter column operator varchar(5) collate database_default NOT NULL
go
alter table dbo.effective_change_notice alter column notes varchar(255) collate database_default NULL
go
alter table dbo.effective_change_notice alter column engineering_level varchar(10) collate database_default NULL
go
alter table dbo.PMRQMUSRA alter column ATYP varchar(254) collate database_default NULL
go
alter table dbo.customer alter column customer varchar(10) collate database_default NOT NULL
go
alter table dbo.customer alter column name varchar(50) collate database_default NOT NULL
go
alter table dbo.customer alter column address_1 varchar(50) collate database_default NULL
go
alter table dbo.customer alter column address_2 varchar(50) collate database_default NULL
go
alter table dbo.customer alter column address_3 varchar(50) collate database_default NULL
go
alter table dbo.customer alter column phone varchar(20) collate database_default NULL
go
alter table dbo.customer alter column fax varchar(20) collate database_default NULL
go
alter table dbo.customer alter column modem varchar(20) collate database_default NULL
go
alter table dbo.customer alter column contact varchar(35) collate database_default NULL
go
alter table dbo.customer alter column profile varchar(255) collate database_default NULL
go
alter table dbo.customer alter column company varchar(10) collate database_default NULL
go
alter table dbo.customer alter column salesrep varchar(10) collate database_default NULL
go
alter table dbo.customer alter column terms varchar(20) collate database_default NULL
go
alter table dbo.customer alter column category varchar(25) collate database_default NULL
go
alter table dbo.customer alter column bitmap_filename varchar(50) collate database_default NULL
go
alter table dbo.customer alter column notes varchar(255) collate database_default NULL
go
alter table dbo.customer alter column address_4 varchar(40) collate database_default NULL
go
alter table dbo.customer alter column address_5 varchar(40) collate database_default NULL
go
alter table dbo.customer alter column address_6 varchar(40) collate database_default NULL
go
alter table dbo.customer alter column default_currency_unit varchar(3) collate database_default NULL
go
alter table dbo.customer alter column cs_status varchar(20) collate database_default NULL
go
alter table dbo.customer alter column custom1 varchar(25) collate database_default NULL
go
alter table dbo.customer alter column custom2 varchar(25) collate database_default NULL
go
alter table dbo.customer alter column custom3 varchar(25) collate database_default NULL
go
alter table dbo.customer alter column custom4 varchar(25) collate database_default NULL
go
alter table dbo.customer alter column custom5 varchar(25) collate database_default NULL
go
alter table dbo.customer alter column origin_code varchar(25) collate database_default NULL
go
alter table dbo.customer alter column sales_manager_code varchar(10) collate database_default NULL
go
alter table dbo.customer alter column region_code varchar(10) collate database_default NULL
go
alter table dbo.customer alter column auto_profile char(1) collate database_default NULL
go
alter table dbo.customer alter column check_standard_pack char(1) collate database_default NULL
go
alter table dbo.PMFLDR alter column XNAM varchar(254) collate database_default NULL
go
alter table dbo.PMFLDR alter column ADDR varchar(254) collate database_default NULL
go
alter table dbo.PMFLDR alter column ATFM varchar(40) collate database_default NULL
go
alter table dbo.PMFLDR alter column AUTH varchar(254) collate database_default NULL
go
alter table dbo.PMFLDR alter column AVSN varchar(254) collate database_default NULL
go
alter table dbo.PMFLDR alter column BLCD varchar(40) collate database_default NULL
go
alter table dbo.PMFLDR alter column ELFM varchar(40) collate database_default NULL
go
alter table dbo.PMFLDR alter column FNLD varchar(40) collate database_default NULL
go
alter table dbo.PMFLDR alter column LANG varchar(254) collate database_default NULL
go
alter table dbo.PMFLDR alter column MULT varchar(254) collate database_default NULL
go
alter table dbo.PMFLDR alter column TNSP varchar(254) collate database_default NULL
go
alter table dbo.PMFLDR alter column VERS varchar(254) collate database_default NULL
go
alter table dbo.PMFLDR alter column XSID varchar(254) collate database_default NULL
go
alter table dbo.PMFLDR alter column PTYP varchar(254) collate database_default NULL
go
alter table dbo.edi_benteler862_Releases alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_Releases alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_Releases alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_Releases alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_Releases alter column Quantity varchar(80) collate database_default NULL
go
alter table dbo.edi_benteler862_Releases alter column ShipDate varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Address alter column Relno varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Address alter column AddressType varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Address alter column AddressID varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Address alter column AddressName varchar(80) collate database_default NULL
go
alter table dbo.cdi_vprating alter column rating varchar(25) collate database_default NULL
go
alter table dbo.PMSTNG alter column FNAM varchar(254) collate database_default NULL
go
alter table dbo.PMOOMACTN alter column CNDA varchar(254) collate database_default NULL
go
alter table dbo.PMOOMACTN alter column EARG varchar(254) collate database_default NULL
go
alter table dbo.PMOOMACTN alter column OARG varchar(254) collate database_default NULL
go
alter table dbo.PMOOMACTN alter column PEVT varchar(1) collate database_default NULL
go
alter table dbo.m_in_release_plan_benteler alter column customer_part varchar(35) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan_benteler alter column shipto_id varchar(20) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan_benteler alter column customer_po varchar(20) collate database_default NULL
go
alter table dbo.m_in_release_plan_benteler alter column model_year varchar(4) collate database_default NULL
go
alter table dbo.m_in_release_plan_benteler alter column release_no varchar(30) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan_benteler alter column quantity_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan_benteler alter column release_dt_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.edi_CAMIDELJIT_PIA alter column Relno varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_PIA alter column AddItem1 varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_PIA alter column AddItem1Type varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_PIA alter column AddItem2 varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_PIA alter column AddItem2Type varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_PIA alter column AddItem3 varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_PIA alter column AddItem3Type varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_PIA alter column CAMIPart varchar(80) collate database_default NULL
go
alter table dbo.requisition_group_account alter column group_code varchar(25) collate database_default NOT NULL
go
alter table dbo.requisition_group_account alter column account_no varchar(50) collate database_default NOT NULL
go
alter table dbo.order_detail_copy alter column part_number varchar(25) collate database_default NOT NULL
go
alter table dbo.order_detail_copy alter column type char(1) collate database_default NULL
go
alter table dbo.order_detail_copy alter column product_name varchar(100) collate database_default NULL
go
alter table dbo.order_detail_copy alter column notes varchar(255) collate database_default NULL
go
alter table dbo.order_detail_copy alter column assigned varchar(35) collate database_default NULL
go
alter table dbo.order_detail_copy alter column status char(1) collate database_default NULL
go
alter table dbo.order_detail_copy alter column destination varchar(25) collate database_default NULL
go
alter table dbo.order_detail_copy alter column unit varchar(2) collate database_default NULL
go
alter table dbo.order_detail_copy alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.order_detail_copy alter column plant varchar(10) collate database_default NULL
go
alter table dbo.order_detail_copy alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy alter column ship_type char(1) collate database_default NULL
go
alter table dbo.order_detail_copy alter column packaging_type varchar(20) collate database_default NULL
go
alter table dbo.order_detail_copy alter column custom01 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy alter column custom02 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy alter column custom03 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.order_detail_copy alter column engineering_level varchar(25) collate database_default NULL
go
alter table dbo.order_detail_copy alter column box_label varchar(25) collate database_default NULL
go
alter table dbo.order_detail_copy alter column pallet_label varchar(25) collate database_default NULL
go
alter table dbo.contact alter column name varchar(35) collate database_default NOT NULL
go
alter table dbo.contact alter column title varchar(35) collate database_default NULL
go
alter table dbo.contact alter column notes varchar(255) collate database_default NULL
go
alter table dbo.contact alter column company varchar(35) collate database_default NULL
go
alter table dbo.contact alter column phone varchar(20) collate database_default NULL
go
alter table dbo.contact alter column company_id varchar(10) collate database_default NULL
go
alter table dbo.contact alter column fax_number varchar(20) collate database_default NULL
go
alter table dbo.contact alter column email1 varchar(255) collate database_default NULL
go
alter table dbo.contact alter column email2 varchar(255) collate database_default NULL
go
alter table dbo.contact alter column customer varchar(10) collate database_default NULL
go
alter table dbo.contact alter column destination varchar(20) collate database_default NULL
go
alter table dbo.contact alter column vendor varchar(10) collate database_default NULL
go
alter table dbo.PMOOMACTV alter column ACTP varchar(254) collate database_default NULL
go
alter table dbo.PMOOMACTV alter column DRTN varchar(254) collate database_default NULL
go
alter table dbo.PMOOMACTV alter column TMOT varchar(254) collate database_default NULL
go
alter table dbo.m_in_ship_schedule_benteler alter column customer_part varchar(35) collate database_default NOT NULL
go
alter table dbo.m_in_ship_schedule_benteler alter column shipto_id varchar(20) collate database_default NOT NULL
go
alter table dbo.m_in_ship_schedule_benteler alter column customer_po varchar(20) collate database_default NULL
go
alter table dbo.m_in_ship_schedule_benteler alter column model_year varchar(4) collate database_default NULL
go
alter table dbo.m_in_ship_schedule_benteler alter column release_no varchar(30) collate database_default NOT NULL
go
alter table dbo.m_in_ship_schedule_benteler alter column quantity_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.m_in_ship_schedule_benteler alter column release_dt_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.edi_CAMIDELJIT_Dock alter column Relno varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Dock alter column Dock varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Dock alter column LineFeed varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Dock alter column ReserveLineFeed varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Dock alter column CAMIPart varchar(80) collate database_default NULL
go
alter table dbo.PMOOMASSC alter column FRZA varchar(1) collate database_default NULL
go
alter table dbo.PMOOMASSC alter column FRZB varchar(1) collate database_default NULL
go
alter table dbo.PMOOMASSC alter column INDA varchar(1) collate database_default NULL
go
alter table dbo.PMOOMASSC alter column INDB varchar(1) collate database_default NULL
go
alter table dbo.PMOOMASSC alter column MULA varchar(254) collate database_default NULL
go
alter table dbo.PMOOMASSC alter column MULB varchar(254) collate database_default NULL
go
alter table dbo.PMOOMASSC alter column ORDA varchar(1) collate database_default NULL
go
alter table dbo.PMOOMASSC alter column ORDB varchar(1) collate database_default NULL
go
alter table dbo.PMOOMASSC alter column ROLA varchar(254) collate database_default NULL
go
alter table dbo.PMOOMASSC alter column ROLB varchar(254) collate database_default NULL
go
alter table dbo.PMOOMASSC alter column VISA varchar(1) collate database_default NULL
go
alter table dbo.PMOOMASSC alter column VISB varchar(1) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_RFF alter column Relno varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_RFF alter column RFFType varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_RFF alter column RFFItem varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_RFF alter column RFFLine varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_RFF alter column CAMIPart varchar(80) collate database_default NULL
go
alter table dbo.requisition_group_project alter column group_code varchar(25) collate database_default NOT NULL
go
alter table dbo.requisition_group_project alter column project_number varchar(50) collate database_default NOT NULL
go
alter table dbo.mdata alter column pmcode varchar(20) collate database_default NOT NULL
go
alter table dbo.mdata alter column mcode varchar(20) collate database_default NOT NULL
go
alter table dbo.mdata alter column mname varchar(50) collate database_default NULL
go
alter table dbo.mdata alter column switch char(1) collate database_default NULL
go
alter table dbo.mdata alter column display char(1) collate database_default NULL
go
alter table dbo.PMTMP2 alter column STR1 varchar(254) collate database_default NULL
go
alter table dbo.PMTMP2 alter column STR2 varchar(254) collate database_default NULL
go
alter table dbo.company alter column id varchar(10) collate database_default NOT NULL
go
alter table dbo.company alter column name varchar(35) collate database_default NULL
go
alter table dbo.company alter column city varchar(35) collate database_default NULL
go
alter table dbo.company alter column state varchar(2) collate database_default NULL
go
alter table dbo.company alter column zip varchar(9) collate database_default NULL
go
alter table dbo.company alter column address_3 varchar(35) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Detail alter column Relno varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Detail alter column ProcessingIndicator varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Detail alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Detail alter column DockCode varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Detail alter column CAMIPart varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Detail alter column CAMIOrderNo varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Detail alter column PlanStatusInd varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Detail alter column SchedFreq varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Detail alter column SchedPattern varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Detail alter column Qty varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Detail alter column DelDate varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Detail alter column ModelYear varchar(4) collate database_default NULL
go
alter table dbo.PMTMP3 alter column STR1 varchar(254) collate database_default NULL
go
alter table dbo.PMTMP3 alter column STR2 varchar(254) collate database_default NULL
go
alter table dbo.PMOOMCLNK alter column CNDA varchar(254) collate database_default NULL
go
alter table dbo.PMOOMCLNK alter column EARG varchar(254) collate database_default NULL
go
alter table dbo.PMOOMCLNK alter column FTYP varchar(254) collate database_default NULL
go
alter table dbo.PMOOMCLNK alter column OARG varchar(254) collate database_default NULL
go
alter table dbo.PMOOMCLNK alter column TACN varchar(254) collate database_default NULL
go
alter table dbo.PMTMP4 alter column STR1 varchar(254) collate database_default NULL
go
alter table dbo.PMTMP4 alter column STR2 varchar(254) collate database_default NULL
go
alter table dbo.product_line alter column id varchar(25) collate database_default NOT NULL
go
alter table dbo.product_line alter column notes varchar(255) collate database_default NULL
go
alter table dbo.product_line alter column flag char(1) collate database_default NULL
go
alter table dbo.product_line alter column gl_segment varchar(50) collate database_default NULL
go
alter table dbo.PMOOMCMPI alter column ACCP varchar(254) collate database_default NULL
go
alter table dbo.PMOOMCMPI alter column MULT varchar(254) collate database_default NULL
go
alter table dbo.PMOOMCMPI alter column WURL varchar(254) collate database_default NULL
go
alter table dbo.PMOOMCOMP alter column CTYP varchar(3) collate database_default NULL
go
alter table dbo.PMOOMCOMP alter column TRSP varchar(2) collate database_default NULL
go
alter table dbo.PMOOMCOMP alter column WNPX varchar(254) collate database_default NULL
go
alter table dbo.PMOOMCOMP alter column WNSP varchar(254) collate database_default NULL
go
alter table dbo.PMOOMCOMP alter column WSTY varchar(4) collate database_default NULL
go
alter table dbo.PMOOMCOMP alter column WTNS varchar(254) collate database_default NULL
go
alter table dbo.PMOOMCOMP alter column WTYP varchar(4) collate database_default NULL
go
alter table dbo.PMOOMCOMP alter column WURL varchar(254) collate database_default NULL
go
alter table dbo.BartenderLabels alter column LabelFormat varchar(50) collate database_default NOT NULL
go
alter table dbo.BartenderLabels alter column LabelPath varchar(250) collate database_default NOT NULL
go
alter table dbo.part_vendor alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_vendor alter column vendor varchar(10) collate database_default NOT NULL
go
alter table dbo.part_vendor alter column vendor_part varchar(25) collate database_default NULL
go
alter table dbo.part_vendor alter column outside_process char(1) collate database_default NULL
go
alter table dbo.part_vendor alter column receiving_um varchar(10) collate database_default NULL
go
alter table dbo.part_vendor alter column part_name varchar(100) collate database_default NULL
go
alter table dbo.part_vendor alter column note text collate database_default NULL
go
alter table dbo.phone alter column name varchar(14) collate database_default NOT NULL
go
alter table dbo.phone alter column namel varchar(15) collate database_default NOT NULL
go
alter table dbo.phone alter column phone varchar(12) collate database_default NOT NULL
go
alter table dbo.phone alter column company varchar(32) collate database_default NOT NULL
go
alter table dbo.phone alter column title varchar(20) collate database_default NULL
go
alter table dbo.phone alter column address varchar(32) collate database_default NULL
go
alter table dbo.phone alter column city varchar(18) collate database_default NULL
go
alter table dbo.phone alter column state varchar(2) collate database_default NULL
go
alter table dbo.phone alter column zip varchar(5) collate database_default NULL
go
alter table dbo.phone alter column rem1 varchar(65) collate database_default NULL
go
alter table dbo.phone alter column rem2 varchar(65) collate database_default NULL
go
alter table dbo.phone alter column car varchar(12) collate database_default NULL
go
alter table dbo.phone alter column fax varchar(12) collate database_default NULL
go
alter table dbo.phone alter column home varchar(12) collate database_default NULL
go
alter table dbo.phone alter column modem varchar(12) collate database_default NULL
go
alter table dbo.phone alter column cat varchar(10) collate database_default NULL
go
alter table dbo.phone alter column type char(1) collate database_default NULL
go
alter table dbo.phone alter column company_id varchar(10) collate database_default NULL
go
alter table dbo.PMOOMCSFR alter column CTYP varchar(1) collate database_default NULL
go
alter table dbo.PMOOMCSFR alter column MULT varchar(254) collate database_default NULL
go
alter table dbo.PMOOMCSFR alter column PCOD varchar(254) collate database_default NULL
go
alter table dbo.PMOOMCSFR alter column PERS varchar(1) collate database_default NULL
go
alter table dbo.PMOOMCSFR alter column VISI varchar(1) collate database_default NULL
go
alter table dbo.issues alter column issue text collate database_default NOT NULL
go
alter table dbo.issues alter column status varchar(25) collate database_default NULL
go
alter table dbo.issues alter column solution text collate database_default NULL
go
alter table dbo.issues alter column category varchar(50) collate database_default NOT NULL
go
alter table dbo.issues alter column sub_category varchar(50) collate database_default NULL
go
alter table dbo.issues alter column product_line varchar(50) collate database_default NULL
go
alter table dbo.issues alter column product_code varchar(50) collate database_default NULL
go
alter table dbo.issues alter column origin_type varchar(50) collate database_default NOT NULL
go
alter table dbo.issues alter column origin varchar(50) collate database_default NOT NULL
go
alter table dbo.issues alter column assigned_to varchar(50) collate database_default NULL
go
alter table dbo.issues alter column authorized_by varchar(50) collate database_default NULL
go
alter table dbo.issues alter column documentation_change varchar(1) collate database_default NULL
go
alter table dbo.issues alter column fax_sheet varchar(1) collate database_default NULL
go
alter table dbo.issues alter column environment varchar(255) collate database_default NULL
go
alter table dbo.issues alter column entered_by varchar(50) collate database_default NULL
go
alter table dbo.issues alter column product_component varchar(25) collate database_default NULL
go
alter table dbo.PMOOMDCSN alter column EXPA varchar(254) collate database_default NULL
go
alter table dbo.process alter column id varchar(25) collate database_default NOT NULL
go
alter table dbo.process alter column name varchar(255) collate database_default NULL
go
alter table dbo.PMOOMDTSC alter column CNCT varchar(254) collate database_default NULL
go
alter table dbo.PMOOMDTSC alter column DTSR varchar(254) collate database_default NULL
go
alter table dbo.PMOOMDTSC alter column LGIN varchar(254) collate database_default NULL
go
alter table dbo.PMOOMDTSC alter column PSWD varchar(254) collate database_default NULL
go
alter table dbo.issue_detail alter column status_old varchar(25) collate database_default NOT NULL
go
alter table dbo.issue_detail alter column status_new varchar(25) collate database_default NOT NULL
go
alter table dbo.issue_detail alter column notes text collate database_default NOT NULL
go
alter table dbo.issue_detail alter column origin varchar(50) collate database_default NOT NULL
go
alter table dbo.PMOOMGNRL alter column VISI varchar(1) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column part_number varchar(25) collate database_default NOT NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column type varchar(1) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column product_name varchar(100) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column notes varchar(255) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column assigned varchar(35) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column status varchar(1) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column destination varchar(25) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column unit varchar(2) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column plant varchar(10) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column ship_type varchar(1) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column packaging_type varchar(20) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column custom01 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column custom02 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column custom03 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column engineering_level varchar(25) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column box_label varchar(25) collate database_default NULL
go
alter table dbo.order_detail_backupKzoo20190220 alter column pallet_label varchar(25) collate database_default NULL
go
alter table dbo.Label_ObjectPrintHistory alter column RowCreateUser nvarchar(128) collate database_default NULL
go
alter table dbo.Label_ObjectPrintHistory alter column RowModifiedUser nvarchar(128) collate database_default NULL
go
alter table dbo.Label_ObjectPrintHistory alter column LabelData nvarchar(2000) collate database_default NULL
go
alter table dbo.part_online alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_online alter column default_vendor varchar(10) collate database_default NULL
go
alter table dbo.part_online alter column kanban_po_requisition char(1) collate database_default NULL
go
alter table dbo.part_online alter column kanban_required char(1) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_f alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_f alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_f alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_f alter column customer_po varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_f alter column model_year varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_f alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_f alter column po_line varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_f alter column SDP01 varchar(2) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_f alter column SDP02 varchar(1) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_f alter column FST01 varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_f alter column FST02 varchar(1) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_f alter column FST03 varchar(1) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_f alter column FST04 varchar(10) collate database_default NULL
go
alter table dbo.issues_status alter column status varchar(25) collate database_default NOT NULL
go
alter table dbo.issues_status alter column type varchar(1) collate database_default NOT NULL
go
alter table dbo.issues_status alter column default_value varchar(1) collate database_default NOT NULL
go
alter table dbo.vendor alter column code varchar(10) collate database_default NOT NULL
go
alter table dbo.vendor alter column name varchar(35) collate database_default NOT NULL
go
alter table dbo.vendor alter column outside_processor char(1) collate database_default NULL
go
alter table dbo.vendor alter column contact varchar(35) collate database_default NULL
go
alter table dbo.vendor alter column phone varchar(20) collate database_default NULL
go
alter table dbo.vendor alter column terms varchar(20) collate database_default NULL
go
alter table dbo.vendor alter column frieght_type varchar(15) collate database_default NULL
go
alter table dbo.vendor alter column fob varchar(10) collate database_default NULL
go
alter table dbo.vendor alter column buyer varchar(30) collate database_default NULL
go
alter table dbo.vendor alter column plant varchar(10) collate database_default NULL
go
alter table dbo.vendor alter column ship_via varchar(15) collate database_default NULL
go
alter table dbo.vendor alter column company varchar(10) collate database_default NULL
go
alter table dbo.vendor alter column address_1 varchar(50) collate database_default NULL
go
alter table dbo.vendor alter column address_2 varchar(50) collate database_default NULL
go
alter table dbo.vendor alter column address_3 varchar(50) collate database_default NULL
go
alter table dbo.vendor alter column fax varchar(20) collate database_default NULL
go
alter table dbo.vendor alter column partial_release_update char(1) collate database_default NULL
go
alter table dbo.vendor alter column trusted varchar(1) collate database_default NULL
go
alter table dbo.vendor alter column address_4 varchar(40) collate database_default NULL
go
alter table dbo.vendor alter column address_5 varchar(40) collate database_default NULL
go
alter table dbo.vendor alter column address_6 varchar(40) collate database_default NULL
go
alter table dbo.vendor alter column kanban char(1) collate database_default NULL
go
alter table dbo.vendor alter column default_currency_unit varchar(3) collate database_default NULL
go
alter table dbo.vendor alter column status varchar(20) collate database_default NULL
go
alter table dbo.PMOOMMSSG alter column ACTN varchar(1) collate database_default NULL
go
alter table dbo.PMOOMMSSG alter column BTIM varchar(254) collate database_default NULL
go
alter table dbo.PMOOMMSSG alter column COND varchar(254) collate database_default NULL
go
alter table dbo.PMOOMMSSG alter column ETIM varchar(254) collate database_default NULL
go
alter table dbo.PMOOMMSSG alter column MTYP varchar(1) collate database_default NULL
go
alter table dbo.PMOOMMSSG alter column OARG varchar(254) collate database_default NULL
go
alter table dbo.PMOOMMSSG alter column ORVL varchar(254) collate database_default NULL
go
alter table dbo.PMOOMMSSG alter column PRED varchar(254) collate database_default NULL
go
alter table dbo.PMOOMMSSG alter column SEQN varchar(254) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_p alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_p alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_p alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_p alter column customer_po varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_p alter column model_year varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_p alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_p alter column po_line varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_p alter column SDP01 varchar(2) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_p alter column SDP02 varchar(1) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_p alter column FST01 varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_p alter column FST02 varchar(1) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_p alter column FST03 varchar(1) collate database_default NULL
go
alter table dbo.adv_edi_830_releases_p alter column FST04 varchar(10) collate database_default NULL
go
alter table dbo.parameters alter column company_name varchar(50) collate database_default NOT NULL
go
alter table dbo.parameters alter column company_logo varchar(30) collate database_default NULL
go
alter table dbo.parameters alter column show_program_name char(1) collate database_default NULL
go
alter table dbo.parameters alter column address_1 varchar(30) collate database_default NULL
go
alter table dbo.parameters alter column address_2 varchar(30) collate database_default NULL
go
alter table dbo.parameters alter column address_3 varchar(30) collate database_default NULL
go
alter table dbo.parameters alter column admin_password varchar(5) collate database_default NULL
go
alter table dbo.parameters alter column delete_scrapped_objects char(1) collate database_default NULL
go
alter table dbo.parameters alter column ipa char(1) collate database_default NULL
go
alter table dbo.parameters alter column audit_trail_delete char(1) collate database_default NULL
go
alter table dbo.parameters alter column invoice_add char(1) collate database_default NULL
go
alter table dbo.parameters alter column plant_required char(1) collate database_default NULL
go
alter table dbo.parameters alter column edit_po_number char(1) collate database_default NULL
go
alter table dbo.parameters alter column over_receive char(1) collate database_default NULL
go
alter table dbo.parameters alter column PHONE_NUMBER varchar(15) collate database_default NULL
go
alter table dbo.parameters alter column shipping_label varchar(30) collate database_default NULL
go
alter table dbo.parameters alter column verify_packaging char(1) collate database_default NULL
go
alter table dbo.parameters alter column SALES_TAX_ACCOUNT varchar(50) collate database_default NULL
go
alter table dbo.parameters alter column FREIGHT_ACCOUNT varchar(50) collate database_default NULL
go
alter table dbo.parameters alter column populate_parts char(1) collate database_default NULL
go
alter table dbo.parameters alter column populate_locations char(1) collate database_default NULL
go
alter table dbo.parameters alter column populate_machines char(1) collate database_default NULL
go
alter table dbo.parameters alter column mandatory_lot_inventory char(1) collate database_default NULL
go
alter table dbo.parameters alter column set_asn_uop char(1) collate database_default NULL
go
alter table dbo.parameters alter column shop_floor_check_u1 char(1) collate database_default NULL
go
alter table dbo.parameters alter column shop_floor_check_u2 char(1) collate database_default NULL
go
alter table dbo.parameters alter column shop_floor_check_u3 char(1) collate database_default NULL
go
alter table dbo.parameters alter column shop_floor_check_u4 char(1) collate database_default NULL
go
alter table dbo.parameters alter column shop_floor_check_u5 char(1) collate database_default NULL
go
alter table dbo.parameters alter column shop_floor_check_lot char(1) collate database_default NULL
go
alter table dbo.parameters alter column lot_control_message varchar(255) collate database_default NULL
go
alter table dbo.parameters alter column mandatory_qc_notes char(1) collate database_default NULL
go
alter table dbo.parameters alter column asn_directory varchar(25) collate database_default NULL
go
alter table dbo.parameters alter column auto_stage_for_packline char(1) collate database_default NULL
go
alter table dbo.parameters alter column ask_for_minicop char(1) collate database_default NULL
go
alter table dbo.parameters alter column issue_file_location varchar(250) collate database_default NULL
go
alter table dbo.parameters alter column accounting_interface_db varchar(25) collate database_default NULL
go
alter table dbo.parameters alter column accounting_interface_type varchar(25) collate database_default NULL
go
alter table dbo.parameters alter column accounting_interface_login varchar(10) collate database_default NULL
go
alter table dbo.parameters alter column accounting_interface_pwd varchar(10) collate database_default NULL
go
alter table dbo.parameters alter column accounting_pbl_name varchar(50) collate database_default NULL
go
alter table dbo.parameters alter column accounting_cust_sync_dp varchar(50) collate database_default NULL
go
alter table dbo.parameters alter column accounting_vend_sync_db varchar(50) collate database_default NULL
go
alter table dbo.parameters alter column accounting_ap_dp_header varchar(50) collate database_default NULL
go
alter table dbo.parameters alter column accounting_ar_dp varchar(50) collate database_default NULL
go
alter table dbo.parameters alter column accounting_ap_dp_detail varchar(50) collate database_default NULL
go
alter table dbo.parameters alter column inv_reg_col varchar(25) collate database_default NULL
go
alter table dbo.parameters alter column scale_part_choice char(1) collate database_default NULL
go
alter table dbo.parameters alter column accounting_profile varchar(50) collate database_default NULL
go
alter table dbo.parameters alter column accounting_type varchar(25) collate database_default NULL
go
alter table dbo.parameters alter column include_setuptime char(1) collate database_default NULL
go
alter table dbo.parameters alter column sunday char(1) collate database_default NULL
go
alter table dbo.parameters alter column monday char(1) collate database_default NULL
go
alter table dbo.parameters alter column tuesday char(1) collate database_default NULL
go
alter table dbo.parameters alter column wednesday char(1) collate database_default NULL
go
alter table dbo.parameters alter column thursday char(1) collate database_default NULL
go
alter table dbo.parameters alter column friday char(1) collate database_default NULL
go
alter table dbo.parameters alter column saturday char(1) collate database_default NULL
go
alter table dbo.parameters alter column order_type char(1) collate database_default NULL
go
alter table dbo.parameters alter column pallet_package_type char(1) collate database_default NULL
go
alter table dbo.parameters alter column clear_after_trans_jc char(1) collate database_default NULL
go
alter table dbo.parameters alter column dda_required char(1) collate database_default NULL
go
alter table dbo.parameters alter column dda_formula_type char(1) collate database_default NULL
go
alter table dbo.parameters alter column shipper_required varchar(1) collate database_default NULL
go
alter table dbo.parameters alter column calc_mtl_cost varchar(1) collate database_default NULL
go
alter table dbo.parameters alter column issues_environment_message varchar(255) collate database_default NULL
go
alter table dbo.parameters alter column base_currency varchar(3) collate database_default NULL
go
alter table dbo.parameters alter column currency_display_symbol varchar(10) collate database_default NULL
go
alter table dbo.parameters alter column requisition varchar(1) collate database_default NULL
go
alter table dbo.parameters alter column onhand_from_partonline char(1) collate database_default NULL
go
alter table dbo.parameters alter column consolidate_mps char(1) collate database_default NULL
go
alter table dbo.parameters alter column audit_deletion char(1) collate database_default NULL
go
alter table dbo.PMOOMMTHD alter column EVNT varchar(254) collate database_default NULL
go
alter table dbo.PMOOMMTHD alter column RTTP varchar(254) collate database_default NULL
go
alter table dbo.PMOOMMTHD alter column VISI varchar(1) collate database_default NULL
go
alter table dbo.PMOOMMTHD alter column WSIM varchar(254) collate database_default NULL
go
alter table dbo.PMOOMMTHD alter column WSOM varchar(254) collate database_default NULL
go
alter table dbo.PMOOMMTHD alter column WSSF varchar(254) collate database_default NULL
go
alter table dbo.edi_830_AuTH2 alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH2 alter column supplier varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH2 alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH2 alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH2 alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH2 alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.edi_830_AuTH2 alter column auth_type varchar(20) collate database_default NULL
go
alter table dbo.edi_830_AuTH2 alter column auth_date1 varchar(12) collate database_default NULL
go
alter table dbo.edi_830_AuTH2 alter column auth_qty1 varchar(12) collate database_default NULL
go
alter table dbo.edi_830_AuTH2 alter column auth_qty2 varchar(20) collate database_default NULL
go
alter table dbo.edi_830_AuTH2 alter column auth_date2 varchar(12) collate database_default NULL
go
alter table dbo.adv_edi_830_oh_data alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_oh_data alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_oh_data alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_oh_data alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_oh_data alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.adv_edi_830_oh_data alter column dock_REF_DK varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_oh_data alter column line_feed_REF_LF varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_oh_data alter column res_line_feed_REF_RL varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_oh_data alter column user_defined1 varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_oh_data alter column user_defined2 varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_oh_data alter column user_defined3 varchar(30) collate database_default NULL
go
alter table dbo.issues_category alter column category varchar(50) collate database_default NOT NULL
go
alter table dbo.issues_category alter column default_value varchar(1) collate database_default NOT NULL
go
alter table dbo.vendor_service_status alter column status_name varchar(20) collate database_default NOT NULL
go
alter table dbo.vendor_service_status alter column status_type varchar(1) collate database_default NOT NULL
go
alter table dbo.vendor_service_status alter column default_value varchar(1) collate database_default NOT NULL
go
alter table dbo.edi_830_AuTH_history2 alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history2 alter column supplier varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history2 alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history2 alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history2 alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history2 alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history2 alter column auth_type varchar(20) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history2 alter column auth_date1 varchar(12) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history2 alter column auth_qty1 varchar(12) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history2 alter column auth_qty2 varchar(20) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history2 alter column auth_date2 varchar(12) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH alter column raw_auth varchar(20) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH alter column raw_start_date varchar(12) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH alter column raw_end_date varchar(12) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH alter column fab_auth varchar(20) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH alter column fab_start_date varchar(12) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH alter column fab_end_date varchar(12) collate database_default NULL
go
alter table dbo.PMOOMPARM alter column ARSZ varchar(254) collate database_default NULL
go
alter table dbo.PMOOMPARM alter column DTTP varchar(254) collate database_default NULL
go
alter table dbo.PMOOMPARM alter column DVAL varchar(254) collate database_default NULL
go
alter table dbo.PMOOMPARM alter column PTTP varchar(10) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH_history alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH_history alter column ship_to varchar(10) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH_history alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH_history alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH_history alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH_history alter column raw_auth varchar(20) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH_history alter column raw_start_date varchar(12) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH_history alter column raw_end_date varchar(12) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH_history alter column fab_auth varchar(20) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH_history alter column fab_start_date varchar(12) collate database_default NULL
go
alter table dbo.adv_edi_830_AuTH_history alter column fab_end_date varchar(12) collate database_default NULL
go
alter table dbo.issues_sub_category alter column category varchar(50) collate database_default NOT NULL
go
alter table dbo.issues_sub_category alter column sub_category varchar(50) collate database_default NOT NULL
go
alter table dbo.issues_sub_category alter column default_value varchar(1) collate database_default NOT NULL
go
alter table dbo.activity_router alter column parent_part varchar(25) collate database_default NOT NULL
go
alter table dbo.activity_router alter column code varchar(25) collate database_default NOT NULL
go
alter table dbo.activity_router alter column part varchar(25) collate database_default NULL
go
alter table dbo.activity_router alter column notes varchar(255) collate database_default NULL
go
alter table dbo.activity_router alter column labor varchar(25) collate database_default NULL
go
alter table dbo.activity_router alter column material char(1) collate database_default NULL
go
alter table dbo.activity_router alter column cost_bill char(1) collate database_default NULL
go
alter table dbo.activity_router alter column group_location varchar(10) collate database_default NULL
go
alter table dbo.activity_router alter column process varchar(25) collate database_default NULL
go
alter table dbo.activity_router alter column doc1 varchar(35) collate database_default NULL
go
alter table dbo.activity_router alter column doc2 varchar(35) collate database_default NULL
go
alter table dbo.activity_router alter column doc3 varchar(35) collate database_default NULL
go
alter table dbo.activity_router alter column doc4 varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases_gm2 alter column release_number varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases_gm2 alter column supplier varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases_gm2 alter column ship_to_id varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases_gm2 alter column buyer_part varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases_gm2 alter column model_year varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases_gm2 alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases_gm2 alter column forecast_type varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases_gm2 alter column quantity varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases_gm2 alter column date_type varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases_gm2 alter column date1 varchar(35) collate database_default NULL
go
alter table dbo.Label_ObjectScanHistory alter column RowCreateUser nvarchar(128) collate database_default NULL
go
alter table dbo.Label_ObjectScanHistory alter column RowModifiedUser nvarchar(128) collate database_default NULL
go
alter table dbo.Label_ObjectScanHistory alter column LabelData nvarchar(2000) collate database_default NULL
go
alter table dbo.destination alter column destination varchar(20) collate database_default NOT NULL
go
alter table dbo.destination alter column name varchar(50) collate database_default NULL
go
alter table dbo.destination alter column company varchar(10) collate database_default NULL
go
alter table dbo.destination alter column type varchar(2) collate database_default NULL
go
alter table dbo.destination alter column address_1 varchar(50) collate database_default NULL
go
alter table dbo.destination alter column address_2 varchar(50) collate database_default NULL
go
alter table dbo.destination alter column address_3 varchar(50) collate database_default NULL
go
alter table dbo.destination alter column customer varchar(10) collate database_default NULL
go
alter table dbo.destination alter column vendor varchar(10) collate database_default NULL
go
alter table dbo.destination alter column salestax_flag char(1) collate database_default NULL
go
alter table dbo.destination alter column plant varchar(10) collate database_default NULL
go
alter table dbo.destination alter column scheduler varchar(15) collate database_default NULL
go
alter table dbo.destination alter column gl_segment varchar(50) collate database_default NULL
go
alter table dbo.destination alter column address_4 varchar(40) collate database_default NULL
go
alter table dbo.destination alter column address_5 varchar(40) collate database_default NULL
go
alter table dbo.destination alter column address_6 varchar(40) collate database_default NULL
go
alter table dbo.destination alter column default_currency_unit varchar(3) collate database_default NULL
go
alter table dbo.destination alter column cs_status varchar(20) collate database_default NULL
go
alter table dbo.destination alter column region_code varchar(10) collate database_default NULL
go
alter table dbo.destination alter column custom1 varchar(10) collate database_default NULL
go
alter table dbo.destination alter column custom2 varchar(10) collate database_default NULL
go
alter table dbo.destination alter column custom3 varchar(10) collate database_default NULL
go
alter table dbo.destination alter column custom4 varchar(10) collate database_default NULL
go
alter table dbo.destination alter column custom5 varchar(10) collate database_default NULL
go
alter table dbo.destination alter column custom6 varchar(10) collate database_default NULL
go
alter table dbo.destination alter column custom7 varchar(10) collate database_default NULL
go
alter table dbo.destination alter column custom8 varchar(10) collate database_default NULL
go
alter table dbo.destination alter column custom9 varchar(10) collate database_default NULL
go
alter table dbo.destination alter column custom10 varchar(10) collate database_default NULL
go
alter table dbo.PMOOMSYNC alter column TMOT varchar(254) collate database_default NULL
go
alter table dbo.edi_modatek830_AccumATH alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_AccumATH alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_AccumATH alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_AccumATH alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_AccumATH alter column AccumQuantity varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_AccumATH alter column LastDate varchar(80) collate database_default NULL
go
alter table dbo.delfor_cums_gm2 alter column release_number varchar(35) collate database_default NULL
go
alter table dbo.delfor_cums_gm2 alter column ship_to_id varchar(35) collate database_default NULL
go
alter table dbo.delfor_cums_gm2 alter column buyer_part varchar(35) collate database_default NULL
go
alter table dbo.delfor_cums_gm2 alter column model_year varchar(35) collate database_default NULL
go
alter table dbo.delfor_cums_gm2 alter column fab_auth_qty varchar(35) collate database_default NULL
go
alter table dbo.delfor_cums_gm2 alter column fab_auth_start_dte varchar(35) collate database_default NULL
go
alter table dbo.delfor_cums_gm2 alter column raw_auth_qty varchar(35) collate database_default NULL
go
alter table dbo.delfor_cums_gm2 alter column raw_auth_start_dte varchar(35) collate database_default NULL
go
alter table dbo.contact_call_log alter column contact varchar(35) collate database_default NOT NULL
go
alter table dbo.contact_call_log alter column call_subject varchar(100) collate database_default NOT NULL
go
alter table dbo.contact_call_log alter column call_content text collate database_default NOT NULL
go
alter table dbo.bill_of_material_ec alter column parent_part varchar(25) collate database_default NOT NULL
go
alter table dbo.bill_of_material_ec alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.bill_of_material_ec alter column type char(1) collate database_default NOT NULL
go
alter table dbo.bill_of_material_ec alter column unit_measure varchar(2) collate database_default NOT NULL
go
alter table dbo.bill_of_material_ec alter column reference_no varchar(50) collate database_default NULL
go
alter table dbo.bill_of_material_ec alter column engineering_level varchar(10) collate database_default NULL
go
alter table dbo.bill_of_material_ec alter column operator varchar(5) collate database_default NULL
go
alter table dbo.bill_of_material_ec alter column substitute_part varchar(25) collate database_default NULL
go
alter table dbo.bill_of_material_ec alter column note varchar(255) collate database_default NULL
go
alter table dbo.PMPCTF alter column PTID char(40) collate database_default NULL
go
alter table dbo.edi_modatek830_AccumSHP alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_AccumSHP alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_AccumSHP alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_AccumSHP alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_AccumSHP alter column AccumQuantity varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_AccumSHP alter column LastDate varchar(80) collate database_default NULL
go
alter table dbo.shipper_copy alter column destination varchar(20) collate database_default NOT NULL
go
alter table dbo.shipper_copy alter column shipping_dock varchar(15) collate database_default NULL
go
alter table dbo.shipper_copy alter column ship_via varchar(20) collate database_default NULL
go
alter table dbo.shipper_copy alter column status varchar(1) collate database_default NULL
go
alter table dbo.shipper_copy alter column aetc_number varchar(20) collate database_default NULL
go
alter table dbo.shipper_copy alter column freight_type varchar(30) collate database_default NULL
go
alter table dbo.shipper_copy alter column printed varchar(1) collate database_default NULL
go
alter table dbo.shipper_copy alter column model_year_desc varchar(15) collate database_default NULL
go
alter table dbo.shipper_copy alter column model_year varchar(4) collate database_default NULL
go
alter table dbo.shipper_copy alter column customer varchar(25) collate database_default NULL
go
alter table dbo.shipper_copy alter column location varchar(20) collate database_default NULL
go
alter table dbo.shipper_copy alter column plant varchar(10) collate database_default NULL
go
alter table dbo.shipper_copy alter column type varchar(1) collate database_default NULL
go
alter table dbo.shipper_copy alter column invoiced varchar(1) collate database_default NULL
go
alter table dbo.shipper_copy alter column responsibility_code varchar(1) collate database_default NULL
go
alter table dbo.shipper_copy alter column trans_mode varchar(10) collate database_default NULL
go
alter table dbo.shipper_copy alter column pro_number varchar(35) collate database_default NULL
go
alter table dbo.shipper_copy alter column notes varchar(254) collate database_default NULL
go
alter table dbo.shipper_copy alter column truck_number varchar(30) collate database_default NULL
go
alter table dbo.shipper_copy alter column invoice_printed varchar(1) collate database_default NULL
go
alter table dbo.shipper_copy alter column seal_number varchar(25) collate database_default NULL
go
alter table dbo.shipper_copy alter column terms varchar(25) collate database_default NULL
go
alter table dbo.shipper_copy alter column container_message varchar(100) collate database_default NULL
go
alter table dbo.shipper_copy alter column picklist_printed varchar(1) collate database_default NULL
go
alter table dbo.shipper_copy alter column dropship_reconciled varchar(1) collate database_default NULL
go
alter table dbo.shipper_copy alter column platinum_trx_ctrl_num varchar(16) collate database_default NULL
go
alter table dbo.shipper_copy alter column posted varchar(1) collate database_default NULL
go
alter table dbo.shipper_copy alter column currency_unit varchar(3) collate database_default NULL
go
alter table dbo.shipper_copy alter column cs_status varchar(20) collate database_default NULL
go
alter table dbo.shipper_copy alter column bol_ship_to varchar(20) collate database_default NULL
go
alter table dbo.shipper_copy alter column bol_carrier varchar(35) collate database_default NULL
go
alter table dbo.shipper_copy alter column operator varchar(5) collate database_default NULL
go
alter table dbo.delfor_oh_gm2 alter column release_number varchar(35) collate database_default NULL
go
alter table dbo.delfor_oh_gm2 alter column release_date varchar(35) collate database_default NULL
go
alter table dbo.delfor_oh_gm2 alter column supplier varchar(35) collate database_default NULL
go
alter table dbo.delfor_oh_gm2 alter column ship_to_id varchar(35) collate database_default NULL
go
alter table dbo.delfor_oh_gm2 alter column buyer_part varchar(35) collate database_default NULL
go
alter table dbo.delfor_oh_gm2 alter column model_year varchar(35) collate database_default NULL
go
alter table dbo.delfor_oh_gm2 alter column dock_code varchar(35) collate database_default NULL
go
alter table dbo.delfor_oh_gm2 alter column line_feed_code varchar(35) collate database_default NULL
go
alter table dbo.currency_conversion alter column currency_code varchar(10) collate database_default NOT NULL
go
alter table dbo.currency_conversion alter column currency_display_symbol varchar(10) collate database_default NULL
go
alter table dbo.PMPDMABDT alter column DTTP varchar(254) collate database_default NULL
go
alter table dbo.PMPDMABDT alter column OTYP varchar(254) collate database_default NULL
go
alter table dbo.PMPDMABDT alter column CNAM varchar(254) collate database_default NULL
go
alter table dbo.edi_modatek830_Header alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_Header alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_Header alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_Header alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_Header alter column DockCode varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_Header alter column LineFeedCode varchar(80) collate database_default NULL
go
alter table dbo.delfor_cytd_gm2 alter column release_number varchar(35) collate database_default NULL
go
alter table dbo.delfor_cytd_gm2 alter column release_date varchar(35) collate database_default NULL
go
alter table dbo.delfor_cytd_gm2 alter column supplier varchar(35) collate database_default NULL
go
alter table dbo.delfor_cytd_gm2 alter column ship_to_id varchar(35) collate database_default NULL
go
alter table dbo.delfor_cytd_gm2 alter column buyer_part varchar(35) collate database_default NULL
go
alter table dbo.delfor_cytd_gm2 alter column model_year varchar(35) collate database_default NULL
go
alter table dbo.delfor_cytd_gm2 alter column cytd_start_date varchar(35) collate database_default NULL
go
alter table dbo.delfor_cytd_gm2 alter column cytd_qty_shipped varchar(35) collate database_default NULL
go
alter table dbo.contact_xref alter column contact varchar(50) collate database_default NOT NULL
go
alter table dbo.contact_xref alter column customer varchar(10) collate database_default NOT NULL
go
alter table dbo.contact_xref alter column destination varchar(20) collate database_default NOT NULL
go
alter table dbo.contact_xref alter column vendor varchar(10) collate database_default NOT NULL
go
alter table dbo.PMPDMADPR alter column PTYP varchar(64) collate database_default NULL
go
alter table dbo.PMPDMADPR alter column RTTP varchar(254) collate database_default NULL
go
alter table dbo.edi_modatek830_Releases alter column ReleaseNo varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_Releases alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_Releases alter column CustomerPart varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_Releases alter column CustomerPO varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_Releases alter column Quantity varchar(80) collate database_default NULL
go
alter table dbo.edi_modatek830_Releases alter column ShipDate varchar(80) collate database_default NULL
go
alter table dbo.fd5_830_releases alter column release_number varchar(30) collate database_default NULL
go
alter table dbo.fd5_830_releases alter column ship_to varchar(5) collate database_default NULL
go
alter table dbo.fd5_830_releases alter column ship_from varchar(5) collate database_default NULL
go
alter table dbo.fd5_830_releases alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.fd5_830_releases alter column customer_po varchar(30) collate database_default NULL
go
alter table dbo.fd5_830_releases alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.fd5_830_releases alter column cum_qty varchar(30) collate database_default NULL
go
alter table dbo.fd5_830_releases alter column date_indicator varchar(30) collate database_default NULL
go
alter table dbo.fd5_830_releases alter column date1 varchar(30) collate database_default NULL
go
alter table dbo.fd5_830_releases alter column date2 varchar(30) collate database_default NULL
go
alter table dbo.fd5_830_releases alter column delivery_time varchar(30) collate database_default NULL
go
alter table dbo.customer_origin_code alter column code varchar(25) collate database_default NOT NULL
go
alter table dbo.customer_origin_code alter column description varchar(50) collate database_default NULL
go
alter table dbo.custom_pbl_link alter column button_text varchar(15) collate database_default NOT NULL
go
alter table dbo.custom_pbl_link alter column menu_text varchar(25) collate database_default NOT NULL
go
alter table dbo.custom_pbl_link alter column module varchar(25) collate database_default NOT NULL
go
alter table dbo.custom_pbl_link alter column mdi_microhelp varchar(254) collate database_default NULL
go
alter table dbo.custom_pbl_link alter column open_window varchar(254) collate database_default NULL
go
alter table dbo.custom_pbl_link alter column type varchar(254) collate database_default NULL
go
alter table dbo.custom_pbl_link alter column command_line varchar(254) collate database_default NULL
go
alter table dbo.custom_pbl_link alter column sql_script varchar(254) collate database_default NULL
go
alter table dbo.custom_pbl_link alter column button_pic varchar(254) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column datawindow_name varchar(30) collate database_default NOT NULL
go
alter table dbo.dw_inquiry_files alter column screen_title varchar(40) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column table_name varchar(20) collate database_default NOT NULL
go
alter table dbo.dw_inquiry_files alter column primary_column varchar(20) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column change_buttons char(1) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column chain_parameter varchar(20) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column window_chain varchar(30) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column accept_args char(1) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column retrieve_all char(1) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column modifiable char(1) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column print_button char(1) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column auto_number_on_add char(1) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column graph_chain varchar(30) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column secondary_column varchar(20) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column append_title varchar(30) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column utility_1 varchar(30) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column utility_2 varchar(30) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column util_1_text varchar(30) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column util_1_icon varchar(30) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column util_2_text varchar(30) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column util_2_icon varchar(30) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column primary_column_3 varchar(20) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column primary_column_4 varchar(20) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column primary_column_5 varchar(20) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column normal_open_dblclk char(1) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column parm_field_on_add varchar(30) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column number_on_retrieve char(1) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column add_chain varchar(30) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column util1_parameter varchar(30) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column util2_parameter varchar(30) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column normal_open_on_add char(1) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column normal_open_with_parm char(1) collate database_default NULL
go
alter table dbo.dw_inquiry_files alter column default_operator varchar(10) collate database_default NULL
go
alter table dbo.m_in_release_plan_modatek alter column customer_part varchar(35) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan_modatek alter column shipto_id varchar(20) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan_modatek alter column customer_po varchar(20) collate database_default NULL
go
alter table dbo.m_in_release_plan_modatek alter column model_year varchar(4) collate database_default NULL
go
alter table dbo.m_in_release_plan_modatek alter column release_no varchar(30) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan_modatek alter column quantity_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.m_in_release_plan_modatek alter column release_dt_qualifier char(1) collate database_default NOT NULL
go
alter table dbo.dtproperties alter column property varchar(64) collate database_default NOT NULL
go
alter table dbo.dtproperties alter column value varchar(255) collate database_default NULL
go
alter table dbo.dtproperties alter column uvalue nvarchar(255) collate database_default NULL
go
alter table dbo.deljit_releases alter column release_number varchar(35) collate database_default NULL
go
alter table dbo.deljit_releases alter column ship_to_id varchar(35) collate database_default NULL
go
alter table dbo.deljit_releases alter column supplier varchar(35) collate database_default NULL
go
alter table dbo.deljit_releases alter column buyer_part varchar(35) collate database_default NULL
go
alter table dbo.deljit_releases alter column type1 varchar(35) collate database_default NULL
go
alter table dbo.deljit_releases alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.deljit_releases alter column model_year varchar(35) collate database_default NULL
go
alter table dbo.deljit_releases alter column quantity varchar(35) collate database_default NULL
go
alter table dbo.deljit_releases alter column date_time varchar(35) collate database_default NULL
go
alter table dbo.admin alter column version varchar(50) collate database_default NOT NULL
go
alter table dbo.admin alter column db_invoice_sync char(1) collate database_default NULL
go
alter table dbo.customer_service_status alter column status_name varchar(20) collate database_default NOT NULL
go
alter table dbo.customer_service_status alter column status_type varchar(1) collate database_default NOT NULL
go
alter table dbo.customer_service_status alter column default_value varchar(1) collate database_default NOT NULL
go
alter table dbo.defects alter column machine varchar(10) collate database_default NOT NULL
go
alter table dbo.defects alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.defects alter column reason varchar(20) collate database_default NULL
go
alter table dbo.defects alter column operator varchar(10) collate database_default NULL
go
alter table dbo.defects alter column shift char(1) collate database_default NULL
go
alter table dbo.defects alter column work_order varchar(10) collate database_default NULL
go
alter table dbo.defects alter column data_source varchar(10) collate database_default NULL
go
alter table dbo.part_purchasing alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_purchasing alter column buyer varchar(25) collate database_default NULL
go
alter table dbo.part_purchasing alter column primary_vendor varchar(10) collate database_default NULL
go
alter table dbo.part_purchasing alter column gl_account_code varchar(50) collate database_default NULL
go
alter table dbo.deljit_kanban alter column release_number varchar(35) collate database_default NULL
go
alter table dbo.deljit_kanban alter column ship_to_id varchar(35) collate database_default NULL
go
alter table dbo.deljit_kanban alter column supplier varchar(35) collate database_default NULL
go
alter table dbo.deljit_kanban alter column buyer_part varchar(35) collate database_default NULL
go
alter table dbo.deljit_kanban alter column model_year varchar(35) collate database_default NULL
go
alter table dbo.deljit_kanban alter column kanban_line varchar(35) collate database_default NULL
go
alter table dbo.deljit_kanban alter column line_id varchar(35) collate database_default NULL
go
alter table dbo.deljit_kanban alter column begin_kanban varchar(35) collate database_default NULL
go
alter table dbo.deljit_kanban alter column end_kanban varchar(35) collate database_default NULL
go
alter table dbo.PMPDMGRPE alter column PASS varchar(254) collate database_default NULL
go
alter table dbo.deljit_oh alter column release_date varchar(35) collate database_default NULL
go
alter table dbo.deljit_oh alter column release_number varchar(35) collate database_default NULL
go
alter table dbo.deljit_oh alter column ship_to_id varchar(35) collate database_default NULL
go
alter table dbo.deljit_oh alter column supplier varchar(35) collate database_default NULL
go
alter table dbo.deljit_oh alter column buyer_part varchar(35) collate database_default NULL
go
alter table dbo.deljit_oh alter column model_year varchar(35) collate database_default NULL
go
alter table dbo.deljit_oh alter column dock_code varchar(35) collate database_default NULL
go
alter table dbo.deljit_oh alter column line_feed_code varchar(35) collate database_default NULL
go
alter table dbo.dim_relation alter column dim_code varchar(2) collate database_default NOT NULL
go
alter table dbo.dim_relation alter column dimension varchar(10) collate database_default NULL
go
alter table dbo.dim_relation alter column delete_flag varchar(1) collate database_default NULL
go
alter table dbo.dim_relation alter column relationship varchar(254) collate database_default NULL
go
alter table dbo.commodity alter column id varchar(25) collate database_default NOT NULL
go
alter table dbo.commodity alter column notes varchar(255) collate database_default NULL
go
alter table dbo.PMPDMINDX alter column OTYP varchar(40) collate database_default NULL
go
alter table dbo.deljit_cytd alter column release_number varchar(35) collate database_default NULL
go
alter table dbo.deljit_cytd alter column ship_to_id varchar(35) collate database_default NULL
go
alter table dbo.deljit_cytd alter column supplier varchar(35) collate database_default NULL
go
alter table dbo.deljit_cytd alter column buyer_part varchar(35) collate database_default NULL
go
alter table dbo.deljit_cytd alter column model_year varchar(35) collate database_default NULL
go
alter table dbo.deljit_cytd alter column cytd_start_date varchar(35) collate database_default NULL
go
alter table dbo.deljit_cytd alter column cytd_ship_qty varchar(35) collate database_default NULL
go
alter table dbo.PlanningAccums alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.PlanningAccums alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.PlanningAccums alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.PlanningAccums alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.PlanningAccums alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.PlanningAccums alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.PlanningAccums alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.PlanningAccums alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.PlanningAccums alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.PlanningAccums alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.PlanningAccums alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.PlanningAccums alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.PlanningAccums alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.PlanningAccums alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.PlanningAccums alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.PlanningAccums alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.PlanningAccums alter column LastShipper varchar(50) collate database_default NULL
go
alter table dbo.PlanningAccums alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.PlanningAccums alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.package_materials alter column code varchar(20) collate database_default NOT NULL
go
alter table dbo.package_materials alter column name varchar(25) collate database_default NULL
go
alter table dbo.package_materials alter column type char(1) collate database_default NOT NULL
go
alter table dbo.package_materials alter column returnable char(1) collate database_default NOT NULL
go
alter table dbo.package_materials alter column stackable char(1) collate database_default NULL
go
alter table dbo.part_gl_account alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_gl_account alter column tran_type varchar(2) collate database_default NOT NULL
go
alter table dbo.part_gl_account alter column gl_account_no_db varchar(50) collate database_default NULL
go
alter table dbo.part_gl_account alter column gl_account_no_cr varchar(50) collate database_default NULL
go
alter table dbo.part_gl_account alter column name varchar(50) collate database_default NULL
go
alter table dbo.dimensions alter column dim_code varchar(2) collate database_default NOT NULL
go
alter table dbo.dimensions alter column dimension varchar(10) collate database_default NOT NULL
go
alter table dbo.dimensions alter column delete_flag varchar(1) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column part_number varchar(25) collate database_default NOT NULL
go
alter table dbo.order_detail_backupmodatek alter column type varchar(1) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column product_name varchar(100) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column notes varchar(255) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column assigned varchar(35) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column status varchar(1) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column destination varchar(25) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column unit varchar(2) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column plant varchar(10) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column ship_type varchar(1) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column packaging_type varchar(20) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column custom01 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column custom02 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column custom03 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column engineering_level varchar(25) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column box_label varchar(25) collate database_default NULL
go
alter table dbo.order_detail_backupmodatek alter column pallet_label varchar(25) collate database_default NULL
go
alter table dbo.filters alter column filtername varchar(10) collate database_default NOT NULL
go
alter table dbo.filters alter column module varchar(30) collate database_default NOT NULL
go
alter table dbo.filters alter column leftparenthesis varchar(10) collate database_default NULL
go
alter table dbo.filters alter column column_name varchar(255) collate database_default NOT NULL
go
alter table dbo.filters alter column roperator varchar(15) collate database_default NOT NULL
go
alter table dbo.filters alter column value varchar(255) collate database_default NOT NULL
go
alter table dbo.filters alter column loperator varchar(10) collate database_default NULL
go
alter table dbo.filters alter column operator varchar(5) collate database_default NULL
go
alter table dbo.filters alter column rightparenthesis varchar(10) collate database_default NULL
go
alter table dbo.PMPDMPARM alter column DTTP varchar(254) collate database_default NULL
go
alter table dbo.PMPDMPARM alter column DVAL varchar(254) collate database_default NULL
go
alter table dbo.PMPDMPARM alter column PTTP varchar(254) collate database_default NULL
go
alter table dbo.titan_test alter column test varchar(35) collate database_default NULL
go
alter table dbo.region_code alter column code varchar(10) collate database_default NOT NULL
go
alter table dbo.region_code alter column description varchar(50) collate database_default NULL
go
alter table dbo.downtime alter column machine varchar(10) collate database_default NOT NULL
go
alter table dbo.downtime alter column reason_code varchar(10) collate database_default NULL
go
alter table dbo.downtime alter column reason_name varchar(35) collate database_default NULL
go
alter table dbo.downtime alter column notes varchar(255) collate database_default NULL
go
alter table dbo.downtime alter column employee varchar(10) collate database_default NULL
go
alter table dbo.downtime alter column shift char(1) collate database_default NULL
go
alter table dbo.downtime alter column job varchar(10) collate database_default NULL
go
alter table dbo.downtime alter column part varchar(15) collate database_default NULL
go
alter table dbo.downtime alter column type char(1) collate database_default NULL
go
alter table dbo.downtime alter column production_pointer varchar(10) collate database_default NULL
go
alter table dbo.downtime alter column data_source varchar(10) collate database_default NULL
go
alter table dbo.PMPDMPKCU alter column RTTP varchar(254) collate database_default NULL
go
alter table dbo.package_materials_copy alter column code varchar(20) collate database_default NOT NULL
go
alter table dbo.package_materials_copy alter column name varchar(25) collate database_default NULL
go
alter table dbo.package_materials_copy alter column type char(1) collate database_default NOT NULL
go
alter table dbo.package_materials_copy alter column returnable char(1) collate database_default NOT NULL
go
alter table dbo.package_materials_copy alter column stackable char(1) collate database_default NULL
go
alter table dbo.sales_manager_code alter column code varchar(10) collate database_default NOT NULL
go
alter table dbo.sales_manager_code alter column description varchar(50) collate database_default NULL
go
alter table dbo.downtime_codes alter column dt_code varchar(10) collate database_default NOT NULL
go
alter table dbo.downtime_codes alter column code_group varchar(25) collate database_default NULL
go
alter table dbo.downtime_codes alter column code_description varchar(35) collate database_default NULL
go
alter table dbo.workorder_detail alter column workorder varchar(10) collate database_default NOT NULL
go
alter table dbo.workorder_detail alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.workorder_detail alter column plant varchar(20) collate database_default NULL
go
alter table dbo.PMPDMPKPR alter column RTTP varchar(254) collate database_default NULL
go
alter table dbo.textron_830_releases alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.textron_830_releases alter column forecast_date varchar(30) collate database_default NULL
go
alter table dbo.textron_830_releases alter column supplier varchar(30) collate database_default NULL
go
alter table dbo.textron_830_releases alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.textron_830_releases alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.textron_830_releases alter column customer_po varchar(30) collate database_default NULL
go
alter table dbo.textron_830_releases alter column ecl varchar(35) collate database_default NULL
go
alter table dbo.textron_830_releases alter column model_year varchar(30) collate database_default NULL
go
alter table dbo.textron_830_releases alter column QTY0101 varchar(3) collate database_default NULL
go
alter table dbo.textron_830_releases alter column QTY0102 varchar(17) collate database_default NULL
go
alter table dbo.textron_830_releases alter column SCC01 char(1) collate database_default NULL
go
alter table dbo.textron_830_releases alter column DTM0101 varchar(3) collate database_default NULL
go
alter table dbo.textron_830_releases alter column DTM0102 varchar(8) collate database_default NULL
go
alter table dbo.textron_830_releases alter column RFF0102 varchar(35) collate database_default NULL
go
alter table dbo.xreport_datasource alter column datasource_name varchar(8) collate database_default NOT NULL
go
alter table dbo.xreport_datasource alter column description varchar(50) collate database_default NOT NULL
go
alter table dbo.xreport_datasource alter column library_name varchar(50) collate database_default NULL
go
alter table dbo.xreport_datasource alter column dw_name varchar(50) collate database_default NOT NULL
go
alter table dbo.edi_ff_layout alter column transaction_set char(3) collate database_default NOT NULL
go
alter table dbo.edi_ff_layout alter column overlay_group char(3) collate database_default NOT NULL
go
alter table dbo.edi_ff_layout alter column line char(2) collate database_default NOT NULL
go
alter table dbo.edi_ff_layout alter column field char(2) collate database_default NOT NULL
go
alter table dbo.edi_ff_layout alter column field_description varchar(25) collate database_default NOT NULL
go
alter table dbo.edi_ff_layout alter column data_type char(2) collate database_default NOT NULL
go
alter table dbo.edi_ff_layout alter column segment varchar(6) collate database_default NULL
go
alter table dbo.edi_ff_layout alter column description varchar(25) collate database_default NOT NULL
go
alter table dbo.edi_ff_layout alter column version varchar(6) collate database_default NOT NULL
go
alter table dbo.group_technology alter column id varchar(25) collate database_default NOT NULL
go
alter table dbo.group_technology alter column notes varchar(255) collate database_default NULL
go
alter table dbo.group_technology alter column source_type varchar(10) collate database_default NULL
go
alter table dbo.textron_830_releases_copy alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.textron_830_releases_copy alter column forecast_date varchar(30) collate database_default NULL
go
alter table dbo.textron_830_releases_copy alter column supplier varchar(30) collate database_default NULL
go
alter table dbo.textron_830_releases_copy alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.textron_830_releases_copy alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.textron_830_releases_copy alter column customer_po varchar(30) collate database_default NULL
go
alter table dbo.textron_830_releases_copy alter column ecl varchar(35) collate database_default NULL
go
alter table dbo.textron_830_releases_copy alter column model_year varchar(30) collate database_default NULL
go
alter table dbo.textron_830_releases_copy alter column QTY0101 varchar(3) collate database_default NULL
go
alter table dbo.textron_830_releases_copy alter column QTY0102 varchar(17) collate database_default NULL
go
alter table dbo.textron_830_releases_copy alter column SCC01 char(1) collate database_default NULL
go
alter table dbo.textron_830_releases_copy alter column DTM0101 varchar(3) collate database_default NULL
go
alter table dbo.textron_830_releases_copy alter column DTM0102 varchar(8) collate database_default NULL
go
alter table dbo.textron_830_releases_copy alter column RFF0102 varchar(35) collate database_default NULL
go
alter table dbo.PMPDMPKVA alter column DTTP varchar(254) collate database_default NULL
go
alter table dbo.textron_830_oh_data alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.textron_830_oh_data alter column supplier varchar(30) collate database_default NULL
go
alter table dbo.textron_830_oh_data alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.textron_830_oh_data alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.textron_830_oh_data alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.textron_830_oh_data alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.textron_830_oh_data alter column dock_REF_DK varchar(30) collate database_default NULL
go
alter table dbo.textron_830_oh_data alter column user_defined1 varchar(30) collate database_default NULL
go
alter table dbo.textron_830_oh_data alter column user_defined2 varchar(30) collate database_default NULL
go
alter table dbo.textron_830_oh_data alter column user_defined3 varchar(30) collate database_default NULL
go
alter table dbo.xreport_library alter column name varchar(25) collate database_default NOT NULL
go
alter table dbo.xreport_library alter column report varchar(25) collate database_default NOT NULL
go
alter table dbo.xreport_library alter column datasource varchar(8) collate database_default NOT NULL
go
alter table dbo.xreport_library alter column xlabelformat varchar(50) collate database_default NOT NULL
go
alter table dbo.edi_ff_loops alter column transaction_set char(3) collate database_default NOT NULL
go
alter table dbo.edi_ff_loops alter column overlay_group char(3) collate database_default NOT NULL
go
alter table dbo.edi_ff_loops alter column line_name varchar(25) collate database_default NULL
go
alter table dbo.edi_ff_loops alter column loop_name varchar(25) collate database_default NULL
go
alter table dbo.edi_ff_loops alter column used char(1) collate database_default NULL
go
alter table dbo.edi_ff_loops alter column loop_used char(1) collate database_default NULL
go
alter table dbo.objects_ab alter column name varchar(128) collate database_default NULL
go
alter table dbo.objects_ab alter column type char(2) collate database_default NULL
go
alter table dbo.labor alter column id varchar(25) collate database_default NOT NULL
go
alter table dbo.labor alter column group_no varchar(25) collate database_default NULL
go
alter table dbo.labor alter column notes varchar(255) collate database_default NULL
go
alter table dbo.labor alter column gl_segment varchar(50) collate database_default NULL
go
alter table dbo.PMPDMPROC alter column MNAM varchar(254) collate database_default NULL
go
alter table dbo.textron_830_cum alter column ship_to varchar(10) collate database_default NULL
go
alter table dbo.textron_830_cum alter column supplier varchar(30) collate database_default NULL
go
alter table dbo.textron_830_cum alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.textron_830_cum alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.PMPDMPROF alter column CHFM varchar(254) collate database_default NULL
go
alter table dbo.PMPDMPROF alter column CHIV varchar(254) collate database_default NULL
go
alter table dbo.PMPDMPROF alter column CHVL varchar(254) collate database_default NULL
go
alter table dbo.PMPDMPROF alter column COLN varchar(254) collate database_default NULL
go
alter table dbo.PMPDMPROF alter column ODSL varchar(254) collate database_default NULL
go
alter table dbo.PMPDMPROF alter column ODSN varchar(254) collate database_default NULL
go
alter table dbo.PMPDMPROF alter column ODSP varchar(254) collate database_default NULL
go
alter table dbo.PMPDMPROF alter column OFIL varchar(254) collate database_default NULL
go
alter table dbo.PMPDMPROF alter column TABL varchar(254) collate database_default NULL
go
alter table dbo.textron_830_notes alter column supplier varchar(30) collate database_default NULL
go
alter table dbo.textron_830_notes alter column ship_to varchar(10) collate database_default NULL
go
alter table dbo.textron_830_notes alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.textron_830_notes alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.textron_830_notes alter column notes varchar(70) collate database_default NULL
go
alter table dbo.textron_830_notes alter column notes2 varchar(70) collate database_default NULL
go
alter table dbo.m_gmv_862_ship_schedule alter column schedule_number varchar(30) collate database_default NULL
go
alter table dbo.m_gmv_862_ship_schedule alter column release_number varchar(30) collate database_default NULL
go
alter table dbo.m_gmv_862_ship_schedule alter column ship_to_type varchar(2) collate database_default NULL
go
alter table dbo.m_gmv_862_ship_schedule alter column ship_to varchar(17) collate database_default NULL
go
alter table dbo.m_gmv_862_ship_schedule alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.m_gmv_862_ship_schedule alter column model_year varchar(30) collate database_default NULL
go
alter table dbo.m_gmv_862_ship_schedule alter column qty varchar(30) collate database_default NULL
go
alter table dbo.m_gmv_862_ship_schedule alter column ship_date varchar(30) collate database_default NULL
go
alter table dbo.machine_process alter column machine varchar(25) collate database_default NOT NULL
go
alter table dbo.machine_process alter column process varchar(10) collate database_default NOT NULL
go
alter table dbo.PMPDMREFR alter column CARD varchar(10) collate database_default NULL
go
alter table dbo.PMPDMREFR alter column FKCN varchar(254) collate database_default NULL
go
alter table dbo.PMPDMREFR alter column IMPL varchar(2) collate database_default NULL
go
alter table dbo.PMPDMREFR alter column CROL varchar(254) collate database_default NULL
go
alter table dbo.PMPDMREFR alter column PROL varchar(254) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Address2 alter column Relno varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Address2 alter column ShipToID varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Address2 alter column MaterialIssuerID varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Address2 alter column SupplierCode varchar(80) collate database_default NULL
go
alter table dbo.m_gmv_862_label_data alter column ship_to_type varchar(2) collate database_default NULL
go
alter table dbo.m_gmv_862_label_data alter column ship_to varchar(17) collate database_default NULL
go
alter table dbo.m_gmv_862_label_data alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.m_gmv_862_label_data alter column model_year varchar(30) collate database_default NULL
go
alter table dbo.m_gmv_862_label_data alter column pack_char varchar(2) collate database_default NULL
go
alter table dbo.m_gmv_862_label_data alter column pack_code varchar(7) collate database_default NULL
go
alter table dbo.m_gmv_862_label_data alter column label_data varchar(78) collate database_default NULL
go
alter table dbo.employee alter column name varchar(40) collate database_default NOT NULL
go
alter table dbo.employee alter column operator_code varchar(5) collate database_default NOT NULL
go
alter table dbo.employee alter column password varchar(5) collate database_default NOT NULL
go
alter table dbo.employee alter column epassword text collate database_default NULL
go
alter table dbo.PMPDMROLE alter column PASS varchar(254) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Dock2 alter column Relno varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Dock2 alter column CAMIPart varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Dock2 alter column LocType varchar(80) collate database_default NULL
go
alter table dbo.edi_CAMIDELJIT_Dock2 alter column Location varchar(80) collate database_default NULL
go
alter table dbo.m_gmv_862_line_feed alter column ship_to_type varchar(2) collate database_default NULL
go
alter table dbo.m_gmv_862_line_feed alter column ship_to varchar(17) collate database_default NULL
go
alter table dbo.m_gmv_862_line_feed alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.m_gmv_862_line_feed alter column model_year varchar(30) collate database_default NULL
go
alter table dbo.m_gmv_862_line_feed alter column dock_code varchar(5) collate database_default NULL
go
alter table dbo.m_gmv_862_line_feed alter column line_feed varchar(30) collate database_default NULL
go
alter table dbo.m_gmv_862_line_feed alter column stockman varchar(35) collate database_default NULL
go
alter table dbo.log alter column message varchar(255) collate database_default NULL
go
alter table dbo.part_machine alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_machine alter column machine varchar(15) collate database_default NOT NULL
go
alter table dbo.part_machine alter column process_id varchar(25) collate database_default NULL
go
alter table dbo.part_machine alter column cycle_unit varchar(10) collate database_default NULL
go
alter table dbo.part_machine alter column overlap_type char(1) collate database_default NULL
go
alter table dbo.part_machine alter column labor_code varchar(25) collate database_default NULL
go
alter table dbo.part_machine alter column activity varchar(25) collate database_default NULL
go
alter table dbo.m_gmv_830_firm alter column release_number varchar(3) collate database_default NULL
go
alter table dbo.m_gmv_830_firm alter column ship_to_type varchar(2) collate database_default NULL
go
alter table dbo.m_gmv_830_firm alter column ship_to varchar(17) collate database_default NULL
go
alter table dbo.m_gmv_830_firm alter column type varchar(2) collate database_default NULL
go
alter table dbo.m_gmv_830_firm alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.m_gmv_830_firm alter column firm_qty varchar(12) collate database_default NULL
go
alter table dbo.m_gmv_830_firm alter column ship_date varchar(6) collate database_default NULL
go
alter table dbo.m_gmv_830_firm alter column cum_ytd varchar(12) collate database_default NULL
go
alter table dbo.PlanningAuthAccums alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.PlanningAuthAccums alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.PlanningAuthAccums alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.PlanningAuthAccums alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.PlanningAuthAccums alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.PlanningAuthAccums alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.PlanningAuthAccums alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.PlanningAuthAccums alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.PlanningAuthAccums alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.PlanningAuthAccums alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.PlanningAuthAccums alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.PlanningAuthAccums alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.PlanningAuthAccums alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.PlanningAuthAccums alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.PlanningAuthAccums alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.PlanningAuthAccums alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.PlanningAuthAccums alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.PlanningAuthAccums alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.m_gmv_830_planning alter column line_indicator varchar(2) collate database_default NULL
go
alter table dbo.m_gmv_830_planning alter column release_number varchar(3) collate database_default NULL
go
alter table dbo.m_gmv_830_planning alter column ship_to_type varchar(2) collate database_default NULL
go
alter table dbo.m_gmv_830_planning alter column ship_to varchar(17) collate database_default NULL
go
alter table dbo.m_gmv_830_planning alter column type varchar(2) collate database_default NULL
go
alter table dbo.m_gmv_830_planning alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.m_gmv_830_planning alter column planning_qty varchar(12) collate database_default NULL
go
alter table dbo.m_gmv_830_planning alter column ship_date varchar(6) collate database_default NULL
go
alter table dbo.m_gmv_830_planning alter column cum_ytd varchar(12) collate database_default NULL
go
alter table dbo.exp_apdata_detail alter column trx_ctrl_num varchar(16) collate database_default NOT NULL
go
alter table dbo.exp_apdata_detail alter column po_ctrl_num varchar(8) collate database_default NULL
go
alter table dbo.exp_apdata_detail alter column gl_exp_acct varchar(32) collate database_default NOT NULL
go
alter table dbo.exp_apdata_detail alter column line_description varchar(60) collate database_default NULL
go
alter table dbo.department alter column code varchar(30) collate database_default NOT NULL
go
alter table dbo.department alter column name varchar(50) collate database_default NOT NULL
go
alter table dbo.PMPDMTABL alter column CKCN varchar(254) collate database_default NULL
go
alter table dbo.PMPDMTABL alter column TTYP varchar(254) collate database_default NULL
go
alter table dbo.PMPDMTABL alter column XELT varchar(254) collate database_default NULL
go
alter table dbo.m_gmc_830_releases alter column release_number varchar(3) collate database_default NULL
go
alter table dbo.m_gmc_830_releases alter column ship_to_type varchar(2) collate database_default NULL
go
alter table dbo.m_gmc_830_releases alter column ship_to varchar(9) collate database_default NULL
go
alter table dbo.m_gmc_830_releases alter column type varchar(2) collate database_default NULL
go
alter table dbo.m_gmc_830_releases alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.m_gmc_830_releases alter column qty varchar(12) collate database_default NULL
go
alter table dbo.m_gmc_830_releases alter column identifier varchar(1) collate database_default NULL
go
alter table dbo.m_gmc_830_releases alter column ship_date varchar(6) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column type varchar(1) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2004 alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2004 alter column remarks varchar(10) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2004 alter column salesman varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column customer varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column vendor varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column po_number varchar(30) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column operator varchar(5) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2004 alter column from_loc varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column to_loc varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column lot varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column status varchar(1) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2004 alter column shipper varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column flag varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column activity varchar(25) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column unit varchar(2) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column workorder varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column control_number varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column custom1 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column custom2 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column custom3 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column custom4 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column custom5 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column plant varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column invoice_number varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column notes varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column gl_account varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column package_type varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column sales_order varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column release_no varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column user_defined_status varchar(30) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column engineering_level varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column posted varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column origin varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column destination varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column object_type varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column part_name varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column field1 varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column field2 varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column show_on_shipper varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column kanban_number varchar(6) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2004 alter column dim_qty_string_other varchar(50) collate database_default NULL
go
alter table dbo.PMPDMTKEY alter column CNST varchar(254) collate database_default NULL
go
alter table dbo.m_gmc_862_ship_schedule alter column schedule_number varchar(25) collate database_default NULL
go
alter table dbo.m_gmc_862_ship_schedule alter column release_number varchar(3) collate database_default NULL
go
alter table dbo.m_gmc_862_ship_schedule alter column ship_to_type varchar(2) collate database_default NULL
go
alter table dbo.m_gmc_862_ship_schedule alter column ship_to varchar(9) collate database_default NULL
go
alter table dbo.m_gmc_862_ship_schedule alter column type varchar(2) collate database_default NULL
go
alter table dbo.m_gmc_862_ship_schedule alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.m_gmc_862_ship_schedule alter column qty varchar(12) collate database_default NULL
go
alter table dbo.m_gmc_862_ship_schedule alter column ship_date varchar(6) collate database_default NULL
go
alter table dbo.exp_apdata_header alter column trx_ctrl_num varchar(16) collate database_default NOT NULL
go
alter table dbo.exp_apdata_header alter column doc_ctrl_num varchar(16) collate database_default NULL
go
alter table dbo.exp_apdata_header alter column user_trx_type_code varchar(8) collate database_default NULL
go
alter table dbo.exp_apdata_header alter column batch_code varchar(16) collate database_default NOT NULL
go
alter table dbo.exp_apdata_header alter column vendor_code varchar(12) collate database_default NULL
go
alter table dbo.exp_apdata_header alter column terms_code varchar(8) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column type varchar(1) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2005 alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2005 alter column remarks varchar(10) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2005 alter column salesman varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column customer varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column vendor varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column po_number varchar(30) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column operator varchar(5) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2005 alter column from_loc varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column to_loc varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column lot varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column status varchar(1) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2005 alter column shipper varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column flag varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column activity varchar(25) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column unit varchar(2) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column workorder varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column control_number varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column custom1 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column custom2 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column custom3 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column custom4 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column custom5 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column plant varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column invoice_number varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column notes varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column gl_account varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column package_type varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column sales_order varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column release_no varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column user_defined_status varchar(30) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column engineering_level varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column posted varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column origin varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column destination varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column object_type varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column part_name varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column field1 varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column field2 varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column show_on_shipper varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column kanban_number varchar(6) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2005 alter column dim_qty_string_other varchar(50) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column part_number varchar(25) collate database_default NOT NULL
go
alter table dbo.order_detail_copy_1 alter column type varchar(1) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column product_name varchar(100) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column notes varchar(255) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column assigned varchar(35) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column status varchar(1) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column destination varchar(25) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column unit varchar(2) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column plant varchar(10) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column ship_type varchar(1) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column packaging_type varchar(20) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column custom01 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column custom02 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column custom03 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column engineering_level varchar(25) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column box_label varchar(25) collate database_default NULL
go
alter table dbo.order_detail_copy_1 alter column pallet_label varchar(25) collate database_default NULL
go
alter table dbo.m_gmc_862_label_data alter column schedule_number varchar(25) collate database_default NULL
go
alter table dbo.m_gmc_862_label_data alter column release_number varchar(3) collate database_default NULL
go
alter table dbo.m_gmc_862_label_data alter column ship_to_type varchar(2) collate database_default NULL
go
alter table dbo.m_gmc_862_label_data alter column ship_to varchar(9) collate database_default NULL
go
alter table dbo.m_gmc_862_label_data alter column type varchar(2) collate database_default NULL
go
alter table dbo.m_gmc_862_label_data alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.m_gmc_862_label_data alter column label_line varchar(3) collate database_default NULL
go
alter table dbo.m_gmc_862_label_data alter column label_data varchar(21) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column type varchar(1) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2006 alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2006 alter column remarks varchar(10) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2006 alter column salesman varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column customer varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column vendor varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column po_number varchar(30) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column operator varchar(5) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2006 alter column from_loc varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column to_loc varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column lot varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column status varchar(1) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2006 alter column shipper varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column flag varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column activity varchar(25) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column unit varchar(2) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column workorder varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column control_number varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column custom1 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column custom2 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column custom3 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column custom4 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column custom5 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column plant varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column invoice_number varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column notes varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column gl_account varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column package_type varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column sales_order varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column release_no varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column user_defined_status varchar(30) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column engineering_level varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column posted varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column origin varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column destination varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column object_type varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column part_name varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column field1 varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column field2 varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column show_on_shipper varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column kanban_number varchar(6) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2006 alter column dim_qty_string_other varchar(50) collate database_default NULL
go
alter table dbo.PMPDMTRGR alter column EVNT varchar(64) collate database_default NULL
go
alter table dbo.PMPDMTRGR alter column TTIM varchar(64) collate database_default NULL
go
alter table dbo.PMPDMTRGR alter column MNAM varchar(254) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column part_number varchar(25) collate database_default NOT NULL
go
alter table dbo.order_detail_copy_2 alter column type varchar(1) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column product_name varchar(100) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column notes varchar(255) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column assigned varchar(35) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column status varchar(1) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column destination varchar(25) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column unit varchar(2) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column plant varchar(10) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column ship_type varchar(1) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column packaging_type varchar(20) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column custom01 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column custom02 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column custom03 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column engineering_level varchar(25) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column box_label varchar(25) collate database_default NULL
go
alter table dbo.order_detail_copy_2 alter column pallet_label varchar(25) collate database_default NULL
go
alter table dbo.m_gmc_862_line_feed_kanban alter column schedule_number varchar(25) collate database_default NULL
go
alter table dbo.m_gmc_862_line_feed_kanban alter column release_number varchar(3) collate database_default NULL
go
alter table dbo.m_gmc_862_line_feed_kanban alter column ship_to_type varchar(2) collate database_default NULL
go
alter table dbo.m_gmc_862_line_feed_kanban alter column ship_to varchar(9) collate database_default NULL
go
alter table dbo.m_gmc_862_line_feed_kanban alter column type varchar(2) collate database_default NULL
go
alter table dbo.m_gmc_862_line_feed_kanban alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.m_gmc_862_line_feed_kanban alter column dock_code varchar(8) collate database_default NULL
go
alter table dbo.m_gmc_862_line_feed_kanban alter column line_feed varchar(30) collate database_default NULL
go
alter table dbo.m_gmc_862_line_feed_kanban alter column beg_kanban varchar(6) collate database_default NULL
go
alter table dbo.m_gmc_862_line_feed_kanban alter column end_kanban varchar(6) collate database_default NULL
go
alter table dbo.gl_tran_type alter column code varchar(1) collate database_default NOT NULL
go
alter table dbo.gl_tran_type alter column name varchar(25) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2007 alter column type varchar(1) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2007 alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2007 alter column remarks varchar(10) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2007 alter column salesman varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column customer varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column vendor varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column po_number varchar(30) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column operator varchar(5) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2007 alter column from_loc varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column to_loc varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column lot varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column status varchar(1) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2007 alter column shipper varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column flag varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column activity varchar(25) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column unit varchar(2) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column workorder varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column control_number varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column custom1 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column custom2 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column custom3 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column custom4 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column custom5 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column plant varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column invoice_number varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column notes varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column gl_account varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column package_type varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column sales_order varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column release_no varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column user_defined_status varchar(30) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column engineering_level varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column posted varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column origin varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column destination varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column object_type varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column part_name varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column field1 varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column field2 varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column show_on_shipper varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column kanban_number varchar(6) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2007 alter column dim_qty_string_other varchar(50) collate database_default NULL
go
alter table dbo.carrier alter column name varchar(35) collate database_default NOT NULL
go
alter table dbo.carrier alter column scac varchar(4) collate database_default NOT NULL
go
alter table dbo.carrier alter column trans_mode varchar(2) collate database_default NOT NULL
go
alter table dbo.carrier alter column phone varchar(20) collate database_default NULL
go
alter table dbo.PMPDMTRGT alter column EVNT varchar(64) collate database_default NULL
go
alter table dbo.PMPDMTRGT alter column TNAM varchar(254) collate database_default NULL
go
alter table dbo.PMPDMTRGT alter column TTIM varchar(64) collate database_default NULL
go
alter table dbo.PMPDMTRGT alter column TRTP varchar(254) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column part_number varchar(25) collate database_default NOT NULL
go
alter table dbo.order_detail_copy_1b alter column type varchar(1) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column product_name varchar(100) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column notes varchar(255) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column assigned varchar(35) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column status varchar(1) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column destination varchar(25) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column unit varchar(2) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column plant varchar(10) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column ship_type varchar(1) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column packaging_type varchar(20) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column custom01 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column custom02 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column custom03 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column engineering_level varchar(25) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column box_label varchar(25) collate database_default NULL
go
alter table dbo.order_detail_copy_1b alter column pallet_label varchar(25) collate database_default NULL
go
alter table dbo.delfor_releases alter column release_number varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases alter column ship_to_id varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases alter column buyer_part varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases alter column type1 varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases alter column model_year varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases alter column forecast_type varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases alter column quantity varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases alter column start_date varchar(35) collate database_default NULL
go
alter table dbo.delfor_releases alter column date_mgo varchar(35) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column type varchar(1) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2008 alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2008 alter column remarks varchar(10) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2008 alter column salesman varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column customer varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column vendor varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column po_number varchar(30) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column operator varchar(5) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2008 alter column from_loc varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column to_loc varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column lot varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column status varchar(1) collate database_default NOT NULL
go
alter table dbo.audit_trail_archive_2008 alter column shipper varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column flag varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column activity varchar(25) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column unit varchar(2) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column workorder varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column control_number varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column custom1 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column custom2 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column custom3 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column custom4 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column custom5 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column plant varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column invoice_number varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column notes varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column gl_account varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column package_type varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column sales_order varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column release_no varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column user_defined_status varchar(30) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column engineering_level varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column posted varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column origin varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column destination varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column object_type varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column part_name varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column field1 varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column field2 varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column show_on_shipper varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column kanban_number varchar(6) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_archive_2008 alter column dim_qty_string_other varchar(50) collate database_default NULL
go
alter table dbo.PMPDMUSER alter column PASS varchar(254) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column part_number varchar(25) collate database_default NOT NULL
go
alter table dbo.order_detail_copy_2b alter column type varchar(1) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column product_name varchar(100) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column notes varchar(255) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column assigned varchar(35) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column status varchar(1) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column destination varchar(25) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column unit varchar(2) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column plant varchar(10) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column ship_type varchar(1) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column packaging_type varchar(20) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column custom01 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column custom02 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column custom03 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column engineering_level varchar(25) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column box_label varchar(25) collate database_default NULL
go
alter table dbo.order_detail_copy_2b alter column pallet_label varchar(25) collate database_default NULL
go
alter table dbo.gt_comp_list alter column part_number varchar(25) collate database_default NOT NULL
go
alter table dbo.gt_comp_list alter column processed char(1) collate database_default NOT NULL
go
alter table dbo.PMPDMVIDX alter column OTYP varchar(40) collate database_default NULL
go
alter table dbo.delfor_cums alter column release_number varchar(35) collate database_default NULL
go
alter table dbo.delfor_cums alter column ship_to_id varchar(35) collate database_default NULL
go
alter table dbo.delfor_cums alter column buyer_part varchar(35) collate database_default NULL
go
alter table dbo.delfor_cums alter column model_year varchar(35) collate database_default NULL
go
alter table dbo.delfor_cums alter column fab_auth_qty varchar(35) collate database_default NULL
go
alter table dbo.delfor_cums alter column fab_auth_start_dte varchar(35) collate database_default NULL
go
alter table dbo.delfor_cums alter column raw_auth_qty varchar(35) collate database_default NULL
go
alter table dbo.delfor_cums alter column raw_auth_start_dte varchar(35) collate database_default NULL
go
alter table dbo.inventory_accuracy_history alter column code varchar(15) collate database_default NOT NULL
go
alter table dbo.inventory_accuracy_history alter column type char(1) collate database_default NOT NULL
go
alter table dbo.inventory_accuracy_history alter column group_no varchar(15) collate database_default NULL
go
alter table dbo.PMPDMVIEW alter column TTYP varchar(254) collate database_default NULL
go
alter table dbo.PMPDMVIEW alter column XELT varchar(254) collate database_default NULL
go
alter table dbo.PlanningHeaders alter column TradingPartner varchar(50) collate database_default NULL
go
alter table dbo.PlanningHeaders alter column DocType varchar(6) collate database_default NULL
go
alter table dbo.PlanningHeaders alter column Version varchar(20) collate database_default NULL
go
alter table dbo.PlanningHeaders alter column Release varchar(30) collate database_default NULL
go
alter table dbo.PlanningHeaders alter column DocNumber varchar(50) collate database_default NULL
go
alter table dbo.PlanningHeaders alter column ControlNumber varchar(10) collate database_default NULL
go
alter table dbo.PlanningHeaders alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.PlanningHeaders alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.gm_pilot_releases alter column customer_part varchar(35) collate database_default NULL
go
alter table dbo.gm_pilot_releases alter column ship_to_id varchar(20) collate database_default NULL
go
alter table dbo.gm_pilot_releases alter column customer_po varchar(20) collate database_default NULL
go
alter table dbo.gm_pilot_releases alter column model_year varchar(4) collate database_default NULL
go
alter table dbo.gm_pilot_releases alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.gm_pilot_releases alter column forecast_type varchar(2) collate database_default NULL
go
alter table dbo.part_packaging alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_packaging alter column code varchar(20) collate database_default NOT NULL
go
alter table dbo.part_packaging alter column manual_tare char(1) collate database_default NULL
go
alter table dbo.part_packaging alter column label_format varchar(25) collate database_default NULL
go
alter table dbo.part_packaging alter column round_to_whole_number char(1) collate database_default NULL
go
alter table dbo.part_packaging alter column package_is_object char(1) collate database_default NULL
go
alter table dbo.part_packaging alter column unit varchar(3) collate database_default NULL
go
alter table dbo.part_packaging alter column stage_using_weight char(1) collate database_default NULL
go
alter table dbo.part_packaging alter column threshold_upper_type varchar(1) collate database_default NULL
go
alter table dbo.part_packaging alter column threshold_lower_type varchar(1) collate database_default NULL
go
alter table dbo.part_packaging alter column serial_type varchar(25) collate database_default NULL
go
alter table dbo.PMPDMVIWC alter column CCMT varchar(254) collate database_default NULL
go
alter table dbo.PMPDMVIWC alter column CCOD varchar(254) collate database_default NULL
go
alter table dbo.PMPDMVIWC alter column CDTP varchar(254) collate database_default NULL
go
alter table dbo.PMPDMVIWC alter column CNAM varchar(254) collate database_default NULL
go
alter table dbo.PMPDMVIWC alter column DTTP varchar(254) collate database_default NULL
go
alter table dbo.PMPDMVIWC alter column DVAL varchar(254) collate database_default NULL
go
alter table dbo.PMPDMVIWC alter column FRMT varchar(254) collate database_default NULL
go
alter table dbo.PMPDMVIWC alter column HVAL varchar(254) collate database_default NULL
go
alter table dbo.PMPDMVIWC alter column LVAL varchar(254) collate database_default NULL
go
alter table dbo.PMPDMVIWC alter column UNIT varchar(254) collate database_default NULL
go
alter table dbo.edi_830_releases alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.edi_830_releases alter column supplier varchar(30) collate database_default NULL
go
alter table dbo.edi_830_releases alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.edi_830_releases alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.edi_830_releases alter column customer_po varchar(30) collate database_default NULL
go
alter table dbo.edi_830_releases alter column model_year varchar(30) collate database_default NULL
go
alter table dbo.edi_830_releases alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.edi_830_releases alter column SDP01 varchar(2) collate database_default NULL
go
alter table dbo.edi_830_releases alter column SDP02 varchar(1) collate database_default NULL
go
alter table dbo.edi_830_releases alter column FST01 varchar(30) collate database_default NULL
go
alter table dbo.edi_830_releases alter column FST02 varchar(1) collate database_default NULL
go
alter table dbo.edi_830_releases alter column FST03 varchar(1) collate database_default NULL
go
alter table dbo.edi_830_releases alter column FST04 varchar(10) collate database_default NULL
go
alter table dbo.delfor_oh alter column release_date varchar(12) collate database_default NULL
go
alter table dbo.delfor_oh alter column release_number varchar(35) collate database_default NULL
go
alter table dbo.delfor_oh alter column ship_to_id varchar(35) collate database_default NULL
go
alter table dbo.delfor_oh alter column buyer_part varchar(35) collate database_default NULL
go
alter table dbo.delfor_oh alter column model_year varchar(35) collate database_default NULL
go
alter table dbo.delfor_oh alter column dock_code varchar(35) collate database_default NULL
go
alter table dbo.delfor_oh alter column line_feed_code varchar(35) collate database_default NULL
go
alter table dbo.machine_data_1050 alter column machine varchar(10) collate database_default NOT NULL
go
alter table dbo.machine_data_1050 alter column status char(1) collate database_default NULL
go
alter table dbo.PMPSEL alter column LCLS char(40) collate database_default NULL
go
alter table dbo.edi_830_oh_data alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.edi_830_oh_data alter column supplier varchar(30) collate database_default NULL
go
alter table dbo.edi_830_oh_data alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.edi_830_oh_data alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.edi_830_oh_data alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.edi_830_oh_data alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.edi_830_oh_data alter column dock_REF_DK varchar(30) collate database_default NULL
go
alter table dbo.edi_830_oh_data alter column line_feed_REF_LF varchar(30) collate database_default NULL
go
alter table dbo.edi_830_oh_data alter column res_line_feed_REF_RL varchar(30) collate database_default NULL
go
alter table dbo.edi_830_oh_data alter column user_defined1 varchar(30) collate database_default NULL
go
alter table dbo.edi_830_oh_data alter column user_defined2 varchar(30) collate database_default NULL
go
alter table dbo.edi_830_oh_data alter column user_defined3 varchar(30) collate database_default NULL
go
alter table dbo.delfor_cytd alter column release_number varchar(35) collate database_default NULL
go
alter table dbo.delfor_cytd alter column ship_to_id varchar(35) collate database_default NULL
go
alter table dbo.delfor_cytd alter column buyer_part varchar(35) collate database_default NULL
go
alter table dbo.delfor_cytd alter column model_year varchar(35) collate database_default NULL
go
alter table dbo.delfor_cytd alter column cytd_start_date varchar(35) collate database_default NULL
go
alter table dbo.delfor_cytd alter column cytd_qty_shipped varchar(35) collate database_default NULL
go
alter table dbo.machine_policy alter column machine varchar(10) collate database_default NOT NULL
go
alter table dbo.machine_policy alter column job_change char(1) collate database_default NOT NULL
go
alter table dbo.machine_policy alter column schedule_queue char(1) collate database_default NOT NULL
go
alter table dbo.machine_policy alter column start_stop_login char(1) collate database_default NOT NULL
go
alter table dbo.machine_policy alter column process_control char(1) collate database_default NOT NULL
go
alter table dbo.machine_policy alter column access_inventory_control char(1) collate database_default NOT NULL
go
alter table dbo.machine_policy alter column material_substitution char(1) collate database_default NOT NULL
go
alter table dbo.machine_policy alter column change_std_pack char(1) collate database_default NOT NULL
go
alter table dbo.machine_policy alter column change_packaging char(1) collate database_default NOT NULL
go
alter table dbo.machine_policy alter column change_unit char(1) collate database_default NOT NULL
go
alter table dbo.machine_policy alter column job_completion_delete char(1) collate database_default NOT NULL
go
alter table dbo.machine_policy alter column material_issue_delete char(1) collate database_default NOT NULL
go
alter table dbo.machine_policy alter column defects_delete char(1) collate database_default NOT NULL
go
alter table dbo.machine_policy alter column downtime_delete char(1) collate database_default NOT NULL
go
alter table dbo.machine_policy alter column work_order_display_window varchar(60) collate database_default NULL
go
alter table dbo.machine_policy alter column packaging_line char(1) collate database_default NULL
go
alter table dbo.machine_policy alter column operator_required char(1) collate database_default NULL
go
alter table dbo.machine_policy alter column supervisorclose char(1) collate database_default NULL
go
alter table dbo.PMREPL alter column RCLS char(40) collate database_default NULL
go
alter table dbo.PMREPL alter column ROID char(40) collate database_default NULL
go
alter table dbo.edi_830_AuTH alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH alter column supplier varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.edi_830_AuTH alter column raw_auth varchar(20) collate database_default NULL
go
alter table dbo.edi_830_AuTH alter column raw_start_date varchar(12) collate database_default NULL
go
alter table dbo.edi_830_AuTH alter column raw_end_date varchar(12) collate database_default NULL
go
alter table dbo.edi_830_AuTH alter column fab_auth varchar(20) collate database_default NULL
go
alter table dbo.edi_830_AuTH alter column fab_start_date varchar(12) collate database_default NULL
go
alter table dbo.edi_830_AuTH alter column fab_end_date varchar(12) collate database_default NULL
go
alter table dbo.fd5_830_fab_raw alter column fab_date varchar(10) collate database_default NULL
go
alter table dbo.fd5_830_fab_raw alter column fab_cum varchar(15) collate database_default NULL
go
alter table dbo.fd5_830_fab_raw alter column fab_start_date varchar(10) collate database_default NULL
go
alter table dbo.fd5_830_fab_raw alter column raw_date varchar(10) collate database_default NULL
go
alter table dbo.fd5_830_fab_raw alter column raw_cum varchar(15) collate database_default NULL
go
alter table dbo.fd5_830_fab_raw alter column raw_start_date varchar(10) collate database_default NULL
go
alter table dbo.fd5_830_fab_raw alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.fd5_830_fab_raw alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.fd5_830_fab_raw alter column customer_po varchar(30) collate database_default NULL
go
alter table dbo.fd5_830_fab_raw alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.master_prod_sched alter column type char(1) collate database_default NULL
go
alter table dbo.master_prod_sched alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.master_prod_sched alter column source2 varchar(15) collate database_default NULL
go
alter table dbo.master_prod_sched alter column tool varchar(15) collate database_default NULL
go
alter table dbo.master_prod_sched alter column workcenter varchar(10) collate database_default NULL
go
alter table dbo.master_prod_sched alter column machine varchar(10) collate database_default NOT NULL
go
alter table dbo.master_prod_sched alter column material varchar(15) collate database_default NULL
go
alter table dbo.master_prod_sched alter column job varchar(15) collate database_default NOT NULL
go
alter table dbo.master_prod_sched alter column location varchar(10) collate database_default NULL
go
alter table dbo.master_prod_sched alter column field1 varchar(10) collate database_default NULL
go
alter table dbo.master_prod_sched alter column field2 varchar(10) collate database_default NULL
go
alter table dbo.master_prod_sched alter column field3 varchar(10) collate database_default NULL
go
alter table dbo.master_prod_sched alter column field4 varchar(10) collate database_default NULL
go
alter table dbo.master_prod_sched alter column field5 varchar(10) collate database_default NULL
go
alter table dbo.master_prod_sched alter column status char(1) collate database_default NOT NULL
go
alter table dbo.master_prod_sched alter column sched_method char(1) collate database_default NULL
go
alter table dbo.master_prod_sched alter column process varchar(25) collate database_default NULL
go
alter table dbo.master_prod_sched alter column tool_num varchar(15) collate database_default NULL
go
alter table dbo.master_prod_sched alter column workorder varchar(10) collate database_default NULL
go
alter table dbo.master_prod_sched alter column plant varchar(15) collate database_default NULL
go
alter table dbo.master_prod_sched alter column ship_type char(1) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column LastQtyReceived varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column LastQtyDT varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column LastShipper varchar(50) collate database_default NULL
go
alter table dbo.RawPlanningAccums alter column LastAccumQty varchar(50) collate database_default NULL
go
alter table dbo.T_EmpRep_Temp alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.T_EmpRep_Temp alter column remarks varchar(10) collate database_default NOT NULL
go
alter table dbo.T_EmpRep_Temp alter column operator varchar(5) collate database_default NOT NULL
go
alter table dbo.edi_830_AuTH_history alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history alter column supplier varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history alter column ship_to varchar(10) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history alter column raw_auth varchar(20) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history alter column raw_start_date varchar(12) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history alter column raw_end_date varchar(12) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history alter column fab_auth varchar(20) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history alter column fab_start_date varchar(12) collate database_default NULL
go
alter table dbo.edi_830_AuTH_history alter column fab_end_date varchar(12) collate database_default NULL
go
alter table dbo.fd5_830_oh_data alter column ship_to varchar(5) collate database_default NULL
go
alter table dbo.fd5_830_oh_data alter column buyer varchar(5) collate database_default NULL
go
alter table dbo.fd5_830_oh_data alter column bill_to varchar(5) collate database_default NULL
go
alter table dbo.fd5_830_oh_data alter column consignee varchar(5) collate database_default NULL
go
alter table dbo.fd5_830_oh_data alter column ford_part varchar(30) collate database_default NULL
go
alter table dbo.fd5_830_oh_data alter column ford_po varchar(30) collate database_default NULL
go
alter table dbo.fd5_830_oh_data alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.fd5_830_oh_data alter column euro_fin_code varchar(30) collate database_default NULL
go
alter table dbo.fd5_830_oh_data alter column customer_order_no varchar(16) collate database_default NULL
go
alter table dbo.fd5_830_oh_data alter column part_status varchar(2) collate database_default NULL
go
alter table dbo.fd5_830_oh_data alter column expeditor varchar(35) collate database_default NULL
go
alter table dbo.fd5_830_oh_data alter column exp_phone varchar(21) collate database_default NULL
go
alter table dbo.fd5_830_oh_data alter column plant_dock varchar(35) collate database_default NULL
go
alter table dbo.fd5_830_oh_data alter column plant_dock_phone varchar(21) collate database_default NULL
go
alter table dbo.fd5_830_oh_data alter column note varchar(60) collate database_default NULL
go
alter table dbo.asn_overlay_structure alter column overlay_group varchar(10) collate database_default NOT NULL
go
alter table dbo.asn_overlay_structure alter column column_name varchar(25) collate database_default NOT NULL
go
alter table dbo.asn_overlay_structure alter column section char(1) collate database_default NOT NULL
go
alter table dbo.asn_overlay_structure alter column hard_code_value varchar(25) collate database_default NULL
go
alter table dbo.asn_overlay_structure alter column error char(1) collate database_default NULL
go
alter table dbo.PMRPRT alter column AVSN varchar(254) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column RAWCUMStartDT varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column RAWCUMEndDT varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column RAWCUM varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column FABCUMStartDT varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column FABCUMEndDT varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column FABCUM varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column PriorCUMStartDT varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column PriorCUMEndDT varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningAuthAccums alter column PriorCUM varchar(50) collate database_default NULL
go
alter table dbo.ford862_container alter column ship_to varchar(50) collate database_default NULL
go
alter table dbo.ford862_container alter column ship_from varchar(50) collate database_default NULL
go
alter table dbo.ford862_container alter column consignee varchar(50) collate database_default NULL
go
alter table dbo.ford862_container alter column customer_part varchar(50) collate database_default NULL
go
alter table dbo.ford862_container alter column std_pack varchar(50) collate database_default NULL
go
alter table dbo.ford862_container alter column weight_per_thousand varchar(50) collate database_default NULL
go
alter table dbo.ford862_container alter column container varchar(50) collate database_default NULL
go
alter table dbo.ole_objects alter column id varchar(255) collate database_default NOT NULL
go
alter table dbo.ole_objects alter column parent_id varchar(100) collate database_default NOT NULL
go
alter table dbo.ole_objects alter column parent_type char(1) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column ScheduleType varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column SEQQualifier varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column QuantityQualifier varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column Quantity varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column QuantityType varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column DateType varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column DateDT varchar(50) collate database_default NULL
go
alter table dbo.RAWPlanningReleases alter column DateDTFormat varchar(50) collate database_default NULL
go
alter table dbo.m_ford830_consignee alter column ship_to varchar(50) collate database_default NULL
go
alter table dbo.m_ford830_consignee alter column consignee varchar(50) collate database_default NULL
go
alter table dbo.m_ford830_consignee alter column customer_part varchar(50) collate database_default NULL
go
alter table dbo.m_ford830_consignee alter column customer_po varchar(50) collate database_default NULL
go
alter table dbo.bill_of_lading alter column scac_transfer varchar(35) collate database_default NULL
go
alter table dbo.bill_of_lading alter column scac_pickup varchar(35) collate database_default NULL
go
alter table dbo.bill_of_lading alter column trans_mode varchar(10) collate database_default NULL
go
alter table dbo.bill_of_lading alter column equipment_initial varchar(10) collate database_default NULL
go
alter table dbo.bill_of_lading alter column equipment_description varchar(10) collate database_default NULL
go
alter table dbo.bill_of_lading alter column status char(1) collate database_default NULL
go
alter table dbo.bill_of_lading alter column printed char(1) collate database_default NULL
go
alter table dbo.bill_of_lading alter column destination varchar(20) collate database_default NULL
go
alter table dbo.PMSMAP alter column ALIA varchar(254) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column LastQtyReceived varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column LastQtyDT varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column LastShipper varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column LastAccumQty varchar(50) collate database_default NULL
go
alter table dbo.RawShipScheduleAccums alter column LastAccumDT varchar(50) collate database_default NULL
go
alter table dbo.ford862_descrepency alter column ship_to varchar(50) collate database_default NULL
go
alter table dbo.ford862_descrepency alter column ship_from varchar(50) collate database_default NULL
go
alter table dbo.ford862_descrepency alter column consignee varchar(50) collate database_default NULL
go
alter table dbo.ford862_descrepency alter column customer_part varchar(50) collate database_default NULL
go
alter table dbo.ford862_descrepency alter column quantity_qualifier varchar(50) collate database_default NULL
go
alter table dbo.ford862_descrepency alter column quantity varchar(50) collate database_default NULL
go
alter table dbo.ford862_descrepency alter column last_asn_date varchar(50) collate database_default NULL
go
alter table dbo.ford862_descrepency alter column last_shipper_id varchar(50) collate database_default NULL
go
alter table dbo.part_class_definition alter column class char(1) collate database_default NOT NULL
go
alter table dbo.part_class_definition alter column class_name varchar(25) collate database_default NOT NULL
go
alter table dbo.PMSRPL alter column RCLS char(40) collate database_default NULL
go
alter table dbo.PMSRPL alter column ROID char(40) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column ScheduleType varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column ReleaseQty varchar(50) collate database_default NULL
go
alter table dbo.RawShipSchedules alter column ReleaseDT varchar(50) collate database_default NULL
go
alter table dbo.T_EmpRep alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.T_EmpRep alter column operator varchar(5) collate database_default NOT NULL
go
alter table dbo.PlanningReleases alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.PlanningReleases alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.PlanningReleases alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.PlanningReleases alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.PlanningReleases alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.PlanningReleases alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.PlanningReleases alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.PlanningReleases alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.PlanningReleases alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.PlanningReleases alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.PlanningReleases alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.PlanningReleases alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.PlanningReleases alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.PlanningReleases alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.PlanningReleases alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.PlanningReleases alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.PlanningReleases alter column ScheduleType varchar(50) collate database_default NULL
go
alter table dbo.PlanningReleases alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.PlanningReleases alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.ford862_linefeed alter column ship_to varchar(50) collate database_default NULL
go
alter table dbo.ford862_linefeed alter column ship_from varchar(50) collate database_default NULL
go
alter table dbo.ford862_linefeed alter column consignee varchar(50) collate database_default NULL
go
alter table dbo.ford862_linefeed alter column customer_part varchar(50) collate database_default NULL
go
alter table dbo.ford862_linefeed alter column location_type varchar(50) collate database_default NULL
go
alter table dbo.ford862_linefeed alter column delivery_location varchar(50) collate database_default NULL
go
alter table dbo.ford862_ship_schedule alter column ship_to varchar(50) collate database_default NULL
go
alter table dbo.ford862_ship_schedule alter column ship_from varchar(50) collate database_default NULL
go
alter table dbo.ford862_ship_schedule alter column consignee varchar(50) collate database_default NULL
go
alter table dbo.ford862_ship_schedule alter column customer_part varchar(50) collate database_default NULL
go
alter table dbo.ford862_ship_schedule alter column quantity varchar(50) collate database_default NULL
go
alter table dbo.ford862_ship_schedule alter column ship_date varchar(50) collate database_default NULL
go
alter table dbo.ford862_ship_schedule alter column ship_time varchar(50) collate database_default NULL
go
alter table dbo.ford862_ship_schedule alter column release_number varchar(30) collate database_default NULL
go
alter table dbo.part_customer_price_matrix alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_customer_price_matrix alter column customer varchar(25) collate database_default NOT NULL
go
alter table dbo.part_customer_price_matrix alter column code varchar(10) collate database_default NULL
go
alter table dbo.part_customer_price_matrix alter column category varchar(25) collate database_default NULL
go
alter table dbo.PMTRFS alter column OBID char(40) collate database_default NULL
go
alter table dbo.PMTRFS alter column ORGI char(40) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column type varchar(1) collate database_default NOT NULL
go
alter table dbo.audit_trail_copy alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.audit_trail_copy alter column remarks varchar(10) collate database_default NOT NULL
go
alter table dbo.audit_trail_copy alter column salesman varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column customer varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column vendor varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column po_number varchar(30) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column operator varchar(5) collate database_default NOT NULL
go
alter table dbo.audit_trail_copy alter column from_loc varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column to_loc varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column lot varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column status varchar(1) collate database_default NOT NULL
go
alter table dbo.audit_trail_copy alter column shipper varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column flag varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column activity varchar(25) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column unit varchar(2) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column workorder varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column control_number varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column custom1 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column custom2 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column custom3 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column custom4 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column custom5 varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column plant varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column invoice_number varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column notes varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column gl_account varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column package_type varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column sales_order varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column release_no varchar(15) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column user_defined_status varchar(30) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column engineering_level varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column posted varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column origin varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column destination varchar(20) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column object_type varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column part_name varchar(254) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column field1 varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column field2 varchar(10) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column show_on_shipper varchar(1) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column kanban_number varchar(6) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.audit_trail_copy alter column dim_qty_string_other varchar(50) collate database_default NULL
go
alter table dbo.m_ford862_release_date alter column release_date varchar(30) collate database_default NULL
go
alter table dbo.m_ford862_release_date alter column release_number varchar(30) collate database_default NULL
go
alter table dbo.m_ford862_release_date alter column ship_to varchar(50) collate database_default NULL
go
alter table dbo.m_ford862_release_date alter column customer_part varchar(50) collate database_default NULL
go
alter table dbo.temp_pops alter column name varchar(45) collate database_default NOT NULL
go
alter table dbo.temp_pops alter column number varchar(20) collate database_default NOT NULL
go
alter table dbo.temp_pops alter column area varchar(5) collate database_default NULL
go
alter table dbo.edi_setups alter column destination varchar(20) collate database_default NOT NULL
go
alter table dbo.edi_setups alter column supplier_code varchar(20) collate database_default NOT NULL
go
alter table dbo.edi_setups alter column trading_partner_code varchar(20) collate database_default NOT NULL
go
alter table dbo.edi_setups alter column release_flag char(1) collate database_default NOT NULL
go
alter table dbo.edi_setups alter column auto_create_asn char(1) collate database_default NOT NULL
go
alter table dbo.edi_setups alter column asn_overlay_group varchar(3) collate database_default NULL
go
alter table dbo.edi_setups alter column equipment_description varchar(20) collate database_default NULL
go
alter table dbo.edi_setups alter column pool_flag char(1) collate database_default NOT NULL
go
alter table dbo.edi_setups alter column pool_code varchar(20) collate database_default NULL
go
alter table dbo.edi_setups alter column material_issuer varchar(25) collate database_default NULL
go
alter table dbo.edi_setups alter column id_code_type varchar(10) collate database_default NULL
go
alter table dbo.edi_setups alter column check_model_year char(1) collate database_default NULL
go
alter table dbo.edi_setups alter column check_po char(1) collate database_default NULL
go
alter table dbo.edi_setups alter column prev_cum_in_asn char(1) collate database_default NULL
go
alter table dbo.edi_setups alter column parent_destination varchar(20) collate database_default NULL
go
alter table dbo.edi_setups alter column EDIShipToID varchar(25) collate database_default NULL
go
alter table dbo.edi_setups alter column PlanningReleasesFlag char(1) collate database_default NULL
go
alter table dbo.edi_setups alter column ReferenceAccum varchar(10) collate database_default NULL
go
alter table dbo.edi_setups alter column AdjustmentAccum varchar(10) collate database_default NULL
go
alter table dbo.edi_setups alter column IConnectID varchar(50) collate database_default NULL
go
alter table dbo.m_ford830_release_date alter column release_date varchar(30) collate database_default NULL
go
alter table dbo.m_ford830_release_date alter column release_number varchar(30) collate database_default NULL
go
alter table dbo.m_ford830_release_date alter column ship_to varchar(50) collate database_default NULL
go
alter table dbo.m_ford830_release_date alter column customer_part varchar(50) collate database_default NULL
go
alter table dbo.part_location alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_location alter column location varchar(10) collate database_default NOT NULL
go
alter table dbo.part_location alter column destination varchar(10) collate database_default NULL
go
alter table dbo.PMXSMAITM alter column LANG varchar(254) collate database_default NULL
go
alter table dbo.PMXSMAITM alter column SRCE varchar(254) collate database_default NULL
go
alter table dbo.PMXSMAITM alter column XSID varchar(254) collate database_default NULL
go
alter table dbo.PMCMRID alter column UUID varchar(254) collate database_default NOT NULL
go
alter table dbo.PMCMRID alter column NAME varchar(254) collate database_default NULL
go
alter table dbo.PMCMRID alter column VRSN varchar(254) collate database_default NULL
go
alter table dbo.PMXSMANNT alter column XSID varchar(254) collate database_default NULL
go
alter table dbo.PMENUM alter column VALU varchar(254) collate database_default NULL
go
alter table dbo.PMENUM alter column RVAL varchar(254) collate database_default NULL
go
alter table dbo.MonitorDeadlockNew alter column TextData ntext collate database_default NULL
go
alter table dbo.MonitorDeadlockNew alter column NTUserName nvarchar(128) collate database_default NULL
go
alter table dbo.MonitorDeadlockNew alter column ApplicationName nvarchar(128) collate database_default NULL
go
alter table dbo.MonitorDeadlockNew alter column LoginName nvarchar(128) collate database_default NULL
go
alter table dbo.part_machine_tool alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_machine_tool alter column machine varchar(10) collate database_default NOT NULL
go
alter table dbo.part_machine_tool alter column tool varchar(25) collate database_default NOT NULL
go
alter table dbo.freight_type_definition alter column type_name varchar(20) collate database_default NOT NULL
go
alter table dbo.PMXSMCMPT alter column ATFM varchar(40) collate database_default NULL
go
alter table dbo.PMXSMCMPT alter column AUSE varchar(40) collate database_default NULL
go
alter table dbo.PMXSMCMPT alter column BLCK varchar(40) collate database_default NULL
go
alter table dbo.PMXSMCMPT alter column BTPN varchar(254) collate database_default NULL
go
alter table dbo.PMXSMCMPT alter column ELFM varchar(40) collate database_default NULL
go
alter table dbo.PMXSMCMPT alter column FINL varchar(40) collate database_default NULL
go
alter table dbo.PMXSMCMPT alter column GTYP varchar(254) collate database_default NULL
go
alter table dbo.PMXSMCMPT alter column ITPN varchar(254) collate database_default NULL
go
alter table dbo.PMXSMCMPT alter column MNOC varchar(254) collate database_default NULL
go
alter table dbo.PMXSMCMPT alter column MXOC varchar(254) collate database_default NULL
go
alter table dbo.PMXSMCMPT alter column PCNT varchar(40) collate database_default NULL
go
alter table dbo.PMXSMCMPT alter column PUBL varchar(254) collate database_default NULL
go
alter table dbo.PMXSMCMPT alter column RFNM varchar(254) collate database_default NULL
go
alter table dbo.PMXSMCMPT alter column SUBN varchar(254) collate database_default NULL
go
alter table dbo.PMXSMCMPT alter column SYST varchar(254) collate database_default NULL
go
alter table dbo.PMXSMCMPT alter column TPNM varchar(254) collate database_default NULL
go
alter table dbo.PMXSMCMPT alter column XSID varchar(254) collate database_default NULL
go
alter table dbo.PMMTMD alter column NAME varchar(254) collate database_default NOT NULL
go
alter table dbo.PMMTMD alter column CODE varchar(254) collate database_default NOT NULL
go
alter table dbo.PMMTMD alter column MAID varchar(254) collate database_default NOT NULL
go
alter table dbo.PMMTMD alter column MAVN varchar(254) collate database_default NULL
go
alter table dbo.PMMTMD alter column EXTN varchar(254) collate database_default NULL
go
alter table dbo.DiscretePONumbersShipped alter column DiscretePONumber varchar(50) collate database_default NULL
go
alter table dbo.part_tooling alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_tooling alter column tool_number varchar(25) collate database_default NOT NULL
go
alter table dbo.link alter column type char(1) collate database_default NOT NULL
go
alter table dbo.PMXSMDTSC alter column DTSR varchar(254) collate database_default NULL
go
alter table dbo.PMXSMDTSC alter column LGIN varchar(254) collate database_default NULL
go
alter table dbo.PMXSMDTSC alter column MTYP char(40) collate database_default NULL
go
alter table dbo.PMXSMDTSC alter column PSWD varchar(254) collate database_default NULL
go
alter table dbo.PMXSMDTSC alter column ACTP varchar(2) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined6 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined7 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined8 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined9 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined10 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined11 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined12 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined13 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined14 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined15 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined16 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined17 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined18 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined19 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column UserDefined20 varchar(50) collate database_default NULL
go
alter table dbo.PlanningSupplemental alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.PlanningSupplemental alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.order_detail_inserted alter column part_number varchar(25) collate database_default NOT NULL
go
alter table dbo.order_detail_inserted alter column type char(1) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column product_name varchar(50) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column notes varchar(255) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column assigned varchar(35) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column status char(1) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column destination varchar(25) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column unit varchar(2) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column plant varchar(10) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column ship_type char(1) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column packaging_type varchar(20) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column custom01 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column custom02 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column custom03 varchar(30) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column engineering_level varchar(25) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column box_label varchar(25) collate database_default NULL
go
alter table dbo.order_detail_inserted alter column pallet_label varchar(25) collate database_default NULL
go
alter table dbo.PMXSMENTT alter column NOTN varchar(254) collate database_default NULL
go
alter table dbo.PMXSMENTT alter column PUBL varchar(254) collate database_default NULL
go
alter table dbo.PMXSMENTT alter column SYST varchar(254) collate database_default NULL
go
alter table dbo.order_header_inserted alter column blanket_part varchar(25) collate database_default NULL
go
alter table dbo.order_header_inserted alter column model_year varchar(4) collate database_default NULL
go
alter table dbo.order_header_inserted alter column customer_part varchar(35) collate database_default NULL
go
alter table dbo.order_header_inserted alter column order_type char(1) collate database_default NULL
go
alter table dbo.order_header_inserted alter column status char(1) collate database_default NULL
go
alter table dbo.order_header_inserted alter column unit varchar(2) collate database_default NULL
go
alter table dbo.order_header_inserted alter column revision varchar(10) collate database_default NULL
go
alter table dbo.order_header_inserted alter column customer_po varchar(20) collate database_default NULL
go
alter table dbo.order_header_inserted alter column salesman varchar(25) collate database_default NULL
go
alter table dbo.order_header_inserted alter column zone_code varchar(30) collate database_default NULL
go
alter table dbo.order_header_inserted alter column dock_code varchar(10) collate database_default NULL
go
alter table dbo.order_header_inserted alter column package_type varchar(20) collate database_default NULL
go
alter table dbo.order_header_inserted alter column notes varchar(255) collate database_default NULL
go
alter table dbo.order_header_inserted alter column shipping_unit varchar(15) collate database_default NULL
go
alter table dbo.order_header_inserted alter column line_feed_code varchar(30) collate database_default NULL
go
alter table dbo.order_header_inserted alter column begin_kanban_number varchar(6) collate database_default NULL
go
alter table dbo.order_header_inserted alter column end_kanban_number varchar(6) collate database_default NULL
go
alter table dbo.order_header_inserted alter column line11 varchar(21) collate database_default NULL
go
alter table dbo.order_header_inserted alter column line12 varchar(21) collate database_default NULL
go
alter table dbo.order_header_inserted alter column line13 varchar(21) collate database_default NULL
go
alter table dbo.order_header_inserted alter column line14 varchar(21) collate database_default NULL
go
alter table dbo.order_header_inserted alter column line15 varchar(21) collate database_default NULL
go
alter table dbo.order_header_inserted alter column line16 varchar(21) collate database_default NULL
go
alter table dbo.order_header_inserted alter column line17 varchar(21) collate database_default NULL
go
alter table dbo.order_header_inserted alter column custom01 varchar(30) collate database_default NULL
go
alter table dbo.order_header_inserted alter column custom02 varchar(30) collate database_default NULL
go
alter table dbo.order_header_inserted alter column custom03 varchar(30) collate database_default NULL
go
alter table dbo.order_header_inserted alter column cs_status varchar(20) collate database_default NULL
go
alter table dbo.order_header_inserted alter column engineering_level varchar(25) collate database_default NULL
go
alter table dbo.order_header_inserted alter column reviewed_by varchar(25) collate database_default NULL
go
alter table dbo.part_machine_tool_list alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_machine_tool_list alter column machine varchar(10) collate database_default NOT NULL
go
alter table dbo.part_machine_tool_list alter column station_id varchar(25) collate database_default NOT NULL
go
alter table dbo.part_machine_tool_list alter column station_type char(1) collate database_default NOT NULL
go
alter table dbo.part_machine_tool_list alter column tool varchar(25) collate database_default NOT NULL
go
alter table dbo.part_machine_tool_list alter column tool_list_no varchar(50) collate database_default NULL
go
alter table dbo.shipper_container alter column container_type varchar(15) collate database_default NOT NULL
go
alter table dbo.shipper_container alter column group_flag char(1) collate database_default NULL
go
alter table dbo.part_customer alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_customer alter column customer varchar(10) collate database_default NOT NULL
go
alter table dbo.part_customer alter column customer_part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_customer alter column taxable char(1) collate database_default NULL
go
alter table dbo.part_customer alter column customer_unit varchar(3) collate database_default NULL
go
alter table dbo.part_customer alter column type char(1) collate database_default NULL
go
alter table dbo.part_customer alter column upc_code varchar(11) collate database_default NULL
go
alter table dbo.PMXSMXTRN alter column NMSP varchar(254) collate database_default NULL
go
alter table dbo.PMXSMXTRN alter column SCHE varchar(254) collate database_default NULL
go
alter table dbo.PMXSMXTRN alter column XSID varchar(254) collate database_default NULL
go
alter table dbo.PMPROR alter column TRET varchar(254) collate database_default NOT NULL
go
alter table dbo.PMPROR alter column TDET varchar(254) collate database_default NOT NULL
go
alter table dbo.textron_830_AuTH alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.textron_830_AuTH alter column ship_to varchar(30) collate database_default NULL
go
alter table dbo.textron_830_AuTH alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.textron_830_AuTH alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.textron_830_AuTH alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.textron_830_AuTH alter column authorized_thru_date varchar(35) collate database_default NULL
go
alter table dbo.textron_830_AuTH alter column authorized_qty varchar(35) collate database_default NULL
go
alter table dbo.textron_830_AuTH alter column raw_auth varchar(20) collate database_default NULL
go
alter table dbo.textron_830_AuTH alter column raw_start_date varchar(12) collate database_default NULL
go
alter table dbo.textron_830_AuTH alter column raw_end_date varchar(12) collate database_default NULL
go
alter table dbo.textron_830_AuTH alter column fab_auth varchar(20) collate database_default NULL
go
alter table dbo.textron_830_AuTH alter column fab_start_date varchar(12) collate database_default NULL
go
alter table dbo.textron_830_AuTH alter column fab_end_date varchar(12) collate database_default NULL
go
alter table dbo.textron_830_AuTH alter column supplier varchar(30) collate database_default NULL
go
alter table dbo.part_type_definition alter column type char(1) collate database_default NOT NULL
go
alter table dbo.part_type_definition alter column type_name varchar(25) collate database_default NOT NULL
go
alter table dbo.part_standard alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_standard alter column account_number varchar(50) collate database_default NULL
go
alter table dbo.part_standard alter column premium char(1) collate database_default NULL
go
alter table dbo.PMRRLM alter column NAME varchar(254) collate database_default NOT NULL
go
alter table dbo.PMRRLM alter column RTYP varchar(254) collate database_default NOT NULL
go
alter table dbo.textron_830_AuTH_history alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.textron_830_AuTH_history alter column ship_to varchar(10) collate database_default NULL
go
alter table dbo.textron_830_AuTH_history alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.textron_830_AuTH_history alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.textron_830_AuTH_history alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.textron_830_AuTH_history alter column authorized_thru_date varchar(35) collate database_default NULL
go
alter table dbo.textron_830_AuTH_history alter column authorized_qty varchar(35) collate database_default NULL
go
alter table dbo.textron_830_AuTH_history alter column raw_auth varchar(20) collate database_default NULL
go
alter table dbo.textron_830_AuTH_history alter column raw_start_date varchar(12) collate database_default NULL
go
alter table dbo.textron_830_AuTH_history alter column raw_end_date varchar(12) collate database_default NULL
go
alter table dbo.textron_830_AuTH_history alter column fab_auth varchar(20) collate database_default NULL
go
alter table dbo.textron_830_AuTH_history alter column fab_start_date varchar(12) collate database_default NULL
go
alter table dbo.textron_830_AuTH_history alter column fab_end_date varchar(12) collate database_default NULL
go
alter table dbo.textron_830_AuTH_history alter column supplier varchar(30) collate database_default NULL
go
alter table dbo.textron_830_SHP_data alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.textron_830_SHP_data alter column ship_to varchar(10) collate database_default NULL
go
alter table dbo.textron_830_SHP_data alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.textron_830_SHP_data alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.textron_830_SHP_data alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.textron_830_SHP_data alter column qty_type varchar(35) collate database_default NULL
go
alter table dbo.textron_830_SHP_data alter column qty varchar(35) collate database_default NULL
go
alter table dbo.textron_830_SHP_data alter column date_type varchar(20) collate database_default NULL
go
alter table dbo.textron_830_SHP_data alter column date1 varchar(12) collate database_default NULL
go
alter table dbo.textron_830_SHP_data alter column supplier varchar(30) collate database_default NULL
go
alter table dbo.partlist alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.plant_part alter column plant varchar(10) collate database_default NOT NULL
go
alter table dbo.plant_part alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.pbcatcol alter column pbc_tnam char(129) collate database_default NOT NULL
go
alter table dbo.pbcatcol alter column pbc_ownr char(129) collate database_default NOT NULL
go
alter table dbo.pbcatcol alter column pbc_cnam char(129) collate database_default NOT NULL
go
alter table dbo.pbcatcol alter column pbc_labl varchar(254) collate database_default NULL
go
alter table dbo.pbcatcol alter column pbc_hdr varchar(254) collate database_default NULL
go
alter table dbo.pbcatcol alter column pbc_mask varchar(31) collate database_default NULL
go
alter table dbo.pbcatcol alter column pbc_ptrn varchar(31) collate database_default NULL
go
alter table dbo.pbcatcol alter column pbc_bmap char(1) collate database_default NULL
go
alter table dbo.pbcatcol alter column pbc_init varchar(254) collate database_default NULL
go
alter table dbo.pbcatcol alter column pbc_cmnt varchar(254) collate database_default NULL
go
alter table dbo.pbcatcol alter column pbc_edit varchar(31) collate database_default NULL
go
alter table dbo.pbcatcol alter column pbc_tag varchar(254) collate database_default NULL
go
alter table dbo.textron_830_SHP_data_history alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.textron_830_SHP_data_history alter column ship_to varchar(10) collate database_default NULL
go
alter table dbo.textron_830_SHP_data_history alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.textron_830_SHP_data_history alter column ecl varchar(30) collate database_default NULL
go
alter table dbo.textron_830_SHP_data_history alter column customer_po varchar(35) collate database_default NULL
go
alter table dbo.textron_830_SHP_data_history alter column qty_type varchar(35) collate database_default NULL
go
alter table dbo.textron_830_SHP_data_history alter column qty varchar(35) collate database_default NULL
go
alter table dbo.textron_830_SHP_data_history alter column date_type varchar(20) collate database_default NULL
go
alter table dbo.textron_830_SHP_data_history alter column date1 varchar(12) collate database_default NULL
go
alter table dbo.textron_830_SHP_data_history alter column supplier varchar(30) collate database_default NULL
go
alter table dbo.production_shift alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.production_shift alter column location varchar(10) collate database_default NOT NULL
go
alter table dbo.production_shift alter column machine varchar(10) collate database_default NULL
go
alter table dbo.production_shift alter column tool varchar(15) collate database_default NULL
go
alter table dbo.production_shift alter column activity varchar(10) collate database_default NULL
go
alter table dbo.production_shift alter column type varchar(1) collate database_default NULL
go
alter table dbo.production_shift alter column transaction_number varchar(10) collate database_default NULL
go
alter table dbo.production_shift alter column data_source varchar(10) collate database_default NULL
go
alter table dbo.production_shift alter column work_order_number varchar(10) collate database_default NULL
go
alter table dbo.part_inventory alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.part_inventory alter column standard_unit varchar(2) collate database_default NULL
go
alter table dbo.part_inventory alter column cycle varchar(10) collate database_default NULL
go
alter table dbo.part_inventory alter column abc varchar(1) collate database_default NULL
go
alter table dbo.part_inventory alter column primary_location varchar(10) collate database_default NULL
go
alter table dbo.part_inventory alter column location_group varchar(10) collate database_default NULL
go
alter table dbo.part_inventory alter column ipa varchar(1) collate database_default NULL
go
alter table dbo.part_inventory alter column label_format varchar(30) collate database_default NULL
go
alter table dbo.part_inventory alter column material_issue_type varchar(1) collate database_default NULL
go
alter table dbo.part_inventory alter column safety_part varchar(1) collate database_default NULL
go
alter table dbo.part_inventory alter column upc_code varchar(15) collate database_default NULL
go
alter table dbo.part_inventory alter column dim_code varchar(2) collate database_default NULL
go
alter table dbo.part_inventory alter column configurable varchar(1) collate database_default NULL
go
alter table dbo.part_inventory alter column drop_ship_part varchar(1) collate database_default NULL
go
alter table dbo.PMCDMDTSC alter column ACTP varchar(2) collate database_default NULL
go
alter table dbo.PMCDMDTSC alter column DTSR varchar(254) collate database_default NULL
go
alter table dbo.PMCDMDTSC alter column LGIN varchar(254) collate database_default NULL
go
alter table dbo.PMCDMDTSC alter column MTYP char(40) collate database_default NULL
go
alter table dbo.PMCDMDTSC alter column PSWD varchar(254) collate database_default NULL
go
alter table dbo.pbcatfmt alter column pbf_name varchar(30) collate database_default NOT NULL
go
alter table dbo.pbcatfmt alter column pbf_frmt varchar(254) collate database_default NULL
go
alter table dbo.textron_order_auth alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.textron_order_auth alter column ship_to varchar(10) collate database_default NULL
go
alter table dbo.textron_order_auth alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.textron_order_auth alter column supplier varchar(30) collate database_default NULL
go
alter table dbo.user_definable_data alter column module varchar(10) collate database_default NOT NULL
go
alter table dbo.user_definable_data alter column code varchar(50) collate database_default NOT NULL
go
alter table dbo.user_definable_data alter column description varchar(255) collate database_default NULL
go
alter table dbo.PMDFDT alter column ACTP varchar(2) collate database_default NULL
go
alter table dbo.PMDFDT alter column DTSR varchar(254) collate database_default NULL
go
alter table dbo.PMDFDT alter column LGIN varchar(254) collate database_default NULL
go
alter table dbo.PMDFDT alter column MTYP char(40) collate database_default NULL
go
alter table dbo.PMDFDT alter column PSWD varchar(254) collate database_default NULL
go
alter table dbo.trans_mode alter column code varchar(2) collate database_default NOT NULL
go
alter table dbo.trans_mode alter column description varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column LastShipper varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAccums alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.ShipScheduleAccums alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.report_list alter column report varchar(25) collate database_default NOT NULL
go
alter table dbo.report_list alter column description varchar(255) collate database_default NULL
go
alter table dbo.PMIACT alter column PEVT varchar(64) collate database_default NULL
go
alter table dbo.PMIACT alter column PNAM varchar(64) collate database_default NULL
go
alter table dbo.edi_overlay_structure alter column overlay_group varchar(10) collate database_default NOT NULL
go
alter table dbo.edi_overlay_structure alter column data_set varchar(3) collate database_default NOT NULL
go
alter table dbo.edi_overlay_structure alter column column_name varchar(25) collate database_default NOT NULL
go
alter table dbo.edi_overlay_structure alter column last_line_in_detail_section char(1) collate database_default NULL
go
alter table dbo.edi_overlay_structure alter column filter_value varchar(15) collate database_default NULL
go
alter table dbo.edi_overlay_structure alter column kanban char(1) collate database_default NULL
go
alter table dbo.PMIAOB alter column SOID char(40) collate database_default NULL
go
alter table dbo.PMIAOB alter column STYP char(40) collate database_default NULL
go
alter table dbo.pbcattbl alter column pbt_tnam char(129) collate database_default NOT NULL
go
alter table dbo.pbcattbl alter column pbt_ownr char(129) collate database_default NOT NULL
go
alter table dbo.pbcattbl alter column pbd_fitl char(1) collate database_default NULL
go
alter table dbo.pbcattbl alter column pbd_funl char(1) collate database_default NULL
go
alter table dbo.pbcattbl alter column pbd_ffce char(18) collate database_default NULL
go
alter table dbo.pbcattbl alter column pbh_fitl char(1) collate database_default NULL
go
alter table dbo.pbcattbl alter column pbh_funl char(1) collate database_default NULL
go
alter table dbo.pbcattbl alter column pbh_ffce char(18) collate database_default NULL
go
alter table dbo.pbcattbl alter column pbl_fitl char(1) collate database_default NULL
go
alter table dbo.pbcattbl alter column pbl_funl char(1) collate database_default NULL
go
alter table dbo.pbcattbl alter column pbl_ffce char(18) collate database_default NULL
go
alter table dbo.pbcattbl alter column pbt_cmnt varchar(254) collate database_default NULL
go
alter table dbo.shop_floor_calendar alter column machine varchar(10) collate database_default NOT NULL
go
alter table dbo.shop_floor_calendar alter column labor_code varchar(25) collate database_default NULL
go
alter table dbo.PMILMACOL alter column DTTP varchar(254) collate database_default NULL
go
alter table dbo.PMILMACOL alter column RCOL varchar(254) collate database_default NULL
go
alter table dbo.PMILMACOL alter column SCCE varchar(254) collate database_default NULL
go
alter table dbo.customer_additional alter column customer varchar(10) collate database_default NOT NULL
go
alter table dbo.customer_additional alter column type varchar(10) collate database_default NOT NULL
go
alter table dbo.customer_additional alter column platinum_id varchar(5) collate database_default NULL
go
alter table dbo.PMATTR alter column NAME varchar(254) collate database_default NOT NULL
go
alter table dbo.PMATTR alter column CODE varchar(254) collate database_default NOT NULL
go
alter table dbo.PMATTR alter column TNAM varchar(254) collate database_default NULL
go
alter table dbo.PMATTR alter column CNAM varchar(254) collate database_default NULL
go
alter table dbo.order_detail alter column part_number varchar(25) collate database_default NOT NULL
go
alter table dbo.order_detail alter column type varchar(1) collate database_default NULL
go
alter table dbo.order_detail alter column product_name varchar(100) collate database_default NULL
go
alter table dbo.order_detail alter column notes varchar(255) collate database_default NULL
go
alter table dbo.order_detail alter column assigned varchar(35) collate database_default NULL
go
alter table dbo.order_detail alter column status varchar(1) collate database_default NULL
go
alter table dbo.order_detail alter column destination varchar(25) collate database_default NULL
go
alter table dbo.order_detail alter column unit varchar(2) collate database_default NULL
go
alter table dbo.order_detail alter column group_no varchar(10) collate database_default NULL
go
alter table dbo.order_detail alter column plant varchar(10) collate database_default NULL
go
alter table dbo.order_detail alter column release_no varchar(30) collate database_default NULL
go
alter table dbo.order_detail alter column customer_part varchar(30) collate database_default NULL
go
alter table dbo.order_detail alter column ship_type varchar(1) collate database_default NULL
go
alter table dbo.order_detail alter column packaging_type varchar(20) collate database_default NULL
go
alter table dbo.order_detail alter column custom01 varchar(30) collate database_default NULL
go
alter table dbo.order_detail alter column custom02 varchar(30) collate database_default NULL
go
alter table dbo.order_detail alter column custom03 varchar(30) collate database_default NULL
go
alter table dbo.order_detail alter column dimension_qty_string varchar(50) collate database_default NULL
go
alter table dbo.order_detail alter column engineering_level varchar(25) collate database_default NULL
go
alter table dbo.order_detail alter column box_label varchar(25) collate database_default NULL
go
alter table dbo.order_detail alter column pallet_label varchar(25) collate database_default NULL
go
alter table dbo.workorder_detail_history alter column workorder varchar(10) collate database_default NOT NULL
go
alter table dbo.workorder_detail_history alter column part varchar(25) collate database_default NOT NULL
go
alter table dbo.workorder_detail_history alter column plant varchar(20) collate database_default NULL
go
alter table dbo.PMILMARTC alter column RTBL varchar(254) collate database_default NULL
go
alter table dbo.PMBRNC alter column NAME varchar(254) collate database_default NOT NULL
go
alter table dbo.PMBRNC alter column CODE varchar(254) collate database_default NOT NULL
go
alter table dbo.PMILMBPRC alter column PTYP varchar(254) collate database_default NULL
go
alter table dbo.edi_setups_backup alter column destination varchar(20) collate database_default NOT NULL
go
alter table dbo.edi_setups_backup alter column supplier_code varchar(20) collate database_default NOT NULL
go
alter table dbo.edi_setups_backup alter column trading_partner_code varchar(20) collate database_default NOT NULL
go
alter table dbo.edi_setups_backup alter column release_flag char(1) collate database_default NOT NULL
go
alter table dbo.edi_setups_backup alter column auto_create_asn char(1) collate database_default NOT NULL
go
alter table dbo.edi_setups_backup alter column asn_overlay_group varchar(3) collate database_default NULL
go
alter table dbo.edi_setups_backup alter column equipment_description varchar(20) collate database_default NULL
go
alter table dbo.edi_setups_backup alter column pool_flag char(1) collate database_default NOT NULL
go
alter table dbo.edi_setups_backup alter column pool_code varchar(20) collate database_default NULL
go
alter table dbo.edi_setups_backup alter column material_issuer varchar(25) collate database_default NULL
go
alter table dbo.edi_setups_backup alter column id_code_type varchar(10) collate database_default NULL
go
alter table dbo.edi_setups_backup alter column check_model_year char(1) collate database_default NULL
go
alter table dbo.edi_setups_backup alter column check_po char(1) collate database_default NULL
go
alter table dbo.edi_setups_backup alter column prev_cum_in_asn char(1) collate database_default NULL
go
alter table dbo.edi_setups_backup alter column parent_destination varchar(20) collate database_default NULL
go
alter table dbo.PMCLSS alter column CLID char(40) collate database_default NOT NULL
go
alter table dbo.PMCLSS alter column NAME varchar(254) collate database_default NOT NULL
go
alter table dbo.PMCLSS alter column CODE varchar(254) collate database_default NOT NULL
go
alter table dbo.PMCLSS alter column TNAM varchar(254) collate database_default NULL
go
alter table dbo.shop_floor_time_log alter column operator varchar(10) collate database_default NOT NULL
go
alter table dbo.shop_floor_time_log alter column activity varchar(25) collate database_default NULL
go
alter table dbo.shop_floor_time_log alter column location varchar(10) collate database_default NULL
go
alter table dbo.shop_floor_time_log alter column part varchar(25) collate database_default NULL
go
alter table dbo.shop_floor_time_log alter column work_order varchar(10) collate database_default NULL
go
alter table dbo.shop_floor_time_log alter column status varchar(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column machine_number varchar(20) collate database_default NULL
go
alter table dbo.inventory_parameters alter column jc_machine char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column jc_part char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column jc_packaging char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column jc_location_to char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column jc_operator char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column jc_number_of char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column jc_qty char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column jc_unit char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column mi_machine char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column mi_operator char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column mi_serial char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column mi_qty char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column mi_unit char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column bo_operator char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column bo_serial char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column bo_number_of char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column bo_qty char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column bo_unit char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column jc_allow_zero_qty char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column jc_parts_mode char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column limit_locations char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column jc_material_lot char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column limit_locations_jc char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column limit_locations_mi char(1) collate database_default NULL
go
alter table dbo.inventory_parameters alter column limit_locations_tr char(1) collate database_default NULL
go
alter table dbo.PMCNFG alter column NAME varchar(254) collate database_default NOT NULL
go
alter table dbo.PMCNFG alter column CODE varchar(254) collate database_default NOT NULL
go
alter table dbo.PMILMDBOU alter column PTYP varchar(254) collate database_default NULL
go
alter table dbo.destination_shipping alter column destination varchar(20) collate database_default NOT NULL
go
alter table dbo.destination_shipping alter column scac_code varchar(4) collate database_default NOT NULL
go
alter table dbo.destination_shipping alter column trans_mode varchar(2) collate database_default NOT NULL
go
alter table dbo.destination_shipping alter column dock_code_flag char(1) collate database_default NOT NULL
go
alter table dbo.destination_shipping alter column model_year_flag char(1) collate database_default NULL
go
alter table dbo.destination_shipping alter column fob varchar(20) collate database_default NULL
go
alter table dbo.destination_shipping alter column freigt_type varchar(20) collate database_default NULL
go
alter table dbo.destination_shipping alter column note_for_shipper varchar(200) collate database_default NULL
go
alter table dbo.destination_shipping alter column note_for_bol varchar(200) collate database_default NULL
go
alter table dbo.destination_shipping alter column print_shipper_note char(1) collate database_default NULL
go
alter table dbo.destination_shipping alter column print_bol_note char(1) collate database_default NULL
go
alter table dbo.destination_shipping alter column allow_mult_po char(1) collate database_default NULL
go
alter table dbo.destination_shipping alter column ship_day varchar(10) collate database_default NULL
go
alter table dbo.destination_shipping alter column will_call_customer char(1) collate database_default NULL
go
alter table dbo.destination_shipping alter column allow_overstage char(1) collate database_default NULL
go
alter table dbo.temp_bom_stack alter column part varchar(25) collate database_default NULL
go
alter table dbo.location_limits alter column trans_code char(1) collate database_default NOT NULL
go
alter table dbo.location_limits alter column location_code varchar(10) collate database_default NOT NULL
go
alter table dbo.salesrep alter column salesrep varchar(10) collate database_default NOT NULL
go
alter table dbo.salesrep alter column name varchar(40) collate database_default NOT NULL
go
alter table dbo.salesrep alter column commission_type char(1) collate database_default NOT NULL
go
alter table dbo.PMILMDCNT alter column ACTP varchar(2) collate database_default NULL
go
alter table dbo.ShipScheduleAuthAccums alter column ReleaseNo varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAuthAccums alter column ShipToCode varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAuthAccums alter column ConsigneeCode varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAuthAccums alter column ShipFromCode varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAuthAccums alter column SupplierCode varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAuthAccums alter column CustomerPart varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAuthAccums alter column CustomerPO varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAuthAccums alter column CustomerPOLine varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAuthAccums alter column CustomerModelYear varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAuthAccums alter column CustomerECL varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAuthAccums alter column ReferenceNo varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAuthAccums alter column UserDefined1 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAuthAccums alter column UserDefined2 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAuthAccums alter column UserDefined3 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAuthAccums alter column UserDefined4 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAuthAccums alter column UserDefined5 varchar(50) collate database_default NULL
go
alter table dbo.ShipScheduleAuthAccums alter column RowCreateUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.ShipScheduleAuthAccums alter column RowModifiedUser nvarchar(128) collate database_default NOT NULL
go
alter table dbo.temp_bomec_stack alter column parent_part varchar(25) collate database_default NULL
go
alter table dbo.temp_bomec_stack alter column part varchar(25) collate database_default NULL
go
alter table dbo.temp_bomec_stack alter column substitute_part varchar(1) collate database_default NULL
go
alter table dbo.temp_bomec_stack alter column type varchar(1) collate database_default NULL
go
alter table FT.XRt alter column TopPart varchar(25) collate database_default not null
go
alter table FT.XRt alter column ChildPart varchar(25) collate database_default not null
go
alter table FT.XRt alter column Hierarchy varchar(500) collate database_default not null
go
alter table dbo.StampingSetup_PO_Import alter column RawPart varchar(25) collate database_default null
go
alter table FT.BOM alter column ParentPart varchar(25) collate database_default not null
go
alter table FT.BOM alter column ChildPart varchar(25) collate database_default not null
go
alter table FT.PartRouter alter column Part varchar(25) collate database_default not null
go
alter table dbo.StampingSetup alter column FinishedGood varchar(25) collate database_default null
go
alter table dbo.StampingSetup alter column RawPart varchar(25) collate database_default null
go
alter table dbo.StampingSetup alter column Supplier varchar(30) collate database_default null
go
