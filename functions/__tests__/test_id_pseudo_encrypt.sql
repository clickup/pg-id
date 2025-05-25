\ir ./begin.sql

SELECT expect(
  $$ SELECT
    id_pseudo_encrypt(
      46,
      id_pseudo_encrypt(46, 424242, 17141763000000, 13795571000000, 19458232000000),
      17141763000000,
      13795571000000,
      19458232000000
    ) $$,
  '424242',
  'id_pseudo_encrypt() is invertible'
) \gset

\ir ./rollback.sql
