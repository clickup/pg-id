\ir ./begin.sql

SELECT expect(
  $$ SELECT id_gen_uuid() $$,
  '10123%-%-4%-%-%',
  'id_gen_uuid()'
) \gset

\ir ./rollback.sql
