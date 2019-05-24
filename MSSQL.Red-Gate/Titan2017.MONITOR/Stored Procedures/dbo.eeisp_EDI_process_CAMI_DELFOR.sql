SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[eeisp_EDI_process_CAMI_DELFOR]

as
BEGIN
BEGIN TRANSACTION
DELETE Log
COMMIT TRANSACTION

BEGIN TRANSACTION
Delete m_in_release_plan
COMMIT TRANSACTION

declare	@LastSchedule	varchar(80),
		@CurrentID		int

Select	@LastSchedule = rtrim(max(Relno)),
		@CurrentID = max(RelProcID)
from		edi_CAMIDELFOR_header
where	isNULL(nullif(Mapped,''), 'N') != 'Y'

Update	edi_CAMIDELFOR_Address
set		RelProcID = @CurrentID
where	RelProcID is NULL and
		rtrim(Relno) = @LastSchedule

Update	edi_CAMIDELFOR_Dock
set		RelProcID = @CurrentID
where	RelProcID is NULL and
		rtrim(Relno) = @LastSchedule

Update	edi_CAMIDELFOR_Detail
set		RelProcID = @CurrentID
where	RelProcID is NULL and
		rtrim(Relno) = @LastSchedule

Update	edi_CAMIDELFOR_PIA
set		RelProcID = @CurrentID
where	RelProcID is NULL and
		rtrim(Relno) = @LastSchedule


Create	table #orderstoupdate(
						OrderNo	integer,
						customerPart		varchar(25),
						destination		varchar(25))

Insert	#orderstoupdate (	
						OrderNo,
						customerPart,
						destination	)

Select	max(order_header.order_no),
		rtrim(CAMIPart),
		rtrim(ShipToID)
from		order_header
join		edi_setups	on	order_header.destination = edi_setups.destination
join		edi_CAMIDELFOR_Detail on COALESCE(edi_setups.parent_destination, edi_setups.destination) = rtrim(ShipToID) and order_header.customer_part = rtrim(CAMIPart) and rtrim(RelNo) =@LastSchedule and RelProcId =  @CurrentID
group	by	rtrim(CAMIPart),
		rtrim(ShipToID)

update	order_header
set		Dock_code= RTRIM(Dock),
		Line_feed_code = rtrim(LineFeed),
		Zone_code = rtrim(ReserveLineFeed)
FROM	order_header
JOIN		#orderstoupdate on order_header.order_no = #orderstoupdate.orderNo
JOIN		edi_CAMIDELFOR_Dock on	#orderstoupdate.customerPart = RTRIM(edi_CAMIDELFOR_Dock.CamiPart) 
WHERE	rtrim(RelNo) =@LastSchedule and RelProcId =  @CurrentID


Create table #DELFORSchedue (
							lineid	integer identity,
							customerpart		varchar (35),
							destination		varchar (20),
							customerPO		varchar	(20),
							modelYear		varchar	(4),
							ReleaseNumber	varchar(30),
							QtyQual			char(1),
							Qty				numeric(20,6),
							DateType			char(1),
							ReleaseDate		DATETIME,
							CustomerAccum	numeric (20,6))
							
BEGIN TRANSACTION
insert  #DELFORSchedue(			customerpart	,
							destination		,
							customerPO		,
							modelYear			,
							ReleaseNumber	,
							QtyQual				,
							Qty						,
							DateType			,
							ReleaseDate	,
							CustomerAccum		)
	select 	rtrim(edi_CAMIDELFOR_Detail.CAMIPart) as custpart,
			COALESCE( edi_setups.destination, edi_setups.parent_destination, 'NoShipTo'),
			rtrim(edi_CAMIDELFOR_Detail.CAMIOrderNo),
			rtrim(edi_CAMIDELFOR_Detail.ModelYear),
			rtrim(edi_CAMIDELFOR_Detail.Relno)+'*'+rtrim(edi_CAMIDELFOR_Detail.CAMIOrderNo),
			'N',
			convert(decimal(20,6),Qty),
			'S',
			convert(DATETIME,substring(rtrim(edi_CAMIDELFOR_Detail.DelDate),1,8)),
			0
	 FROM	edi_CAMIDELFOR_Detail
	join		edi_CAMIDELFOR_PIA on edi_CAMIDELFOR_Detail.CAMIPart = edi_CAMIDELFOR_PIA.CAMIPart   and  rtrim(edi_CAMIDELFOR_Detail.Relno) = @LastSchedule and edi_CAMIDELFOR_Detail.RelProcId =  @CurrentID and edi_CAMIDELFOR_PIA.RelProcId =  @CurrentID
	 LEFT OUTER JOIN edi_setups  ON  rtrim(edi_CAMIDELFOR_Detail.ShipToID) = COALESCE(edi_setups.parent_destination, edi_setups.destination) 
	Where	rtrim(PlanStatusInd) in ('1', '4')
	
           
COMMIT TRANSACTION 			

BEGIN TRANSACTION
insert m_in_release_plan (customer_part,
													shipto_id,
													customer_po,
													model_year,
													release_no,
													quantity_qualifier,
													quantity,
													release_dt_qualifier,
													release_dt)
	select 	customerpart,
			destination,
			customerPO,
			ModelYear,
			ReleaseNumber,
			QtyQual,
			Qty,
			DateType,
			ReleaseDate
	 FROM	 #DELFORSchedue
	 order by destination, customerpart, ReleaseDate       
COMMIT TRANSACTION


execute msp_process_in_release_plan

update	edi_CAMIDELFOR_header
set		mapped = 'Y'
where	rtrim(RelNo) = @LastSchedule and
		RelProcId =  @CurrentID

Select ' Processed CAMI DELFOR' +' ' + convert(varchar(25), getdate()) + ' For Release No ' + @LastSchedule
UNION
Select 'a: Updated Orders'
UNION
Select distinct 'a :'+ "message" from log where "message" like '%inserted%'
UNION
Select 'b: Exceptions'
UNION
Select distinct 'b:'+"message" from log where "message" like 'Blanket Order%'
UNION
Select distinct 'b:'+"message" from log where "message" like 'Inbound release plan does not exist%'
order by 1
END
GO
