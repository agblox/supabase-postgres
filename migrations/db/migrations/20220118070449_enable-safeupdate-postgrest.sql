-- migrate:up
-- ALTER ROLE authenticator SET session_preload_libraries = 'safeupdate';
-- RDS: removed above, it is a module that is not strictly necessary
-- I believe there is an issue due to this being an unsupported extension OR RDS does not allow 'session_preload_libraries' to be set
-- See: https://pgxn.org/dist/safeupdate/ for more details

-- migrate:down
