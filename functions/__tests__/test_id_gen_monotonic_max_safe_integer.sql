\ir ./begin.sql

SELECT expect(
  $$ SELECT id_gen_monotonic_max_safe_integer('test_custom_seq') $$,
  '1012300000000001',
  'id_gen_monotonic_max_safe_integer()'
) \gset

SELECT expect(
  $$ SELECT id_gen_monotonic_max_safe_integer('test_custom_seq') $$,
  '1012300000000002',
  'id_gen_monotonic_max_safe_integer()'
) \gset

\ir ./rollback.sql
