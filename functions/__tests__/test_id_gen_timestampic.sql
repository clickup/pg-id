\ir ./begin.sql

SELECT expect(
  $$ SELECT id_gen_timestampic()::text $$,
  '10123%00001',
  'id_gen_timestampic()'
) \gset

SELECT expect(
  $$ SELECT id_gen_timestampic()::text $$,
  '10123%00002',
  'id_gen_timestampic()'
) \gset

SELECT id_gen_timestampic() AS "id_gen_timestampic() sample result";

SELECT expect(
  $$ SELECT id_gen_timestampic('test_custom_seq')::text $$,
  '10123%00001',
  'id_gen_timestampic()'
) \gset

\ir ./rollback.sql
