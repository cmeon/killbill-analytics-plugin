drop procedure if exists create_calendar;

create procedure create_calendar(calendar_from date, calendar_to date)
language plpgsql
as $$
declare d date;
begin
  d := calendar_from;

  drop table if exists calendar;
  create table calendar(d date primary key);
  while d <= calendar_to LOOP
    insert into calendar(d) values (d);
    d := d + interval '1' day;
  end LOOP;
end $$;

call create_calendar((now() - interval '5' year)::date, (now() + interval '10' year)::date);
