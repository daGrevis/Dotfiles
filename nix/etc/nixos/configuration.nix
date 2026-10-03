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
      cache.enable = true;
    };
  };

systemd.user.services.earlyoom = {
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.earlyoom}/bin/earlyoom -g";
      Restart = "on-failure";
    };
  };

  services = {
    openssh = {
      enable = true;

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        # Tunnel clients all come from loopback, so scans would lock them out.
        PerSourcePenaltyExemptList = "127.0.0.1,::1";
        # Dead tunnel sessions count toward the limit on dagrev.is, so close them fast.
        ClientAliveInterval = 15;
        ClientAliveCountMax = 3;
      };
    };

    displayManager = {
      defaultSession = "none+awesome";

      autoLogin = {
        enable = true;
        user = "dagrevis";
      };
    };

    xserver = {
      enable = true;

      xkb.layout = "lv";

      displayManager = {
        lightdm.enable = true;
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
    virtualbox.guest.enable = true;
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

  nix.settings = {
    trusted-users = [ "root" "dagrevis" ];
    experimental-features = [ "nix-command" ];
  };

  security.sudo.wheelNeedsPassword = false;

  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-curses;

  programs.nix-ld.enable = true;

  programs.zsh.enable = true;

}
