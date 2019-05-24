CREATE TABLE [dbo].[object]
(
[serial] [int] NOT NULL,
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[location] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_date] [datetime] NOT NULL,
[unit_measure] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[operator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[destination] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[station] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[origin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost] [numeric] (20, 6) NULL,
[weight] [numeric] (20, 6) NULL,
[parent_serial] [numeric] (10, 0) NULL,
[note] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [numeric] (20, 6) NULL,
[last_time] [datetime] NULL,
[date_due] [datetime] NULL,
[customer] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sequence] [int] NULL,
[shipper] [int] NULL,
[lot] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[name] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plant] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[start_date] [datetime] NULL,
[std_quantity] [numeric] (20, 6) NULL,
[package_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[field1] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[field2] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[show_on_shipper] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tare_weight] [numeric] (20, 6) NULL,
[suffix] [int] NULL,
[std_cost] [numeric] (20, 6) NULL,
[user_defined_status] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[workorder] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[engineering_level] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[kanban_number] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dimension_qty_string] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dim_qty_string_other] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[varying_dimension_code] [numeric] (2, 0) NULL,
[posted] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[mtr_object_i] ON [dbo].[object]
FOR INSERT
AS
BEGIN

	DECLARE	@update_shipper		int,
		@net_weight		numeric(20,6),
		@tare_weight		numeric(20,6),
		@type		varchar(1),
		@part		varchar(25),
		@package_type	varchar(25),
		@std_qty		numeric(20,6),
		@serial		int,
		@shipper		int,
		@weight		numeric(20,6),
		@count			int,
		@unit_weight		numeric(20,6),
		@calc_weight	numeric(20,6),
		@current_datetime	datetime,
		@eng_level		varchar(10),
		@dummy_date		datetime

/*	This trigger is only valid for single row inserts to object table	*/
/*	Get key values for the new object...	*/
	set rowcount 1
	SELECT	@current_datetime = GetDate ( ),
		@type = type,
		@part = part,
		@package_type = package_type,
		@std_qty = std_quantity,
		@serial = serial,
		@shipper = shipper, 
		@weight  = weight,
		@eng_level   = engineering_level
	FROM	inserted
	set rowcount 0

/*	Set the engineering revision level for the object based on 'Right Now'	*/
      IF Isnull(@eng_level, '') = ''
      BEGIN  
    	  SELECT	@eng_level = max(engineering_level)
	  FROM	effective_change_notice
	  WHERE	effective_date = (
			select Max ( a.effective_date )
			  from effective_change_notice a
			 where a.effective_date < @current_datetime AND
				 a.part = @part ) AND
		effective_change_notice.part = @part
	  UPDATE	object
	  SET		engineering_level = @eng_level
	  WHERE	serial = @serial
      END

/*	Set tare weight to zero, then adjust it to package weight if package type is valid	*/
	UPDATE	object
	   SET	tare_weight = 0
	 WHERE	serial = @serial

	UPDATE	object
	   SET	tare_weight = isnull(package_materials.weight,0)
	  FROM	package_materials
	 WHERE	serial = @serial AND
			code = @package_type

/*	If not a weighed item or a super object, calculate the object's net weight	*/
	IF IsNull ( @type, '' ) = '' -- is whether a pallet or normal object
	BEGIN
            -- next is whether weight is from scale or not
		IF IsNull ( (	SELECT	part_packaging.serial_type
				FROM	part_packaging
				WHERE	part = @part AND
							code = @package_type ), '(None)' ) = '(None)'
		BEGIN
			SELECT @unit_weight = IsNull ( unit_weight, 0 )
			FROM   part_inventory
			WHERE  part_inventory.part = @part
			select @calc_weight = @unit_weight * @std_qty
                  -- calculate weight only when weight column is null while inserting a new row 
			IF (@weight IS NULL)
				UPDATE 	object
				SET	 	object.weight = isnull(@calc_weight,0)
				WHERE  object.serial = @serial


		END

	END

	IF @shipper > 0
	begin
		execute msp_calc_shipper_weights @shipper

		update	object
		set	object.destination = shipper.destination
		from	shipper
		where	object.serial = @serial and
			shipper.id = object.shipper
	end

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[mtr_object_u] ON [dbo].[object]
FOR UPDATE
AS
BEGIN
-----------------------------------------------------------------------------------------------
--	Modifications	09/06/02, HGP	Commented out the object update st. to over come 
--					recurrsive trigger problem.
-----------------------------------------------------------------------------------------------

	DECLARE	@update_shipper		int,
		@net_weight		numeric(20,6),
		@tare_weight		numeric(20,6),
		@old_shipper		int,
		@type			varchar(1),
		@part			varchar(25),
		@package_type		varchar(25),
		@std_qty		numeric(20,6),
		@serial			int,
		@shipper		int,
		@weight			numeric(20,6),
		@calc_weight		numeric(20,6),
		@unit_weight		numeric(20,6)

	DECLARE	recs CURSOR FOR
		SELECT	type,
			part,
			package_type,
			std_quantity,
			serial,
			shipper,
			weight
		FROM	inserted

	OPEN recs

	FETCH recs INTO @type,
			@part,
			@package_type,
			@std_qty,
			@serial,
			@shipper,
                	@weight
	
	WHILE @@fetch_status = 0
	BEGIN

		SELECT	@old_shipper		= shipper
		FROM	deleted
		WHERE	serial = @serial
/*
		if Update ( shipper )
		begin
			if @shipper > 0
			begin
				update	object
				set	object.destination = shipper.destination
				from	shipper
				where	serial = @serial and
					object.shipper = shipper.id
			end
			else
				update	object
				set	destination = ''
				where	serial = @serial
		end
*/		
		IF @type IS NULL -- normal object or pallet 
		BEGIN
                  -- weight is from scale or not    
			IF IsNull ( (	SELECT	part_packaging.serial_type
					FROM	part_packaging
					WHERE	part = @part AND
						code = @package_type ), '(None)' ) = '(None)'
			BEGIN
                        -- calculate the weight only when the qty or std qty differs & deleted 
                        -- weight is same as the inserted wt. or when the inserted wt. is null 
				IF ( Update ( std_quantity ) or Update ( part ) ) and ( NOT Update ( weight ) or @weight IS NULL)
				BEGIN
					SELECT	@unit_weight = IsNull ( unit_weight, 0 )
					FROM	part_inventory
					WHERE	part_inventory.part = @part

					SELECT	@calc_weight = @unit_weight * @std_qty
/*
					UPDATE	object
					SET	object.weight = isnull(@calc_weight,0)
					WHERE	object.serial = @serial
*/					
				END

				SELECT @update_shipper = 1

			END

			ELSE

				SELECT @update_shipper = 1

			IF @shipper > 0 AND @update_shipper = 1

				IF @old_shipper > 0 AND Update ( shipper )
				BEGIN

					execute msp_calc_shipper_weights @shipper

					execute msp_calc_shipper_weights @old_shipper

				END
				ELSE

					execute msp_calc_shipper_weights @shipper

			ELSE IF @old_shipper > 0 AND @update_shipper = 1

				execute msp_calc_shipper_weights @old_shipper

		END
		ELSE

			IF Update ( package_type ) AND @shipper > 0
				execute msp_calc_shipper_weights @shipper

		FETCH recs INTO @type,
				@part,
				@package_type,
				@std_qty,
				@serial,
				@shipper,
				@weight

	END

	CLOSE recs

	DEALLOCATE recs

END
GO
ALTER TABLE [dbo].[object] ADD CONSTRAINT [PK_object] PRIMARY KEY CLUSTERED  ([serial]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [part] ON [dbo].[object] ([part]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [partpkgtype] ON [dbo].[object] ([part], [package_type]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_object_3] ON [dbo].[object] ([shipper]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [status_index] ON [dbo].[object] ([status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
