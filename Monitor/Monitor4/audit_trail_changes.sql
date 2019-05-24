----------------------------------------------------------------------------------------------
--	NOTE
--	Please do the following before running the script
--	Make a back up of your database
--	If Monitor is interfaced with Empower accounting, the update trigger(s) on audit_trail
--	table will have to removed before running the script, otherwise it will give a problem
--	Make sure to save a copy of the update triggers being removed, so that you could load 
--	it back.
----------------------------------------------------------------------------------------------

alter table audit_trail modify origin varchar(20)
go
