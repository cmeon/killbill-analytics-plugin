create or replace view v_report_payments_by_provider_sub2 as
select distinct plugin_name,ifnull(plugin_property_4,'unknown') as merchant_account,ifnull(plugin_property_5,'unknown') as payment_method,converted_currency,tenant_record_id from analytics_payment_auths where created_date > now() - interval '7' day
union
select distinct plugin_name,ifnull(plugin_property_4,'unknown') as merchant_account,ifnull(plugin_property_5,'unknown') as payment_method,converted_currency,tenant_record_id from analytics_payment_captures where created_date > now() - interval '7' day
union
select distinct plugin_name,ifnull(plugin_property_4,'unknown') as merchant_account,ifnull(plugin_property_5,'unknown') as payment_method,converted_currency,tenant_record_id from analytics_payment_chargebacks where created_date > now() - interval '7' day
union
select distinct plugin_name,ifnull(plugin_property_4,'unknown') as merchant_account,ifnull(plugin_property_5,'unknown') as payment_method,converted_currency,tenant_record_id from analytics_payment_credits where created_date > now() - interval '7' day
union
select distinct plugin_name,ifnull(plugin_property_4,'unknown') as merchant_account,ifnull(plugin_property_5,'unknown') as payment_method,converted_currency,tenant_record_id from analytics_payment_purchases where created_date > now() - interval '7' day
union
select distinct plugin_name,ifnull(plugin_property_4,'unknown') as merchant_account,ifnull(plugin_property_5,'unknown') as payment_method,converted_currency,tenant_record_id from analytics_payment_refunds where created_date > now() - interval '7' day
union
select distinct plugin_name,ifnull(plugin_property_4,'unknown') as merchant_account,ifnull(plugin_property_5,'unknown') as payment_method,converted_currency,tenant_record_id from analytics_payment_voids where created_date > now() - interval '7' day
;
