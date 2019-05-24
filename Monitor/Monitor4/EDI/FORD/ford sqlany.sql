/****** Object:  Table fd5_830_releases    Script Date: 10/21/98 11:35:38 AM ******/

if exists (select * from sysobjects where id = object_id('fd5_830_releases'))
        drop table fd5_830_releases
        
GO

CREATE TABLE fd5_830_releases (
        release_number	varchar (30),	
        ship_to varchar (5) NULL ,
        ship_from	varchar(5) NULL,
        customer_part varchar (30) NULL ,
        customer_po varchar (30) NULL ,
        ecl varchar (30) NULL ,
        cum_qty varchar (30) NULL ,
        date_indicator varchar (30) NULL ,
        date1 varchar (30) NULL ,
        date2 varchar (30) NULL ,
        delivery_time varchar (30) NULL 
)
GO



/****** Object:  Table fd5_830_fab_raw    Script Date: 10/21/98 11:35:38 AM ******/

        if exists (select * from sysobjects where id = object_id('fd5_830_fab_raw'))
        drop table fd5_830_fab_raw
        
GO

CREATE TABLE fd5_830_fab_raw (
        fab_date varchar (10) NULL ,
        fab_cum varchar (15) NULL ,
        fab_start_date varchar (10) NULL ,
        raw_date varchar (10) NULL ,
        raw_cum varchar (15) NULL ,
        raw_start_date varchar (10) NULL ,
        ship_to varchar (30) NULL ,
        customer_part varchar (30) NULL ,
        customer_po varchar (30) NULL ,
        ecl varchar (30) NULL 
)
GO



/****** Object:  Table fd5_830_oh_data    Script Date: 10/14/98 11:23:14 AM ******/

if exists (select * from sysobjects where id = object_id('fd5_830_oh_data'))
        drop table fd5_830_oh_data
        
GO

/****** Object:  Table fd5_830_oh_data    Script Date: 10/14/98 11:23:14 AM ******/
CREATE TABLE fd5_830_oh_data (
        ship_to varchar (5) NULL ,
        buyer varchar (5) NULL ,
        ship_from	varchar (5) NULL,
        bill_to varchar (5) NULL ,
        consignee varchar (5) NULL ,
        ford_part varchar (30) NULL ,
        ford_po varchar (30) NULL ,
        ecl varchar (30) NULL ,
        euro_fin_code varchar (30) NULL ,
        issue_date datetime NULL ,
        effective_date datetime NULL ,
        customer_order_no varchar (16) NULL ,
        part_status varchar (2) NULL ,
        expeditor varchar (35) NULL ,
        exp_phone varchar (21) NULL ,
        plant_dock varchar (35) NULL ,
        plant_dock_phone varchar (21) NULL ,
        note varchar (60) NULL 
)
GO




/****** Object:  Table ford862_container    Script Date: 11/13/98 5:25:04 PM ******/

        if exists (select * from sysobjects where id = object_id('ford862_container'))
        drop table ford862_container
GO

/****** Object:  Table ford862_descrepency    Script Date: 11/13/98 5:25:04 PM ******/

        if exists (select * from sysobjects where id = object_id('ford862_descrepency'))
        drop table ford862_descrepency
GO

/****** Object:  Table ford862_linefeed    Script Date: 11/13/98 5:25:04 PM ******/

        if exists (select * from sysobjects where id = object_id('ford862_linefeed'))
        drop table ford862_linefeed
GO

/****** Object:  Table ford862_ship_schedule    Script Date: 11/13/98 5:25:04 PM ******/

        if exists (select * from sysobjects where id = object_id('ford862_ship_schedule'))
        drop table ford862_ship_schedule
GO

/****** Object:  Table m_ford830_consignee    Script Date: 11/13/98 5:25:04 PM ******/

        if exists (select * from sysobjects where id = object_id('m_ford830_consignee'))
        drop table m_ford830_consignee
GO

/****** Object:  Table ford862_container    Script Date: 11/13/98 5:25:04 PM ******/
CREATE TABLE ford862_container (
        ship_to varchar (50) NULL ,
        ship_from varchar (50) NULL ,
        consignee varchar (50) NULL ,
        customer_part varchar (50) NULL ,
        std_pack varchar (50) NULL ,
        weight_per_thousand varchar (50) NULL ,
        container varchar (50) NULL 
)
GO

/****** Object:  m_ford830_consignee    Script Date: 11/13/98 5:25:04 PM ******/
CREATE TABLE m_ford830_consignee (
        ship_to varchar (50) NULL ,
        consignee varchar (50) NULL ,
        customer_part varchar (50) NULL,
        customer_po varchar (50) NULL	
        )
GO



/****** Object:  Table ford862_descrepency    Script Date: 11/13/98 5:25:05 PM ******/
CREATE TABLE ford862_descrepency (
        ship_to varchar (50) NULL ,
        ship_from varchar (50) NULL ,
        consignee varchar (50) NULL ,
        customer_part varchar (50) NULL ,
        quantity_qualifier varchar (50) NULL ,
        quantity varchar (50) NULL ,
        last_asn_date varchar (50) NULL ,
        last_shipper_id varchar (50) NULL 
)
GO

/****** Object:  Table ford862_linefeed    Script Date: 11/13/98 5:25:05 PM ******/
CREATE TABLE ford862_linefeed (
        ship_to varchar (50) NULL ,
        ship_from varchar (50) NULL ,
        consignee varchar (50) NULL ,
        customer_part varchar (50) NULL ,
        location_type varchar (50) NULL ,
        delivery_location varchar (50) NULL 
)
GO

/****** Object:  Table ford862_ship_schedule    Script Date: 11/13/98 5:25:05 PM ******/
CREATE TABLE ford862_ship_schedule (
        ship_to varchar (50) NULL ,
        ship_from varchar (50) NULL ,
        consignee varchar (50) NULL ,
        customer_part varchar (50) NULL ,
        quantity varchar (50) NULL ,
        ship_date varchar (50) NULL ,
        ship_time varchar (50) NULL 
)
GO


if exists (select * from sysobjects where id = object_id('msp_process_ford_862_ss'))
        drop procedure msp_process_ford_862_ss
go

if exists (select * from sysobjects where id = object_id('msp_insert_m_in_release_plan3'))
        drop procedure msp_insert_m_in_release_plan3
go

CREATE PROCEDURE msp_insert_m_in_release_plan3 
as
BEGIN
BEGIN TRANSACTION
Delete fd5_830_releases
COMMIT TRANSACTION
execute msp_process_in_release_plan
Select "message" from log
END
go

if exists (select * from sysobjects where id = object_id('msp_insert_m_in_release_planf'))
        drop procedure msp_insert_m_in_release_planf
go

CREATE PROCEDURE msp_insert_m_in_release_planf
as
BEGIN
BEGIN TRANSACTION
insert m_in_ship_schedule
        select  rtrim(customer_part),
                rtrim(ship_to),
                '',
                '',
                '',
                'A',
                convert(decimal(20,6),cum_qty),
                'S',
                convert(datetime, date1)
        from    fd5_830_releases, edi_setups
        where  rtrim(date_indicator) ='W' and 
                      edi_setups.release_flag = 'F' and
                      rtrim(ship_to) = edi_setups.destination

EXECUTE msp_process_in_ship_sched
COMMIT TRANSACTION 

END

go

if exists (select * from sysobjects where id = object_id('msp_insert_m_in_release_plan1'))
        drop procedure msp_insert_m_in_release_plan1
go

CREATE PROCEDURE msp_insert_m_in_release_plan1 
as
BEGIN
BEGIN TRANSACTION
insert m_in_release_plan
        select  rtrim(customer_part),
                rtrim(ship_to),
                '',
                '',
                '',
                'A',
                convert(decimal(20,6),cum_qty),
                'S',
                convert(datetime, date1)
        from    fd5_830_releases
        where   date_indicator ='W'

COMMIT TRANSACTION 
SELECT 1
END








