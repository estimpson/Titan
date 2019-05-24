SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[msp_bol_form](@bol_number integer)
as
begin
  begin transaction
  declare @bill_name varchar(50)
  create table #bol_form(
    bol_number integer null,
    customer varchar(25) null,
    notes varchar(254) null,
    freight_type varchar(30) null,
    aetc_number varchar(20) null,
    gross_weight decimal(20,6) null,
    pickup_carrier varchar(35) null,
    transfer_carrier varchar(35) null,
    pool_name varchar(50) null,
    pool_address_1 varchar(50) null,
    pool_address_2 varchar(50) null,
    pool_address_3 varchar(50) null,
    box_count integer null,
    package_type varchar(20) null,
    dest_name varchar(50) null,
    dest_address_1 varchar(50) null,
    dest_address_2 varchar(50) null,
    dest_address_3 varchar(50) null,
    bill_name varchar(50) null,
    bill_address_1 varchar(50) null,
    bill_address_2 varchar(50) null,
    bill_address_3 varchar(50) null,
    supplier_code varchar(20) null,
    )
  insert into #bol_form(bol_number,
    customer,
    notes,
    freight_type,
    aetc_number)
    select distinct bol_number,
      customer,
      notes,
      freight_type,
      aetc_number
      from bill_of_lading,shipper
      where bol_number=convert(integer,bill_of_lading_number)
      and bol_number=@bol_number
  update #bol_form set
    gross_weight
    =(select SUM(gross_weight)
      from shipper
      where convert(integer,bill_of_lading_number)=bol_number)
  update #bol_form set
    pickup_carrier
    =(select  name 
      from carrier,bill_of_lading
      where carrier.scac=bill_of_lading.scac_pickup
      and bill_of_lading.bol_number=#bol_form.bol_number)
  update #bol_form set
    transfer_carrier
    =(select  name 
      from carrier,bill_of_lading
      where carrier.scac=bill_of_lading.scac_transfer
      and bill_of_lading.bol_number=#bol_form.bol_number)
  update #bol_form set
    pool_name
    =(select  name 
      from destination,bill_of_lading
      where destination.destination=bill_of_lading.destination
      and bill_of_lading.bol_number=#bol_form.bol_number)
  update #bol_form set
    pool_address_1
    =(select address_1
      from destination,bill_of_lading
      where destination.destination=bill_of_lading.destination
      and bill_of_lading.bol_number=#bol_form.bol_number)
  update #bol_form set
    pool_address_2
    =(select address_2
      from destination,bill_of_lading
      where destination.destination=bill_of_lading.destination
      and bill_of_lading.bol_number=#bol_form.bol_number)
  update #bol_form set
    pool_address_3
    =(select address_3
      from destination,bill_of_lading
      where destination.destination=bill_of_lading.destination
      and bill_of_lading.bol_number=#bol_form.bol_number)
  update #bol_form set
    box_count
    =(select  COUNT (serial)
      from object,shipper
      where shipper=id
      and parent_serial is null
      and convert(integer,bill_of_lading_number)=bol_number)
  update #bol_form set
    package_type
    =(select  MAX (package_type)
      from object,shipper
      where shipper=id
      and parent_serial is null
      and convert(integer,bill_of_lading_number)=bol_number)
  update #bol_form set
    dest_name
    =(select  MAX ( name )
      from destination,shipper
      where destination.destination=shipper.destination
      and convert(integer,bill_of_lading_number)=bol_number)
  update #bol_form set
    dest_address_1
    =(select  MAX (address_1)
      from destination,shipper
      where destination.destination=shipper.destination
      and convert(integer,bill_of_lading_number)=bol_number)
  update #bol_form set
    dest_address_2
    =(select  MAX (address_2)
      from destination,shipper
      where destination.destination=shipper.destination
      and convert(integer,bill_of_lading_number)=bol_number)
  update #bol_form set
    dest_address_3
    =(select  MAX (address_3)
      from destination,shipper
      where destination.destination=shipper.destination
      and convert(integer,bill_of_lading_number)=bol_number)
  update #bol_form set
    bill_name
    =(select  MAX ( name )
      from customer,destination_shipping,shipper
      where customer.customer=note_for_bol
      and destination_shipping.destination=shipper.destination
      and convert(integer,bill_of_lading_number)=bol_number)
  update #bol_form set
    bill_address_1
    =(select  MAX (address_1)
      from customer,destination_shipping,shipper
      where customer.customer=note_for_bol
      and destination_shipping.destination=shipper.destination
      and convert(integer,bill_of_lading_number)=bol_number)
  update #bol_form set
    bill_address_2
    =(select  MAX (address_2)
      from customer,destination_shipping,shipper
      where customer.customer=note_for_bol
      and destination_shipping.destination=shipper.destination
      and convert(integer,bill_of_lading_number)=bol_number)
  update #bol_form set
    bill_address_3
    =(select  MAX (address_3)
      from customer,destination_shipping,shipper
      where customer.customer=note_for_bol
      and destination_shipping.destination=shipper.destination
      and convert(integer,bill_of_lading_number)=bol_number)
  update #bol_form set
    supplier_code
    =(select  Max (supplier_code)
      from edi_setups,shipper
      where edi_setups.destination=shipper.destination
      and convert(integer,bill_of_lading_number)=@bol_number)
  select @bill_name=bill_name
    from #bol_form
  if @bill_name>''
    update #bol_form set
      pool_name=dest_name
  select #bol_form.bol_number,
    #bol_form.customer,
    #bol_form.notes,#bol_form.freight_type,#bol_form.aetc_number,
    #bol_form.gross_weight,
    #bol_form.pickup_carrier,
    #bol_form.transfer_carrier,#bol_form.pool_name,
    #bol_form.pool_address_1,
    #bol_form.pool_address_2,
    #bol_form.pool_address_3,
    #bol_form.box_count,
    #bol_form.package_type,
    #bol_form.dest_name,
    #bol_form.dest_address_1,
    #bol_form.dest_address_2,
    #bol_form.dest_address_3,
    #bol_form.bill_name,
    #bol_form.bill_address_1,
    #bol_form.bill_address_2,#bol_form.bill_address_3,
    #bol_form.supplier_code
    from #bol_form
  commit transaction
end
GO
