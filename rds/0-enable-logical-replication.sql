-- RDS: must set rds.logical_replication to 1 for realtime to work
-- RDS NOTE: supabase_realtime only works with the writer endpoint
-- Setting rds.logical_replication possible in plain pg14 AWS parameter group, but not Aurora. Unsure if supabase_realtime would be supported with Aurora.

DO LANGUAGE PLPGSQL $$
DECLARE
    wal_level text;
BEGIN
    SELECT setting INTO wal_level FROM pg_settings WHERE name = 'wal_level';
    IF wal_level <> 'logical'
    THEN
        RAISE EXCEPTION USING MESSAGE = 'RDS logical replication must be enabled to proceed. In other words, the RDS database must be a member of an AWS parameter group with rds.logical_replication = 1. Change the parameter "rds.logical_replication" to "1" in the parameter group, save, and restart the database.';
    END IF;
END;
$$;

