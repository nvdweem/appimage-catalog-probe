#!/bin/bash
# What the runner provides that a container does not: session/user buses, systemd user instance, a11y.
echo "id: $(id)"
echo "nproc: $(nproc)  kernel: $(uname -r)"
env | grep -E '^(XDG_|DBUS|DISPLAY|WAYLAND|HOME|LANG|LC_)' | sort
echo "-- /run/user/$(id -u):"; ls -la /run/user/$(id -u) 2>&1
echo "-- systemd --user: $(systemctl --user is-system-running 2>&1)"
echo "-- user bus names:"; busctl --user list --no-pager 2>&1 | head -30
echo "-- dbus-launch: $(command -v dbus-launch || echo none)  at-spi-bus-launcher: $(ls /usr/libexec/at-spi-bus-launcher 2>/dev/null || echo none)"
echo "-- firefox: $(readlink -f "$(command -v firefox)") $(firefox --version 2>&1 | tail -1)"
echo "-- existing firefox profiles:"; ls -la ~/.mozilla ~/snap 2>&1 | head
echo "-- system bus: $(ls -la /run/dbus/system_bus_socket 2>&1)"
