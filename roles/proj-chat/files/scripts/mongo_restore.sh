#!/bin/bash
mongo_databases_list=( rocketchat )
mongo_port=27017
mongo_host=localhost
mongo_archive_name=mongo
mongo_db_backup_path=/h/toolset/backups
now_date=`date +%Y-%m-%d`

echo "Enter a date in YYYY-MM-DD format to restore bases for that date:"
read now_date
cd $mongo_db_backup_path
db_archive=${mongo_archive_name}.${now_date}*.tar.gz;
db_tar_gz="$(find . -name $db_archive)"
tar -zxvf $db_tar_gz -C /
mongorestore --dir ${now_date}
