SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[cdivw_ford856_end_asn]
	(package_type, 
	row_count, 
	returncontainer, 
	po, 
	um,
	supplier_code,
	id)
as
SELECT 	audit_trail.package_type, 
	(select count(audit_trail.package_type) from audit_trail where shipper = convert(varchar(30),shipper.id) and audit_trail.package_type = package_materials.code) as row_count, 
	'RC' as returncontainer, 
	'NONE' as po, 
	'PC' as um,
	supplier_code,
	shipper.id
fROM	audit_trail, 
	package_materials, 
	shipper,
	edi_setups
WHERE 	( shipper.destination = edi_setups.destination ) and
	( audit_trail.package_type = package_materials.code ) and 
	( convert(varchar(30),shipper.id) = audit_trail.shipper ) and 
	( package_materials.returnable = 'Y' )  and
	audit_trail.type = 'S'	 
GO
