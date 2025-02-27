\ir ./begin.sql

SELECT expect(
  $$ SELECT substring(id_gen_uuid()::text FROM 1 FOR 5) $$,
  '10123',
  'id_gen_uuid()'
) \gset

\ir ./rollback.sql
