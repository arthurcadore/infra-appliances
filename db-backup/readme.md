# Image to simplified backup of MySQL/Mariadb databases

### Environment Variables

- DB_HOST=mariadb: Used to set the database host; 
- DB_PORT=3306: Used to set the database port; 
- DB_USER=root: Used to set the database user; 
- DB_PASSWORD=root: Used to set the database root password; 

BACKUP_TYPE=full: Used to set the backup type, which can be either `full` or `incremental`. The default value is `full`, which means that a full backup will be performed. 
BACKUP_NUMBER=5 : Used to set the number of backup files to keep. The default value is 5, which means that the script will keep the 5 most recent backup files and delete older ones.
BACKUP_TIME=86400 : Used to set the time interval (in seconds) between each backup. The default value is 86400, which means that a backup will be performed every 24 hours.

# SFTP variables (optional)
SFTP_HOST=remp.brazilsouth.cloudapp.azure.com : Used to set the SFTP server host for upload the backup file;
SFTP_PORT=2022 : Used to set the SFTP server port for upload the backup file;
SFTP_USER=test-backup : Used to set the SFTP server user for upload the backup file;
SFTP_PASS=test-backup : Used to set the SFTP server password for upload the backup file;
SFTP_PATH=/ : Used to set the SFTP server path for upload the backup file;
SFTP_BACKUP_NUMBER=5 : Used to set the number of backup files to keep on the SFTP server. The default value is 5, which means that the script will keep the 5 most recent backup files on the SFTP server and delete older ones.


### To restore: 

Once the backup was done, the backup file will be sent to a SFTP server (if configured) and can be downloaded and used to restore the database. The backup files are in tar.gz format, so you can extract them and use the SQL file to restore your database.

To restore the database, the simplest way is to use the `mariadb:10.3` image to run a temporary container with the backup file mounted as a volume, and then execute the restore command inside the container. Here is an example command to do that:


- First of all, download the backup file and extract it to a local directory (as `~/test` for example): 
```bash
cadore@cadore:~/test$ ls -l
total 4400
-rw-r--r--  1 cadore cadore 4497133 May 12 15:28 backup_full_2026-05-12_18-27-49.tar.gz
drwxr-xr-x 11 cadore cadore    4096 May 12 15:27 full
```

- Then we need to create a directory to store the restored data (as `~/restore-data` for example):

```bash
cadore@cadore:~/test$ ls -l
total 4400
-rw-r--r--  1 cadore cadore 4497133 May 12 15:28 backup_full_2026-05-12_18-27-49.tar.gz
drwxr-xr-x 11 cadore cadore    4096 May 12 15:27 full
drwxr-xr-x  2 cadore cadore    4096 May 12 15:30 restore-data
```

- Then we can run the following command to restore the database:

```bash
docker run --rm -it --name mariadb-restore -v $(pwd)/full:/backup/full:ro -v $(pwd)/restore-data:/var/lib/mysql -e MARIADB_ROOT_PASSWORD=root mariadb:10.3


##### INSIDE THE CONTAINER #####
rm -rf /var/lib/mysql/
mariabackup --copy-back --target-dir/backup/full
```

- The comand above will copy the files back into the `/var/lib/mysql` directory, which is the default data directory for MySQL/Mariadb.

- After that, you can start a new container with the restored data and access the database as usual:

```bash
docker run -d --name mysql-restored -e MYSQL_ROOT_PASSWORD=root -v $(pwd)/restore-data:var/lib/mysql mariadb:10.3
```