\ir ./begin.sql

\ir ../_id_template.sql
\ir ../_id_init.sql

DROP FUNCTION id_env_no();

SELECT expect_rollback(
  $$SELECT _id_init('1', 10, 10000)$$,
  '',
  'success with const_env_mul=10'
) \gset

SELECT expect_rollback(
  $$SELECT _id_init('10', 100, 10000)$$,
  '',
  'success with const_env_mul=100'
) \gset

SELECT expect_rollback(
  $$SELECT _id_init('100', 1000, 10000)$$,
  '',
  'success with const_env_mul=1000'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('1', 42, 10000)$$,
  'CONST_ENV_MUL must be a power of 10',
  'error: CONST_ENV_MUL'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('1', 10, 10001)$$,
  'CONST_SHARD_MUL must be a power of 10',
  'error: CONST_SHARD_MUL'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('1', 10000, 10000)$$,
  'CONST_ENV_MUL*CONST_SHARD_MUL combined must fit into 7 decimal digits, but they are 8 digits combined. Reasoning: there must be enough space left for timestamp part (9 digits) and sequence part (3+ digits) in the full bigint id range (19 digits)',
  'error: CONST_SHARD_MUL'
) \gset

SELECT expect_raise(
  $$
    CREATE OR REPLACE FUNCTION id_env_no() RETURNS integer LANGUAGE sql
      SET search_path FROM CURRENT AS 'SELECT NULL::integer';
    SELECT _id_init('', 10, 10000);
  $$,
  '%but it returned <NULL>%',
  'error: id_env_no() returns NULL'
) \gset

SELECT expect_raise(
  $$SELECT _id_init(NULL, 10, 10000)$$,
  'DB_ID_ENV_NO=<NULL> environment variable must be a number%',
  'error: env_no is passed as NULL'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('', 10, 10000)$$,
  'DB_ID_ENV_NO='''' environment variable must be a number%',
  'error: env_no is passed as empty string'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('a', 10, 10000)$$,
  'DB_ID_ENV_NO=''a'' environment variable must be a number%',
  'error: env_no is a non-numeric string'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('42', 10, 10000)$$,
  '%in 1..8 range%',
  'error: env_no out of range, 1 digit in env_no'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('1', 100, 10000)$$,
  '%in 10..89 range%',
  'error: env_no out of range, 2 digits in env_no'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('1', 1000, 10000)$$,
  '%in 100..899 range%',
  'error: env_no out of range, 3 digits in env_no'
) \gset

SELECT expect_raise(
  $$SELECT _id_init('42', 100, 100)$$,
  '%in 0..99 range, but it returned 123',
  'error: shard_no out of range'
) \gset

DROP FUNCTION _id_init(text, numeric, numeric);
DROP FUNCTION _id_template(text, text[]);

CREATE OR REPLACE FUNCTION id_env_no() RETURNS integer LANGUAGE sql
  SET search_path FROM CURRENT AS 'SELECT 1';

\ir ./rollback.sql
