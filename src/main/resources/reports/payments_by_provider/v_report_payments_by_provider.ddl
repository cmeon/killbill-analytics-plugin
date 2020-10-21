CREATE OR REPLACE VIEW v_report_payments_by_provider AS
SELECT
  t1.plugin_name,
  t1.merchant_account,
  t1.payment_method,
  t1.tenant_record_id,
  t2.timeframe,
  transaction_type,
  CASE WHEN t2.timeframe = 1 THEN
    'Last 30 days'
  WHEN t2.timeframe = 2 THEN
    'Last 7 days'
  WHEN t2.timeframe = 3 THEN
    'Last 24 hours'
  WHEN t2.timeframe = 4 THEN
    'Last 30 min'
  END AS period,
  sum(ifnull (total, 0)) AS total,
  sum(ifnull (failed, 0)) AS failed,
  sum(ifnull (pending, 0)) AS pending,
  sum(ifnull (good, 0)) AS good,
  CASE WHEN failed IS NOT NULL
    AND total IS NOT NULL THEN
    concat(round(((sum(failed) / sum(total)) * 100), 2), '%')
  ELSE
    '0%'
  END AS pct_failed,
  CASE WHEN failed IS NOT NULL
    AND total IS NOT NULL THEN
    concat(round(((sum(pending) / sum(total)) * 100), 2), '%')
  ELSE
    '0%'
  END AS pct_pending,
  CASE WHEN failed IS NOT NULL
    AND total IS NOT NULL THEN
    concat(round(((sum(good) / sum(total)) * 100), 2), '%')
  ELSE
    '0%'
  END AS pct_good,
  converted_amount,
  t1.converted_currency,
  CURRENT_DATE AS refresh_date
FROM
  v_report_payments_by_provider_sub2 t1
  LEFT OUTER JOIN v_report_payments_by_provider_sub1 v1 ON v1.plugin_name = t1.plugin_name
  AND v1.merchant_account = t1.merchant_account
  AND v1.payment_method = t1.payment_method
  AND v1.converted_currency = t1.converted_currency
  AND v1.tenant_record_id = t1.tenant_record_id
  INNER JOIN v_report_payments_by_provider_sub3 t2 ON v1.timeframe = t2.timeframe
GROUP BY
  plugin_name,
  merchant_account,
  payment_method,
  timeframe,
  transaction_type,
  converted_currency,
  tenant_record_id
ORDER BY
  tenant_record_id,
  merchant_account,
  payment_method,
  plugin_name,
  timeframe,
  transaction_type,
  converted_currency;

