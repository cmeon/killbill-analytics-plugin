drop table if exists report_churn_total_usd_monthly;
create table report_churn_total_usd_monthly (tenant_record_id int, day date, term varchar(50), count int);
