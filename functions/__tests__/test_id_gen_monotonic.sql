\ir ./begin.sql

SELECT expect(
  $$ SELECT id_gen_monotonic() $$,
  '1012300000000000001',
  'id_gen_monotonic()'
) \gset

SELECT expect(
  $$ SELECT id_gen_monotonic() $$,
  '1012300000000000002',
  'id_gen_monotonic()'
) \gset

\ir ./rollback.sql
