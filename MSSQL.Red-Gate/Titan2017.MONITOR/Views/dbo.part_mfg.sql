SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create view [dbo].[part_mfg](part,
  mfg_lot_size,
  process_id,
  parts_per_cycle,
  parts_per_hour,
  cycle_unit,
  cycle_time,
  overlap_type,
  overlap_time,
  engineering_level,
  drawing_number,
  labor_code,
  gl_account_code,
  activity,
  setup_time,
  eng_effective_date)
  as select part_machine.part,
    part_machine.mfg_lot_size,
    part_machine.process_id,
    part_machine.parts_per_cycle,
    part_machine.parts_per_hour,
    part_machine.cycle_unit,
    part_machine.cycle_time,
    part_machine.overlap_type,
    part_machine.overlap_time,
    part.engineering_level,
    part.drawing_number,
    part_machine.labor_code,
    part.gl_account_code,
    part_machine.activity,
    part_machine.setup_time,
    part.eng_effective_date
    from part_machine,.part
    where part_machine.sequence=1
    and part_machine.part=part.part
GO
