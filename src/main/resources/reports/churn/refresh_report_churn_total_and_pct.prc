drop procedure if exists refresh_report_churn_total_and_pct;

CREATE PROCEDURE refresh_report_churn_total_and_pct() LANGUAGE plpgsql AS $$
BEGIN

    -- Refresh Churn Dollars and Churn Percent for MONTHLY subscriptions
    create temporary table report_temp_churn_monthly_paid_bundles (index (bundle_id)) as
       select distinct
         tenant_record_id
       , bundle_id
       from
         analytics_invoice_items
       where 1=1
         and invoice_original_amount_charged >0
         and invoice_balance = 0
    ;

    create temporary table report_temp_churn_monthly_paid_bundles2 (index (bundle_id)) as
       select distinct
         tenant_record_id
       , bundle_id
       from
         analytics_invoice_items
       where 1=1
         and invoice_original_amount_charged >0
         and invoice_balance = 0
    ;

    create temporary table report_temp_churn_monthly_dollars_pct_monthly as
    select
      active_sub_dollar.tenant_record_id
    , active_sub_dollar.month
    , round(churn_dollar.amount) churn_dollars_monthly
    , round(churn_dollar.amount / active_sub_dollar.amount,4) churn_pct_monthly
    from (
    select
      ast.tenant_record_id
    , to_char(next_start_date, 'YYYY-MM-01')::date month
    , prev_billing_period
    , sum(converted_prev_price) amount
    from
      analytics_subscription_transitions ast
      join report_temp_churn_monthly_paid_bundles paid_bundles on ast.bundle_id = paid_bundles.bundle_id and ast.tenant_record_id = paid_bundles.tenant_record_id
    where 1=1
      and report_group='default'
      and next_service='entitlement-service'
      and event like 'STOP_ENTITLEMENT%'
      and  prev_billing_period in ('MONTHLY')
    group by 1,2,3
    ) churn_dollar join (
    select
      ast.tenant_record_id
    , cal.d month
    , next_billing_period
    , sum(converted_next_price) amount
    from
      analytics_subscription_transitions ast
      join calendar cal  on next_start_date < cal.d and (next_end_date > cal.d or next_end_date is null )  and (cal.d = to_char(cal.d, 'YYYY-MM-01')::date) and cal.d>='2013-01-01'::date and cal.d < sysdate()
      join report_temp_churn_monthly_paid_bundles2 paid_bundles on ast.bundle_id = paid_bundles.bundle_id and ast.tenant_record_id = paid_bundles.tenant_record_id
    where 1=1
      and report_group='default'
      and next_service='entitlement-service'
      and event not like 'STOP_ENTITLEMENT%'
      and next_billing_period in ('MONTHLY')
    group by 1,2,3
    ) active_sub_dollar on churn_dollar.month=active_sub_dollar.month and churn_dollar.prev_billing_period=active_sub_dollar.next_billing_period and churn_dollar.tenant_record_id=active_sub_dollar.tenant_record_id
    ;

    DELETE FROM report_churn_total_usd_monthly;
    DELETE FROM report_churn_percent_monthly;

    insert into report_churn_total_usd_monthly
    select
      tenant_record_id
    , month day
    , 'MONTHLY'
    , churn_dollars_monthly count
    from
      report_temp_churn_monthly_dollars_pct_monthly
    ;

    insert into report_churn_percent_monthly
    select
      tenant_record_id
    , month day
    , 'MONTHLY'
    , churn_pct_monthly count
    from
      report_temp_churn_monthly_dollars_pct_monthly
    ;

    -- Refresh Churn Dollars and Churn Percent for ANNUAL subscriptions
    create temporary table report_temp_churn_annual_paid_bundles (index (bundle_id)) as
       select distinct
         tenant_record_id
       , bundle_id
       from (
           select
             tenant_record_id
           , bundle_id
           from
             analytics_invoice_items
           where 1=1
             and invoice_original_amount_charged >0
             and invoice_balance = 0
           union
           select
             s.tenant_record_id
           , s.bundle_id
           from
             subscription_events se
             join subscriptions s on se.subscription_id = s.id and se.tenant_record_id = s.tenant_record_id
           where 1=1
             and user_type in ('MIGRATE_ENTITLEMENT')
       ) bundles
    ;


    create temporary table report_temp_churn_annual_paid_bundles2 (index (bundle_id)) as
       select distinct
         tenant_record_id
       , bundle_id
       , charged_through_date
       from (
           select
             tenant_record_id
           , bundle_id
           , end_date charged_through_date
           from
             analytics_invoice_items
           where 1=1
             and invoice_original_amount_charged >0
             and invoice_balance = 0
           union
           select
             s.tenant_record_id
           , s.bundle_id
           , effective_date charged_through_date
           from
             subscription_events se
             join subscriptions s on se.subscription_id = s.id and se.tenant_record_id = s.tenant_record_id
           where 1=1
             and user_type in ('MIGRATE_ENTITLEMENT')
         ) bundles
    ;

    create temporary table report_temp_churn_annual_dollars_pct_monthly as
    select
      churn_dollar.tenant_record_id
    , churn_dollar.month
    , churn_dollar.amount churn_dollars_annual
    , round(churn_dollar.amount /active_sub_dollar.amount,4) churn_pct_annual
    from (
    select
      ast.tenant_record_id
    , to_char(next_start_date, 'YYYY-MM-01') month
    , prev_billing_period
    , round(sum(converted_prev_price)) amount
    from
      analytics_subscription_transitions ast
      join report_temp_churn_annual_paid_bundles paid_bundles on ast.bundle_id = paid_bundles.bundle_id and ast.tenant_record_id = paid_bundles.tenant_record_id
    where 1=1
      and report_group='default'
      and next_service='entitlement-service'
      and event like 'STOP_ENTITLEMENT%'
      and prev_billing_period in ('ANNUAL')
    group by 1,2,3
    ) churn_dollar join (
    select
      ast.tenant_record_id
    , cal.d month
    , next_billing_period
    , round(sum(converted_next_price)) amount
    from
      analytics_subscription_transitions ast
      join calendar cal  on next_start_date < cal.d and (next_end_date > cal.d or next_end_date is null )  and (cal.d = to_date(cal.d, 'YYYY-MM-01')) and cal.d>='2013-01-01'::date and cal.d < sysdate()
      join report_temp_churn_annual_paid_bundles2 paid_bundles on ast.bundle_id = paid_bundles.bundle_id and ast.tenant_record_id = paid_bundles.tenant_record_id
    where 1=1
      and report_group='default'
      and next_service='entitlement-service'
      and event not like 'STOP_ENTITLEMENT%'
      and next_billing_period in ('ANNUAL')
      and extract(month from (charged_through_date + interval '1' day)) = extract(month from cal.d)
    group by 1,2,3
    ) active_sub_dollar on churn_dollar.month=active_sub_dollar.month and churn_dollar.prev_billing_period=active_sub_dollar.next_billing_period and churn_dollar.tenant_record_id=active_sub_dollar.tenant_record_id
    ;

    insert into report_churn_total_usd_monthly
    select
      tenant_record_id
    , month day
    , 'ANNUAL'
    , churn_dollars_annual count
    from
      report_temp_churn_annual_dollars_pct_monthly
    ;

    insert into report_churn_percent_monthly
    select
      tenant_record_id
    , month day
    , 'ANNUAL'
    , churn_pct_annual count
    from
      report_temp_churn_annual_dollars_pct_monthly
    ;


END $$;
