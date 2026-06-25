@echo off
set BACKUP_NAME=pfmp_manager_backup_%date:~-4%-%date:~3,2%-%date:~0,2%.sql

echo Creating database backup...

docker compose exec -T mysql sh -c "MYSQL_PWD=rootpassword mysqldump -u root pfmp_manager" > %BACKUP_NAME%

echo Backup created: %BACKUP_NAME%
pause
