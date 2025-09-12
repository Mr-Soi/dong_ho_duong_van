echo "smoke loop start"
[ -d /logs ] || mkdir -p /logs
while true; do
  TS=$(date +%Y%m%d_%H%M%S)
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://web:8080/ping || echo 000)
  DAY=$(date +%Y%m%d)
  LOG="/logs/smoke_${DAY}.log"
  LINE="${TS} ${CODE}"
  printf "%s\n" "$LINE" >> "$LOG"
  printf "%s\n" "$LINE" > /logs/smoke_latest.log
  sleep 300
done