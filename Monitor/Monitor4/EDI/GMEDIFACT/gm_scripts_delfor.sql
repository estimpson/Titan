

  if exists (select * from sysobjects where id = object_id('delfor_releases')) 
        drop table delfor_releases
go


CREATE TABLE delfor_releases  (
  release_number                varchar(35) NULL,
  ship_to_id                    varchar(35) NULL,
  buyer_part                    varchar(35) NULL,
  type1				varchar(35) NULL,
  model_year                    varchar(35) NULL,
  forecast_type                 varchar(35) NULL,
  quantity                      varchar(35) NULL,
  start_date                    varchar(35) NULL  )
go  
  if exists (select * from sysobjects where id = object_id('delfor_cums')) 
        drop table delfor_cums
go
CREATE TABLE delfor_cums  (
  release_number                varchar(35) NULL,
  ship_to_id                    varchar(35) NULL,
  buyer_part                    varchar(35) NULL,
  model_year                    varchar(35) NULL,
  fab_auth_qty                  varchar(35) NULL,
  fab_auth_start_dte            varchar(35) NULL,
  raw_auth_qty                  varchar(35) NULL,
  raw_auth_start_dte            varchar(35) NULL  )
go  
  if exists (select * from sysobjects where id = object_id('delfor_oh')) 
        drop table delfor_oh
go      
CREATE TABLE delfor_oh  (
  release_number                varchar(35) NULL,
  ship_to_id                    varchar(35) NULL,
  buyer_part                    varchar(35) NULL,
  model_year                    varchar(35) NULL,
  dock_code                     varchar(35) NULL,
  line_feed_code                varchar(35) NULL  )
go  
  if exists (select * from sysobjects where id = object_id('delfor_cytd')) 
        drop table delfor_cytd
go
CREATE TABLE delfor_cytd  (
  release_number                varchar(35) NULL,
  ship_to_id                    varchar(35) NULL,
  buyer_part                    varchar(35) NULL,
  model_year                    varchar(35) NULL,
  cytd_start_date                varchar(35) NULL,
  cytd_qty_shipped              varchar(35) NULL  )
