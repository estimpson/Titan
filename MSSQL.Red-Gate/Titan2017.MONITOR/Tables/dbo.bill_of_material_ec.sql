CREATE TABLE [dbo].[bill_of_material_ec]
(
[parent_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[start_datetime] [datetime] NOT NULL,
[end_datetime] [datetime] NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[quantity] [numeric] (20, 6) NOT NULL,
[unit_measure] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[reference_no] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[std_qty] [numeric] (20, 6) NULL,
[scrap_factor] [numeric] (20, 6) NOT NULL,
[engineering_level] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[operator] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[substitute_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_changed] [datetime] NOT NULL,
[note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtr_bill_of_material_ec_d]
on [dbo].[bill_of_material_ec] for delete
as
begin
  declare @current_datetime datetime,
  @parent_part varchar(25),
  @part varchar(25),
  @start_datetime datetime,
  @end_datetime datetime,
  @type varchar(1),
  @quantity decimal(20,6),
  @unit_measure varchar(2),
  @reference_no varchar(50),
  @std_qty decimal(20,6),
  @scrap_factor decimal(20,6),
  @engineering_level varchar(10),
  @operator varchar(5),
  @substitute_part varchar(25),
  @note varchar(255)
  if @@rowcount>1
    rollback transaction
  else
    begin
      select @current_datetime=convert(datetime,convert(varchar(12),GetDate())+' '+convert(varchar(2),datepart(hh,GetDate()))+':'+convert(varchar(2),datepart(mi,GetDate()))+':'+convert(varchar(2),datepart(ss,dateadd(ss,-1,GetDate()))))
      select @parent_part=parent_part,
        @part=part,
        @start_datetime=start_datetime,
        @end_datetime=end_datetime,
        @type=type,
        @quantity=quantity,
        @unit_measure=unit_measure,
        @reference_no=reference_no,
        @std_qty=std_qty,
        @scrap_factor=scrap_factor,
        @engineering_level=engineering_level,
        @operator=operator,
        @substitute_part=substitute_part,
        @note=note
        from deleted
      if @start_datetime<=@current_datetime
        and @end_datetime<@current_datetime
        begin
          rollback transaction
        end
      else
        begin
          insert into bill_of_material_ec(parent_part,
            part,
            start_datetime,
            end_datetime,
            type,
            quantity,
            unit_measure,
            reference_no,
            std_qty,
            scrap_factor,
            engineering_level,
            operator,
            substitute_part,
            date_changed,
            note) values(
            @parent_part,
            @part,
            @start_datetime,
            @current_datetime,
            @type,
            @quantity,
            @unit_measure,
            @reference_no,
            @std_qty,
            @scrap_factor,
            @engineering_level,
            @operator,
            @substitute_part,
            @current_datetime,
            @note)
        end
    end
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger
[dbo].[mtr_bill_of_material_ec_i]
on [dbo].[bill_of_material_ec] for insert
as
begin
  declare @current_datetime datetime,
  @most_recient_start_datetime datetime,
  @new_end_datetime datetime,
  @parent_part varchar(25),
  @part varchar(25),
  @start_datetime datetime,
  @end_datetime datetime,
  @type varchar(1),
  @quantity decimal(20,6),
  @unit_measure varchar(2),
  @reference_no varchar(50),
  @std_qty decimal(20,6),
  @scrap_factor decimal(20,6),
  @engineering_level varchar(10),
  @operator varchar(5),
  @substitute_part varchar(25),
  @note varchar(255),
  @std_unit varchar(2),
  @unit_conversion decimal(20,14)
  if @@rowcount>1
    rollback transaction
  else
    begin
      select @current_datetime=convert(datetime,convert(varchar(12),GetDate())+' '+convert(varchar(2),datepart(hh,GetDate()))+':'+convert(varchar(2),datepart(mi,GetDate()))+':'+convert(varchar(2),datepart(ss,GetDate())))
      select @parent_part=parent_part,
        @part=part,
        @start_datetime=start_datetime,
        @end_datetime=end_datetime,
        @type=type,
        @quantity=quantity,
        @unit_measure=unit_measure,
        @reference_no=reference_no,
        @std_qty=std_qty,
        @scrap_factor=scrap_factor,
        @engineering_level=engineering_level,
        @operator=operator,
        @substitute_part=substitute_part,
        @note=note
        from inserted
      if @parent_part=@part
        begin
          rollback transaction
        end
      else
        begin
          select @std_unit = standard_unit
          from part_inventory
          where part = @part
          if isnull(@std_unit,'') > ''
          begin
            if @std_unit <> @unit_measure
            begin
            	select @unit_conversion = conversion
            	from unit_conversion uc,
            		 part_unit_conversion puc
            	where puc.part = @part and
            		  puc.code = uc.code and
            		  unit1 = @unit_measure and
            		  unit2 = @std_unit
            	if isnull(@unit_conversion,0) <> 0
          			update bill_of_material_ec set
          				std_qty = @unit_conversion * @quantity
          			where parent_part = @parent_part and
					part = @part and
          				start_datetime = @start_datetime
          		else
	          		update bill_of_material_ec set
	          			std_qty = @quantity
          			where parent_part = @parent_part and
					part = @part and
          				start_datetime = @start_datetime
          	end
          	else
          		update bill_of_material_ec set
          			std_qty = @quantity
     			where parent_part = @parent_part and
				part = @part and
     				start_datetime = @start_datetime
          end
          if @start_datetime=convert(datetime,'1980/01/01')
            select @start_datetime=@current_datetime
          execute msp_check_downline @@parent=@parent_part,@@child=@part
          if @start_datetime>@current_datetime
            begin
              select @most_recient_start_datetime=max(start_datetime)
                from bill_of_material_ec
                where parent_part=@parent_part
                and part=@part
                and start_datetime<@start_datetime
                and(end_datetime>@start_datetime
                or end_datetime is null)
              if @most_recient_start_datetime is not null
                begin
                  update bill_of_material_ec set
                    end_datetime=dateadd(ss,-1,@start_datetime),
                    date_changed=@current_datetime
                    where parent_part=@parent_part
                    and part=@part
                    and start_datetime=@most_recient_start_datetime
                end
              select @new_end_datetime=min(start_datetime)
                from bill_of_material_ec
                where parent_part=@parent_part
                and part=@part
                and start_datetime>@start_datetime
              if @new_end_datetime is not null
                begin
                  update bill_of_material_ec set
                    end_datetime=dateadd(ss,-1,@new_end_datetime),
                    date_changed=@current_datetime
                    where parent_part=@parent_part
                    and part=@part
                    and start_datetime=@start_datetime
                end
            end
          else
            begin
              select @most_recient_start_datetime=max(start_datetime)
                from bill_of_material_ec
                where parent_part=@parent_part
                and part=@part
                and start_datetime<@start_datetime
                and(end_datetime>@start_datetime
                or end_datetime is null)
              if @most_recient_start_datetime is not null
                begin
                  update bill_of_material_ec set
                    end_datetime=dateadd(ss,-1,@start_datetime),
                    date_changed=@current_datetime
                    where parent_part=@parent_part
                    and part=@part
                    and start_datetime=@most_recient_start_datetime
                end
              select @new_end_datetime=min(start_datetime)
                from bill_of_material_ec
                where parent_part=@parent_part
                and part=@part
                and start_datetime>@start_datetime
              if @new_end_datetime is not null
                begin
                  update bill_of_material_ec set
                    end_datetime=dateadd(ss,-1,@new_end_datetime),
                    date_changed=@current_datetime
                    where parent_part=@parent_part
                    and part=@part
                    and start_datetime=@start_datetime
                end
            end
        end
    end
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger
[dbo].[mtr_bill_of_material_ec_u]
on [dbo].[bill_of_material_ec] for update
as
begin
  declare @current_datetime datetime,
  @closest_start_datetime datetime,
  @return_code integer,
  @inserted_parent_part varchar(25),
  @inserted_part varchar(25),
  @inserted_start_datetime datetime,
  @inserted_end_datetime datetime,
  @inserted_type varchar(1),
  @inserted_quantity decimal(20,6),
  @inserted_unit_measure varchar(2),
  @inserted_reference_no varchar(50),
  @inserted_std_qty decimal(20,6),
  @inserted_scrap_factor decimal(20,6),
  @inserted_engineering_level varchar(10),
  @inserted_operator varchar(5),
  @inserted_substitute_part varchar(25),
  @inserted_note varchar(255),
  @deleted_parent_part varchar(25),
  @deleted_part varchar(25),
  @deleted_start_datetime datetime,
  @deleted_end_datetime datetime,
  @deleted_type varchar(1),
  @deleted_quantity decimal(20,6),
  @deleted_unit_measure varchar(2),
  @deleted_reference_no varchar(50),
  @deleted_std_qty decimal(20,6),
  @deleted_scrap_factor decimal(20,6),
  @deleted_engineering_level varchar(10),
  @deleted_operator varchar(5),
  @deleted_substitute_part varchar(25),
  @deleted_note varchar(255),
  @std_unit varchar(2),
  @unit_conversion decimal(20,14),
  @adjusted_std_qty decimal(20,6)
  if @@rowcount>1
    rollback transaction
  else
    begin
      select @current_datetime=convert(datetime,convert(varchar(12),GetDate())+' '+convert(varchar(2),datepart(hh,GetDate()))+':'+convert(varchar(2),datepart(mi,GetDate()))+':'+convert(varchar(2),datepart(ss,GetDate())))
      select @inserted_parent_part=parent_part,
        @inserted_part=part,
        @inserted_start_datetime=start_datetime,
        @inserted_end_datetime=end_datetime,
        @inserted_type=type,
        @inserted_quantity=quantity,
        @inserted_unit_measure=unit_measure,
        @inserted_reference_no=reference_no,
        @inserted_std_qty=std_qty,
        @inserted_scrap_factor=scrap_factor,
        @inserted_engineering_level=engineering_level,
        @inserted_operator=operator,
        @inserted_substitute_part=substitute_part,
        @inserted_note=note
        from inserted
      select @deleted_parent_part=parent_part,
        @deleted_part=part,
        @deleted_start_datetime=start_datetime,
        @deleted_end_datetime=end_datetime,
        @deleted_type=type,
        @deleted_quantity=quantity,
        @deleted_unit_measure=unit_measure,
        @deleted_reference_no=reference_no,
        @deleted_std_qty=std_qty,
        @deleted_scrap_factor=scrap_factor,
        @deleted_engineering_level=engineering_level,
        @deleted_operator=operator,
        @deleted_substitute_part=substitute_part,
        @deleted_note=note
        from deleted
      if not update ( std_qty )
      begin
      if @inserted_start_datetime<@current_datetime
        and @inserted_end_datetime<@current_datetime
        begin
          rollback transaction
        end
      else
        begin
          if update(quantity) or update(unit_measure)
            begin
	          select @std_unit = standard_unit
	          from part_inventory
	          where part = @inserted_part
	          if isnull(@std_unit,'') > ''
	          begin
	            if @std_unit <> @inserted_unit_measure
	            begin
	            	select @unit_conversion = conversion
	            	from unit_conversion uc,
	            		 part_unit_conversion puc
	            	where puc.part = @inserted_part and
	            		  puc.code = uc.code and
	            		  unit1 = @inserted_unit_measure and
	            		  unit2 = @std_unit
	            	if isnull(@unit_conversion,0) <> 0
	          			select @adjusted_std_qty = @unit_conversion * @inserted_quantity
	          		else
		          		select @adjusted_std_qty = @inserted_quantity
	          	end
	          	else
	          		select @adjusted_std_qty = @inserted_quantity
	          end
            end
			else
				select @adjusted_std_qty = @inserted_std_qty

          if update(end_datetime)
            begin
              select @closest_start_datetime=min(start_datetime)
                from bill_of_material_ec
                where parent_part=@inserted_parent_part
                and part=@inserted_parent_part
                and start_datetime>@inserted_start_datetime
              if @closest_start_datetime is not null
                begin
                  update bill_of_material_ec set
                    start_datetime=dateadd(ss,1,@inserted_end_datetime),
                    date_changed=@current_datetime
                    where parent_part=@inserted_parent_part
                    and part=@inserted_part
                    and start_datetime=@closest_start_datetime
                end
            end
          if @inserted_start_datetime<=@current_datetime
            and(@inserted_end_datetime>=@current_datetime or @inserted_end_datetime is null)
            begin
              update bill_of_material_ec set
                end_datetime=dateadd(ss,-1,@current_datetime),
                date_changed=@current_datetime,
                type=@deleted_type,
                quantity=@deleted_quantity,
                unit_measure=@deleted_unit_measure,
                reference_no=@deleted_reference_no,
                std_qty=@deleted_std_qty,
                scrap_factor=@deleted_scrap_factor,
                engineering_level=@deleted_engineering_level,
                operator=@deleted_operator,
                substitute_part=@deleted_substitute_part,
                note=@deleted_note
                where parent_part=@inserted_parent_part
                and part=@inserted_part
                and start_datetime=@inserted_start_datetime
              insert into bill_of_material_ec(parent_part,
                part,
                start_datetime,
                end_datetime,
                type,
                quantity,
                unit_measure,
                reference_no,
                std_qty,
                scrap_factor,
                engineering_level,
                operator,
                substitute_part,
                date_changed,
                note) values(
                @inserted_parent_part,
                @inserted_part,
                @current_datetime,
                @inserted_end_datetime,
                @inserted_type,
                @inserted_quantity,
                @inserted_unit_measure,
                @inserted_reference_no,
                @adjusted_std_qty,
                @inserted_scrap_factor,
                @inserted_engineering_level,
                @inserted_operator,
                @inserted_substitute_part,
                @current_datetime,
                @inserted_note)
            end
        end
      end
    end
end
GO
ALTER TABLE [dbo].[bill_of_material_ec] ADD CONSTRAINT [bill_of_material_ec_x] PRIMARY KEY CLUSTERED  ([parent_part], [part], [start_datetime]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
