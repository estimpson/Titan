SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[sp_EDI_process_GMBFT_DELJIT]

as
BEGIN
BEGIN TRANSACTION
DELETE Log
COMMIT TRANSACTION

BEGIN TRANSACTION
Delete m_in_ship_schedule
COMMIT TRANSACTION

declare @PCIData table (

Destination varchar(25),
CustomerPart varchar(25),
PCI0201 varchar(50),
PCI0401 varchar(50) )

Insert @PCIData

Select 
	'T'+ rtrim(nad02),
	rtrim(LIN0301),
	rtrim(PCI0201),
	rtrim(PCI0401)
From
	GM_BFT_DELJIT_PCI_GIN


declare @LOCData table (

Destination varchar(25),
CustomerPart varchar(25),
LOC0201 varchar(50),
LOC0202 varchar(50),
LOC0203 varchar(50) )

Insert @LOCData

Select 
	'T'+ rtrim(nad02),
	rtrim(LIN0301),
	rtrim(LOC0201_1),
	rtrim(LOC0201_2),
	rtrim(LOC0201_3)
From
	GM_BFT_DELJIT_LOC


declare @AccumData table (
CustomerPart	varchar(50),
Destination		varchar(50),
AccumQty		Int)

Insert @AccumData

Select 
	rtrim(ac.LIN0301),
	'T'+ rtrim(ac.nad02),
	convert(int,ac.qty0102) as CustomerAccum
From
	gm_bft_deljit_cytd Ac


declare @JITData table 
(
RowID int Identity (1,1),
CustomerPart	varchar(50),
Destination		varchar(50),
CustomerPO		varchar(50),
ModelYear		varchar(50),
ReleaseNumber	varchar(50),
QtyQual			varchar(50),
Qty				Int,
DateType		varchar(50),
ReleaseDate		datetime )

Insert @JITData

Select 
	rtrim(SS.LIN0301),
	'T'+ rtrim(SS.nad02),
	'',
	'',
	rtrim(SS.BGM02),
	'A',
	convert(int,ss.QTY0102),
	'S',
	convert(DATETIME,substring(SS.DTM0102,1,8) + ' '+ substring(SS.DTM0102,9,2) + ':' + substring(SS.DTM0102,11,2) ) as reldate
From
	GM_BFT_DELJIT_SHIP_SCHED SS
	
order by 
	'T'+ rtrim(SS.nad02),
	rtrim(SS.LIN0301),
	convert(DATETIME,substring(SS.DTM0102,1,8) + ' '+ substring(SS.DTM0102,9,2) + ':' + substring(SS.DTM0102,11,2) )
	
	




update	order_header
set		line11= PCI0201
FROM	order_header
JOIN	@PCIData PCI on order_header.customer_part = PCI.CustomerPart  and order_header.destination =  PCI.Destination
Where   PCI0401 =  '11Z'


update	order_header
set		line12= PCI0201
FROM	order_header
JOIN	@PCIData PCI on order_header.customer_part = PCI.CustomerPart  and order_header.destination =  PCI.Destination
Where   PCI0401 =  '12Z'

update	order_header
set		line13= PCI0201
FROM	order_header
JOIN	@PCIData PCI on order_header.customer_part = PCI.CustomerPart  and order_header.destination =  PCI.Destination
Where   PCI0401 =  '13Z'


update	order_header
set		line14= PCI0201
FROM	order_header
JOIN	@PCIData PCI on order_header.customer_part = PCI.CustomerPart  and order_header.destination =  PCI.Destination
Where   PCI0401 =  '14Z'

update	order_header
set		line15= PCI0201
FROM	order_header
JOIN	@PCIData PCI on order_header.customer_part = PCI.CustomerPart  and order_header.destination =  PCI.Destination
Where   PCI0401 =  '15Z'

update	order_header
set		line16= PCI0201
FROM	order_header
JOIN	@PCIData PCI on order_header.customer_part = PCI.CustomerPart  and order_header.destination =  PCI.Destination
Where   PCI0401 =  '16Z'


update	order_header
set		line17= PCI0201
FROM	order_header
JOIN	@PCIData PCI on order_header.customer_part = PCI.CustomerPart  and order_header.destination =  PCI.Destination
Where   PCI0401 =  '17Z'

update	order_header
set		dock_code = RTRIM(LOC0201),
		zone_code = RTRIM(LOC0203),
		line_feed_code = RTRIM(LOC0202)
FROM	order_header
JOIN	@LOCData LOC on order_header.customer_part = LOC.CustomerPart  and order_header.destination =  LOC.Destination

			

BEGIN TRANSACTION
insert m_in_ship_schedule (customer_part,
													shipto_id,
													customer_po,
													model_year,
													release_no,
													quantity_qualifier,
													quantity,
													release_dt_qualifier,
													release_dt)
	select 	jd.customerpart,
			jd.destination,
			customerPO,
			ModelYear,
			left(convert(varchar(25),jd.releaseDate),19) +  ' : ' + jd.ReleaseNumber,
			QtyQual,
			(Select sum(JD2.Qty) from	@JITData JD2 
				where JD2.customerPart =	JD.customerPart and 
							JD2.destination =	JD.destination  and 
							JD2.RowID <=JD.RowID) + coalesce(AccumQty, 0),
			DateType,
			ReleaseDate
	 FROM	@JITData JD
	 LEFT JOIN
			@AccumData AD on JD.CustomerPart = AD.CustomerPart and JD.Destination = AD.Destination
	 order by JD.destination, JD.customerpart, ReleaseDate       
COMMIT TRANSACTION

--Select * From m_in_ship_schedule

execute msp_process_in_ship_sched

delete	gm_bft_deljit_cytd   
delete	gm_bft_deljit_loc   
delete	gm_bft_deljit_nad
delete	gm_bft_deljit_partlist 
delete	gm_bft_deljit_pci_gin 
delete	gm_bft_deljit_pia 
delete	gm_bft_deljit_rff
delete	gm_bft_deljit_ship_sched

Select ' Processed GM DELJIT' +' ' + convert(varchar(25), getdate())
UNION
Select 'a: Updated Orders'
UNION
Select distinct 'a:'+substring("message",1,patindex('%release date%',"message" )-3) from log where "message" like '%inserted%'
UNION
Select 'b: Exceptions'
UNION
Select distinct 'b:'+"message" from log where "message" like 'Blanket Order%'
UNION
Select distinct 'b:'+"message" from log where "message" like 'Inbound release plan does not exist%'
order by 1
END


GO
