#!/bin/bash
# Candidate fix for appimage.github.io's worker.sh: when waiting for the application's window, do not count
# tiny windows. Firefox (and other GTK/X11 apps) map a 10x10 helper window first; on a cold runner Firefox's
# real window follows ~9s later, after worker.sh has already decided "a window appeared" and screenshotted
# the 10x10 helper. Only a window of at least 50x50 now ends the wait.
set -e
W="$1"
perl -0pi -e 's/(set -o pipefail\n)/$1\n# A window that can show something: at least 50x50 (Firefox first maps a 10x10 helper window)\nreal_window() { grep -E "0x.*\\": \\\\(" | grep -oE " [0-9]+x[0-9]+[-+]" | tr -d " +-" | awk -Fx '"'"'\$1 >= 50 && \$2 >= 50 { found = 1 } END { exit !found }'"'"' ; }\n/' "$W"
sed -i "s/grep -qE '0x\.\*\": \\\\(' <<< /real_window <<< /g" "$W"
echo "== patched worker.sh:"
grep -n -E "real_window" "$W"
