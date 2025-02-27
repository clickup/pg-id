\ir ../../pg-id-down.sql

SET search_path TO test_pg_id;

DROP FUNCTION expect(text, text, text);

SET search_path TO public;
DROP SCHEMA test_pg_id;

ROLLBACK;
