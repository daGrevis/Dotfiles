{ config, pkgs, ... }:

{

  system.stateVersion = "23.05";

  imports =
    [
      ./hardware-configuration.nix
    ];

  boot = {
    loader = {
      grub = {
        enable = true;
        device = "/dev/sda";
      };
      timeout = 1;
    };

    initrd.checkJournalingFS = false;
  };

  fileSystems."/mnt/nixos-shared" = {
    device = "NixOS-Shared";
    fsType = "vboxsf";
    options = [ "rw,nofail" ];
  };

  networking = {
    useDHCP = false;
    interfaces.enp0s3.useDHCP = true;

    firewall.enable = false;
  };

  time.timeZone = "Europe/Riga";

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim
    git
    earlyoom
  ];

  documentation = {
    enable = true;

    man = {
      enable = true;
      generateCaches = true;
    };
  };

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=15s
  '';

  systemd.user.services.virtualbox-resize = {
    description = "VirtualBox Guest: Resize";

    wantedBy = [ "graphical-session.target" ];
    requires = [ "dev-vboxguest.device" ];
    after = [ "dev-vboxguest.device" ];

    unitConfig.ConditionVirtualization = "oracle";

    serviceConfig.ExecStart = "${config.boot.kernelPackages.virtualboxGuestAdditions}/bin/VBoxClient -fv --vmsvga";
  };

  systemd.user.services.earlyoom = {
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.earlyoom}/bin/earlyoom -g";
      Restart = "on-failure";
    };
  };

  services = {
    openssh.enable = true;

    xserver = {
      enable = true;

      layout = "lv";

      displayManager = {
        defaultSession = "none+awesome";
        lightdm.enable = true;

        autoLogin = {
          enable = true;
          user = "dagrevis";
        };
      };

      windowManager = {
        awesome.enable = true;
      };

      desktopManager = {
        wallpaper.mode = "center";
      };
    };
  };

  virtualisation = {
    docker.enable = true;
  };

  users = {
    users = {
      dagrevis = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "docker" "vboxsf" ];
        shell = pkgs.zsh;
      };
    };
  };

  nix.settings.trusted-users = ["root" "dagrevis"];

  security.sudo.wheelNeedsPassword = false;

  programs.gnupg.agent.enable = true;

  programs.zsh.enable = true;

}
