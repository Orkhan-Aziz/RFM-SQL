USE MTP;
GO

drop view  if exists dbo.rfm
Go
create view rfm as
Select CustomerID,
datediff(DAY,MAX(Date), GETDATE()) as Recency,
count(BillNo) as Frequency,
SUM(Quantity*Price) AS Monetary 
from Basket_Market
where CustomerID is not null
Group by CustomerID
GO

select * from rfm 
GO

drop view  if exists dbo.rfm_rank
Go
create view rfm_rank as
Select rfm.CustomerID,
      ntile(4) over (order by rfm.Recency desc ) as R,
      ntile(4) over (order by rfm.Frequency ) as F,
      ntile(4) over (order by rfm.Monetary ) as M,
	  CONCAT(ntile(4) over (order by rfm.Recency desc ),
			ntile(4) over (order by rfm.Frequency  ),
			ntile(4) over (order by rfm.Monetary  )) RFM_Score from rfm
GO

select * from rfm_rank

GO

select * from rfm join rfm_rank 
on rfm_rank.CustomerID=rfm.CustomerID
where rfm.Frequency>0 and rfm.Monetary>0




--1) Best Customers: 111 Ranking
select * from rfm join rfm_rank 
on rfm_rank.CustomerID=rfm.CustomerID  --frequency daha yuksek olanlar var
where rfm.Frequency>0 and rfm.Monetary>0
order by rfm.Frequency desc

