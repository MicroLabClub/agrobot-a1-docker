#!/bin/bash -e
set -x  # Debug logging for Balena

openvpn --config /etc/openvpn/profile.ovpn --auth-user-pass /etc/openvpn/profile.txt &

# SSHD forreground
exec /usr/sbin/sshd -D