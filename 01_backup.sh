#!/bin/bash
BACKUP_DIR="/backup"
SOURCE_DIR="/data"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_$DATE.tar.gz"
RETENTION_DAYS=7

# Создаем директорию для бекапов 
mkdir -p $BACKUP_DIR

# Создаем архив
echo "Creating backup: $BACKUP_FILE"
tar -czf "$BACKUP_DIR/$BACKUP_FILE" "$SOURCE_DIR" 2>/dev/null

# Проверяем успешность
if [ $? -eq 0 ]; then
	echo "Backup completed succesufully"
else
	echo "Backup failed!"
	exit 1
fi

# Удаляем старые backups
echo "Removing old backups older than $RETENTION_DAYS days"
find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +$RETENTION_DAYS -delete

echo "Done!"
