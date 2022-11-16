-- Loading of PG extensions

create schema if not exists extensions;
create extension if not exists "uuid-ossp"      with schema extensions;
create extension if not exists pgcrypto         with schema extensions;
-- pgjwt in jwt schema, (not an extension, loaded in following script ./1-pgjwt.sql)

