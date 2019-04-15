alter table analytics_invoices add raw_balance numeric(10, 4) default 0 after currency;
alter table analytics_invoices add converted_raw_balance numeric(10, 4) default null after raw_balance;
alter table analytics_invoice_adjustments add raw_invoice_balance numeric(10, 4) default 0 after invoice_currency;
alter table analytics_invoice_adjustments add converted_raw_invoice_balance numeric(10, 4) default null after raw_invoice_balance;
alter table analytics_invoice_items add raw_invoice_balance numeric(10, 4) default 0 after invoice_currency;
alter table analytics_invoice_items add converted_raw_invoice_balance numeric(10, 4) default null after raw_invoice_balance;
alter table analytics_invoice_item_adjustments add raw_invoice_balance numeric(10, 4) default 0 after invoice_currency;
alter table analytics_invoice_item_adjustments add converted_raw_invoice_balance numeric(10, 4) default null after raw_invoice_balance;
alter table analytics_invoice_credits add raw_invoice_balance numeric(10, 4) default 0 after invoice_currency;
alter table analytics_invoice_credits add converted_raw_invoice_balance numeric(10, 4) default null after raw_invoice_balance;
