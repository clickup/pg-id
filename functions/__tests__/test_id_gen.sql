\ir ./begin.sql

SELECT expect(
  $$ SELECT substring(id_gen()::text FROM 1 FOR 5) $$,
  '10123',
  'id_gen()'
) \gset

\ir ./rollback.sql
