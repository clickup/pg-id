SELECT _id_template(
  $sql$
    CREATE OR REPLACE FUNCTION id_gen_timestampic() RETURNS bigint
    LANGUAGE plpgsql
    SET search_path FROM CURRENT
    AS $$
    -- Generates next globally-unique id prefixed with timestamp.
    --   EssssTTTTnnnn...
    -- where decimal positions are:
    -- a) E is environment number (1..7)
    -- b) s is micro-shard number (0..9999)
    -- c) T is timestamp in seconds since 2010-01-01 UTC (9 decimal digits, +17 years from 2023)
    -- c) n is monotonic sequence ring (up to 5 decimal digits, so up to 100k inserts/sec)
    DECLARE
      seq text := {current_schema} || '.id_timestampic_seq';
      plain_id bigint;
      id bigint;
    BEGIN
      plain_id := nextval(seq::regclass);
      IF plain_id < 0 OR plain_id >= {CONST_RND_MUL} THEN
        RAISE EXCEPTION 'Too many ids generated by %: % (max %)', seq, plain_id, {CONST_RND_MUL};
      END IF;
      id := {I:current_schema}.id_env_no();
      id := id * {CONST_SHARD_MUL} + {I:current_schema}.id_shard_no();
      id := id * {CONST_RND_TS_MUL} + trunc(EXTRACT(EPOCH FROM clock_timestamp())) - {CONST_RND_TS_START};
      id := id * {CONST_RND_SEQ_MUL} + (plain_id % {CONST_RND_SEQ_MUL});
      RETURN id;
    END
    $$;
  $sql$,
  'CONST_SHARD_MUL', :'CONST_SHARD_MUL',
  'CONST_RND_MUL', :'CONST_RND_MUL',
  'CONST_RND_TS_MUL', :'CONST_RND_TS_MUL',
  'CONST_RND_TS_START', :'CONST_RND_TS_START',
  'CONST_RND_SEQ_MUL', (:CONST_RND_MUL / :CONST_RND_TS_MUL)::text,
  'current_schema', current_schema
) AS tmp \gset
:tmp

COMMENT ON FUNCTION id_gen_timestampic() IS
  'Generates next next globally-unique id prefixed with timestamp. Increasing '
  'ids are more friendly to heavy INSERTs since they maximize the chance for '
  'btree index to reuse the newly created leaf pages.';
