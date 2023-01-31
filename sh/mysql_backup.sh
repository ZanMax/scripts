#!/bin/bash

USER="root"
PASSWORD=""
OUTPUT="/root/db_backups"

rm "$OUTPUT/*gz" > /dev/null 2>&1

if [ -z $PASSWORD ]; then
    databases=`mysql --user=$USER -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`
    for db in $databases; do
        if [[ "$db" != "information_schema" ]] && [[ "$db" != _* ]] ; then
            echo "Dumping database: $db"
            mysqldump --force --opt --routines --user=$USER --databases $db > $OUTPUT/`date +%Y%m%d`.$db.sql
            gzip $OUTPUT/`date +%Y%m%d`.$db.sql
        fi
    done
else
    databases=`mysql --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`
    for db in $databases; do
        if [[ "$db" != "information_schema" ]] && [[ "$db" != _* ]] ; then
            echo "Dumping database: $db"
            mysqldump --force --opt --routines --user=$USER --password=$PASSWORD --databases $db > $OUTPUT/`date +%Y%m%d`.$db.sql
            gzip $OUTPUT/`date +%Y%m%d`.$db.sql
        fi
    done
fi