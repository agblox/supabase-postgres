-- WARNING: THIS SCRIPT WILL DELETE EVERYTHING IN A DATABASE IT IS POINTED AT.
-- PLEASE DO NOT RUN THIS ON ANY DEV/STAGING/PROD DB!
-- DEBUG PURPOSES ONLY!

-- clear general database
CREATE DATABASE other;
\c other
DROP DATABASE postgres;
CREATE DATABASE postgres;
\c postgres
DROP DATABASE other;

-- clear init scripts
DROP PUBLICATION supabase_realtime;
DROP ROLE supabase_admin;
DROP ROLE anon;
DROP ROLE authenticated;
DROP ROLE authenticator;
DROP ROLE dashboard_user;
DROP ROLE service_role;
DROP ROLE supabase_auth_admin;
DROP ROLE supabase_storage_admin;
