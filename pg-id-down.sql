DROP FUNCTION id_env_no();
DROP FUNCTION id_shard_no();

DROP FUNCTION id_gen_monotonic(regclass);
DROP FUNCTION id_gen_monotonic_max_safe_integer(regclass);
DROP FUNCTION id_gen_timestampic(regclass);
DROP FUNCTION id_gen_uuid();
DROP FUNCTION id_gen(regclass);
DROP FUNCTION id_gen_max_safe_integer(regclass);
DROP FUNCTION id_pseudo_encrypt(integer, bigint, numeric, numeric, numeric);

DROP SEQUENCE IF EXISTS id_seq;
DROP SEQUENCE IF EXISTS id_monotonic_seq;
DROP SEQUENCE IF EXISTS id_timestampic_seq;
