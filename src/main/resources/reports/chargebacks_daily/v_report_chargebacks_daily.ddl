create or replace view v_report_chargebacks_daily as
select
  ac.tenant_record_id
, ac.created_date::date as day
, ac.currency
, sum(ac.amount) as count
from
  analytics_payment_chargebacks ac
where 1=1
  and ac.report_group='default'
group by 1,2,3
;
