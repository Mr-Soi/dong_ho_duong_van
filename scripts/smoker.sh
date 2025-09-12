echo "smoke loop start"
[ -d /logs ] || mkdir -p /logs
: > /logs/smoke_latest.log
while true; do
  TS=$(date +%Y%m%d_%H%M%S)
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://web:8080/ping || echo 000)
  LINE="$TS $CODE"
  printf "%s\n" "$LINE" >> /logs/smoke_latest.log
  printf "%s\n" "$LINE"
  sleep 300
done