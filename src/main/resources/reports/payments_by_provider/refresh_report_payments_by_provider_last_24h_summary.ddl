create table report_payments_by_provider_last_24h_summary as select * from v_report_payments_by_provider_last_24h_summary limit 0;

drop procedure if exists refresh_report_payments_by_provider_last_24h_summary;

CREATE PROCEDURE refresh_report_payments_by_provider_last_24h_summary() LANGUAGE SQL AS $$
BEGIN

-- DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
-- DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
  delete from report_payments_by_provider_last_24h_summary;
  insert into report_payments_by_provider_last_24h_summary select * from v_report_payments_by_provider_last_24h_summary;
COMMIT;

END $$;
