SELECT current_database();

BEGIN;

CREATE SCHEMA test_pg_id;
SET search_path TO test_pg_id;
SET client_min_messages TO NOTICE;
\set ON_ERROR_STOP on

CREATE OR REPLACE FUNCTION id_env_no() RETURNS integer LANGUAGE sql
  SET search_path FROM CURRENT AS 'SELECT 1';

CREATE OR REPLACE FUNCTION id_shard_no() RETURNS integer LANGUAGE sql
  SET search_path FROM CURRENT AS 'SELECT 123';

\ir ../../pg-id-up.sql

CREATE FUNCTION expect(sql text, exp text, msg text) RETURNS void LANGUAGE plpgsql AS $$
DECLARE
  got text;
BEGIN
  EXECUTE sql INTO got;
  got := trim(E' \t\n' from regexp_replace(got, E'^[ \t]+', '', 'mg'));
  exp := trim(E' \t\n' from regexp_replace(exp, E'^[ \t]+', '', 'mg'));
  IF got IS DISTINCT FROM exp THEN
    RAISE EXCEPTION 'Expectation failed (%): expected %, got %', msg, exp, got;
  END IF;
END;
$$;
