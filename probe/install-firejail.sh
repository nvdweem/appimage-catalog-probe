#!/bin/bash
# The same firejail worker.sh installs (Alpine build + musl), run from the catalog checkout.
set -e
mkdir -p firejail
[ -s alpine-firejail-git20230825.tar.gz ] || wget -c -q "https://github.com/AppImage/appimage.github.io/releases/download/deps/alpine-firejail-git20230825.tar.gz"
MUSL=$(wget -q "https://dl-cdn.alpinelinux.org/alpine/v3.13/main/x86_64/" -O - | grep -o 'musl-1[^"]*\.apk' | head -n 1)
wget -c -q "https://dl-cdn.alpinelinux.org/alpine/v3.13/main/x86_64/$MUSL"
sudo tar xf alpine-firejail-git20230825.tar.gz
sudo tar xf musl-*.apk -C ./firejail/ 2>/dev/null || true
sudo tar xf firejail-0*.apk -C ./firejail/ 2>/dev/null || true
sudo cp -Rf ./firejail/etc/* /etc/; sudo cp -Rf ./firejail/lib/* /lib/; sudo cp -Rf ./firejail/usr/* /usr/
sudo chown root:root /usr/bin/firejail; sudo chmod u+s /usr/bin/firejail
firejail --version | head -1
