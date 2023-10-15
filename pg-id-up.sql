\ir ./pg-id-consts.sql

\ir ./functions/_id_template.sql

\ir ./functions/_id_init.sql
\ir ./functions/id_gen_monotonic.sql
\ir ./functions/id_gen_timestampic.sql
\ir ./functions/id_gen.sql
\ir ./functions/id_pseudo_encrypt.sql
\ir ./functions/id_test_dangerous.sql

DROP FUNCTION _id_init(text);
DROP FUNCTION _id_template(text, text[]);

DROP FUNCTION IF EXISTS id_gen_test(integer);

CREATE SEQUENCE IF NOT EXISTS id_seq
  START WITH 100000000
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

CREATE SEQUENCE IF NOT EXISTS id_monotonic_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

CREATE SEQUENCE IF NOT EXISTS id_timestampic_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;
