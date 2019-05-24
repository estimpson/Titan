SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[cdisp_pkginvreport] as
begin -- 1b
	begin tran
	--	Declare the required temp tables
	create table #pkgcodes 
		( code	varchar(20) not null,
		  name	varchar(25),
		  type	char(1),
		  returnable char(1),	
		  total	numeric(20,6))

	create table #partqty 
		( code	varchar(20) not null,	
		  part	varchar(25) not null,
		  qfull numeric(20,6),	
		  partial numeric(20,6))
		  
	--	Insert data into #pkgcodes temp table
	insert into #pkgcodes
	select	pm.code, 
		pm.name,
		pm.type,
		pm.returnable,
		sum(o.quantity) total
	from	package_materials pm
		join object o on o.part  = pm.code
	group by pm.code, pm.name, pm.type, pm.returnable
	order by pm.code

	--	Insert data into #partqty temp table
	insert into #partqty	
	select	pp.code,
		pp.part,
		(select	isnull(count(o1.part),0) 
		from	object o1
		where	o1.part = pp.part and
			o1.package_type = pp.code and
			o1.quantity >= pp.quantity) qfull,
		(select	isnull(count(o.serial),0) 
		from	object o
		where	o.part = pp.part and
			o.package_type = pp.code and
			o.quantity < pp.quantity) partial
	from	part_packaging pp
	where	pp.code in (select code from #pkgcodes ) 

	--	Display result set
	select	a.code, 
		c.name, 
		c.type,
		c.returnable,
		a.total, 
		sum(isnull(qfull,0)) fullqty, 
		sum(isnull(b.partial,0)) partialqty, 
		(a.total - (sum(isnull(qfull,0)) + sum(isnull(b.partial,0)))) emptyqty
	from	#pkgcodes a
		join #partqty b on b.code = a.code
		join package_materials c on c.code = a.code
	group by a.code, c.name, c.type, c.returnable, a.total	
	commit tran
	
end -- 1e
GO
