#!/bin/bash


TOTAL=`cat /proc/meminfo | grep MemTotal: | awk '{print $2}'`
USEDMEM=`cat /proc/meminfo | grep Active: | awk '{print $2}'`
LOG=/tmp/test.log
PERCENT_USED=87
echo > $LOG
if [ "$USEDMEM" -gt 0 ]
 then
     USEDMEMPER=$[$USEDMEM * 100 / $TOTAL ]
     echo "$(date +'%d/%m/%Y'): Current used memory = $USEDMEMPER %"
     if [ "$USEDMEMPER" -gt "$PERCENT_USED" ]; then

         echo "$(date +'%d/%m/%Y'): Used memory: $USEDMEMPER" >> $LOG

        sites=$(ls /var/www/|grep -v '.zip' | grep -v html | grep  -v req | grep -iv 'back*' | grep -v '__*');
        #set -x
        for i in $sites; do
                echo "site $i"
                sudo systemctl restart  ${i/./_};
                sleep 10
        done
        #set +x

 fi
fi
cat $LOG