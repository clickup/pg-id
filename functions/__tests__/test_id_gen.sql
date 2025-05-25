\ir ./begin.sql

SELECT expect(
  $$ SELECT id_gen() $$,
  '1012340636307545984',
  'id_gen()'
) \gset

SELECT expect(
  $$ SELECT id_gen() $$,
  '1012352440562068925',
  'id_gen()'
) \gset

\ir ./rollback.sql
