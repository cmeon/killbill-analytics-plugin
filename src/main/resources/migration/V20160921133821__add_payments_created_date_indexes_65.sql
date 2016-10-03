alter table analytics_payment_auths add index analytics_payment_auths_created_date (created_date);
alter table analytics_payment_captures add index analytics_payment_captures_created_date (created_date);
alter table analytics_payment_chargebacks add index analytics_payment_chargebacks_created_date (created_date);
alter table analytics_payment_credits add index analytics_payment_credits_created_date (created_date);
alter table analytics_payment_purchases add index analytics_payment_purchases_created_date (created_date);
alter table analytics_payment_refunds add index analytics_payment_refunds_created_date (created_date);
alter table analytics_payment_voids add index analytics_payment_voids_created_date (created_date);