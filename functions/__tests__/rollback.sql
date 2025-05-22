\ir ../../pg-id-down.sql

SET search_path TO test_pg_id;

DROP FUNCTION expect(text, text, text);
DROP FUNCTION expect_rollback(text, text, text);
DROP FUNCTION expect_raise(text, text, text);

SET search_path TO public;
DROP SCHEMA test_pg_id;

ROLLBACK;
