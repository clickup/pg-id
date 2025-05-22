\ir ./begin.sql

\ir ../_id_template.sql
\ir ../_id_init.sql

DROP FUNCTION id_env_no();

SELECT expect_rollback(
  $$SELECT _id_init('1', 10, 10000, 100000000000000, 1000000000)$$,
  '',
  'success with const_env_mul=10'
) \gset

SELECT expect_rollback(
  $$SELECT _id_init('10', 100, 10000, 10000000000000, 1000000000)$$,
  '',
  'success with const_env_mul=100'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('1', 42, 10000, 100000000000000, 1000000000)$$,
  'CONST_ENV_MUL must be a power of 10',
  'error: CONST_ENV_MUL'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('1', 10000000, 10000, 100000000000000, 1000000000)$$,
  'CONST_ENV_MUL must not be greater%',
  'error: CONST_ENV_MUL'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('1', 10, 10001, 100000000000000, 1000000000)$$,
  'CONST_SHARD_MUL must be a power of 10',
  'error: CONST_SHARD_MUL'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('1', 10, 100000000, 100000000000000, 1000000000)$$,
  'CONST_SHARD_MUL must not be greater%',
  'error: CONST_SHARD_MUL'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('1', 10, 10000, 100000000000001, 1000000000)$$,
  'CONST_RND_MUL must be a power of 10',
  'error: CONST_RND_MUL'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('1', 10, 10000, 100000000000000, 1000000001)$$,
  'CONST_RND_TS_MUL must be a power of 10',
  'error: CONST_RND_TS_MUL'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('1', 10, 10000, 1000000, 1000000000)$$,
  'CONST_RND_TS_MUL must be less than CONST_RND_MUL',
  'error: CONST_RND_TS_MUL is too big'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('1', 100, 10000, 100000000000000, 1000000000)$$,
  '%but they generated 20%',
  'error: too many digits combined'
) \gset

SELECT expect_raise(
  $$
    CREATE OR REPLACE FUNCTION id_env_no() RETURNS integer LANGUAGE sql
      SET search_path FROM CURRENT AS 'SELECT NULL::integer';
    SELECT _id_init('', 10, 10000, 100000000000000, 1000000000);
  $$,
  '%but it returned <NULL>%',
  'error: id_env_no() returns NULL'
) \gset

SELECT expect_raise(
  $$SELECT _id_init(NULL, 10, 10000, 100000000000000, 1000000000)$$,
  'DB_ID_ENV_NO=<NULL> environment variable must be a number%',
  'error: env_no is passed as NULL'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('', 10, 10000, 100000000000000, 1000000000)$$,
  'DB_ID_ENV_NO='''' environment variable must be a number%',
  'error: env_no is passed as empty string'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('a', 10, 10000, 100000000000000, 1000000000)$$,
  'DB_ID_ENV_NO=''a'' environment variable must be a number%',
  'error: env_no is a non-numeric string'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('42', 10, 10000, 100000000000000, 1000000000)$$,
  '%in 1..8 range (MAX_BIGINT=9223372036854775807)%',
  'error: MAX_BIGINT, 1 digit in env_no'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('1', 100, 10000, 10000000000000, 1000000000)$$,
  '%in 10..91 range (MAX_BIGINT=9223372036854775807)%',
  'error: MAX_BIGINT, 2 digits in env_no'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('1', 1000, 10000, 1000000000000, 1000000000)$$,
  '%in 100..921 range (MAX_BIGINT=9223372036854775807)%',
  'error: MAX_BIGINT, 3 digits in env_no'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('42', 10, 10000, 100000000000, 1000000000)$$,
  '%in 1..8 range (MAX_SAFE_INTEGER=9007199254740991)%',
  'error: MAX_SAFE_INTEGER, 1 digit in env_no'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('1', 100, 10000, 10000000000, 1000000000)$$,
  '%in 10..89 range (MAX_SAFE_INTEGER=9007199254740991)%',
  'error: MAX_SAFE_INTEGER, 2 digits in env_no'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('1', 100, 10000, 10000000, 1000)$$,
  '%in 10..99 range (MAX=9999999999999)%',
  'error: MAX'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('42', 100, 100, 10000000, 1000)$$,
  '%in 0..99 range, but it returned 123',
  'error: shard_no out of range'
) \gset

DROP FUNCTION _id_init(text, numeric, numeric, numeric, numeric);
DROP FUNCTION _id_template(text, text[]);

CREATE OR REPLACE FUNCTION id_env_no() RETURNS integer LANGUAGE sql
  SET search_path FROM CURRENT AS 'SELECT 1';

\ir ./rollback.sql
