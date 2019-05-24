Select * From destination where name like '%Moda%'

update edi_setups set trading_partner_code = 'MODATEK', asn_overlay_group = 'MDK' where destination  = 'MODA1'

select * from shipper where destination = 'MODA1'

select * from customer where customer = 'MODA'