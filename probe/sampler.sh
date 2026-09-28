#!/bin/bash
# Runs as root next to worker.sh: every 0.5s the named X windows and firefox processes; screenshots every
# 2s; and, while Firefox has only its helper window, an strace + wchan snapshot of every firefox process.
OUT="$1"; SECS="$2"; export DISPLAY=:99
mkdir -p "$OUT/shots"; chmod 777 "$OUT"
START=$(date +%s.%N); traced=0
for i in $(seq 1 $((SECS * 2))); do
  t=$(echo "$(date +%s.%N) - $START" | bc)
  W=$(xwininfo -tree -root 2>/dev/null | grep '": ("' | sed 's/^ *//' | cut -c1-90 | tr '\n' '|')
  FF=$(pgrep -x firefox | tr '\n' ' ')
  printf 't=%6.1f ff=[%s] %s\n' "$t" "$FF" "${W:-none}" >> "$OUT/timeline.log"
  [ $((i % 4)) = 0 ] && import -window root "$OUT/shots/$(printf '%05.1f' "$t").png" 2>/dev/null
  if [ -n "$FF" ] && ! grep -q Navigator <<< "$W" && [ $traced -lt 3 ]; then
    traced=$((traced + 1))
    for p in $(pgrep firefox); do
      {
        echo "===== t=$t pid $p: $(tr '\0' ' ' < /proc/$p/cmdline | cut -c1-150)"
        echo "wchan: $(cat /proc/$p/wchan 2>/dev/null)"
        echo "-- fds:"; ls -l /proc/$p/fd 2>/dev/null | awk '{print $NF}' | sort | uniq -c | sort -rn | head -15
        echo "-- threads' wchan:"; for tsk in /proc/$p/task/*; do echo "$(cat $tsk/comm) $(cat $tsk/wchan)"; done | sort | uniq -c | head -30
        echo "-- strace 3s:"; timeout 3 strace -f -tt -s 120 -p "$p" 2>&1 | head -80
      } >> "$OUT/stuck-$traced.log" 2>&1
    done
    ss -xp 2>/dev/null | grep -i -E 'firefox|dbus' | head -40 >> "$OUT/stuck-$traced.log"
    sleep 3
  fi
  sleep 0.5
done
