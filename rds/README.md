# supabase-rds

This repo has been modified to enable easy deployments of supabase onto an AWS RDS instance. Simply execute the following script:

```
./provision.sh <endpoint> <port> <db_name> <username> <password>
```

- `<endpoint>` is the RDS endpoint accessible from the script location.
- `<port>` is the RDS port, usually `5432`
- `<db_name>` is the name of the database, usually `postgres`
- `<username>` is the username of the RDS database root user, usually `supabase`
- `<password>` is the password of the RDS database root user, set during RDS setup

Requires installation of `psql` command line tool to run.

## Useful Guides & Resources

The following guides are useful for familiarizing yourself with hosting Supabase environments:

- [Self Hosting Supabase](https://supabase.com/docs/guides/hosting/overview) homepage
- [How to Self-Host Supabase with Docker](https://www.linode.com/docs/guides/installing-supabase/)
- [Supabase JWT Generator](https://supabase.com/docs/guides/hosting/overview#api-keys)

## Example: Simple Deployment with Docker-Compose

Note that the below steps walk you through setting up a very basic RDS and Supabase Docker-Compose to connect to the RDS. This is not easily scalable or production ready due to the use of docker-compose on EC2 and the storage of secrets outside of a secrets manager, but is good for demonstration purposes. A more production-ready solution would use solutions like AWS Fargate and AWS Secrets Manager.

1. Create RDS database instance and an EC2 instance that has access to the RDS database.
2. (_Optional_) if you want realtime to work, enable (set to `1`) the `rds.logical_replication` setting in the AWS parameter store that corresponds to the RDS database. The parameter store must be associated with the database, and the database restarted for the changes to take effect.
3. Clone the [supabase/supabase](https://github.com/supabase/supabase) and [agblox/supabase-postgres](https://github.com/agblox/supabase-postgres) repositories into your EC2.
4. Run the `provision.sh` script as outlined above from the `agblox/supabase-postgres` repo. All scripts should run without any errors.
5. Generate Supabase API keys with a JWT tool (e.g. the [Supabase JWT Generator](https://supabase.com/docs/guides/hosting/overview#api-keys)). Copy the `JWT_SECRET`, `ANON_KEY`, and `SERVICE_KEY`, you will use these for later.
6. In the `supabase/supabase` repo, edit the `docker/volumes/api/kong.yml` file. Edit the `consumers:` section, edit the `keyauth_credentials` section for both `anon` and `service_role`. Replace the `key`s with the keys you generated above.
7. Now, edit the `docker/docker-compose.yml` file: comment oiut the `db` section in the file and all the `depends_on: db` sections. Since we are using RDS for the database we no longer need dockerized postgres.
8. (_Optional_) if you are not using Supabase Realtime, you can also comment out the `realtime` section.
9. Copy the `docker/.env.example` to `docker/.env`
10. Edit the `POSTGRES_PASSWORD` variable to match the password of the RDS superuser. Set `JWT_SECRET`, `ANON_KEY`, and `SERVICE_ROLE_KEY`` to the values generated earlier. Set the `POSTGRES_HOST` to the RDS endpoint corresponding to the RDS postgres server.
11. Running `docker-compose up` should now connect you to RDS and you are off to the races! Check dashboard connection with your browser (`localhost:3000`) and connection to the API endpoint (`localhost:8000/rest/v1`)
12. (_Note: if using realtime_) You may want to shutdown the stack (CTRL + C) then edit the Supabase Realtime run command in the `docker-compose.yml` from `bash -c "./prod/rel/realtime/bin/realtime eval Realtime.Release.migrate && ./prod/rel/realtime/bin/realtime start"` to just `bash -c "./prod/rel/realtime/bin/realtime start"`. The first command runs some PG migrations relating to Supabase realtime that only need to be run once on server startup and for some reason cause the container to fail to launch on subsequent runs. This issue needs to be looked into more thoroughly.

## Caveats Discovered with RDS

Generally, the issues with using the scripts out of the box with RDS are as follows:

- `superuser` is not an assignable role in RDS, you must use `rds_superuser` instead
- `replication` is not an assignable role in RDS, you must use `rds_replication` instead
- [pgjwt](https://github.com/michelp/pgjwt) extension is not easily installable because it is incompatible with RDS. However, since pgjwt is written in pure postgres, an alternative solution is just to run the SQL scripts directly in RDS and [install the module as a schema](./2-pgjwt.sql).
- Supabase realtime does not work out of the box with RDS due to `wal_level` not being set to `logical` by default. This can be fixed by adding the RDS instance to a parameter group where `rds.logical_replication` is set to `1`.
  - _Note_: As a consequence of this, Supabase Realtime will likely only work with the read/write RDS endpoints rather than read-only. In other words, all supabase realtime connections should go to the master database.
  - _Note_: Aurora Postgres has not been tested yet overall, but the parameter `rds.logical_replication` is not available as a parameter on Aurora-Postgres param groups, thus it is liklely that Realtime is unsupported in Aurora based postgres environments.

## Developing & Updating from Upstream Repo

Generally, merging from the upstream [supabase/postgres](https://github.com/supabase/postgres) repo will work without difficulty, and rerunning the `povision.sh` script again with the updated repo may work first time. Should something break, changes can be applied to this forked repo.

For developer convenience, the script `xx-clear-database.sql` is included: this will get rid of everything the Supabase migration scripts created and make it such that you can rerun the migrations without encountering errors, useful when debugging changes to the migration scripts. **Running this script will delete everything in the database, please only run this on a test RDS instance and not a production database.**
