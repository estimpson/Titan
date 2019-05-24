
if exists (select * from sysobjects where id = object_id('textron_830_releases'))
        drop table textron_830_releases
        
GO

CREATE TABLE textron_830_releases (
        release_no		varchar (30) NULL,
        forecast_date	varchar (30) NULL,
        supplier		varchar (30) NULL,
        ship_to 		varchar (30) NULL,
        customer_part 	varchar (30) NULL,
        customer_po 		varchar (30) NULL,
        ecl 			varchar (35) NULL,
        model_year		varchar	(30) NULL,
       QTY0101 		varchar (3) NULL,
       QTY0102 		varchar (17) NULL,
       SCC01 		char (1) NULL,
       DTM0101 		varchar (3) NULL,
       DTM0102		varchar (8) NULL,
       RFF0102		varchar (35) NULL 
)
GO


if exists (select * from sysobjects where id = object_id('textron_830_releases_copy'))
        drop table textron_830_releases_copy
        
GO

CREATE TABLE textron_830_releases_copy (
        release_no		varchar (30) NULL,
        forecast_date		varchar (30) NULL,
        supplier		varchar (30) NULL,
        ship_to 		varchar (30) NULL,
        customer_part 	varchar (30) NULL,
        customer_po 		varchar (30) NULL,
        ecl 			varchar (35) NULL,
        model_year		varchar	(30) NULL,
       QTY0101 		varchar (3) NULL,
       QTY0102 		varchar (17) NULL,
       SCC01 		char (1) NULL,
       DTM0101 		varchar (3) NULL,
       DTM0102		varchar (8) NULL,
       RFF0102		varchar (35) NULL 
)
GO






if exists (select * from sysobjects where id = object_id('textron_830_oh_data'))
        drop table textron_830_oh_data
        
GO

CREATE TABLE textron_830_oh_data (
        release_no		varchar	(30) NULL,
        supplier		varchar	(30) NULL,
        ship_to 		varchar (30) NULL,
        customer_part 	varchar (30) NULL,
        ecl 			varchar (30) NULL,
        customer_po 		varchar (35) NULL,
        dock_REF_DK 		varchar (30) NULL,
        user_defined1 	varchar (30) NULL,
        user_defined2 	varchar (30) NULL,
        user_defined3 	varchar	(30) NULL 
)
GO


if exists (select * from sysobjects where id = object_id('textron_830_cum'))
        drop table textron_830_cum
        
GO

CREATE TABLE textron_830_cum (
        ship_to 		varchar (10) 	NULL,
        supplier		varchar (30)	NULL,
        customer_part 	varchar (30) 	NULL,
        customer_po		varchar (35) 	NULL,        
        customer_cum		decimal (20,6)	NULL
                
)
GO

if exists (select * from sysobjects where id = object_id('textron_830_notes'))
        drop table textron_830_notes
        
GO

CREATE TABLE textron_830_notes (
	supplier		varchar(30) 	NULL,
        	ship_to 		varchar (10) 	NULL,
        	customer_part 	varchar (30) 	NULL,
        	customer_po		varchar (35) 	NULL,        
        	notes		varchar (70)	NULL,
        	notes2		varchar(70)	NULL
                
)
GO












