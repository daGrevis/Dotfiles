# Unifi

The `./rainbow-leds.sh` and `./uled-weather.sh` scripts let you control the LEDs on the UniFi Dream Router (UDR) and similar devices.

The `./floodlight-keepalive.sh` script keeps a UniFi Protect floodlight ON while a
watched camera is detecting activity, dimming it step-by-step and turning it off
after a hold window. See `floodlight-keepalive.md` for the full design notes.

## Persisting across reboots

The `.service` units run their scripts under systemd so they survive reboots and
auto-restart on crash. Deploy on the device (as root), e.g. for `uled-weather`:

```
cp uled-weather.sh /root/uled-weather.sh
cp uled-weather.service /etc/systemd/system/uled-weather.service
systemctl daemon-reload
systemctl enable --now uled-weather.service
```

Same steps for `floodlight-keepalive` (edit its `ExecStart` flags first).

Note: `/etc/systemd/system` and `/root` survive reboots but may be wiped by a
UniFi OS firmware upgrade; re-run after a major upgrade.

