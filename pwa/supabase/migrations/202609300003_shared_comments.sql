alter table public.couple_records
  drop constraint if exists couple_records_record_id_check;

alter table public.couple_records
  add constraint couple_records_record_id_check
  check (length(record_id) <= 100 and (
    record_id like 'memory:%'
    or record_id like 'together:%'
    or record_id like 'comment:%'
  ));
