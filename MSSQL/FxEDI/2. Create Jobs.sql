USE [msdb]
GO

/****** Object:  Job [EDI: Receive and Send iConnect (Customer)]    Script Date: 6/13/2019 6:33:19 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 6/13/2019 6:33:19 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'EDI: Receive and Send iConnect (Customer)', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'FTSupport', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [FTP: Receive iConnect]    Script Date: 6/13/2019 6:33:20 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'FTP: Receive iConnect', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'set ansi_warnings on
go

exec FTP.usp_ReceiveCustomerEDI
go
', 
		@database_name=N'FxEDI', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Process Inbound Ford EDI]    Script Date: 6/13/2019 6:33:20 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Process Inbound Ford EDI', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [FXEDI].[EDIFord].[usp_Stage_1] 
   @TranDT OUTPUT
  ,@Result output
 commit Transaction
GO


DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [EDIFord].[usp_stage_2] 
   @TranDT OUTPUT
  ,@Result output
 commit Transaction
GO

DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int
DECLARE @Testing int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [EDIFord].[usp_Process] 
   @TranDT OUTPUT
  ,@Result OUTPUT
  ,0
 Commit Transaction
GO
', 
		@database_name=N'FxEDI', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Process Inbound Toyota EDI]    Script Date: 6/13/2019 6:33:20 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Process Inbound Toyota EDI', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [FXEDI].[EDIToyota].[usp_Stage_1] 
   @TranDT OUTPUT
  ,@Result output
 commit Transaction
GO


DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [EDItoyota].[usp_stage_2] 
   @TranDT OUTPUT
  ,@Result output
 commit Transaction
GO

DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int
DECLARE @Testing int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [EDItoyota].[usp_Process] 
   @TranDT OUTPUT
  ,@Result OUTPUT
  ,0
 Commit Transaction
GO
', 
		@database_name=N'FxEDI', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Process Inbound Chrysler EDI]    Script Date: 6/13/2019 6:33:20 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Process Inbound Chrysler EDI', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [FXEDI].[EDICHRY].[usp_Stage_1] 
   @TranDT OUTPUT
  ,@Result output
 commit Transaction
GO


DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [EDICHRY].[usp_stage_2] 
   @TranDT OUTPUT
  ,@Result output
 commit Transaction
GO

DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int
DECLARE @Testing int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [EDICHRY].[usp_Process] 
   @TranDT OUTPUT
  ,@Result OUTPUT
  ,0
 Commit Transaction
GO
', 
		@database_name=N'FxEDI', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Process Inbound 3010 ( Currently :TRW )]    Script Date: 6/13/2019 6:33:20 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Process Inbound 3010 ( Currently :TRW )', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [FXEDI].[EDI3010].[usp_Stage_1] 
   @TranDT OUTPUT
  ,@Result output
 commit Transaction
GO


DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [EDI3010].[usp_stage_2] 
   @TranDT OUTPUT
  ,@Result output
 commit Transaction
GO

DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int
DECLARE @Testing int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [EDI3010].[usp_Process] 
   @TranDT OUTPUT
  ,@Result OUTPUT
  ,0
 Commit Transaction
GO
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Process Inbound 4010 ( Currently : Cooper Std )]    Script Date: 6/13/2019 6:33:21 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Process Inbound 4010 ( Currently : Cooper Std )', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [FXEDI].[EDI4010].[usp_Stage_1] 
   @TranDT OUTPUT
  ,@Result output
 commit Transaction
GO


DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [EDI4010].[usp_stage_2] 
   @TranDT OUTPUT
  ,@Result output
 commit Transaction
GO

DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int
DECLARE @Testing int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [EDI4010].[usp_Process] 
   @TranDT OUTPUT
  ,@Result OUTPUT
  ,0
 Commit Transaction
GO
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Process Inbound 2003 (Dana)]    Script Date: 6/13/2019 6:33:21 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Process Inbound 2003 (Dana)', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [FXEDI].[EDI2003].[usp_Stage_1] 
   @TranDT OUTPUT
  ,@Result output
 commit Transaction
GO


DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [EDI2003].[usp_stage_2] 
   @TranDT OUTPUT
  ,@Result output
 commit Transaction
GO

DECLARE @RC int
DECLARE @TranDT datetime
DECLARE @Result int
DECLARE @Testing int

-- TODO: Set parameter values here.
Begin Transaction
EXECUTE @RC = [EDI2003].[usp_Process] 
   @TranDT OUTPUT
  ,@Result OUTPUT
  ,0
 Commit Transaction
GO
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Process Ship Notice Acknowledgements]    Script Date: 6/13/2019 6:33:21 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Process Ship Notice Acknowledgements', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = FxEDI.EDI_iConnect.usp_iConnectAck_Stage_1
	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult

if	@Error != 0 begin
	rollback
	return
end

execute
	@ProcReturn = FxEDI.EDI_iConnect.usp_ShipNotice997_Stage_1
	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult

if	@Error != 0 begin
	rollback
	return
end

execute
	@ProcReturn = FxAztec.EDI_iConnect.usp_Process
	@TranDT = @TranDT out
,	@Result = @ProcResult out
,	@Testing = 0

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult

if	@Error != 0 begin
	rollback
	return
end

if	@@trancount > 0 begin
	commit
end
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Generate and Send Oubound Documents]    Script Date: 6/13/2019 6:33:21 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Generate and Send Oubound Documents', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = EDI.usp_CustomerEDI_SendShipNotices
	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult

if	@Error != 0 begin
	rollback
	return
end

if	@@trancount > 0 begin
	commit
end
', 
		@database_name=N'FxAztec', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete old EDI Documents]    Script Date: 6/13/2019 6:33:22 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete old EDI Documents', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = FxEDI.EDI.usp_DeleteOldDocuments
	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult

if	@Error != 0 begin
	rollback
	return
end

if	@@trancount > 0 begin
	commit
end
', 
		@database_name=N'FxEDI', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 5 min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160531, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'9866ca00-7d37-4fea-8347-c4368e4f00fb'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

