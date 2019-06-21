
/*
Create View.FxDependencies.dbo.Sales.sql
*/

--use FxDependencies
--go

--drop table dbo.Sales
if	objectproperty(object_id('custom.Sales'), 'IsView') = 1 begin
	drop view custom.Sales
end
go

create view custom.Sales
as
select
	InvoiceDate = convert(datetime, convert(date, s.date_stamp))
,	InvoiceType = case when s.type is null then 'Normal' when s.type = 'M' then 'Manual' end
,	FreightAmount = sum(s.freight)
,	CurrencyUnit = max(s.currency_unit)
,	Part= sd.part_original
,	Quantity = sum(sd.qty_packed)
,	Price = sd.price
,	AlternatePrice = sd.alternate_price
,	TaxRate = coalesce(max
		(	case
				when c.custom1 not like '%[^.0-9]%'
					then convert(numeric(20,6), c.custom1)
			end
		) / 100, 0)
from
	dbo.shipper s
	join dbo.shipper_detail sd
		on sd.shipper = s.id
	join dbo.customer c
		on c.customer = s.customer
where
	s.status in ('C', 'Z')
	and
	(	s.type is null
		or s.type = 'M')
	and sd.part not like 'CUM_CHANGE%'
group by
	convert(datetime, convert(date, s.date_stamp))
,	s.type
,	sd.part_original
,	sd.price
,	sd.alternate_price
go

select
	s.InvoiceDate
,	s.InvoiceType
,	s.FreightAmount
,	s.CurrencyUnit
,	s.Part
,	s.Quantity
,	s.Price
,	s.AlternatePrice
,	s.TaxRate
from
	custom.Sales s
