

Create view vw_Top10ReadmissionRateByProvider as

with providerCounts 
as
(
Select ic.PRVDR_NUM,COUNT(ic.CLM_ID) as countClaims
FROM ip_claim ic
where segment = 1
group by ic.PRVDR_NUM
),


admissionCount as 
(Select PRVDR_NUM, COUNT(*) as adm from ip_claim
where segment = 1
-- and PRVDR_NUM  = '01006V'
group by PRVDR_NUM),

nextClaims as 
(Select PRVDR_NUM , clm_id, lead(clm_id) over (partition by PRVDR_NUM order by CLM_FROM_DT asc) readmit_clm_id,
CLM_FROM_DT , lead( clm_from_dt ,1) over (partition by PRVDR_NUM order by CLM_FROM_DT asc) as readmit_clm_date
from ip_claim 
where segment = 1
-- and  PRVDR_NUM  = '01006V'
)
-- select * from nextClaims
,

filterDates as
(Select *, JULIANDAY(readmit_clm_date) - JULIANDAY(clm_from_dt )  as C  from nextClaims
 where   JULIANDAY(readmit_clm_date) - JULIANDAY(clm_from_dt ) < 30
order by C desc)  ,
--Datediff not working

-- select * from filterDates

readmissionCount as 
(select PRVDR_NUM, count(*) as reAdm from filterDates
group by PRVDR_NUM)

select  a.PRVDR_NUM, cast(adm as decimal)  as Admit_Count,   Round(cast(reAdm as float)/ cast(adm as float) *100, 2) as ReAdmissionRate
from admissionCount a join readmissionCount r
where a.PRVDR_NUM = r.PRVDR_NUM
and Admit_count > 100
order by ReAdmissionRate DESC
limit 10;

--select * from filterDates;

