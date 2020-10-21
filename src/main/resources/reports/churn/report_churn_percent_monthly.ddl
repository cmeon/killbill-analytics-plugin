drop table if exists report_churn_percent_monthly;
create table if not exists report_churn_percent_monthly (tenant_record_id int, day date, term varchar(50), count decimal(5,4));
