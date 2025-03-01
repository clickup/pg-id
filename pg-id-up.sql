\set ON_ERROR_STOP off
\if :{?CONST_MUL}
  \echo CONST_MUL variable is already set, skipping pg-id.config.sql loading.
\else
  \ir ./pg-id.config.sql
  \if :{?CONST_MUL}
    \echo Found pg-id.config.sql, using it.
  \else
    \ir ../pg-id.config.sql
    \if :{?CONST_MUL}
      \echo Found ../pg-id.config.sql, using it.
    \else
      \ir ../../pg-id.config.sql
      \if :{?CONST_MUL}
        \echo Found ../../pg-id.config.sql, using it.
      \else
        \ir ../../../pg-id.config.sql
        \if :{?CONST_MUL}
          \echo Found ../../../pg-id.config.sql, using it.
        \else
          \ir ../../../../pg-id.config.sql
          \if :{?CONST_MUL}
            \echo Found ../../../../pg-id.config.sql, using it.
          \else
            \ir ../../../../../pg-id.config.sql
            \if :{?CONST_MUL}
              \echo Found ../../../../../pg-id.config.sql, using it.
            \else
              \ir ../../../../../../pg-id.config.sql
              \if :{?CONST_MUL}
                \echo Found ../../../../../../pg-id.config.sql, using it.
              \else
                \set ON_ERROR_STOP on
                \set SHOW_CONTEXT never
                DO $$ BEGIN
                  RAISE EXCEPTION 'Could not find pg-id.config.sql in any of the parent directories.';
                END $$;
              \endif
            \endif
          \endif
        \endif
      \endif
    \endif
  \endif
\endif
\set ON_ERROR_STOP on

\ir ./functions/_id_template.sql

\ir ./functions/_id_init.sql
\ir ./functions/id_gen_monotonic.sql
\ir ./functions/id_gen_timestampic.sql
\ir ./functions/id_gen_uuid.sql
\ir ./functions/id_gen.sql
\ir ./functions/id_pseudo_encrypt.sql
\ir ./functions/id_test_dangerous.sql

DROP FUNCTION _id_init(text);
DROP FUNCTION _id_template(text, text[]);

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
