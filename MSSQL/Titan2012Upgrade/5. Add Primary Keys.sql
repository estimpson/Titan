alter table dbo.account_code add constraint PK__account_code__308E3499 PRIMARY KEY (
	account_no
	)
go
alter table dbo.activity_codes add constraint PK__activity_codes__1FCDBCEB PRIMARY KEY (
	code
	)
go
alter table dbo.activity_costs add constraint PK__activity_costs__21B6055D PRIMARY KEY (
	parent_part,activity,location
	)
go
alter table dbo.activity_router add constraint PK__activity_router__42ECDBF6 PRIMARY KEY (
	parent_part,sequence
	)
go
alter table dbo.alternative_parts add constraint PK__alternative_part__0F624AF8 PRIMARY KEY (
	main_part,alt_part
	)
go
alter table dbo.asn_overlay_structure add constraint PK__asn_overlay_stru__66603565 PRIMARY KEY (
	overlay_group,column_name,line,position,section
	)
go
alter table dbo.BartenderLabels add constraint PK_BartenderLabels PRIMARY KEY (
	LabelFormat
	)
go
alter table dbo.bill_of_material_ec add constraint bill_of_material_ec_x PRIMARY KEY (
	parent_part,part,start_datetime
	)
go
alter table dbo.carrier add constraint PK__carrier__5EBF139D PRIMARY KEY (
	name
	)
go
alter table dbo.category add constraint PK__category__08B54D69 PRIMARY KEY (
	code
	)
go
alter table dbo.commodity add constraint PK__commodity__4BAC3F29 PRIMARY KEY (
	id
	)
go
alter table dbo.company add constraint PK__company__36B12243 PRIMARY KEY (
	id
	)
go
alter table dbo.company_info add constraint PK__company_info__25869641 PRIMARY KEY (
	name
	)
go
alter table dbo.contact add constraint PK__contact__34C8D9D1 PRIMARY KEY (
	name
	)
go
alter table dbo.contact_call_log add constraint PK__contact_call_log__44D52468 PRIMARY KEY (
	contact,start_date
	)
go
alter table dbo.currency_conversion add constraint PK__currency_convers__45BE5BA9 PRIMARY KEY (
	currency_code,effective_date
	)
go
alter table dbo.custom_pbl_link add constraint PK__custom_pbl_link__47B19113 PRIMARY KEY (
	module
	)
go
alter table dbo.customer add constraint PK__customer__32E0915F PRIMARY KEY (
	customer
	)
go
alter table dbo.customer_additional add constraint PK__customer_additio__7B905C75 PRIMARY KEY (
	customer
	)
go
alter table dbo.customer_origin_code add constraint PK__customer_origin___47A6A41B PRIMARY KEY (
	code
	)
go
alter table dbo.customer_service_status add constraint PK__customer_service__498EEC8D PRIMARY KEY (
	status_name
	)
go
alter table dbo.defect_codes add constraint PK__defect_codes__014935CB PRIMARY KEY (
	code
	)
go
alter table dbo.defects add constraint PK__defects__4999D985 PRIMARY KEY (
	machine,defect_date,defect_time
	)
go
alter table dbo.department add constraint PK__department__5AEE82B9 PRIMARY KEY (
	code
	)
go
alter table dbo.destination add constraint PK__destination__440B1D61 PRIMARY KEY (
	destination
	)
go
alter table dbo.destination_package add constraint PK__destination_pack__02FC7413 PRIMARY KEY (
	destination,package
	)
go
alter table dbo.destination_shipping add constraint PK__destination_ship__7F60ED59 PRIMARY KEY (
	destination
	)
go
alter table dbo.dim_relation add constraint PK__dim_relation__4B8221F7 PRIMARY KEY (
	dim_code
	)
go
alter table dbo.dimensions add constraint PK__dimensions__4D6A6A69 PRIMARY KEY (
	dim_code,dimension
	)
go
alter table dbo.downtime add constraint PK__downtime__4F52B2DB PRIMARY KEY (
	trans_date,machine,trans_time
	)
go
alter table dbo.downtime_codes add constraint PK__downtime_codes__513AFB4D PRIMARY KEY (
	dt_code
	)
go
alter table dbo.dw_inquiry_files add constraint PK__dw_inquiry_files__47DBAE45 PRIMARY KEY (
	datawindow_name
	)
go
alter table dbo.edi_ff_layout add constraint PK__edi_ff_layout__532343BF PRIMARY KEY (
	transaction_set,overlay_group,line,field
	)
go
alter table dbo.edi_ff_loops add constraint PK__edi_ff_loops__550B8C31 PRIMARY KEY (
	transaction_set,overlay_group,line
	)
go
alter table dbo.edi_overlay_structure add constraint PK__edi_overlay_stru__7A672E12 PRIMARY KEY (
	overlay_group,data_set,column_name,line,position
	)
go
alter table dbo.edi_setups add constraint PK__edi_setups__1C323631 PRIMARY KEY (
	destination
	)
go
alter table dbo.edi_setups_backup add constraint PK__edi_setups__7D78A4E7 PRIMARY KEY (
	destination
	)
go
alter table dbo.effective_change_notice add constraint PK__effective_change__55FFB06A PRIMARY KEY (
	part,effective_date
	)
go
alter table dbo.employee add constraint PK__employee__57E7F8DC PRIMARY KEY (
	operator_code
	)
go
alter table dbo.employee add constraint UQ__employee__58DC1D15 UNIQUE (
	password
	)
go
alter table dbo.exp_apdata_detail add constraint PK__exp_apdata_detai__5AC46587 PRIMARY KEY (
	trx_ctrl_num,sequence_id
	)
go
alter table dbo.exp_apdata_header add constraint PK__exp_apdata_heade__5CACADF9 PRIMARY KEY (
	trx_ctrl_num,batch_code
	)
go
alter table dbo.filters add constraint PK_filters PRIMARY KEY (
	filtername,sequence
	)
go
alter table dbo.freight_type_definition add constraint PK__freight_type_def__6FB49575 PRIMARY KEY (
	type_name
	)
go
alter table dbo.gl_tran_type add constraint PK__gl_tran_type__5E94F66B PRIMARY KEY (
	code
	)
go
alter table dbo.group_technology add constraint PK__group_technology__534D60F1 PRIMARY KEY (
	id
	)
go
alter table dbo.interface_utilities add constraint PK__interface_utilit__0C85DE4D PRIMARY KEY (
	transaction_type,sequence
	)
go
alter table dbo.inventory_accuracy_history add constraint PK__inventory_accura__61716316 PRIMARY KEY (
	code,date_counted
	)
go
alter table dbo.issues_category add constraint PK__issues_category__40F9A68C PRIMARY KEY (
	category
	)
go
alter table dbo.issues_status add constraint PK__issues_status__3F115E1A PRIMARY KEY (
	status
	)
go
alter table dbo.issues_sub_category add constraint PK__issues_sub_categ__42E1EEFE PRIMARY KEY (
	category,sub_category
	)
go
alter table dbo.kanban add constraint PK__kanban__07970BFE PRIMARY KEY (
	kanban_number,order_no
	)
go
alter table dbo.labor add constraint PK__labor__5535A963 PRIMARY KEY (
	id
	)
go
alter table dbo.limit_parts add constraint PK__limit_parts__0A9D95DB PRIMARY KEY (
	part
	)
go
alter table dbo.link add constraint PK__link__70DDC3D8 PRIMARY KEY (
	type,order_no,order_detail_id,mps_origin,mps_row_id
	)
go
alter table dbo.location add constraint PK__location__03317E3D PRIMARY KEY (
	code
	)
go
alter table dbo.location_limits add constraint PK__location_limits__00200768 PRIMARY KEY (
	trans_code,location_code
	)
go
alter table dbo.machine add constraint PK__machine__0519C6AF PRIMARY KEY (
	machine_no
	)
go
alter table dbo.machine_data_1050 add constraint PK__machine_data_105__6359AB88 PRIMARY KEY (
	machine
	)
go
alter table dbo.machine_policy add constraint PK__machine_policy__6477ECF3 PRIMARY KEY (
	machine
	)
go
alter table dbo.machine_process add constraint PK__machine_process__571DF1D5 PRIMARY KEY (
	machine,process
	)
go
alter table dbo.machine_serial_comm add constraint PK__machine_serial_c__0A7378A9 PRIMARY KEY (
	machine
	)
go
alter table dbo.mdata add constraint PK__mdata__36870511 PRIMARY KEY (
	mcode
	)
go
alter table dbo.mold add constraint PK__mold__145C0A3F PRIMARY KEY (
	mold_number
	)
go
alter table dbo.multireleases add constraint multirelease_pk PRIMARY KEY (
	id,part,rel_date
	)
go
alter table dbo.package_materials add constraint PK__package_material__4D2A7347 PRIMARY KEY (
	code
	)
go
alter table dbo.package_materials_copy add constraint PK__package_material__50FB042B PRIMARY KEY (
	code
	)
go
alter table dbo.parameters add constraint PK__parameters__403A8C7D PRIMARY KEY (
	company_name
	)
go
alter table dbo.part add constraint part_x PRIMARY KEY (
	part
	)
go
alter table dbo.part_characteristics add constraint PK__part_characteris__30F848ED PRIMARY KEY (
	part
	)
go
alter table dbo.part_class_definition add constraint PK__part_class_defin__691284DE PRIMARY KEY (
	class
	)
go
alter table dbo.part_class_type_cross_ref add constraint PK__part_class_type___0D4FE554 PRIMARY KEY (
	class,type
	)
go
alter table dbo.part_copy add constraint PK__part_copy__382F5661 PRIMARY KEY (
	part
	)
go
alter table dbo.part_customer add constraint part_customer_x PRIMARY KEY (
	part,customer
	)
go
alter table dbo.part_customer_price_matrix add constraint PK__part_customer_pr__6AFACD50 PRIMARY KEY (
	part,customer,qty_break
	)
go
alter table dbo.part_customer_tbp add constraint PK__part_customer_tb__15261146 PRIMARY KEY (
	customer,part,effect_date
	)
go
alter table dbo.part_gl_account add constraint PK__part_gl_account__4D5F7D71 PRIMARY KEY (
	part,tran_type
	)
go
alter table dbo.part_inventory add constraint PK_part_inventory PRIMARY KEY (
	part
	)
go
alter table dbo.part_location add constraint PK__part_location__6CE315C2 PRIMARY KEY (
	part,location
	)
go
alter table dbo.part_machine add constraint PK__part_machine__59063A47 PRIMARY KEY (
	part,machine
	)
go
alter table dbo.part_machine_tool add constraint PK__part_machine_too__6ECB5E34 PRIMARY KEY (
	part,machine,tool
	)
go
alter table dbo.part_machine_tool_list add constraint PK__part_machine_too__729BEF18 PRIMARY KEY (
	part,machine,station_id,tool
	)
go
alter table dbo.part_online add constraint PK__part_online__3E52440B PRIMARY KEY (
	part
	)
go
alter table dbo.part_packaging add constraint PK__part_packaging__628FA481 PRIMARY KEY (
	part,code
	)
go
alter table dbo.part_purchasing add constraint PK__part_purchasing__49C3F6B7 PRIMARY KEY (
	part
	)
go
alter table dbo.part_revision add constraint PK__part_revision__11207638 PRIMARY KEY (
	part,revision,engineering_level
	)
go
alter table dbo.part_standard add constraint part_standard_x PRIMARY KEY (
	part
	)
go
alter table dbo.part_tooling add constraint PK__part_tooling__70B3A6A6 PRIMARY KEY (
	part,tool_number
	)
go
alter table dbo.part_type_definition add constraint PK__part_type_defini__7484378A PRIMARY KEY (
	type
	)
go
alter table dbo.part_unit_conversion add constraint PK__part_unit_conver__2B3F6F97 PRIMARY KEY (
	part,code
	)
go
alter table dbo.part_vendor add constraint PK_part_vendor1 PRIMARY KEY (
	part,vendor
	)
go
alter table dbo.part_vendor_price_matrix add constraint PK__part_vendor_pric__13FCE2E3 PRIMARY KEY (
	part,vendor,break_qty
	)
go
alter table dbo.phone add constraint PK__phone__3A81B327 PRIMARY KEY (
	name,namel
	)
go
alter table dbo.plant_part add constraint PK__plant_part__76969D2E PRIMARY KEY (
	plant,part
	)
go
alter table dbo.po_detail add constraint PK_po_detail PRIMARY KEY (
	po_number,part_number,date_due,row_id
	)
go
alter table dbo.po_detail_history add constraint PK_po_detail_history PRIMARY KEY (
	po_number,part_number,date_due,row_id
	)
go
alter table dbo.process add constraint PK__process__3C69FB99 PRIMARY KEY (
	id
	)
go
alter table dbo.product_line add constraint PK__product_line__38996AB5 PRIMARY KEY (
	id
	)
go
alter table dbo.production_shift add constraint PK__production_shift__7760A435 PRIMARY KEY (
	part,transaction_timestamp
	)
go
alter table dbo.region_code add constraint PK__region_code__4F47C5E3 PRIMARY KEY (
	code
	)
go
alter table dbo.report_library add constraint PK__report_library__16D94F8E PRIMARY KEY (
	name,report
	)
go
alter table dbo.report_list add constraint PK__report_list__7948ECA7 PRIMARY KEY (
	report
	)
go
alter table dbo.requisition_account_project add constraint PK__requisition_acco__2CBDA3B5 PRIMARY KEY (
	account_number,project_number
	)
go
alter table dbo.requisition_group add constraint PK__requisition_grou__32767D0B PRIMARY KEY (
	group_code
	)
go
alter table dbo.requisition_group_account add constraint PK__requisition_grou__345EC57D PRIMARY KEY (
	group_code,account_no
	)
go
alter table dbo.requisition_group_project add constraint PK__requisition_grou__36470DEF PRIMARY KEY (
	group_code,project_number
	)
go
alter table dbo.requisition_notes add constraint PK__requisition_note__2AD55B43 PRIMARY KEY (
	code
	)
go
alter table dbo.requisition_project_number add constraint PK__requisition_proj__2EA5EC27 PRIMARY KEY (
	project_number
	)
go
alter table dbo.requisition_security add constraint PK__requisition_secu__261B931E PRIMARY KEY (
	operator_code
	)
go
alter table dbo.sales_manager_code add constraint PK__sales_manager_co__51300E55 PRIMARY KEY (
	code
	)
go
alter table dbo.salesrep add constraint salesrep_x PRIMARY KEY (
	salesrep
	)
go
alter table dbo.shipper_container add constraint PK_shipper_container PRIMARY KEY (
	shipper,container_type
	)
go
alter table dbo.shipper_detail add constraint PK_shipper_detail PRIMARY KEY (
	shipper,part
	)
go
alter table dbo.shop_floor_calendar add constraint UQ__shop_floor_calen__7C255952 UNIQUE (
	machine,begin_datetime
	)
go
alter table dbo.shop_floor_time_log add constraint PK__shop_floor_time___7E0DA1C4 PRIMARY KEY (
	operator,transaction_date_time
	)
go
alter table dbo.StampingSetup add constraint UC_StampingSetup UNIQUE (
	FinishedGood,RawPart,Supplier,PoNumber
	)
go
alter table dbo.StampingSetup_PO_Import add constraint uc_po_import UNIQUE (
	RawPart,PoDate,Quantity
	)
go
alter table dbo.T_EmpRep add constraint PK__T_EmpRep__67C95AEA PRIMARY KEY (
	operator
	)
go
alter table dbo.T_EmpRep_Temp add constraint PK_EmpRep_Temp PRIMARY KEY (
	operator
	)
go
alter table dbo.tdata add constraint PK__tdata__22EA20B8 PRIMARY KEY (
	mcode,ucode
	)
go
alter table dbo.temp_pops add constraint PK__temp_pops__6C190EBB PRIMARY KEY (
	name,number
	)
go
alter table dbo.trans_mode add constraint PK__trans_mode__78B3EFCA PRIMARY KEY (
	code
	)
go
alter table dbo.unit_conversion add constraint unit_conversion_x PRIMARY KEY (
	code,unit1,unit2
	)
go
alter table dbo.unit_measure add constraint PK__unit_measure__1DE57479 PRIMARY KEY (
	unit
	)
go
alter table dbo.unit_sub add constraint PK__unit_sub__03C67B1A PRIMARY KEY (
	unit_group,sequence
	)
go
alter table dbo.user_definable_data add constraint PK__user_definable_d__787EE5A0 PRIMARY KEY (
	module,sequence,code
	)
go
alter table dbo.user_definable_module_labels add constraint user_definable_module_labels_x PRIMARY KEY (
	module,sequence
	)
go
alter table dbo.user_defined_status add constraint PK__user_defined_sta__04E4BC85 PRIMARY KEY (
	display_name
	)
go
alter table dbo.vendor add constraint PK__vendor__167AF389 PRIMARY KEY (
	code
	)
go
alter table dbo.vendor_custom add constraint PK__vendor_custom__05AEC38C PRIMARY KEY (
	code
	)
go
alter table dbo.vendor_service_status add constraint PK__vendor_service__status PRIMARY KEY (
	status_name
	)
go
alter table dbo.work_order add constraint PK__work_order__19B5BC39 PRIMARY KEY (
	work_order
	)
go
alter table dbo.workorder_detail add constraint PK__workorder_detail__5165187F PRIMARY KEY (
	workorder,part
	)
go
alter table dbo.workorder_detail_history add constraint PK__workorder_detail__7C4F7684 PRIMARY KEY (
	workorder,part
	)
go
alter table dbo.workorder_header_history add constraint PK__workorder_header__1C9228E4 PRIMARY KEY (
	work_order,machine_no,sequence
	)
go
alter table dbo.xreport_datasource add constraint PK__xreport_datasour__531856C7 PRIMARY KEY (
	datasource_name
	)
go
alter table dbo.xreport_library add constraint PK__xreport_library__55009F39 PRIMARY KEY (
	name,report
	)
go
alter table FT.PartRouter add constraint PK__PartRout__A15FB6946FFB18C3 PRIMARY KEY (
	Part
	)
go
alter table FT.XRt add constraint UQ__XRt__1FDC25FC3945FD15 UNIQUE (
	TopPart,Sequence
	)
go
