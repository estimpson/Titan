alter table dbo.T_EmpRep_Temp add Part_qty as (quantity * std_quantity)
EXEC sp_addextendedproperty N'MS_DisplayControl', N'109', 'SCHEMA', N'dbo', 'TABLE', N'T_EmpRep_Temp', 'COLUMN', N'Part_qty'
EXEC sp_addextendedproperty N'MS_Format', N'', 'SCHEMA', N'dbo', 'TABLE', N'T_EmpRep_Temp', 'COLUMN', N'Part_qty'
EXEC sp_addextendedproperty N'MS_IMEMode', N'0', 'SCHEMA', N'dbo', 'TABLE', N'T_EmpRep_Temp', 'COLUMN', N'Part_qty'
go
create FUNCTION [dbo].[CurrentShipSchedules]
()
RETURNS @CurrentSS TABLE
(	RawDocumentGUID UNIQUEIDENTIFIER
,	ReleaseNo VARCHAR(50)
,	ShipToCode VARCHAR(15)
,	ShipFromCode VARCHAR(15)
,	ConsigneeCode VARCHAR(15)
,	CustomerPart VARCHAR(50)
,	CustomerPO VARCHAR(50)
,	CustomerModelYear VARCHAR(50)
,	NewDocument INT
)
AS
BEGIN
--- <Body>
	INSERT
		@CurrentSS
	SELECT DISTINCT
		RawDocumentGUID = ssh.RawDocumentGUID
	,	ReleaseNo =  COALESCE(ss.ReleaseNo,'')
	,	ShipToCode = ss.ShipToCode
	,	ShipFromCode = COALESCE(ss.ShipFromCode,'')
	,	ConsigneeCode = COALESCE(ss.ConsigneeCode,'')
	,	CustomerPart = ss.CustomerPart
	,	CustomerPO = COALESCE(ss.CustomerPO,'')
	,	CustomerModelYear = COALESCE(ss.CustomerModelYear,'')
	,	NewDocument =
			CASE
				WHEN ssh.Status = 0 --(select dbo.udf_StatusValue('dbo.ShipScheduleHeaders', 'Status', 'New'))
					THEN 1
				ELSE 0
			END
	FROM
		(	SELECT
				ShipToCode = ss.ShipToCode
			,	ShipFromCode = COALESCE(ss.ShipFromCode,'')
			,	ConsigneeCode = ''
			,	CustomerPart = ss.CustomerPart
			,	CustomerPO = ''
			,	CustomerModelYear = COALESCE(ss.CustomerModelYear,'')
			,	CheckLast = MAX
				(	  CONVERT(CHAR(20), ssh.DocumentImportDT, 120)
					+ CONVERT(CHAR(20), ssh.DocumentDT, 120)
					+ CONVERT(CHAR(10), ssh.DocNumber)
					+ CONVERT(CHAR(10), ssh.ControlNumber)
					
				)
			FROM
				dbo.ShipScheduleHeaders ssh
				JOIN dbo.ShipSchedules ss
					ON ss.RawDocumentGUID = ssh.RawDocumentGUID
			WHERE
				ssh.Status IN
				(	0 --(select dbo.udf_StatusValue('dbo.ShipScheduleHeaders', 'Status', 'New'))
				,	1 --(select dbo.udf_StatusValue('dbo.ShipScheduleHeaders', 'Status', 'Active'))
				)
			GROUP BY
				ss.ShipToCode
			,	COALESCE(ss.ShipFromCode,'')
			,	ss.CustomerPart
			,	COALESCE(ss.CustomerModelYear,'')
		) cl
		JOIN dbo.ShipScheduleHeaders ssh
			JOIN dbo.ShipSchedules ss
			ON ss.RawDocumentGUID = ssh.RawDocumentGUID
			ON ss.ShipToCode = cl.ShipToCode
			AND COALESCE(ss.ShipFromCode, '') = cl.ShipFromCode
			AND ss.CustomerPart = cl.CustomerPart
			AND COALESCE(ss.CustomerModelYear,'') = cl.CustomerModelYear
			AND	(	CONVERT(CHAR(20), ssh.DocumentImportDT, 120)
					+ CONVERT(CHAR(20), ssh.DocumentDT, 120)
					+ CONVERT(CHAR(10), ssh.DocNumber)
					+ CONVERT(CHAR(10), ssh.ControlNumber)
					
				) = cl.CheckLast
			LEFT JOIN
				dbo.BlanketOrders bo ON bo.EDIShipToCode = ss.ShipToCode
			WHERE  COALESCE(bo.ProcessShipSchedule,1) = 1
--- </Body>

---	<Return>
	RETURN
END
go

create FUNCTION [dbo].[CurrentPlanningReleases]
()
RETURNS @CurrentPlanningReleases TABLE
(	RawDocumentGUID UNIQUEIDENTIFIER
,	ReleaseNo VARCHAR(50)
,	ShipToCode VARCHAR(15)
,	ShipFromCode VARCHAR(15)
,	ConsigneeCode VARCHAR(15)
,	CustomerPart VARCHAR(50)
,	CustomerPO VARCHAR(50)
,	CustomerModelYear VARCHAR(50)
,	NewDocument INT
)
AS
BEGIN
--- <Body>
	INSERT
		@CurrentPlanningReleases
	SELECT DISTINCT
		RawDocumentGUID = ph.RawDocumentGUID
	,	ReleaseNo = COALESCE(pr.ReleaseNo,'')
	,	ShipToCode = pr.ShipToCode
	,	ShipFromCode = COALESCE(pr.ShipFromCode,'')
	,	ConsigneeCode = COALESCE(pr.ConsigneeCode,'')
	,	CustomerPart = pr.CustomerPart
	,	CustomerPO = COALESCE(pr.CustomerPO,'')
	,	CustomerModelYear =  COALESCE(pr.CustomerModelYear,'')
	,	NewDocument =
			CASE
				WHEN ph.Status = 0 --(select dbo.udf_StatusValue('dbo.PlanningHeaders', 'Status', 'New'))
					THEN 1
				ELSE 0
			END
	FROM
		(	SELECT
				ShipToCode = pr.ShipToCode
			,	ShipFromCode = COALESCE(pr.ShipFromCode,'')
			,	ConsigneeCode = ''
			,	CustomerPart = pr.CustomerPart
			,	CustomerPO = ''
			,	CustomerModelYear =  COALESCE(pr.CustomerModelYear,'')
			,	CheckLast = MAX
				(	  CONVERT(CHAR(20), ph.DocumentImportDT, 120)
					+ CONVERT(CHAR(20), ph.DocumentDT, 120)					
					+ CONVERT(CHAR(10), ph.DocNumber)
					+ CONVERT(CHAR(10), ph.ControlNumber)
					
				)
			FROM
				dbo.PlanningHeaders ph
				JOIN dbo.PlanningReleases pr
					ON pr.RawDocumentGUID = ph.RawDocumentGUID
			WHERE
				ph.Status IN
				(	0 --(select dbo.udf_StatusValue('dbo.PlanningHeaders', 'Status', 'New'))
				,	1 --(select dbo.udf_StatusValue('dbo.PlanningHeaders', 'Status', 'Active'))
				)
			GROUP BY
				pr.ShipToCode
			,	COALESCE(pr.ShipFromCode,'')
			,	pr.CustomerPart
			,	COALESCE(pr.CustomerModelYear,'')
		) cl
		JOIN dbo.PlanningHeaders ph
			JOIN dbo.PlanningReleases pr
				ON pr.RawDocumentGUID = ph.RawDocumentGUID
			ON 
						pr.ShipToCode = cl.ShipToCode
			AND COALESCE(pr.ShipFromCode, '') = cl.ShipFromCode
			AND pr.CustomerPart = cl.CustomerPart
			AND COALESCE(pr.CustomerModelYear,'') = cl.CustomerModelYear
			AND	(	CONVERT(CHAR(20), ph.DocumentImportDT, 120) 
						+ CONVERT(CHAR(20), ph.DocumentDT, 120)
						+ CONVERT(CHAR(10), ph.DocNumber)
					  + CONVERT(CHAR(10), ph.ControlNumber)
					
				) = cl.CheckLast
			LEFT JOIN
			dbo.BlanketOrders bo ON bo.EDIShipToCode = pr.ShipToCode
					WHERE COALESCE(bo.ProcessPlanningRelease,1) = 1
--- </Body>

---	<Return>
	RETURN
END
go

