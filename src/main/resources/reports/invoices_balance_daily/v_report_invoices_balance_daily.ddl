create or replace view v_report_invoices_balance_daily as
select
  ai.tenant_record_id
, ai.created_date::date as day
, sum(ai.balance) as count
from
  analytics_invoices ai
where 1=1
  and ai.report_group='default'
group by 1,2
;