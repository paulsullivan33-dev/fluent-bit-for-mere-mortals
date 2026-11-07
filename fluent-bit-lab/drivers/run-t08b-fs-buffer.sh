#!/bin/sh
# t08b: filesystem buffering. While the output endpoint is down and
# retries are pending, list the chunk files under the storage path.
set -u
FB=${FB:-fluent-bit}
LAB=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
rm -rf "$LAB/outputs/fsbuffer"
cd "$LAB/configs"
"$FB" -c t08b-fs-buffer.conf > "$LAB/transcripts/t08b-fs-buffer.txt" 2>&1 &
FB_PID=$!
sleep 7
{
  echo '$ find ../outputs/fsbuffer -type f (while Fluent Bit is running, endpoint down)'
  find "$LAB/outputs/fsbuffer" -type f | sort
  echo
  echo '$ ls -l of the chunk files'
  find "$LAB/outputs/fsbuffer" -type f -exec ls -l {} \;
} > "$LAB/transcripts/t08b-fs-buffer-files.txt" 2>&1
kill -TERM "$FB_PID" 2>/dev/null
wait "$FB_PID" 2>/dev/null
cat "$LAB/transcripts/t08b-fs-buffer-files.txt"
