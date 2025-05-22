CREATE OR REPLACE FUNCTION _id_init(
  env_no_str text,
  const_env_mul numeric,
  const_shard_mul numeric,
  const_rnd_mul numeric,
  const_rnd_ts_mul numeric
) RETURNS void
LANGUAGE plpgsql
SET search_path FROM CURRENT
AS $$
DECLARE
  MAX_BIGINT numeric := 9223372036854775807;
  MAX_SAFE_INTEGER numeric := 9007199254740991;
  env_no integer;
  shard_no integer;
  id_digits integer;
  max_env_no bigint;
  prefix_of text;
BEGIN
  id_digits := length((const_env_mul * const_shard_mul * const_rnd_mul)::text) - 1;
  IF const_env_mul::text !~ '^10+$' THEN
    RAISE EXCEPTION 'CONST_ENV_MUL must be a power of 10';
  ELSIF const_env_mul >= 1000000 THEN
    RAISE EXCEPTION 'CONST_ENV_MUL must not be greater than 1000000';
  ELSIF const_shard_mul::text !~ '^10+$' THEN
    RAISE EXCEPTION 'CONST_SHARD_MUL must be a power of 10';
  ELSIF const_shard_mul >= 10000000 THEN
    RAISE EXCEPTION 'CONST_SHARD_MUL must not be greater than 10000000';
  ELSIF const_rnd_mul::text !~ '^10+$' THEN
    RAISE EXCEPTION 'CONST_RND_MUL must be a power of 10';
  ELSIF const_rnd_ts_mul::text !~ '^10+$' THEN
    RAISE EXCEPTION 'CONST_RND_TS_MUL must be a power of 10';
  ELSIF const_rnd_ts_mul >= const_rnd_mul THEN
    RAISE EXCEPTION 'CONST_RND_TS_MUL must be less than CONST_RND_MUL';
  ELSIF id_digits > 19 THEN
    RAISE EXCEPTION
      'To fit into a bigint number, CONST_ENV_MUL*CONST_SHARD_MUL*CONST_RND_MUL '
      'combined must generate ids with not more than 19 decimal digits, but '
      'they generated % digits', id_digits;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_proc
    JOIN pg_namespace ON pg_namespace.oid = pronamespace
    WHERE proname = 'id_env_no' AND nspname = current_schema()
  ) THEN
    IF env_no_str IS NULL OR env_no_str !~ '^[0-9]+$' THEN
      RAISE EXCEPTION
        'DB_ID_ENV_NO=% environment variable must be a number. '
        'Alternatively, define id_env_no() function manually.',
        quote_literal(env_no_str);
    END IF;
    EXECUTE _id_template(
      $sql$
        CREATE OR REPLACE FUNCTION id_env_no() RETURNS integer LANGUAGE sql SET search_path FROM CURRENT
        AS 'SELECT {SQL:env_no_str}'
      $sql$,
      'env_no_str', env_no_str::text
    );
    COMMENT ON FUNCTION id_env_no()
      IS 'Returns the current environment number (1st digit(s) in ids).';
  END IF;

  env_no := id_env_no();
  IF id_digits = length(MAX_BIGINT::text) THEN
    max_env_no := left(MAX_BIGINT::text, length(const_env_mul::text) - 1)::bigint - 1;
    prefix_of := 'MAX_BIGINT=' || MAX_BIGINT;
  ELSIF id_digits = length(MAX_SAFE_INTEGER::text) THEN
    max_env_no := left(MAX_SAFE_INTEGER::text, length(const_env_mul::text) - 1)::bigint - 1;
    prefix_of := 'MAX_SAFE_INTEGER=' || MAX_SAFE_INTEGER;
  ELSE
    max_env_no := repeat('9', length(const_env_mul::text) - 1)::bigint;
    prefix_of := 'MAX=' || repeat('9', id_digits);
  END IF;
  IF env_no IS NULL OR env_no < round(const_env_mul / 10) OR env_no > max_env_no THEN
    RAISE EXCEPTION
      'id_env_no() must return a number in %..% range (%), but it returned %',
      round(const_env_mul / 10),
      max_env_no,
      prefix_of,
      env_no;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_proc
    JOIN pg_namespace ON pg_namespace.oid = pronamespace
    WHERE proname = 'id_shard_no' AND nspname = current_schema()
  ) THEN
    shard_no := substring(current_schema from '([0-9]+)')::integer;
    IF shard_no IS NULL THEN
      RAISE EXCEPTION 'Cannot extract the shard number from schema name %', current_schema;
    END IF;
    EXECUTE _id_template(
      $sql$
        CREATE OR REPLACE FUNCTION id_shard_no() RETURNS integer LANGUAGE sql SET search_path FROM CURRENT
        AS 'SELECT {SQL:shard_no}';
      $sql$,
      'shard_no', shard_no::text
    );
    COMMENT ON FUNCTION id_shard_no()
      IS 'Returns the current shard number (prefix of all ids in this shard).';
  END IF;

  shard_no := id_shard_no();
  IF shard_no IS NULL OR shard_no < 0 OR shard_no > const_shard_mul - 1 THEN
    RAISE EXCEPTION
      'id_shard_no() must return a number in 0..% range, but it returned %',
      const_shard_mul - 1,
      shard_no;
  END IF;
END
$$;
