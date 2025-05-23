SELECT _id_template(
  $sql$
    CREATE OR REPLACE FUNCTION id_gen() RETURNS bigint
    LANGUAGE plpgsql
    SET search_path FROM CURRENT
    AS $$
    -- Generates next globally-unique randomly-looking id:
    --   EssssRRRRR...
    -- where decimal positions are:
    -- a) E is environment number (1..7)
    -- b) s is microshard number (0..9999)
    -- c) R is random-looking part (up to 10^14 which is > 2^46)
    DECLARE
      seq text := {current_schema} || '.id_seq';
      plain_id bigint;
      id bigint;
    BEGIN
      plain_id := nextval(seq::regclass);
      IF plain_id < 0 OR plain_id >= {CONST_RND_MUL} THEN
        RAISE EXCEPTION 'Too many ids generated by %: % (max %)', seq, plain_id, {CONST_RND_MUL};
      END IF;
      id := {I:current_schema}.id_env_no();
      id := id * {CONST_SHARD_MUL} + {I:current_schema}.id_shard_no();
      id := id * {CONST_RND_MUL} + {I:current_schema}.id_pseudo_encrypt(
        {CONST_RND_BITS},
        plain_id,
        {CONST_MUL},
        {CONST_SUM},
        {CONST_MOD}
      );
      RETURN id;
    END
    $$;
  $sql$,
  'CONST_SHARD_MUL', :'CONST_SHARD_MUL',
  'CONST_RND_MUL', :'CONST_RND_MUL',
  'CONST_RND_BITS', :'CONST_RND_BITS',
  'CONST_MUL', :'CONST_MUL',
  'CONST_SUM', :'CONST_SUM',
  'CONST_MOD', :'CONST_MOD',
  'current_schema', current_schema
) AS tmp \gset
:tmp

COMMENT ON FUNCTION id_gen()
  IS 'Generates next globally-unique randomly-looking id. The main idea is to '
     'not let external people infer the rate at which the ids are generated, '
     'even when they look at some ids sample.';
