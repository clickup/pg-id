\ir ./begin.sql

SELECT expect(
  $$ SELECT id_gen_max_safe_integer('test_custom_seq') $$,
  '1012323626055688',
  'id_gen_max_safe_integer()'
) \gset

SELECT expect(
  $$ SELECT id_gen_max_safe_integer('test_custom_seq') $$,
  '1012335164653795',
  'id_gen_max_safe_integer()'
) \gset

SELECT expect(
  $$ SELECT id_gen_max_safe_integer('test_custom_seq') $$,
  '1012324269199313',
  'id_gen_max_safe_integer()'
) \gset

\ir ./rollback.sql
