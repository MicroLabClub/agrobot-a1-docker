#!/bin/bash -e
# VPN credentials come from balena device variables (never baked into the image).
# NOTE: no `set -x` here on purpose — it would leak VPN_PASS into balena logs.
: "${VPN_USER:?VPN_USER not set (balena device variable)}"
: "${VPN_PASS:?VPN_PASS not set (balena device variable)}"

umask 077
printf '%s\n%s\n' "$VPN_USER" "$VPN_PASS" > /dev/shm/vpn-auth
chmod 600 /dev/shm/vpn-auth

# Split-tunnel: only 10.9.0.0/22 routes through the VPN, so balena's own
# management/OTA connection stays on the device's normal path.
openvpn --config /etc/openvpn/profile.ovpn --auth-user-pass /dev/shm/vpn-auth --auth-nocache &

# SSHD foreground (keeps the container alive)
exec /usr/sbin/sshd -D
