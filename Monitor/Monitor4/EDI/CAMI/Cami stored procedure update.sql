
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[eeisp_EDI_process_CAMI_DELJIT]

as
BEGIN
BEGIN TRANSACTION
DELETE Log
COMMIT TRANSACTION

BEGIN TRANSACTION
Delete m_in_ship_schedule
COMMIT TRANSACTION

declare    @LastSchedule    varchar(80),
        @CurrentID        int

Select    @LastSchedule = rtrim(max(Relno)),
        @CurrentID = max(RelProcID)
from        edi_CAMIDELJIT_header
where    isNULL(nullif(Mapped,''), 'N') != 'Y'

Update    edi_CAMIDELJIT_Address2
set        RelProcID = @CurrentID
where    RelProcID is NULL and
        rtrim(Relno) = @LastSchedule

Update    edi_CAMIDELJIT_Dock2
set        RelProcID = @CurrentID
where    RelProcID is NULL and
        rtrim(Relno) = @LastSchedule

Update    edi_CAMIDELJIT_Detail
set        RelProcID = @CurrentID
where    RelProcID is NULL and
        rtrim(Relno) = @LastSchedule

Update    edi_CAMIDELJIT_PIA
set        RelProcID = @CurrentID
where    RelProcID is NULL and
        rtrim(Relno) = @LastSchedule

Update    edi_CAMIDELJIT_RFF
set        RelProcID = @CurrentID
where    RelProcID is NULL and
        rtrim(Relno) = @LastSchedule



Create    table #orderstoupdate(
                        OrderNo    integer,
                        customerPart        varchar(25),
                        destination        varchar(25))

Insert    #orderstoupdate (    
                        OrderNo,
                        customerPart,
                        destination    )

Select    max(order_header.order_no),
        rtrim(CAMIPart),
        rtrim(ShipToID)
from        order_header
join        edi_setups    on    order_header.destination = edi_setups.destination
join        edi_CAMIDELJIT_Detail on COALESCE(edi_setups.parent_destination, edi_setups.destination) = rtrim(ShipToID) and order_header.customer_part = rtrim(CAMIPart) and rtrim(RelNo) =@LastSchedule and RelProcId =  @CurrentID
group    by    rtrim(CAMIPart),
        rtrim(ShipToID)

update    order_header
set        Dock_code= RTRIM(edi_CAMIDELJIT_Dock2.Location)            
FROM    order_header
JOIN        #orderstoupdate on order_header.order_no = #orderstoupdate.orderNo
JOIN        edi_CAMIDELJIT_Dock2 on    #orderstoupdate.customerPart = RTRIM(edi_CAMIDELJIT_Dock2.CamiPart) 
WHERE    rtrim(RelNo) =@LastSchedule and RelProcId =  @CurrentID and rtrim(LocType) = '11'

update    order_header
set        Line_feed_code= RTRIM(edi_CAMIDELJIT_Dock2.Location)
FROM    order_header
JOIN        #orderstoupdate on order_header.order_no = #orderstoupdate.orderNo
JOIN        edi_CAMIDELJIT_Dock2 on    #orderstoupdate.customerPart = RTRIM(edi_CAMIDELJIT_Dock2.CamiPart) 
WHERE    rtrim(RelNo) =@LastSchedule and RelProcId =  @CurrentID and rtrim(LocType) = '159'


Create table #DELJITSchedue (
                            lineid    integer identity,
                            customerpart        varchar (35),
                            destination        varchar (20),
                            customerPO        varchar    (20),
                            modelYear        varchar    (4),
                            ReleaseNumber    varchar(30),
                            QtyQual            char(1),
                            Qty                numeric(20,6),
                            DateType            char(1),
                            ReleaseDate        DATETIME,
                            CustomerAccum    numeric (20,6))
                            
BEGIN TRANSACTION
insert  #DELJITSchedue(            customerpart    ,
                            destination        ,
                            customerPO        ,
                            modelYear            ,
                            ReleaseNumber    ,
                            QtyQual                ,
                            Qty                        ,
                            DateType            ,
                            ReleaseDate    ,
                            CustomerAccum        )
    select     rtrim(edi_CAMIDELJIT_Detail.CAMIPart) as custpart,
            COALESCE(edi_setups.destination,edi_setups.parent_destination,  'NoShipTo'),
            rtrim(edi_CAMIDELJIT_rff.RFFItem),
            '',
            rtrim(isNull(edi_CAMIDELJIT_Detail.CAMIOrderNo,''))+'*'+rtrim(edi_CAMIDELJIT_Detail.Relno),
            'N',
            convert(decimal(20,6),Qty),
            'S',
            convert(DATETIME,substring(rtrim(edi_CAMIDELJIT_Detail.DelDate),1,8)),
            0
     FROM    edi_CAMIDELJit_Detail
    left join    edi_CAMIDELjit_address2 on edi_CAMIDELJit_Detail.Relno = edi_CAMIDELjit_address2.Relno and edi_CAMIDELjit_Detail.RelProcId = edi_CAMIDELjit_address2.RelProcId and edi_CAMIDELjit_address2.RelProcId =  @CurrentID 
    join        edi_CAMIDELjit_rff on edi_CAMIDELjit_Detail.CAMIPart = edi_CAMIDELjit_rff.CAMIPart   and  rtrim(edi_CAMIDELjit_Detail.Relno) = @LastSchedule and edi_CAMIDELjit_Detail.RelProcId =  @CurrentID and edi_CAMIDELJIT_rff.RelProcId =  @CurrentID and  edi_CAMIDELjit_rff.RelProcId =  @CurrentID 
    left join    edi_setups  ON  rtrim(edi_CAMIDELjit_address2.ShipToID) = COALESCE(edi_setups.parent_destination, edi_setups.destination) 
    Where    rtrim(PlanStatusInd) in ('1', '4', '13')
    
           
COMMIT TRANSACTION             

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
    select     customerpart,
            destination,
            customerPO,
            ModelYear,
            ReleaseNumber,
            QtyQual,
            Qty,
            DateType,
            ReleaseDate
     FROM     #DELJITSchedue
     order by destination, customerpart, ReleaseDate       
COMMIT TRANSACTION


execute msp_process_in_ship_sched

update    edi_CAMIDELJIT_header
set        mapped = 'Y'
where    rtrim(RelNo) = @LastSchedule and
        RelProcId =  @CurrentID

Select ' Processed CAMI DELJIT' +' ' + convert(varchar(25), getdate()) + ' For Release No ' + @LastSchedule
UNION
Select 'a: Updated Orders'
UNION
Select distinct 'a: '+ "message" from log where "message" like '%inserted%'
UNION
Select 'b: Exceptions'
UNION
Select distinct 'b:'+"message" from log where "message" like 'Blanket Order%'
UNION
Select distinct 'b:'+"message" from log where "message" like 'Inbound ship schedule plan does not exist%'
order by 1
END
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

