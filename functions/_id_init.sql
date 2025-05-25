CREATE OR REPLACE FUNCTION _id_init(
  env_no_str text,
  const_env_mul numeric,
  const_shard_mul numeric
) RETURNS void
LANGUAGE plpgsql
SET search_path FROM CURRENT
AS $$
DECLARE
  MAX_BIGINT numeric := 9223372036854775807;
  MAX_SAFE_INTEGER numeric := 9007199254740991;
  env_no integer;
  shard_no integer;
  prefix_digits integer;
  max_prefix_digits integer;
  max_env_no bigint;
BEGIN
  max_prefix_digits := length(MAX_BIGINT::text) - 9 - 3;
  prefix_digits := length(round(const_env_mul * const_shard_mul)::text) - 1;
  IF const_env_mul::text !~ '^10+$' THEN
    RAISE EXCEPTION 'CONST_ENV_MUL must be a power of 10';
  ELSIF const_shard_mul::text !~ '^10+$' THEN
    RAISE EXCEPTION 'CONST_SHARD_MUL must be a power of 10';
  ELSIF prefix_digits > max_prefix_digits THEN
    RAISE EXCEPTION
      'CONST_ENV_MUL*CONST_SHARD_MUL combined must fit into % decimal digits, '
      'but they are % digits combined. Reasoning: there must be enough space '
      'left for timestamp part (9 digits) and sequence part (3+ digits) in '
      'the full bigint id range (% digits)',
      max_prefix_digits,
      prefix_digits,
      length(MAX_BIGINT::text);
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
  max_env_no := LEAST(
    left(MAX_BIGINT::text, length(const_env_mul::text) - 1)::bigint - 1,
    left(MAX_SAFE_INTEGER::text, length(const_env_mul::text) - 1)::bigint - 1
  );
  IF env_no IS NULL OR env_no < round(const_env_mul / 10) OR env_no > max_env_no THEN
    RAISE EXCEPTION
      'id_env_no() must return a number in %..% range (satisfying both MAX_BIGINT=% and MAX_SAFE_INTEGER=% decimal prefixes), but it returned %',
      round(const_env_mul / 10),
      max_env_no,
      MAX_BIGINT,
      MAX_SAFE_INTEGER,
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
