# Nix

Nix & NixOS configuration for declarative, reliable and reproducible system.

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

### Home Share

`home-share 3000` on home makes port 3000 public at `https://dagrev.is:23000`. The path stays the same, so `https://dagrev.is:23000/a/b` opens `/a/b` on port 3000. The port stays public until `home-unshare 3000` or a restart of the tunnel. Without a port, `home-share` lists the shared ports and `home-unshare` unshares all of them.

The forward listens on `172.17.0.1:33000` (docker0), so only containers on dagrev.is can connect to it. nginx listens on 23000 with the Let's Encrypt cert and sends the requests to the forward. A port works only if nginx has a server block for it: now 3000 (navda), 7777 (`:Md`) and 8000 (`serve-http`).

Unshare a port when you are done. Port scanners find open ports.

Setup on dagrev.is:

1. Add `"23000:23000"`, `"27777:27777"` and `"28000:28000"` to the `ports` of `nginx` in `~/docker-compose.yml`.
2. Add this server block to `http` in `~/nginx.conf`. The navda dev server uses HTTPS with mkcert, and nginx does not verify that cert.

   ```nginx
   server {
       listen 23000 ssl;
       server_name dagrev.is;

       ssl_certificate /etc/letsencrypt/live/dagrev.is/fullchain.pem;
       ssl_certificate_key /etc/letsencrypt/live/dagrev.is/privkey.pem;

       error_page 497 =301 https://$host:$server_port$request_uri;

       location / {
           proxy_pass https://172.17.0.1:33000;
           proxy_set_header Host $http_host;
       }
   }
   ```

3. Add the same block for 27777 and for 28000. Change `listen` to that port, and change `proxy_pass` to `http://172.17.0.1:37777` or `http://172.17.0.1:38000`. `:Md` and `serve-http` use plain HTTP.
4. `docker-compose up -d nginx`. This recreates nginx, so all sites are down for a few seconds.
