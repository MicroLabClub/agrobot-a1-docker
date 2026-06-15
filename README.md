# agrobot-docker-balenaos

Docker image to build Ubuntu for AGROBOT-A1 (balenaOS), including a hardened
VPN client.

## Deploy

```
balena push microlab/agrobot-a1 --nocache
```

## VPN

The device joins the private OpenVPN overlay (`10.9.0.0/22`) on a **split tunnel**,
so balena's own management/OTA connection is never affected.

**Credentials are NOT stored in this repo.** Each device receives its own VPN
username/password as **balena device variables**, injected at runtime:

- `VPN_USER` — per-device username (e.g. `bot-<uuid>`)
- `VPN_PASS` — per-device password

`start.sh` writes these to a tmpfs file at boot and starts OpenVPN. Devices are
provisioned (server user + static IP + balena variables) by the VPN admin
tooling — see the `vpnadmin` project.

### Before `balena push`

Place the fleet's split-tunnel client profile in the repo root as **`profile.ovpn`**
(obtain it from the VPN admin). It is **gitignored on purpose** — it contains the
shared client cert and must never be committed to this public repository.

```
profile.ovpn          # split-tunnel client config (shared certs, NO credentials)
```
