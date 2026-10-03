# dagrev.is side of the tunnel. See "Tunnel" in nix/README.md.
{ lib, ... }:

{
  users.users.tunnel = {
    isSystemUser = true;
    group = "tunnel";
    openssh.authorizedKeys.keys = [
      ''restrict,port-forwarding,permitlisten="0.0.0.0:2222" ${lib.fileContents /etc/nixos/tunnel.pub}''
    ];
  };
  users.groups.tunnel = { };

  networking.firewall.allowedTCPPorts = [ 2222 ];

  # Home sees all tunnel clients as loopback, so limit each IP here.
  networking.firewall.extraCommands = ''
    iptables -I nixos-fw -p tcp --dport 2222 --syn -m connlimit --connlimit-above 5 -j nixos-fw-refuse
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
