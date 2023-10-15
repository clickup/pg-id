CREATE OR REPLACE FUNCTION id_test_dangerous(num integer = 200000) RETURNS void
LANGUAGE plpgsql
SET search_path FROM CURRENT
AS $$
DECLARE
  v integer;
  ts timestamptz;
BEGIN
  ts := clock_timestamp();
  SELECT count(DISTINCT id_gen()) FROM generate_series(1, num) INTO v;
  IF v <> num THEN
    RAISE EXCEPTION 'Invalid number of id_gen() distinct values: % (expected %)', v, num;
  END IF;
  RAISE NOTICE 'id_gen(): % reqs/s', round(v / EXTRACT(SECONDS FROM clock_timestamp() - ts));

  ts := clock_timestamp();
  SELECT count(DISTINCT id_gen_monotonic()) FROM generate_series(1, num) INTO v;
  IF v <> num THEN
    RAISE EXCEPTION 'Invalid number of id_gen_monotonic() distinct values: % (expected %)', v, num;
  END IF;
  RAISE NOTICE 'id_gen_monotonic(): % reqs/s', round(v / EXTRACT(SECONDS FROM clock_timestamp() - ts));

  ts := clock_timestamp();
  num := 99990; -- since we have limit of ids generated per second
  SELECT count(DISTINCT id_gen_timestampic()) FROM generate_series(1, num ) INTO v;
  IF v <> num THEN
    RAISE EXCEPTION 'Invalid number of id_gen_timestampic() distinct values: % (expected %)', v, num;
  END IF;
  RAISE NOTICE 'id_gen_timestampic(): % reqs/s', round(v / EXTRACT(SECONDS FROM clock_timestamp() - ts));
END;
$$;

COMMENT ON FUNCTION id_test_dangerous(integer)
  IS 'For manual runs: verifies that the algorithms really work. Do not run in production!';
