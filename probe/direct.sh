#!/bin/bash
# Firefox alone in the worker's sandbox (firejail --noprofile --net=none), one fresh profile per variant:
# how long until its main (Navigator) window exists, and what it prints.
OUT="$1"; mkdir -p "$OUT"; export DISPLAY=:99
run() {
  name="$1"; shift
  home=$(mktemp -d); pkill -x firefox; sleep 1
  start=$(date +%s.%N)
  env HOME="$home" "$@" firejail --quiet --noprofile --net=none firefox --new-instance about:blank > "$OUT/$name.log" 2>&1 &
  pid=$!; helper=""; nav=""
  for i in $(seq 1 90); do
    sleep 0.5
    W=$(xwininfo -tree -root 2>/dev/null)
    t=$(echo "$(date +%s.%N) - $start" | bc)
    [ -z "$helper" ] && grep -q '("firefox" "Firefox")' <<< "$W" && helper=$t
    grep -q '("Navigator"' <<< "$W" && { nav=$t; break; }
  done
  import -window root "$OUT/$name.png" 2>/dev/null
  printf '%-28s helper=%-6s navigator=%s\n' "$name" "${helper:-never}" "${nav:-never (>45s)}"
  kill $pid 2>/dev/null; pkill -x firefox; sleep 2
}
run baseline
run baseline-again
run no-user-bus         env -u XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS=disabled:
run no-at-bridge        NO_AT_BRIDGE=1
run no-a11y-no-bus      env -u XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS=disabled: NO_AT_BRIDGE=1
echo "-- baseline stderr:"; head -30 "$OUT/baseline.log"
