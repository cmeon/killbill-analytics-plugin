drop procedure if exists refresh_report_conversions_total_dollar_monthly;

CREATE PROCEDURE refresh_report_conversions_total_dollar_monthly() language plpgsql as $$
BEGIN

    DELETE FROM report_conversions_total_dollar_monthly;

    create temporary table report_temp_paid_bundles (index (bundle_id)) as
    select distinct
      tenant_record_id
    , bundle_id
    from
      analytics_invoice_items
    where 1=1
      and invoice_original_amount_charged > 0
      and invoice_balance = 0
    ;

    insert into report_conversions_total_dollar_monthly
    select
      ast.tenant_record_id
    , to_char(next_start_date, 'YYYY-MM-01')::date day
    , next_billing_period billing_period
    , round(sum(converted_next_price)) count
    from
      analytics_subscription_transitions ast
      join report_temp_paid_bundles paid_bundles on ast.bundle_id = paid_bundles.bundle_id and ast.tenant_record_id = paid_bundles.tenant_record_id
    where 1=1
      and report_group='default'
      and next_service='entitlement-service'
      and prev_phase='TRIAL'
      and next_phase!='TRIAL'
      and event not like 'STOP_ENTITLEMENT%'
    group by 1,2,3
    ;

END $$;