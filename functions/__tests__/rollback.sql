\ir ../../pg-id-down.sql

SET search_path TO "test.pg_id";

DROP SEQUENCE test_custom_seq;
DROP FUNCTION expect(text, text, text);
DROP FUNCTION expect_rollback(text, text, text);
DROP FUNCTION expect_raise(text, text, text);

SET search_path TO public;
DROP SCHEMA "test.pg_id";

ROLLBACK;
