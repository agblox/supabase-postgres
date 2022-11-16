# supabase-rds

This repo has been modified to enable easy deployments of supabase onto an AWS RDS instance. Simply execute the following script:

```
./provision.sh <rds endpoint> <rds port> <rds db name> <rds superuser username (usually 'postgres')> <rds superuser password>
```
