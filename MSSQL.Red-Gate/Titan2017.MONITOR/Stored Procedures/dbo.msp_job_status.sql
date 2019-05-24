SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[msp_job_status](@workorder varchar(10))
/*----------------------------------------------------------------------------------------------*/
/*      Procedure       : msp_job_status*/
/*      */
/*      Purporse        : To get the runtime (std, predicted, act, jobcomplete avg, downtime*/
/*                        defects, laborhours etc. */
/*                      */
/*      1. Declarations*/
/*      2. get the data for the current job/workorder*/
/*      3. return result set*/
/**/
/*      Development     : Harish Gubbi  9/17/99 Created*/
/**/
/*----------------------------------------------------------------------------------------------*/
as /*      1. Declarations*/
declare @std_runtime decimal(20,6),
@pre_runtime decimal(20,6),
@act_runtime decimal(20,6),
@partsperhour decimal(20,6),
@jobcomplete decimal(20,6),
@downtime decimal(20,6),
@defects decimal(20,6),
@laborhours decimal(20,6)
/*      2. get the max runtime for the current job*/
select @std_runtime=isnull( max (qty_required),0)/isnull(parts_per_hour,1),
  @pre_runtime=isnull( max (balance),0)/isnull(parts_per_hour,1),
  @act_runtime=sum(run_time),
  @jobcomplete=((sum(qty_completed)*100)/sum(qty_required))/ count (*),
  @downtime=isnull(sum(down_time),0),
  @defects=isnull(sum(quantity),0),
  @laborhours=isnull(sum(labor_hours),0)
  from workorder_detail left outer join
  downtime on downtime.job=@workorder left outer join
  defects on defects.work_order=@workorder left outer join
  shop_floor_time_log as stl on stl.work_order=@workorder
  where workorder=@workorder
  group by qty_required,balance,parts_per_hour
/*      3. return result set*/
select @std_runtime,@pre_runtime,@act_runtime,@jobcomplete,@downtime,@defects,@laborhours
-- Confirm whether, the workorder_detail table needs to be updated with the new runtime 
-- & machine table needs to updated with redraw = 'Y' for the current machine of the job

GO
