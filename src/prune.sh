if [ -n "$BACKUP_RETENTION_IN_DAYS" ]; then
  echo "Pruning backups older than ${BACKUP_RETENTION_IN_DAYS} days..."
  find /backups/* -mtime +$BACKUP_RETENTION_IN_DAYS -exec rm {} \;
fi
