# How To Use MSSQL CLI in Linux

## Backup Command

```
?
```

## Restore Command

```
/opt/mssql-tools/bin/sqlcmd -S localhost -U 'sa' -P 'yourStrong(!)Password' -Q "RESTORE DATABASE [Database.Name] FROM DISK = '/db/MyDatabase.bak' WITH MOVE 'Database.Name' TO '/var/opt/mssql/data/Database.Name.mdf', MOVE 'Database.Name_log' TO '/var/opt/mssql/data/Database.Name_log.LDF';"
```
