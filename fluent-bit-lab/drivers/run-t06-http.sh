#!/bin/sh
# t06: HTTP input on 127.0.0.1:18084 + monitoring server on 127.0.0.1:19084.
# Starts Fluent Bit in the background, POSTs one JSON record with curl,
# reads the monitoring endpoints, then stops Fluent Bit.
set -u
FB=${FB:-fluent-bit}
LAB=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
rm -f "$LAB/outputs/t06-http.log"
cd "$LAB/configs"
"$FB" -c t06-http-input.conf > "$LAB/transcripts/t06-http-server.txt" 2>&1 &
FB_PID=$!
sleep 3
{
  echo '$ curl -s http://127.0.0.1:19084/api/v1/metrics'
  curl -s http://127.0.0.1:19084/api/v1/metrics; echo
  echo '$ curl -s -i http://127.0.0.1:19084/api/v1/health   (checked: 404 in v5.1.5)'
  curl -s -i http://127.0.0.1:19084/api/v1/health; echo
  echo '$ curl -s -X POST http://127.0.0.1:18084/ -H "Content-Type: application/json" -d @payload'
  cat "$LAB/fixtures/http-payload.json"; echo
  curl -s -i -X POST http://127.0.0.1:18084/ \
    -H 'Content-Type: application/json' \
    --data-binary @"$LAB/fixtures/http-payload.json"; echo
  sleep 2
  echo '$ cat ../outputs/t06-http.log'
  cat "$LAB/outputs/t06-http.log"
  echo '$ curl -s http://127.0.0.1:19084/api/v1/uptime'
  curl -s http://127.0.0.1:19084/api/v1/uptime; echo
  echo '$ curl -s http://127.0.0.1:19084/api/v1/metrics/prometheus | head -4'
  curl -s http://127.0.0.1:19084/api/v1/metrics/prometheus | head -4
} > "$LAB/transcripts/t06-http-client.txt" 2>&1
kill -TERM "$FB_PID" 2>/dev/null
wait "$FB_PID" 2>/dev/null
cat "$LAB/transcripts/t06-http-client.txt"
