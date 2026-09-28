#!/bin/bash
# Installed as /usr/local/bin/firefox (ahead of /usr/bin on PATH): records how PCPanel's xdg-open starts
# Firefox, then runs the real one with its stdout/stderr kept (PCPanel discards them).
LOG="$HOME/probe/ff-$$.log"
{
  echo "== $(date +%T.%N) firefox $*"
  echo "-- id: $(id)  pid: $$  ppid: $PPID ($(cat /proc/$PPID/comm 2>/dev/null))"
  env | grep -E '^(XDG_|DBUS|DISPLAY|HOME|LANG|LC_|APPIMAGE|APPDIR|ARGV0|OWD|LD_|GTK|GDK|MOZ|NO_AT)' | sort
  echo "-- in firejail: $([ -e /run/firejail ] && echo yes || echo no)"
} >> "$LOG" 2>&1
exec /usr/bin/firefox "$@" >> "$LOG" 2>&1
