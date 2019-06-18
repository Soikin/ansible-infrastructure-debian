#!/bin/bash
mongo_databases_list=( rocketchat )
mongo_port=27017
mongo_host=localhost
mongo_archive_name=mongo
mongo_db_backup_path=/h/toolset/backups
now_date=`date +%Y-%m-%d`

cd ${mongo_db_backup_path}
for base in ${mongo_databases_list[@]};
do
  echo "$(date "+%Y-%m-%d %H-%M-%S"): Start backup db of $base."
  mongodump --host ${mongo_host} --port ${mongo_port} --db $base --out ${mongo_db_backup_path}/${now_date}
  tar -zcvf ${mongo_archive_name}.${now_date}.tar.gz ${mongo_db_backup_path}/${now_date}
  echo "$(date "+%Y-%m-%d %H-%M-%S"): Complete backup db of $base."
  rm -rf ${mongo_db_backup_path}/${now_date}
done
find ${mongo_db_backup_path}/*.gz -mtime +2 -exec rm {} \;
