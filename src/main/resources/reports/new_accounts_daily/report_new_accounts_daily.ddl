create table if not exists report_new_accounts_daily as select * from v_report_new_accounts_daily limit 0;

drop procedure if exists refresh_report_new_accounts_daily;

CREATE PROCEDURE refresh_report_new_accounts_daily() LANGUAGE SQL AS $$
BEGIN

-- DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
-- DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
  delete from report_new_accounts_daily;
  insert into report_new_accounts_daily select * from v_report_new_accounts_daily;
COMMIT;

END $$;

