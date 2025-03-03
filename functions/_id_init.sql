CREATE OR REPLACE FUNCTION _id_init(env_no text) RETURNS void
LANGUAGE plpgsql
SET search_path FROM CURRENT
AS $$
DECLARE
  shard_no integer;
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_proc
    JOIN pg_namespace ON pg_namespace.oid = pronamespace
    WHERE proname = 'id_env_no' AND nspname = current_schema()
  ) THEN
    IF env_no IS NULL OR env_no !~ '^[0-9]$' OR env_no::integer < 1 OR env_no::integer > 7 THEN
      RAISE EXCEPTION
        'DB_ID_ENV_NO="%" environment variable must be a 1..7 number. '
        'Alternatively, define id_env_no() function manually.',
        env_no;
    END IF;
    EXECUTE _id_template(
      $sql$
        CREATE OR REPLACE FUNCTION id_env_no() RETURNS integer LANGUAGE sql SET search_path FROM CURRENT
        AS 'SELECT {SQL:env_no}'
      $sql$,
      'env_no', env_no::text
    );
    COMMENT ON FUNCTION id_env_no()
      IS 'Returns the current environment number (1st digit in ids).';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_proc
    JOIN pg_namespace ON pg_namespace.oid = pronamespace
    WHERE proname = 'id_shard_no' AND nspname = current_schema()
  ) THEN
    shard_no := substring(current_schema from '([0-9]+)$');
    IF shard_no IS NULL OR shard_no::integer < 0 OR shard_no::integer > 9999 THEN
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
END
$$;

\set DB_ID_ENV_NO `echo "$DB_ID_ENV_NO"`
SELECT _id_init(:'DB_ID_ENV_NO');
