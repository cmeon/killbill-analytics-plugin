create table report_payments_total_daily as select * from v_report_payments_total_daily limit 0;

drop procedure if exists refresh_report_payments_total_daily;

CREATE PROCEDURE refresh_report_payments_total_daily() LANGUAGE SQL AS $$
BEGIN

-- DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
-- DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
  delete from report_payments_total_daily;
  insert into report_payments_total_daily select * from v_report_payments_total_daily;
COMMIT;

END $$;
