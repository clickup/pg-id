DROP FUNCTION id_env_no();
DROP FUNCTION id_shard_no();

DROP FUNCTION id_gen_monotonic();
DROP FUNCTION id_gen_timestampic();
DROP FUNCTION id_gen();
DROP FUNCTION id_pseudo_encrypt(integer, bigint, numeric, numeric, numeric);
DROP FUNCTION id_test_dangerous(integer);

DROP SEQUENCE IF EXISTS id_seq;
DROP SEQUENCE IF EXISTS id_monotonic_seq;
DROP SEQUENCE IF EXISTS id_timestampic_seq;
