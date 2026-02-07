#!/bin/bash

# Nginx log parser for 5xx errors
LOG_FILE="/var/log/nginx/access.log"
HOUR_AGO=$(date -d 'now -1 hour' '+%d/%b/%Y:%H')

echo "=== 5xx Errors in the last hour ==="

# Фильтруем логи за последний час с ошибками 5xx
grep "$HOUR_AGO" "$LOG_FILE" | grep -E ' 5[0-9][0-9] [0-9]' | awk '{print $7}' | sort | uniq -c | sort -rn | head -10

echo ""
echo "=== Total 5xx errors ==="
grep "$HOUR_AGO" "$LOG_FILE" | grep -c ' 5[0-9][0-9] [0-9]'
