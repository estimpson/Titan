alter table dbo.account_code drop constraint PK__account_code__308E3499
go
alter table dbo.activity_codes drop constraint PK__activity_codes__1FCDBCEB
go
alter table dbo.activity_costs drop constraint PK__activity_costs__21B6055D
go
alter table dbo.activity_router drop constraint PK__activity_router__42ECDBF6
go
alter table dbo.alternative_parts drop constraint PK__alternative_part__0F624AF8
go
alter table dbo.asn_overlay_structure drop constraint PK__asn_overlay_stru__66603565
go
alter table dbo.BartenderLabels drop constraint PK_BartenderLabels
go
alter table dbo.bill_of_material_ec drop constraint bill_of_material_ec_x
go
alter table dbo.carrier drop constraint PK__carrier__5EBF139D
go
alter table dbo.category drop constraint PK__category__08B54D69
go
alter table dbo.commodity drop constraint PK__commodity__4BAC3F29
go
alter table dbo.company drop constraint PK__company__36B12243
go
alter table dbo.company_info drop constraint PK__company_info__25869641
go
alter table dbo.contact drop constraint PK__contact__34C8D9D1
go
alter table dbo.contact_call_log drop constraint PK__contact_call_log__44D52468
go
alter table dbo.currency_conversion drop constraint PK__currency_convers__45BE5BA9
go
alter table dbo.custom_pbl_link drop constraint PK__custom_pbl_link__47B19113
go
alter table dbo.customer drop constraint PK__customer__32E0915F
go
alter table dbo.customer_additional drop constraint PK__customer_additio__7B905C75
go
alter table dbo.customer_origin_code drop constraint PK__customer_origin___47A6A41B
go
alter table dbo.customer_service_status drop constraint PK__customer_service__498EEC8D
go
alter table dbo.defect_codes drop constraint PK__defect_codes__014935CB
go
alter table dbo.defects drop constraint PK__defects__4999D985
go
alter table dbo.department drop constraint PK__department__5AEE82B9
go
alter table dbo.destination drop constraint PK__destination__440B1D61
go
alter table dbo.destination_package drop constraint PK__destination_pack__02FC7413
go
alter table dbo.destination_shipping drop constraint PK__destination_ship__7F60ED59
go
alter table dbo.dim_relation drop constraint PK__dim_relation__4B8221F7
go
alter table dbo.dimensions drop constraint PK__dimensions__4D6A6A69
go
alter table dbo.downtime drop constraint PK__downtime__4F52B2DB
go
alter table dbo.downtime_codes drop constraint PK__downtime_codes__513AFB4D
go
alter table dbo.dw_inquiry_files drop constraint PK__dw_inquiry_files__47DBAE45
go
alter table dbo.edi_ff_layout drop constraint PK__edi_ff_layout__532343BF
go
alter table dbo.edi_ff_loops drop constraint PK__edi_ff_loops__550B8C31
go
alter table dbo.edi_overlay_structure drop constraint PK__edi_overlay_stru__7A672E12
go
alter table dbo.edi_setups drop constraint PK__edi_setups__1C323631
go
alter table dbo.edi_setups_backup drop constraint PK__edi_setups__7D78A4E7
go
alter table dbo.effective_change_notice drop constraint PK__effective_change__55FFB06A
go
alter table dbo.employee drop constraint PK__employee__57E7F8DC
go
alter table dbo.employee drop constraint UQ__employee__58DC1D15
go
alter table dbo.exp_apdata_detail drop constraint PK__exp_apdata_detai__5AC46587
go
alter table dbo.exp_apdata_header drop constraint PK__exp_apdata_heade__5CACADF9
go
alter table dbo.filters drop constraint PK_filters
go
alter table dbo.freight_type_definition drop constraint PK__freight_type_def__6FB49575
go
alter table dbo.gl_tran_type drop constraint PK__gl_tran_type__5E94F66B
go
alter table dbo.group_technology drop constraint PK__group_technology__534D60F1
go
alter table dbo.interface_utilities drop constraint PK__interface_utilit__0C85DE4D
go
alter table dbo.inventory_accuracy_history drop constraint PK__inventory_accura__61716316
go
alter table dbo.issues_category drop constraint PK__issues_category__40F9A68C
go
alter table dbo.issues_status drop constraint PK__issues_status__3F115E1A
go
alter table dbo.issues_sub_category drop constraint PK__issues_sub_categ__42E1EEFE
go
alter table dbo.kanban drop constraint PK__kanban__07970BFE
go
alter table dbo.labor drop constraint PK__labor__5535A963
go
alter table dbo.limit_parts drop constraint PK__limit_parts__0A9D95DB
go
alter table dbo.link drop constraint PK__link__70DDC3D8
go
alter table dbo.location drop constraint PK__location__03317E3D
go
alter table dbo.location_limits drop constraint PK__location_limits__00200768
go
alter table dbo.machine drop constraint PK__machine__0519C6AF
go
alter table dbo.machine_data_1050 drop constraint PK__machine_data_105__6359AB88
go
alter table dbo.machine_policy drop constraint PK__machine_policy__6477ECF3
go
alter table dbo.machine_process drop constraint PK__machine_process__571DF1D5
go
alter table dbo.machine_serial_comm drop constraint PK__machine_serial_c__0A7378A9
go
alter table dbo.mdata drop constraint PK__mdata__36870511
go
alter table dbo.mold drop constraint PK__mold__145C0A3F
go
alter table dbo.multireleases drop constraint multirelease_pk
go
alter table dbo.package_materials drop constraint PK__package_material__4D2A7347
go
alter table dbo.package_materials_copy drop constraint PK__package_material__50FB042B
go
alter table dbo.parameters drop constraint PK__parameters__403A8C7D
go
alter table dbo.part drop constraint part_x
go
alter table dbo.part_characteristics drop constraint PK__part_characteris__30F848ED
go
alter table dbo.part_class_definition drop constraint PK__part_class_defin__691284DE
go
alter table dbo.part_class_type_cross_ref drop constraint PK__part_class_type___0D4FE554
go
alter table dbo.part_copy drop constraint PK__part_copy__382F5661
go
alter table dbo.part_customer drop constraint part_customer_x
go
alter table dbo.part_customer_price_matrix drop constraint PK__part_customer_pr__6AFACD50
go
alter table dbo.part_customer_tbp drop constraint PK__part_customer_tb__15261146
go
alter table dbo.part_gl_account drop constraint PK__part_gl_account__4D5F7D71
go
alter table dbo.part_inventory drop constraint PK_part_inventory
go
alter table dbo.part_location drop constraint PK__part_location__6CE315C2
go
alter table dbo.part_machine drop constraint PK__part_machine__59063A47
go
alter table dbo.part_machine_tool drop constraint PK__part_machine_too__6ECB5E34
go
alter table dbo.part_machine_tool_list drop constraint PK__part_machine_too__729BEF18
go
alter table dbo.part_online drop constraint PK__part_online__3E52440B
go
alter table dbo.part_packaging drop constraint PK__part_packaging__628FA481
go
alter table dbo.part_purchasing drop constraint PK__part_purchasing__49C3F6B7
go
alter table dbo.part_revision drop constraint PK__part_revision__11207638
go
alter table dbo.part_standard drop constraint part_standard_x
go
alter table dbo.part_tooling drop constraint PK__part_tooling__70B3A6A6
go
alter table dbo.part_type_definition drop constraint PK__part_type_defini__7484378A
go
alter table dbo.part_unit_conversion drop constraint PK__part_unit_conver__2B3F6F97
go
alter table dbo.part_vendor drop constraint PK_part_vendor1
go
alter table dbo.part_vendor_price_matrix drop constraint PK__part_vendor_pric__13FCE2E3
go
alter table dbo.phone drop constraint PK__phone__3A81B327
go
alter table dbo.plant_part drop constraint PK__plant_part__76969D2E
go
alter table dbo.po_detail drop constraint PK_po_detail
go
alter table dbo.po_detail_history drop constraint PK_po_detail_history
go
alter table dbo.process drop constraint PK__process__3C69FB99
go
alter table dbo.product_line drop constraint PK__product_line__38996AB5
go
alter table dbo.production_shift drop constraint PK__production_shift__7760A435
go
alter table dbo.region_code drop constraint PK__region_code__4F47C5E3
go
alter table dbo.report_library drop constraint PK__report_library__16D94F8E
go
alter table dbo.report_list drop constraint PK__report_list__7948ECA7
go
alter table dbo.requisition_account_project drop constraint PK__requisition_acco__2CBDA3B5
go
alter table dbo.requisition_group drop constraint PK__requisition_grou__32767D0B
go
alter table dbo.requisition_group_account drop constraint PK__requisition_grou__345EC57D
go
alter table dbo.requisition_group_project drop constraint PK__requisition_grou__36470DEF
go
alter table dbo.requisition_notes drop constraint PK__requisition_note__2AD55B43
go
alter table dbo.requisition_project_number drop constraint PK__requisition_proj__2EA5EC27
go
alter table dbo.requisition_security drop constraint PK__requisition_secu__261B931E
go
alter table dbo.sales_manager_code drop constraint PK__sales_manager_co__51300E55
go
alter table dbo.salesrep drop constraint salesrep_x
go
alter table dbo.shipper_container drop constraint PK_shipper_container
go
alter table dbo.shipper_detail drop constraint PK_shipper_detail
go
alter table dbo.shop_floor_calendar drop constraint UQ__shop_floor_calen__7C255952
go
alter table dbo.shop_floor_time_log drop constraint PK__shop_floor_time___7E0DA1C4
go
alter table dbo.StampingSetup drop constraint UC_StampingSetup
go
alter table dbo.StampingSetup_PO_Import drop constraint uc_po_import
go
alter table dbo.T_EmpRep drop constraint PK__T_EmpRep__67C95AEA
go
alter table dbo.T_EmpRep_Temp drop constraint PK_EmpRep_Temp
go
alter table dbo.tdata drop constraint PK__tdata__22EA20B8
go
alter table dbo.temp_pops drop constraint PK__temp_pops__6C190EBB
go
alter table dbo.trans_mode drop constraint PK__trans_mode__78B3EFCA
go
alter table dbo.unit_conversion drop constraint unit_conversion_x
go
alter table dbo.unit_measure drop constraint PK__unit_measure__1DE57479
go
alter table dbo.unit_sub drop constraint PK__unit_sub__03C67B1A
go
alter table dbo.user_definable_data drop constraint PK__user_definable_d__787EE5A0
go
alter table dbo.user_definable_module_labels drop constraint user_definable_module_labels_x
go
alter table dbo.user_defined_status drop constraint PK__user_defined_sta__04E4BC85
go
alter table dbo.vendor drop constraint PK__vendor__167AF389
go
alter table dbo.vendor_custom drop constraint PK__vendor_custom__05AEC38C
go
alter table dbo.vendor_service_status drop constraint PK__vendor_service__status
go
alter table dbo.work_order drop constraint PK__work_order__19B5BC39
go
alter table dbo.workorder_detail drop constraint PK__workorder_detail__5165187F
go
alter table dbo.workorder_detail_history drop constraint PK__workorder_detail__7C4F7684
go
alter table dbo.workorder_header_history drop constraint PK__workorder_header__1C9228E4
go
alter table dbo.xreport_datasource drop constraint PK__xreport_datasour__531856C7
go
alter table dbo.xreport_library drop constraint PK__xreport_library__55009F39
go
alter table FT.PartRouter drop constraint PK__PartRout__A15FB6946FFB18C3
go
alter table FT.XRt drop constraint UQ__XRt__1FDC25FC3945FD15
go

