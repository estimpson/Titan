if exists (select * from sysobjects where id = object_id('edi_830_AuTH2'))
        drop table edi_830_AuTH2
        
GO

CREATE TABLE edi_830_AuTH2 (
       release_no		varchar	(30) NULL,
       supplier		varchar	(30) NULL,
       ship_to 		varchar (30) NULL,
       customer_part 		varchar (30) NULL,
       ecl 			varchar (30) NULL,
       customer_po 		varchar (35) NULL,
       auth_type 		varchar (20) NULL,
       auth_date1		varchar (12) NULL,
       auth_qty1		varchar (12) NULL,
       auth_qty2	 	varchar (20) NULL,
       auth_date2 		varchar (12) NULL,
                 
)
GO



if exists (select * from sysobjects where id = object_id('edi_830_AuTH_history2'))
        drop table edi_830_AuTH_history2
        
GO

CREATE TABLE edi_830_AuTH_history2 (
        release_no		varchar	(30) NULL,
       supplier		varchar	(30) NULL,
       ship_to 		varchar (30) NULL,
       customer_part 		varchar (30) NULL,
       ecl 			varchar (30) NULL,
       customer_po 		varchar (35) NULL,
       auth_type 		varchar (20) NULL,
       auth_date1		varchar (12) NULL,
       auth_qty1		varchar (12) NULL,
       auth_qty2	 	varchar (20) NULL,
       auth_date2 		varchar (12) NULL,
                 
)
GO