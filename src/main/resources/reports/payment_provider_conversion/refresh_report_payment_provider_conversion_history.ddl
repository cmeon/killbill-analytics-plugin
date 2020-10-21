create table report_payment_provider_conversion_history as select * from v_report_payment_provider_conversion limit 0;

drop procedure if exists refresh_report_payment_provider_conversion_history;

CREATE PROCEDURE refresh_report_payment_provider_conversion_history() LANGUAGE SQL AS $$
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
insert into report_payment_provider_conversion_history select * from v_report_payment_provider_conversion;

END $$;

