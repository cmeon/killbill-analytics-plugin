create or replace view v_report_overdue_states_count_daily as
select
  aat.tenant_record_id
, aat.state
, cal.d::date as day
, count(1) as count
from
  calendar cal
  join analytics_account_transitions aat on aat.start_date = cal.d
where 1=1
  and aat.report_group='default'
  and aat.service='overdue-service'
  and cal.d <= now()
group by 1,2,3
;
