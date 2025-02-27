SELECT _id_template(
  $sql$
    CREATE OR REPLACE FUNCTION id_gen_uuid() RETURNS uuid
    LANGUAGE plpgsql
    SET search_path FROM CURRENT
    AS $$
    -- Generates UUID v4 ID with environment and shard number prefix.
    --   Essssxxx-xxxx-4xxx-Nxxx-xxxxxxxxxxxx
    -- where decimal positions are:
    -- a) E is environment number (1..9)
    -- b) s is microshard number e.g. (0..9999)
    -- c) N is "UUID v4 variant number"
    DECLARE
      uuid text;
      n bigint;
      prefix text;
    BEGIN
      n := {I:current_schema}.id_env_no();
      n := n * {CONST_SHARD_MUL} + {I:current_schema}.id_shard_no();
      prefix := n::text;
      uuid := gen_random_uuid()::text;
      RETURN (prefix || substring(uuid from length(prefix) + 1))::uuid;
    END
    $$;
  $sql$,
  'CONST_SHARD_MUL', :'CONST_SHARD_MUL',
  'current_schema', current_schema
) AS tmp \gset
:tmp

COMMENT ON FUNCTION id_gen_uuid() IS
  'Generates an UUID v4 compatible id. First several digits still contain the '
  'information about environment and shard numbers. Example of the UUID generated: '
  '10246xxx-xxxx-4xxx-Nxxx-xxxxxxxxxxxx';
