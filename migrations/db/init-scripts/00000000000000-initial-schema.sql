-- migrate:up

-- Set up realtime
-- defaults to empty publication
create publication supabase_realtime;

-- Supabase super admin
create user supabase_admin;
grant supabase_admin to postgres; -- RDS: postgres must have supabase_admin role for future commands
grant rds_superuser to supabase_admin; -- RDS: rds_superuser rather than superuser
grant rds_replication to supabase_admin; -- RDS: rds_replication rather than replication
alter user  supabase_admin with createdb createrole bypassrls; -- RDS: had to remove replication, superuser (see above)

-- Set up auth roles for the developer
create role anon                nologin noinherit;
create role authenticated       nologin noinherit; -- "logged in" user: web_user, app_user, etc
create role service_role        nologin noinherit bypassrls; -- allow developers to create JWT's that bypass their policies

create user authenticator noinherit;
grant anon              to authenticator;
grant authenticated     to authenticator;
grant service_role      to authenticator;
grant supabase_admin    to authenticator;

grant usage                     on schema public to postgres, anon, authenticated, service_role;
alter default privileges in schema public grant all on tables to postgres, anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to postgres, anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to postgres, anon, authenticated, service_role;

-- Allow Extensions to be used in the API
grant usage                     on schema extensions to postgres, anon, authenticated, service_role;

-- Set up namespacing
alter user supabase_admin SET search_path TO public, extensions; -- don't include the "auth" schema

-- These are required so that the users receive grants whenever "supabase_admin" creates tables/function
alter default privileges for user supabase_admin in schema public grant all
    on sequences to postgres, anon, authenticated, service_role;
alter default privileges for user supabase_admin in schema public grant all
    on tables to postgres, anon, authenticated, service_role;
alter default privileges for user supabase_admin in schema public grant all
    on functions to postgres, anon, authenticated, service_role;

-- Set short statement/query timeouts for API roles
alter role anon set statement_timeout = '3s';
alter role authenticated set statement_timeout = '8s';

-- migrate:down
