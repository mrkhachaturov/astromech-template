#!/bin/bash
# Remove voice message files older than 7 days
# Runs daily via crontab at 3 AM

VOICE_DIR="/path/to/astromech/runtime/voice-messages"

# Log start
echo "[$(date)] Starting cleanup of voice messages older than 7 days"

# Remove old files
find "$VOICE_DIR" \
  -type f \
  \( -name "*.ogg" -o -name "*.mp3" -o -name "*.opus" \) \
  -mtime +7 \
  -print \
  -delete | while read file; do
    echo "Deleted: $file"
  done

# Count remaining files
count=$(find "$VOICE_DIR" -type f | wc -l)
echo "[$(date)] Cleanup complete. Remaining files: $count"
