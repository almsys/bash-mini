#!/bin/bash

# Disk space monitoring
THRESHOLD=80
EMAIL="admin@asia.com"
EXCLUDE_PARTITIONS="/dev/loop|/dev/loop2"

# Проверяем каждую файловую систему
df -H | grep -vE '^Filesystem|tmpfs|cdrom|$EXCLUDE_PARTITIONS' | awk '{ print $5 " " $1 }' | while read output;
do
        usage=$(echo $output | awk '{ print $1 }' | sed 's/%//g')
        echo "Заполненость % - $usage"
        partition=$(echo $output | awk '{ print $2 }')
        echo "Имя раздела - $partition"

        if [ $usage -ge $THRESHOLD ]; then
                echo "WARNING: Partition $partition is ${usage}% full" | mail -s "Disk $partition is crtitcal full, threshold greater or equal %60" "$EMAIL"
                # Проверяем что что email ушел
                if [ $? -eq 0 ]; then
                        echo "Email was send to recipient"
                else
                        echo "Email not sended due errors"
                        exit 1;
                fi

        else
                echo "OK: Partition $partition is ${usage}% full"
        fi
done
