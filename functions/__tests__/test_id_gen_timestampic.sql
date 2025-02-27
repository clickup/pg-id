\ir ./begin.sql

SELECT expect(
  $$ SELECT substring(id_gen_timestampic()::text FROM 1 FOR 5) $$,
  '10123',
  'id_gen_timestampic()'
) \gset

\ir ./rollback.sql
