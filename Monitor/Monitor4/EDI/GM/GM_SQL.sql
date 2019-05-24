if exists (select * from sysobjects where id = object_id('m_gmv_862_ship_schedule'))
        drop table m_gmv_862_ship_schedule
        
        go
        
if exists (select * from sysobjects where id = object_id('m_gmv_862_label_data'))
        drop table m_gmv_862_label_data
        
        go
        
if exists (select * from sysobjects where id = object_id('m_gmv_862_line_feed'))
        drop table m_gmv_862_line_feed
        
        go
        
if exists (select * from sysobjects where id = object_id('m_gmv_830_firm'))
        drop table m_gmv_830_firm
        
        go
        
if exists (select * from sysobjects where id = object_id('m_gmv_830_planning'))
        drop table m_gmv_830_planning
        
        go
        
if exists (select * from sysobjects where id = object_id('m_gmc_830_releases'))
        drop table m_gmc_830_releases
        
        go
        
if exists (select * from sysobjects where id = object_id('m_gmc_862_ship_schedule'))
        drop table m_gmc_862_ship_schedule
        
        go
        
if exists (select * from sysobjects where id = object_id('m_gmc_862_label_data'))
        drop table m_gmc_862_label_data
        
        go
        
if exists (select * from sysobjects where id = object_id('m_gmc_862_line_feed_kanban'))
        drop table m_gmc_862_line_feed_kanban
        
        go       
        
                        
CREATE TABLE "DBA"."m_gmv_862_ship_schedule"
(
	"schedule_number"       	varchar(30) NULL,
	"release_number"        	varchar(30) NULL,
	"ship_to_type"  		varchar(2) NULL,
	"ship_to"       		varchar(17) NULL,
	"customer_part" 		varchar(30) NULL,
	"model_year"    		varchar(30) NULL,
	"qty"   			varchar(30) NULL,
	"ship_date"     		varchar(30) NULL
)
go
CREATE TABLE "DBA"."m_gmv_862_label_data"
(
	"ship_to_type"  		varchar(2) NULL,
	"ship_to"       		varchar(17) NULL,
	"customer_part" 		varchar(30) NULL,
	"model_year"    		varchar(30) NULL,
	"pack_char"     		varchar(2) NULL,
	"pack_code"     		varchar(7) NULL,
	"label_data"    		varchar(78) NULL
)
go
CREATE TABLE "DBA"."m_gmv_862_line_feed"
(
	"ship_to_type"  		varchar(2) NULL,
	"ship_to"       		varchar(17) NULL,
	"customer_part" 		varchar(30) NULL,
	"model_year"    		varchar(30) NULL,
	"dock_code"     		varchar(5) NULL,
	"line_feed"     		varchar(30) NULL,
	"stockman"      		varchar(35) NULL
)
go
CREATE TABLE "DBA"."m_gmv_830_firm"
(
	"release_number"        	varchar(3) NULL,
	"ship_to_type"  		varchar(2) NULL,
	"ship_to"       		varchar(17) NULL,
	"type"  			varchar(2) NULL,
	"customer_part" 		varchar(30) NULL,
	"firm_qty"      		varchar(12) NULL,
	"ship_date"     		varchar(6) NULL,
	"cum_ytd"		varchar(12)NULL
)
go
CREATE TABLE "DBA"."m_gmv_830_planning"
(
	"line_indicator"		varchar(2) NULL,
	"release_number"        	varchar(3) NULL,
	"ship_to_type"  		varchar(2) NULL,
	"ship_to"       		varchar(17) NULL,
	"type"  			varchar(2) NULL,
	"customer_part" 		varchar(30) NULL,
	"planning_qty"  		varchar(12) NULL,
	"ship_date"     		varchar(6) NULL,
	"cum_ytd"		varchar(12)NULL
)
go
CREATE TABLE "DBA"."m_gmc_830_releases"
(
	"release_number"        	varchar(3) NULL,
	"ship_to_type"  		varchar(2) NULL,
	"ship_to"       		varchar(9) NULL,
	"type"  			varchar(2) NULL,
	"customer_part" 		varchar(30) NULL,
	"qty"   			varchar(12) NULL,
	"identifier"    		varchar(1) NULL,
	"ship_date"     		varchar(6) NULL
)
go
CREATE TABLE "DBA"."m_gmc_862_ship_schedule"
(
	"schedule_number"       	varchar(25) NULL,
	"release_number"        	varchar(3) NULL,
	"ship_to_type"  		varchar(2) NULL,
	"ship_to"       		varchar(9) NULL,
	"type"  			varchar(2) NULL,
	"customer_part" 		varchar(30) NULL,
	"qty"   			varchar(12) NULL,
	"ship_date"     		varchar(6) NULL
)
go
CREATE TABLE "DBA"."m_gmc_862_label_data"
(
	"schedule_number"       	varchar(25) NULL,
	"release_number"        	varchar(3) NULL,
	"ship_to_type"  		varchar(2) NULL,
	"ship_to"       		varchar(9) NULL,
	"type"  			varchar(2) NULL,
	"customer_part" 		varchar(30) NULL,
	"label_line"    		varchar(3) NULL,
	"label_data"    		varchar(21) NULL
)
go
CREATE TABLE "DBA"."m_gmc_862_line_feed_kanban"
(
	"schedule_number"       	varchar(25) NULL,
	"release_number"        	varchar(3) NULL,
	"ship_to_type"  		varchar(2) NULL,
	"ship_to"       		varchar(9) NULL,
	"type"  			varchar(2) NULL,
	"customer_part" 		varchar(30) NULL,
	"dock_code"     		varchar(8) NULL,
	"line_feed"     		varchar(30) NULL,
	"beg_kanban"    		varchar(6) NULL,
	"end_kanban"    		varchar(6) NULL
)
