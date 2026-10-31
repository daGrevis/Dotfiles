# dagrev.is side of the tunnel. See "Tunnel" in nix/README.md.
{ lib, ... }:

{
  users.users.tunnel = {
    isSystemUser = true;
    group = "tunnel";
    # 172.17.0.1 is docker0, so only containers reach the "Home Share" forwards.
    openssh.authorizedKeys.keys = [
      ''restrict,port-forwarding,permitlisten="0.0.0.0:2222",permitlisten="172.17.0.1:*" ${lib.fileContents /etc/nixos/tunnel.pub}''
    ];
  };
  users.groups.tunnel = { };

  networking.firewall.allowedTCPPorts = [ 2222 ];

  # Home sees all tunnel clients as loopback, so limit each IP here.
  networking.firewall.extraCommands = ''
    iptables -I nixos-fw -p tcp --dport 2222 --syn -m connlimit --connlimit-above 5 -j nixos-fw-refuse
    # nginx in Docker connects to the "Home Share" forwards on docker0.
    iptables -I nixos-fw -s 172.16.0.0/12 -d 172.17.0.1 -p tcp --dport 30000:39999 -j nixos-fw-accept
  '';

  # mkAfter: every line after Match applies only to that user, so it must be last.
  services.openssh.extraConfig = lib.mkAfter ''
    Match User tunnel
      AllowTcpForwarding remote
      AllowStreamLocalForwarding no
      GatewayPorts clientspecified
      ClientAliveInterval 30
      ClientAliveCountMax 3
  '';
}
