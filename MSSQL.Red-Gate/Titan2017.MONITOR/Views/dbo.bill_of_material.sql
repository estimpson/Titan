SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[bill_of_material]
    ( parent_part,
      part,
      type,
      quantity,
      unit_measure,
      reference_no,
      std_qty,
      substitute_part ) AS
  select bill_of_material_ec.parent_part,
         bill_of_material_ec.part,
         bill_of_material_ec.type,
         bill_of_material_ec.quantity * (1 + bill_of_material_ec.scrap_factor),
         bill_of_material_ec.unit_measure,
         bill_of_material_ec.reference_no,
         bill_of_material_ec.std_qty * (1 + bill_of_material_ec.scrap_factor),
         bill_of_material_ec.substitute_part         
    from bill_of_material_ec
   where ( bill_of_material_ec.start_datetime <= getdate() ) AND
         (bill_of_material_ec.end_datetime > getdate() OR
         bill_of_material_ec.end_datetime is null)


GO
