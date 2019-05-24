print	'Part Standard changes'

if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'os_cost' )
	alter table part_standard add os_cost numeric(20,6) null
go
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'os_cost_cum' )
	alter table part_standard add os_cost_cum numeric(20,6) null
go
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'os_qtd_cost' )
	alter table part_standard add os_qtd_cost numeric(20,6) null
go
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'os_qtd_cost_cum' )
	alter table part_standard add os_qtd_cost_cum numeric(20,6) null
go
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'os_planned_cost' )
	alter table part_standard add os_planned_cost numeric(20,6) null
go
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'os_planned_cost_cum' )
	alter table part_standard add os_planned_cost_cum numeric(20,6) null
go
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'os_frozen_cost' )
	alter table part_standard add os_frozen_cost numeric(20,6) null
go
if not exists ( select 1 from dbo.sysobjects so, dbo.syscolumns sc where so.name = 'part_standard' and sc.id = so.id and sc.name = 'os_frozen_cost_cum' )
	alter table part_standard add os_frozen_cost_cum numeric(20,6) null
go

print'
------------------------------
-- procedure:	msp_calc_costs
------------------------------
'
if exists(select 1 from dbo.sysobjects where name='msp_calc_costs' and type = 'P')
   drop procedure msp_calc_costs
go
create procedure msp_calc_costs (@part varchar(25), @cost_bucket char(1)) as  
begin -- (1b)
--------------------------------------------------------------------------------------------------------------------------
--
--	Procedure 	msp_calc_costs
--	Arguments	part varchar(25)
--			cost bucket char(1) ie S/P/Q/F
--	Purpose		To rollup the cost from it's components for the specified part
--
--	Logic		
--		Declare variables
--		Create Temp tables
--		Initialize
--		Process data in temp table #bom_parts starting from the top part
--			process all component parts
--		processing the costing rollup from the deepest level 
--		process all the rows in the temp table in the reverse order (cost rolls up from inner most to top part)
--			calculate labor & burden
--			update part_standard table with the new values for the current part
--
--	Development	GPH
--------------------------------------------------------------------------------------------------------------------------
--	Declare variables
declare @rowno  int, 
	@rowno_prev int,   
	@parent_part varchar(25),
	@parent_part_prev varchar(25),
	@bom_level integer,                    
	@partno varchar(25),
	@parentpartno varchar(25),
	@part_tmp varchar(25),
	@bom_qty numeric(20,6),
	@bom_type char(1),
	@bomlevel integer,
	@extended_qty numeric(20,6),
	@cost              numeric(20,6),
	@material          numeric(20,6),
	@labor             numeric(20,6),
	@burden            numeric(20,6),
	@other             numeric(20,6),
	@cost_cum          numeric(20,6),
	@material_cum      numeric(20,6),
	@labor_cum         numeric(20,6),
	@burden_cum        numeric(20,6),
	@other_cum         numeric(20,6),
	@mfg_lot_size      numeric(20,6),
	@standard_rate     numeric(20,6),
	@standard_rate_mc  numeric(20,6),  
	@parts_per_hour    numeric(20,6),
	@setup_time        numeric(5,2),
	@machine_no        varchar(10),
	@include_setuptime varchar(1),
	@varying           numeric(20,6),
	@indirect          numeric(20,6),
	@sga               numeric(20,6), 
	@varying_mc        numeric(20,6),
	@indirect_mc       numeric(20,6),
	@sga_mc            numeric(20,6), 
	@crew_size         numeric(20,6), 
	@parttype          varchar(1),
	@calc_mtl_cost     varchar(1),
	@default_vendor    varchar(10),
	@vendor_price      numeric(15,7),
	@qty               numeric(20,6),
	@vendor_uom        varchar(2),
	@std_uom           varchar(2),
	@conversion        numeric(15,7),
	@bom_uom           varchar(2),
	@count             integer

--	Create Temp tables
create table #bom_parts ( 
	rowno integer not null,
	parent_part varchar(25) null,
	part varchar(25) not null,
	bom_qty  numeric(20,6) not null,
	bom_level integer not null,
	bom_uom varchar(2) null)

create table #bom_parts_adnl ( 
	rowno integer not null,
	parent_part varchar(25) null,
	part varchar(25) not null,
	bom_qty  numeric(20,6) not null,
	bom_level integer not null,
	bom_uom varchar(2) null)

create table #duplicate_parts ( 
	parentpart 	varchar(25),
	part		varchar(25))

create table #bom_comp (part varchar(25) not null, 
	bom_qty numeric(20,6) not null,
	bom_uom varchar(2) null) 

begin transaction

	set rowcount 0
	--	Initialize
	select	@rowno=1, @bom_level = isnull(@bom_level,0) + 1

	select	@include_setuptime=include_setuptime,
		@calc_mtl_cost    =calc_mtl_cost
	from	parameters

	insert into #bom_parts values (@rowno, @parent_part, @part, 1, @bom_level, @bom_uom) 
	
	--	Process data in temp table #bom_parts starting from the top part
	set rowcount 1
	select	@partno=part,
		@rowno_prev = rowno,
		@bomlevel = bom_level 
	from	#bom_parts
	where	rowno > 0

	while @@rowcount > 0
	begin -- (2b)
		set rowcount 0  
		if @cost_bucket='S'
			update	part_standard
			set	cost_cum=0, material_cum=0, labor_cum=0, burden_cum=0, other_cum=0, cost=0 
			where	part = @partno
		else if @cost_bucket='Q'
			update	part_standard
			set	qtd_cost_cum=0, qtd_material_cum=0, qtd_labor_cum=0, 
				qtd_burden_cum=0, qtd_other_cum=0, qtd_cost=0 
			where	part = @partno
		else if @cost_bucket='P'
			update	part_standard
			set	planned_cost_cum=0, planned_material_cum=0, planned_labor_cum=0, 
				planned_burden_cum=0, planned_other_cum=0, planned_cost=0 
			where	part = @partno
		else if	@cost_bucket='F' 
			update	part_standard
			set	frozen_cost_cum=0, frozen_material_cum=0, frozen_labor_cum=0, 
				frozen_burden_cum=0, frozen_other_cum=0, frozen_cost=0 
			where	part = @partno

		set rowcount 0 
		--	insert into components temp table for the considered part
		insert into #bom_comp 
		select part, quantity, unit_measure from bill_of_material where parent_part = @partno and substitute_part <> 'Y'
		
		if @@rowcount > 0
		begin -- (3b)
			--	process all component parts		
			set rowcount 0 
			select @bomlevel = isnull(@bomlevel,0) + 1

			set rowcount 1
			select @part_tmp = part, @bom_qty = bom_qty, @bom_uom = bom_uom from #bom_comp

			while @@rowcount > 0
			begin -- (4b)
				set rowcount 0 
				select @rowno = @rowno + 1
				insert #bom_parts values (@rowno, @partno, @part_tmp, @bom_qty, @bomlevel, @bom_uom) 

				set rowcount 0              
				delete from #bom_comp where (part = @part_tmp)   

				set rowcount 1 
				select @part_tmp = part, @bom_qty = bom_qty, @bom_uom = bom_uom from #bom_comp
			end  -- (4e)
			set rowcount 0 
			delete from #bom_comp
			
		end -- (3e)
		
		set rowcount 1
		select	@partno=part,
			@rowno_prev = rowno,
			@bomlevel = bom_level
		from	#bom_parts
		where rowno > @rowno_prev
	end -- (2e)
	
	--	processing the costing rollup from the deepest level 
	set rowcount 0 
	insert	into #bom_parts_adnl
	select	rowno, parent_part, part, bom_qty, bom_level, bom_uom 
	from	#bom_parts
	order by rowno desc
	
	--	process all the rows in the temp table in the reverse order (cost rolls up from inner most to top part)
	set rowcount 1  
	select	@rowno = rowno,
		@parent_part=parent_part,
		@part = part,
		@bom_qty = isnull(bom_qty,1),
		@bom_level = bom_level,
		@bom_uom = bom_uom
	from	#bom_parts_adnl

	while @@rowcount > 0
	begin -- (3b)
		set rowcount 0 
		select	@material=0, @burden=0, @labor=0, @other=0, @cost=0, 
			@material_cum=0, @burden_cum=0, @labor_cum=0, @other_cum=0, @cost_cum=0,
			@standard_rate=0, @varying=0, @indirect=0, @sga=0,
			@standard_rate_mc=0, @varying_mc=0, @indirect_mc=0, @sga_mc=0,
			@conversion=1
			
		if @cost_bucket='S' -- Standard 
		begin 
			select	@material=isnull(ps.material,0.0),
				@labor   =isnull(ps.labor,0.0),
				@burden  =isnull(ps.burden,0.0),
				@other   =isnull(ps.other,0.0),
				@material_cum=isnull(ps.material_cum,0.0),
				@labor_cum   =isnull(ps.labor_cum,0.0),
				@burden_cum  =isnull(ps.burden_cum,0.0),
				@other_cum   =isnull(ps.other_cum,0.0),
				@parttype=(select p.class from part as p where p.part = ps.part),
				@std_uom=(select pi.standard_unit from part_inventory as pi where pi.part = ps.part),
				@default_vendor=(select isnull(pol.default_vendor,'') from part_online as pol where pol.part = ps.part),
				@machine_no=(select pm.machine from part_machine as pm where pm.part = ps.part  and pm.sequence = 1)
			from	part_standard as ps
			where	ps.part=@part

			set rowcount 1 
			select	@parts_per_hour=pmg.parts_per_hour,
				@mfg_lot_size  =pmg.mfg_lot_size,
				@setup_time    =pmg.setup_time,   
				@standard_rate =isnull(l.standard_rate,0),
				@varying       =isnull(l.varying_rate_1,0),
				@indirect      =isnull(l.indirect,0),
				@sga           =0
			from	part_mfg as pmg
				join labor as l on l.id = pmg.labor_code
			where	part=@part
			
			select	@standard_rate_mc=isnull(standard_rate,0),
				@varying_mc      =isnull(varying_rate_1,0),
				@indirect_mc     =isnull(indirect,0),
				@sga_mc          =0
			from	machine
			where	machine_no=@machine_no
		end
		else if @cost_bucket='Q' -- Quoted
		begin
			select	@material=isnull(ps.qtd_material,0.0),
				@labor   =isnull(ps.qtd_labor,0.0),
				@burden  =isnull(ps.qtd_burden,0.0),
				@other   =isnull(ps.qtd_other,0.0),
				@material_cum=isnull(ps.qtd_material_cum,0.0),
				@labor_cum   =isnull(ps.qtd_labor_cum,0.0),
				@burden_cum  =isnull(ps.qtd_burden_cum,0.0),
				@other_cum   =isnull(ps.qtd_other_cum,0.0),
				@parttype=(select p.class from part as p where p.part = ps.part),
				@std_uom=(select pi.standard_unit from part_inventory as pi where pi.part = ps.part),
				@default_vendor=(select isnull(pol.default_vendor,'') from part_online as pol where pol.part = ps.part),
				@machine_no=(select pm.machine from part_machine as pm where pm.part = ps.part  and pm.sequence = 1)
			from	part_standard as ps
			where	ps.part=@part
			
			set rowcount 1 
			select	@parts_per_hour=pmg.parts_per_hour,
				@mfg_lot_size  =pmg.mfg_lot_size,
				@setup_time    =pmg.setup_time,   
				@standard_rate =isnull(l.qted_rate,0),
				@varying       =isnull(l.qted_variable,0),
				@indirect      =isnull(l.qted_indirect,0),
				@sga           =isnull(l.qted_sga,0)
			from	part_mfg as pmg
				join labor as l on l.id = pmg.labor_code
			where	part=@part
			
			select	@standard_rate_mc=isnull(qted_rate,0),
				@varying_mc      =isnull(qted_variable,0),
				@indirect_mc     =isnull(qted_indirect,0),
				@sga_mc          =isnull(qted_sga,0)
			from	machine
			where	machine_no=@machine_no
		end
		else if @cost_bucket='P' -- Planned
		begin  
			select	@material=isnull(ps.planned_material,0.0),
				@labor   =isnull(ps.planned_labor,0.0),
				@burden  =isnull(ps.planned_burden,0.0),
				@other   =isnull(ps.planned_other,0.0),
				@material_cum=isnull(ps.planned_material_cum,0.0),
				@labor_cum   =isnull(ps.planned_labor_cum,0.0),
				@burden_cum  =isnull(ps.planned_burden_cum,0.0),
				@other_cum   =isnull(ps.planned_other_cum,0.0),
				@parttype=(select p.class from part as p where p.part = ps.part),
				@std_uom=(select pi.standard_unit from part_inventory as pi where pi.part = ps.part),
				@default_vendor=(select isnull(pol.default_vendor,'') from part_online as pol where pol.part = ps.part),
				@machine_no=(select pm.machine from part_machine as pm where pm.part = ps.part  and pm.sequence = 1)
			from	part_standard as ps
			where	ps.part=@part

			set rowcount 1 
			select	@parts_per_hour=pmg.parts_per_hour,
				@mfg_lot_size  =pmg.mfg_lot_size,
				@setup_time    =pmg.setup_time,   
				@standard_rate =isnull(l.plnd_rate,0),
				@varying       =isnull(l.plnd_variable,0),
				@indirect      =isnull(l.plnd_indirect,0),
				@sga           =isnull(l.plnd_sga,0)
			from	part_mfg as pmg
				join labor as l on l.id = pmg.labor_code
			where	part=@part
			
			select	@standard_rate=isnull(plnd_rate,0),
				@varying      =isnull(plnd_variable,0),
				@indirect     =isnull(plnd_indirect,0),
				@sga          =isnull(plnd_sga,0)
			from	machine
			where	machine_no=@machine_no
		end 
		else if @cost_bucket='F' -- Frozen
		begin 
			select	@material=isnull(ps.frozen_material,0.0),
				@labor   =isnull(ps.frozen_labor,0.0),
				@burden  =isnull(ps.frozen_burden,0.0),
				@other   =isnull(ps.frozen_other,0.0),
				@material_cum=isnull(ps.frozen_material_cum,0.0),
				@labor_cum   =isnull(ps.frozen_labor_cum,0.0),
				@burden_cum  =isnull(ps.frozen_burden_cum,0.0),
				@other_cum   =isnull(ps.frozen_other_cum,0.0),
				@parttype=(select p.class from part as p where p.part = ps.part),
				@std_uom=(select pi.standard_unit from part_inventory as pi where pi.part = ps.part),
				@default_vendor=(select isnull(pol.default_vendor,'') from part_online as pol where pol.part = ps.part),
				@machine_no=(select pm.machine from part_machine as pm where pm.part = ps.part  and pm.sequence = 1)
			from	part_standard as ps
			where	ps.part=@part
			
			set rowcount 1 
			select	@parts_per_hour=pmg.parts_per_hour,
				@mfg_lot_size  =pmg.mfg_lot_size,
				@setup_time    =pmg.setup_time,   
				@standard_rate =isnull(l.frzn_rate,0),
				@varying       =isnull(l.frzn_variable,0),
				@indirect      =isnull(l.frzn_indirect,0),
				@sga           =isnull(l.frzn_sga,0)
			from	part_mfg as pmg
				join labor as l on l.id = pmg.labor_code
			where	part=@part
			
			select	@standard_rate=isnull(frzn_rate,0),
				@varying      =isnull(frzn_variable,0),
				@indirect     =isnull(frzn_indirect,0),
				@sga          =isnull(frzn_sga,0)
			from	machine
			where	machine_no=@machine_no
		end
		
		if	@calc_mtl_cost='Y' and @parttype='P'
		begin
			set rowcount 1 
			select	@vendor_uom=receiving_um
			from	part_vendor
			where	part=@part and vendor=@default_vendor
			
			if @std_uom <> @vendor_uom
			begin
				set rowcount 1 
				select	@conversion=isnull(uc.conversion,1)
				from	part_unit_conversion as puc
					join unit_conversion as uc on uc.code=puc.code and
					uc.unit1=@std_uom and uc.unit2=@vendor_uom
				where	puc.part = @part
			end

			set rowcount 1
			select	@vendor_price=isnull(price,0)
			from	part_vendor_price_matrix
			where	vendor=@default_vendor and part=@part and break_qty=1
			
			if @cost_bucket='S'
				select @material= isnull(@vendor_price,0) * isnull(@conversion,1)
		end

		if @std_uom <> @bom_uom
		begin 
			set rowcount 1 
			select	@conversion=isnull(conversion,1)
			from	part_unit_conversion as a,unit_conversion as b
			where	a.part = @part and b.code=a.code and unit1=@bom_uom and unit2=@std_uom
			if @conversion is null
				select @conversion=1 
		end
		
		if @mfg_lot_size = 0
			select @mfg_lot_size=null
			
		if @parts_per_hour=0
			select @parts_per_hour=null 
			
		set rowcount 1
		select	@crew_size=isnull(crew_size,1)
		from	part_machine
		where	part=@part and machine=@machine_no and sequence=1

		if @crew_size is null or @crew_size=0
			select @crew_size=1  

		--	calculate labor & burden
		if @cost_bucket='S'
			if @include_setuptime='Y'
			begin
				--	calculate the labor with setuptime
				select @labor=(((1.0/isnull(@parts_per_hour,1.0))+(isnull(@setup_time,0.0)/isnull(@mfg_lot_size,1)))* (isnull(@standard_rate,0) * isnull(@crew_size,1)))
				if @varying>0
					select @labor= @labor + (((1.0/isnull(@parts_per_hour,1.0))+(isnull(@setup_time,0.0)/isnull(@mfg_lot_size,1))) * isnull(@varying,0)  * isnull(@crew_size,1))  
				if @indirect>0
					select @labor= @labor + (((1.0/isnull(@parts_per_hour,1.0))+(isnull(@setup_time,0.0)/isnull(@mfg_lot_size,1))) * isnull(@indirect,0) * isnull(@crew_size,1)) 
				if @sga>0
					select @labor= @labor + (((1.0/isnull(@parts_per_hour,1.0))+(isnull(@setup_time,0.0)/isnull(@mfg_lot_size,1))) * isnull(@sga,0)      * isnull(@crew_size,1)) 
					
				--	calculate the burden with setuptime
				select @burden = (((1.0/isnull(@parts_per_hour,1.0)) + (isnull(@setup_time,0.0)/isnull(@mfg_lot_size,1))) * isnull(@standard_rate_mc,0)) 
				if @varying_mc>0
					select @burden = isnull(@burden,0) + (((1.0/isnull(@parts_per_hour,1.0)) + (isnull(@setup_time,0.0)/isnull(@mfg_lot_size,1))) * isnull(@varying_mc,0))
				if @indirect_mc>0
					select @burden = isnull(@burden,0) + (((1.0/isnull(@parts_per_hour,1.0)) + (isnull(@setup_time,0.0)/isnull(@mfg_lot_size,1))) * isnull(@indirect_mc,0))
				if @sga_mc>0
					select @burden = isnull(@burden,0) + (((1.0/isnull(@parts_per_hour,1.0)) + (isnull(@setup_time,0.0)/isnull(@mfg_lot_size,1))) * isnull(@sga_mc,0))
			end -- ()
			else
			begin
				--	calculate labor without setup time
				select @labor=((1.0/isnull(@parts_per_hour,1.0))* (isnull(@standard_rate,0) * isnull(@crew_size,1)))
				if @varying>0
					select @labor= @labor + ((1.0/isnull(@parts_per_hour,1.0)) * isnull(@varying,0)  * isnull(@crew_size,1))  
				if @indirect>0
					select @labor= @labor + ((1.0/isnull(@parts_per_hour,1.0)) * isnull(@indirect,0) * isnull(@crew_size,1)) 
				if @sga>0
					select @labor= @labor + ((1.0/isnull(@parts_per_hour,1.0)) * isnull(@sga,0)      * isnull(@crew_size,1)) 
					
				--	calculate the burden without setuptime
				select @burden=((1.0/isnull(@parts_per_hour,1.0))* isnull(@standard_rate_mc,0))
				if @varying_mc>0
					select @burden = isnull(@burden,0) + ((1.0/isnull(@parts_per_hour,1.0)) * isnull(@varying_mc,0))
				if @indirect_mc>0
					select @burden = isnull(@burden,0) + ((1.0/isnull(@parts_per_hour,1.0)) * isnull(@indirect_mc,0))
				if @sga_mc>0
					select @burden = isnull(@burden,0) + ((1.0/isnull(@parts_per_hour,1.0)) * isnull(@sga_mc,0))
			end
	
		if @parttype in ('M', 'O')
			select	@material_cum = isnull(@material_cum,0) + isnull(@material,0),
				@labor_cum    = isnull(@labor_cum,0) + isnull(@labor,0),
				@burden_cum   = isnull(@burden_cum,0) + isnull(@burden,0), 
				@other_cum    = isnull(@other_cum,0) + isnull(@other,0)
		else
			if ((select a.flow_route_window 
				from	activity_codes a
					join part_machine b on b.activity = a.code
				where	b.part = @part) = 'w_create_flow_route_outside_version2')
				select	@material_cum = isnull(@material_cum,0) + isnull(@material,0),
					@labor_cum    = isnull(@labor_cum,0) + isnull(@labor,0),
					@burden_cum   = isnull(@burden_cum,0) + isnull(@burden,0), 
					@other_cum    = isnull(@other_cum,0) + isnull(@other,0)
			else    
				select	@material_cum = isnull(@material,0),
					@labor_cum    = isnull(@labor,0),
					@burden_cum   = isnull(@burden,0), 
					@other_cum    = isnull(@other,0)
					
		select	@cost_cum     = isnull(@material_cum,0.0)+
					isnull(@burden_cum,0.0)  +
					isnull(@labor_cum,0.0)   +
					isnull(@other_cum,0.0)
		select	@cost         = isnull(@material,0.0)+
					isnull(@burden,0.0)  +
					isnull(@labor,0.0)   +
					isnull(@other,0.0)
			
		--	update part_standard table with the new values for the current part					
		set rowcount 0 
		if @cost_bucket='S'
		begin  
			update	part_standard 
			set	cost        =isnull(@cost,0.0),
				material    =isnull(@material,0.0),
				labor       =isnull(@labor,0.0),
				burden      =isnull(@burden,0.0),
				other       =isnull(@other,0.0),
				cost_cum    =isnull(@cost_cum,0.0),
				material_cum=isnull(@material_cum,0.0),
				burden_cum  =isnull(@burden_cum,0.0),
				other_cum   =isnull(@other_cum,0.0),
				labor_cum   =isnull(@labor_cum,0.0),
				flag        =1,
				cost_changed_date=getdate() 
			where	part=@part
			
			select @count = count(1) from #duplicate_parts where parentpart=@parent_part and part=@part
			if @count = 0 
			begin  
				insert into #duplicate_parts values ( @parent_part, @part )
				set rowcount 0 
				--	update parent too
				update	part_standard
				set	material_cum=material_cum + (isnull(@material_cum,0.0) * @bom_qty * @conversion),
					labor_cum   =labor_cum    + (isnull(@labor_cum,0.0) * @bom_qty * @conversion),
					burden_cum  =burden_cum   + (isnull(@burden_cum,0.0) * @bom_qty * @conversion),
					other_cum   =other_cum    + (isnull(@other_cum,0.0) * @bom_qty * @conversion)
				where	part=@parent_part
			end          
		end
		else if @cost_bucket='Q'
		begin  
			update	part_standard
			set	qtd_cost        =isnull(@cost,0.0),
				qtd_material    =isnull(@material,0.0),
				qtd_labor       =isnull(@labor,0.0),
				qtd_burden      =isnull(@burden,0.0),
				qtd_other       =isnull(@other,0.0),
				qtd_cost_cum    =isnull(@cost_cum,0.0),
				qtd_material_cum=isnull(@material_cum,0.0),
				qtd_burden_cum  =isnull(@burden_cum,0.0),
				qtd_other_cum   =isnull(@other_cum,0.0),
				qtd_labor_cum   =isnull(@labor_cum,0.0),
				flag        =1,
				qtd_changed_date=getdate() 
			where part=@part
			
			select @count = count(1) from #duplicate_parts where parentpart=@parent_part and part=@part
			if @count = 0 
			begin  
				insert into #duplicate_parts values ( @parent_part, @part )
				set rowcount 0 

				update	part_standard 
				set	qtd_material_cum=qtd_material_cum + (isnull(@material_cum,0.0) * @bom_qty * @conversion),
					qtd_labor_cum   =qtd_labor_cum    + (isnull(@labor_cum,0.0) * @bom_qty * @conversion),
					qtd_burden_cum  =qtd_burden_cum   + (isnull(@burden_cum,0.0) * @bom_qty * @conversion),
					qtd_other_cum   =qtd_other_cum    + (isnull(@other_cum,0.0) * @bom_qty * @conversion)
				where	part=@parent_part
			end         
		end
		else if @cost_bucket='P'
		begin  
			update	part_standard
			set	planned_cost        =isnull(@cost,0.0),
				planned_material    =isnull(@material,0.0),
				planned_labor       =isnull(@labor,0.0),
				planned_burden      =isnull(@burden,0.0),
				planned_other       =isnull(@other,0.0),
				planned_cost_cum    =isnull(@cost_cum,0.0),
				planned_material_cum=isnull(@material_cum,0.0),
				planned_burden_cum  =isnull(@burden_cum,0.0),
				planned_other_cum   =isnull(@other_cum,0.0),
				planned_labor_cum   =isnull(@labor_cum,0.0),
				flag        =1,
				planned_changed_date=getdate() 
			where	part=@part
			
			select @count = count(1) from #duplicate_parts where parentpart=@parent_part and part=@part
			if @count = 0 
			begin  
				insert into #duplicate_parts values ( @parent_part, @part )
				set rowcount 0 

				update	part_standard 
				set	planned_material_cum=planned_material_cum + (isnull(@material_cum,0.0) * @bom_qty * @conversion),
					planned_labor_cum   =planned_labor_cum    + (isnull(@labor_cum,0.0) * @bom_qty * @conversion),
					planned_burden_cum  =planned_burden_cum   + (isnull(@burden_cum,0.0) * @bom_qty * @conversion),
					planned_other_cum   =planned_other_cum    + (isnull(@other_cum,0.0) * @bom_qty * @conversion)
				where	part=@parent_part
			end         
		end
		else if @cost_bucket='F'
		begin
			update part_standard
			set	frozen_cost        =isnull(@cost,0.0),
				frozen_material    =isnull(@material,0.0),
				frozen_labor       =isnull(@labor,0.0),
				frozen_burden      =isnull(@burden,0.0),
				frozen_other       =isnull(@other,0.0),
				frozen_cost_cum    =isnull(@cost_cum,0.0),
				frozen_material_cum=isnull(@material_cum,0.0),
				frozen_burden_cum  =isnull(@burden_cum,0.0),
				frozen_other_cum   =isnull(@other_cum,0.0),
				frozen_labor_cum   =isnull(@labor_cum,0.0),
				flag        =1,
				frozen_changed_date=getdate() 
			where	part=@part
			
			select @count = count(1) from #duplicate_parts where parentpart=@parent_part and part=@part
			if @count = 0 
			begin  
				insert into #duplicate_parts values ( @parent_part, @part )
				set rowcount 0 

				update	part_standard
				set	frozen_material_cum=frozen_material_cum + (isnull(@material_cum,0.0) * @bom_qty * @conversion),
					frozen_labor_cum   =frozen_labor_cum    + (isnull(@labor_cum,0.0) * @bom_qty * @conversion),
					frozen_burden_cum  =frozen_burden_cum   + (isnull(@burden_cum,0.0) * @bom_qty * @conversion),
					frozen_other_cum   =frozen_other_cum    + (isnull(@other_cum,0.0) * @bom_qty * @conversion)
				where	part=@parent_part
			end         
		end

		set rowcount 0 
		delete from #bom_parts_adnl where rowno = @rowno
		
		--	get next set of data 
		set rowcount 1  
		select	@rowno = rowno,
			@parent_part=parent_part,
			@part = part,
			@bom_qty = isnull(bom_qty,1),
			@bom_level = bom_level,
			@bom_uom = bom_uom
		from	#bom_parts_adnl
	end -- (3e)
	drop table #duplicate_parts
	set rowcount 0 
commit transaction  
end -- (1e)
go

print	'audit_trail_archive'

if exists (select * from sysobjects where name = 'audit_trail_archive')
	drop table audit_trail_archive
GO

CREATE TABLE audit_trail_archive (
	serial int NOT NULL ,
	date_stamp datetime NOT NULL ,
	type char (1) NOT NULL ,
	part varchar (25)  NOT NULL ,
	quantity numeric(20, 6) NOT NULL ,
	remarks varchar (10)  NOT NULL ,
	price numeric(20, 6) NULL ,
	salesman varchar (10)  NULL ,
	customer varchar (10)  NULL ,
	vendor varchar (10)  NULL ,
	po_number varchar (30)  NULL ,
	operator varchar (5)  NOT NULL ,
	from_loc varchar (10)  NULL ,
	to_loc varchar (10)  NULL ,
	on_hand numeric(20, 6) NULL ,
	lot varchar (20)  NULL ,
	weight numeric(20, 6) NULL ,
	status char (1)  NOT NULL ,
	shipper varchar (20)  NULL ,
	flag char (1)  NULL ,
	activity varchar (25)  NULL ,
	unit varchar (2)  NULL ,
	workorder varchar (10)  NULL ,
	std_quantity numeric(20, 6) NULL ,
	cost numeric(20, 6) NULL ,
	control_number varchar (254)  NULL ,
	custom1 varchar (50)  NULL ,
	custom2 varchar (50)  NULL ,
	custom3 varchar (50)  NULL ,
	custom4 varchar (50)  NULL ,
	custom5 varchar (50)  NULL ,
	plant varchar (10)  NULL ,
	invoice_number varchar (15)  NULL ,
	notes varchar (254)  NULL ,
	gl_account varchar (15)  NULL ,
	package_type varchar (20)  NULL ,
	suffix int NULL ,
	due_date datetime NULL ,
	group_no varchar (10)  NULL ,
	sales_order varchar (15)  NULL ,
	release_no varchar (15)  NULL ,
	dropship_shipper int NULL ,
	std_cost numeric(20, 6) NULL ,
	user_defined_status varchar (30)  NULL ,
	engineering_level varchar (10)  NULL ,
	posted char (1)  NULL ,
	parent_serial numeric(10, 0) NULL ,
	origin varchar (20)  NULL ,
	destination varchar (20)  NULL ,
	sequence int NULL ,
	object_type char (1)  NULL ,
	part_name varchar (254)  NULL ,
	start_date datetime NULL ,
	field1 varchar (10)  NULL ,
	field2 varchar (10)  NULL ,
	show_on_shipper char (1)  NULL ,
	tare_weight numeric(20, 6) NULL ,
	kanban_number varchar (6)  NULL ,
	dimension_qty_string varchar (50)  NULL ,
	dim_qty_string_other varchar (50)  NULL ,
	varying_dimension_code numeric(2, 0) NULL 
)
GO

print	'cdisp_archiveaudittrail'

if exists(select 1 from sysobjects where name = 'cdisp_archiveaudittrail')
	drop procedure cdisp_archiveaudittrail
go
create procedure cdisp_archiveaudittrail (@startdt datetime=null, @enddt datetime=null) as
begin
	--	Declarations
	declare	@sdate varchar(20),
		@edate varchar(20),
		@serial	integer,
		@datestamp datetime
		
	
	if @startdt is null 
		select	@startdt = getdate()
	if @enddt is null
		select	@enddt = getdate()
			
	select	@sdate = convert(varchar(10), @startdt, 102) + ' 00:00:00',
		@edate = convert(varchar(10), @enddt, 102) + ' 23:59:59'
	select	@startdt = convert(datetime, @sdate),
		@enddt = convert(datetime, @edate)

	if (select count(1) from sysobjects where name = 'audit_trail_archive') = 1
	begin
		begin tran

		declare	auditt cursor for
		select	serial, date_stamp
		from	audit_trail
		where	date_stamp >= @startdt 
			and date_stamp <= @enddt
		
		open	auditt
		
		fetch	auditt into @serial, @datestamp

		while	@@sqlstatus = 0 
		begin
			if (select count(1) from audit_trail where serial = @serial and date_stamp = @datestamp) = 0 
				insert	into audit_trail_archive
				select	* 
				from	audit_trail
				where	serial = @serial
					and date_stamp <= @datestamp
			
			fetch	auditt into @serial, @datestamp
		end	
		
		close	auditt
/*
		insert	into audit_trail_archive
		select	* 
		from	audit_trail
		where	date_stamp >= @startdt 
			and date_stamp <= @enddt
*/			
		delete	audit_trail
		where	date_stamp >= @startdt 
			and date_stamp <= @enddt
			
		commit tran
	end
	select 0
end
go

print 	'part_customer_tbp'

if exists ( select 1 from sysobjects where name = 'part_customer_tbp' ) 
	drop table part_customer_tbp
go
create table part_customer_tbp 
(	customer	varchar(10) not null,
	part	varchar(25) not null, 
	effect_date	datetime not null,
	price	numeric(20,6) null default 0,
	primary key (customer, part, effect_date))
go

print	'cdisp_updatetbprice'

if exists ( select 1 from sysobjects where name = 'cdisp_updatetbprice')
	drop procedure cdisp_updatetbprice
go
create procedure cdisp_updatetbprice as
begin
	declare	@cnt integer,
		@part	varchar(25),
		@customer varchar(10),
		@price	numeric(20,6)
	
	--	Count if any enteries are there for today
	select	@cnt = count(1)
	from	part_customer_tbp
	where	convert(varchar(10), effect_date,101) = convert(varchar(10), getdate(),101)
	
	if isnull(@cnt,0) > 0 
	begin
		begin tran
		--	Declare a cursor for the records from tbp table
		declare tbpcursor cursor for
		select	tbp.part, tbp.customer, tbp.price
		from	part_customer_tbp tbp
			join part_eecustom as p on p.part = tbp.part
		where	convert(varchar(10), tbp.effect_date,101) = convert(varchar(10), getdate(),101) and
			isnull(p.tb_pricing,'0') = '1' 
		
		--	Open cursor
		open	tbpcursor
		
		--	fetch data
		fetch	tbpcursor into @part, @customer, @price
		
		while @@sqlstatus = 0 
		begin
			--	Update sales order header
			update	order_header
			set	alternate_price = @price
			where	customer = @customer and 
				blanket_part = @part and
				isnull(status,'O') = 'O'

			--	Update sales order detail
			update	order_detail
			set	order_detail.alternate_price = @price
			from	order_detail
				join order_header on order_header.order_no = order_detail.order_no 
			where	order_detail.part_number = @part and
				order_header.customer = @customer and 
				isnull(order_header.status,'O') = 'O'

			--	Update part standard
			update	part_standard
			set	price = @price
			where	part = @part				

			--	Update part customer
			update	part_customer
			set	blanket_price = @price
			where	part = @part and
				customer = @customer

			--	Update part customer_price_matrix
			update	part_customer_price_matrix
			set	alternate_price = @price
			where	part = @part and
				customer = @customer and
				qty_break = 1

			--	fetch data
			fetch	tbpcursor into @part, @customer, @price
		end
		
		--	Close cursor
		close	tbpcursor
	
		commit tran
	end
end
go

insert into mdata values ( '0101','010101','TMI/Objects','N','N')
insert into mdata values ( '0101','010102','TMI/Audit Trail','N','N')
insert into mdata values ( '0101','010103','TMI/Parts','N','N')
insert into mdata values ( '0101','010104','TMI/Outside','N','N')
insert into mdata values ( '0101','010105','TMI/PhyInv','N','N')
insert into mdata values ( '0102','010201','TMO/Sales','N','N')
insert into mdata values ( '0102','010202','TMO/Glbl Ship','N','N')
insert into mdata values ( '0102','010203','TMO/Drop Ship','N','N')
insert into mdata values ( '0102','010204','TMO/Invoice','N','N')
insert into mdata values ( '0102','010205','TMO/EDI','N','N')
insert into mdata values ( '0102','010206','TMO/ASN','N','N')
insert into mdata values ( '0102','010207','TMO/EDI Parm','N','N')
insert into mdata values ( '0102','010208','TMO/Service','N','N')
insert into mdata values ( '0103','010301','TMP/P.O.Schdl','N','N')
insert into mdata values ( '0103','010302','TMP/P.O','N','N')
insert into mdata values ( '0103','010303','TMP/P.O.Inquiry','N','N')
insert into mdata values ( '0104','010401','TMP/Machine','N','N')
insert into mdata values ( '0104','010402','TMP/Production','N','N')
insert into mdata values ( '0104','010403','TMP/Reset','N','N')
insert into mdata values ( '0104','010404','TMP/Policy','N','N')
insert into mdata values ( '0104','010405','TMP/SoftQue','N','N')
insert into mdata values ( '0104','010406','TMP/Manual W.O','N','N')
insert into mdata values ( '0105','010501','TMS/Parms','N','N')
insert into mdata values ( '0105','010502','TMS/Parts','N','N')
insert into mdata values ( '0105','010503','TMS/Locations','N','N')
insert into mdata values ( '0105','010504','TMS/Customers','N','N')
insert into mdata values ( '0105','010505','TMS/Vendors','N','N')
insert into mdata values ( '0105','010506','TMS/Pricing','N','N')
insert into mdata values ( '0105','010507','TMS/Setups','N','N')
insert into mdata values ( '0105','010508','TMS/User','N','N')
go

update	admin set version = '4.6.20041231'
go

commit
go
