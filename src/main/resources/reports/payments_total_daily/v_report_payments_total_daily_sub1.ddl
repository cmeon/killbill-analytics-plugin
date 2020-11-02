create or replace view v_report_payments_total_daily_sub1 as
select
  ac.tenant_record_id
, 'CAPTURE' as op
, ac.created_date::date as day
, ac.currency
, sum(ifnull(ac.amount, 0)) as count
from analytics_payment_captures ac
where 1=1
  and ac.payment_transaction_status = 'SUCCESS'
  and ac.report_group='default'
group by 1,2,3,4
union
select
  ap.tenant_record_id
, 'PURCHASE' as op
, ap.created_date::date as day
, ap.currency
, sum(ifnull(ap.amount, 0)) as count
from analytics_payment_purchases ap
where 1=1
  and ap.payment_transaction_status = 'SUCCESS'
  and ap.report_group='default'
group by 1,2,3,4
;
