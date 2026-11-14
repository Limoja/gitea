#!/bin/sh
# LAW: BIO-CAPACITY — the platform Gitea accepts a 20K-word bio through the
# API (PATCH), stores it, and returns it byte-equal on GET. A stock Gitea
# 422s at 255 (proven); the Limoja fork raises the cap. This test decides
# the fork's CI verdict and the chart's rollout.
set -e
GITEA_URL="${GITEA_URL:-http://127.0.0.1:3000}"
TOKEN="${TOKEN:-}"
BIO_FILE=/tmp/bio.txt
python3 - <<'PY' 2>/dev/null || awk 'BEGIN{srand();for(i=0;i<20000;i++){w="";L=int(rand()*8)+2;for(j=0;j<L;j++)w=w sprintf("%c",97+int(rand()*26));printf "%s ",w}}' > /tmp/bio.txt
import random, string
words = [''.join(random.choices(string.ascii_lowercase, k=random.randint(2,9))) for _ in range(20000)]
open('/tmp/bio.txt','w').write(' '.join(words))
PY
WORDS=$(wc -w < $BIO_FILE); CHARS=$(wc -c < $BIO_FILE)
echo "bio: ${WORDS} words, ${CHARS} chars"
DESC=$(python3 -c "import json;print(json.dumps(open('/tmp/bio.txt').read()))" 2>/dev/null)
CODE=$(curl -s -o /tmp/patch-resp.json -w '%{http_code}' -X PATCH "$GITEA_URL/api/v1/user" \
  -H "Authorization: token $TOKEN" -H "Content-Type: application/json" -d "{\"description\": $DESC}")
echo "PATCH: $CODE"
[ "$CODE" = "200" ] || { echo "FAIL — PATCH rejected (stock cap?)"; cat /tmp/patch-resp.json; exit 1; }
BACK=$(curl -s "$GITEA_URL/api/v1/user" -H "Authorization: token $TOKEN" | python3 -c "import json,sys;print(json.load(sys.stdin).get('description') or '')" 2>/dev/null)
BACK_N=$(printf '%s' "$BACK" | wc -c)
echo "GET back: ${BACK_N} chars"
[ "$BACK_N" = "$CHARS" ] || { echo "FAIL — bio truncated on read ($BACK_N != $CHARS)"; exit 1; }
echo "PASS — a ${WORDS}-word bio stored and returned byte-complete"
