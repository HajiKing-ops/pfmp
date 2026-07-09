# Database Backup and Restore

## MySQL Volume

Database data is stored in a persistent Docker volume configured as external:

```yaml
volumes:
  mysql_data:
    external: true
    name: docker-test_mysql_data
```

Create the volume before the first run on a new machine:

```bash
docker volume create docker-test_mysql_data
docker volume ls
```

Do not run `docker compose down -v` unless you intentionally want to delete local database data. The `-v` option removes volumes.

## Create a Backup

Create a backup directory:

```bash
mkdir -p backups
```

Create a dump:

```bash
docker exec pfmp_mysql mysqldump -uroot -pYOUR_PASSWORD pfmp_manager > backups/pfmp_manager_backup.sql
```

Before risky work, use a descriptive name:

```bash
docker exec pfmp_mysql mysqldump -uroot -pYOUR_PASSWORD pfmp_manager > backups/pfmp_manager_before_changes.sql
```

Use placeholders in documentation. Do not write real database passwords in committed files.

## Restore from a Backup

Place the `.sql` backup somewhere accessible, for example:

```text
backups/pfmp_manager_backup.sql
```

Start MySQL only:

```bash
docker compose up -d mysql
docker compose ps
```

Wait until `pfmp_mysql` is healthy.

### Windows CMD

```cmd
cmd /c "docker exec -i pfmp_mysql mysql -uroot -pYOUR_PASSWORD pfmp_manager < backups\pfmp_manager_backup.sql"
```

There is no space between `-p` and the password.

### PowerShell

```powershell
Get-Content .\backups\pfmp_manager_backup.sql | docker exec -i pfmp_mysql mysql -uroot -pYOUR_PASSWORD pfmp_manager
```

For large backups, CMD can be more reliable than piping through `Get-Content`.

### macOS/Linux

```bash
docker exec -i pfmp_mysql mysql -uroot -pYOUR_PASSWORD pfmp_manager < backups/pfmp_manager_backup.sql
```

## Before Sharing the Project

Testing and local development can create real rows: users, PFMPs, messages, daily reports, attendance, and refresh tokens.

Before sharing a database export:

- provide a clean backup, or
- document which rows are test data, or
- delete test data carefully with SQL while respecting table relationships.

Always take a backup before cleaning data.
