\ir ./begin.sql

SELECT expect(
  $$ SELECT substring(id_gen_monotonic()::text FROM 1 FOR 5) $$,
  '10123',
  'id_gen_monotonic()'
) \gset

\ir ./rollback.sql
