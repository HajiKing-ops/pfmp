# Database Backup & Restore

## The MySQL volume

Database data is stored in a persistent Docker volume, configured as
**external** so it survives `docker compose down`:

```yaml
volumes:
  mysql_data:
    external: true
    name: docker-test_mysql_data
```

Create it before the first run on any new machine:

```bash
docker volume create docker-test_mysql_data
docker volume ls   # confirm it exists
```

**Never run `docker compose down -v` unless you intentionally want to delete
local database data** — `-v` removes volumes, including this one.

## Restore from a backup

Place the `.sql` backup somewhere accessible, e.g.
`backups/pfmp_manager_backup.sql`, then start MySQL only:

```bash
docker compose up -d mysql
docker compose ps   # wait until healthy
```

**Windows CMD:**

```cmd
cmd /c "docker exec -i pfmp_mysql mysql -uroot -pYOUR_PASSWORD pfmp_manager < backups\pfmp_manager_backup.sql"
```

Note: there is no space between `-p` and the password.

**PowerShell:**

```powershell
Get-Content .\backups\pfmp_manager_backup.sql | docker exec -i pfmp_mysql mysql -uroot -pYOUR_PASSWORD pfmp_manager
```

For large backups, CMD tends to be more reliable than piping through
`Get-Content`.

**macOS/Linux:**

```bash
docker exec -i pfmp_mysql mysql -uroot -pYOUR_PASSWORD pfmp_manager < backups/pfmp_manager_backup.sql
```

## Create a backup

```bash
mkdir -p backups
docker exec pfmp_mysql mysqldump -uroot -pYOUR_PASSWORD pfmp_manager > backups/pfmp_manager_backup.sql
```

Take one before any risky change:

```bash
docker exec pfmp_mysql mysqldump -uroot -pYOUR_PASSWORD pfmp_manager > backups/pfmp_manager_before_changes.sql
```

## Before handing the project to someone else

Testing and local development create real rows: users, PFMPs, messages,
reports, refresh tokens. Before sharing the project or a database export:

- Provide a clean backup, **or**
- Document exactly which rows are test data, **or**
- Delete test data carefully with SQL, respecting foreign key order.

Always take a backup before cleaning anything out.
