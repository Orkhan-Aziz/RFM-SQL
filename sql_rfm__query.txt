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
      ntile(4) over (order by rfm.Recency ) as R,
      ntile(4) over (order by rfm.Frequency ) as F,
      ntile(4) over (order by rfm.Monetary ) as M,
	  CONCAT(ntile(4) over (order by rfm.Recency ),
			ntile(4) over (order by rfm.Frequency  ),
			ntile(4) over (order by rfm.Monetary  )) RFM_Score from rfm
GO

select * from rfm_rank

GO

select * from rfm join rfm_rank 
on rfm_rank.CustomerID=rfm.CustomerID
where rfm.Frequency>0 and rfm.Monetary>0


------- labels prablemi var -----------

--1) Best Customers: 111 Ranking
select * from rfm join rfm_rank 
on rfm_rank.CustomerID=rfm.CustomerID  --frequency daha yuksek olanlar var
where rfm_rank.rfm_score = '111' and rfm.Frequency>0 and rfm.Monetary>0
order by rfm.Frequency desc

--2) High Spending New Customers: from 141 to 142
select * from rfm join rfm_rank 
on rfm_rank.CustomerID=rfm.CustomerID  
where rfm_rank.rfm_score in ('141','142') and rfm.Frequency>0 and rfm.Monetary>0
order by rfm.Monetary desc

--3) Lowest Spending: From 113 to 114 
select * from rfm join rfm_rank 
on rfm_rank.CustomerID=rfm.CustomerID  
where rfm_rank.rfm_score in ('113','114') and rfm.Frequency>0 and rfm.Monetary>0
order by rfm.Monetary

--4) Churned Best Customers: 411, 412, 421, 422
select * from rfm join rfm_rank 
on rfm_rank.CustomerID=rfm.CustomerID  
where rfm_rank.rfm_score in ('411','412','421','422') and rfm.Frequency>0 and rfm.Monetary>0
order by rfm.Recency desc