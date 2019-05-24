use Monitor
go
alter table dbo.T_EmpRep_Temp drop column Part_qty
go
drop function dbo.CurrentShipSchedules
go
drop function dbo.CurrentPlanningReleases
go
