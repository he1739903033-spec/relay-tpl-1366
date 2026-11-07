#!/usr/bin/env bash
set -u
echo "RELAY1366 BEGIN"
echo "=== ipinfo (runner egress) ==="
curl -sSk -m 25 https://ipinfo.io/json
echo
echo "=== httpbin POST passthrough ==="
HB=$(curl -sSk -m 30 -X POST https://httpbin.org/anything \
  -H 'Authorization: Bearer DUMMY_ABC123' \
  -H 'X-Forwarded-For: 198.51.100.77' \
  -H 'X-Custom-Test: keepme-1366' \
  -H 'Content-Type: application/json' \
  -d '{"probe":"gha_1366","n":1}')
echo "$HB"
case "$HB" in
  *DUMMY_ABC123*keepme-1366*gha_1366*) PASS=1 ;;
  *) PASS=0 ;;
esac
echo "HTTPBIN_PASSTHROUGH=$PASS"
if [ "$PASS" = "1" ]; then
  echo "=== T1 GET /v1/models ==="
  curl -sSk -m 30 -o /tmp/t1.body -w 'code=%{http_code} size=%{size_download} ct=%{content_type}\n' https://changapi.club/v1/models
  head -c 400 /tmp/t1.body; echo
  sleep 3
  echo "=== T2 GET /api/v1/settings/public ==="
  curl -sSk -m 30 -o /tmp/t2.body -w 'code=%{http_code} size=%{size_download} ct=%{content_type}\n' https://changapi.club/api/v1/settings/public
  head -c 200 /tmp/t2.body; echo
  sleep 3
  echo "=== T3 POST /api/v1/auth/login (dummy, single shot) ==="
  curl -sSk -m 30 -X POST https://changapi.club/api/v1/auth/login \
    -H 'Content-Type: application/json' \
    -d '{"email":"probe-1366@example.com","password":"Xx1366!dummy","turnstile_token":"DUMMY-1366"}' \
    -w '\ncode=%{http_code} size=%{size_download} ct=%{content_type}\n'
fi
echo "RELAY1366 END"
exit 1
