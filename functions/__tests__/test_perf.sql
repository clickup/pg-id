\ir ./begin.sql

CREATE OR REPLACE FUNCTION test_perf(num integer = 200000) RETURNS void
LANGUAGE plpgsql
SET search_path FROM CURRENT
AS $$
DECLARE
  v integer;
  ts timestamptz;
BEGIN
  ts := clock_timestamp();
  SELECT count(DISTINCT id_gen_uuid()) FROM generate_series(1, num) INTO v;
  IF v <> num THEN
    RAISE EXCEPTION 'Invalid number of id_gen_uuid() distinct values: % (expected %)', v, num;
  END IF;
  RAISE NOTICE 'id_gen_uuid(): % reqs/s', round(v / EXTRACT(SECONDS FROM clock_timestamp() - ts));

  ts := clock_timestamp();
  SELECT count(DISTINCT id_gen()) FROM generate_series(1, num) INTO v;
  IF v <> num THEN
    RAISE EXCEPTION 'Invalid number of id_gen() distinct values: % (expected %)', v, num;
  END IF;
  RAISE NOTICE 'id_gen(): % reqs/s', round(v / EXTRACT(SECONDS FROM clock_timestamp() - ts));

  ts := clock_timestamp();
  SELECT count(DISTINCT id_gen_max_safe_integer()) FROM generate_series(1, num) INTO v;
  IF v <> num THEN
    RAISE EXCEPTION 'Invalid number of id_gen_max_safe_integer() distinct values: % (expected %)', v, num;
  END IF;
  RAISE NOTICE 'id_gen_max_safe_integer(): % reqs/s', round(v / EXTRACT(SECONDS FROM clock_timestamp() - ts));

  ts := clock_timestamp();
  SELECT count(DISTINCT id_gen_monotonic()) FROM generate_series(1, num) INTO v;
  IF v <> num THEN
    RAISE EXCEPTION 'Invalid number of id_gen_monotonic() distinct values: % (expected %)', v, num;
  END IF;
  RAISE NOTICE 'id_gen_monotonic(): % reqs/s', round(v / EXTRACT(SECONDS FROM clock_timestamp() - ts));

  ts := clock_timestamp();
  SELECT count(DISTINCT id_gen_monotonic_max_safe_integer()) FROM generate_series(1, num) INTO v;
  IF v <> num THEN
    RAISE EXCEPTION 'Invalid number of id_gen_monotonic_max_safe_integer() distinct values: % (expected %)', v, num;
  END IF;
  RAISE NOTICE 'id_gen_monotonic_max_safe_integer(): % reqs/s', round(v / EXTRACT(SECONDS FROM clock_timestamp() - ts));

  ts := clock_timestamp();
  SELECT count(DISTINCT id_gen_monotonic_max_safe_integer('test_custom_seq')) FROM generate_series(1, num) INTO v;
  IF v <> num THEN
    RAISE EXCEPTION 'Invalid number of id_gen_monotonic_max_safe_integer() distinct values: % (expected %)', v, num;
  END IF;
  RAISE NOTICE 'id_gen_monotonic_max_safe_integer(''test_custom_seq''): % reqs/s', round(v / EXTRACT(SECONDS FROM clock_timestamp() - ts));

  ts := clock_timestamp();
  num := 99990; -- since we have limit of ids generated per second
  SELECT count(DISTINCT id_gen_timestampic()) FROM generate_series(1, num ) INTO v;
  IF v <> num THEN
    RAISE EXCEPTION 'Invalid number of id_gen_timestampic() distinct values: % (expected %)', v, num;
  END IF;
  RAISE NOTICE 'id_gen_timestampic(): % reqs/s', round(v / EXTRACT(SECONDS FROM clock_timestamp() - ts));
END;
$$;

SELECT test_perf() \gset

DROP FUNCTION test_perf(integer);

\ir ./rollback.sql
