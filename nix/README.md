# Nix

Nix & NixOS configuration for declarative, reliable and reproducible system.

## Setup for VirtualBox on Windows

### Setting the Icon File

```sh
cd C:\Program Files\Oracle\VirtualBox
VBoxManage.exe modifyvm Nixo --iconfile "C:\Users\me\Pictures\Icons\nixos.png"
```

## Tunnel

Reverse SSH tunnel from home to dagrev.is. Port 2222 on dagrev.is leads to sshd on home.

### One-Time Setup

On home:

1. `ssh-keygen -t ed25519 -N "" -C tunnel -f ~/.ssh/tunnel_ed25519`
2. `scp ~/.ssh/tunnel_ed25519.pub dagrev.is:`
3. Add the client public keys (for example, Termius) to `~/.ssh/authorized_keys`.

On dagrev.is:

4. `sudo install -m 644 ~/tunnel_ed25519.pub /etc/nixos/tunnel.pub && rm ~/tunnel_ed25519.pub`
5. Add `/home/dagrevis/Dotfiles/nix/etc/nixos/tunnel-server.nix` to `imports` in `/etc/nixos/configuration.nix`.
6. `sudo nixos-rebuild switch`

On home:

8. `sudo nixos-rebuild switch`
9. `systemctl --user enable --now tunnel`

In the client:

10. Add host `dagrev.is`, port `2222`, user `dagrevis`, with the key from step 3.

### Connect

`ssh -p 2222 dagrevis@dagrev.is`
