create or replace view v_report_invoice_adjustments_daily as
select
  aia.tenant_record_id
, aia.currency
, aia.created_date::date as day
, sum(aia.amount) as count
from
  analytics_invoice_adjustments aia
where 1=1
  and aia.report_group='default'
group by 1,2,3
;
