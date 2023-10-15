CREATE OR REPLACE FUNCTION id_pseudo_encrypt(
  bits integer,
  value bigint,
  const_mul numeric,
  const_sum numeric,
  const_mod numeric
) RETURNS bigint
LANGUAGE plpgsql
SET search_path FROM CURRENT
IMMUTABLE STRICT
AS $$
-- Based on https://en.wikipedia.org/wiki/Feistel_cipher
-- Given a value, generates its "random 1:1" equivalent which fits into
-- the provided number of bits. Call one more time to get the original back.
DECLARE
  halfbits int := bits / 2;
  halfmask bigint := (2 ^ halfbits) - 1;
  l1 bigint;
  l2 bigint;
  r1 bigint;
  r2 bigint;
BEGIN
  l1 := (value >> halfbits) & halfmask;
  r1 := value & halfmask;
  FOR i IN 0..2 LOOP
    l2 := r1;
    r2 := l1 # div(((const_mul * r1 + const_sum) % const_mod) * halfmask, const_mod)::bigint;
    l1 := l2;
    r1 := r2;
  END LOOP;
  RETURN (r1 << halfbits) + l1;
END;
$$;
